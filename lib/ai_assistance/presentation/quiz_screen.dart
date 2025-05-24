import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/styles/app_color_styles.dart';
import '../../core/styles/app_text_styles.dart';
import '../../core/utils/app_logger.dart';
import '../domain/model/quiz.dart';
import 'quiz_action.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  final String? skills;
  final Function(QuizAction)? onAction;

  const QuizScreen({super.key, required this.quiz, this.skills, this.onAction});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? selectedAnswerIndex;
  bool hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      // SingleChildScrollView 추가
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildQuestion(),
            const SizedBox(height: 16),
            _buildOptions(),
            if (hasAnswered) ...[
              const SizedBox(height: 16),
              _buildExplanation(),
            ],
            const SizedBox(height: 20),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorStyles.primary60.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.quiz.relatedSkill} 퀴즈',
            style: AppTextStyles.button2Regular.copyWith(
              color: AppColorStyles.primary80,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            if (widget.onAction != null) {
              widget.onAction!(const QuizAction.closeQuiz());
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.close, size: 24),
          color: Colors.grey[600],
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    // 코드 블록이 있는지 확인 (```로 감싸진 부분)
    final regex = RegExp(r'```(.*?)```', dotAll: true);
    final match = regex.firstMatch(widget.quiz.question);

    if (match != null) {
      // 코드 블록 전후로 나누기
      final parts = widget.quiz.question.split(match.group(0)!);
      final beforeCode = parts[0];
      final code = match.group(1) ?? '';
      final afterCode = parts.length > 1 ? parts[1] : '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (beforeCode.isNotEmpty)
            Text(beforeCode.trim(), style: AppTextStyles.subtitle1Bold),
          if (code.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  code.trim(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          if (afterCode.isNotEmpty)
            Text(afterCode.trim(), style: AppTextStyles.subtitle1Bold),
        ],
      );
    }

    // 코드 블록이 없는 경우 기존 스타일 유지
    return Text(widget.quiz.question, style: AppTextStyles.subtitle1Bold);
  }

  Widget _buildOptions() {
    return Column(
      children: List.generate(
        widget.quiz.options.length,
        (index) => _buildOptionItem(index),
      ),
    );
  }

  Widget _buildOptionItem(int index) {
    final option = widget.quiz.options[index];
    final isSelected = selectedAnswerIndex == index;
    final isCorrect = hasAnswered && index == widget.quiz.correctOptionIndex;
    final isWrong = hasAnswered && isSelected && !isCorrect;

    // 상태에 따른 색상 및 스타일 설정
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (isCorrect) {
      backgroundColor = Colors.green.withValues(alpha: 0.1);
      borderColor = Colors.green;
      textColor = Colors.green.shade800;
      trailingIcon = Icons.check_circle;
    } else if (isWrong) {
      backgroundColor = Colors.red.withValues(alpha: 0.1);
      borderColor = Colors.red;
      textColor = Colors.red.shade800;
      trailingIcon = Icons.cancel;
    } else if (isSelected) {
      backgroundColor = AppColorStyles.primary60;
      borderColor = AppColorStyles.primary80;
      textColor = AppColorStyles.primary80;
      trailingIcon = null;
    } else {
      backgroundColor = Colors.grey.withValues(alpha: 0.05);
      borderColor = Colors.grey.withValues(alpha: 0.2);
      textColor = Colors.grey[800]!;
      trailingIcon = null;
    }

    return GestureDetector(
      onTap: hasAnswered ? null : () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D...
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: AppTextStyles.body1Regular.copyWith(
                  color: textColor,
                  fontWeight: isCorrect || isSelected ? FontWeight.w500 : null,
                ),
              ),
            ),
            if (trailingIcon != null)
              Icon(
                trailingIcon,
                color: isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '해설',
            style: AppTextStyles.captionRegular.copyWith(
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.quiz.explanation,
            style: AppTextStyles.body2Regular.copyWith(
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!hasAnswered) ...[
          ElevatedButton(
            onPressed:
                selectedAnswerIndex != null
                    ? () => _checkAnswer(selectedAnswerIndex!)
                    : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColorStyles.primary60.withAlpha(200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text('정답 확인', style: AppTextStyles.subtitle1Bold),
          ),
        ] else ...[
          OutlinedButton(
            onPressed: () {
              if (widget.onAction != null) {
                widget.onAction!(const QuizAction.closeQuiz());
              } else {
                Navigator.of(context).pop();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorStyles.primary80,
              side: BorderSide(color: AppColorStyles.primary80),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '닫기',
              style: AppTextStyles.button2Regular.copyWith(
                color: AppColorStyles.primary80,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              AppLogger.debug(
                '새 퀴즈 요청 - 원본 스킬 목록: ${widget.skills}',
                tag: 'QuizScreen',
              );
              // 새로운 퀴즈 로드 액션 트리거
              if (widget.onAction != null) {
                widget.onAction!(
                  QuizAction.loadQuiz(
                    skills: widget.skills, // 원본 스킬 목록 그대로 전달
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColorStyles.primary80,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text('새 퀴즈', style: AppTextStyles.button2Regular),
          ),
        ],
      ],
    );
  }

  // 답변 선택 메서드 추가
  void _selectAnswer(int index) {
    AppLogger.debug('답변 선택: $index', tag: 'QuizScreen');
    setState(() {
      selectedAnswerIndex = index;
    });
  }

  // 답변 확인 메서드 추가
  void _checkAnswer(int index) {
    AppLogger.debug(
      '답변 제출: $index, 정답: ${widget.quiz.correctOptionIndex}',
      tag: 'QuizScreen',
    );
    setState(() {
      hasAnswered = true;
    });

    // 답변 제출 액션 호출
    if (widget.onAction != null) {
      widget.onAction!(QuizAction.submitAnswer(index));
    }
  }
}
