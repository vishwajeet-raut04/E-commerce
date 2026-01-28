import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/orders_controller.dart';

class TimeFilterBar extends StatelessWidget {
  TimeFilterBar({super.key});

  final OrdersController orders = Get.find<OrdersController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: TimeFilter.values.map((filter) {
            final selected = orders.selectedFilter.value == filter;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: selected,
                selectedColor: Colors.indigo,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                onSelected: (_) {
                  orders.selectedFilter.value = filter;
                },
              ),
            );
          }).toList(),
        ));
  }
}
