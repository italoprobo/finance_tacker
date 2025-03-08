class Validator {
  Validator._();

  static String? validateName(String? value) {

    if (value == null || value.isEmpty) {
      return "Esse campo não pode ser vazio.";
    }
    return null;
  }

  static String? validateEmail(String? value) {

    if (value == null || value.isEmpty) {
      return "O e-mail não pode estar vazio.";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "A senha não pode estar vazia.";
    }
    if (value.length < 6) {
      return "A senha deve ter pelo menos 6 caracteres.";
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return "Confirme sua senha.";
    }
    if (value != password) {
      return "As senhas não coincidem.";
    }
    return null;
  }
}
