// This is a stub file that is used for non-web platforms.
// It provides empty implementations of the classes and methods from dart:html
// that we're using in our code.

// We don't need to implement anything here as this file will only be imported
// on non-web platforms and the code paths that would use these implementations
// are protected by kIsWeb checks.

class FileUploadInputElement {
  String accept = '';
  void click() {}
  Stream<dynamic> get onChange => throw UnimplementedError();
  List<dynamic>? get files => null;
}

class FileReader {
  void readAsArrayBuffer(dynamic file) {}
  dynamic result;
  Stream<dynamic> get onLoadEnd => throw UnimplementedError();
}

class Completer<T> {
  Future<T> get future => throw UnimplementedError();
  void complete(T value) {}
  void completeError(dynamic error) {}
}