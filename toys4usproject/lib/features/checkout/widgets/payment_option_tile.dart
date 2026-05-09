import 'package:flutter/material.dart';

const Color brandColor = Color(0xFF7B1FA2);

class PaymentOptionTile extends StatelessWidget {
  final String value;
  final IconData icon;
  final String selectedMethod;
  final ValueChanged<String> onSelect;

  const PaymentOptionTile({
    super.key,
    required this.value,
    required this.icon,
    required this.selectedMethod,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedMethod == value;

    return Card(
      elevation: 0,
      color: selected ? const Color(0xFFF1E5F6) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? brandColor : Colors.grey.shade200,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => onSelect(value),
        leading: Icon(icon, color: selected ? brandColor : Colors.grey),
        title:
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? brandColor : Colors.grey,
        ),
      ),
    );
  }
}