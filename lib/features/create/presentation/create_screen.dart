import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/widgets/guest_guard_screen.dart';
import '../../authentication/presentation/providers/auth_providers.dart';
import 'image_preprocess_screen.dart';
import 'puzzle_editor_screen.dart';
import 'providers/create_puzzle_controller.dart';
import '../data/services/draft_service.dart';
import '../../../shared/utils/image_processor.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptDraft();
    });
  }

  void _checkAndPromptDraft() async {
    final hasDraft = await DraftService().hasDraft();
    if (!mounted) return;
    if (hasDraft) {
      final resume = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Resume Draft?'),
          content: const Text('We found an unfinished Nonogram draft. Would you like to resume editing?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Resume'),
            ),
          ],
        ),
      );

      if (resume == true) {
        await ref.read(createPuzzleProvider.notifier).loadLatestDraft();
      } else {
        await ref.read(createPuzzleProvider.notifier).discardDraft();
      }
    }
  }

  void _pickAndProcessImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      final grayscaleGrid = ImageProcessor.preprocessImage(bytes);
      ref.read(createPuzzleProvider.notifier).initNewImagePuzzle(grayscaleGrid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestProvider);
    final state = ref.watch(createPuzzleProvider);

    if (isGuest) {
      return const Scaffold(
        body: GuestGuardScreen(
          message: 'You must be signed in to create and publish puzzles.',
        ),
      );
    }

    switch (state.step) {
      case CreateStep.imagePreprocess:
        return const Scaffold(
          body: SafeArea(child: ImagePreprocessScreen()),
        );
      case CreateStep.puzzleEditor:
        return const PuzzleEditorScreen();
      case CreateStep.selectMethod:
      default:
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create Puzzle'),
          ),
          body: Center(
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
                    onPressed: _pickAndProcessImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Convert Image (15x15)'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 48),
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
                      minimumSize: const Size(220, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
