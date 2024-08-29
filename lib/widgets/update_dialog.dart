import 'package:flutter/material.dart';
import 'package:hive_ui/core/screen_utils.dart';

import '../services/flutter_clipboard_hive_ui.dart';
import 'update_dialog_type_picker.dart';

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> objectAsJson;
  final String fieldName;
  final String? dateFormat;

  const UpdateDialog({
    Key? key,
    required this.objectAsJson,
    required this.fieldName,
    this.dateFormat,
  }) : super(key: key);

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  Map<String, dynamic> get jsonObject => widget.objectAsJson;
  UpdateDialogType fieldType = UpdateDialogType.string;
  late TextEditingController _controller;
  bool booleanFieldValue = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onTypeChanged(UpdateDialogType? type) {
    if (type == UpdateDialogType.bool) {
      booleanFieldValue = false;
    }
    setState(() => fieldType = type!);
  }

  Future<void> onFormFieldTapped() async {
    if (fieldType == UpdateDialogType.datePicker) {
      final currentDate = jsonObject[widget.fieldName];
      late DateTime initialDate;

      if (currentDate != null && currentDate.isNotEmpty) {
        initialDate = DateTime.parse(currentDate.replaceAll("/", "-"));
      } else {
        initialDate = DateTime.now();
      }
      final datePicked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(
          const Duration(days: 30 * 4),
        ),
      );
      if (datePicked != null) {
        // _controller.text =
        //     widget.dateFormat?.format(datePicked) ?? datePicked.toString();
        _controller.text = datePicked.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Container(
          // constraints: BoxConstraints.loose(
          //   Size(
          //     mediaQuerySize.width * 0.5,
          //     mediaQuerySize.height * 0.6,
          //   ),
          // ),
          child: _MobileView(
        jsonObject: jsonObject,
        fieldName: widget.fieldName,
        fieldType: fieldType,
        onTypeChanged: onTypeChanged,
        onFormFieldTapped: onFormFieldTapped,
        controller: _controller,
        setBooleanFieldValue: (value) => setState(() {
          booleanFieldValue = value;
        }),
        booleanFieldValue: booleanFieldValue,
      )),
    );
  }
}

class _MobileView extends StatelessWidget {
  final Map<String, dynamic> jsonObject;
  final String fieldName;
  final UpdateDialogType fieldType;
  final void Function(UpdateDialogType?) onTypeChanged;
  final Future<void> Function() onFormFieldTapped;
  final TextEditingController controller;
  final void Function(bool) setBooleanFieldValue;
  final bool booleanFieldValue;
  const _MobileView({
    Key? key,
    required this.jsonObject,
    required this.fieldName,
    required this.fieldType,
    required this.onTypeChanged,
    required this.onFormFieldTapped,
    required this.controller,
    required this.setBooleanFieldValue,
    required this.booleanFieldValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Size buttonSize() {
    //   if (ScreenUtils.instance.isDesktopScreen) {
    //     return const Size(125, 42);
    //   } else {
    //     return const Size(75, 42);
    //   }
    // }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              ListTile(
                title: Text(
                  "Edit ${fieldName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    // fontSize: 18,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Divider(),
            ],
          ),
          // const SizedBox(height: 24),
          // UpdateDialogTypePicker(
          //   selectedType: fieldType,
          //   onTypeChanged: onTypeChanged,
          // ),
          const SizedBox(height: 10),
          Flexible(
            child: Padding(
              // padding: const EdgeInsets.symmetric(horizontal: 32.0),
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      readOnly: true,
                      enabled: false,
                      textAlign: TextAlign.center,
                      initialValue: jsonObject[fieldName].toString(),
                      decoration: InputDecoration(
                        label: const Text('Old Value'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (fieldType != UpdateDialogType.bool)
                    Flexible(
                      child: TextField(
                        readOnly: fieldType == UpdateDialogType.datePicker,
                        onTap: () async => await onFormFieldTapped(),
                        controller: controller,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          label: const Text('New Value'),
                          hintText: 'New Value',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: DropdownButtonFormField<bool>(
                        items: [true, false]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toString()),
                                ))
                            .toList(),
                        onChanged: (value) => setBooleanFieldValue(value!),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                        )),
                      ),
                    )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     fixedSize: buttonSize(),
                    //     elevation: 0,
                    //     backgroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: const BorderRadius.all(
                    //         Radius.circular(12),
                    //       ),
                    //       side: BorderSide(
                    //         color: Theme.of(context).primaryColor,
                    //       ),
                    //     ),
                    //   ),
                    //   onPressed: () {
                    //     FlutterClipboardHiveUi.copy(
                    //       jsonObject[fieldName].toString(),
                    //     );
                    //   },
                    //   child: FittedBox(
                    //     child: Text(
                    //       'Copy Value',
                    //       style: TextStyle(
                    //         color: Theme.of(context).primaryColor,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // fixedSize: buttonSize(),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Object updatedValue;
                        switch (fieldType) {
                          case UpdateDialogType.datePicker:
                            updatedValue = controller.text;
                            break;
                          case UpdateDialogType.string:
                            updatedValue = controller.text;
                            break;
                          case UpdateDialogType.num:
                            updatedValue = num.parse(controller.text);
                            break;
                          case UpdateDialogType.bool:
                            updatedValue = booleanFieldValue;
                            break;
                        }
                        jsonObject[fieldName] = updatedValue;
                        Navigator.pop(context, jsonObject);
                      },
                      child: const FittedBox(child: Text('Confirm')),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

enum UpdateDialogType {
  datePicker,
  string,
  num,
  bool,
}

