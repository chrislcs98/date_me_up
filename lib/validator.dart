class Validator {
  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    if (email.isEmpty) {
      return '     Email can\'t be empty';
    } else if (!emailRegExp.hasMatch(email)) {
      return '     Enter a valid email';
    }

    return null;
  }

  static String? validatePassword({required String? password}) {
    if (password == null) {
      return null;
    }
    if (password.isEmpty) {
      return '     Password can\'t be empty';
    } else if (password.length < 6) {
      return '     Enter a password with length at least 6';
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      return "     Password must contain a number";
    } else if (!password.contains(RegExp(r'[a-zA-Z]'))) {
      return "     Password must contain a letter";
    }

    return null;
  }

  static String? validateText({required String? text, required String name}) {
    // if (email == null) {
    //   return null;
    // }

    if (text == null || text.isEmpty) {
      return '$name can\'t be empty';
    } else if (text.contains(RegExp(r"[!#$%&'*+/=?^_`{|}~]"))) {
      return 'Enter a valid $name without symbols';
    }

    return null;
  }

  static String? validateAge({required String? age, String? minAge = ""}) {
    if (age == null || age.isEmpty) {
      return null;
    }

    RegExp ageRegExp = RegExp(r"^[1-9][0-9]{1,2}");
    if (ageRegExp.hasMatch(age)) {
      if (int.parse(age) < 18) return '> 18';

      if ((minAge != null && minAge.isNotEmpty) && (int.parse(age) < int.parse(minAge))) return '>= Min';
    } else {
      return 'Number';
    }

    return null;
  }
}