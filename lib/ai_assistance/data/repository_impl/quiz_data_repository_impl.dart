import 'dart:math';

import '../../../core/result/result.dart';
import '../../../core/utils/app_logger.dart';
import '../../domain/model/quiz.dart';
import '../../domain/repository/quiz_repository.dart';
import '../../module/quiz_prompt.dart';
import '../data_source/quiz_data_source.dart';
import '../dto/quiz_dto.dart';
import '../mapper/quiz_mapper.dart';

class QuizRepositoryImpl implements QuizRepository {
  final FirebaseAiDataSource _dataSource;
  final PromptService _promptService;
  final Random _random = Random();

  // 기술별 키워드 맵 - 관련성 검사에 사용
  final Map<String, List<String>> _skillKeywords = {
    'flutter': [
      'flutter',
      'dart',
      'widget',
      'stateful',
      'stateless',
      'build',
      'material',
      'cupertino',
      'scaffold',
      'navigator',
      'route',
    ],
    'javascript': [
      'javascript',
      'js',
      'promise',
      'async',
      'await',
      'function',
      'var',
      'let',
      'const',
      'es6',
      'dom',
    ],
    'python': [
      'python',
      'def',
      'list',
      'dict',
      'tuple',
      'pep8',
      'django',
      'flask',
      'numpy',
      'pandas',
    ],
    'react': [
      'react',
      'jsx',
      'component',
      'hook',
      'usestate',
      'useeffect',
      'props',
      'redux',
    ],
    'html': [
      'html',
      'tag',
      'element',
      'doctype',
      'head',
      'body',
      'div',
      'span',
      'semantic',
      'attribute',
    ],
    'css': [
      'css',
      'selector',
      'style',
      'flexbox',
      'grid',
      'media',
      'query',
      'property',
      'value',
      'animation',
    ],
    'sql': [
      'sql',
      'database',
      'query',
      'select',
      'insert',
      'update',
      'delete',
      'join',
      'table',
      'column',
    ],
    'java': [
      'java',
      'class',
      'object',
      'interface',
      'extends',
      'implements',
      'override',
      'public',
      'private',
    ],
    'kotlin': [
      'kotlin',
      'val',
      'var',
      'fun',
      'class',
      'coroutine',
      'extension',
      'null',
      'safety',
    ],
    'swift': [
      'swift',
      'optional',
      'struct',
      'enum',
      'protocol',
      'extension',
      'guard',
      'let',
      'var',
    ],
    'go': [
      'go',
      'golang',
      'goroutine',
      'channel',
      'struct',
      'interface',
      'error',
      'slice',
      'map',
      'pointer',
    ],
    'rust': [
      'rust',
      'ownership',
      'borrowing',
      'lifetime',
      'trait',
      'struct',
      'enum',
      'match',
      'result',
      'option',
    ],
    'c#': [
      'c#',
      'csharp',
      '.net',
      'class',
      'async',
      'await',
      'linq',
      'wpf',
      'xaml',
      'delegate',
    ],
    'typescript': [
      'typescript',
      'ts',
      'interface',
      'type',
      'enum',
      'generic',
      'union',
      'intersection',
      'utility',
      'any',
    ],
    'vue': [
      'vue',
      'component',
      'template',
      'directive',
      'v-if',
      'v-for',
      'v-model',
      'vuex',
      'lifecycle',
      'prop',
    ],
    'angular': [
      'angular',
      'component',
      'directive',
      'service',
      'dependency',
      'injection',
      'module',
      'pipe',
      'observable',
    ],
    'node': [
      'node',
      'nodejs',
      'express',
      'npm',
      'package',
      'module',
      'require',
      'import',
      'middleware',
      'route',
    ],
    'php': [
      'php',
      'array',
      'function',
      'class',
      'echo',
      'print',
      'laravel',
      'symfony',
      'composer',
      'namespace',
    ],
    'ruby': [
      'ruby',
      'rails',
      'gem',
      'block',
      'module',
      'class',
      'method',
      'hash',
      'symbol',
      'irb',
    ],
    'c++': [
      'c++',
      'class',
      'template',
      'stl',
      'vector',
      'pointer',
      'reference',
      'inheritance',
      'polymorphism',
    ],
    'blockchain': [
      'blockchain',
      'bitcoin',
      'ethereum',
      'smart',
      'contract',
      'token',
      'wallet',
      'hash',
      'block',
      'transaction',
    ],
    'machine learning': [
      'ml',
      'machine',
      'learning',
      'algorithm',
      'model',
      'training',
      'classification',
      'regression',
      'neural',
      'network',
    ],
    'ai': [
      'artificial',
      'intelligence',
      'ml',
      'deep',
      'learning',
      'neural',
      'network',
      'nlp',
      'computer',
      'vision',
    ],
  };

  QuizRepositoryImpl({
    required FirebaseAiDataSource dataSource,
    required PromptService promptService,
  }) : _dataSource = dataSource,
       _promptService = promptService;

  @override
  Future<Result<Quiz>> generateQuiz(String skillArea) async {
    final startTime = DateTime.now();

    AppLogger.info(
      'Quiz 생성 시작: $skillArea',
      tag: 'QuizRepository',
    );

    try {
      // 스킬 영역 정제 - PromptService 사용
      final cleanedSkill = _promptService.cleanSkillArea(skillArea);

      AppLogger.info(
        'QuizRepositoryImpl - 정제된 스킬: $cleanedSkill',
        tag: 'QuizRepository',
      );

      // API 호출 실패 횟수 (재시도 용)
      int retryCount = 0;

      // 최대 5번까지 시도
      while (retryCount < 5) {
        try {
          AppLogger.info(
            'Firebase AI 퀴즈 생성 시도 ${retryCount + 1}/5',
            tag: 'QuizGeneration',
          );

          // PromptService를 사용하여 프롬프트 생성
          final prompt = _promptService.createQuizPrompt(cleanedSkill);
          final response = await _dataSource.generateQuizWithPrompt(prompt);

          // DTO로 변환
          final quizDto = QuizDto.fromJson(response);

          // 검증: 필수 필드 확인
          if (quizDto.question == null ||
              quizDto.options == null ||
              quizDto.options!.isEmpty ||
              quizDto.explanation == null) {
            AppLogger.warning(
              '생성된 퀴즈가 불완전합니다. 재시도합니다.',
              tag: 'QuizValidation',
            );

            AppLogger.logState('불완전한 퀴즈 데이터', {
              'question': quizDto.question != null ? '존재' : 'null',
              'options': '${quizDto.options?.length ?? 0}개',
              'explanation': quizDto.explanation != null ? '존재' : 'null',
            });

            retryCount++;
            continue;
          }

          // correctOptionIndex 확인 및 수정
          final correctIndex = _validateCorrectOptionIndex(
            quizDto.correctOptionIndex ?? 0,
            quizDto.options?.length ?? 4,
          );

          // 관련성 검사
          final normalizedSkill = cleanedSkill.toLowerCase();
          final normalizedQuestion = quizDto.question!.toLowerCase();

          // 기본 관련성 확인 - 스킬명이 질문에 포함됨
          bool isRelevant = normalizedQuestion.contains(normalizedSkill);

          // 관련 키워드 검사
          if (!isRelevant && _skillKeywords.containsKey(normalizedSkill)) {
            final keywords = _skillKeywords[normalizedSkill]!;
            isRelevant = keywords.any(
              (keyword) => normalizedQuestion.contains(keyword),
            );

            if (isRelevant) {
              AppLogger.debug(
                '키워드 매칭으로 관련성 확인됨: $cleanedSkill',
                tag: 'QuizValidation',
              );
            }
          }

          // 관련성 없는 경우 재시도
          if (!isRelevant) {
            AppLogger.warning(
              '생성된 퀴즈가 $cleanedSkill 기술과 관련이 없습니다. 재시도합니다.',
              tag: 'QuizValidation',
            );

            AppLogger.logState('관련성 검사 결과', {
              'skill': cleanedSkill,
              'question': normalizedQuestion.substring(
                0,
                min(50, normalizedQuestion.length),
              ),
              'hasSkillKeywords': _skillKeywords.containsKey(normalizedSkill),
            });

            retryCount++;
            continue;
          }

          // 추가 검증 - 비정상적인 답변 옵션 체크
          bool hasInvalidOptions =
              quizDto.options?.any(
                (option) => option.isEmpty || option.length < 2,
              ) ??
              false;

          if (hasInvalidOptions) {
            AppLogger.warning(
              '생성된 퀴즈에 비정상적인 옵션이 있습니다. 재시도합니다.',
              tag: 'QuizValidation',
            );

            AppLogger.logState('비정상적인 옵션 감지', {
              'options': quizDto.options?.map((o) => o.length ?? 0).toList(),
            });

            retryCount++;
            continue;
          }

          // 보정된 DTO 생성
          final updatedDto = quizDto.copyWith(
            correctOptionIndex: correctIndex,
            // 스킬명의 첫 글자를 대문자로 변경
            skillArea:
                cleanedSkill.substring(0, 1).toUpperCase() +
                cleanedSkill.substring(1),
          );

          // 모델로 변환
          final result = updatedDto.toModel();

          final duration = DateTime.now().difference(startTime);
          AppLogger.logPerformance('퀴즈 생성 완료', duration);

          AppLogger.info(
            '퀴즈 생성 완료: ${result.question.substring(0, min(30, result.question.length))}...',
            tag: 'QuizRepository',
          );

          return Result.success(result);
        } catch (innerError) {
          AppLogger.error(
            '퀴즈 생성 중 오류 발생 (시도 ${retryCount + 1}/5)',
            tag: 'QuizGeneration',
            error: innerError,
          );
          retryCount++;
        }
      }

      // 모든 시도가 실패한 경우 맞춤형 퀴즈 생성
      AppLogger.warning(
        'Firebase AI 퀴즈 생성 모두 실패. 최후의 시도를 합니다.',
        tag: 'QuizGeneration',
      );

      // 최후의 시도 - 이미 정의된 문자열을 기반으로 퀴즈 생성
      final fallbackQuiz = _generateFallbackQuiz(cleanedSkill);

      final duration = DateTime.now().difference(startTime);
      AppLogger.logPerformance('폴백 퀴즈 생성 완료', duration);

      return Result.success(fallbackQuiz);
    } catch (e, st) {
      final duration = DateTime.now().difference(startTime);
      AppLogger.logPerformance('퀴즈 생성 실패', duration);

      AppLogger.error(
        'QuizRepositoryImpl - 퀴즈 생성 실패',
        tag: 'QuizRepository',
        error: e,
        stackTrace: st,
      );

      return Result.error(mapExceptionToFailure(e, st));
    }
  }

  // 매우 기본적인 폴백 퀴즈 생성 (최후의 수단)
  Quiz _generateFallbackQuiz(String skillName) {
    AppLogger.info(
      '폴백 퀴즈 생성: $skillName',
      tag: 'QuizFallback',
    );

    final capitalizedSkill =
        skillName.substring(0, 1).toUpperCase() + skillName.substring(1);

    final fallbackQuiz = Quiz(
      question: "$capitalizedSkill의 주요 특징은 무엇인가요?",
      options: [
        "$capitalizedSkill은 높은 생산성을 제공합니다.",
        "$capitalizedSkill은 주로 모바일 앱 개발에만 사용됩니다.",
        "$capitalizedSkill은 객체 지향 프로그래밍을 지원하지 않습니다.",
        "$capitalizedSkill은 오직 Windows에서만 동작합니다.",
      ],
      explanation:
          "$capitalizedSkill은 다양한 환경에서 사용할 수 있으며, 높은 생산성을 제공하는 것이 주요 특징입니다.",
      correctOptionIndex: 0,
      relatedSkill: capitalizedSkill,
    );

    AppLogger.info(
      '폴백 퀴즈 생성 완료: ${fallbackQuiz.question}',
      tag: 'QuizFallback',
    );

    return fallbackQuiz;
  }

  // correctOptionIndex 값 검증 및 수정
  int _validateCorrectOptionIndex(int index, int optionsLength) {
    if (optionsLength <= 0) {
      AppLogger.warning(
        '옵션 개수가 0 이하입니다: $optionsLength',
        tag: 'QuizValidation',
      );
      return 0;
    }

    // 범위 확인 (0 <= index < optionsLength)
    if (index < 0 || index >= optionsLength) {
      final validIndex = _random.nextInt(optionsLength);

      AppLogger.warning(
        '유효하지 않은 correctOptionIndex 감지: $index, 옵션 개수: $optionsLength → $validIndex로 수정',
        tag: 'QuizValidation',
      );

      return validIndex; // 랜덤한 유효 인덱스 반환
    }

    AppLogger.debug(
      'correctOptionIndex 검증 통과: $index (옵션 개수: $optionsLength)',
      tag: 'QuizValidation',
    );

    return index;
  }
}
