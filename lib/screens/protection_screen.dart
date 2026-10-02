import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/eligibility_api_service.dart';
import '../services/health_profile_service.dart';
import '../models/health_profile.dart';

Widget emojiText(String emoji, {double size = 14}) {
  return Text(
    emoji,
    style: TextStyle(
      fontSize: size,
      fontFamily: 'NotoColorEmoji',
      fontFamilyFallback: const [
        'Noto Color Emoji',
        'Apple Color Emoji',
        'Segoe UI Emoji',
      ],
    ),
  );
}

class ConditionNode {
  final String id;
  final List<ConditionNode> children;
  const ConditionNode(this.id, {this.children = const []});
}

class ConditionGroup {
  final String title;
  final List<ConditionNode> nodes;
  const ConditionGroup(this.title, this.nodes);

  List<String> get allIds => _flatten(nodes);

  static List<String> _flatten(List<ConditionNode> nodes) {
    final result = <String>[];
    for (final n in nodes) {
      result.add(n.id);
      result.addAll(_flatten(n.children));
    }
    return result;
  }
}

List<ConditionNode> _leaves(List<String> ids) =>
    ids.map((id) => ConditionNode(id)).toList();

final List<ConditionGroup> _conditionGroups = [
  ConditionGroup(
    'Anticonvulsant therapy',
    _leaves(['anticonvulsant_certain', 'anticonvulsant_lamotrigine']),
  ),
  ConditionGroup(
    'Antimicrobial therapy',
    _leaves(['antimicrobial_rifampicin', 'antimicrobial_broad_spectrum']),
  ),
  ConditionGroup('Antiretroviral Therapy', [
    ConditionNode('antiretroviral_therapy'),
    ConditionNode(
      'art_nrti',
      children: [
        ConditionNode('art_abacavir_init'),
        ConditionNode('art_abacavir_cont'),
        ConditionNode('art_tenofovir_init'),
        ConditionNode('art_tenofovir_cont'),
        ConditionNode('art_zidovudine_init'),
        ConditionNode('art_zidovudine_cont'),
        ConditionNode('art_lamivudine_init'),
        ConditionNode('art_lamivudine_cont'),
        ConditionNode('art_didanosine_init'),
        ConditionNode('art_didanosine_cont'),
        ConditionNode('art_emtricitabine_init'),
        ConditionNode('art_emtricitabine_cont'),
        ConditionNode('art_stavudine_init'),
        ConditionNode('art_stavudine_cont'),
      ],
    ),
    ConditionNode(
      'art_nnrti',
      children: [
        ConditionNode('art_efavirenz_init'),
        ConditionNode('art_efavirenz_cont'),
        ConditionNode('art_etravirine_init'),
        ConditionNode('art_etravirine_cont'),
        ConditionNode('art_nevirapine_init'),
        ConditionNode('art_nevirapine_cont'),
        ConditionNode('art_rilpivirine_init'),
        ConditionNode('art_rilpivirine_cont'),
      ],
    ),
    ConditionNode(
      'art_pi',
      children: [
        ConditionNode('art_atv_r_init'),
        ConditionNode('art_atv_r_cont'),
        ConditionNode('art_lpv_r_init'),
        ConditionNode('art_lpv_r_cont'),
        ConditionNode('art_drv_r_init'),
        ConditionNode('art_drv_r_cont'),
        ConditionNode('art_ritonavir_init'),
        ConditionNode('art_ritonavir_cont'),
      ],
    ),
    ConditionNode(
      'art_integrase',
      children: [
        ConditionNode('art_raltegravir_init'),
        ConditionNode('art_raltegravir_cont'),
      ],
    ),
  ]),
  ConditionGroup('Benign ovarian tumours', _leaves(['benign_ovarian_tumours'])),
  ConditionGroup(
    'Blood pressure measurement unavailable',
    _leaves(['bp_unavailable']),
  ),
  ConditionGroup('Breast Disease', [
    ConditionNode('breast_undiagnosed_mass'),
    ConditionNode('breast_benign_disease'),
    ConditionNode('breast_family_history_cancer'),
    ConditionNode(
      'breast_cancer_category',
      children: [
        ConditionNode('current_breast_cancer'),
        ConditionNode('past_breast_cancer_5yrs'),
      ],
    ),
  ]),
  ConditionGroup(
    'Breastfeeding',
    _leaves([
      'breastfeeding_lt6weeks',
      'breastfeeding_6wk_6mo',
      'breastfeeding_6mo_plus',
    ]),
  ),
  ConditionGroup('Cardiovascular disease', _leaves(['cardiovascular_disease'])),
  ConditionGroup('Cardiovascular risk factors', _leaves(['multiple_cvd_risk'])),
  ConditionGroup(
    'Cervical conditions',
    _leaves([
      'cervical_cancer_awaiting_treatment',
      'cervical_cancer_initiation',
      'cervical_cancer_continuation',
      'cervical_ectropion',
      'cin',
    ]),
  ),
  ConditionGroup('Cirrhosis', _leaves(['cirrhosis_mild', 'cirrhosis_severe'])),
  ConditionGroup(
    'Diabetes',
    _leaves([
      'diabetes_no_vascular',
      'diabetes_with_vascular',
      'diabetes_gestational_history',
      'diabetes_nephropathy',
      'diabetes_other_vascular_20yrs',
      'diabetes_non_insulin_dependent',
      'diabetes_insulin_dependent',
    ]),
  ),
  ConditionGroup(
    'Endometrial cancer',
    _leaves([
      'endometrial_cancer',
      'endometrial_cancer_initiation',
      'endometrial_cancer_continuation',
    ]),
  ),
  ConditionGroup('Endometriosis', _leaves(['endometriosis'])),
  ConditionGroup('Epilepsy', _leaves(['epilepsy'])),
  ConditionGroup(
    'Gall bladder disease',
    _leaves([
      'gall_bladder_symptomatic_cholecystectomy',
      'gall_bladder_symptomatic_medical',
      'gall_bladder_symptomatic_current',
      'gall_bladder_asymptomatic',
      'gall_bladder_disease',
    ]),
  ),
  ConditionGroup(
    'Gestational trophoblastic disease',
    _leaves([
      'gestational_trophoblastic_disease',
      'gtd_decreasing_hcg',
      'gtd_elevated_hcg_or_malignant',
    ]),
  ),
  ConditionGroup(
    'Headaches',
    _leaves([
      'headache_non_migranous',
      'migraine_no_aura',
      'migraine_no_aura_under35',
      'migraine_no_aura_35plus',
      'migraine_with_aura',
    ]),
  ),
  ConditionGroup(
    'History of cholestasis',
    _leaves(['history_cholestasis', 'history_cholestasis_past_oc_related']),
  ),
  ConditionGroup('History of DVT/PE (blood clots)', _leaves(['vte_history'])),
  ConditionGroup(
    'History of high blood pressure in pregnancy',
    _leaves(['history_pregnancy_hypertension']),
  ),
  ConditionGroup(
    'History of pelvic surgery',
    _leaves(['history_pelvic_surgery']),
  ),
  ConditionGroup(
    'HIV',
    _leaves([
      'high_risk_hiv_sti',
      'known_hiv_on_art',
      'hiv_high_risk',
      'hiv_mild_stage',
      'hiv_severe_stage',
    ]),
  ),
  ConditionGroup(
    'Hypertension',
    _leaves([
      'hypertension_controlled',
      'hypertension_uncontrolled',
      'hypertension_elevated_140_159',
      'hypertension_elevated_160_plus',
      'hypertension_vascular_disease',
    ]),
  ),
  ConditionGroup('Iron-deficient anaemia', _leaves(['iron_deficient_anaemia'])),
  ConditionGroup('Known dyslipidaemias', _leaves(['known_dyslipidaemias'])),
  ConditionGroup(
    'Known thrombogenic mutations',
    _leaves(['known_thrombogenic_mutations']),
  ),
  ConditionGroup(
    'Liver tumours',
    _leaves(['liver_tumours_benign', 'liver_tumours_malignant']),
  ),
  ConditionGroup('Malaria', _leaves(['malaria'])),
  ConditionGroup(
    'Obesity',
    _leaves(['obesity_bmi30', 'obesity_adolescent_bmi30']),
  ),
  ConditionGroup(
    'Ovarian cancer',
    _leaves(['ovarian_cancer_initiation', 'ovarian_cancer_continuation']),
  ),
  ConditionGroup('Parity', _leaves(['nulliparous', 'parous'])),
  ConditionGroup('Past ectopic pregnancy', _leaves(['past_ectopic_pregnancy'])),
  ConditionGroup(
    'Pelvic Inflammatory Disease (PID)',
    _leaves([
      'pid_past_no_subsequent_pregnancy',
      'pid_past_with_subsequent_pregnancy',
      'pid_current',
    ]),
  ),
  ConditionGroup(
    'Postpartum (not breastfeeding)',
    _leaves([
      'postpartum_non_breastfeeding',
      'postpartum_48h_4wk',
      'postpartum_4_6wk',
      'postpartum_6wk_plus',
      'postpartum_vte_risk',
      'postpartum_puerperal_sepsis',
    ]),
  ),
  ConditionGroup(
    'Post-abortion',
    _leaves([
      'post_abortion_first_trimester',
      'post_abortion_second_trimester',
      'post_abortion_septic',
    ]),
  ),
  ConditionGroup('Pregnancy', _leaves(['pregnancy'])),
  ConditionGroup(
    'Schistosomiasis',
    _leaves(['schistosomiasis_uncomplicated', 'schistosomiasis_fibrosis']),
  ),
  ConditionGroup('Severe dysmenorrhoea', _leaves(['severe_dysmenorrhoea'])),
  ConditionGroup(
    'Sexually transmitted infections',
    _leaves([
      'sti_current_purulent',
      'sti_other',
      'vaginitis',
      'increased_risk_stis',
    ]),
  ),
  ConditionGroup('Sickle cell disease', _leaves(['sickle_cell_disease'])),
  ConditionGroup(
    'Smoking',
    _leaves([
      'smoking_under_35',
      'smoking_35_plus',
      'smoking_35_plus_under15cig',
      'smoking_35_plus_15plus_cig',
    ]),
  ),
  ConditionGroup('Stroke', _leaves(['stroke_history'])),
  ConditionGroup(
    'Superficial venous thrombosis',
    _leaves(['superficial_venous_thrombosis']),
  ),
  ConditionGroup(
    'Systemic lupus erythematosus (SLE)',
    _leaves([
      'sle_antiphospholipid_positive',
      'sle_severe_thrombocytopenia',
      'sle_immunosuppressive_treatment',
      'sle_none_of_above',
    ]),
  ),
  ConditionGroup('Thalassaemia', _leaves(['thalassaemia'])),
  ConditionGroup(
    'Thyroid disorders',
    _leaves([
      'thyroid_simple_goitre',
      'thyroid_hyperthyroid',
      'thyroid_hypothyroid',
    ]),
  ),
  ConditionGroup(
    'Tuberculosis',
    _leaves(['tuberculosis_non_pelvic', 'tuberculosis_pelvic']),
  ),
  ConditionGroup(
    'Unexplained vaginal bleeding',
    _leaves(['unexplained_vaginal_bleeding']),
  ),
  ConditionGroup(
    'Uterine fibroids',
    _leaves([
      'uterine_fibroids_no_distortion',
      'uterine_fibroids_with_distortion',
    ]),
  ),
  ConditionGroup(
    'Vaginal bleeding pattern',
    _leaves(['vaginal_bleeding_irregular', 'vaginal_bleeding_heavy']),
  ),
  ConditionGroup(
    'Valvular heart disease',
    _leaves([
      'valvular_heart_disease_uncomplicated',
      'valvular_heart_disease_complicated',
    ]),
  ),
  ConditionGroup('Varicose veins', _leaves(['varicose_veins'])),
  ConditionGroup(
    'Viral hepatitis',
    _leaves(['viral_hepatitis_active', 'viral_hepatitis_carrier']),
  ),
];

const Map<String, String> _fallbackConditionLabels = {
  'malaria': 'Malaria',
  'obesity_adolescent_bmi30': 'Menarche to < 18 years and ≥ 30 kg/m² BMI',
  'ovarian_cancer_initiation': 'Ovarian cancer — initiation',
  'ovarian_cancer_continuation': 'Ovarian cancer — continuation',
  'nulliparous': 'Nulliparous',
  'parous': 'Parous',
  'past_ectopic_pregnancy': 'Past ectopic pregnancy',
  'pid_past_no_subsequent_pregnancy': 'Past PID, without subsequent pregnancy',
  'pid_past_with_subsequent_pregnancy': 'Past PID, with subsequent pregnancy',
  'pid_current': 'Current PID',
  'postpartum_48h_4wk': '48 hours to < 4 weeks postpartum, not breastfeeding',
  'postpartum_4_6wk': '4 to < 6 weeks postpartum, not breastfeeding',
  'postpartum_6wk_plus': '≥ 6 weeks postpartum, not breastfeeding',
  'postpartum_vte_risk': 'Postpartum, with risk factors for VTE',
  'postpartum_puerperal_sepsis': 'Postpartum, puerperal sepsis',
  'post_abortion_first_trimester': 'Post-abortion, first trimester',
  'post_abortion_second_trimester': 'Post-abortion, second trimester',
  'post_abortion_septic': 'Post-abortion, immediately post septic abortion',
  'pregnancy': 'Pregnancy',
  'schistosomiasis_uncomplicated': 'Schistosomiasis, uncomplicated',
  'schistosomiasis_fibrosis': 'Schistosomiasis, fibrosis of the liver',
  'vaginitis':
      'Vaginitis (excluding Trichomonas vaginalis and bacterial vaginosis)',
  'increased_risk_stis': 'Increased risk of STIs',
  'smoking_35_plus_under15cig': 'Age ≥ 35, < 15 cigarettes/day',
  'smoking_35_plus_15plus_cig': 'Age ≥ 35, ≥ 15 cigarettes/day',
  'sle_severe_thrombocytopenia': 'SLE with severe thrombocytopenia',
  'sle_immunosuppressive_treatment': 'SLE on immunosuppressive treatment',
  'sle_none_of_above': 'SLE, none of the above',
  'thalassaemia': 'Thalassaemia',
  'thyroid_simple_goitre': 'Simple goitre',
  'thyroid_hyperthyroid': 'Hyperthyroid',
  'thyroid_hypothyroid': 'Hypothyroid',
  'tuberculosis_non_pelvic': 'Tuberculosis, non-pelvic',
  'tuberculosis_pelvic': 'Tuberculosis, pelvic',
  'hypertension_elevated_140_159':
      'Elevated blood pressure: systolic 140–159 or diastolic 90–99 mmHg',
  'hypertension_elevated_160_plus':
      'Elevated blood pressure: systolic ≥ 160 or diastolic ≥ 100 mmHg',
  'hypertension_vascular_disease': 'Hypertension with vascular disease',
  'migraine_no_aura_under35': 'Migraine without aura, age < 35',
  'migraine_no_aura_35plus': 'Migraine without aura, age ≥ 35',
  'headache_non_migranous': 'Non-migranous headache',
  'history_cholestasis_past_oc_related':
      'History of cholestasis, past OC-related',
  'gall_bladder_symptomatic_cholecystectomy':
      'Symptomatic, treated by cholecystectomy',
  'gall_bladder_symptomatic_medical': 'Symptomatic, medically treated',
  'gall_bladder_symptomatic_current': 'Symptomatic, current',
  'gall_bladder_asymptomatic': 'Asymptomatic',
  'gtd_decreasing_hcg': 'Decreasing or undetectable β-hCG levels',
  'gtd_elevated_hcg_or_malignant':
      'Persistently elevated β-hCG levels or malignant disease',
  'diabetes_non_insulin_dependent': 'Non-insulin dependent',
  'diabetes_insulin_dependent': 'Insulin dependent',
  'endometrial_cancer_initiation': 'Endometrial cancer — initiation',
  'endometrial_cancer_continuation': 'Endometrial cancer — continuation',
  'cervical_cancer_initiation':
      'Cervical cancer (awaiting treatment) — initiation',
  'cervical_cancer_continuation':
      'Cervical cancer (awaiting treatment) — continuation',
  'art_nrti': 'Nucleoside reverse transcriptase inhibitors (NRTIs)',
  'art_nnrti': 'Non-nucleoside reverse transcriptase inhibitors (NNRTIs)',
  'art_pi': 'Protease inhibitors (PIs)',
  'art_integrase': 'Integrase inhibitors',
  'art_abacavir_init': 'Abacavir (ABC) / Initiation',
  'art_abacavir_cont': 'Abacavir (ABC) / Continuation',
  'art_tenofovir_init': 'Tenofovir (TDF) / Initiation',
  'art_tenofovir_cont': 'Tenofovir (TDF) / Continuation',
  'art_zidovudine_init': 'Zidovudine (AZT) / Initiation',
  'art_zidovudine_cont': 'Zidovudine (AZT) / Continuation',
  'art_lamivudine_init': 'Lamivudine (3TC) / Initiation',
  'art_lamivudine_cont': 'Lamivudine (3TC) / Continuation',
  'art_didanosine_init': 'Didanosine (DDI) / Initiation',
  'art_didanosine_cont': 'Didanosine (DDI) / Continuation',
  'art_emtricitabine_init': 'Emtricitabine (FTC) / Initiation',
  'art_emtricitabine_cont': 'Emtricitabine (FTC) / Continuation',
  'art_stavudine_init': 'Stavudine (D4T) / Initiation',
  'art_stavudine_cont': 'Stavudine (D4T) / Continuation',
  'art_efavirenz_init': 'Efavirenz (EFV) / Initiation',
  'art_efavirenz_cont': 'Efavirenz (EFV) / Continuation',
  'art_etravirine_init': 'Etravirine (ETR) / Initiation',
  'art_etravirine_cont': 'Etravirine (ETR) / Continuation',
  'art_nevirapine_init': 'Nevirapine (NVP) / Initiation',
  'art_nevirapine_cont': 'Nevirapine (NVP) / Continuation',
  'art_rilpivirine_init': 'Rilpivirine (RPV) / Initiation',
  'art_rilpivirine_cont': 'Rilpivirine (RPV) / Continuation',
  'art_atv_r_init': 'Ritonavir-boosted atazanavir (ATV/r) / Initiation',
  'art_atv_r_cont': 'Ritonavir-boosted atazanavir (ATV/r) / Continuation',
  'art_lpv_r_init': 'Ritonavir-boosted Lopinavir (LPV/r) / Initiation',
  'art_lpv_r_cont': 'Ritonavir-boosted Lopinavir (LPV/r) / Continuation',
  'art_drv_r_init': 'Ritonavir-boosted darunavir (DRV/r) / Initiation',
  'art_drv_r_cont': 'Ritonavir-boosted darunavir (DRV/r) / Continuation',
  'art_ritonavir_init': 'Ritonavir (RTV) / Initiation',
  'art_ritonavir_cont': 'Ritonavir (RTV) / Continuation',
  'art_raltegravir_init': 'Raltegravir (RAL) / Initiation',
  'art_raltegravir_cont': 'Raltegravir (RAL) / Continuation',
  'breast_cancer_category': 'Breast cancer',
  'breast_undiagnosed_mass': 'Undiagnosed mass',
  'breast_benign_disease': 'Benign breast disease',
  'breast_family_history_cancer': 'Family history of cancer',
  'current_breast_cancer': 'Current',
  'past_breast_cancer_5yrs':
      'Past and no evidence of current disease for 5 years',
};

// ============================================================
// Emergency contraception reference data.
// ============================================================
class EcConditionRow {
  final String label;
  final String value;
  const EcConditionRow(this.label, this.value);
}

class EcMethod {
  final String abbreviation;
  final String fullName;
  final List<EcConditionRow>? rows;
  const EcMethod({
    required this.abbreviation,
    required this.fullName,
    this.rows,
  });
}

const List<EcMethod> _ecMethods = [
  EcMethod(
    abbreviation: 'COC',
    fullName: 'Combined oral contraceptives',
    rows: [
      EcConditionRow('Pregnancy', 'NA'),
      EcConditionRow('Breastfeeding', '1'),
      EcConditionRow('Past ectopic pregnancy', '1'),
      EcConditionRow('Obesity* (BMI ≥30 kg/m2)', '1'),
      EcConditionRow(
        'History of severe cardiovascular disease (ischaemic heart disease, cerebrovascular attack, or other thromboembolic conditions)',
        '2',
      ),
      EcConditionRow('Migraine', '2'),
      EcConditionRow('Severe liver disease (including jaundice)', '2'),
      EcConditionRow(
        'CYP3A4 inducers (e.g. rifampicin, phenytoin, phenobarbital, carbamazepine, efavirenz, fosphenytoin, nevirapine, oxcarbazepine, primidone, rifabutin, St John\'s wort/ hypericum perforatum)',
        '1',
      ),
      EcConditionRow('Repeated emergency contraceptive pill use', '1'),
      EcConditionRow('Rape', '1'),
    ],
  ),
  EcMethod(abbreviation: 'LNG', fullName: 'Levonorgestrel'),
  EcMethod(abbreviation: 'UPA', fullName: 'Ulipristal acetate'),
  EcMethod(
    abbreviation: 'Cu-IUD',
    fullName: 'Copper intrauterine device',
    rows: [
      EcConditionRow(
        'This method is highly effective for preventing pregnancy. It can be used within 5 days of unprotected intercourse as an emergency contraceptive. However, when the time of ovulation can be estimated, the Cu-IUD can be inserted beyond 5 days after intercourse, if necessary, as long as the insertion does not occur more than 5 days after ovulation.\n\nThe eligibility criteria for general Cu-IUD insertion also apply for the insertion of Cu-IUDs as emergency contraception.',
        'NA',
      ),
      EcConditionRow('Pregnancy', '4'),
      EcConditionRow('Rape (high risk of STI)', '3'),
      EcConditionRow('Rape (low risk of STI)', '1'),
    ],
  ),
];

// ============================================================
// Antiretroviral drug classes/abbreviations for Additional info.
// ============================================================
class ArtDrug {
  final String abbr;
  final String name;
  const ArtDrug(this.abbr, this.name);
}

class ArtClass {
  final String title;
  final List<ArtDrug> drugs;
  const ArtClass(this.title, this.drugs);
}

const List<ArtClass> _artClasses = [
  ArtClass('Nucleoside reverse transcriptase inhibitors (NRTIs)', [
    ArtDrug('ABC', 'Abacavir'),
    ArtDrug('TDF', 'Tenofovir'),
    ArtDrug('AZT', 'Zidovudine'),
    ArtDrug('3TC', 'Lamivudine'),
    ArtDrug('DDI', 'Didanosine'),
    ArtDrug('FTC', 'Emtricitabine'),
    ArtDrug('D4T', 'Stavudine'),
  ]),
  ArtClass('Non-nucleoside reverse transcriptase inhibitors (NNRTIs)', [
    ArtDrug('EFV', 'Efavirenz'),
    ArtDrug('ETR', 'Etravirine'),
    ArtDrug('NVP', 'Nevirapine'),
    ArtDrug('RPV', 'Rilpivirine'),
  ]),
  ArtClass('Protease inhibitors (PIs)', [
    ArtDrug('ATV/r', 'Ritonavir-boosted atazanavir'),
    ArtDrug('LPV/r', 'Ritonavir-boosted lopinavir'),
    ArtDrug('DRV/r', 'Ritonavir-boosted darunavir'),
    ArtDrug('RTV', 'Ritonavir'),
  ]),
  ArtClass('Integrase Inhibitors', [ArtDrug('RAL', 'Raltegravir')]),
];

// ============================================================
// Effectiveness-of-methods reference data (Additional info tab).
// ============================================================
class EffMethod {
  final String name;
  final String percent;
  const EffMethod(this.name, this.percent);
}

class EffectivenessTier {
  final String title;
  final Color color;
  final List<EffMethod> methods;
  final String note;
  const EffectivenessTier({
    required this.title,
    required this.color,
    required this.methods,
    required this.note,
  });
}

const List<EffectivenessTier> _effectivenessTiers = [
  EffectivenessTier(
    title: 'Most effective',
    color: AppColors.ovulationTeal,
    methods: [
      EffMethod('Implants', '0.05%'),
      EffMethod('IUD', '0.8%'),
      EffMethod('Female sterilization', '0.5%'),
      EffMethod('Vasectomy', '0.15%'),
    ],
    note:
        'Implants, IUD, female sterilization: After procedure, little or nothing to do or remember. Vasectomy: Use another method for first 3 months.',
  ),
  EffectivenessTier(
    title: 'Very effective',
    color: AppColors.primary,
    methods: [
      EffMethod('Injectables', '6%'),
      EffMethod('LAM', '—'),
      EffMethod('Patch & vaginal ring', '9%'),
      EffMethod('Pills', '9%'),
    ],
    note:
        'Injectables: Get repeat injections on time. Lactational amenorrhea method, LAM (for 6 months): The baby is fully or near fully breastfed. To maintain effective protection against pregnancy, another method of contraception must be used as soon as menstruation resumes, the frequency or duration of breast-feeds is reduced, bottle feeds are introduced or the baby reaches 6 months of age. Pills: Take a pill each day. Patch, ring: Keep in place, change on time.',
  ),
  EffectivenessTier(
    title: 'Moderately effective',
    color: AppColors.moodYellow,
    methods: [
      EffMethod('Male condoms', '18%'),
      EffMethod('Diaphragm', '12%'),
      EffMethod('Female condoms', '21%'),
      EffMethod('Fertility awareness methods', '24%'),
    ],
    note:
        'Condoms, diaphragm: Use correctly every time you have sex. Fertility awareness methods: Abstain from sex or use condoms on fertile days. The Standard Days Method or TwoDay Method can also be used.',
  ),
  EffectivenessTier(
    title: 'Least effective',
    color: AppColors.periodRed,
    methods: [EffMethod('Withdrawal', '22%'), EffMethod('Spermicides', '28%')],
    note: 'Withdrawal, spermicides: Use correctly every time you have sex.',
  ),
];

class ProtectionScreen extends StatefulWidget {
  const ProtectionScreen({super.key});

  @override
  State<ProtectionScreen> createState() => _ProtectionScreenState();
}

class _ProtectionScreenState extends State<ProtectionScreen> {
  int _activeTab = 0;

  int _myPlanView = 0;

  int? _selectedMethodIndex;

  // ---- Diary logging state ----
  // Tracks whether a save-to-diary call is in flight, and which method
  // name was most recently saved, so the button on the method detail
  // screen can show a spinner / confirmed state correctly.
  bool _savingMethod = false;
  String? _savedMethodName;

  int _additionalInfoView = 0;
  final Set<String> _expandedEcMethods = {};
  final Set<String> _expandedArtClasses = {};
  final Set<int> _expandedEffTiers = {};

  final EligibilityApiService _api = EligibilityApiService();
  Future<List<Condition>>? _conditionsFuture;
  final Set<String> _selectedConditionIds = {};
  final Set<String> _expandedGroups = {};

  /// IDs the backend actually recognizes. Populated once fetchConditions()
  /// resolves. Anything NOT in this set is a frontend-only fallback label
  /// (see _fallbackConditionLabels) and must never be sent to the backend.
  Set<String> _apiConditionIds = {};

  /// The full fetched condition list (id + label), kept at class level
  /// so it can be used to translate the user's selected condition IDs
  /// into readable labels when saving an eligibility check to the
  /// diary -- without needing to rebuild the FutureBuilder's local
  /// lookup map from _conditionPicker().
  List<Condition> _fetchedConditions = [];

  List<MethodResult>? _eligibilityResults;
  bool _checkingEligibility = false;
  bool _savingEligibility = false;
  bool _eligibilitySaved = false;
  String? _eligibilityError;

  int _eligibilitySubTab = 0;

  double _agePreference = 2;
  static const List<String> _ageBrackets = [
    'Menarche to < 18 years',
    '18–24 years',
    '25–29 years',
    '30–34 years',
    '35–39 years',
    '40–45 years',
    '≥ 46 years',
  ];

  final Set<String> _expandedPreferences = {};
  final List<Map<String, dynamic>> _preferences = [
    {
      'id': 'highly_effective',
      'label': 'Highly effective',
      'icon': Icons.star_rounded,
      'color': AppColors.ovulationTeal,
      'description':
          'Methods with a very low chance of pregnancy, even with typical, imperfect use — the failure rate is under 1% a year.',
      'methods': [
        'Implants',
        'Levonorgestrel IUD',
        'Copper intrauterine device',
        'Female sterilization',
        'Male sterilization (vasectomy)',
      ],
    },
    {
      'id': 'sti_prevention',
      'label': 'STI prevention',
      'icon': Icons.shield_outlined,
      'color': AppColors.moodYellow,
      'description':
          'Only one method category also lowers the risk of sexually transmitted infections, not just pregnancy — every other method here protects against pregnancy alone.',
      'methods': ['Barrier methods (male condoms)'],
    },
    {
      'id': 'no_hormones',
      'label': 'No hormones',
      'icon': Icons.block,
      'color': AppColors.primary,
      'description':
          'Methods that don\'t use estrogen or progestin at all, for people who want to avoid hormonal side effects or have a medical reason to avoid them.',
      'methods': [
        'Copper intrauterine device',
        'Barrier methods',
        'Lactational amenorrhoea method',
        'Female sterilization',
        'Male sterilization (vasectomy)',
      ],
    },
    {
      'id': 'regular_bleeding',
      'label': 'Regular bleeding',
      'icon': Icons.water_drop_outlined,
      'color': AppColors.periodRed,
      'description':
          'If keeping a predictable, regular period matters to you, some methods are more likely to disrupt bleeding patterns than others — this can guide which to ask your provider about.',
      'methods': [
        'Combined hormonal contraceptives (tends to regulate cycles)',
        'Copper intrauterine device (keeps a natural cycle, though periods may be heavier)',
      ],
    },
    {
      'id': 'privacy',
      'label': 'Privacy',
      'icon': Icons.visibility_off_outlined,
      'color': AppColors.accent,
      'description':
          'Methods that are discreet once in place — nothing a partner would necessarily notice, no daily routine, and no packaging to keep hidden.',
      'methods': [
        'Implants',
        'Progestogen-only injectables',
        'Levonorgestrel IUD',
        'Copper intrauterine device',
      ],
    },
    {
      'id': 'client_controlled',
      'label': 'Client controlled',
      'icon': Icons.pan_tool_outlined,
      'color': const Color(0xFF8A9A5B),
      'description':
          'Methods you can start or stop yourself, without needing a provider visit for insertion or removal.',
      'methods': [
        'Combined hormonal contraceptives (pill, patch, ring)',
        'Progestogen-only pills',
        'Barrier methods',
      ],
    },
    {
      'id': 'long_lasting',
      'label': 'Long lasting',
      'icon': Icons.calendar_month_outlined,
      'color': const Color(0xFFB08968),
      'description':
          'Methods that protect for months or years at a time, with nothing to remember day-to-day.',
      'methods': [
        'Implants (up to 3 years)',
        'Levonorgestrel IUD (3–8 years)',
        'Copper intrauterine device (up to 10 years)',
        'Female sterilization (permanent)',
        'Male sterilization (permanent)',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _conditionsFuture = _api.fetchConditions();
    _conditionsFuture!
        .then((data) {
          if (!mounted) return;
          setState(() {
            _apiConditionIds = data.map((c) => c.id).toSet();
            _fetchedConditions = data;
          });
        })
        .catchError((_) {
          // Leave _apiConditionIds empty; the FutureBuilder below already
          // surfaces the fetch error to the user.
        });
  }

  Future<void> _checkEligibility() async {
    if (_selectedConditionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one condition first')),
      );
      return;
    }

    // Only send IDs the backend actually knows about. Some entries in
    // _conditionGroups only exist as frontend fallback labels
    // (_fallbackConditionLabels) and were never returned by fetchConditions(),
    // so sending them causes an "Unknown condition id(s)" error from the API.
    final validIds = _selectedConditionIds
        .where((id) => _apiConditionIds.contains(id))
        .toList();

    if (validIds.isEmpty) {
      setState(() {
        _eligibilityError =
            'The selected condition(s) aren\'t supported for eligibility checking yet. Please choose a different condition.';
      });
      return;
    }

    setState(() {
      _checkingEligibility = true;
      _eligibilityError = null;
    });
    try {
      final results = await _api.checkEligibility(validIds);
      if (!mounted) return;
      setState(() {
        _eligibilityResults = results;
        // A fresh check produced new results -- clear the "saved" state
        // from any previous check so the save button is live again.
        _eligibilitySaved = false;
      });
    } catch (e, st) {
      debugPrint('eligibility error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _eligibilityError =
            'Could not check eligibility right now. Please try again in a moment.\n\nDetails: $e';
      });
    } finally {
      if (mounted) setState(() => _checkingEligibility = false);
    }
  }

  /// Translates the currently selected condition IDs into human-readable
  /// labels (falling back to _fallbackConditionLabels for IDs the API
  /// didn't return directly), for saving a readable record to the diary.
  List<String> _selectedConditionLabels() {
    final byId = {for (final c in _fetchedConditions) c.id: c.label};
    for (final entry in _fallbackConditionLabels.entries) {
      byId.putIfAbsent(entry.key, () => entry.value);
    }
    return _selectedConditionIds.map((id) => byId[id] ?? id).toList();
  }

  /// Saves the most recent eligibility check -- the conditions selected
  /// and the resulting method-by-method category ratings -- into the
  /// Health Diary. Without this, running the Eligibility tool never left
  /// any trace once the user navigated away from this screen.
  Future<void> _logEligibilityCheckToDiary() async {
    if (_eligibilityResults == null || _eligibilityResults!.isEmpty) return;

    setState(() => _savingEligibility = true);
    try {
      await HealthProfileService().appendEligibilityCheck(
        conditions: _selectedConditionLabels(),
        // Only save methods that actually received a rating -- a
        // "not yet assessed" (null category) result has nothing
        // meaningful to record in the diary.
        results: _eligibilityResults!
            .where((r) => r.category != null)
            .map(
              (r) => EligibilityResultEntry(
                methodLabel: r.methodLabel,
                category: r.category!,
              ),
            )
            .toList(),
      );
      if (mounted) {
        setState(() {
          _savingEligibility = false;
          _eligibilitySaved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eligibility results saved to your diary'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _savingEligibility = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save — please try again')),
        );
      }
    }
  }

  /// Saves the chosen contraception method into the user's Health Diary
  /// (HealthProfile.reproductiveHistory) — both as the new "current
  /// method" and as a new dated entry in the contraception history list,
  /// so it shows up in the Health Diary's unified timeline alongside
  /// PCOS checks and AI check-ins.
  Future<void> _logMethodToDiary(String methodName) async {
    setState(() => _savingMethod = true);
    try {
      await HealthProfileService().updateProfile((p) {
        final updatedHistory =
            List<ContraceptionLogEntry>.from(
              p.reproductiveHistory.contraceptionHistory,
            )..add(
              ContraceptionLogEntry(
                date: DateTime.now(),
                method: methodName,
                note: 'Selected from Protection > Methods',
              ),
            );
        return p.copyWith(
          reproductiveHistory: p.reproductiveHistory.copyWith(
            currentContraceptionMethod: methodName,
            contraceptionHistory: updatedHistory,
          ),
        );
      });
      if (mounted) {
        setState(() {
          _savingMethod = false;
          _savedMethodName = methodName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$methodName saved to your diary')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _savingMethod = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save — please try again')),
        );
      }
    }
  }

  Color _categoryColor(int? category) {
    switch (category) {
      case 1:
        return AppColors.ovulationTeal;
      case 2:
        return AppColors.primary;
      case 3:
        return AppColors.moodYellow;
      case 4:
        return AppColors.periodRed;
      default:
        // null (or anything unrecognized) means "not yet assessed" --
        // the server sends this when the WHO MEC matrix has no rating
        // for this method + condition combination.
        return AppColors.textSecondary;
    }
  }

  String _categoryShortLabel(int? category) {
    switch (category) {
      case 1:
        return 'Safe to use';
      case 2:
        return 'Generally safe';
      case 3:
        return 'Use with caution';
      case 4:
        return 'Not recommended';
      default:
        return 'Not yet assessed';
    }
  }

  final List<Map<String, dynamic>> _methods = const [
    {
      'emoji': '💊',
      'badgeColor': AppColors.periodRed,
      'name': 'Combined hormonal contraceptives',
      'effectiveness': '91–99% effective',
      'detail':
          'Includes the combined pill, the patch, and the vaginal ring. All three release a combination of estrogen and progestin, which work together to stop ovulation, thicken cervical mucus, and thin the uterine lining, so there\'s no egg released and it\'s harder for sperm to reach one anyway. Each form needs a different routine: the pill is taken daily at roughly the same time, the patch is changed weekly, and the ring is replaced monthly. With perfect use effectiveness reaches 99%, but typical use (missed pills, late patch changes) brings real-world effectiveness down to around 91%. None of these protect against STIs, so a barrier method is still worth using alongside them if that\'s a concern. Many people also use combined methods to regulate irregular cycles, reduce heavy or painful periods, and manage hormonal acne. They\'re usually not recommended for smokers over 35, or for anyone with a history of blood clots, certain migraines, or uncontrolled high blood pressure — worth flagging in the Eligibility tool if any of those apply.',
      'tags': [
        {'label': 'Highly effective', 'color': AppColors.ovulationTeal},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
        {'label': 'Routine required', 'color': AppColors.moodYellow},
      ],
    },
    {
      'emoji': '💊',
      'badgeColor': AppColors.moodYellow,
      'name': 'Progestogen-only pills',
      'effectiveness': '91–99% effective',
      'detail':
          'Often called the "mini-pill," this contains only progestin — no estrogen — and works mainly by thickening cervical mucus and, depending on the formulation, sometimes suppressing ovulation too. Because there\'s no estrogen, it\'s a good option for people who can\'t safely use combined methods: while breastfeeding, or with a history of blood clots, migraines with aura, or certain other estrogen-sensitive conditions. The trade-off is a stricter routine — traditional progestogen-only pills need to be taken within the same 3-hour window every day, or their effectiveness drops noticeably (some newer formulations allow a wider 12-hour window, so it\'s worth checking which type is prescribed). Bleeding patterns can become irregular, lighter, or occasionally stop altogether. Like all hormonal methods, it offers no protection against STIs.',
      'tags': [
        {'label': 'Estrogen-free', 'color': AppColors.ovulationTeal},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
        {'label': 'Daily routine', 'color': AppColors.moodYellow},
      ],
    },
    {
      'emoji': '💉',
      'badgeColor': AppColors.primary,
      'name': 'Progestogen-only injectables',
      'effectiveness': '94–99% effective',
      'detail':
          'A shot of progestin given by a healthcare provider every 2–3 months (the exact interval depends on the formulation), which suppresses ovulation for the full duration between doses. The main appeal is that there\'s nothing to remember day-to-day — just a reminder to book the next appointment on time. With perfect timing effectiveness is over 99%, but typical use (returning late for a repeat shot) brings it down to around 94%. Periods often become lighter, more irregular, or stop entirely with continued use, which some people prefer and others find inconvenient. One thing worth planning around: fertility doesn\'t bounce back immediately after stopping — it can take several months, occasionally up to a year, for regular ovulation to return, so it\'s not the best choice if pregnancy is being planned in the near future. No STI protection.',
      'tags': [
        {'label': 'Every 2–3 months', 'color': AppColors.ovulationTeal},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
        {'label': 'Delayed fertility return', 'color': AppColors.moodYellow},
      ],
    },
    {
      'emoji': '📍',
      'badgeColor': AppColors.periodRed,
      'name': 'Implants',
      'effectiveness': '>99% effective',
      'detail':
          'A small, flexible rod — about the size of a matchstick — inserted just under the skin of the upper arm by a trained provider, using a local anesthetic. It steadily releases progestin for up to 3 years (some brands are approved for longer), making it one of the most effective reversible methods that exists, with a failure rate under 0.1%. Because there\'s no daily or monthly routine to keep up with, it removes the most common cause of "typical use" failure entirely. Insertion and removal both take just a few minutes, though removal does need a provider — it\'s not something to attempt at home. The most common side effect is a change in bleeding pattern: some people get lighter periods or none at all, others get more irregular spotting, especially in the first few months. Fertility returns quickly, often within days of removal. Doesn\'t protect against STIs.',
      'tags': [
        {'label': 'Set and forget', 'color': AppColors.ovulationTeal},
        {'label': '3 years', 'color': AppColors.primary},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '⚓',
      'badgeColor': AppColors.textSecondary,
      'name': 'Levonorgestrel IUD',
      'effectiveness': '>99% effective',
      'detail':
          'A small, T-shaped device placed inside the uterus by a healthcare provider, releasing a low, steady dose of progestin directly where it\'s needed rather than through the whole body. Depending on the brand, it\'s approved to work for anywhere from 3 to 8 years, though it can be removed earlier at any time if plans change — fertility returns quickly after removal. Because so little can go wrong once it\'s in place, it\'s consistently one of the most effective methods available, with a failure rate similar to sterilization. A common and often welcome side effect is much lighter periods over time, and for some people, periods stop altogether. The insertion process itself can cause cramping for a day or two, and irregular spotting is common for the first few months while the body adjusts. It does not protect against STIs, so a barrier method is still worth using for that.',
      'tags': [
        {'label': 'Long-term', 'color': AppColors.ovulationTeal},
        {'label': 'Most effective', 'color': AppColors.ovulationTeal},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '🔵',
      'badgeColor': AppColors.textSecondary,
      'name': 'Copper intrauterine device',
      'effectiveness': '>99% effective',
      'detail':
          'Also T-shaped and placed inside the uterus, but hormone-free — it works by releasing copper ions that create an environment that\'s toxic to sperm, preventing fertilization. Because there are no hormones involved, it\'s a common choice for people who want to avoid hormonal side effects or who have health conditions that rule out hormonal methods. It\'s approved for up to 10 years of use, making it the longest-lasting reversible method available, and it\'s also the single most effective form of emergency contraception if inserted within 5 days of unprotected sex — more effective than any emergency pill. The main trade-off is that periods often become heavier and crampier, particularly in the first several months after insertion, which is the most common reason people choose to have it removed early. Fertility returns immediately once it\'s taken out. Like the hormonal IUD, it offers no STI protection.',
      'tags': [
        {'label': 'Hormone-free', 'color': AppColors.ovulationTeal},
        {'label': 'Up to 10 years', 'color': AppColors.primary},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '🛡️',
      'badgeColor': AppColors.ovulationTeal,
      'name': 'Barrier methods',
      'effectiveness': '82–98% effective',
      'detail':
          'This category covers male condoms, female (internal) condoms, diaphragms, and cervical caps — physical barriers that block sperm from reaching an egg, used only at the time of sex rather than on an ongoing basis. Male condoms are the standout here because they\'re the only method on this list that also reduces the risk of sexually transmitted infections, not just pregnancy. Effectiveness varies more than any other method depending on how consistently and correctly it\'s used: condoms reach about 98% with perfect use but drop to roughly 82–87% with typical use, mostly due to breakage, slipping, or not using one every single time. A few practical basics make a real difference — use a new condom for every act of sex, check the expiry date, leave a little space at the tip to collect fluid, and use only water- or silicone-based lubricant with latex condoms (oil-based lubricants can weaken and break latex). Diaphragms and cervical caps need to be fitted by a provider and used with spermicide for best effectiveness.',
      'tags': [
        {'label': 'STI protection (condoms)', 'color': AppColors.ovulationTeal},
        {'label': 'No hormones', 'color': AppColors.ovulationTeal},
        {'label': 'User-dependent', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '🤱',
      'badgeColor': AppColors.moodYellow,
      'name': 'Lactational amenorrhoea method',
      'effectiveness': '98% effective (first 6 months)',
      'detail':
          'A temporary, natural method that relies on the way exclusive, frequent breastfeeding can suppress ovulation. To reach its full 98% effectiveness, three conditions all need to be true at once: the baby is under 6 months old, the baby is being fed only breast milk with no long gaps — day or night — between feeds (generally no more than about 4 hours in the day or 6 hours overnight), and menstrual periods haven\'t returned yet. If any one of those three changes — periods come back, feeds start spacing out, or the baby turns 6 months and starts other foods — protection drops off quickly and unpredictably, so it\'s worth having a backup method ready well before any of those milestones hit. It has no cost, requires no supplies, and has zero effect on the baby\'s health. It does not protect against STIs and, being temporary by nature, isn\'t meant as a long-term plan on its own.',
      'tags': [
        {'label': 'No cost', 'color': AppColors.ovulationTeal},
        {'label': 'Time-limited', 'color': AppColors.moodYellow},
        {'label': 'Conditions apply', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '✂️',
      'badgeColor': AppColors.primary,
      'name': 'Female sterilization',
      'effectiveness': '>99% effective',
      'detail':
          'A permanent surgical procedure — most often tubal ligation, sometimes salpingectomy (full removal of the tubes) — that closes off or removes the fallopian tubes so eggs can no longer reach the uterus. It\'s a single procedure, typically done under general or local anesthesia with a short recovery, and after that there\'s nothing to remember, refill, or replace for the rest of a person\'s reproductive life. Because of that, it\'s consistently among the most effective methods that exist. The decision it asks for is different from every other method on this list, though: it should be considered permanent and not easily reversible, so it\'s generally recommended only for people who are certain they don\'t want any future pregnancies, regardless of changes in circumstances like a new partner or relationship. It doesn\'t affect hormone levels, libido, or menstrual cycles, and it offers no protection against STIs.',
      'tags': [
        {'label': 'Permanent', 'color': AppColors.periodRed},
        {'label': 'One-time procedure', 'color': AppColors.ovulationTeal},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '🔧',
      'badgeColor': AppColors.textSecondary,
      'name': 'Male sterilization (vasectomy)',
      'effectiveness': '>99% effective',
      'detail':
          'A permanent procedure for the male partner that cuts or seals the vas deferens — the tubes that carry sperm — so sperm can no longer mix into semen. It\'s simpler and lower-risk than female sterilization: usually done under local anesthesia in a clinic in about 15–30 minutes, with most people back to normal activities within a few days. It\'s not immediately effective, though — sperm already in the system can stick around for a few months, so another method needs to be used for roughly the first 3 months, until a follow-up semen test confirms there\'s no sperm left. Like female sterilization, it should be considered permanent; while reversal surgery exists, it\'s not always successful and isn\'t something to count on. It has no effect on hormone levels, sex drive, or the ability to ejaculate — semen looks and behaves the same, it just no longer contains sperm. It offers no protection against STIs.',
      'tags': [
        {'label': 'Permanent', 'color': AppColors.periodRed},
        {'label': 'Simple procedure', 'color': AppColors.ovulationTeal},
        {'label': 'Delayed effectiveness', 'color': AppColors.moodYellow},
      ],
    },
  ];

  /// MODULE NOTE: Methods shown on the top-level "Contraception" tab
  /// (see _buildContraceptionTab below). Deliberately a SEPARATE, shorter
  /// list from `_methods` above -- `_methods` still powers "My Plan →
  /// Methods" (the full 10-method browsable list) unchanged. This list
  /// exists so the first thing a person sees is a quick, common-methods
  /// overview (Condom, Combined Pill, IUCD, Implant, Emergency
  /// Contraception) without duplicating or altering the full list used
  /// elsewhere in the screen.
  final List<Map<String, dynamic>> _contraceptionTabMethods = const [
    {
      'emoji': '🛡️',
      'badgeColor': AppColors.ovulationTeal,
      'name': 'Condom',
      'effectiveness': '85–98% effective',
      'detail':
          'A physical barrier — male (external) or female (internal) — that blocks sperm from reaching an egg, used only at the time of sex. Condoms are the only method here that also reduces the risk of sexually transmitted infections, not just pregnancy. Effectiveness varies a lot with how consistently and correctly it\'s used: about 98% with perfect use, dropping to roughly 85% with typical use, mostly due to breakage, slipping, or not using one every single time. Use a new condom for every act of sex, check the expiry date, and use only water- or silicone-based lubricant with latex condoms (oil-based lubricants can weaken and break latex).',
      'tags': [
        {'label': 'STI protection', 'color': AppColors.ovulationTeal},
        {'label': 'No hormones', 'color': AppColors.ovulationTeal},
        {'label': 'User-dependent', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '💊',
      'badgeColor': AppColors.periodRed,
      'name': 'Combined Pill (OCP)',
      'effectiveness': '91–99% effective',
      'detail':
          'The combined oral contraceptive pill releases estrogen and progestin together, which work to stop ovulation, thicken cervical mucus, and thin the uterine lining. Taken daily at roughly the same time. With perfect use effectiveness reaches 99%, but typical use (missed pills) brings real-world effectiveness down to around 91%. Offers no STI protection, so a barrier method is still worth using alongside it if that\'s a concern. Many people also use it to regulate irregular cycles, reduce heavy or painful periods, and manage hormonal acne. Usually not recommended for smokers over 35, or for anyone with a history of blood clots, certain migraines, or uncontrolled high blood pressure — worth flagging in the Eligibility tool if any of those apply.',
      'tags': [
        {'label': 'Highly effective', 'color': AppColors.ovulationTeal},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
        {'label': 'Daily routine', 'color': AppColors.moodYellow},
      ],
    },
    {
      'emoji': '🔵',
      'badgeColor': AppColors.textSecondary,
      'name': 'IUCD',
      'effectiveness': '>99% effective',
      'detail':
          'A small, T-shaped device placed inside the uterus by a healthcare provider. Hormonal versions (levonorgestrel IUD) release a low, steady dose of progestin and last 3–8 years depending on the brand; the copper IUD is hormone-free and lasts up to 10 years, working by releasing copper ions that are toxic to sperm. Because so little can go wrong once it\'s in place, IUCDs are consistently among the most effective methods available. The hormonal version often makes periods much lighter over time; the copper version can make periods heavier and crampier, especially in the first few months. Insertion can cause cramping for a day or two. Fertility returns quickly after removal for either type. No STI protection.',
      'tags': [
        {'label': 'Long-term', 'color': AppColors.ovulationTeal},
        {'label': 'Most effective', 'color': AppColors.ovulationTeal},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '📍',
      'badgeColor': AppColors.periodRed,
      'name': 'Implant',
      'effectiveness': '>99% effective',
      'detail':
          'A small, flexible rod — about the size of a matchstick — inserted just under the skin of the upper arm by a trained provider, using a local anesthetic. It steadily releases progestin for up to 3 years (some brands are approved for longer), making it one of the most effective reversible methods that exists, with a failure rate under 0.1%. There\'s no daily or monthly routine to keep up with. Insertion and removal both take just a few minutes, though removal needs a provider. The most common side effect is a change in bleeding pattern — lighter periods or none at all for some, more irregular spotting for others, especially in the first few months. Fertility returns quickly, often within days of removal. No STI protection.',
      'tags': [
        {'label': 'Set and forget', 'color': AppColors.ovulationTeal},
        {'label': '3 years', 'color': AppColors.primary},
        {'label': 'No STI protection', 'color': AppColors.periodRed},
      ],
    },
    {
      'emoji': '⏱️',
      'badgeColor': AppColors.moodYellow,
      'name': 'Emergency Contraception',
      'effectiveness': '75–99% effective',
      'detail':
          'Used after unprotected sex or contraceptive failure (e.g. a missed pill or broken condom) to reduce the chance of pregnancy — not meant as a regular, ongoing method. Options include emergency contraceptive pills (levonorgestrel or ulipristal acetate, most effective the sooner they\'re taken, generally within 3–5 days depending on the type) and the copper IUD, which is the single most effective form of emergency contraception if inserted within 5 days of unprotected sex — more effective than any emergency pill, and it then continues working as an ongoing method for years if left in place. Emergency contraception does not protect against STIs and does not end an existing pregnancy. If it\'s needed repeatedly, that\'s worth a conversation with a provider about switching to an ongoing method instead.',
      'tags': [
        {'label': 'After the fact', 'color': AppColors.moodYellow},
        {'label': 'Time-sensitive', 'color': AppColors.periodRed},
        {'label': 'Not a regular method', 'color': AppColors.periodRed},
      ],
    },
  ];

  String _formattedDate() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
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
              ..._buildContraceptionTab()
            else
              _buildMyPlanTab(),
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
        Expanded(
          child: _tabButton('🛡️', 'Contraception', 0, AppColors.ovulationTeal),
        ),
        const SizedBox(width: 10),
        Expanded(child: _tabButton('💊', 'My Plan', 1, AppColors.periodRed)),
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
          color: isActive ? activeColor.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? activeColor.withOpacity(0.6)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emojiText(emoji, size: 14),
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

  List<Widget> _buildContraceptionTab() {
    return [
      _heroCard(),
      const SizedBox(height: 24),
      Text(
        'CONTRACEPTION METHODS',
        style: AppTextStyles.sans(
          size: 11,
          weight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 12),
      ..._contraceptionTabMethods.map(
        (m) => MethodCard(
          emoji: m['emoji'] as String,
          badgeColor: m['badgeColor'] as Color,
          title: m['name'] as String,
          subtitle: m['effectiveness'] as String,
          detail: m['detail'] as String,
          tags: m['tags'] as List<Map<String, dynamic>>,
          // The save-to-diary button now lives directly on every method
          // card here on the main Contraception tab (not just buried in
          // My Plan > Methods), since this is the entry point most
          // people actually browse from.
          isSaving: _savingMethod,
          isSaved: _savedMethodName == m['name'],
          onSave: () => _logMethodToDiary(m['name'] as String),
        ),
      ),
    ];
  }

  Widget _buildMyPlanTab() {
    switch (_myPlanView) {
      case 1:
        return _buildSubView(
          title: 'Eligibility tool',
          child: _buildEligibilityTool(),
        );
      case 2:
        return _buildSubView(
          title: _selectedMethodIndex == null
              ? 'Methods'
              : _methods[_selectedMethodIndex!]['name'] as String,
          onBack: _selectedMethodIndex == null
              ? null
              : () => setState(() => _selectedMethodIndex = null),
          child: _selectedMethodIndex == null
              ? _buildMethodsList()
              : _buildMethodDetail(_methods[_selectedMethodIndex!]),
        );
      case 3:
        return _buildSubView(
          title: _additionalInfoTitle(),
          onBack: _additionalInfoView == 0
              ? null
              : () => setState(() => _additionalInfoView = 0),
          child: _buildAdditionalInfoContent(),
        );
      case 4:
        return _buildSubView(
          title: 'How to use the tool',
          child: _buildHowToUse(),
        );
      default:
        return _buildMyPlanMenu();
    }
  }

  Widget _buildMyPlanMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medical eligibility criteria\nfor contraceptive use',
          style: AppTextStyles.serif(size: 19).copyWith(height: 1.3),
        ),
        const SizedBox(height: 6),
        Text(
          'Based on established medical guidance, adapted to help you understand what\'s safe for you.',
          style: AppTextStyles.sans(
            size: 12,
            color: AppColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 22),
        _menuCard(
          icon: Icons.track_changes_outlined,
          title: 'Eligibility tool',
          subtitle: 'Check conditions against medical guidance',
          onTap: () => setState(() => _myPlanView = 1),
        ),
        const SizedBox(height: 10),
        _menuCard(
          icon: Icons.assignment_outlined,
          title: 'Methods',
          subtitle: 'Browse all contraception methods',
          onTap: () => setState(() {
            _myPlanView = 2;
            _selectedMethodIndex = null;
          }),
        ),
        const SizedBox(height: 10),
        _menuCard(
          icon: Icons.info_outline,
          title: 'Additional info',
          subtitle: 'Understand what your results mean',
          onTap: () => setState(() {
            _myPlanView = 3;
            _additionalInfoView = 0;
          }),
        ),
        const SizedBox(height: 10),
        _menuCard(
          icon: Icons.settings_outlined,
          title: 'How to use the tool',
          subtitle: 'A quick guide to the eligibility checker',
          onTap: () => setState(() => _myPlanView = 4),
        ),
      ],
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.periodRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.periodRed, size: 22),
            ),
            const SizedBox(width: 14),
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
                    subtitle,
                    style: AppTextStyles.sans(
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubView({
    required String title,
    required Widget child,
    VoidCallback? onBack,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onBack ?? () => setState(() => _myPlanView = 0),
          child: Row(
            children: [
              Icon(Icons.arrow_back, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Back',
                style: AppTextStyles.sans(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(title, style: AppTextStyles.serif(size: 19)),
        const SizedBox(height: 18),
        child,
      ],
    );
  }

  Widget _buildEligibilityTool() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select any conditions that apply to you, and we\'ll match them against established medical eligibility guidance.',
          style: AppTextStyles.sans(
            size: 12,
            color: AppColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
        const SizedBox(height: 20),
        _eligibilitySubTabs(),
        const SizedBox(height: 18),
        if (_eligibilitySubTab == 0) ...[
          _agePreferenceCard(),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONDITIONS THAT APPLY TO YOU',
                style: AppTextStyles.sans(
                  size: 11,
                  weight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_selectedConditionIds.isNotEmpty)
                Text(
                  '${_selectedConditionIds.length} selected',
                  style: AppTextStyles.sans(
                    size: 11,
                    weight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _conditionPicker(),
        ] else ...[
          Text(
            'WHAT MATTERS TO YOU',
            style: AppTextStyles.sans(
              size: 11,
              weight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          _preferencesPicker(),
        ],
        if (_eligibilitySubTab == 0) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _checkingEligibility ? null : _checkEligibility,
              child: _checkingEligibility
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Check my eligibility',
                      style: AppTextStyles.sans(
                        size: 14,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          if (_eligibilityError != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.periodRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.periodRed.withOpacity(0.3)),
              ),
              child: Text(
                _eligibilityError!,
                style: AppTextStyles.sans(size: 12, color: AppColors.periodRed),
              ),
            ),
          ],
          if (_eligibilityResults != null) ...[
            const SizedBox(height: 28),
            Text(
              'YOUR RESULTS',
              style: AppTextStyles.sans(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ..._eligibilityResults!.map(_resultCard),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _savingEligibility
                    ? null
                    : _logEligibilityCheckToDiary,
                icon: _savingEligibility
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        _eligibilitySaved
                            ? Icons.check_circle
                            : Icons.bookmark_add_outlined,
                        size: 18,
                      ),
                label: Text(
                  _eligibilitySaved
                      ? 'Saved to My Diary'
                      : 'Save these results to my diary',
                  style: AppTextStyles.sans(size: 13, weight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _eligibilitySaved
                      ? AppColors.ovulationTeal
                      : AppColors.primary,
                  side: BorderSide(
                    color:
                        (_eligibilitySaved
                                ? AppColors.ovulationTeal
                                : AppColors.primary)
                            .withOpacity(0.6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _eligibilitySubTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(child: _subTabButton('Conditions', 0)),
          Expanded(child: _subTabButton('Preferences', 1)),
        ],
      ),
    );
  }

  Widget _subTabButton(String label, int index) {
    final active = _eligibilitySubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _eligibilitySubTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.sans(
            size: 13,
            weight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _agePreferenceCard() {
    final index = _agePreference.round().clamp(0, _ageBrackets.length - 1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Age',
                style: AppTextStyles.sans(size: 14, weight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _ageBrackets[index],
                  style: AppTextStyles.sans(
                    size: 11,
                    weight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.cardBorder,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
            ),
            child: Slider(
              value: _agePreference,
              onChanged: (v) => setState(() => _agePreference = v),
              min: 0,
              max: (_ageBrackets.length - 1).toDouble(),
              divisions: _ageBrackets.length - 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menarche to < 18 years',
                style: AppTextStyles.sans(
                  size: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '(≥ 46)',
                style: AppTextStyles.sans(
                  size: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _preferencesPicker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _preferences.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.cardBorder),
            _preferenceTile(_preferences[i]),
          ],
        ],
      ),
    );
  }

  Widget _preferenceTile(Map<String, dynamic> p) {
    final id = p['id'] as String;
    final expanded = _expandedPreferences.contains(id);
    final color = p['color'] as Color;
    final methods = p['methods'] as List<String>;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (expanded) {
                _expandedPreferences.remove(id);
              } else {
                _expandedPreferences.add(id);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    p['icon'] as IconData,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    p['label'] as String,
                    style: AppTextStyles.sans(
                      size: 14,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cardBorder, width: 1.5),
                  ),
                  child: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['description'] as String,
                  style: AppTextStyles.sans(
                    size: 12.5,
                    color: AppColors.textSecondary,
                  ).copyWith(height: 1.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'METHODS THAT FIT',
                  style: AppTextStyles.sans(
                    size: 10,
                    weight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: methods.map((m) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.35)),
                      ),
                      child: Text(
                        m,
                        style: AppTextStyles.sans(
                          size: 11,
                          weight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _conditionPicker() {
    return FutureBuilder<List<Condition>>(
      future: _conditionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Could not load conditions: ${snapshot.error}',
            style: AppTextStyles.sans(size: 12, color: AppColors.periodRed),
          );
        }

        final conditions = snapshot.data!;
        if (conditions.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              'No conditions available right now. Please try again later.',
              textAlign: TextAlign.center,
              style: AppTextStyles.sans(
                size: 12,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final byId = {for (final c in conditions) c.id: c};

        for (final group in _conditionGroups) {
          for (final id in group.allIds) {
            if (!byId.containsKey(id) &&
                _fallbackConditionLabels.containsKey(id)) {
              byId[id] = Condition(
                id: id,
                label: _fallbackConditionLabels[id]!,
              );
            }
          }
        }

        final groups =
            _conditionGroups
                .where((g) => g.allIds.any((id) => byId.containsKey(id)))
                .toList()
              ..sort((a, b) => a.title.compareTo(b.title));

        final coveredIds = _conditionGroups.expand((g) => g.allIds).toSet();
        final ungrouped =
            conditions.where((c) => !coveredIds.contains(c.id)).toList()
              ..sort((a, b) => a.label.compareTo(b.label));

        final rows = <Widget>[
          for (final group in groups) _groupTile(group, byId),
          for (final c in ungrouped) _singleConditionTile(c),
        ];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, color: AppColors.cardBorder),
                rows[i],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _groupTile(ConditionGroup group, Map<String, Condition> byId) {
    final presentIds = group.allIds
        .where((id) => byId.containsKey(id))
        .toList();
    if (presentIds.length == 1) {
      return _singleConditionTile(byId[presentIds.first]!);
    }

    final expanded = _expandedGroups.contains(group.title);
    final hasSelection = presentIds.any(_selectedConditionIds.contains);

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (expanded) {
                _expandedGroups.remove(group.title);
              } else {
                _expandedGroups.add(group.title);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.title,
                    style: AppTextStyles.sans(
                      size: 13,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                if (hasSelection)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildNodeRows(group.nodes, byId, presentIds, depth: 0),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildNodeRows(
    List<ConditionNode> nodes,
    Map<String, Condition> byId,
    List<String> allPresentIds, {
    required int depth,
  }) {
    final rows = <Widget>[];
    for (final node in nodes) {
      if (!byId.containsKey(node.id)) continue;
      final c = byId[node.id]!;
      final selected = _selectedConditionIds.contains(node.id);

      // A condition is only checkable once fetchConditions() has confirmed
      // the backend recognizes it. Until then (or if it's a fallback-only
      // label), keep it visible for context but not selectable — this is
      // what stops "Unknown condition id(s)" errors at the source.
      final isSupported = _apiConditionIds.contains(node.id);

      rows.add(
        InkWell(
          onTap: !isSupported
              ? null
              : () {
                  setState(() {
                    if (selected) {
                      _selectedConditionIds.remove(node.id);
                    } else {
                      for (final otherId in allPresentIds) {
                        _selectedConditionIds.remove(otherId);
                      }
                      _selectedConditionIds.add(node.id);
                    }
                  });
                },
          child: Opacity(
            opacity: isSupported ? 1.0 : 0.4,
            child: Padding(
              padding: EdgeInsets.only(left: depth * 20, top: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (depth > 0) ...[
                    Container(
                      width: 1,
                      height: 18,
                      margin: const EdgeInsets.only(right: 10, top: 2),
                      color: AppColors.cardBorder,
                    ),
                  ],
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            c.label,
                            style: AppTextStyles.sans(
                              size: depth > 0 ? 12 : 12.5,
                              weight: node.children.isNotEmpty
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: AppColors.textPrimary,
                            ).copyWith(height: 1.35),
                          ),
                        ),
                        if (!isSupported) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Coming soon',
                              style: AppTextStyles.sans(
                                size: 9,
                                weight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (node.children.isNotEmpty) {
        rows.addAll(
          _buildNodeRows(node.children, byId, allPresentIds, depth: depth + 1),
        );
      }
    }
    return rows;
  }

  Widget _singleConditionTile(Condition c) {
    final selected = _selectedConditionIds.contains(c.id);
    final isSupported = _apiConditionIds.contains(c.id);
    return CheckboxListTile(
      value: selected,
      activeColor: AppColors.primary,
      controlAffinity: ListTileControlAffinity.leading,
      title: Opacity(
        opacity: isSupported ? 1.0 : 0.4,
        child: Row(
          children: [
            Flexible(child: Text(c.label, style: AppTextStyles.sans(size: 13))),
            if (!isSupported) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Coming soon',
                  style: AppTextStyles.sans(
                    size: 9,
                    weight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      onChanged: !isSupported
          ? null
          : (checked) {
              setState(() {
                if (checked == true) {
                  _selectedConditionIds.add(c.id);
                } else {
                  _selectedConditionIds.remove(c.id);
                }
              });
            },
    );
  }

  Widget _resultCard(MethodResult r) {
    final color = _categoryColor(r.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    r.category?.toString() ?? '–',
                    style: AppTextStyles.sans(
                      size: 16,
                      weight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.methodLabel,
                      style: AppTextStyles.sans(
                        size: 14,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _categoryShortLabel(r.category),
                      style: AppTextStyles.sans(size: 11, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // The server sends a note explaining why a method has no
          // rating yet (category == null) -- surface it so it doesn't
          // look like a silent failure.
          if (r.category == null && r.note != null) ...[
            const SizedBox(height: 10),
            Text(
              r.note!,
              style: AppTextStyles.sans(
                size: 11.5,
                color: AppColors.textSecondary,
              ).copyWith(height: 1.4, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: _methods.asMap().entries.map((entry) {
          final index = entry.key;
          final m = entry.value;
          return Column(
            children: [
              if (index > 0) Divider(height: 1, color: AppColors.cardBorder),
              _methodListTile(
                emoji: m['emoji'] as String,
                badgeColor: m['badgeColor'] as Color,
                title: m['name'] as String,
                subtitle: m['effectiveness'] as String,
                onTap: () => setState(() => _selectedMethodIndex = index),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _methodListTile({
    required String emoji,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 1.5),
              ),
              child: Center(child: emojiText(emoji, size: 17)),
            ),
            const SizedBox(width: 14),
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
                    subtitle,
                    style: AppTextStyles.sans(size: 11, color: badgeColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodDetail(Map<String, dynamic> m) {
    final badgeColor = m['badgeColor'] as Color;
    final tags = m['tags'] as List<Map<String, dynamic>>;
    final methodName = m['name'] as String;
    final isSavedMethod = _savedMethodName == methodName;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeColor, width: 1.5),
                ),
                child: Center(child: emojiText(m['emoji'] as String, size: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  m['effectiveness'] as String,
                  style: AppTextStyles.sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            m['detail'] as String,
            style: AppTextStyles.sans(
              size: 13,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.6),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) {
              final color = t['color'] as Color;
              final label = t['label'] as String;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.sans(
                    size: 10,
                    weight: FontWeight.w600,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          // "Save to My Diary" — logs this method as the user's current
          // contraception choice and appends a dated entry to their
          // Health Diary timeline (see HealthProfileService).
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _savingMethod
                  ? null
                  : () => _logMethodToDiary(methodName),
              icon: _savingMethod
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isSavedMethod
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      size: 18,
                    ),
              label: Text(
                isSavedMethod ? 'Saved to My Diary' : 'I\'m using this method',
                style: AppTextStyles.sans(
                  size: 13,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSavedMethod
                    ? AppColors.ovulationTeal
                    : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _additionalInfoTitle() {
    switch (_additionalInfoView) {
      case 1:
        return 'Emergency contraception';
      case 2:
        return 'Effectiveness of methods';
      case 3:
        return 'Antiretroviral medications and abbreviations';
      default:
        return 'Additional info';
    }
  }

  Widget _buildAdditionalInfoContent() {
    switch (_additionalInfoView) {
      case 1:
        return _buildEmergencyContraception();
      case 2:
        return Column(
          children: [
            _categoryLegendCard(),
            const SizedBox(height: 16),
            _buildEffectivenessComparison(),
          ],
        );
      case 3:
        return _buildArtGlossary();
      default:
        return _additionalInfoMenu();
    }
  }

  Widget _additionalInfoMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _additionalInfoMenuCard(
          title: 'Emergency contraception',
          description:
              'Safety ratings for emergency contraceptive pills and the copper IUD, organized by medical condition.',
          onTap: () => setState(() => _additionalInfoView = 1),
        ),
        _additionalInfoMenuCard(
          title: 'Effectiveness of methods',
          description:
              'Compare how effective each method is at preventing pregnancy, plus what the category numbers mean.',
          onTap: () => setState(() => _additionalInfoView = 2),
        ),
        _additionalInfoMenuCard(
          title: 'Antiretroviral medications and abbreviations',
          description:
              'A glossary of ARV drug classes and abbreviations used throughout the Antiretroviral Therapy condition list.',
          onTap: () => setState(() => _additionalInfoView = 3),
        ),
      ],
    );
  }

  Widget _additionalInfoMenuCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(
          left: 14,
          top: 14,
          right: 14,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.sans(size: 15, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.sans(
                size: 12.5,
                color: AppColors.textSecondary,
              ).copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContraception() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._ecMethods.map(_ecMethodCard),
        const SizedBox(height: 8),
        Text(
          'NA = not applicable',
          style: AppTextStyles.sans(size: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Text(
          '*Emergency contraceptive pills may be less effective among women with BMI ≥ 30 kg/m2 than among women with BMI < 25 kg/m2. Despite this, there are no safety concerns.',
          style: AppTextStyles.sans(
            size: 12,
            color: AppColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
      ],
    );
  }

  Widget _ecMethodCard(EcMethod method) {
    final expanded = _expandedEcMethods.contains(method.abbreviation);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (expanded) {
                  _expandedEcMethods.remove(method.abbreviation);
                } else {
                  _expandedEcMethods.add(method.abbreviation);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(
                left: 14,
                top: 14,
                right: 14,
                bottom: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.abbreviation,
                          style: AppTextStyles.sans(
                            size: 20,
                            weight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.fullName,
                          style: AppTextStyles.sans(
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
              child: method.rows == null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Full guidance for ${method.abbreviation} hasn\'t been added yet.',
                        style: AppTextStyles.sans(
                          size: 12,
                          color: AppColors.textSecondary,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < method.rows!.length; i++) ...[
                          if (i > 0)
                            Divider(height: 1, color: AppColors.cardBorder),
                          _ecConditionRow(method.rows![i]),
                        ],
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _ecConditionRow(EcConditionRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              row.label,
              style: AppTextStyles.sans(
                size: 12.5,
                color: AppColors.textPrimary,
              ).copyWith(height: 1.4),
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            row.value,
            style: AppTextStyles.sans(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtGlossary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _artClasses.map(_artClassCard).toList(),
    );
  }

  Widget _artClassCard(ArtClass cls) {
    final expanded = _expandedArtClasses.contains(cls.title);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (expanded) {
                  _expandedArtClasses.remove(cls.title);
                } else {
                  _expandedArtClasses.add(cls.title);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cls.title,
                      style: AppTextStyles.sans(
                        size: 15,
                        weight: FontWeight.w700,
                        color: AppColors.primary,
                      ).copyWith(height: 1.3),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Column(
              children: [
                for (int i = 0; i < cls.drugs.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: AppColors.cardBorder),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 62,
                          child: Text(
                            cls.drugs[i].abbr,
                            style: AppTextStyles.sans(
                              size: 13,
                              weight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 16,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            cls.drugs[i].name,
                            style: AppTextStyles.sans(
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _categoryLegendCard() {
    final rows = [
      (1, AppColors.ovulationTeal, 'Use in any circumstance'),
      (2, AppColors.primary, 'Generally use the method'),
      (
        3,
        AppColors.moodYellow,
        'Not usually recommended unless no better option',
      ),
      (4, AppColors.periodRed, 'Method should not be used'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Understanding your results',
            style: AppTextStyles.sans(size: 13, weight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: row.$2.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${row.$1}',
                        style: AppTextStyles.sans(
                          size: 10,
                          weight: FontWeight.w700,
                          color: row.$2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      row.$3,
                      style: AppTextStyles.sans(
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on established medical eligibility criteria for contraceptive use. This tool is educational and does not replace advice from a healthcare provider.',
            style: AppTextStyles.sans(
              size: 10,
              color: AppColors.textSecondary,
            ).copyWith(fontStyle: FontStyle.italic, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectivenessComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comparing effectiveness',
          style: AppTextStyles.sans(size: 13, weight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Chance of pregnancy in the first year of typical use — lower is more effective.',
          style: AppTextStyles.sans(
            size: 11,
            color: AppColors.textSecondary,
          ).copyWith(height: 1.4),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < _effectivenessTiers.length; i++)
          _effTierCard(i, _effectivenessTiers[i]),
        Text(
          'Numbers indicate % of women experiencing an unintended pregnancy during the first year of typical use of the method. Source: Trussell J., 2011.',
          style: AppTextStyles.sans(
            size: 10,
            color: AppColors.textSecondary,
          ).copyWith(fontStyle: FontStyle.italic, height: 1.4),
        ),
      ],
    );
  }

  Widget _effTierCard(int index, EffectivenessTier tier) {
    final expanded = _expandedEffTiers.contains(index);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (expanded) {
                  _expandedEffTiers.remove(index);
                } else {
                  _expandedEffTiers.add(index);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 32,
                    decoration: BoxDecoration(
                      color: tier.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.title,
                          style: AppTextStyles.sans(
                            size: 13,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tier.methods.length} methods',
                          style: AppTextStyles.sans(
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tier.methods.map((m) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tier.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: tier.color.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              m.name,
                              style: AppTextStyles.sans(
                                size: 11.5,
                                weight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              m.percent,
                              style: AppTextStyles.sans(
                                size: 11.5,
                                weight: FontWeight.w700,
                                color: tier.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tier.note,
                    style: AppTextStyles.sans(
                      size: 11.5,
                      color: AppColors.textSecondary,
                    ).copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHowToUse() {
    final steps = [
      (
        '1',
        'Select your conditions',
        'Open the Eligibility tool and check any medical conditions or characteristics that apply to you.',
      ),
      (
        '2',
        'Tap "Check my eligibility"',
        'The app matches your selections against established guidance for each method.',
      ),
      (
        '3',
        'Read the category numbers',
        '1 and 2 mean the method can generally be used. 3 and 4 mean it\'s not usually recommended, or should not be used.',
      ),
      (
        '4',
        'Check "Additional info"',
        'Review what each category means, plus how methods compare on effectiveness.',
      ),
      (
        '5',
        'When in doubt, ask a provider',
        'This tool is educational — a healthcare provider can give guidance specific to you.',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The tool provides guidance on the safety of contraceptive methods for clients with specific medical conditions or characteristics, and allows searching by client preferences.',
                style: AppTextStyles.sans(
                  size: 13,
                  color: AppColors.textSecondary,
                ).copyWith(height: 1.6),
              ),
              const SizedBox(height: 14),
              Text(
                'Begin by selecting the medical condition(s) of interest and client preferences. The app will then indicate the safety rating of each method, and will filter results by client preferences. The numbers 1, 2, 3, 4 correspond to recommendations, telling you whether the individual who has this known condition or characteristic is eligible to initiate this contraceptive method. If clinical judgement is limited, numbers 1 and 2 mean the method can be used (depicted in yellow), and 3 and 4 indicate the method should not be used (depicted in red). Recommendations that have caveats have additional explanations.',
                style: AppTextStyles.sans(
                  size: 13,
                  color: AppColors.textSecondary,
                ).copyWith(height: 1.6),
              ),
              const SizedBox(height: 14),
              Text(
                'Once contraceptive method eligibility has been established, the Additional Info screen may be reviewed regarding other considerations. A chart of contraceptive effectiveness, comparing typical use for a diverse range of methods (including some not explicitly covered in this app) is included in this menu.',
                style: AppTextStyles.sans(
                  size: 13,
                  color: AppColors.textSecondary,
                ).copyWith(height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.periodRed.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              s.$1,
                              style: AppTextStyles.sans(
                                size: 11,
                                weight: FontWeight.w700,
                                color: AppColors.periodRed,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.$2,
                                style: AppTextStyles.sans(
                                  size: 13,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                s.$3,
                                style: AppTextStyles.sans(
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ).copyWith(height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ovulationTeal.withOpacity(0.3)),
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
            child: Center(child: emojiText('🛡️', size: 24)),
          ),
          const SizedBox(height: 14),
          Text('Protective Sex', style: AppTextStyles.serif(size: 19)),
          const SizedBox(height: 8),
          Text(
            'Using contraception correctly is one of the most responsible health decisions you can make. No method is 100% effective — layering methods gives the best protection.',
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

class MethodCard extends StatelessWidget {
  final String emoji;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final String detail;
  final List<Map<String, dynamic>> tags;

  /// Save-to-diary hooks. All optional so MethodCard can still be used
  /// purely for display elsewhere without wiring diary logic -- when
  /// [onSave] is null, no button is rendered at all.
  final VoidCallback? onSave;
  final bool isSaving;
  final bool isSaved;

  const MethodCard({
    super.key,
    required this.emoji,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.tags,
    this.onSave,
    this.isSaving = false,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: emojiText(emoji, size: 18)),
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
                      subtitle,
                      style: AppTextStyles.sans(size: 11, color: badgeColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            detail,
            style: AppTextStyles.sans(
              size: 12,
              color: AppColors.textSecondary,
            ).copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) {
              final color = t['color'] as Color;
              final label = t['label'] as String;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.sans(
                    size: 10,
                    weight: FontWeight.w600,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
          if (onSave != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isSaved
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 17,
                      ),
                label: Text(
                  isSaved ? 'Saved to My Diary' : "I'm using this method",
                  style: AppTextStyles.sans(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSaved
                      ? AppColors.ovulationTeal
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
