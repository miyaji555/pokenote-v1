import 'package:flutter/material.dart';

class TutorialWidget extends StatelessWidget {
  const TutorialWidget(
      {super.key,
      required this.onTap,
      required this.show,
      required this.child});
  final VoidCallback onTap;
  final bool show;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: show,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: InkWell(
            onTap: onTap,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
