import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/pcos_api_service.dart';
import '../services/health_profile_service.dart';
import '../widgets/pcos_card.dart';

class PcosScreen extends StatefulWidget {
  const PcosScreen({super.key});

  @override
  State<PcosScreen> createState() => _PcosScreenState();
}

class _PcosScreenState extends State<PcosScreen> {
  int _activeTab = 0;

  // ---- Detection form state ----
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _cycleLengthController = TextEditingController();
  final _prlController = TextEditingController();
  final _vitD3Controller = TextEditingController();
  final _prgController = TextEditingController();
  final _rbsController = TextEditingController();
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _follicleLController = TextEditingController();
  final _follicleRController = TextEditingController();
  final _avgFSizeLController = TextEditingController();
  final _avgFSizeRController = TextEditingController();
  final _endometriumController = TextEditingController();
  final _notesController = TextEditingController();

  String _cycleRegularity = 'Regular';

  // Optional extras. NOT used by the model; kept on this screen only.
  String? _maritalStatus; // 'Married', 'Unmarried', 'Prefer not to say'

  bool _weightGain = false;
  bool _hairGrowth = false;
  bool _skinDarkening = false;
  bool _hairLoss = false;
  bool _pimples = false;
  bool _fastFood = false;
  bool _regularExercise = false;

  bool _isLoading = false;
  PcosResult? _result;
  String? _errorText;
  bool _prefilled = false;

  List<TextEditingController> get _requiredControllers => [
    _ageController,
    _weightController,
    _heightController,
    _cycleLengthController,
    _prlController,
    _vitD3Controller,
    _prgController,
    _rbsController,
    _bpSystolicController,
    _bpDiastolicController,
    _follicleLController,
    _follicleRController,
    _avgFSizeLController,
    _avgFSizeRController,
    _endometriumController,
  ];

  double get _progress {
    final all = _requiredControllers;
    final filled = all.where((c) => c.text.trim().isNotEmpty).length;
    return filled / all.length;
  }

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  /// Pre-fills whatever the AI check-in / diary already knows. Only fills
  /// empty fields -- never overwrites something already typed.
  Future<void> _prefillFromProfile() async {
    final profile = await HealthProfileService().loadProfile();
    if (!mounted) return;

    bool filledSomething = false;

    setState(() {
      if (_ageController.text.isEmpty && profile.demographics.ageYrs != null) {
        _ageController.text = profile.demographics.ageYrs.toString();
        filledSomething = true;
      }
      if (_weightController.text.isEmpty &&
          profile.demographics.weightKg != null) {
        _weightController.text = profile.demographics.weightKg.toString();
        filledSomething = true;
      }
      if (_heightController.text.isEmpty &&
          profile.demographics.heightCm != null) {
        _heightController.text = profile.demographics.heightCm.toString();
        filledSomething = true;
      }
      if (profile.reproductiveHistory.cycleRegularity != null) {
        _cycleRegularity = profile.reproductiveHistory.cycleRegularity!;
        filledSomething = true;
      }
      if (_cycleLengthController.text.isEmpty &&
          profile.reproductiveHistory.cycleLengthDays != null) {
        _cycleLengthController.text = profile
            .reproductiveHistory
            .cycleLengthDays
            .toString();
        filledSomething = true;
      }
      if (profile.lifestyle.fastFoodFrequent != null) {
        _fastFood = profile.lifestyle.fastFoodFrequent!;
        filledSomething = true;
      }
      if (profile.lifestyle.regularExercise != null) {
        _regularExercise = profile.lifestyle.regularExercise!;
        filledSomething = true;
      }
      _prefilled = filledSomething;
    });
  }

  @override
  void dispose() {
    for (final c in _requiredControllers) {
      c.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  String _formattedDate() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 20),
            if (_activeTab == 0)
              ..._buildInformationTab()
            else
              ..._buildDetectionTab(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Wellness ',
                style: AppTextStyles.serif(
                  size: 22,
                  weight: FontWeight.w600,
                  color: AppColors.accent,
                ).copyWith(fontStyle: FontStyle.italic),
              ),
              TextSpan(
                text: 'Saheli',
                style: AppTextStyles.serif(
                  size: 22,
                  weight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Text(
          _formattedDate(),
          style: AppTextStyles.sans(size: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _tabButton('ℹ️', 'Information', 0, AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(
          child: _tabButton('🔍', 'Detection', 1, AppColors.ovulationTeal),
        ),
      ],
    );
  }

  Widget _tabButton(String emoji, String label, int index, Color activeColor) {
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.6)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.sans(
                size: 13,
                weight: FontWeight.w600,
                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INFORMATION TAB (unchanged from your original)
  // =========================================================
  List<Widget> _buildInformationTab() {
    return [
      _heroCard(),
      const SizedBox(height: 24),
      _sectionLabel('WHAT IS PCOS?'),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '💡',
        badgeColor: AppColors.primary,
        title: 'Overview',
        subtitle: 'PCOS basics',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            text:
                'PCOS (Polycystic Ovary Syndrome) is a common hormonal condition affecting the ovaries and metabolism. Despite the name, many people with PCOS do not actually have cysts on their ovaries — the name reflects how the condition was first described on ultrasound, not how it\'s diagnosed today.',
          ),
        ],
      ),
      const SizedBox(height: 20),
      _sectionLabel('SYMPTOMS & DIAGNOSIS'),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '📋',
        badgeColor: AppColors.symptomOrange,
        title: 'Common Symptoms',
        subtitle: 'How PCOS presents',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            boldLead: 'Menstrual irregularities',
            text:
                'Infrequent, irregular, or prolonged periods. Some people have fewer than 8 cycles per year.',
          ),
          PcosLine(
            boldLead: 'Hyperandrogenism',
            text:
                'Elevated androgens causing excess facial or body hair (hirsutism), acne, and scalp hair thinning.',
          ),
          PcosLine(
            boldLead: 'Metabolic symptoms',
            text:
                'Weight gain, difficulty losing weight, fatigue, sugar cravings, and insulin resistance.',
          ),
          PcosLine(
            boldLead: 'Mood changes',
            text:
                'Anxiety and depression are significantly more common in people with PCOS.',
          ),
        ],
        tags: const [
          PcosTag('Irregular periods', AppColors.ovulationTeal),
          PcosTag('Hirsutism', AppColors.symptomOrange),
          PcosTag('Acne', AppColors.periodRed),
          PcosTag('Insulin resistance', AppColors.primary),
        ],
      ),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '🔍',
        badgeColor: AppColors.ovulationTeal,
        title: 'Diagnosis (Rotterdam Criteria)',
        subtitle: 'How it is identified',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            text:
                'PCOS is diagnosed when at least 2 of the following 3 criteria are met:',
          ),
          PcosLine(
            number: '1',
            boldLead: 'Irregular or absent ovulation',
            text: 'reflected in irregular or missing periods.',
          ),
          PcosLine(
            number: '2',
            boldLead: 'Clinical or biochemical hyperandrogenism',
            text:
                'excess hair growth, acne, or elevated androgen levels on a blood test.',
          ),
          PcosLine(
            number: '3',
            boldLead: 'Polycystic ovarian morphology on ultrasound',
            text:
                '12 or more follicles in an ovary or increased ovarian volume.',
          ),
        ],
        tags: const [
          PcosTag('Blood tests', AppColors.ovulationTeal),
          PcosTag('Ultrasound', AppColors.primary),
          PcosTag('2 of 3 criteria', AppColors.moodYellow),
        ],
      ),
      const SizedBox(height: 20),
      _sectionLabel('HORMONES & CAUSES'),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '⚡',
        badgeColor: AppColors.accent,
        title: 'Hormonal Imbalances',
        subtitle: 'What goes wrong inside the body',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            text:
                'In PCOS, the pituitary releases more LH relative to FSH, stimulating the ovaries to produce excess androgens instead of allowing normal follicle maturation and ovulation.',
          ),
          PcosLine(
            boldLead: 'Insulin resistance',
            text:
                'is present in up to 70% of people with PCOS. High insulin further stimulates androgen production and reduces sex-hormone-binding globulin (SHBG), leaving more free testosterone in the blood.',
          ),
          PcosLine(
            boldLead: 'Chronic low-grade inflammation',
            text:
                'also contributes to androgen production and the metabolic features of the condition.',
          ),
        ],
        tags: const [
          PcosTag('High LH', AppColors.accent),
          PcosTag('High androgens', AppColors.periodRed),
          PcosTag('Low SHBG', AppColors.moodYellow),
          PcosTag('Insulin resistance', AppColors.primary),
        ],
      ),
      const SizedBox(height: 20),
      _sectionLabel('MANAGEMENT & TREATMENT'),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '🌿',
        badgeColor: AppColors.ovulationTeal,
        title: 'Lifestyle & Diet',
        subtitle: 'First-line management',
        initiallyExpanded: true,
        lines: const [
          PcosLine(
            text:
                'Even a 5–10% reduction in body weight (where applicable) can significantly restore ovulation and reduce androgen levels.',
          ),
          PcosLine(
            boldLead: 'Diet',
            text:
                'A low-GI diet helps manage insulin resistance. Focus on whole grains, legumes, lean protein, and healthy fats.',
          ),
          PcosLine(
            boldLead: 'Exercise',
            text:
                'Both aerobic and resistance training improve insulin sensitivity. Aim for 150 minutes of moderate activity per week.',
          ),
          PcosLine(
            boldLead: 'Sleep & stress',
            text:
                'Poor sleep and chronic stress worsen cortisol and insulin levels.',
          ),
        ],
        tags: const [
          PcosTag('Low-GI diet', AppColors.ovulationTeal),
          PcosTag('Exercise', AppColors.primary),
          PcosTag('Sleep hygiene', AppColors.accent),
        ],
      ),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '💊',
        badgeColor: AppColors.periodRed,
        title: 'Medications',
        subtitle: 'Medical treatment options',
        initiallyExpanded: false,
        lines: const [
          PcosLine(
            boldLead: 'Combined pill',
            text:
                'Regulates cycles, lowers androgens, and protects the uterine lining.',
          ),
          PcosLine(
            boldLead: 'Metformin',
            text:
                'Improves insulin sensitivity and can help restore ovulation.',
          ),
          PcosLine(
            boldLead: 'Anti-androgens',
            text:
                'Reduce excess hair growth and acne, usually combined with contraception.',
          ),
          PcosLine(
            boldLead: 'Fertility medication',
            text:
                'Such as letrozole may be used to induce ovulation when trying to conceive.',
          ),
        ],
      ),
      const SizedBox(height: 12),
      PcosCard(
        emoji: '⏳',
        badgeColor: AppColors.moodYellow,
        title: 'Long-Term Health Risks',
        subtitle: 'Why monitoring over time matters',
        initiallyExpanded: false,
        lines: const [
          PcosLine(
            boldLead: 'Type 2 diabetes',
            text:
                'Insulin resistance raises long-term risk, so regular glucose screening is recommended.',
          ),
          PcosLine(
            boldLead: 'Cardiovascular disease',
            text:
                'Higher rates of high blood pressure and cholesterol are seen in PCOS.',
          ),
          PcosLine(
            boldLead: 'Endometrial health',
            text:
                'Infrequent periods can let the uterine lining build up, raising long-term risk if untreated.',
          ),
        ],
      ),
    ];
  }

  // =========================================================
  // DETECTION TAB (redesigned)
  // =========================================================
  List<Widget> _buildDetectionTab() {
    return [
      _detectionHeroCard(),
      const SizedBox(height: 14),
      _progressBar(),
      const SizedBox(height: 14),
      if (_prefilled) ...[_prefillBanner(), const SizedBox(height: 14)],
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepCard(
              icon: Icons.person_outline,
              color: AppColors.primary,
              title: 'About you',
              helper:
                  'Basic details. Height and weight are used to work out BMI.',
              children: [
                _fieldRow(
                  _numberField('Age (yrs)', _ageController, hint: 'e.g. 24'),
                  _numberField(
                    'Weight (kg)',
                    _weightController,
                    hint: 'e.g. 58',
                  ),
                ),
                const SizedBox(height: 12),
                _numberField(
                  'Height (cm)',
                  _heightController,
                  hint: 'e.g. 162',
                ),
                const SizedBox(height: 14),
                _fieldLabel('MARITAL STATUS (OPTIONAL)'),
                const SizedBox(height: 6),
                _maritalStatusChips(),
                const SizedBox(height: 6),
                Text(
                  'Not used for the prediction. It only appears in the summary you can share with your doctor.',
                  style: AppTextStyles.sans(
                    size: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            _stepCard(
              icon: Icons.calendar_month_outlined,
              color: AppColors.periodRed,
              title: 'Your cycle',
              helper: 'Think about your last few months.',
              children: [
                _fieldLabel('CYCLE REGULARITY'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: _regularityOption('Regular')),
                    const SizedBox(width: 10),
                    Expanded(child: _regularityOption('Irregular')),
                  ],
                ),
                const SizedBox(height: 12),
                _numberField(
                  'Cycle length (days)',
                  _cycleLengthController,
                  hint: 'e.g. 30',
                ),
              ],
            ),
            _stepCard(
              icon: Icons.science_outlined,
              color: AppColors.ovulationTeal,
              title: 'Lab results',
              helper: 'Enter values from your latest blood tests and check-up.',
              children: [
                _fieldRow(
                  _numberField(
                    'PRL (ng/mL)',
                    _prlController,
                    hint: 'e.g. 18.5',
                  ),
                  _numberField(
                    'Vit D3 (ng/mL)',
                    _vitD3Controller,
                    hint: 'e.g. 32.0',
                  ),
                ),
                const SizedBox(height: 12),
                _fieldRow(
                  _numberField('PRG (ng/mL)', _prgController, hint: 'e.g. 1.2'),
                  _numberField('RBS (mg/dl)', _rbsController, hint: 'e.g. 95'),
                ),
                const SizedBox(height: 12),
                _fieldRow(
                  _numberField(
                    'Systolic (mmHg)',
                    _bpSystolicController,
                    hint: 'e.g. 120',
                  ),
                  _numberField(
                    'Diastolic (mmHg)',
                    _bpDiastolicController,
                    hint: 'e.g. 80',
                  ),
                ),
              ],
            ),
            _stepCard(
              icon: Icons.monitor_heart_outlined,
              color: AppColors.accent,
              title: 'Ultrasound',
              helper:
                  'Use the numbers from your scan report. The result is only meaningful with real scan values.',
              children: [
                _fieldRow(
                  _numberField(
                    'Follicle No. (L)',
                    _follicleLController,
                    hint: 'e.g. 12',
                  ),
                  _numberField(
                    'Follicle No. (R)',
                    _follicleRController,
                    hint: 'e.g. 11',
                  ),
                ),
                const SizedBox(height: 12),
                _fieldRow(
                  _numberField(
                    'Avg. F size (L) (mm)',
                    _avgFSizeLController,
                    hint: 'e.g. 8.5',
                  ),
                  _numberField(
                    'Avg. F size (R) (mm)',
                    _avgFSizeRController,
                    hint: 'e.g. 8.2',
                  ),
                ),
                const SizedBox(height: 12),
                _numberField(
                  'Endometrium (mm)',
                  _endometriumController,
                  hint: 'e.g. 7.0',
                ),
              ],
            ),
            _stepCard(
              icon: Icons.favorite_border,
              color: AppColors.symptomOrange,
              title: 'Symptoms',
              helper: 'Switch on anything you have noticed recently.',
              children: [
                _toggleRow(
                  'Weight gain',
                  _weightGain,
                  (v) => setState(() => _weightGain = v),
                ),
                _toggleRow(
                  'Excess hair growth',
                  _hairGrowth,
                  (v) => setState(() => _hairGrowth = v),
                ),
                _toggleRow(
                  'Skin darkening',
                  _skinDarkening,
                  (v) => setState(() => _skinDarkening = v),
                ),
                _toggleRow(
                  'Hair loss',
                  _hairLoss,
                  (v) => setState(() => _hairLoss = v),
                ),
                _toggleRow(
                  'Pimples',
                  _pimples,
                  (v) => setState(() => _pimples = v),
                ),
              ],
            ),
            _stepCard(
              icon: Icons.spa_outlined,
              color: AppColors.ovulationTeal,
              title: 'Lifestyle',
              helper: 'Your usual habits.',
              children: [
                _toggleRow(
                  'Frequent fast food',
                  _fastFood,
                  (v) => setState(() => _fastFood = v),
                ),
                _toggleRow(
                  'Regular exercise',
                  _regularExercise,
                  (v) => setState(() => _regularExercise = v),
                ),
              ],
            ),
            _stepCard(
              icon: Icons.edit_note,
              color: AppColors.primary,
              title: 'Anything else?',
              helper:
                  'Optional. Medications, family history, other symptoms. Not used for the prediction, but included in your doctor summary.',
              children: [_notesField()],
            ),
            const SizedBox(height: 4),
            _submitButton(),
            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                style: AppTextStyles.sans(size: 12, color: AppColors.periodRed),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              _resultCard(_result!),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _prefillBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.ovulationTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.ovulationTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 15, color: AppColors.ovulationTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Some fields were pre-filled from your profile. Review and edit as needed.',
              style: AppTextStyles.sans(
                size: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detectionHeroCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.ovulationTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Text('🧪', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 12),
          Text('PCOS Risk Check', style: AppTextStyles.serif(size: 19)),
          const SizedBox(height: 8),
          Text(
            'Answer a few sections to get a screening estimate. It takes about 3 minutes and helps you decide whether to talk to a doctor.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sans(
              size: 12,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _progressBar() {
    final pct = (_progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Form progress',
              style: AppTextStyles.sans(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$pct%',
              style: AppTextStyles.sans(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: AppColors.cardBorder,
            valueColor: AlwaysStoppedAnimation(AppColors.ovulationTeal),
          ),
        ),
      ],
    );
  }

  /// A rounded card with a coloured icon badge, title, helper line and body.
  Widget _stepCard({
    required IconData icon,
    required Color color,
    required String title,
    required String helper,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.sans(
                        size: 14,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      helper,
                      style: AppTextStyles.sans(
                        size: 11,
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.sans(
        size: 10,
        weight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label.toUpperCase()),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.sans(size: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.sans(
              size: 13,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.ovulationTeal),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            if (double.tryParse(value.trim()) == null) return 'Enter a number';
            return null;
          },
        ),
      ],
    );
  }

  Widget _maritalStatusChips() {
    const options = ['Married', 'Unmarried', 'Prefer not to say'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final selected = _maritalStatus == o;
        return GestureDetector(
          onTap: () => setState(() => _maritalStatus = selected ? null : o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : AppColors.cardBorder,
              ),
            ),
            child: Text(
              o,
              style: AppTextStyles.sans(
                size: 12,
                weight: FontWeight.w600,
                color: selected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _notesField() {
    return TextFormField(
      controller: _notesController,
      minLines: 3,
      maxLines: 6,
      maxLength: 500,
      style: AppTextStyles.sans(size: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'e.g. taking metformin, family history of diabetes…',
        hintStyle: AppTextStyles.sans(size: 13, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.ovulationTeal),
        ),
      ),
    );
  }

  Widget _regularityOption(String value) {
    final isActive = _cycleRegularity == value;
    return GestureDetector(
      onTap: () => setState(() => _cycleRegularity = value),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.ovulationTeal.withValues(alpha: 0.18)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? AppColors.ovulationTeal.withValues(alpha: 0.6)
                : AppColors.cardBorder,
          ),
        ),
        child: Text(
          value,
          style: AppTextStyles.sans(
            size: 12,
            weight: FontWeight.w600,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.sans(size: 13, color: AppColors.textPrimary),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.ovulationTeal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onRunDetectionPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ovulationTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Check my PCOS risk',
                style: AppTextStyles.sans(
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // ---- Result: a likelihood band instead of "PCOS Detected" ----
  ({String band, String headline, String body, Color color}) _bandFor(
    double p,
  ) {
    if (p < 0.33) {
      return (
        band: 'Low likelihood',
        headline: 'Lower likelihood of PCOS',
        body:
            'Based on what you entered, PCOS looks less likely. A low result does not rule PCOS out. If you have symptoms or concerns, please still see a doctor.',
        color: AppColors.ovulationTeal,
      );
    }
    if (p < 0.66) {
      return (
        band: 'Moderate likelihood',
        headline: 'Possible PCOS',
        body:
            'Some of your values point towards PCOS. This is worth discussing with a doctor, who can run the right tests to confirm.',
        color: AppColors.symptomOrange,
      );
    }
    return (
      band: 'High likelihood',
      headline: 'Higher likelihood of PCOS',
      body:
          'Several of your values point towards PCOS. Please see a doctor to confirm. Only a doctor can diagnose PCOS.',
      color: AppColors.periodRed,
    );
  }

  Widget _resultCard(PcosResult result) {
    final p = result.pcosProbability.clamp(0.0, 1.0).toDouble();
    final b = _bandFor(p);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: b.color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: b.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              b.band.toUpperCase(),
              style: AppTextStyles.sans(
                size: 10,
                weight: FontWeight.w700,
                color: b.color,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            b.headline,
            style: AppTextStyles.sans(
              size: 16,
              weight: FontWeight.w700,
              color: b.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Screening estimate: ${(p * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.sans(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            b.body,
            style: AppTextStyles.sans(
              size: 12,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            'This is a screening estimate from a model trained on a limited dataset. It is not a medical diagnosis.',
            style: AppTextStyles.sans(
              size: 11,
              color: AppColors.textSecondary,
            ).copyWith(fontStyle: FontStyle.italic, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => _copySummary(result, b.band),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: Text(
                'Copy summary for my doctor',
                style: AppTextStyles.sans(size: 12, weight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: b.color.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _yn(bool v) => v ? 'Yes' : 'No';

  Future<void> _copySummary(PcosResult result, String band) async {
    final p = (result.pcosProbability.clamp(0.0, 1.0) * 100).toStringAsFixed(0);
    final notes = _notesController.text.trim();
    final text = StringBuffer()
      ..writeln('Wellness Saheli - PCOS screening summary')
      ..writeln('Result: $band (screening estimate $p%). Not a diagnosis.')
      ..writeln()
      ..writeln(
        'Age: ${_ageController.text} | Height: ${_heightController.text} cm | Weight: ${_weightController.text} kg',
      )
      ..writeln('Marital status: ${_maritalStatus ?? 'Not shared'}')
      ..writeln('Cycle: $_cycleRegularity, ${_cycleLengthController.text} days')
      ..writeln(
        'PRL: ${_prlController.text} | Vit D3: ${_vitD3Controller.text} | PRG: ${_prgController.text} | RBS: ${_rbsController.text}',
      )
      ..writeln(
        'BP: ${_bpSystolicController.text}/${_bpDiastolicController.text} mmHg',
      )
      ..writeln(
        'Follicles L/R: ${_follicleLController.text}/${_follicleRController.text} | Avg size L/R: ${_avgFSizeLController.text}/${_avgFSizeRController.text} mm | Endometrium: ${_endometriumController.text} mm',
      )
      ..writeln(
        'Weight gain: ${_yn(_weightGain)} | Hair growth: ${_yn(_hairGrowth)} | Skin darkening: ${_yn(_skinDarkening)} | Hair loss: ${_yn(_hairLoss)} | Pimples: ${_yn(_pimples)}',
      )
      ..writeln(
        'Fast food: ${_yn(_fastFood)} | Regular exercise: ${_yn(_regularExercise)}',
      );
    if (notes.isNotEmpty) {
      text
        ..writeln()
        ..writeln('Notes: $notes');
    }

    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Summary copied. You can paste it into a message or note.',
        ),
      ),
    );
  }

  /// Validates the form, then runs the prediction.
  Future<void> _onRunDetectionPressed() async {
    setState(() {
      _errorText = null;
      _result = null;
    });

    if (!_formKey.currentState!.validate()) return;

    await _runDetection();
  }

  Future<void> _runDetection() async {
    setState(() => _isLoading = true);

    try {
      final result = await PcosApiService.predict(
        ageYrs: double.parse(_ageController.text.trim()),
        weightKg: double.parse(_weightController.text.trim()),
        heightCm: double.parse(_heightController.text.trim()),
        cycleRegularity: _cycleRegularity,
        cycleLengthDays: double.parse(_cycleLengthController.text.trim()),
        prl: double.parse(_prlController.text.trim()),
        vitD3: double.parse(_vitD3Controller.text.trim()),
        prg: double.parse(_prgController.text.trim()),
        rbs: double.parse(_rbsController.text.trim()),
        bpSystolic: double.parse(_bpSystolicController.text.trim()),
        bpDiastolic: double.parse(_bpDiastolicController.text.trim()),
        follicleNoL: double.parse(_follicleLController.text.trim()),
        follicleNoR: double.parse(_follicleRController.text.trim()),
        avgFSizeL: double.parse(_avgFSizeLController.text.trim()),
        avgFSizeR: double.parse(_avgFSizeRController.text.trim()),
        endometrium: double.parse(_endometriumController.text.trim()),
        weightGain: _weightGain ? 'Yes' : 'No',
        hairGrowth: _hairGrowth ? 'Yes' : 'No',
        skinDarkening: _skinDarkening ? 'Yes' : 'No',
        hairLoss: _hairLoss ? 'Yes' : 'No',
        pimples: _pimples ? 'Yes' : 'No',
        fastFood: _fastFood ? 'Yes' : 'No',
        regularExercise: _regularExercise ? 'Yes' : 'No',
      );

      setState(() {
        _isLoading = false;
        _result = result;
      });

      // Save into the diary/profile (fire-and-forget).
      final service = HealthProfileService();
      service.appendPcosResult(
        prediction: result.prediction,
        pcosProbability: result.pcosProbability,
        modelUsed: result.modelUsed,
      );

      service.updateProfile((p) {
        final age = int.tryParse(_ageController.text.trim());
        final weight = double.tryParse(_weightController.text.trim());
        final height = double.tryParse(_heightController.text.trim());
        final cycleLen = int.tryParse(_cycleLengthController.text.trim());

        return p.copyWith(
          demographics: p.demographics.copyWith(
            ageYrs: age,
            weightKg: weight,
            heightCm: height,
          ),
          reproductiveHistory: p.reproductiveHistory.copyWith(
            cycleRegularity: _cycleRegularity,
            cycleLengthDays: cycleLen,
          ),
          lifestyle: p.lifestyle.copyWith(
            regularExercise: _regularExercise,
            fastFoodFrequent: _fastFood,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Could not get a prediction: $e';
      });
    }
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.sans(
        size: 11,
        weight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Text('🎗️', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 14),
          Text('PCOS Guide', style: AppTextStyles.serif(size: 19)),
          const SizedBox(height: 8),
          Text(
            'Polycystic Ovary Syndrome — a hormonal and metabolic condition affecting people with ovaries, affecting nearly 1 in 10.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sans(
              size: 12,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
