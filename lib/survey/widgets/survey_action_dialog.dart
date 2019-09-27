import 'package:flutter/material.dart';
import 'package:native_widgets/native_widgets.dart';

surveyActionDialog(BuildContext context, String id, bool active) async {
  showSurveyDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => child,
    );
  }

  return showSurveyDialog<String>(
      context: context,
      child: NativeDialog(
        title: Text('Survey Action'),
        content: Text('Select a action'),
        actions: <NativeDialogAction>[
          NativeDialogAction(
            text: active ? Text('Open') : SizedBox(),
            isDestructive: false,
            onPressed: () {
              Navigator.pop(context, true);
            }
          ),
          NativeDialogAction(
            text: active ? Text('Close', style: TextStyle(color: Colors.red)) : SizedBox(),
            isDestructive: false,
            onPressed: () {
              Navigator.of(context).pop('closed');
            }
          ),
              
          NativeDialogAction(
            text: Text('Cancel', style: TextStyle(color: Colors.black)),
            isDestructive: false,
            onPressed: () {
              Navigator.pop(context);
            }
            
          ),
        ],
      ));
}