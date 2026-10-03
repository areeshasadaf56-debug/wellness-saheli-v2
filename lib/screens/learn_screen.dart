import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QAItem {
  final String question;
  final String answer;
  const QAItem(this.question, this.answer);
}

class TopicItem {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final List<QAItem> qa;

  const TopicItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.qa,
  });
}

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  /// Set by other screens (e.g. Home suggestion card) to open a topic sheet
  /// by its title once the Learn tab is shown.
  static final ValueNotifier<String?> pendingTopic = ValueNotifier<String?>(
    null,
  );

  static void openTopic(String title) => pendingTopic.value = title;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  static final List<TopicItem> _topics = [
    TopicItem(
      emoji: '⚕️',
      title: 'Anatomy',
      subtitle: 'Reproductive system basics',
      color: AppColors.accent,
      qa: const [
        QAItem(
          'What are the main internal reproductive organs?',
          'The ovaries produce eggs and hormones. The fallopian tubes carry eggs from the ovaries to the uterus. The uterus is where a fetus develops. The cervix connects the uterus to the vagina.',
        ),
        QAItem(
          'What does the vagina actually do?',
          'The vagina is the muscular canal connecting the cervix to the outside of the body. It serves as the birth canal, the pathway for menstrual blood, and the entry point for sexual intercourse. It is self-cleaning and produces natural discharge.',
        ),
        QAItem(
          'What is the hymen?',
          'The hymen is a thin membrane that partially covers the vaginal opening. It varies widely in shape and size. It does not indicate virginity and may stretch or tear through exercise, tampon use, or sexual activity.',
        ),
        QAItem(
          "What is the difference between the vulva and the vagina?",
          "The vulva is the outer, visible part. The vagina is the internal canal. Many people use the word vagina for both, but they are different.\n\nThe vulva includes:\n• Labia majora (outer lips) and labia minora (inner lips)\n• The clitoris, a small, highly sensitive organ whose only known purpose is pleasure\n• The urethral opening, where urine leaves the body\n• The vaginal opening\n\nEvery vulva looks different in colour, size and shape. Asymmetry and uneven lips are completely normal.",
        ),
        QAItem(
          "Are urine, periods and sex all through the same opening?",
          "No. There are three separate openings: the urethra (urine), the vagina (period blood, sex, birth) and the anus (stool). Tampons and menstrual cups go in the vagina, so you can still urinate while using them.",
        ),
        QAItem(
          "How do the ovaries and eggs work?",
          "You are born with roughly 1 to 2 million immature eggs, and only about 300 to 400 are ever released. Around once a month, one ovary releases a mature egg (ovulation). The ovaries also make most of your estrogen and progesterone. Ovaries usually take turns, but it is not a strict pattern.",
        ),
        QAItem(
          "What is the uterus made of?",
          "The uterus is a muscular, pear-sized organ with two main layers:\n• Endometrium: the inner lining that thickens every month to prepare for a pregnancy. When no pregnancy happens, this lining is shed as your period.\n• Myometrium: the strong muscle wall that cramps during periods and pushes during childbirth.\n\nThe uterus can tilt forward or backward (tilted uterus). This is a normal variation.",
        ),
        QAItem(
          "What is normal vaginal discharge?",
          "Discharge keeps the vagina clean and healthy. It changes through the cycle:\n• After period: little or dry\n• Before ovulation: cloudy, then clear and stretchy like egg white\n• After ovulation: thicker, creamy or sticky\n\nSee a doctor if discharge is green, grey or yellow, smells strongly fishy or foul, is frothy or lumpy like cottage cheese, or comes with itching, burning or pain. Do not douche; it upsets the natural balance and can cause infections.",
        ),
        QAItem(
          "When should I see a doctor about my anatomy or pelvic health?",
          "• Pain during sex, tampon use or an exam\n• Persistent pelvic pain\n• Unusual lumps, sores or swelling\n• Bleeding after sex or between periods\n• Burning when you urinate\n\nThese are common and treatable, and a doctor will not judge you for asking.",
        ),
      ],
    ),
    TopicItem(
      emoji: '🧬',
      title: 'Hormones',
      subtitle: 'How they affect your cycle',
      color: AppColors.primary,
      qa: const [
        QAItem(
          'What hormones control my cycle?',
          'Estrogen and progesterone rise and fall through the month, while FSH and LH from the pituitary gland trigger egg development and ovulation. Together they drive every phase of the cycle.',
        ),
        QAItem(
          'Why do I feel different in each phase?',
          'Estrogen tends to lift energy and mood in the first half of the cycle, while progesterone in the second half can cause fatigue, bloating, and mood changes as it eventually drops before your period.',
        ),
        QAItem(
          'Can hormone levels be tested?',
          'Yes. Blood tests can measure estrogen, progesterone, LH, FSH, and thyroid hormones, which are often checked together when investigating irregular cycles.',
        ),
        QAItem(
          "What does each hormone actually do?",
          "• Estrogen: builds up the uterine lining, supports energy, mood, skin, bones and heart health.\n• Progesterone: made after ovulation; prepares and holds the lining for pregnancy, and raises body temperature slightly.\n• FSH (follicle-stimulating hormone): helps eggs mature in the ovary.\n• LH (luteinizing hormone): a sudden surge triggers the release of the egg, about 24 to 36 hours later.\n• Testosterone: women also make a small amount; it supports libido, muscle and energy.",
        ),
        QAItem(
          "How does the brain control the cycle?",
          "The brain and ovaries talk to each other in a loop. The hypothalamus signals the pituitary gland, which releases FSH and LH. The ovaries respond with estrogen and progesterone, which then signal back to the brain. Stress, illness, big weight changes, intense exercise and lack of sleep can disturb this loop and delay or skip ovulation.",
        ),
        QAItem(
          "Which other hormones affect my cycle?",
          "• Thyroid hormones: an underactive or overactive thyroid can cause heavy, light or missed periods.\n• Prolactin: high levels can stop ovulation.\n• Cortisol (stress hormone): long-term stress can make cycles irregular.\n• Insulin: insulin resistance is closely linked to PCOS.",
        ),
        QAItem(
          "What are signs of a hormonal imbalance?",
          "• Irregular, very heavy, very light or missing periods\n• Acne that is severe or keeps returning\n• Excess facial or body hair, or scalp hair thinning\n• Unexplained weight changes\n• Constant fatigue, low mood or anxiety\n• Hot flashes or night sweats\n• Trouble getting pregnant\n\nThese signs can have many causes. A doctor can check with blood tests and an ultrasound.",
        ),
        QAItem(
          "How do hormonal contraceptives change my hormones?",
          "Pills, patches, rings, injections and hormonal IUDs add synthetic hormones that mostly stop ovulation or thicken cervical mucus. Bleeding on the pill is a withdrawal bleed, not a true period. Side effects such as spotting, headaches or mood changes are common in the first 3 months. Talk to a doctor if they do not settle.",
        ),
        QAItem(
          "Can lifestyle support healthy hormones?",
          "Yes. Regular sleep, balanced meals with enough protein and healthy fats, moderate exercise, stress management and avoiding smoking all help. Extreme dieting and over-exercising can stop periods completely.",
        ),
      ],
    ),
    TopicItem(
      emoji: '🛡️',
      title: 'STIs',
      subtitle: 'Common infections & prevention',
      color: AppColors.textPrimary,
      qa: const [
        QAItem(
          'How are STIs usually transmitted?',
          'Most STIs spread through vaginal, anal, or oral sex, and some, like herpes and HPV, can spread through skin-to-skin contact even without penetration.',
        ),
        QAItem(
          'Can you have an STI with no symptoms?',
          'Yes. Many STIs, including chlamydia and gonorrhea, often cause no symptoms at all, which is why regular screening matters even if you feel fine.',
        ),
        QAItem(
          'How can risk be reduced?',
          'Condoms significantly lower the risk of most STIs, and regular testing with new or multiple partners helps catch infections early, when they are easiest to treat.',
        ),
        QAItem(
          "What are the most common STIs?",
          "• Chlamydia and gonorrhea (bacterial, curable): often no symptoms; can cause discharge, burning, pelvic pain.\n• HPV (viral): very common; some types cause genital warts, some can lead to cervical cancer.\n• Genital herpes (viral): painful blisters or sores that come and go.\n• Syphilis (bacterial, curable): painless sore first, later rash and serious complications if untreated.\n• Trichomoniasis (parasite, curable): frothy or smelly discharge and itching.\n• HIV (viral): attacks the immune system; with treatment people live long, healthy lives.\n• Hepatitis B (viral): affects the liver; a vaccine is available.",
        ),
        QAItem(
          "What symptoms should I watch for?",
          "• Unusual discharge or smell\n• Burning or pain when urinating\n• Sores, bumps, blisters or warts around the genitals or mouth\n• Itching or irritation\n• Pain during sex or in the lower belly\n• Bleeding between periods or after sex\n\nRemember that many infections have no symptoms at all.",
        ),
        QAItem(
          "How do I get tested and treated?",
          "Testing is usually a urine sample, a swab or a blood test. Bacterial infections and parasites are cured with antibiotics or antiparasitic medicine; finish the full course and avoid sex until you and your partner are treated. Viral infections such as herpes and HIV cannot be cured but can be controlled with medicine. Untreated infections can cause pelvic inflammatory disease, infertility and pregnancy complications.",
        ),
        QAItem(
          "How can I protect myself?",
          "• Use condoms correctly every time\n• Get the HPV and hepatitis B vaccines\n• Get regular screening (Pap or HPV test for cervical cancer as advised by your doctor)\n• Test with new partners and talk openly before sex\n• Do not share needles or razors\n\nBirth control pills, implants and IUDs prevent pregnancy but do NOT protect against STIs.",
        ),
        QAItem(
          "How do I talk to a partner about STIs?",
          "Choose a calm, private moment before sex. Say it simply, for example: I want us both to be safe, so I would like us to get tested. If you are diagnosed, tell recent partners so they can get tested too. Having an STI is common and does not define you.",
        ),
        QAItem(
          "How are STIs NOT spread?",
          "STIs are not spread by toilet seats, hugging, sharing food or drinks, swimming pools or everyday touch.",
        ),
      ],
    ),
    TopicItem(
      emoji: '🩸',
      title: 'Menstruation',
      subtitle: "What's normal, what's not",
      color: AppColors.periodRed,
      qa: const [
        QAItem(
          'What counts as a "normal" cycle?',
          "A typical cycle ranges from 21 to 35 days, with bleeding lasting 2 to 7 days. Some variation month to month is normal and doesn't necessarily indicate a problem.",
        ),
        QAItem(
          'When is bleeding considered too heavy?',
          'Soaking through a pad or tampon every hour for several hours, passing large clots, or bleeding for more than 7 days can indicate heavy menstrual bleeding worth discussing with a doctor.',
        ),
        QAItem(
          'Is period pain always normal?',
          "Mild cramping is common, but pain that stops you from daily activities, doesn't respond to over-the-counter painkillers, or worsens over time can be a sign of an underlying condition like endometriosis.",
        ),
        QAItem(
          "What are the phases of a cycle?",
          "• Menstrual phase: the lining sheds; you bleed (about days 1 to 5).\n• Follicular phase: the body prepares an egg; estrogen rises; energy improves (day 1 up to ovulation).\n• Ovulation: an egg is released; the most fertile time (around the middle of the cycle).\n• Luteal phase: progesterone rises; PMS symptoms may appear; ends when the next period starts.\n\nYour cycle is counted from the first day of one period to the day before the next.",
        ),
        QAItem(
          "What do different blood colours mean?",
          "• Bright red: fresh, flowing blood\n• Dark red or brown: older blood, common at the start and end\n• Pink: light flow mixed with discharge\n• Orange: mixed with discharge, can occasionally signal infection if it smells bad\n• Grey or foul smelling: see a doctor\n\nSmall clots (smaller than a coin) are normal.",
        ),
        QAItem(
          "What is PMS and when is it more serious?",
          "PMS (premenstrual syndrome) includes mood swings, bloating, sore breasts, headaches, cravings, fatigue and trouble sleeping in the week or two before a period. Symptoms ease once bleeding starts. PMDD (premenstrual dysphoric disorder) is a severe form with intense depression, anxiety, rage or hopelessness that disrupts work or relationships. It is treatable, so please speak to a doctor. If you ever have thoughts of harming yourself, seek help immediately.",
        ),
        QAItem(
          "When do periods start and stop?",
          "Periods usually begin between ages 9 and 15 (menarche), and the first few years are often irregular. Periods end at menopause, typically around 45 to 55. In the years before it (perimenopause), cycles become irregular and symptoms like hot flashes can appear.",
        ),
        QAItem(
          "What can cause missed or irregular periods?",
          "• Pregnancy (take a test if sexually active)\n• Stress, illness, travel\n• Big weight loss or gain, over-exercising, eating disorders\n• PCOS, thyroid problems, high prolactin\n• Breastfeeding, perimenopause\n• Starting or stopping hormonal contraception\n\nSee a doctor if you miss 3 periods in a row, cycles are shorter than 21 or longer than 35 days, or you bleed between periods or after sex.",
        ),
        QAItem(
          "Why track my cycle?",
          "Logging the first day of your period, flow, mood, pain and symptoms helps you predict your next period, notice patterns, and give your doctor clear information. It is one of the most useful things to bring to an appointment.",
        ),
      ],
    ),
    TopicItem(
      emoji: '❌',
      title: 'Myths',
      subtitle: 'Debunking common myths',
      color: AppColors.primary,
      qa: const [
        QAItem(
          "Myth: You can't get pregnant during your period.",
          'False. Sperm can survive up to 5 days, so if you ovulate early or have a short cycle, sex during your period can still lead to pregnancy.',
        ),
        QAItem(
          'Myth: Irregular periods always mean something is wrong.',
          "Not necessarily. Cycles can vary due to stress, travel, or weight changes. Consistently irregular cycles over several months are what's worth checking with a doctor.",
        ),
        QAItem(
          'Myth: You lose a lot of blood during your period.',
          'Most people lose only 2 to 3 tablespoons of blood across an entire period, even though it can feel like more.',
        ),
        QAItem(
          "Myth: You should not exercise or shower during your period.",
          "False. Exercise often reduces cramps and improves mood. Showering and washing your hair are safe and hygienic.",
        ),
        QAItem(
          "Myth: You cannot get pregnant the first time you have sex.",
          "False. Pregnancy can happen any time sperm meets an egg, including the first time.",
        ),
        QAItem(
          "Myth: A tampon can get lost inside you.",
          "False. The cervix opening is too small for a tampon to pass. A forgotten tampon can stay in the vagina and cause infection, so remove it within 8 hours; a doctor can remove it if you cannot.",
        ),
        QAItem(
          "Myth: PMS is just in your head.",
          "False. PMS is caused by real hormone changes and their effect on brain chemicals. Symptoms are real and can be managed.",
        ),
        QAItem(
          "Myth: Periods make you impure or unclean.",
          "False. Menstruation is a normal, healthy body process. There is nothing shameful or dirty about it.",
        ),
        QAItem(
          "Myth: Birth control causes permanent infertility.",
          "False. Fertility generally returns after stopping hormonal contraception, though regular cycles may take a few months to resume.",
        ),
        QAItem(
          "Myth: Cycle length is always exactly 28 days.",
          "False. 28 days is only an average. Anything from 21 to 35 days can be normal.",
        ),
      ],
    ),
  ];

  static final List<TopicItem> _guides = [
    TopicItem(
      emoji: '☀️',
      title: 'Fertility Window Guide',
      subtitle: 'Ovulation & your most fertile days',
      color: AppColors.accent,
      qa: const [
        QAItem(
          "What is the fertile window?",
          "It is the roughly 6-day stretch each cycle when pregnancy is possible: the 5 days before ovulation plus the day of ovulation. Sperm can survive up to 5 days in the body, but the egg lives only 12 to 24 hours after release.",
        ),
        QAItem(
          "When does ovulation happen?",
          "Ovulation usually happens about 12 to 16 days BEFORE your next period, not always on day 14. In a 28-day cycle it is around day 14, but in a 35-day cycle it is closer to day 21. The app gives an estimate from your logged cycles, so it is more accurate the more you log.",
        ),
        QAItem(
          "Which are the most fertile days?",
          "The two days before ovulation and the day of ovulation have the highest chance of pregnancy. Chances drop sharply the day after ovulation.",
        ),
        QAItem(
          "What are the signs of ovulation?",
          "• Cervical mucus becomes clear, slippery and stretchy like raw egg white\n• Mild one-sided lower belly pain or twinge (mittelschmerz)\n• Slightly higher sex drive\n• Breast tenderness, light spotting or mild bloating\n• Basal body temperature rises by about 0.2 to 0.5 °C after ovulation\n• A positive ovulation test (LH strip) means ovulation is likely within 24 to 36 hours\n\nNot everyone notices these signs, and that is normal.",
        ),
        QAItem(
          "How can I track it more accurately?",
          "Combine methods: log your period dates, watch cervical mucus daily, take your temperature every morning before getting up, and use ovulation test strips from a few days before the expected date. Temperature only confirms ovulation after it has happened, so it is best for learning your pattern over several months.",
        ),
        QAItem(
          "If I want to get pregnant, what helps?",
          "• Have sex every 1 to 2 days during the fertile window\n• Start folic acid (400 mcg daily) ideally a month before trying\n• Keep a healthy weight, do not smoke, limit alcohol and caffeine\n• Manage stress and sleep well\n• See a doctor if you have not conceived after 12 months of trying (6 months if you are 35 or older), or sooner if your cycles are very irregular",
        ),
        QAItem(
          "If I want to avoid pregnancy, can I rely on this?",
          "No. Fertile window predictions are estimates, and ovulation can shift with stress, illness or travel. Using only calendar tracking has a high failure rate. For dependable prevention, use a contraceptive method; the Protection tab can help you find one that suits your health conditions.",
        ),
        QAItem(
          "What if my cycles are irregular or I have PCOS?",
          "Ovulation may be late or may not happen at all, so the predicted window can be unreliable. Ovulation tests can be misleading with PCOS because LH may stay high. Talk to a doctor if you want to conceive; treatment can help restore ovulation.",
        ),
      ],
    ),
    TopicItem(
      emoji: '🌙',
      title: 'Managing Luteal Phase',
      subtitle: 'Nutrition and exercise for this phase',
      color: AppColors.primary,
      qa: const [
        QAItem(
          "What is the luteal phase?",
          "It is the time between ovulation and the start of your next period, usually 10 to 16 days (about 14 on average). After the egg is released, progesterone rises to prepare the womb. If you do not become pregnant, progesterone and estrogen fall and your period begins.",
        ),
        QAItem(
          "Why do I feel different now?",
          "In the early luteal phase you may still feel fairly good. In the late luteal phase (the last 5 to 7 days) hormones drop, which can affect mood, sleep, appetite and energy. This is the PMS window.",
        ),
        QAItem(
          "What symptoms are common?",
          "• Bloating and water retention\n• Breast tenderness\n• Mood swings, irritability, anxiety or sadness\n• Cravings and increased appetite\n• Fatigue and poor sleep\n• Headaches, acne, constipation\n• Mild cramps before your period\n\nThese usually ease within a day or two of your period starting.",
        ),
        QAItem(
          "What should I eat?",
          "• Complex carbs (oats, brown rice, whole wheat, sweet potato) to steady mood and cravings\n• Magnesium-rich foods (nuts, seeds, leafy greens, bananas, dark chocolate)\n• Vitamin B6 foods (chickpeas, fish, potatoes, bananas)\n• Calcium (milk, yogurt, cheese, fortified foods)\n• Fibre and plenty of water to reduce bloating and constipation\n• Protein with every meal\n\nTry cutting back on salt, caffeine, alcohol and sugary snacks, which can worsen bloating, anxiety and mood dips.",
        ),
        QAItem(
          "How should I exercise?",
          "Moderate movement works best: brisk walking, light jogging, cycling, swimming, pilates, yoga or lighter strength training. Many people have less energy in the late luteal phase, so lower the intensity if you feel tired. Regular exercise throughout the cycle is one of the best natural ways to reduce PMS.",
        ),
        QAItem(
          "How can I sleep and manage stress better?",
          "• Keep fixed sleep and wake times\n• Avoid caffeine after noon\n• Try deep breathing, stretching, journaling or a warm bath in the evening\n• Say no to extra commitments if you can and give yourself some downtime\n• Use the mood log in the app to spot your personal pattern",
        ),
        QAItem(
          "What about supplements?",
          "Some evidence suggests calcium and magnesium may ease PMS for some people, and vitamin B6 in moderate doses may help mood. Do not take high doses on your own; check with a doctor or pharmacist first, especially if you are pregnant, planning pregnancy or on medication.",
        ),
        QAItem(
          "When is it more than PMS?",
          "See a doctor if mood symptoms are severe (deep sadness, rage, hopelessness, panic) or disrupt work, study or relationships every month; this may be PMDD, which is treatable. Also get checked if your luteal phase is regularly shorter than 10 days, as it can make conceiving harder. If you have thoughts of harming yourself, seek help immediately.",
        ),
      ],
    ),
    TopicItem(
      emoji: '🌸',
      title: 'Explore Your Cycle',
      subtitle: 'Learn more about your follicular phase',
      color: AppColors.primary,
      qa: const [
        QAItem(
          "How does a cycle work?",
          "A cycle starts on the first day of your period and ends the day before the next one. Four phases repeat:\n• Menstrual: shedding of the lining (days 1 to 5 or so)\n• Follicular: egg follicles grow and the lining rebuilds (starts on day 1, ends at ovulation)\n• Ovulation: egg release (around mid-cycle)\n• Luteal: the body prepares for a possible pregnancy (until the next period)\n\nA 28-day cycle is just an average; 21 to 35 days is normal for adults.",
        ),
        QAItem(
          "What happens in the follicular phase?",
          "The pituitary gland releases FSH, which wakes up several follicles (tiny egg sacs) in the ovaries. One becomes dominant and keeps maturing. As it grows it makes more estrogen, which rebuilds the thick uterine lining after your period. This phase ends with ovulation.",
        ),
        QAItem(
          "How might I feel?",
          "Rising estrogen usually brings better energy, mood, focus and skin. Many people feel more social, motivated and creative, and pain tolerance is often higher. This is a good time to start new projects, study hard or try something new. Everyone is different, so use your own tracking to learn your pattern.",
        ),
        QAItem(
          "What should I eat?",
          "• Iron-rich foods to replace blood lost during your period (lentils, spinach, beans, red meat, eggs, dates), paired with vitamin C like lemon or oranges to boost absorption\n• Lean protein and eggs\n• Fresh vegetables and fruit\n• Fermented foods like yogurt\n• Whole grains and healthy fats such as nuts, seeds and olive oil",
        ),
        QAItem(
          "How should I exercise?",
          "Energy is usually rising, so this is a great time for higher-intensity workouts, strength training, running, cardio or learning a new skill. Warm up well and listen to your body, especially in the first days after bleeding.",
        ),
        QAItem(
          "How long does each phase last?",
          "The follicular phase varies the most between people and between cycles (often 10 to 17 days). The luteal phase is more consistent (about 12 to 14 days). That is why a longer or shorter cycle usually means ovulation came later or earlier.",
        ),
        QAItem(
          "What should I track?",
          "• First and last day of bleeding, and flow heaviness\n• Pain, mood, energy and sleep\n• Symptoms like headaches, acne, bloating\n• Discharge changes\n• Medicines, stress, travel or illness\n\nThree or more months of logs give a much clearer picture and help your doctor.",
        ),
        QAItem(
          "When should I see a doctor?",
          "• No period for 3 months or more (and not pregnant)\n• Cycles shorter than 21 or longer than 35 days, regularly\n• Periods lasting more than 7 days or very heavy\n• Bleeding between periods or after sex\n• Severe pain that stops daily activity\n• Sudden big changes in your pattern",
        ),
      ],
    ),
    TopicItem(
      emoji: '🌺',
      title: 'Self-Care During Period',
      subtitle: 'Tips for managing discomfort and boosting energy',
      color: AppColors.periodRed,
      qa: const [
        QAItem(
          "How can I ease period cramps?",
          "• Apply a hot water bottle or heating pad to your lower belly or back\n• Take an over-the-counter pain reliever such as ibuprofen, naproxen or paracetamol as directed on the label; anti-inflammatory ones work best when started at the first sign of pain and taken with food\n• Gentle walking, stretching or yoga\n• Lie with knees bent or in a child's pose\n• Gentle circular belly massage\n• A warm bath or shower\n\nCheck with a doctor before using painkillers if you have stomach ulcers, asthma, kidney problems or allergies to them.",
        ),
        QAItem(
          "What should I eat and drink?",
          "• Iron-rich foods: lentils (daal), chickpeas, spinach, red meat, eggs, dates, jaggery\n• Vitamin C with iron meals (lemon, oranges, guava)\n• Plenty of water; warm drinks like ginger or chamomile tea can soothe cramps\n• Omega-3 foods like fish, walnuts and flaxseed\n• Magnesium foods like nuts, seeds and bananas\n\nLimit very salty, fried and sugary foods, and cut down on caffeine, which can worsen cramps, bloating and anxiety.",
        ),
        QAItem(
          "Which hygiene practices keep me safe?",
          "• Change pads every 4 to 6 hours\n• Change tampons every 4 to 8 hours; never keep one in for more than 8 hours (risk of toxic shock syndrome)\n• Menstrual cups can usually stay in up to 12 hours; empty, wash and sterilise between cycles\n• Wash your hands before and after changing products\n• Wash the outer genital area with plain water or mild unscented soap; never douche\n• Avoid scented pads, tampons and sprays\n• Wrap used products and bin them; do not flush\n\nTry period underwear or a spare pad for heavy nights.",
        ),
        QAItem(
          "Should I exercise or rest?",
          "Both are fine. Light activity like walking, stretching, yoga or swimming can release endorphins and ease pain. If you are exhausted, resting is equally valid. Listen to your body and skip anything that feels painful.",
        ),
        QAItem(
          "How do I handle fatigue and mood?",
          "Hormone levels are at their lowest, so low energy and sensitivity are common. Prioritise sleep (7 to 9 hours), take short breaks, eat regular meals and reduce commitments if possible. Journaling, music, time outdoors and talking to a trusted friend can help. Use the mood log to track patterns.",
        ),
        QAItem(
          "How can I sleep better with a period?",
          "• Sleep with a dark towel or use period underwear\n• Lie on your side with knees slightly bent to ease cramps\n• Use a heating pad before bed\n• Avoid caffeine in the afternoon and heavy meals late at night",
        ),
        QAItem(
          "What are signs of low iron?",
          "Heavy periods can lead to iron deficiency anemia. Watch for ongoing tiredness, pale skin, dizziness, shortness of breath, headaches, cold hands and feet, brittle nails or hair loss. A simple blood test can check this, and treatment is easy once identified.",
        ),
        QAItem(
          "When should I get medical help?",
          "• Soaking through a pad or tampon every hour for 2 or more hours\n• Clots bigger than a coin\n• Bleeding for more than 7 days\n• Pain that does not improve with painkillers or stops you from daily life\n• Dizziness, fainting or a racing heartbeat\n• Fever, vomiting, diarrhea or sunburn-like rash while using a tampon (possible toxic shock syndrome; this is an emergency, remove the tampon and go to hospital)\n\nPeriods should not be so painful that you cannot function. Severe pain is common but not normal, and can signal conditions like endometriosis.",
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    LearnScreen.pendingTopic.addListener(_handlePending);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handlePending());
  }

  @override
  void dispose() {
    LearnScreen.pendingTopic.removeListener(_handlePending);
    super.dispose();
  }

  void _handlePending() {
    final title = LearnScreen.pendingTopic.value;
    if (title == null || !mounted) return;
    LearnScreen.pendingTopic.value = null;
    final all = [..._topics, ..._guides];
    final match = all.where((t) => t.title == title);
    if (match.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showTopicSheet(context, match.first);
    });
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
            _sectionHeading('TOPICS'),
            const SizedBox(height: 12),
            _buildTopicGrid(context, _topics),
            const SizedBox(height: 24),
            _sectionHeading('CYCLE GUIDES'),
            const SizedBox(height: 12),
            _buildTopicGrid(context, _guides),
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

  Widget _sectionHeading(String text) {
    return Text(
      text,
      style: AppTextStyles.sans(
        size: 11,
        weight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTopicGrid(BuildContext context, List<TopicItem> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((topic) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 20 * 2 - 12) / 2,
          child: _topicCard(context, topic),
        );
      }).toList(),
    );
  }

  Widget _topicCard(BuildContext context, TopicItem topic) {
    return GestureDetector(
      onTap: () => _showTopicSheet(context, topic),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Text(topic.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 10),
            Text(
              topic.title,
              style: AppTextStyles.sans(
                size: 13,
                weight: FontWeight.w700,
                color: topic.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic.subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.sans(
                size: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicSheet(BuildContext context, TopicItem topic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        topic.title == 'Anatomy'
                            ? 'Reproductive Anatomy'
                            : topic.title,
                        style: AppTextStyles.serif(size: 18),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < topic.qa.length; i++) ...[
                    _qaBlock(topic.qa[i], topic.color),
                    if (i != topic.qa.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Divider(height: 1, color: AppColors.cardBorder),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _qaBlock(QAItem qa, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          qa.question,
          style: AppTextStyles.sans(
            size: 13,
            weight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          qa.answer,
          style: AppTextStyles.sans(
            size: 12,
            color: AppColors.textSecondary,
          ).copyWith(height: 1.5),
        ),
      ],
    );
  }
}
