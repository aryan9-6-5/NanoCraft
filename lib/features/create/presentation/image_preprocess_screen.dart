import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/create_puzzle_controller.dart';

class ImagePreprocessScreen extends ConsumerWidget {
  const ImagePreprocessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createPuzzleProvider);
    final notifier = ref.read(createPuzzleProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => notifier.changeStep(CreateStep.selectMethod),
              ),
              const Text(
                'Adjust Threshold',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Help text
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'Drag the slider to adjust the contrast. Dark areas will become filled cells in the puzzle grid.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // 15x15 Preview Grid inside a beautiful Card
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Card(
                margin: const EdgeInsets.all(24.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 15,
                      crossAxisSpacing: 2.0,
                      mainAxisSpacing: 2.0,
                    ),
                    itemCount: 225,
                    itemBuilder: (context, index) {
                      final int r = index ~/ 15;
                      final int c = index % 15;
                      final bool isFilled = state.grid[r][c];

                      return Container(
                        decoration: BoxDecoration(
                          color: isFilled
                              ? const Color(0xFF2563EB) // Primary Filled Cell
                              : const Color(0xFF1E1E24), // Empty Cell Background
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        // Threshold Slider Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lighter', style: TextStyle(color: Colors.grey)),
                  Text(
                    'Threshold: ${(state.threshold * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B85FF)),
                  ),
                  const Text('Darker', style: TextStyle(color: Colors.grey)),
                ],
              ),
              Slider(
                value: state.threshold,
                onChanged: (val) => notifier.updateThreshold(val),
                activeColor: const Color(0xFF6C63FF),
                inactiveColor: Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
        ),

        // Confirm Action Button
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: ElevatedButton(
            onPressed: () => notifier.changeStep(CreateStep.puzzleEditor),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm & Edit Grid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
