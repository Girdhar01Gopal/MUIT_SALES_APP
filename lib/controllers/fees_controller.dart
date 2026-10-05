import 'package:get/get.dart';
import 'package:muit_sales_app/models/fees_model.dart';
import 'package:muit_sales_app/repo/fees_repo.dart';

class FeesController extends GetxController {
  final FeesRepo _repo = FeesRepo();

  final RxList<FeesModel> fees = <FeesModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString search = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFees();
  }

  Future<void> fetchFees() async {
    try {
      isLoading.value = true;
      fees.value = await _repo.getFees();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load fees');
    } finally {
      isLoading.value = false;
    }
  }

  List<FeesModel> get filteredFees {
    final q = search.value.toLowerCase().trim();
    if (q.isEmpty) return fees.toList();
    return fees.where((f) => f.course.toLowerCase().contains(q)).toList();
  }
}