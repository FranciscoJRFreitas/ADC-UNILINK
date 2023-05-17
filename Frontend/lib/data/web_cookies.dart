import "package:universal_html/html.dart";

void setCookie(String name, String value) {
  document.cookie = '$name=$value';
}

String? getCookie(String name) {
  final cookies = document.cookie?.split(';');
  for (final cookie in cookies!) {
    final parts = cookie.split('=');
    final cookieName = parts[0].trim();
    if (parts.length >= 2) {  // Check if there are at least two parts
      final cookieValue = parts[1].trim();
      if (cookieName == name) {
        return cookieValue;
      }
    }
  }
  return null;
}

void deleteCookie(String name) {
  // Get the current cookie value
  String currentValue = getCookie(name)!;

  // Check if the cookie exists
  if (currentValue != 'not_found') {
    // Set the cookie value to an empty string and set the expires attribute to a date in the past
    document.cookie = '$name=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
  }
}

