import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../shared/widgets/guest_guard_screen.dart';
import '../../../shared/widgets/nano_button.dart';
import '../../authentication/presentation/providers/auth_providers.dart';
import 'image_preprocess_screen.dart';
import 'puzzle_editor_screen.dart';
import 'providers/create_puzzle_controller.dart';
import '../data/services/draft_service.dart';
import '../../../shared/utils/image_processor.dart';
import '../../../shared/utils/pixel_font.dart';
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

  void _showTextInputDialog() {
    final TextEditingController textController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text('Convert Text to Nonogram'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter a word of up to 12 characters. Words <= 5 characters open in the editor (10x10). Words 6-12 characters generate a multi-round puzzle.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: textController,
                  autofocus: true,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    labelText: 'Input Text',
                    hintText: 'e.g. CAT, HELLOWORLD',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some text';
                    }
                    final clean = value.trim();
                    final regex = RegExp(r'^[a-zA-Z0-9 ]+$');
                    if (!regex.hasMatch(clean)) {
                      return 'Alphanumeric and spaces only';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  final text = textController.text.trim();
                  Navigator.pop(context);
                  _processText(text);
                }
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  void _processText(String text) async {
    final notifier = ref.read(createPuzzleProvider.notifier);
    final currentUser = ref.read(currentUserProvider).value;

    if (text.length <= 5) {
      final textGrid = PixelFont.renderText(text);
      notifier.initNewTextPuzzle(text, textGrid);
    } else {
      if (currentUser == null) return;

      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await notifier.publishMultiRoundTextPuzzle(text, currentUser.uid);

      if (mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Multi-round text puzzle published successfully!'
                  : 'Failed to publish multi-round puzzle. Please try again.',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
        if (success) {
          context.go('/home');
        }
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
                    onPressed: _showTextInputDialog,
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
