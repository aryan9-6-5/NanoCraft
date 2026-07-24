import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/guest_guard_screen.dart';
import '../../authentication/presentation/providers/auth_providers.dart';

class CreateScreen extends ConsumerWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Puzzle'),
      ),
      body: isGuest
          ? const GuestGuardScreen(
              message: 'You must be signed in to create and publish puzzles.',
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate, size: 64, color: Colors.indigo),
                    const SizedBox(height: 16),
                    const Text(
                      'Design Your Nonogram',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose a creation method to generate or paint a puzzle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Phase 3: Image Creation Flow
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Convert Image (15x15)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Phase 4: Text Creation Flow
                      },
                      icon: const Icon(Icons.title),
                      label: const Text('Convert Text (10x10)'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
