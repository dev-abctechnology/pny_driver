class CPF {
  static String mask(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'(\d{3})(\d{3})(\d{3})(\d{2})'),
          (match) => '${match[1]}.${match[2]}.${match[3]}-${match[4]}',
        )
        .replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String unmask(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isValid(String value) {
    if (value.isEmpty) return false;

    final unmasked = unmask(value);
    if (unmasked.length != 11) return false;

    final numbers = unmasked.split('').map(int.parse).toList();
    final firstDigit = numbers[9];
    final secondDigit = numbers[10];

    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }

    var mod = sum % 11;
    if (mod < 2) {
      mod = 0;
    } else {
      mod = 11 - mod;
    }

    if (mod != firstDigit) return false;

    sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }

    mod = sum % 11;
    if (mod < 2) {
      mod = 0;
    } else {
      mod = 11 - mod;
    }

    return mod == secondDigit;
  }
}
