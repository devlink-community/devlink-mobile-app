import 'dart:async';

import 'package:devlink_mobile_app/core/auth/auth_state.dart';
import 'package:devlink_mobile_app/core/config/app_config.dart';
import 'package:devlink_mobile_app/notification/domain/model/app_notification.dart';
import 'package:devlink_mobile_app/notification/domain/usecase/delete_notification_use_case.dart';
import 'package:devlink_mobile_app/notification/domain/usecase/get_notifications_use_case.dart';
import 'package:devlink_mobile_app/notification/domain/usecase/mark_all_notifications_as_read_use_case.dart';
import 'package:devlink_mobile_app/notification/domain/usecase/mark_notification_as_read_use_case.dart';
import 'package:devlink_mobile_app/notification/module/fcm_di.dart';
import 'package:devlink_mobile_app/notification/module/notification_di.dart';
import 'package:devlink_mobile_app/notification/presentation/notification_action.dart';
import 'package:devlink_mobile_app/notification/presentation/notification_state.dart';
import 'package:devlink_mobile_app/core/auth/auth_provider.dart';
import 'package:devlink_mobile_app/notification/service/fcm_service.dart';
import 'package:devlink_mobile_app/notification/service/fcm_token_service.dart';
import 'package:devlink_mobile_app/core/utils/app_logger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_notifier.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  // 의존성
  late final GetNotificationsUseCase _getNotificationsUseCase;
  late final MarkNotificationAsReadUseCase _markAsReadUseCase;
  late final MarkAllNotificationsAsReadUseCase _markAllAsReadUseCase;
  late final DeleteNotificationUseCase _deleteNotificationUseCase;
  late final FCMService _fcmService;
  late final FCMTokenService _fcmTokenService;

  // 스트림 구독 관리
  StreamSubscription? _fcmSubscription;
  ProviderSubscription? _authSubscription;

  // 마지막으로 토큰을 등록한 사용자 ID (중복 방지)
  String? _lastRegisteredUserId;

  String? get _currentUserId {
    AppLogger.debug('_currentUserId 호출됨', tag: 'NotificationAuth');
    final authStateAsync = ref.read(authStateProvider);

    return authStateAsync.when(
      data: (authState) {
        AppLogger.debug('authState 데이터: $authState', tag: 'NotificationAuth');
        switch (authState) {
          case Authenticated(user: final member):
            AppLogger.debug(
              '인증된 사용자 발견: ${member.uid}',
              tag: 'NotificationAuth',
            );
            return member.uid;
          case _:
            AppLogger.debug('인증되지 않은 상태', tag: 'NotificationAuth');
            return null;
        }
      },
      loading: () {
        AppLogger.debug('authState 로딩 중...', tag: 'NotificationAuth');
        return null;
      },
      error: (error, stackTrace) {
        AppLogger.error(
          'authState 에러',
          tag: 'NotificationAuth',
          error: error,
          stackTrace: stackTrace,
        );
        return null;
      },
    );
  }

  @override
  NotificationState build() {
    AppLogger.info(
      'NotificationNotifier.build() 호출됨',
      tag: 'NotificationNotifier',
    );

    // 의존성 주입
    _getNotificationsUseCase = ref.watch(getNotificationsUseCaseProvider);
    _markAsReadUseCase = ref.watch(markNotificationAsReadUseCaseProvider);
    _markAllAsReadUseCase = ref.watch(
      markAllNotificationsAsReadUseCaseProvider,
    );
    _deleteNotificationUseCase = ref.watch(deleteNotificationUseCaseProvider);
    _fcmService = ref.watch(fcmServiceProvider);
    _fcmTokenService = ref.watch(fcmTokenServiceProvider);

    AppLogger.info('의존성 주입 완료', tag: 'NotificationNotifier');

    // FCM 알림 클릭 이벤트 구독
    _subscribeToFCMEvents();
    AppLogger.info('FCM 이벤트 구독 완료', tag: 'NotificationNotifier');

    // 인증 상태 변화 감지 및 처리
    _setupAuthStateListener();
    AppLogger.info('인증 상태 리스너 설정 완료', tag: 'NotificationNotifier');

    // 초기 인증 상태 확인 및 알림 로딩
    _checkInitialAuthStateAndLoadNotifications();

    // 리소스 정리 (메모리 누수 방지)
    ref.onDispose(() {
      AppLogger.info(
        'NotificationNotifier 리소스 정리 시작',
        tag: 'NotificationNotifier',
      );

      // FCM 구독 취소
      _fcmSubscription?.cancel();
      _fcmSubscription = null;

      // 인증 상태 구독 취소
      _authSubscription?.close();
      _authSubscription = null;

      // 등록된 사용자 ID 초기화
      _lastRegisteredUserId = null;

      AppLogger.info(
        'NotificationNotifier 리소스 정리 완료',
        tag: 'NotificationNotifier',
      );
    });

    AppLogger.info(
      '초기 상태 반환: NotificationState()',
      tag: 'NotificationNotifier',
    );
    return const NotificationState();
  }

  /// 인증 상태 변화 리스너 설정 (중복 방지)
  void _setupAuthStateListener() {
    AppLogger.info('인증 상태 리스너 설정', tag: 'NotificationAuth');

    // 기존 구독이 있다면 취소 (중복 방지)
    _authSubscription?.close();

    _authSubscription = ref.listen(authStateProvider, (previous, next) {
      AppLogger.info('authStateProvider 변화 감지됨', tag: 'NotificationAuth');
      AppLogger.logState('인증 상태 변화', {
        'previous': previous?.toString(),
        'next': next.toString(),
      });

      next.when(
        data: (authState) {
          AppLogger.debug('authState 데이터: $authState', tag: 'NotificationAuth');
          switch (authState) {
            case Authenticated(user: final member):
              AppLogger.info(
                '로그인 상태 감지 - 사용자: ${member.nickname}',
                tag: 'NotificationAuth',
              );
              _handleUserLogin(member.uid, member.nickname);
            case Unauthenticated():
              AppLogger.info('로그아웃 상태 감지', tag: 'NotificationAuth');
              _handleUserLogout();
            case Loading():
              AppLogger.debug('로딩 상태', tag: 'NotificationAuth');
              break;
          }
        },
        loading: () {
          AppLogger.debug('authState 로딩 중...', tag: 'NotificationAuth');
        },
        error: (error, stackTrace) {
          AppLogger.error(
            'authState 에러',
            tag: 'NotificationAuth',
            error: error,
            stackTrace: stackTrace,
          );
          _handleAuthError();
        },
      );
    });

    AppLogger.info('인증 상태 리스너 설정 완료', tag: 'NotificationAuth');
  }

  /// 사용자 로그인 처리
  Future<void> _handleUserLogin(String userId, String nickname) async {
    AppLogger.info('사용자 로그인 처리 시작', tag: 'NotificationAuth');
    AppLogger.logState('로그인 정보', {
      'userId': userId,
      'nickname': nickname,
    });

    try {
      // 1. FCM 토큰 등록 (중복 방지)
      await _registerFCMTokenIfNeeded(userId);

      // 2. FCM 서비스 진단 (디버깅용)
      await _fcmTokenService.diagnoseService(userId);

      // 3. 알림 목록 로딩
      Future.microtask(() {
        AppLogger.debug(
          'microtask에서 알림 refresh 액션 호출',
          tag: 'NotificationNotifier',
        );
        onAction(const NotificationAction.refresh());
      });

      AppLogger.info('사용자 로그인 처리 완료', tag: 'NotificationAuth');
    } catch (e) {
      AppLogger.error(
        '사용자 로그인 처리 실패',
        tag: 'NotificationAuth',
        error: e,
      );
    }
  }

  /// 사용자 로그아웃 처리
  Future<void> _handleUserLogout() async {
    AppLogger.info('사용자 로그아웃 처리 시작', tag: 'NotificationAuth');

    try {
      // 1. 알림 상태 초기화
      state = const NotificationState(
        notifications: AsyncData([]),
        unreadCount: 0,
      );

      // 2. 등록된 사용자 ID 초기화
      _lastRegisteredUserId = null;

      AppLogger.info('사용자 로그아웃 처리 완료', tag: 'NotificationAuth');
    } catch (e) {
      AppLogger.error(
        '사용자 로그아웃 처리 실패',
        tag: 'NotificationAuth',
        error: e,
      );
    }
  }

  /// 인증 에러 처리
  void _handleAuthError() {
    AppLogger.warning('인증 에러 처리', tag: 'NotificationAuth');

    state = const NotificationState(
      notifications: AsyncData([]),
      unreadCount: 0,
      errorMessage: '인증 오류가 발생했습니다.',
    );
  }

  /// FCM 토큰 등록 (중복 방지)
  Future<void> _registerFCMTokenIfNeeded(String userId) async {
    // 이미 등록된 사용자인 경우 스킵
    if (_lastRegisteredUserId == userId) {
      AppLogger.debug('이미 등록된 사용자 - FCM 토큰 등록 스킵', tag: 'FCMToken');
      return;
    }

    try {
      AppLogger.info('FCM 토큰 등록 시작', tag: 'FCMToken');

      // 1. 권한 확인
      final hasPermission = await _fcmTokenService.hasNotificationPermission();
      if (!hasPermission) {
        AppLogger.warning('FCM 권한이 없음 - 권한 요청', tag: 'FCMToken');
        final granted = await _fcmTokenService.requestNotificationPermission();
        if (!granted) {
          AppLogger.warning('FCM 권한 거부됨', tag: 'FCMToken');
          return;
        }
      }

      // 2. 토큰 등록
      await _fcmTokenService.registerDeviceToken(userId);

      // 3. 등록 완료 마킹
      _lastRegisteredUserId = userId;

      AppLogger.info('FCM 토큰 등록 완료', tag: 'FCMToken');
    } catch (e) {
      AppLogger.error(
        'FCM 토큰 등록 실패',
        tag: 'FCMToken',
        error: e,
      );
    }
  }

  /// 초기 인증 상태를 확인하고 필요시 알림을 로딩
  void _checkInitialAuthStateAndLoadNotifications() {
    AppLogger.info('초기 인증 상태 확인 시작', tag: 'NotificationAuth');

    Future.microtask(() {
      final authStateAsync = ref.read(authStateProvider);
      AppLogger.debug('현재 authState: $authStateAsync', tag: 'NotificationAuth');

      authStateAsync.when(
        data: (authState) {
          AppLogger.debug(
            '초기 authState 데이터: $authState',
            tag: 'NotificationAuth',
          );
          switch (authState) {
            case Authenticated(user: final member):
              AppLogger.info(
                '초기 상태에서 인증된 사용자 감지: ${member.nickname}',
                tag: 'NotificationAuth',
              );
              _handleUserLogin(member.uid, member.nickname);
            case _:
              AppLogger.debug('초기 상태에서 비인증 상태', tag: 'NotificationAuth');
              _handleUserLogout();
          }
        },
        loading: () {
          AppLogger.debug('초기 authState 로딩 중...', tag: 'NotificationAuth');
        },
        error: (error, stackTrace) {
          AppLogger.error(
            '초기 authState 에러',
            tag: 'NotificationAuth',
            error: error,
            stackTrace: stackTrace,
          );
          _handleAuthError();
        },
      );
    });
  }

  /// FCM 이벤트 구독 (중복 방지)
  void _subscribeToFCMEvents() {
    AppLogger.info('FCM 이벤트 구독 설정', tag: 'FCMEvents');

    // 기존 구독이 있다면 취소 (중복 방지)
    _fcmSubscription?.cancel();

    _fcmSubscription = _fcmService.onNotificationTap.listen((payload) {
      AppLogger.info('FCM 알림 탭 이벤트 수신', tag: 'FCMEvents');
      AppLogger.logState('FCM 페이로드', {
        'type': payload.type.toString(),
        'targetId': payload.targetId,
        'title': payload.title,
        'body': payload.body,
      });

      // 알림 목록 새로고침
      onAction(const NotificationAction.refresh());

      // 특정 알림 처리는 Root에서 처리하도록 위임
      // 여기서는 단순히 알림 목록만 새로고침
    });

    AppLogger.info('FCM 이벤트 구독 완료', tag: 'FCMEvents');
  }

  /// 액션 핸들러 - 모든 사용자 액션의 진입점
  Future<void> onAction(NotificationAction action) async {
    AppLogger.info('NotificationAction 수신', tag: 'NotificationNotifier');
    AppLogger.debug(
      '액션 타입: ${action.runtimeType}',
      tag: 'NotificationNotifier',
    );

    switch (action) {
      case Refresh():
        await _loadNotifications();

      case TapNotification(:final notificationId):
        await _handleTapNotification(notificationId);

      case MarkAsRead(:final notificationId):
        await _markAsRead(notificationId);

      case MarkAllAsRead():
        await _markAllAsRead();

      case DeleteNotification(:final notificationId):
        await _deleteNotification(notificationId);
    }
  }

  /// 알림 목록 로딩
  Future<void> _loadNotifications() async {
    AppLogger.info('_loadNotifications 시작', tag: 'NotificationData');
    AppLogger.debug(
      '현재 환경: ${AppConfig.useMockAuth ? "Mock" : "Firebase"}',
      tag: 'NotificationData',
    );

    final currentUserId = _currentUserId;
    AppLogger.debug('현재 사용자 ID: $currentUserId', tag: 'NotificationData');

    if (currentUserId == null) {
      AppLogger.warning('사용자 ID가 null - 빈 상태로 설정', tag: 'NotificationData');
      state = const NotificationState(
        notifications: AsyncData([]),
        unreadCount: 0,
      );
      return;
    }

    AppLogger.info('알림 로딩 시작: userId=$currentUserId', tag: 'NotificationData');

    // 로딩 상태로 설정
    state = NotificationState(
      notifications: const AsyncLoading(),
      unreadCount: state.unreadCount,
      errorMessage: state.errorMessage,
    );
    AppLogger.debug('로딩 상태로 변경됨', tag: 'NotificationData');

    try {
      AppLogger.debug('UseCase 호출 중...', tag: 'NotificationData');
      final result = await _getNotificationsUseCase.execute(currentUserId);
      AppLogger.debug(
        'UseCase 결과 타입: ${result.runtimeType}',
        tag: 'NotificationData',
      );
      AppLogger.debug('UseCase 결과: $result', tag: 'NotificationData');

      if (result is AsyncData) {
        final notifications = result.value ?? [];
        final unreadCount = notifications.where((n) => !n.isRead).length;

        AppLogger.info(
          '알림 데이터 로드 성공: ${notifications.length}개, 읽지않음: $unreadCount개',
          tag: 'NotificationData',
        );

        state = NotificationState(
          notifications: AsyncData(notifications),
          unreadCount: unreadCount,
          errorMessage: null,
        );

        AppLogger.debug(
          '상태 업데이트 완료: ${state.notifications.runtimeType}',
          tag: 'NotificationData',
        );
      } else if (result is AsyncError) {
        AppLogger.error(
          'UseCase에서 에러 반환',
          tag: 'NotificationData',
          error: result.error,
          stackTrace: result.stackTrace,
        );
        state = NotificationState(
          notifications: AsyncError(result.error!, result.stackTrace!),
          unreadCount: state.unreadCount,
          errorMessage: '알림을 불러오는데 실패했습니다.',
        );
      }
    } catch (e, stack) {
      AppLogger.error(
        '예외 발생',
        tag: 'NotificationData',
        error: e,
        stackTrace: stack,
      );

      state = NotificationState(
        notifications: AsyncError(e, stack),
        unreadCount: state.unreadCount,
        errorMessage: '알림을 불러오는데 실패했습니다: $e',
      );
    }
  }

  /// 알림 탭 처리
  Future<void> _handleTapNotification(String notificationId) async {
    AppLogger.info('알림 탭 처리: $notificationId', tag: 'NotificationAction');

    // 읽음 처리
    await _markAsRead(notificationId);

    // 여기서 필요한 경우 해당 알림의 타겟으로 내비게이션하는 로직을 추가할 수 있음
    // 예: 게시글 알림이면 게시글 상세로 이동 등
    // 이 부분은 Root에서 처리하도록 설계됨
  }

  /// 단일 알림 읽음 처리
  Future<void> _markAsRead(String notificationId) async {
    AppLogger.info('단일 알림 읽음 처리: $notificationId', tag: 'NotificationAction');

    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      AppLogger.warning('사용자 ID가 null - 읽음 처리 불가', tag: 'NotificationAction');
      return;
    }

    try {
      final result = await _markAsReadUseCase.execute(
        currentUserId,
        notificationId,
      );

      switch (result) {
        case AsyncData(:final value) when value:
          AppLogger.info('알림 읽음 처리 성공', tag: 'NotificationAction');
          _updateNotificationReadStatus(notificationId, true);

        case AsyncError(:final error):
          AppLogger.error(
            '알림 읽음 처리 실패',
            tag: 'NotificationAction',
            error: error,
          );
          state = state.copyWith(errorMessage: '알림 읽음 처리에 실패했습니다.');

        default:
          AppLogger.warning('알림 읽음 처리 결과를 알 수 없음', tag: 'NotificationAction');
          break;
      }
    } catch (e) {
      AppLogger.error(
        '알림 읽음 처리 예외',
        tag: 'NotificationAction',
        error: e,
      );
      state = state.copyWith(errorMessage: '알림 읽음 처리 중 오류가 발생했습니다.');
    }
  }

  /// 모든 알림 읽음 처리
  Future<void> _markAllAsRead() async {
    AppLogger.info('모든 알림 읽음 처리', tag: 'NotificationAction');

    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      AppLogger.warning(
        '사용자 ID가 null - 모든 읽음 처리 불가',
        tag: 'NotificationAction',
      );
      return;
    }

    try {
      final result = await _markAllAsReadUseCase.execute(currentUserId);

      switch (result) {
        case AsyncData(:final value) when value:
          AppLogger.info('모든 알림 읽음 처리 성공', tag: 'NotificationAction');
          _updateAllNotificationsReadStatus();

        case AsyncError(:final error):
          AppLogger.error(
            '모든 알림 읽음 처리 실패',
            tag: 'NotificationAction',
            error: error,
          );
          state = state.copyWith(errorMessage: '모든 알림 읽음 처리에 실패했습니다.');

        default:
          AppLogger.warning(
            '모든 알림 읽음 처리 결과를 알 수 없음',
            tag: 'NotificationAction',
          );
          break;
      }
    } catch (e) {
      AppLogger.error(
        '모든 알림 읽음 처리 예외',
        tag: 'NotificationAction',
        error: e,
      );
      state = state.copyWith(errorMessage: '모든 알림 읽음 처리 중 오류가 발생했습니다.');
    }
  }

  /// 알림 삭제
  Future<void> _deleteNotification(String notificationId) async {
    AppLogger.info('알림 삭제: $notificationId', tag: 'NotificationAction');

    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      AppLogger.warning('사용자 ID가 null - 삭제 불가', tag: 'NotificationAction');
      return;
    }

    try {
      final result = await _deleteNotificationUseCase.execute(
        currentUserId,
        notificationId,
      );

      switch (result) {
        case AsyncData(:final value) when value:
          AppLogger.info('알림 삭제 성공', tag: 'NotificationAction');
          _removeNotificationFromState(notificationId);

        case AsyncError(:final error):
          AppLogger.error(
            '알림 삭제 실패',
            tag: 'NotificationAction',
            error: error,
          );
          state = state.copyWith(errorMessage: '알림 삭제에 실패했습니다.');

        default:
          AppLogger.warning('알림 삭제 결과를 알 수 없음', tag: 'NotificationAction');
          break;
      }
    } catch (e) {
      AppLogger.error(
        '알림 삭제 예외',
        tag: 'NotificationAction',
        error: e,
      );
      state = state.copyWith(errorMessage: '알림 삭제 중 오류가 발생했습니다.');
    }
  }

  /// 특정 알림의 읽음 상태 업데이트
  void _updateNotificationReadStatus(String notificationId, bool isRead) {
    // AsyncData인 경우 직접 .value로 접근
    if (state.notifications is! AsyncData) return;

    final currentNotifications =
        (state.notifications as AsyncData<List<AppNotification>>).value;

    bool wasUnread = false;
    final updatedNotifications =
        currentNotifications.map((notification) {
          if (notification.id == notificationId) {
            if (!notification.isRead && isRead) {
              wasUnread = true;
            }
            return AppNotification(
              id: notification.id,
              userId: notification.userId,
              type: notification.type,
              targetId: notification.targetId,
              senderName: notification.senderName,
              createdAt: notification.createdAt,
              isRead: isRead,
              description: notification.description,
              imageUrl: notification.imageUrl,
            );
          }
          return notification;
        }).toList();

    final newUnreadCount =
        wasUnread
            ? (state.unreadCount > 0 ? state.unreadCount - 1 : 0)
            : state.unreadCount;

    state = state.copyWith(
      notifications: AsyncData(updatedNotifications),
      unreadCount: newUnreadCount,
    );
  }

  /// 모든 알림의 읽음 상태 업데이트
  void _updateAllNotificationsReadStatus() {
    // AsyncData인 경우 직접 .value로 접근
    if (state.notifications is! AsyncData) return;

    final currentNotifications =
        (state.notifications as AsyncData<List<AppNotification>>).value;

    final updatedNotifications =
        currentNotifications.map((notification) {
          if (!notification.isRead) {
            return AppNotification(
              id: notification.id,
              userId: notification.userId,
              type: notification.type,
              targetId: notification.targetId,
              senderName: notification.senderName,
              createdAt: notification.createdAt,
              isRead: true,
              description: notification.description,
              imageUrl: notification.imageUrl,
            );
          }
          return notification;
        }).toList();

    state = state.copyWith(
      notifications: AsyncData(updatedNotifications),
      unreadCount: 0,
    );
  }

  /// 상태에서 알림 제거
  void _removeNotificationFromState(String notificationId) {
    // AsyncData인 경우 직접 .value로 접근
    if (state.notifications is! AsyncData) return;

    final currentNotifications =
        (state.notifications as AsyncData<List<AppNotification>>).value;

    // 삭제될 알림이 읽지 않은 상태였는지 확인
    final wasUnread = currentNotifications
        .where((n) => n.id == notificationId)
        .any((n) => !n.isRead);

    // 목록에서 해당 알림 제거
    final updatedNotifications =
        currentNotifications
            .where((notification) => notification.id != notificationId)
            .toList();

    final newUnreadCount =
        wasUnread ? state.unreadCount - 1 : state.unreadCount;

    state = state.copyWith(
      notifications: AsyncData(updatedNotifications),
      unreadCount: newUnreadCount,
    );
  }
}
