import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/medicine.dart';
import '../services/database_service.dart';

/// Search + pagination state for the medicine database screen.
class MedicineDbController extends GetxController {
  static const int pageSize = 30;

  final RxList<Medicine> medicines = <Medicine>[].obs;
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool searching = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt total = 0.obs;
  final RxString query = ''.obs;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Timer? _debounce;
  int _offset = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    load();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final double remaining =
        scrollController.position.maxScrollExtent - scrollController.offset;
    if (remaining < 320) loadMore();
  }

  /// Debounced so a fast typist does not run a query per keystroke.
  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 260), () {
      search(value);
    });
  }

  void toggleSearch() {
    searching.toggle();
    if (!searching.value) {
      _debounce?.cancel();
      searchController.clear();
      search('');
    }
  }

  Future<void> search(String value) async {
    query.value = value.trim();
    await load();
  }

  Future<void> load() async {
    loading.value = true;
    _offset = 0;
    try {
      final List<Medicine> page = await DatabaseService.instance.searchBrands(
        query: query.value,
        limit: pageSize,
        offset: 0,
      );
      medicines.assignAll(page);
      hasMore.value = page.length == pageSize;
      if (query.value.isNotEmpty) {
        total.value = await DatabaseService.instance.countBrands(query: query.value);
      } else {
        total.value = DatabaseService.instance.brandCount;
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (loading.value || loadingMore.value || !hasMore.value) return;
    loadingMore.value = true;
    _offset += pageSize;
    try {
      final List<Medicine> page = await DatabaseService.instance.searchBrands(
        query: query.value,
        limit: pageSize,
        offset: _offset,
      );
      if (page.isEmpty) {
        hasMore.value = false;
        return;
      }
      medicines.addAll(page);
      if (page.length < pageSize) hasMore.value = false;
    } finally {
      loadingMore.value = false;
    }
  }
}
