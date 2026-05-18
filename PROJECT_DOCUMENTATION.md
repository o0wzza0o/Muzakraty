# 📚 مذاكرتي (Muzakraty) — توثيق المشروع الكامل

> **منصة تعليمية للجامعات المصرية** — Flutter App  
> تاريخ البناء: 16 مايو 2026  
> الحالة: ✅ تم البناء بنجاح (Debug APK)  
> الجهاز المُختبر: Samsung Galaxy S24 Ultra (SM-S928B)

---

## 📊 ملخص المشروع

| البند | التفاصيل |
|-------|---------|
| **اسم المشروع** | Muzakraty (مذاكرتي) |
| **Package Name** | `com.muzakraty.muzakraty` |
| **Flutter Version** | 3.41.1 (Dart 3.11.0) |
| **عدد ملفات Dart** | 25 ملف |
| **إجمالي حجم الكود** | ~133 KB |
| **الثيم** | Material 3 — Dark Theme |
| **اللغة** | عربي (RTL) بخط Cairo |
| **اللون الأساسي** | Deep Blue `#1A237E` |
| **State Management** | flutter_bloc |
| **Navigation** | go_router (ShellRoute) |

---

## 📁 هيكل المشروع الكامل

```
lib/                                          الحجم
├── main.dart                                 1.8 KB   ← نقطة الدخول
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                   2.1 KB   ← الألوان والتدرجات
│   │   ├── app_strings.dart                  4.2 KB   ← كل النصوص العربية
│   │   └── app_assets.dart                   0.5 KB   ← مسارات الأصول
│   ├── router/
│   │   └── app_router.dart                   3.2 KB   ← GoRouter + ShellRoute
│   ├── security/
│   │   └── screen_security_service.dart      2.0 KB   ← حماية الشاشة
│   └── theme/
│       └── app_theme.dart                    7.0 KB   ← Material 3 Dark Theme
├── data/
│   └── acu_cs_courses.dart                   7.1 KB   ← 9 كورسات CS + نموذج البيانات
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart                2.8 KB   ← BLoC للمصادقة
│   │   │   └── auth_event_state.dart         1.6 KB   ← Events & States
│   │   ├── phone_login/
│   │   │   └── phone_login_screen.dart       8.4 KB   ← شاشة تسجيل الدخول
│   │   ├── otp/
│   │   │   └── otp_screen.dart               8.3 KB   ← شاشة رمز التحقق
│   │   └── access_code/
│   │       └── access_code_screen.dart       5.9 KB   ← شاشة رمز الدخول
│   ├── onboarding/
│   │   ├── profile_setup/
│   │   │   └── profile_setup_screen.dart     26.2 KB  ← معالج الإعداد (7 خطوات)
│   │   └── university_data/
│   │       └── universities.dart             10.1 KB  ← 44 جامعة مصرية
│   ├── home/
│   │   ├── home_shell.dart                   2.4 KB   ← Bottom Navigation
│   │   └── home_screen.dart                  7.1 KB   ← الشاشة الرئيسية
│   ├── courses/
│   │   ├── course_list/
│   │   │   └── my_courses_screen.dart        4.6 KB   ← كورساتي
│   │   ├── course_detail/
│   │   │   └── course_detail_screen.dart     13.5 KB  ← تفاصيل الكورس
│   │   └── video_player/
│   │       └── video_player_screen.dart      7.0 KB   ← مشغل الفيديو
│   ├── search/
│   │   └── search_screen.dart                6.6 KB   ← البحث
│   └── profile/
│       └── profile_screen.dart               6.4 KB   ← الملف الشخصي
└── shared/widgets/
    ├── gradient_button.dart                   2.2 KB   ← زر متدرج
    ├── course_card.dart                       7.0 KB   ← بطاقة الكورس
    └── animated_background.dart              3.1 KB   ← خلفية متحركة
```

### ملفات Native (خارج lib/)

```
android/
├── gradle.properties                         ← إعدادات الذاكرة + Kotlin
└── app/src/main/kotlin/.../MainActivity.kt   ← FLAG_SECURE للأندرويد

ios/
└── Runner/AppDelegate.swift                  ← حماية iOS (isCaptured)
```

---

## 🔒 طبقة الأمان — Screen Security

### Android — `FLAG_SECURE`

**الملف:** `MainActivity.kt`

- يتم تفعيل `FLAG_SECURE` تلقائياً في `onCreate()`
- يمنع تصوير الشاشة (Screenshot) وتسجيل الشاشة (Screen Recording)
- Platform Channel: `com.muzakraty/screen_security`
- الأوامر المدعومة: `enableSecureFlag`, `disableSecureFlag`, `addFlags`

### iOS — `UIScreen.isCaptured`

**الملف:** `AppDelegate.swift`

- مراقبة `capturedDidChangeNotification` لاكتشاف تسجيل الشاشة
- عند اكتشاف التسجيل → يظهر overlay أسود مع رسالة تحذيرية
- تقنية `isSecureTextEntry` لمنع التقاط الشاشة
- Platform Channel: `com.muzakraty/screen_security`
- الأوامر: `enableScreenProtection`, `disableScreenProtection`, `isScreenCaptured`

### Dart Service

**الملف:** `screen_security_service.dart`

- يتواصل مع الكود الأصلي عبر `MethodChannel`
- يُفعّل تلقائياً عند بدء التطبيق في `main.dart`
- يُعاد تفعيله عند عرض الفيديو وعند العودة من الخلفية

---

## 🔐 تدفق المصادقة (Authentication Flow)

```
شاشة تسجيل الدخول (Phone) → رمز التحقق (OTP) → رمز الدخول (2026) → إعداد الملف الشخصي → الرئيسية
```

### 1. شاشة تسجيل الدخول (`phone_login_screen.dart`)

- إدخال رقم الهاتف بالصيغة المصرية: `01X-XXXX-XXXX`
- علم مصر 🇪🇬 + كود الدولة `+20`
- التحقق من صحة الرقم: يبدأ بـ `01` ثم `0,1,2,5` ثم 8 أرقام
- تنسيق تلقائي أثناء الكتابة (Auto-formatting)
- أنيميشن دخول (Fade + Slide)
- خلفية متحركة (Animated Orbs)

### 2. شاشة رمز التحقق (`otp_screen.dart`)

- 6 خانات منفصلة للإدخال
- انتقال تلقائي بين الخانات
- تحقق تلقائي عند إدخال 6 أرقام
- مؤقت عد تنازلي (60 ثانية) لإعادة الإرسال
- زر إعادة الإرسال يظهر بعد انتهاء المؤقت

### 3. شاشة رمز الدخول (`access_code_screen.dart`)

- **رمز الدخول الصحيح: `2026`**
- إدخال مخفي (obscured) بأربع خانات
- عند إدخال رمز خاطئ → رسالة خطأ + اهتزاز هابتيك
- عند النجاح → الانتقال لمعالج إعداد الملف الشخصي

### Auth BLoC (`auth_bloc.dart`)

| Event | State الناتج |
|-------|-------------|
| `SendOtpRequested` | `AuthLoading` → `OtpSent` |
| `VerifyOtpRequested` | `AuthLoading` → `OtpVerified` |
| `VerifyAccessCode("2026")` | `AuthLoading` → `AccessCodeVerified` |
| `VerifyAccessCode("wrong")` | `AuthLoading` → `AccessCodeInvalid` |
| `LogoutRequested` | `Unauthenticated` |

---

## 📝 معالج إعداد الملف الشخصي (Onboarding Wizard)

**الملف:** `profile_setup_screen.dart` (26.2 KB — أكبر ملف في المشروع)

### 7 خطوات مع شريط تقدم (Progress Bar)

| الخطوة | العنوان | المحتوى |
|--------|---------|---------|
| 1 | البيانات الشخصية | الاسم الأول + اسم العائلة + الجنس (ذكر/أنثى) |
| 2 | الموقع | مصر 🇪🇬 (محدد مسبقاً، غير قابل للتغيير) |
| 3 | المرحلة التعليمية | جامعي (محدد مسبقاً) |
| 4 | اختيار الجامعة | 44 جامعة مصرية، **ACU أولاً** ⭐ |
| 5 | اختيار الكلية | كليات حسب الجامعة، **حاسبات أولاً لـ ACU** ⭐ |
| 6 | الفرقة الدراسية | 4-6 سنوات حسب الكلية |
| 7 | كورسات مقترحة | بطاقات أفقية قابلة للتمرير |

### مميزات المعالج:

- ✅ شريط تقدم مرئي بالنسبة المئوية
- ✅ زر رجوع للخطوة السابقة
- ✅ التحقق من اكتمال البيانات قبل المتابعة
- ✅ بحث في قائمة الجامعات (عربي + إنجليزي)
- ✅ السنوات تتغير ديناميكياً (طب = 6، هندسة/صيدلة = 5، باقي = 4)
- ✅ حفظ البيانات في `SharedPreferences`

---

## 🎓 بيانات الجامعات (`universities.dart`)

### ⭐ جامعة الأهرام الكندية (ACU) — الجامعة الرئيسية

تظهر أولاً في القائمة مع أيقونة نجمة وإطار مميز.

**كليات ACU (حاسبات أولاً ⭐):**

| الكلية | بالإنجليزية | مدة الدراسة |
|--------|------------|------------|
| ⭐ حاسبات ومعلومات | Computer Science & IT | 4 سنوات |
| هندسة | Engineering & Technology | 5 سنوات |
| إدارة أعمال | Business Administration | 4 سنوات |
| إعلام | Mass Communication | 4 سنوات |
| صيدلة | Pharmacy | 5 سنوات |
| طب أسنان | Dentistry | 5 سنوات |
| ألسن وترجمة | Al-Alsun & Translation | 4 سنوات |
| فنون وتصميم | Arts & Design | 4 سنوات |

### كل الجامعات المصرية (44 جامعة):

**جامعات حكومية (28):** القاهرة، عين شمس، الإسكندرية، المنصورة، طنطا، الزقازيق، حلوان، بنها، المنوفية، أسيوط، سوهاج، الأقصر، جنوب الوادي، أسوان، قناة السويس، بورسعيد، دمياط، كفر الشيخ، دمنهور، مدينة السادات، بني سويف، الفيوم، المنيا، الوادي الجديد، مطروح، العريش، الأزهر

**جامعات خاصة (16):** سيناء، الجلالة، الملك سلمان، المصرية الروسية، MSA، MIU، BUE، AUC، GUC، FUE، 6 أكتوبر، MTI، فاروس، AAST، النيل، زويل

---

## 🏠 الشاشات الرئيسية

### Bottom Navigation (4 تبويبات):

| # | التبويب | الأيقونة | الشاشة |
|---|--------|---------|--------|
| 1 | الرئيسية | `home` | `home_screen.dart` |
| 2 | كورساتي | `play_circle` | `my_courses_screen.dart` |
| 3 | بحث | `search` | `search_screen.dart` |
| 4 | حسابي | `person` | `profile_screen.dart` |

### الشاشة الرئيسية (`home_screen.dart`)

- **بانر ترحيبي** مع اسم الطالب وكليته (Gradient card)
- **متابعة المشاهدة** — آخر 3 كورسات
- **مقترح لك** — كورسات مبنية على التخصص
- **الأكثر شعبية في كليتك** — كورسات شائعة
- كل قسم بتمرير أفقي مع زر "عرض الكل"

### شاشة كورساتي (`my_courses_screen.dart`)

- قائمة الكورسات المسجلة مع شريط تقدم لكل كورس
- صورة مصغرة + اسم الكورس + المحاضر + النسبة المئوية

### شاشة البحث (`search_screen.dart`)

- بحث فوري (Real-time) في الكورسات
- فلترة بالاسم العربي/الإنجليزي + المحاضر + التصنيف
- عرض النتائج مع التقييم

### شاشة الملف الشخصي (`profile_screen.dart`)

- صورة رمزية (Avatar) بالحرف الأول من الاسم
- بطاقات معلومات: الجامعة، الكلية، السنة الدراسية
- قائمة: تعديل الحساب، الإعدادات، المساعدة، عن التطبيق
- زر تسجيل الخروج (يمسح SharedPreferences ويرجع للـ login)

---

## 📚 نظام الكورسات

### نموذج البيانات (`acu_cs_courses.dart`)

```dart
Course → CourseSection → Lesson
```

### 9 كورسات لطلاب حاسبات ACU:

| # | الكورس | المحاضر | التقييم | النوع |
|---|--------|---------|--------|------|
| 1 | أساسيات Python | د. أحمد محمد | 4.8 | مجاني |
| 2 | البرمجة الكائنية Java | م. سارة أحمد | 4.6 | مدفوع |
| 3 | أساسيات C++ | د. محمود حسن | 4.5 | مدفوع |
| 4 | هياكل البيانات والخوارزميات | د. عمر فاروق | 4.9 | مدفوع |
| 5 | نظم قواعد البيانات | د. فاطمة علي | 4.7 | مجاني |
| 6 | تطوير الويب الشامل | م. يوسف إبراهيم | 4.8 | مدفوع |
| 7 | تطوير تطبيقات الموبايل | م. نور الدين | 4.7 | مدفوع |
| 8 | شبكات وأمن سيبراني | د. حسام الدين | 4.4 | مجاني |
| 9 | الذكاء الاصطناعي وتعلم الآلة | د. ليلى محمود | 4.9 | مدفوع |

### شاشة تفاصيل الكورس (`course_detail_screen.dart`)

- SliverAppBar قابل للطي مع خلفية متدرجة
- زر معاينة مجانية (للدرس الأول)
- معلومات: المحاضر، التقييم، عدد الطلاب، عدد الدروس، الساعات
- المنهج (Curriculum): أقسام + دروس مع أيقونة 🔓 أو ▶️
- الدروس المجانية قابلة للضغط → تنقل لمشغل الفيديو
- زر التسجيل

### مشغل الفيديو (`video_player_screen.dart`)

- مشغل `Chewie` مبني على `video_player`
- **سرعات التشغيل:** 0.5x, 1.0x, 1.25x, 1.5x, 2.0x
- **بدون زر تحميل**
- شريط تقدم بألوان التطبيق (Accent)
- مؤشر "محمي" أخضر في شريط العنوان
- تفعيل حماية الشاشة عند فتح الفيديو
- إيقاف الفيديو عند الذهاب للخلفية
- شريط سفلي يوضح أن المحتوى محمي

---

## 🎨 نظام التصميم

### الألوان (`app_colors.dart`)

| الاسم | اللون | الاستخدام |
|-------|------|----------|
| `primary` | `#1A237E` | الأزرار، العناوين |
| `primaryLight` | `#3949AB` | التدرجات |
| `primaryDark` | `#0D1453` | الخلفيات الداكنة |
| `accent` | `#00BFA5` | العناصر النشطة، التحديد |
| `background` | `#0A0E27` | خلفية التطبيق |
| `surface` | `#121638` | البطاقات والأسطح |
| `card` | `#161B45` | بطاقات الكورسات |
| `starFilled` | `#FFD700` | نجوم التقييم |
| `success` | `#4CAF50` | مجاني، محمي |
| `error` | `#EF5350` | أخطاء |
| `warning` | `#FFA726` | مدفوع، ACU badge |

### الخط

- **Cairo** (Google Fonts) — خط عربي حديث
- أحجام: 10px → 32px
- أوزان: 400 (عادي) → 700 (ثقيل)

### الودجات المشتركة (`shared/widgets/`)

| الودجت | الوصف |
|--------|------|
| `GradientButton` | زر بتدرج أزرق + ظل + حالة تحميل |
| `CourseCard` | بطاقة كورس (صورة + عنوان + محاضر + تقييم + طلاب) |
| `AnimatedBackground` | خلفية بكرات متحركة (Orbs) باستخدام CustomPainter |

---

## 🗺️ التوجيه (Routing)

| المسار | الشاشة | النوع |
|--------|--------|------|
| `/login` | تسجيل الدخول | Auth |
| `/otp` | رمز التحقق | Auth |
| `/access-code` | رمز الدخول | Auth |
| `/onboarding` | إعداد الملف الشخصي | Onboarding |
| `/home` | الرئيسية | Shell Tab |
| `/my-courses` | كورساتي | Shell Tab |
| `/search` | البحث | Shell Tab |
| `/profile` | حسابي | Shell Tab |
| `/course/:id` | تفاصيل الكورس | Full Screen |
| `/video/:courseId/:lessonId` | مشغل الفيديو | Full Screen |

---

## 📦 الحزم المستخدمة

| الحزمة | الإصدار | الغرض |
|--------|---------|------|
| `go_router` | ^15.1.2 | التوجيه والملاحة |
| `google_fonts` | ^6.2.1 | خط Cairo العربي |
| `video_player` | ^2.9.2 | تشغيل الفيديو |
| `chewie` | ^1.8.5 | واجهة مشغل الفيديو |
| `flutter_bloc` | ^9.1.0 | إدارة الحالة |
| `equatable` | ^2.0.7 | مقارنة الكائنات |
| `shared_preferences` | ^2.5.3 | تخزين محلي |
| `cached_network_image` | ^3.4.1 | تحميل الصور |
| `shimmer` | ^3.0.0 | تأثير التحميل |
| `lottie` | ^3.3.1 | رسوم متحركة |
| `flutter_animate` | ^4.5.2 | أنيميشن |
| `smooth_page_indicator` | ^1.2.0+3 | مؤشر الصفحات |
| `intl` | ^0.20.2 | التدويل |

### حزم معلقة (تحتاج إعداد Firebase):

```yaml
# firebase_core: ^3.13.0
# firebase_auth: ^5.6.0
# cloud_firestore: ^5.6.7
```

---

## 🔧 مشاكل تم حلها أثناء البناء

| المشكلة | السبب | الحل |
|---------|------|------|
| `flutter_windowmanager` namespace error | الحزمة قديمة ولا تدعم AGP الحديث | حُذفت — تم استبدالها بـ Platform Channels مخصصة |
| Firebase crash | لا يوجد `google-services.json` | تم تعليق حزم Firebase مؤقتاً |
| Kotlin incremental crash | ملفات المصدر على أقراص مختلفة (C: vs E:) | `kotlin.incremental=false` في gradle.properties |
| Gradle lock timeout | عمليات Java معلقة من بناء سابق فاشل | قتل 6 عمليات Java زومبي |
| OOM / Paging file error | JVM يطلب ذاكرة أكثر من المتاح | خُفض لـ 2GB مع `workers.max=2` |

---

## ✅ قائمة المتطلبات المنفذة

- [x] منع تصوير الشاشة على كل الشاشات (Android FLAG_SECURE)
- [x] اكتشاف ومنع تسجيل الشاشة (iOS isCaptured + overlay أسود)
- [x] رمز الدخول `2026` مطلوب قبل إنشاء الملف الشخصي
- [x] **ACU تظهر أولاً** في قائمة الجامعات مع نجمة ⭐
- [x] **حاسبات ومعلومات تظهر أولاً** في كليات ACU مع نجمة ⭐
- [x] كل الجامعات المصرية مدرجة (44 جامعة) مع كلياتها
- [x] تخطيط عربي RTL في كل الشاشات
- [x] مشغل فيديو بدون زر تحميل
- [x] بيانات الملف الشخصي محفوظة في SharedPreferences
- [x] معالج إعداد سلس (رجوع + شريط تقدم)
- [x] كورسات مقترحة بناءً على الكلية + السنة
- [x] طلاب حاسبات ACU يحصلون على كورسات CS مخصصة
- [x] شاشة رقم الهاتف بالصيغة المصرية (01X-XXXX-XXXX)
- [x] شاشة OTP من 6 أرقام مع عد تنازلي
- [x] Bottom Navigation بـ 4 تبويبات
- [x] بطاقات كورسات أفقية قابلة للتمرير
- [x] شاشة بحث فورية
- [x] شاشة تفاصيل كورس مع المنهج
- [x] سرعات تشغيل الفيديو (0.5x - 2x)
- [x] تسجيل خروج يمسح البيانات

---

## 🚀 تشغيل المشروع

```bash
# تثبيت الحزم
cd e:\proj\Muzakarah
flutter pub get

# بناء APK
flutter build apk --debug

# التشغيل على الجهاز
flutter run --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk
```

---

## 📋 خطوات مستقبلية (لم تُنفذ بعد)

- [ ] ربط Firebase (إضافة google-services.json)
- [ ] مصادقة حقيقية عبر Firebase Auth (OTP فعلي)
- [ ] حفظ بيانات المستخدم في Firestore
- [ ] تحميل الكورسات من قاعدة بيانات
- [ ] نظام دفع للكورسات المدفوعة
- [ ] إشعارات Push Notifications
- [ ] وضع Offline مع تخزين مؤقت
- [ ] تتبع تقدم المشاهدة
- [ ] نظام التقييم والتعليقات
