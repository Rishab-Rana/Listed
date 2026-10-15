/// The login field contains the national number; +91 is displayed separately.
bool isValidIndianMobileNumber(String value) {
  return RegExp(r'^[6-9][0-9]{9}$').hasMatch(value.trim());
}
