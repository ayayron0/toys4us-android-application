import 'package:flutter/material.dart';

const Color brandColor = Color(0xFF7B1FA2);

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = ["Cart", "Info", "Total", "Pay"];

    return Row(
      children: List.generate(labels.length, (index) {
        final isActive = index == currentStep;
        final isComplete = index < currentStep;

        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor:
                isActive || isComplete ? brandColor : Colors.grey.shade300,
                child: Icon(
                  isComplete ? Icons.check : Icons.circle,
                  size: isComplete ? 16 : 8,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  labels[index],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive || isComplete
                        ? brandColor
                        : Colors.grey.shade600,
                  ),
                ),
              ),
              if (index != labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: isComplete ? brandColor : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}