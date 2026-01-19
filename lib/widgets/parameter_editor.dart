import 'package:flutter/material.dart';
import '../models/effect_mode.dart';

class ParameterEditor extends StatelessWidget {
  final EffectParameter parameter;
  final dynamic value;
  final Function(dynamic) onChanged;

  const ParameterEditor({
    super.key,
    required this.parameter,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildEditor(context),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    switch (parameter.type) {
      case ParameterType.integer:
        return _buildIntegerEditor(context);
      case ParameterType.decimal:
        return _buildDecimalEditor(context);
      case ParameterType.boolean:
        return _buildBooleanEditor(context);
      case ParameterType.dropdown:
        return _buildDropdownEditor(context);
      case ParameterType.text:
        return _buildTextEditor(context);
    }
  }

  Widget _buildIntegerEditor(BuildContext context) {
    final intValue = (value as num?)?.toInt() ?? parameter.defaultValue as int;
    final min = (parameter.minValue as num?)?.toDouble() ?? 0;
    final max = (parameter.maxValue as num?)?.toDouble() ?? 100;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: intValue.toDouble().clamp(min, max),
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: (v) => onChanged(v.toInt()),
              ),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                intValue.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toInt().toString(),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              max.toInt().toString(),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDecimalEditor(BuildContext context) {
    final doubleValue = (value as num?)?.toDouble() ?? parameter.defaultValue as double;
    final min = (parameter.minValue as num?)?.toDouble() ?? 0.0;
    final max = (parameter.maxValue as num?)?.toDouble() ?? 1.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: doubleValue.clamp(min, max),
                min: min,
                max: max,
                onChanged: (v) => onChanged(double.parse(v.toStringAsFixed(2))),
              ),
            ),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                doubleValue.toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(1),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              max.toStringAsFixed(1),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBooleanEditor(BuildContext context) {
    final boolValue = value as bool? ?? parameter.defaultValue as bool;

    return Row(
      children: [
        Switch(
          value: boolValue,
          onChanged: onChanged,
        ),
        const SizedBox(width: 8),
        Text(
          boolValue ? 'Enabled' : 'Disabled',
          style: TextStyle(
            fontSize: 12,
            color: boolValue ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownEditor(BuildContext context) {
    final stringValue = value as String? ?? parameter.defaultValue as String;
    final options = parameter.options ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: stringValue,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: const Color(0xFF2A2A2A),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _buildTextEditor(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value as String? ?? parameter.defaultValue as String),
      decoration: InputDecoration(
        hintText: 'Enter ${parameter.name.toLowerCase()}...',
        isDense: true,
      ),
      style: const TextStyle(fontSize: 13),
      onChanged: onChanged,
    );
  }
}
