import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/pcos_api_service.dart';
import '../services/health_profile_service.dart';

/// A single bullet/paragraph line inside a card body.
/// If [boldLead] is set, it's rendered bold and inline before [text].
class PcosLine {
  final String? boldLead;
  final String text;
  final String? number; // e.g. "1", "2", "3" for numbered criteria

  const PcosLine({this.boldLead, required this.text, this.number});
}

class PcosTag {
  final String label;
  final Color color;
  const PcosTag(this.label, this.color);
}

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

  String _cycleRegularity = 'Regular';
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

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  /// Pre-fills whatever the AI check-in / diary already knows, so the
  /// person doesn't retype data she's already given the app. Only fills
  /// fields that are currently empty -- never overwrites something she's
  /// already typed into the form.
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
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _cycleLengthController.dispose();
    _prlController.dispose();
    _vitD3Controller.dispose();
    _prgController.dispose();
    _rbsController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _follicleLController.dispose();
    _follicleRController.dispose();
    _avgFSizeLController.dispose();
    _avgFSizeRController.dispose();
    _endometriumController.dispose();
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
          borderRadius: BorderRadius.circular(12),
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
  // DETECTION TAB — now a real, working form (no Coming Soon)
  // =========================================================
  Widget _prefillBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.ovulationTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
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

  List<Widget> _buildDetectionTab() {
    return [
      _detectionHeroCard(),
      const SizedBox(height: 16),
      if (_prefilled) _prefillBanner(),
      const SizedBox(height: 8),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('PERSONAL DETAILS'),
            const SizedBox(height: 12),
            _fieldRow(
              _numberField('Age (yrs)', _ageController, hint: 'e.g. 24'),
              _numberField('Weight (kg)', _weightController, hint: 'e.g. 58'),
            ),
            const SizedBox(height: 12),
            _fieldRow(
              _numberField('Height (cm)', _heightController, hint: 'e.g. 162'),
              _numberField(
                'Cycle length (days)',
                _cycleLengthController,
                hint: 'e.g. 30',
              ),
            ),
            const SizedBox(height: 12),
            _cycleRegularityToggle(),
            const SizedBox(height: 20),

            _sectionLabel('HORMONAL & LAB MARKERS'),
            const SizedBox(height: 12),
            _fieldRow(
              _numberField('PRL (ng/mL)', _prlController, hint: 'e.g. 18.5'),
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
            const SizedBox(height: 20),

            _sectionLabel('BLOOD PRESSURE'),
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
            const SizedBox(height: 20),

            _sectionLabel('ULTRASOUND FINDINGS'),
            const SizedBox(height: 12),
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
            const SizedBox(height: 20),

            _sectionLabel('SYMPTOMS & LIFESTYLE'),
            const SizedBox(height: 12),
            _toggleRow(
              'Weight Gain',
              _weightGain,
              (v) => setState(() => _weightGain = v),
            ),
            _toggleRow(
              'Hair Growth',
              _hairGrowth,
              (v) => setState(() => _hairGrowth = v),
            ),
            _toggleRow(
              'Skin Darkening',
              _skinDarkening,
              (v) => setState(() => _skinDarkening = v),
            ),
            _toggleRow(
              'Hair Loss',
              _hairLoss,
              (v) => setState(() => _hairLoss = v),
            ),
            _toggleRow(
              'Pimples',
              _pimples,
              (v) => setState(() => _pimples = v),
            ),
            _toggleRow(
              'Fast Food',
              _fastFood,
              (v) => setState(() => _fastFood = v),
            ),
            _toggleRow(
              'Regular Exercise',
              _regularExercise,
              (v) => setState(() => _regularExercise = v),
            ),

            const SizedBox(height: 24),
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

  Widget _detectionHeroCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
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
          const SizedBox(height: 14),
          Text('PCOS Detection', style: AppTextStyles.serif(size: 19)),
          const SizedBox(height: 8),
          Text(
            'Enter your medical details below for an AI-powered risk assessment, using a model trained on real clinical data.',
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

  Widget _fieldRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
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
        Text(
          label.toUpperCase(),
          style: AppTextStyles.sans(
            size: 10,
            weight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
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
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
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

  Widget _cycleRegularityToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CYCLE REGULARITY',
          style: AppTextStyles.sans(
            size: 10,
            weight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _regularityOption('Regular')),
            const SizedBox(width: 10),
            Expanded(child: _regularityOption('Irregular')),
          ],
        ),
      ],
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
          borderRadius: BorderRadius.circular(10),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
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
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onRunDetectionPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ovulationTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                'Run PCOS Detection',
                style: AppTextStyles.sans(
                  size: 14,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _resultCard(PcosResult result) {
    final isPositive =
        result.prediction.toLowerCase().contains('detected') &&
        !result.prediction.toLowerCase().contains('no pcos');
    final color = isPositive ? AppColors.periodRed : AppColors.ovulationTeal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.prediction,
            style: AppTextStyles.sans(
              size: 15,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estimated PCOS likelihood: ${(result.pcosProbability * 100).clamp(0, 100).toStringAsFixed(1)}%',
            style: AppTextStyles.sans(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Model used: ${result.modelUsed}',
            style: AppTextStyles.sans(size: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(
            'This is a screening estimate, not a medical diagnosis. Please consult a doctor for confirmation.',
            style: AppTextStyles.sans(
              size: 11,
              color: AppColors.textSecondary,
            ).copyWith(fontStyle: FontStyle.italic, height: 1.4),
          ),
        ],
      ),
    );
  }

  /// Called when the user taps "Run PCOS Detection". Validates the form,
  /// then runs the prediction using the app's single deployed model.
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

      // Save into the diary/profile so history + future AI check-ins
      // can reference it -- fire-and-forget, shouldn't block the result
      // from showing.
      final service = HealthProfileService();
      service.appendPcosResult(
        prediction: result.prediction,
        pcosProbability: result.pcosProbability,
        modelUsed: result.modelUsed,
      );

      // Persist the form inputs back to the profile so Demographics
      // and ReproductiveHistory are no longer permanently "Not set".
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
        borderRadius: BorderRadius.circular(18),
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

/// Accordion-style card used for every PCOS info section. Supports plain
/// paragraphs, bold-lead bullet lines, numbered criteria lines, and an
/// optional row of tag chips at the bottom.
class PcosCard extends StatefulWidget {
  final String emoji;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final List<PcosLine> lines;
  final List<PcosTag>? tags;
  final bool initiallyExpanded;

  const PcosCard({
    super.key,
    required this.emoji,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.lines,
    this.tags,
    this.initiallyExpanded = false,
  });

  @override
  State<PcosCard> createState() => _PcosCardState();
}

class _PcosCardState extends State<PcosCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.badgeColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.sans(
                            size: 14,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.sans(
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final line in widget.lines) _buildLine(line),
                  if (widget.tags != null && widget.tags!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.tags!.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: t.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: t.color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            t.label,
                            style: AppTextStyles.sans(
                              size: 10,
                              weight: FontWeight.w600,
                              color: t.color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(PcosLine line) {
    final baseStyle = AppTextStyles.sans(
      size: 12,
      color: AppColors.textSecondary,
    ).copyWith(height: 1.5);
    final boldStyle = baseStyle.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );

    final spans = <TextSpan>[];
    if (line.number != null) {
      spans.add(TextSpan(text: '${line.number}. ', style: boldStyle));
    }
    if (line.boldLead != null) {
      spans.add(TextSpan(text: line.boldLead, style: boldStyle));
      spans.add(
        TextSpan(
          text: line.number != null ? ' — ${line.text}' : ': ${line.text}',
          style: baseStyle,
        ),
      );
    } else {
      spans.add(TextSpan(text: line.text, style: baseStyle));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(text: TextSpan(children: spans)),
    );
  }
}
