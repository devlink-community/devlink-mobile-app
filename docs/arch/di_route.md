# 🧩 di_route (Router Provider) 설계 가이드

---

## ✅ 목적

- **GoRouter 객체**를 **Riverpod Provider**를 통해 관리하여 앱의 전체 라우팅 경로를 설정한다.
- di_route는 **오직 경로(path) → Root 연결**만 담당한다.
- Root는 **Notifier 주입, 상태 구독, 액션 연결**을 담당한다.
- Screen은 **순수 UI**만 담당한다.

---

## 📚 전체 아키텍처 흐름 요약

| 계층 | 역할 |
|:---|:---|
| DataSource | 외부 API/DB 호출 및 예외 발생 |
| Repository | DataSource 결과를 Result<T>로 변환 |
| UseCase | Result<T>를 AsyncValue<T>로 변환 |
| Notifier | AsyncValue 상태를 관리하고 액션을 처리 |
| Root | Notifier 주입(ref.watch), 상태 구독, 액션 연결 |
| Screen | 주입받은 상태와 액션을 기반으로 UI만 렌더링 |
| di_route | 경로(path) → Root 연결만 담당 (비즈니스 로직 없음) |

---

## 🧱 설계 원칙

- GoRouter는 `@riverpod` 어노테이션을 사용해 Provider로 등록한다.
- 기능별로 `module_di.dart`, `module_route.dart`를 분리하여 관리한다.
- Root는 Notifier를 주입하고, 상태(state) 구독 및 액션(onAction) 연결을 담당한다.
- Screen은 StatelessWidget이며, 외부 Provider(ref)나 context 직접 접근 없이 상태와 액션만 사용한다.
- di_route는 경로-Root 매핑만 담당하며, 상태/인증 체크 등 비즈니스 로직을 처리하지 않는다.

---

## 📚 Provider 정의 예시

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'di_route.g.dart';

@riverpod
AuthDataSource authDataSource(AuthDataSourceRef ref) => AuthDataSource();

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) =>
    AuthRepository(ref.watch(authDataSourceProvider));

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

@riverpod
class LoginNotifier extends _$LoginNotifier {
  late final LoginUseCase _loginUseCase;

  @override
  LoginState build() {
    _loginUseCase = ref.watch(loginUseCaseProvider);
    return const LoginState();
  }
}
```

✅ 기능별 DI(Provider)는 `module_di.dart`로 분리 관리한다.

---

## 📚 Route 정의 예시

```dart
final authRoutes = [
  GoRoute(
    path: '/login',
    builder: (context, state) => const LoginScreenRoot(),
  ),
];
```

✅ 기능별 routes는 `module_route.dart`로 분리 관리한다.

---

# 📚 routerProvider 예시 (di_route.dart)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'di_route.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ...authRoutes,
      ...homeRoutes,
    ],
    errorBuilder: (context, state) => const ErrorScreenRoot(),
  );
}
```

✅ 기능별 routes를 합쳐 GoRouter를 구성한다.

---

## 📚 Root 예시

```dart
class LoginScreenRoot extends ConsumerWidget {
  const LoginScreenRoot({super.key});
//test 123
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(loginNotifierProvider.notifier);
    final state = ref.watch(loginNotifierProvider);

    return LoginScreen(
      state: state,
      onAction: notifier.onAction,
    );
  }
}
```

✅ Root는 상태 구독 및 액션 연결을 담당한다.

---

# 📚 Screen 예시

```dart
class LoginScreen extends StatelessWidget {
  final LoginState state;
  final void Function(LoginAction action) onAction;

  const LoginScreen({
    required this.state,
    required this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(state.email),
          ElevatedButton(
            onPressed: () => onAction(const LoginPressed()),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

✅ Screen은 상태(state)와 액션(onAction)만 받아서 UI를 렌더링한다.

---

# 🛠️ 확장 가능성 (구체 예시 포함)

---

## ✅ 1. ShellRoute 사용 (탭 구조)

```dart
ShellRoute(
  builder: (context, state, child) => MainTabScreenRoot(child: child),
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreenRoot(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreenRoot(),
    ),
  ],
)
```

✅ 탭(Tab) 구조 지원.

---

## ✅ 2. StatefulShellRoute 사용 (탭 상태 유지)

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => MainTabScreenRoot(shell: navigationShell),
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreenRoot(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreenRoot(),
        ),
      ],
    ),
  ],
)
```

✅ 탭 간 이동해도 스크롤/폼 상태 유지 가능.

---

## ✅ 3. Dynamic Parameter Route 사용

```dart
GoRoute(
  path: '/profile/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return ProfileScreenRoot(userId: userId);
  },
)
```

✅ 상세 화면을 ID 기반으로 동적으로 구성.

---

## ✅ 4. Named Route 사용

```dart
GoRoute(
  name: 'profile',
  path: '/profile',
  builder: (context, state) => const ProfileScreenRoot(),
);

// 이동 시
context.goNamed('profile');
```

✅ 경로 대신 이름 기반으로 관리 가능.

---

## ✅ 5. Nested Routing 사용

```dart
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreenRoot(),
  routes: [
    GoRoute(
      path: 'account',
      builder: (context, state) => const AccountSettingsScreenRoot(),
    ),
    GoRoute(
      path: 'notifications',
      builder: (context, state) => const NotificationSettingsScreenRoot(),
    ),
  ],
)
```

✅ 서브 화면 구성 지원.

---

# 📌 딥링크 구조 대비

- 현재 딥링크 기능은 직접 구현하지 않는다.
- Dynamic Parameter Route 기반 구조를 설계하여,  
  추후 딥링크 추가 시 GoRouter 구조 수정 없이 대응할 수 있도록 준비한다.
- initialLocation은 커스터마이즈가 가능하다.

---

# ✅ 최종 요약

| 항목 | 요약 |
|:---|:---|
| routerProvider | Path → Root 연결만 담당 |
| Root | Notifier 주입 + 상태 구독 + 액션 연결 담당 |
| Screen | 상태와 액션만 받아서 순수 UI 렌더링 |
| DI 구성 | DataSource → Repository → UseCase → Notifier |
| 모듈 구조 | module_di.dart, module_route.dart로 분리 관리 |
| 확장성 | ShellRoute, StatefulShellRoute, Dynamic Route, Named Route, Nested Route 대응 가능 |
| 딥링크 대비 | 구조적으로 대비 완료 (구현은 나중) |
| 용어 | ViewModel ❌, 전부 Notifier 기준 |
