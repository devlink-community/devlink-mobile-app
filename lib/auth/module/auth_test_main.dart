import 'package:devlink_mobile_app/auth/data/data_source/user_storage.dart';
import 'package:devlink_mobile_app/auth/module/auth_di.dart'; // mockLoginUseCaseProvider import
import 'package:devlink_mobile_app/main.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {

  runApp(
    ProviderScope(
      // overrides: [
      //   loginUseCaseProvider.overrideWithProvider(mockLoginUseCaseProvider),
      // ],
      child: const MyApp(),
    ),
  );
}
