import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/responsive_utils.dart';

// ═══════════════════════════════════════════════════════════════════
// FAQ SCREEN
// ═══════════════════════════════════════════════════════════════════

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  bool _searching = false;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _howToMatchesQuery(_HowTo howTo, String q) {
    if (howTo.title.toLowerCase().contains(q)) return true;
    if (howTo.subtitle.toLowerCase().contains(q)) return true;
    for (final step in howTo.steps) {
      if (step.title.toLowerCase().contains(q)) return true;
      if (step.description.toLowerCase().contains(q)) return true;
      if (step.tip != null && step.tip!.toLowerCase().contains(q)) return true;
    }
    return false;
  }

  bool _questionMatchesQuery(_TextQuestion question, String q) {
    if (question.question.toLowerCase().contains(q)) return true;
    if (question.subtitle.toLowerCase().contains(q)) return true;
    if (question.answer.toLowerCase().contains(q)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final howTos = _buildHowTos(l10n);
    final questions = _buildQuestions(l10n);
    final q = _query.toLowerCase().trim();

    return Scaffold(
      appBar: _searching
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _searching = false;
                  _searchController.clear();
                  _query = '';
                }),
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '${l10n.faqTitle}...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              actions: [
                if (_query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _searchController.clear();
                      _query = '';
                    }),
                  ),
              ],
            )
          : AppBar(
              title: Text(l10n.faqTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, size: 22),
                  onPressed: () => setState(() => _searching = true),
                ),
              ],
            ),
      body: SelectionArea(child: Responsive.constrainWidth(context, child: q.isEmpty
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // ── Hero ──
                _HeroBanner(theme: theme),
                const SizedBox(height: 24),

                // ── How-to guides ──
                _SectionHeader(title: l10n.faqHowToGuides, icon: Icons.menu_book_rounded),
                const SizedBox(height: 8),
                for (final howTo in howTos) ...[
                  _HowToCard(howTo: howTo, allHowTos: howTos),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 16),

                // ── Common questions ──
                _SectionHeader(title: l10n.faqCommonQuestions, icon: Icons.help_outline_rounded),
                const SizedBox(height: 8),
                for (final faq in questions) ...[
                  _QuestionCard(question: faq, allHowTos: howTos),
                ],
              ],
            )
          : Builder(builder: (context) {
              final matchedHowTos = howTos.where((h) => _howToMatchesQuery(h, q)).toList();
              final matchedQuestions = questions.where((faq) => _questionMatchesQuery(faq, q)).toList();
              if (matchedHowTos.isEmpty && matchedQuestions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(l10n.searchNoResults, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
                    ],
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  if (matchedHowTos.isNotEmpty) ...[
                    _SectionHeader(title: l10n.faqHowToGuides, icon: Icons.menu_book_rounded),
                    const SizedBox(height: 8),
                    for (final howTo in matchedHowTos) ...[
                      _HowToCard(howTo: howTo, allHowTos: howTos),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 16),
                  ],
                  if (matchedQuestions.isNotEmpty) ...[
                    _SectionHeader(title: l10n.faqCommonQuestions, icon: Icons.help_outline_rounded),
                    const SizedBox(height: 8),
                    for (final faq in matchedQuestions) ...[
                      _QuestionCard(question: faq, allHowTos: howTos),
                    ],
                  ],
                ],
              );
            }),
      )),
    );
  }

  List<_HowTo> _buildHowTos(AppLocalizations l10n) {
    return [
      _HowTo(
        id: 'add-headers',
        icon: Icons.view_agenda_outlined,
        color: const Color(0xFF2196F3),
        title: l10n.faqAddHeadersTitle,
        subtitle: l10n.faqAddHeadersSubtitle,
        steps: [
          _FaqStep(
            title: l10n.faqAddHeadersStep1Title,
            description: l10n.faqAddHeadersStep1Desc,
            icon: Icons.edit,
            asset: const _FaqAsset(filename: 'add_headers_1.jpg', description: 'Recipe view with edit icon circled'),
          ),
          _FaqStep(
            title: l10n.faqAddHeadersStep2Title,
            description: l10n.faqAddHeadersStep2Desc,
            icon: Icons.add,
            asset: const _FaqAsset(filename: 'add_headers_2.jpg', description: 'Add header button circled'),
          ),
          _FaqStep(
            title: l10n.faqAddHeadersStep3Title,
            description: l10n.faqAddHeadersStep3Desc,
            icon: Icons.more_vert,
            asset: const _FaqAsset(filename: 'add_headers_3.jpg', description: 'Three dots menu circled'),
          ),
          _FaqStep(
            title: l10n.faqAddHeadersStep4Title,
            description: l10n.faqAddHeadersStep4Desc,
            icon: Icons.sort,
            asset: const _FaqAsset(filename: 'add_headers_4.jpg', description: 'Sort order with drag handle'),
            tip: l10n.faqAddHeadersStep4Tip,
          ),
          _FaqStep(
            title: l10n.faqAddHeadersStep5Title,
            description: l10n.faqAddHeadersStep5Desc,
            icon: Icons.save,
            asset: const _FaqAsset(filename: 'add_headers_5.jpg', description: 'Save button circled'),
          ),
          _FaqStep(
            title: l10n.faqAddHeadersStep6Title,
            description: l10n.faqAddHeadersStep6Desc,
            icon: Icons.check_circle,
            asset: const _FaqAsset(filename: 'add_headers_6.jpg', description: 'Final result with headers'),
          ),
        ],
      ),
      _HowTo(
        id: 'add-sublinked-recipes',
        icon: Icons.link,
        color: const Color(0xFF4CAF50),
        title: l10n.faqAddSublinkedTitle,
        subtitle: l10n.faqAddSublinkedSubtitle,
        steps: [
          _FaqStep(
            title: l10n.faqAddSublinkedStep1Title,
            description: l10n.faqAddSublinkedStep1Desc,
            icon: Icons.edit,
            asset: const _FaqAsset(filename: 'add_sublinked_recipe_1.jpg', description: 'Edit icon circled'),
          ),
          _FaqStep(
            title: l10n.faqAddSublinkedStep2Title,
            description: l10n.faqAddSublinkedStep2Desc,
            icon: Icons.more_vert,
            asset: const _FaqAsset(filename: 'add_sublinked_recipe_2.jpg', description: 'Three dots circled'),
          ),
          _FaqStep(
            title: l10n.faqAddSublinkedStep3Title,
            description: l10n.faqAddSublinkedStep3Desc,
            icon: Icons.link,
            asset: const _FaqAsset(filename: 'add_sublinked_recipe_3.jpg', description: 'Link recipe option circled'),
          ),
          _FaqStep(
            title: l10n.faqAddSublinkedStep4Title,
            description: l10n.faqAddSublinkedStep4Desc,
            icon: Icons.link,
            asset: const _FaqAsset(filename: 'add_sublinked_recipe_4.jpg', description: 'Link icon next to recipe'),
          ),
          _FaqStep(
            title: l10n.faqAddSublinkedStep5Title,
            description: l10n.faqAddSublinkedStep5Desc,
            icon: Icons.save,
            asset: const _FaqAsset(filename: 'add_sublinked_recipe_5.jpg', description: 'Save icon circled'),
          ),
          _FaqStep(
            title: l10n.faqAddSublinkedStep6Title,
            description: l10n.faqAddSublinkedStep6Desc,
            icon: Icons.check_circle,
            asset: const _FaqAsset(filename: 'add_sublinked_recipe_6.jpg', description: 'Final result with linked recipe'),
          ),
        ],
      ),
      _HowTo(
        id: 'macro-calculator',
        icon: Icons.local_fire_department_outlined,
        color: const Color(0xFFFF5722),
        title: l10n.faqMacroCalcTitle,
        subtitle: l10n.faqMacroCalcSubtitle,
        steps: [
          _FaqStep(
            title: l10n.faqMacroCalcStep1Title,
            description: l10n.faqMacroCalcStep1Desc,
            icon: Icons.restaurant_menu,
            asset: const _FaqAsset(filename: 'macro_calc_1.jpg', description: 'Recipe view screen'),
          ),
          _FaqStep(
            title: l10n.faqMacroCalcStep2Title,
            description: l10n.faqMacroCalcStep2Desc,
            icon: Icons.touch_app,
            asset: const _FaqAsset(filename: 'macro_calc_2.jpg', description: 'Empty nutrition section at bottom of recipe'),
          ),
          _FaqStep(
            title: l10n.faqMacroCalcStep3Title,
            description: l10n.faqMacroCalcStep3Desc,
            icon: Icons.calculate,
            asset: const _FaqAsset(filename: 'macro_calc_3.jpg', description: 'Calculator showing match rate, calories, and macros'),
          ),
          _FaqStep(
            title: l10n.faqMacroCalcStep4Title,
            description: l10n.faqMacroCalcStep4Desc,
            icon: Icons.edit_note,
            asset: const _FaqAsset(filename: 'macro_calc_4.jpg', description: 'Enter Manually screen for editing values'),
          ),
          _FaqStep(
            title: l10n.faqMacroCalcStep5Title,
            description: l10n.faqMacroCalcStep5Desc,
            icon: Icons.list_alt,
            asset: const _FaqAsset(filename: 'macro_calc_5.jpg', description: 'Ingredient matches showing USDA foods and sublinked recipes'),
            tip: l10n.faqMacroCalcStep5Tip,
          ),
          _FaqStep(
            title: l10n.faqMacroCalcStep6Title,
            description: l10n.faqMacroCalcStep6Desc,
            icon: Icons.search,
            asset: const _FaqAsset(filename: 'macro_calc_6.jpg', description: 'USDA food database search screen'),
          ),
          _FaqStep(
            title: l10n.faqMacroCalcStep7Title,
            description: l10n.faqMacroCalcStep7Desc,
            icon: Icons.link,
            asset: const _FaqAsset(filename: 'macro_calc_7.jpg', description: 'Linked recipe nutrition detail screen'),
          ),
          _FaqStep(
            title: l10n.faqMacroCalcStep8Title,
            description: l10n.faqMacroCalcStep8Desc,
            icon: Icons.check_circle,
            asset: const _FaqAsset(filename: 'macro_calc_8.jpg', description: 'Nutrition widget showing saved data on recipe'),
          ),
          _FaqStep(
            title: l10n.faqMacroCalcStep9Title,
            description: l10n.faqMacroCalcStep9Desc,
            icon: Icons.settings,
            asset: const _FaqAsset(filename: 'macro_calc_9.jpg', description: 'Nutrition display settings screen'),
          ),
        ],
      ),
    ];
  }

  List<_TextQuestion> _buildQuestions(AppLocalizations l10n) {
    return [
      _TextQuestion(
        icon: Icons.view_agenda_outlined,
        color: const Color(0xFF2196F3),
        question: l10n.faqWhatAreHeadersTitle,
        subtitle: l10n.faqWhatAreHeadersSubtitle,
        answer: l10n.faqWhatAreHeadersAnswer,
        linkedHowToId: 'add-headers',
      ),
      _TextQuestion(
        icon: Icons.link,
        color: const Color(0xFF4CAF50),
        question: l10n.faqWhatAreSublinkedTitle,
        subtitle: l10n.faqWhatAreSublinkedSubtitle,
        answer: l10n.faqWhatAreSublinkedAnswer,
        linkedHowToId: 'add-sublinked-recipes',
      ),
      _TextQuestion(
        icon: Icons.local_fire_department_outlined,
        color: const Color(0xFFFF5722),
        question: l10n.faqWhatIsMacroCalcTitle,
        subtitle: l10n.faqWhatIsMacroCalcSubtitle,
        answer: l10n.faqWhatIsMacroCalcAnswer,
        linkedHowToId: 'macro-calculator',
      ),
      _TextQuestion(
        icon: Icons.error_outline,
        color: const Color(0xFFFF9800),
        question: l10n.faqImportFailedTitle,
        subtitle: l10n.faqImportFailedSubtitle,
        answer: l10n.faqImportFailedAnswer,
      ),
      _TextQuestion(
        icon: Icons.phone_android,
        color: const Color(0xFF795548),
        question: l10n.faqDeviceTransferTitle,
        subtitle: l10n.faqDeviceTransferSubtitle,
        answer: l10n.faqDeviceTransferAnswer,
      ),
    ];
  }
}

// ═══════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════

class _HowTo {
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<_FaqStep> steps;
  const _HowTo({required this.id, required this.icon, required this.color, required this.title, required this.subtitle, required this.steps});
}

class _FaqStep {
  final String title;
  final String description;
  final IconData icon;
  final _FaqAsset? asset;
  final String? tip;
  const _FaqStep({required this.title, required this.description, required this.icon, this.asset, this.tip});
}

class _FaqAsset {
  final String filename;
  final String description;
  const _FaqAsset({required this.filename, required this.description});
}

class _TextQuestion {
  final IconData icon;
  final Color color;
  final String question;
  final String subtitle;
  final String answer;
  final String? linkedHowToId;
  const _TextQuestion({required this.icon, required this.color, required this.question, required this.subtitle, required this.answer, this.linkedHowToId});
}

// ═══════════════════════════════════════════════════════════════════
// HERO BANNER
// ═══════════════════════════════════════════════════════════════════

class _HeroBanner extends StatelessWidget {
  final ThemeData theme;
  const _HeroBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.1),
            theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.15 : 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline_rounded, size: 36, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(l10n.faqHeroTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(l10n.faqHeroSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// HOW-TO CARD — tappable entry on landing page
// ═══════════════════════════════════════════════════════════════════

class _HowToCard extends StatelessWidget {
  final _HowTo howTo;
  final List<_HowTo> allHowTos;
  const _HowToCard({required this.howTo, required this.allHowTos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _FaqDetailScreen(howTo: howTo)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.outlineVariant.withValues(alpha: 0.25)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: howTo.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(howTo.icon, size: 22, color: howTo.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(howTo.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(howTo.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l10n.faqStepsCount(howTo.steps.length),
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.outline, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// QUESTION CARD — expandable text Q&A
// ═══════════════════════════════════════════════════════════════════

class _QuestionCard extends StatelessWidget {
  final _TextQuestion question;
  final List<_HowTo> allHowTos;
  const _QuestionCard({required this.question, required this.allHowTos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.25)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: question.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(question.icon, size: 18, color: question.color),
        ),
        title: Text(question.question,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(question.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(question.answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant, height: 1.5)),
          ),
          if (question.linkedHowToId != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  final linked = allHowTos.where((h) => h.id == question.linkedHowToId).firstOrNull;
                  if (linked != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => _FaqDetailScreen(howTo: linked)),
                    );
                  }
                },
                icon: Icon(Icons.arrow_forward, size: 16, color: question.color),
                label: Text(l10n.faqSeeHowTo, style: TextStyle(color: question.color)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: question.color.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FAQ DETAIL SCREEN — step-by-step timeline
// ═══════════════════════════════════════════════════════════════════

class _FaqDetailScreen extends StatelessWidget {
  final _HowTo howTo;
  const _FaqDetailScreen({super.key, required this.howTo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(howTo.title)),
      body: SelectionArea(child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Responsive.constrainWidth(context, child: Column(
            children: [
          // ── Hero header ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  howTo.color.withValues(alpha: isDark ? 0.25 : 0.1),
                  howTo.color.withValues(alpha: isDark ? 0.08 : 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: howTo.color.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: howTo.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(howTo.icon, size: 28, color: howTo.color),
                ),
                const SizedBox(height: 14),
                Text(howTo.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text(howTo.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: howTo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.format_list_numbered, size: 13, color: howTo.color),
                      const SizedBox(width: 4),
                      Text(l10n.faqStepsCount(howTo.steps.length),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: howTo.color)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Steps ──
          for (int i = 0; i < howTo.steps.length; i++)
            _StepCard(step: howTo.steps[i], color: howTo.color, isLast: i == howTo.steps.length - 1),
            ],
          )),
        ],
      )),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STEP CARD — timeline with screenshot
// ═══════════════════════════════════════════════════════════════════

class _StepCard extends StatelessWidget {
  final _FaqStep step;
  final Color color;
  final bool isLast;
  const _StepCard({required this.step, required this.color, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline column ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
                  ),
                  child: Center(child: Icon(step.icon, size: 16, color: color)),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.05)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Content ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(step.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(step.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant, height: 1.5)),

                  // ── Screenshot ──
                  if (step.asset != null) ...[
                    const SizedBox(height: 12),
                    _FaqAssetWidget(asset: step.asset!, color: color),
                  ],

                  // ── Tip box ──
                  if (step.tip != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(step.tip!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant, fontSize: 12, height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FAQ ASSET WIDGET — loads from assets/images/faqs/
// ═══════════════════════════════════════════════════════════════════

class _FaqAssetWidget extends StatelessWidget {
  final _FaqAsset asset;
  final Color color;
  const _FaqAssetWidget({required this.asset, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assetPath = 'assets/images/faqs/${asset.filename}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 180, maxHeight: 320),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            height: 180,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_android, size: 32, color: color.withValues(alpha: 0.3)),
                const SizedBox(height: 10),
                Text(asset.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5), fontSize: 11, height: 1.4),
                    textAlign: TextAlign.center,
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
