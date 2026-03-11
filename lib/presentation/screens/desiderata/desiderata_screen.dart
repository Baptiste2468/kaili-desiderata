import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';

class DesiderataScreen extends ConsumerStatefulWidget {
  const DesiderataScreen({super.key});

  @override
  ConsumerState<DesiderataScreen> createState() => _DesiderataScreenState();
}

class _DesiderataScreenState extends ConsumerState<DesiderataScreen> {
  // Variables d'état de l'interface
  bool _showForm = false;
  FormTypeEnum _selectedType = FormTypeEnum.reguliere;
  DateTime? _lastTransferAt;
  final Set<String> _regularPreferences = {};
  String? _regularOtherText;
  
  // Variables du formulaire
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedPreference;
  String? _otherPeriodicText;

  @override
  Widget build(BuildContext context) {
    // Les écoutes Riverpod doivent TOUJOURS être dans le build principal
    final desiderataAsync = ref.watch(desiderataProvider);

    return Scaffold(
      backgroundColor: KailiColors.background,
      body: SafeArea(
        child: _showForm
            ? _buildFormView()
            : _buildDashboardView(desiderataAsync),
      ),
    );
  }

  // ──── Vue Dashboard (Affichage des demandes) ────
  Widget _buildDashboardView(
    AsyncValue<List<Desiderata>> desiderataAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Text(
            'Désidérata',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: KailiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gérez vos congés et préférences',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: KailiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Bouton créer désidérata
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _showForm = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: KailiColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '+ Créer un désidérata',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Mes demandes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mes demandes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KailiColors.textPrimary,
                ),
              ),
              desiderataAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) => Text(
                  '${list.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: KailiColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          desiderataAsync.when(
            loading: () => _buildLoadingShimmer(),
            error: (e, _) => const SizedBox.shrink(),
            data: (list) {
              final hasItems = list.isNotEmpty;
              final hasNewSinceTransfer = _hasNewDesiderataSinceLastTransfer(list);
              final user = ref.read(authProvider).user;
              final canTransfer = hasNewSinceTransfer && user != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasItems)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 40,
                              color: KailiColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune demande',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: KailiColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children:
                          list.map((d) => _buildDesiderataItem(d)).toList(),
                    ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KailiColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: KailiColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transférer à votre cadre de santé',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: KailiColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Le fichier généré est directement compatible avec Kaili (gestion des plannings).',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: KailiColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canTransfer
                                ? () => _onTransferToManagerPressed(list, user!)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canTransfer
                                  ? KailiColors.primary
                                  : KailiColors.border,
                              foregroundColor: canTransfer
                                  ? Colors.white
                                  : KailiColors.textSecondary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Transférer les informations à mon cadre de santé',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ──── Vue Formulaire (Créer/Modifier) ────
  Widget _buildFormView() {
    return Column(
      children: [
        // En-tête avec bouton retour
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            border: const Border(bottom: BorderSide(color: KailiColors.border, width: 1)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showForm = false),
                color: KailiColors.textPrimary,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 12),
              Text(
                'Créer un désidérata',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: KailiColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Sélecteur type
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type de désidérata',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: KailiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTypeSelector(),
                const SizedBox(height: 32),

                // Formulaire selon le type
                if (_selectedType == FormTypeEnum.reguliere)
                  _buildRegularForm()
                else
                  _buildPeriodicForm(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: KailiColors.border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton('Régulière', FormTypeEnum.reguliere),
          ),
          Container(width: 1, color: KailiColors.border),
          Expanded(
            child: _buildTypeButton('Ponctuelle', FormTypeEnum.ponctuelle),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, FormTypeEnum type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? KailiColors.primarySurface : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? KailiColors.primary : KailiColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegularForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Préférences régulières',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: KailiColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildRegularPreferenceItem('Matin', 'Travailler le matin'),
        const SizedBox(height: 12),
        _buildRegularPreferenceItem('Soir', 'Travailler le soir'),
        const SizedBox(height: 12),
        _buildRegularPreferenceItem('Nuit', 'Travailler la nuit'),
        const SizedBox(height: 12),
        _buildRegularOtherPreference(),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final hasRegular = _regularPreferences.isNotEmpty;
              final hasOther =
                  _regularOtherText != null && _regularOtherText!.trim().isNotEmpty;

              if (!hasRegular && !hasOther) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Sélectionnez au moins une préférence ou renseignez un champ "Autre".',
                    ),
                  ),
                );
                return;
              }

              final now = DateTime.now();

              for (final pref in _regularPreferences) {
                final newDes = Desiderata(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: DesiderataType.preference,
                  startDate: now,
                  endDate: null,
                  comment: 'Préférence régulière : $pref',
                  status: DesiderataStatus.enAttente,
                  submittedAt: DateTime.now(),
                );

                await ref
                    .read(desiderataProvider.notifier)
                    .submit(newDes);
              }

              if (hasOther) {
                final comment = 'Autre (régulier) : ${_regularOtherText!.trim()}';
                final otherDes = Desiderata(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: DesiderataType.preference,
                  startDate: now,
                  endDate: null,
                  comment: comment,
                  status: DesiderataStatus.enAttente,
                  submittedAt: DateTime.now(),
                );

                await ref
                    .read(desiderataProvider.notifier)
                    .submit(otherDes);
              }

              setState(() {
                _showForm = false;
                _regularPreferences.clear();
                _regularOtherText = null;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Préférences régulières enregistrées et prêtes à être transférées à votre cadre de santé.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KailiColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Enregistrer'),
          ),
        ),
      ],
    );
  }

  Widget _buildRegularPreferenceItem(String title, String description) {
    final isSelected = _regularPreferences.contains(title);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _regularPreferences.remove(title);
          } else {
            _regularPreferences.add(title);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? KailiColors.primarySurface : KailiColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? KailiColors.primary : KailiColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: KailiColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: KailiColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              size: 18,
              color: isSelected
                  ? KailiColors.primary
                  : KailiColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularOtherPreference() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: KailiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KailiColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Autre',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: KailiColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Précisez une préférence régulière particulière (ex : Pas plus de 3 nuits par semaine).',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: KailiColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Autre : …',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _regularOtherText = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodicForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Désidérata ponctuel',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: KailiColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KailiColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: KailiColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Du ', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              _buildDateInput('Date de début', true),
              const SizedBox(height: 12),
              Text('au ', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              _buildDateInput('Date de fin', false),
              const SizedBox(height: 16),
              Text('je souhaite : ', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              _buildPreferenceDropdown(),
              if (_selectedPreference == 'Autre') ...[
                const SizedBox(height: 12),
                Text(
                  'Précisez votre demande (ex : Éviter les nuits ce week-end).',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: KailiColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Autre : …',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _otherPeriodicText = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              // Vérification des champs vides
              if (_startDate == null || _endDate == null || _selectedPreference == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez remplir tous les champs.')),
                );
                return;
              }

              if (_selectedPreference == 'Autre' &&
                  (_otherPeriodicText == null ||
                      _otherPeriodicText!.trim().isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez préciser votre demande dans le champ "Autre".'),
                  ),
                );
                return;
              }

              // Sécurité logique : la fin doit être après le début
              if (_endDate!.isBefore(_startDate!)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La date de fin ne peut pas précéder la date de début.')),
                );
                return;
              }
                
              final newDes = Desiderata(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: DesiderataType.preference,
                startDate: _startDate!,
                endDate: _endDate,
                comment: _selectedPreference == 'Autre'
                    ? 'Autre (ponctuel) : ${_otherPeriodicText!.trim()}'
                    : _selectedPreference,
                status: DesiderataStatus.enAttente,
                submittedAt: DateTime.now(),
              );

              await ref.read(desiderataProvider.notifier).submit(newDes);

              setState(() {
                _showForm = false;
                _startDate = null;
                _endDate = null;
                _selectedPreference = null;
                _otherPeriodicText = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KailiColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Soumettre'),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput(String label, bool isStartDate) {
    final selectedDate = isStartDate ? _startDate : _endDate;
    
    return GestureDetector(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: KailiColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: KailiColors.border, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: KailiColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedDate != null 
                  ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}" 
                  : label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selectedDate != null ? KailiColors.textPrimary : KailiColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 244, 251),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: KailiColors.border, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedPreference, 
          hint: Text(
            'Choisir une préférence',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: KailiColors.textSecondary,
            ),
          ),
          items: ['Repos', 'Matin', 'Soir', 'Nuit', 'Autre']
              .map(
                (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                          color: KailiColors.textPrimary,
                        ),
                  ),
                ),
              )
              .toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedPreference = newValue;
              if (newValue != 'Autre') {
                _otherPeriodicText = null;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildDesiderataItem(Desiderata desiderata) {
    // Sécurité anti-crash au cas où l'ID fait moins de 5 caractères
    final displayId = desiderata.id.length >= 5 
        ? desiderata.id.substring(0, 5) 
        : desiderata.id;
    final title = _formatDesiderataTitle(desiderata);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: KailiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KailiColors.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: KailiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Statut: ${desiderata.status.label} • #$displayId',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: KailiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: KailiColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatShortDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  String _formatDesiderataTitle(Desiderata d) {
    String base;
    final comment = d.comment ?? '';
    final lowerComment = comment.toLowerCase();

    if (lowerComment == 'matin' ||
        lowerComment == 'soir' ||
        lowerComment == 'nuit' ||
        lowerComment == 'repos') {
      base = '${comment[0].toUpperCase()}${comment.substring(1).toLowerCase()}';
    } else if (comment.startsWith('Préférence régulière')) {
      base = comment;
    } else if (comment.isNotEmpty) {
      base = comment;
    } else {
      base = d.type.label;
    }

    final start = _formatShortDate(d.startDate);

    if (d.endDate == null || _isSameDay(d.startDate, d.endDate!)) {
      return '$base le $start';
    } else {
      final end = _formatShortDate(d.endDate!);
      return '$base du $start au $end';
    }
  }

  bool _hasNewDesiderataSinceLastTransfer(List<Desiderata> list) {
    if (list.isEmpty) return false;
    if (_lastTransferAt == null) return true;
    return list.any((d) => d.submittedAt.isAfter(_lastTransferAt!));
  }

  Future<void> _onTransferToManagerPressed(
    List<Desiderata> list,
    User user,
  ) async {
    try {
      await ref
          .read(kailiExportRepositoryProvider)
          .exportDesiderataForPlanning(user: user, desiderata: list);

      setState(() {
        _lastTransferAt = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Les informations ont été transférées à votre cadre de santé au format compatible avec Kaili.',
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue lors du transfert vers Kaili. Veuillez réessayer.',
          ),
        ),
      );
    }
  }
}

enum FormTypeEnum { reguliere, ponctuelle }