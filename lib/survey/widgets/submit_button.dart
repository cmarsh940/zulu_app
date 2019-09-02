import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback _onPressed;
  final bool isEditing;

  SubmitButton({Key key, VoidCallback onPressed, this.isEditing})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
      child: isEditing ? Text('Submit') : Text('Create'),
    );
  }
}