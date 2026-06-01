// CRM shared constants, colours, and reusable widgets for all CRM screens.
import 'package:flutter/material.dart';

const kPrimary    = Color(0xFF36617E);
const kPrimaryLight = Color(0xFFEBF2F7);
const kBg         = Color(0xFFF5F7FA);
const kCard       = Colors.white;
const kText       = Color(0xFF1F2937);
const kSubText    = Color(0xFF6B7280);
const kBorder     = Color(0xFFE5E7EB);

// ── Stat card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11, color: kSubText, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
          if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: const TextStyle(fontSize: 11, color: kSubText))],
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
        if (action != null)
          GestureDetector(onTap: onAction, child: Text(action!, style: const TextStyle(fontSize: 13, color: kPrimary, fontWeight: FontWeight.w600))),
      ],
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }
}

// ── Avatar initials ───────────────────────────────────────────────────────────
class AvatarInitials extends StatelessWidget {
  final String name;
  final double radius;
  final Color? bg;
  const AvatarInitials({super.key, required this.name, this.radius = 20, this.bg});

  @override
  Widget build(BuildContext context) {
    final words = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    final initials = words.take(2).map((w) => w[0].toUpperCase()).join();
    final palette = [const Color(0xFF36617E), Colors.purple, Colors.teal, Colors.orange, Colors.green, Colors.red, Colors.indigo];
    final c = name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length;
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg ?? palette[c].withValues(alpha: 0.2),
      child: Text(initials, style: TextStyle(color: bg != null ? Colors.white : palette[c], fontWeight: FontWeight.bold, fontSize: radius * 0.75)),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
class CrmSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const CrmSearchBar({super.key, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kSubText, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: kSubText, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ── Tab button ────────────────────────────────────────────────────────────────
class CrmTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const CrmTabButton({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : kSubText, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
      ),
    );
  }
}

// ── AppBar helper ─────────────────────────────────────────────────────────────
PreferredSizeWidget crmAppBar(BuildContext context, String title, {List<Widget>? actions}) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.white,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kText),
      onPressed: () => Navigator.maybePop(context),
    ),
    title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
    actions: actions,
    bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: kBorder)),
  );
}
