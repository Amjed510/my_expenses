# مصروفاتي - تطبيق إدارة المصروفات الشخصية 💰

<div dir="rtl">

[![Flutter Version](https://img.shields.io/badge/Flutter-3.5.4-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.0.0-blue.svg)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

تطبيق "مصروفاتي" هو حل متكامل لإدارة المصروفات الشخصية، مصمم بواجهة مستخدم عربية سهلة الاستخدام ومميزات متقدمة لتتبع وتحليل مصروفاتك اليومية.

## 🌟 المميزات الرئيسية

### 📊 إدارة المصروفات
- إضافة وتعديل وحذف المصروفات
- تصنيف المصروفات حسب الفئات
- عرض تفاصيل المصروفات اليومية والشهرية
- البحث المتقدم في المصروفات

### 💹 التحليلات والإحصائيات
- رسوم بيانية تفاعلية
- تقارير شهرية وسنوية
- تحليل الإنفاق حسب الفئات
- مؤشرات الأداء المالي

### 💰 إدارة الميزانية
- تحديد ميزانية شهرية
- تتبع الإنفاق مقابل الميزانية
- تنبيهات عند تجاوز الميزانية
- تخطيط مالي ذكي

### 👤 إدارة الحساب
- تسجيل الدخول وإنشاء حساب
- تعديل الملف الشخصي
- تغيير كلمة المرور
- إدارة الإعدادات الشخصية

### 🎨 تخصيص التطبيق
- دعم الوضع الداكن/الفاتح
- تخصيص الثيم
- واجهة مستخدم عربية بالكامل
- تصميم عصري وجذاب

## 🛠️ التقنيات المستخدمة

- **Flutter**: إطار عمل واجهة المستخدم
- **Provider**: إدارة حالة التطبيق
- **SQLite**: قاعدة البيانات المحلية
- **FL Chart**: الرسوم البيانية
- **Lottie**: الرسوم المتحركة
- **Shared Preferences**: تخزين الإعدادات
- **Google Fonts**: الخطوط العربية

## 📱 متطلبات التشغيل

- Flutter SDK >= 3.5.4
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Android SDK / Xcode (للتطوير)

## ⚙️ التثبيت والإعداد

1. تثبيت Flutter SDK:
```bash
git clone https://github.com/flutter/flutter.git
```

2. استنساخ المشروع:
```bash
git clone https://github.com/yourusername/my_expenses.git
cd my_expenses
```

3. تثبيت التبعيات:
```bash
flutter pub get
```

4. تشغيل التطبيق:
```bash
flutter run
```

## 📁 هيكل المشروع

```
lib/
├── constants/      # الثوابت والأنماط
├── database/       # قاعدة البيانات
├── models/         # نماذج البيانات
├── providers/      # مزودي الحالة
├── screens/        # شاشات التطبيق
├── services/       # الخدمات
├── utils/          # الأدوات المساعدة
└── widgets/        # المكونات القابلة لإعادة الاستخدام
```

## 📚 التوثيق التفصيلي

### 🎯 نظرة عامة على هيكلية الكود

#### 1. نماذج البيانات (Models)
- **`lib/models/expense_model.dart`**
  ```dart
  class Expense {
    final int? id;
    final String title;
    final double amount;
    final DateTime date;
    final int categoryId;
    // ... المزيد من الخصائص والأساليب
  }
  ```
  يمثل نموذج المصروفات مع جميع البيانات المطلوبة.

- **`lib/models/category_model.dart`**
  ```dart
  class Category {
    final int id;
    final String name;
    final IconData icon;
    final Color color;
    // ... المزيد من الخصائص
  }
  ```
  يمثل فئات المصروفات مع الأيقونات والألوان.

#### 2. مزودي الحالة (Providers)
- **`lib/providers/expenses_provider.dart`**
  ```dart
  class ExpensesProvider extends ChangeNotifier {
    List<Expense> _expenses = [];
    double _totalAmount = 0;
    
    // جلب المصروفات من قاعدة البيانات
    Future<void> fetchExpenses() async { ... }
    
    // إضافة مصروف جديد
    Future<void> addExpense(Expense expense) async { ... }
    
    // تحديث مصروف
    Future<void> updateExpense(Expense expense) async { ... }
    
    // حذف مصروف
    Future<void> deleteExpense(int id) async { ... }
  }
  ```

- **`lib/providers/budget_provider.dart`**
  ```dart
  class BudgetProvider extends ChangeNotifier {
    double _monthlyBudget = 0;
    double _remainingBudget = 0;
    
    // تحديث الميزانية الشهرية
    Future<void> updateBudget(double amount) async { ... }
    
    // حساب الميزانية المتبقية
    void calculateRemainingBudget() { ... }
  }
  ```

### 🖥️ الشاشات الرئيسية وعملها

#### 1. الشاشة الرئيسية (HomeScreen)
**الملف**: `lib/screens/home_screen.dart`
```dart
class HomeScreen extends StatelessWidget {
  // عرض الملخص والإحصائيات
  // عرض المصروفات الأخيرة
  // عرض الرسوم البيانية
}
```
**المميزات**:
- عرض إجمالي المصروفات الشهرية
- عرض الميزانية المتبقية
- رسم بياني دائري للمصروفات حسب الفئات
- قائمة بآخر 5 مصروفات
- زر سريع لإضافة مصروف جديد

#### 2. شاشة المصروفات (ExpensesScreen)
**الملف**: `lib/screens/expenses_screen.dart`
```dart
class ExpensesScreen extends StatelessWidget {
  // عرض قائمة المصروفات
  // فلترة وبحث
  // ترتيب حسب التاريخ/المبلغ
}
```
**المميزات**:
- عرض جميع المصروفات في قائمة
- إمكانية الفلترة حسب:
  * التاريخ
  * الفئة
  * المبلغ
- خيارات الترتيب المتعددة
- إمكانية التعديل والحذف السريع

#### 3. شاشة إضافة/تعديل المصروف (AddExpenseScreen)
**الملف**: `lib/screens/add_expense_screen.dart`
```dart
class AddExpenseScreen extends StatefulWidget {
  // نموذج إدخال المصروف
  // اختيار الفئة والتاريخ
  // التحقق من صحة المدخلات
}
```
**المميزات**:
- نموذج متكامل لإدخال البيانات
- اختيار الفئة من قائمة منسدلة
- اختيار التاريخ باستخدام DatePicker
- التحقق من صحة المدخلات مباشرة

#### 4. شاشة الإحصائيات (StatisticsScreen)
**الملف**: `lib/screens/statistics_screen.dart`
```dart
class StatisticsScreen extends StatelessWidget {
  // عرض الرسوم البيانية
  // تحليل المصروفات
  // تقارير شهرية
}
```
**المميزات**:
- رسوم بيانية متعددة:
  * مخطط دائري للفئات
  * مخطط خطي للمصروفات اليومية
  * مخطط أعمدة للمقارنة الشهرية
- تقارير تفصيلية PDF
- مشاركة التقارير

### 🛠️ المكونات الرئيسية (Widgets)

#### 1. قائمة المصروفات (ExpenseList)
**الملف**: `lib/widgets/expense_list.dart`
```dart
class ExpenseList extends StatelessWidget {
  // عرض قائمة المصروفات
  // تحديث تلقائي
  // سحب للتحديث
}
```

#### 2. بطاقة المصروف (ExpenseCard)
**الملف**: `lib/widgets/expense_card.dart`
```dart
class ExpenseCard extends StatelessWidget {
  // عرض تفاصيل المصروف
  // أزرار التعديل والحذف
  // حركات التفاعل
}
```

### 📊 قاعدة البيانات

#### 1. مساعد قاعدة البيانات (DatabaseHelper)
**الملف**: `lib/database/database_helper.dart`
```dart
class DatabaseHelper {
  // إنشاء قاعدة البيانات
  // ترقية الإصدار
  // عمليات CRUD الأساسية
}
```

#### 2. واجهة الوصول للبيانات (DAO)
**الملف**: `lib/database/expense_dao.dart`
```dart
class ExpenseDao {
  // عمليات المصروفات
  // استعلامات مخصصة
  // تحويل البيانات
}
```

### 🔧 الخدمات المساعدة

#### 1. معالجة التواريخ (DateService)
**الملف**: `lib/services/date_service.dart`
```dart
class DateService {
  // تنسيق التواريخ
  // حساب الفترات
  // تحويل التواريخ
}
```

#### 2. تنسيق العملة (CurrencyService)
**الملف**: `lib/services/currency_service.dart`
```dart
class CurrencyService {
  // تنسيق المبالغ
  // تحويل العملات
  // رموز العملات
}
```

### 🎨 الثيم والتصميم

#### 1. ألوان التطبيق
**الملف**: `lib/constants/app_colors.dart`
```dart
class AppColors {
  // ألوان الثيم الرئيسية
  // ألوان الفئات
  // تدرجات الألوان
}
```

#### 2. أنماط التطبيق
**الملف**: `lib/constants/app_styles.dart`
```dart
class AppStyles {
  // أنماط النصوص
  // أنماط البطاقات
  // الهوامش والمسافات
}
```

### 📱 دورة حياة التطبيق

1. **بدء التطبيق**:
   - تهيئة قاعدة البيانات
   - تحميل الإعدادات المحفوظة
   - تهيئة مزودي الحالة

2. **إدارة الحالة**:
   - استخدام Provider للتحكم في حالة التطبيق
   - تحديث واجهة المستخدم تلقائياً
   - حفظ التغييرات في قاعدة البيانات

3. **التفاعل مع المستخدم**:
   - معالجة الإدخال
   - التحقق من صحة البيانات
   - عرض رسائل التأكيد والخطأ

4. **إدارة البيانات**:
   - مزامنة البيانات مع قاعدة البيانات
   - تخزين الإعدادات المحلية
   - النسخ الاحتياطي واستعادة البيانات

## 🤝 المساهمة

نرحب بمساهماتكم! إذا كنت ترغب في المساهمة:

1. Fork المشروع
2. إنشاء فرع للميزة الجديدة
3. Commit التغييرات
4. Push إلى الفرع
5. فتح Pull Request

## 📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.

## 📧 التواصل

- البريد الإلكتروني: your.email@example.com
- تويتر: [@yourusername](https://twitter.com/yourusername)
- لينكد إن: [Your Name](https://linkedin.com/in/yourusername)

## 🌟 شكر خاص

شكر خاص لكل المساهمين والداعمين لهذا المشروع.

</div>
