class Validator {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email adresi gereklidir';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email adresi giriniz';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim gereklidir';
    }

    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalıdır';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String fieldName = 'Bu alan'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }
    return null;
  }

  // Title validation
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Başlık gereklidir';
    }

    if (value.length < 3) {
      return 'Başlık en az 3 karakter olmalıdır';
    }

    if (value.length > 100) {
      return 'Başlık en fazla 100 karakter olabilir';
    }

    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Açıklama gereklidir';
    }

    if (value.length < 10) {
      return 'Açıklama en az 10 karakter olmalıdır';
    }

    if (value.length > 500) {
      return 'Açıklama en fazla 500 karakter olabilir';
    }

    return null;
  }

  // Phone number validation (Turkish format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gereklidir';
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Geçerli bir telefon numarası giriniz (10 haneli)';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Geçerli bir URL giriniz';
    }

    return null;
  }

  // Number validation
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu alan gereklidir';
    }

    if (int.tryParse(value) == null) {
      return 'Geçerli bir sayı giriniz';
    }

    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(String? value) {
    final numberValidation = validateNumber(value);
    if (numberValidation != null) {
      return numberValidation;
    }

    if (int.parse(value!) <= 0) {
      return 'Pozitif bir sayı giriniz';
    }

    return null;
  }

  // Date validation (not in past)
  static String? validateFutureDate(DateTime? date) {
    if (date == null) {
      return 'Tarih gereklidir';
    }

    if (date.isBefore(DateTime.now())) {
      return 'Geçmiş bir tarih seçemezsiniz';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gereklidir';
    }

    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }
}
