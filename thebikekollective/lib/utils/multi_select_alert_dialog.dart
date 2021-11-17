import 'package:flutter/material.dart';

// Sourced and heavily adapted (Flutter 2.0 -> 3.0) from:
// https://stackoverflow.com/questions/51975690/is-there-an-equivalent-widget-in-flutter-to-the-select-multiple-element-in-htm

class MultiSelectDialogItem {
  int value;
  String filter;
  MultiSelectDialogItem({
    required this.value,
    required this.filter,
  });
}

class MultiSelectAlertDialog extends StatefulWidget {
  final List<MultiSelectDialogItem> items;
  final Set<int>? initiallyChecked;

  MultiSelectAlertDialog(
      {Key? key, required this.items, required this.initiallyChecked})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectAlertDialogState();
}

class _MultiSelectAlertDialogState extends State<MultiSelectAlertDialog> {
  final _selectedFilters = Set<int>();

  void initState() {
    super.initState();
    if (widget.initiallyChecked != null) {
      for (var indexChecked in widget.initiallyChecked!) {
        _selectedFilters.add(indexChecked);
      }
    }
  }

  void _onItemCheckedChange(int filterValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedFilters.add(filterValue);
      } else {
        _selectedFilters.remove(filterValue);
      }
    });
  }

  void _onCancelTap() {
    _selectedFilters.clear();
    Navigator.pop(context, _selectedFilters);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Tags to Filter'),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('Reset'),
          onPressed: _onCancelTap,
        ),
        ElevatedButton(
          child: Text('Filter'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem item) {
    final checked = _selectedFilters.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: Text(item.filter),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked!),
    );
  }
}
