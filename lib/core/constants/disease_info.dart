// lib/core/constants/disease_info.dart
//
// Hardcoded disease knowledge base used as a fallback when the AI service is
// unavailable or disabled.  Content is formatted as GitHub-flavoured Markdown
// so it can be rendered directly by flutter_markdown.

class DiseaseInfo {
  DiseaseInfo._();

  // ── Knowledge base ────────────────────────────────────────────────────────
  static const Map<String, String> _db = {
    'bacterial leaf blight': '''## Definition

Bacterial Leaf Blight (BLB) is caused by *Xanthomonas oryzae* pv. *oryzae*, a gram-negative bacterium that invades rice tissue through wounds or natural openings. It is among the most economically damaging rice diseases worldwide, particularly in warm, humid, irrigated lowlands.

## Symptoms

- **Water-soaked to yellowish stripes** begin at leaf margins or tips and rapidly extend inward, turning white or straw-coloured as tissue dies
- **Leaf wilting and rolling** — infected leaves curl lengthwise and dry from the tip downward, eventually turning light brown
- **Milky bacterial ooze** is visible on freshly cut leaf ends when dipped in clean water, a reliable field diagnostic sign

## Remedies

1. **Drain the field** immediately to reduce the moist, warm micro-climate that favours bacterial multiplication; avoid flood irrigation during an outbreak
2. **Apply copper-based bactericides** (e.g. copper oxychloride 50 WP at 3 g/L water) or antibiotics such as streptomycin sulphate as a foliar spray at the first sign of symptoms
3. **Switch to resistant varieties** — IR64, IR72, BRRI dhan28, or other locally recommended BLB-tolerant cultivars — in the next cropping season to reduce recurrence''',

    // ─────────────────────────────────────────────────────────────────────────
    'brown spot': '''## Definition

Brown Spot is a fungal disease caused by *Bipolaris oryzae* (syn. *Helminthosporium oryzae*). It is often associated with nutrient-poor soils and commonly affects rainfed, upland, and dryland rice. Severe infections can reduce grain filling, leading to empty or chaffy grains and significant yield losses.

## Symptoms

- **Oval to circular spots** with a light brown to dark brown border and a gray or whitish centre on leaf blades; spots may coalesce under heavy infection
- **Glume and grain discolouration** — infected hulls turn dark brown and grains may be partially or fully discoloured, reducing market value
- **Seedling blight** — infected seeds produce brown, shrivelled seedlings in the nursery stage

## Remedies

1. **Correct soil nutrient deficiencies** — apply potassium, silicon (as silica slag), and balanced NPK fertilisers; silicon significantly reduces susceptibility to *B. oryzae*
2. **Apply fungicides** such as propiconazole (0.1%), mancozeb (0.25%), or iprodione at the tillering and boot stages or at first symptom appearance
3. **Use certified, treated seed** — soak seeds in hot water (52 °C for 10 min) or treat with thiram/captan before sowing to reduce seed-borne inoculum''',

    // ─────────────────────────────────────────────────────────────────────────
    'leaf blast': '''## Definition

Leaf Blast is caused by the fungus *Magnaporthe oryzae* and is considered the most destructive rice disease globally. It attacks leaves, nodes, necks, and panicles at virtually any growth stage. Cool temperatures (20–28 °C), heavy dew, and high nitrogen levels create the most favourable conditions for explosive outbreaks.

## Symptoms

- **Diamond-shaped or spindle-shaped lesions** with a grayish-white or tan centre and a dark brown to reddish-brown border; a yellow halo often surrounds young lesions
- **Coalescing spots** that kill entire leaves within days under high humidity, giving a "fire-scorched" appearance to severely affected fields
- **Gray, powdery sporulation** visible on lesion surfaces during humid mornings — the fungus' asexual spores ready to spread to neighbouring plants

## Remedies

1. **Apply systemic fungicides early** — tricyclazole (0.06%), isoprothiolane (0.075%), or azoxystrobin at the first appearance of leaf lesions, especially before the boot and heading stages
2. **Reduce nitrogen fertiliser** — split applications and avoid applying excessive N in a single dose; lush, soft foliage is highly susceptible to blast entry
3. **Plant blast-resistant varieties** and time planting to avoid extended periods of cool, foggy weather; maintain adequate spacing to improve air circulation and reduce leaf wetness''',

    // ─────────────────────────────────────────────────────────────────────────
    'leaf scald': '''## Definition

Leaf Scald is caused by *Microdochium oryzae* (formerly *Rhynchosporium oryzae*), a fungal pathogen that attacks leaves and leaf sheaths. It is more prevalent under cool, wet weather during the tillering to booting stages and is commonly confused with other foliar diseases due to its banded pattern.

## Symptoms

- **Zonate, banded lesions** — alternating tan and brown bands on leaves and sheaths give a characteristic "scalded" or zebra-stripe appearance, differentiating it from other diseases
- **Oval to elongated spots** with wavy, irregular margins that start as water-soaked areas, then dry and bleach to a straw colour
- **Sheath infection** weakens the base of culms, increasing the risk of lodging and reducing photosynthate translocation to developing grains

## Remedies

1. **Spray fungicides** such as propiconazole (0.1%), tebuconazole, or iprodione targeting the lower leaves and leaf sheaths as soon as banded lesions appear
2. **Manage water and humidity** — avoid over-irrigation, ensure proper drainage channels, and widen plant spacing to promote air movement and faster leaf drying
3. **Remove infected crop debris** after harvest and practice crop rotation to break the pathogen's life cycle; deep ploughing also buries residual inoculum''',

    // ─────────────────────────────────────────────────────────────────────────
    'healthy': '''## Definition

Your rice plant appears **healthy** — no visible signs of disease, pest damage, or nutrient deficiency have been detected. Healthy rice plants display uniformly green foliage, firm upright stems, and well-developed tillers without lesions, abnormal spots, or discolouration.

## Key Indicators of Plant Health

- **Uniform, deep-green foliage** free from yellowing, browning, or unusual spotting; leaves are smooth and flat with a healthy waxy sheen
- **Strong, upright growth** with well-developed tillers; stems (culms) are firm and resist lodging under normal wind conditions
- **Normal leaf texture** — no water-soaked patches, lesion borders, or powdery/sticky coatings on leaf surfaces

## Preventive Care Recommendations

1. **Maintain balanced soil nutrition** — conduct a soil test and apply NPK fertilisers according to crop demand; adequate potassium and silicon significantly boost disease resistance
2. **Scout your field weekly** — walk diagonally through the field, inspect 10 random hills at each sampling point, and act immediately at the first sign of disease or pest pressure
3. **Practise crop hygiene** — use certified clean seed each season, remove crop residues after harvest, and rotate with a non-host crop to keep pathogen populations low''',
  };

  static const Map<String, String> _dbUrdu = {
    'bacterial leaf blight': '''## تعریف

بیکٹیریل پتی جھلساؤ (BLB) *Xanthomonas oryzae* pv. *oryzae* نامی گرام منفی بیکٹیریا کی وجہ سے ہوتی ہے جو زخموں یا قدرتی سوراخوں کے ذریعے چاول کے پودے میں داخل ہوتا ہے۔ یہ دنیا بھر میں چاول کی سب سے زیادہ نقصاندہ بیماریوں میں سے ایک ہے، خاص طور پر گرم، نم، آبپاشی والے نشیبی علاقوں میں۔

## علامات

- **پانی بھرے سے زرد دھاریاں** پتوں کے کناروں یا سروں سے شروع ہو کر تیزی سے اندر کی طرف پھیلتی ہیں اور بافت کے مرنے پر سفید یا بھوسے کے رنگ میں بدل جاتی ہیں
- **پتوں کا مرجھانا اور لڑھکنا** — متاثرہ پتے لمبائی میں مڑ جاتے ہیں اور سرے سے نیچے کی طرف سوکھنے لگتے ہیں، آخرکار ہلکے بھورے ہو جاتے ہیں
- **دودھیا بیکٹیریل رطوبت** صاف پانی میں ڈبوئے گئے تازہ کٹے ہوئے پتوں کے سروں پر نظر آتی ہے، جو کھیت میں تشخیص کی ایک قابل اعتماد علامت ہے

## علاج

1. **کھیت کو فوری طور پر خالی کریں** تاکہ نم، گرم ماحول کم ہو جو بیکٹیریا کی افزائش کے لیے سازگار ہے؛ پھیلاؤ کے دوران سیلابی آبپاشی سے گریز کریں
2. **تانبے پر مبنی بیکٹیریا کش ادویات** (جیسے کاپر آکسی کلورائڈ 50 WP بمقدار 3 گرام فی لیٹر پانی) یا اسٹریپٹومائسن سلفیٹ جیسے اینٹی بایوٹکس علامات ظاہر ہوتے ہی بطور اسپرے استعمال کریں
3. **مزاحم اقسام پر منتقل ہوں** — IR64، IR72، BRRI dhan28 یا دیگر مقامی طور پر تجویز کردہ BLB برداشت کرنے والی اقسام — اگلے فصلی موسم میں دوبارہ پھیلاؤ کو کم کرنے کے لیے''',

    'brown spot': '''## تعریف

بھورے دھبے *Bipolaris oryzae* (syn. *Helminthosporium oryzae*) نامی فنگل بیماری ہے۔ یہ اکثر غذائی اجزاء کی کمی والی مٹی سے منسلک ہوتی ہے اور عام طور پر بارش پر انحصار کرنے والے، اونچے اور خشک زمین والے چاول کو متاثر کرتی ہے۔ شدید انفیکشن اناج کی بھرائی کو کم کر سکتا ہے، جس سے خالی یا بھوسیلے دانے اور نمایاں پیداوار میں کمی ہوتی ہے۔

## علامات

- **بیضوی سے گول دھبے** پتوں پر ہلکے بھورے سے گہرے بھورے کنارے اور بھوری یا سفیدی مائل بیچ کے ساتھ؛ شدید انفیکشن میں دھبے آپس میں مل سکتے ہیں
- **بھوسی اور اناج کی رنگت میں تبدیلی** — متاثرہ بھوسیاں گہری بھوری ہو جاتی ہیں اور دانے جزوی یا مکمل طور پر رنگ بدل سکتے ہیں، جس سے بازار میں قیمت کم ہو جاتی ہے
- **پودوں کا جھلسنا** — متاثرہ بیج نرسری مرحلے میں بھورے، سکڑے ہوئے پودے پیدا کرتے ہیں

## علاج

1. **مٹی میں غذائی اجزاء کی کمی درست کریں** — پوٹاشیم، سلیکون (سلیکا سلیگ کے طور پر) اور متوازن NPK کھاد ڈالیں؛ سلیکون *B. oryzae* کے خلاف حساسیت کو نمایاں طور پر کم کرتا ہے
2. **فنگی سائڈز استعمال کریں** جیسے پروپیکونازول (0.1%)، مینکوزیب (0.25%)، یا آئپروڈیون تلسی اور بوٹ مراحل میں یا پہلی علامت ظاہر ہوتے ہی
3. **تصدیق شدہ، علاج شدہ بیج استعمال کریں** — بیجوں کو گرم پانی (52 °C پر 10 منٹ) میں بھگوئیں یا بوائی سے پہلے تھیرام/کیپٹن سے علاج کریں تاکہ بیج سے پیدا ہونے والے جراثیم کو کم کیا جا سکے''',

    'leaf blast': '''## تعریف

پتی جھلس *Magnaporthe oryzae* فنگس کی وجہ سے ہوتی ہے اور اسے عالمی سطح پر چاول کی سب سے تباہ کن بیماری سمجھا جاتا ہے۔ یہ تقریباً کسی بھی نشوونما کے مرحلے پر پتوں، گانٹھوں، گردنوں اور بالوں پر حملہ کرتی ہے۔ ٹھنڈا درجہ حرارت (20–28 °C)، بھاری اوس اور نائٹروجن کی زیادہ مقدار پھیلاؤ کے لیے سب سے زیادہ سازگار حالات پیدا کرتے ہیں۔

## علامات

- **ہیرے کی شکل یا تکلے کی شکل کے زخم** بھوری سفید یا ٹین رنگ کے بیچ اور گہرے بھورے سے سرخی مائل بھورے کنارے کے ساتھ؛ تازہ زخموں کے گرد پیلا ہالہ اکثر نظر آتا ہے
- **آپس میں ملنے والے دھبے** جو زیادہ نمی کے تحت چند دنوں میں پورے پتوں کو ہلاک کر دیتے ہیں، جس سے شدید متاثرہ کھیتوں کو "آگ سے جھلسا" ہوا دکھائی دیتا ہے
- **بھوری، پاؤڈر نما اسپورنگ** نم صبحوں میں زخم کی سطحوں پر نظر آتی ہے — فنگس کے غیر جنسی بیج جو پڑوسی پودوں تک پھیلنے کے لیے تیار ہوتے ہیں

## علاج

1. **جلد منظم فنگی سائڈ لگائیں** — ٹرائی سائکلازول (0.06%)، آئسوپروتھیولین (0.075%)، یا ازوکسی اسٹروبن پتوں پر زخم ظاہر ہوتے ہی، خاص طور پر بوٹ اور سر نکلنے کے مراحل سے پہلے
2. **نائٹروجن کھاد کم کریں** — تقسیم شدہ مقداریں لگائیں اور ایک بار میں زیادہ N ڈالنے سے گریز کریں؛ نرم، رسیلی پتیاں جھلس کے داخلے کے لیے انتہائی حساس ہوتی ہیں
3. **جھلس مزاحم اقسام لگائیں** اور ٹھنڈے، دھندلے موسم کے طویل ادوار سے بچنے کے لیے بوائی کا وقت منتخب کریں؛ ہوا کی گردش بہتر بنانے اور پتوں کی نمی کم کرنے کے لیے مناسب فاصلہ رکھیں''',

    'leaf scald': '''## تعریف

پتی جھلساؤ *Microdochium oryzae* (سابقاً *Rhynchosporium oryzae*) کی وجہ سے ہوتی ہے، ایک فنگل پیتھوجن جو پتوں اور پتی کے غلافوں پر حملہ کرتا ہے۔ یہ تلسی سے بوٹ مراحل کے دوران ٹھنڈے، بارش والے موسم میں زیادہ پھیلتی ہے اور اپنے پٹے دار نمونے کی وجہ سے اکثر دیگر بیماریوں سے غلط سمجھی جاتی ہے۔

## علامات

- **زونیٹ، پٹے دار زخم** — پتوں اور غلافوں پر ٹین اور بھورے پٹوں کا ردوبدل ایک خاص "جھلسا ہوا" یا زیبرا دھاری ظاہری شکل دیتا ہے جو اسے دوسری بیماریوں سے الگ کرتا ہے
- **بیضوی سے لمبے دھبے** لہراتے، بے قاعدہ کناروں کے ساتھ جو پانی بھرے علاقوں سے شروع ہوتے ہیں، پھر سوکھ کر بھوسے کے رنگ میں بدل جاتے ہیں
- **غلاف کا انفیکشن** تنوں کی بنیاد کو کمزور کرتا ہے، گرنے کا خطرہ بڑھاتا ہے اور بڑھتے ہوئے دانوں تک خوراک کی منتقلی کو کم کرتا ہے

## علاج

1. **فنگی سائڈز چھڑکیں** جیسے پروپیکونازول (0.1%)، ٹیبیوکونازول، یا آئپروڈیون نچلے پتوں اور پتی کے غلافوں کو نشانہ بناتے ہوئے جیسے ہی پٹے دار زخم ظاہر ہوں
2. **پانی اور نمی کا انتظام کریں** — زیادہ آبپاشی سے گریز کریں، مناسب نکاسی آب کو یقینی بنائیں، اور ہوا کی آمدورفت کو فروغ دینے اور پتوں کے تیزی سے سوکھنے کے لیے پودوں کا وسیع فاصلہ رکھیں
3. **فصل کاٹنے کے بعد متاثرہ فصل کا ملبہ ہٹائیں** اور پیتھوجن کے زندگی کے چکر کو توڑنے کے لیے فصل کی ردوبدل کریں؛ گہری ہل چلانے سے بچا ہوا جراثیم بھی دفن ہو جاتا ہے''',

    'healthy': '''## تعریف

آپ کا چاول کا پودہ **صحت مند** دکھائی دیتا ہے — بیماری، کیڑوں کے نقصان، یا غذائی اجزاء کی کمی کی کوئی واضح علامات نہیں پائی گئیں۔ صحت مند چاول کے پودے یکساں سبز پتے، مضبوط سیدھے تنے، اور بہتر نشوونما پائے ہوئے شاخ بغیر زخموں، غیر معمولی دھبوں، یا رنگت میں تبدیلی کے دکھاتے ہیں۔

## پودے کی صحت کے اہم اشارے

- **یکساں، گہرے سبز پتے** بغیر پیلاہٹ، بھورے پن، یا غیر معمولی دھبوں کے؛ پتے ہموار اور چپٹے ہوتے ہیں جن پر صحت مند موم کی چمک ہوتی ہے
- **مضبوط، سیدھی نشوونما** اچھی طرح سے نشوونما پائے ہوئے شاخوں کے ساتھ؛ تنے مضبوط ہوتے ہیں اور عام ہوا کے حالات میں گرنے سے مزاحمت کرتے ہیں
- **معمول کی پتی کی بناوٹ** — پتوں کی سطحوں پر کوئی پانی بھرے حصے، زخم کے کنارے، یا پاؤڈر/چپچپے کوٹنگ نہیں

## احتیاطی نگہداشت کی سفارشات

1. **متوازن مٹی کی غذائیت برقرار رکھیں** — مٹی کا ٹیسٹ کروائیں اور فصل کی ضرورت کے مطابق NPK کھاد ڈالیں؛ مناسب پوٹاشیم اور سلیکون بیماری کے خلاف مزاحمت کو نمایاں طور پر بڑھاتے ہیں
2. **ہفتہ وار کھیت کا معائنہ کریں** — کھیت میں ترچھے طور پر چلیں، ہر نمونہ لینے کے مقام پر 10 بے ترتیب ٹیلوں کا معائنہ کریں، اور بیماری یا کیڑوں کے دباؤ کی پہلی علامت پر فوری کارروائی کریں
3. **فصل کی صفائی پر عمل کریں** — ہر موسم میں تصدیق شدہ صاف بیج استعمال کریں، فصل کاٹنے کے بعد فصل کی باقیات ہٹائیں، اور جراثیم کی آبادی کو کم رکھنے کے لیے غیر میزبان فصل کے ساتھ ردوبدل کریں''',
  };

  static const Map<String, String> _definitionsUrdu = {
    'bacterial leaf blight':
        'Xanthomonas oryzae pv. oryzae نامی بیکٹیریا کی وجہ سے ہوتی ہے جو زخموں یا قدرتی سوراخوں کے ذریعے چاول کے پودے میں داخل ہوتا ہے۔ یہ دنیا بھر میں چاول کی سب سے زیادہ نقصاندہ بیماریوں میں سے ایک ہے، خاص طور پر گرم، نم، آبپاشی والے نشیبی علاقوں میں۔',
    'brown spot':
        'Bipolaris oryzae نامی فنگل بیماری، جو عام طور پر غذائی اجزاء کی کمی والی مٹی سے منسلک ہے۔ شدید انفیکشن اناج کی بھرائی کو کم کرتا ہے، جس سے خالی یا بھوسیلے دانے اور نمایاں پیداوار میں کمی ہوتی ہے۔',
    'leaf blast':
        'Magnaporthe oryzae فنگس کی وجہ سے ہوتی ہے اور عالمی سطح پر چاول کی سب سے تباہ کن بیماری سمجھی جاتی ہے۔ یہ تقریباً کسی بھی نشوونما کے مرحلے پر پتوں، گانٹھوں، گردنوں اور بالوں پر حملہ کرتی ہے۔',
    'leaf scald':
        'Microdochium oryzae کی وجہ سے ہوتی ہے، ایک فنگل پیتھوجن جو پتوں اور غلافوں پر خاص پٹے دار زخم پیدا کرتا ہے۔ تلسی سے بوٹ مراحل کے دوران ٹھنڈے، بارش والے موسم میں زیادہ پھیلتی ہے۔',
    'healthy':
        'بیماری، کیڑوں کے نقصان، یا غذائی اجزاء کی کمی کی کوئی واضح علامات نہیں ملیں۔ پودہ یکساں سبز پتے، مضبوط سیدھے تنے، اور بہتر نشوونما پائے ہوئے شاخ بغیر زخموں یا رنگت میں تبدیلی کے دکھاتا ہے۔',
  };

  static const Map<String, String> _definitions = {
    'bacterial leaf blight':
        'Caused by Xanthomonas oryzae pv. oryzae, a bacterium that invades rice tissue through wounds or natural openings. It is among the most economically damaging rice diseases worldwide, particularly in warm, humid, irrigated lowlands.',
    'brown spot':
        'A fungal disease caused by Bipolaris oryzae, commonly associated with nutrient-poor soils. Severe infections reduce grain filling, leading to empty or chaffy grains and significant yield losses.',
    'leaf blast':
        'Caused by the fungus Magnaporthe oryzae and considered the most destructive rice disease globally. It attacks leaves, nodes, necks, and panicles at virtually any growth stage under cool temperatures and high humidity.',
    'leaf scald':
        'Caused by Microdochium oryzae, a fungal pathogen that produces characteristic banded lesions on leaves and sheaths. More prevalent under cool, wet weather during the tillering to booting stages.',
    'healthy':
        'No visible signs of disease, pest damage, or nutrient deficiency detected. The plant displays uniformly green foliage, firm upright stems, and well-developed tillers without lesions or discolouration.',
  };

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns a short one-paragraph definition for [label].
  /// Pass [lang] as `'ur'` or `'Urdu'` for the Urdu definition.
  static String getDefinition(String label, {String lang = 'en'}) {
    final key = label.toLowerCase().trim();
    final isUrdu = lang == 'ur' || lang == 'Urdu';
    final db = isUrdu ? _definitionsUrdu : _definitions;
    if (db.containsKey(key)) return db[key]!;
    for (final entry in db.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }
    return isUrdu
        ? 'PaddyScan نے ایک چاول کی بیماری کا پتہ لگایا ہے۔ تصدیق شدہ تشخیص اور علاج کے منصوبے کے لیے اپنے مقامی زرعی توسیعی افسر سے رابطہ کریں۔'
        : 'A rice disease detected by PaddyScan. Consult your local agricultural extension officer for a confirmed diagnosis and treatment plan.';
  }

  /// Returns the hardcoded Markdown report for [label].
  /// Pass [lang] as `'ur'` or `'Urdu'` for the Urdu report.
  static String getInfo(String label, {String lang = 'en'}) {
    final key = label.toLowerCase().trim();
    final isUrdu = lang == 'ur' || lang == 'Urdu';
    final db = isUrdu ? _dbUrdu : _db;

    // 1. Exact match
    if (db.containsKey(key)) return db[key]!;

    // 2. Partial match — stored key is a substring of the label or vice-versa
    for (final entry in db.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    // 3. Generic fallback
    if (isUrdu) {
      return '''## تعریف

آپ کے چاول کے پودے پر **$label** کا پتہ چلا ہے۔ پھیلاؤ کو محدود کرنے اور پیداوار کی حفاظت کے لیے فوری کارروائی کی سفارش کی جاتی ہے۔

## عمومی علامات

- پتوں کی سطحوں یا غلافوں پر غیر معمولی رنگت، زخم، یا مرجھاہٹ
- پڑوسی صحت مند پودوں کے مقابلے میں پودے کی کمزور نشوونما یا رکاوٹ
- نم یا گیلے حالات میں پڑوسی ٹیلوں تک پھیلنے کا امکان

## عمومی علاج

1. **اپنے مقامی زرعی توسیعی افسر سے رابطہ کریں** تصدیق شدہ تشخیص اور فصل کے مخصوص علاج کے منصوبے کے لیے
2. **وسیع اسپیکٹرم فنگی سائڈ یا بیکٹیریا کش دوا لگائیں** (جیسا مناسب ہو) لیبل ہدایات کے مطابق؛ ہمیشہ دوا لگاتے وقت حفاظتی سامان پہنیں
3. **اچھی کھیت کی صفائی پر عمل کریں** — واضح طور پر متاثرہ پودوں کا مواد ہٹائیں، پانی جمنے سے گریز کریں، اور کھیتوں کے درمیان آلات کو صاف کریں''';
    }
    return '''## Definition

**$label** has been detected on your rice plant. Prompt action is recommended to limit spread and protect yield.

## General Symptoms

- Abnormal discolouration, lesions, or wilting on leaf surfaces or sheaths
- Reduced plant vigour or stunted growth compared to neighbouring healthy plants
- Possible spread to adjacent hills under humid or wet conditions

## General Remedies

1. **Consult your local agricultural extension officer** for a confirmed diagnosis and crop-specific treatment plan
2. **Apply a broad-spectrum fungicide or bactericide** (as appropriate) following label directions; always wear protective equipment during application
3. **Practise good field hygiene** — remove visibly infected plant material, avoid waterlogging, and sterilise tools between fields to prevent cross-contamination''';
  }
}
