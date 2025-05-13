import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.error(Failure failure) = Error<T>;
}

/// 실패 정보 구조
class Failure {
  final FailureType type;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const Failure(this.type, this.message, {this.cause, this.stackTrace});

  bool get isNetwork => type == FailureType.network;
  bool get isTimeout => type == FailureType.timeout;

  @override
  String toString() =>
      'Failure(type: $type, message: $message, cause: $cause, stackTrace: $stackTrace)';
}

/// 실패 유형 분류
enum FailureType { network, unauthorized, timeout, server, parsing, validation, unknown }

/// Exception을 Failure로 매핑하는 유틸
Failure mapExceptionToFailure(Object error, StackTrace stackTrace) {
  if (error is TimeoutException) {
    return Failure(
      FailureType.timeout,
      '요청 시간이 초과되었습니다',
      cause: error,
      stackTrace: stackTrace,
    );
  } else if (error is FormatException) {
    return Failure(
      FailureType.parsing,
      '데이터 형식 오류입니다',
      cause: error,
      stackTrace: stackTrace,
    );
  } else if (error.toString().contains('SocketException')) {
    return Failure(
      FailureType.network,
      '인터넷 연결을 확인해주세요',
      cause: error,
      stackTrace: stackTrace,
    );
  } else {
    return Failure(
      FailureType.unknown,
      '알 수 없는 오류가 발생했습니다',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
