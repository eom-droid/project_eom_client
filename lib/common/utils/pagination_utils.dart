import 'package:flutter/material.dart';
import 'package:client/common/const/setting.dart';
import 'package:client/common/provider/pagination_provider.dart';

class PaginationUtils {
  static void paginate({
    required ScrollController controller,
    required PaginationProvider provider,
  }) {
    if (controller.position.maxScrollExtent == 0 ||
        controller.position.maxScrollExtent <= GAP_WHEN_PAGINATE) return;
    if (controller.offset >
        controller.position.maxScrollExtent - GAP_WHEN_PAGINATE) {
      provider.paginate(
        fetchMore: true,
      );
    }
  }
}
