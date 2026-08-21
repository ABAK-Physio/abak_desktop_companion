import 'package:flutter/material.dart';

class TableHeader extends StatelessWidget {
  final List<Widget> columns;

  const TableHeader({
    super.key,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
        fontWeight: FontWeight.w600,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Row(children: columns),
      ),
    );
  }
}