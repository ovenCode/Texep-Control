import 'dart:developer';

T tryCast<T>(dynamic x, {required T fallback}) {
  try {
    return (x as T);
  } on TypeError catch (e) {
    log("TypeError: Error casting $x to type $T");
    log(e.toString());
    return fallback;
  }
}
