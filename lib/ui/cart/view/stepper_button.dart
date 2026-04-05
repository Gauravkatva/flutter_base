import 'package:flutter/material.dart';

class StepperButton extends StatelessWidget {
  const StepperButton({required this.icon, required this.onPressed, super.key});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.black,
      ),
    );
  }
}
