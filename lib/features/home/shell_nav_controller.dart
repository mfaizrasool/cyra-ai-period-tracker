import 'package:get/get.dart';

/// Drives bottom navigation index so other screens can switch tabs (e.g. Home → Log).
class ShellNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void goToTab(int index) {
    if (index < 0 || index > 4) return;
    currentIndex.value = index;
  }
}
