import 'package:flutter/material.dart';

class ExpandedComponent extends StatelessWidget {
  // final Function onLongPress;
  final List<Widget> children;

  const ExpandedComponent({
    super.key,
    // required this.onLongPress,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        // onLongPress: () => onLongPress(),
        child: PageView(
          scrollDirection: Axis.vertical,
          children: children,
        ),
      ),
    );
  }
}
