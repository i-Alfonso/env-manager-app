import 'package:flutter/material.dart';

// Switch element definition.
class FormSwitch extends StatefulWidget {
  final String label;
  final Function(bool)? onChange;

  const FormSwitch({super.key, required this.label, this.onChange});

  @override
  State<FormSwitch> createState() => _SwitchState();
}

class _SwitchState extends State<FormSwitch> {
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.label),
      // This bool value toggles the switch.
      value: enabled,
      activeColor: Colors.green,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          enabled = value;
        });
        if(widget.onChange != null) {
          widget.onChange!(value);
        }
      },
    );
  }
}