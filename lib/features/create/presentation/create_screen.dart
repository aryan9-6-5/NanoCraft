import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/guest_guard_screen.dart';
import '../../../shared/widgets/nano_button.dart';
import '../../authentication/presentation/providers/auth_providers.dart';
import 'image_preprocess_screen.dart';
import 'puzzle_editor_screen.dart';
import 'providers/create_puzzle_controller.dart';
import '../data/services/draft_service.dart';
import '../../../shared/utils/image_processor.dart';
import '../../../shared/widgets/nano_dialog.dart';

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
      final resume = await NanoDialog.show(
        context,
        title: 'Resume Draft?',
        content: 'We found an unfinished Nonogram draft. Would you like to resume editing?',
        confirmLabel: 'Resume',
        cancelLabel: 'Discard',
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
          SnackBar(content: Text('Failed to process image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestProvider);
    final state = ref.watch(createPuzzleProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            title: const Text('Create'),
          ),
          body: Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Design Your Nonogram',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Choose a creation method to generate or paint a puzzle.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  NanoButton(
                    label: 'Convert Image (15×15)',
                    icon: Icons.image_rounded,
                    onPressed: _pickAndProcessImage,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  NanoButton(
                    label: 'Convert Text (10×10)',
                    icon: Icons.title_rounded,
                    variant: NanoButtonVariant.outlined,
                    onPressed: () {
                      // Phase 4: Text Creation Flow
                    },
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
