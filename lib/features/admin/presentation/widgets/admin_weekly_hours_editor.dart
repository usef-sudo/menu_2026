import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:menu_2026/features/branches/data/models/branch_opening_hour_dto.dart";
import "package:menu_2026/l10n/app_localizations.dart";

/// Per-day row: [dayOfWeek] 1 = Monday … 7 = Sunday.
class AdminWeeklyHoursEditor extends StatefulWidget {
  const AdminWeeklyHoursEditor({
    super.key,
    this.initial,
    this.showApplyMondayButton = true,
  });

  final List<BranchOpeningHourDto>? initial;
  final bool showApplyMondayButton;

  @override
  AdminWeeklyHoursEditorState createState() => AdminWeeklyHoursEditorState();
}

class AdminWeeklyHoursEditorState extends State<AdminWeeklyHoursEditor> {
  static final RegExp _hm = RegExp(r"^([01]?\d|2[0-3]):([0-5]\d)$");

  late final List<bool> _closed;
  late final List<TextEditingController> _open;
  late final List<TextEditingController> _close;
  late final List<bool> _overnight;

  @override
  void initState() {
    super.initState();
    _closed = List<bool>.generate(7, (_) => false);
    _open = List<TextEditingController>.generate(
      7,
      (_) => TextEditingController(text: "11:00"),
    );
    _close = List<TextEditingController>.generate(
      7,
      (_) => TextEditingController(text: "22:00"),
    );
    _overnight = List<bool>.generate(7, (_) => false);

    final List<BranchOpeningHourDto>? init = widget.initial;
    if (init != null && init.isNotEmpty) {
      for (int i = 0; i < 7; i++) {
        _closed[i] = true;
      }
      for (final BranchOpeningHourDto h in init) {
        if (h.slotIndex != 0) continue;
        final int idx = h.dayOfWeek - 1;
        if (idx < 0 || idx > 6) continue;
        _closed[idx] = false;
        _open[idx].text = h.openTime;
        _close[idx].text = h.closeTime;
        _overnight[idx] = h.closesNextDay;
      }
    }
  }

  @override
  void dispose() {
    for (final TextEditingController c in _open) {
      c.dispose();
    }
    for (final TextEditingController c in _close) {
      c.dispose();
    }
    super.dispose();
  }

  String _weekdayShort(BuildContext context, int dayOfWeek) {
    final DateTime anchor = DateTime(2024, 1, dayOfWeek);
    return DateFormat.E(
      Localizations.localeOf(context).toString(),
    ).format(anchor);
  }

  void _applyMondayToAll() {
    setState(() {
      for (int i = 1; i < 7; i++) {
        _closed[i] = _closed[0];
        _open[i].text = _open[0].text;
        _close[i].text = _close[0].text;
        _overnight[i] = _overnight[0];
      }
    });
  }

  /// Empty list clears all stored slots on the server.
  List<Map<String, dynamic>> collectPayload() {
    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
    for (int i = 0; i < 7; i++) {
      if (_closed[i]) continue;
      final String open = _open[i].text.trim();
      final String close = _close[i].text.trim();
      if (open.isEmpty || close.isEmpty) continue;
      out.add(<String, dynamic>{
        "dayOfWeek": i + 1,
        "slotIndex": 0,
        "openTime": open,
        "closeTime": close,
        "closesNextDay": _overnight[i],
      });
    }
    return out;
  }

  /// Returns null if valid, or first error message.
  String? validate(AppLocalizations l10n) {
    for (int i = 0; i < 7; i++) {
      if (_closed[i]) continue;
      final String open = _open[i].text.trim();
      final String close = _close[i].text.trim();
      if (open.isEmpty || close.isEmpty) {
        return l10n.adminWeeklyHoursTimeRequired;
      }
      if (!_hm.hasMatch(open) || !_hm.hasMatch(close)) {
        return l10n.adminWeeklyHoursTimeFormat;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.adminWeeklyHoursSectionTitle,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.adminWeeklyHoursHint,
          style: theme.textTheme.bodySmall,
        ),
        if (widget.showApplyMondayButton) ...<Widget>[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: _applyMondayToAll,
              child: Text(l10n.adminWeeklyHoursCopyMonday),
            ),
          ),
        ],
        const SizedBox(height: 8),
        for (int i = 0; i < 7; i++) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 44,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _weekdayShort(context, i + 1),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(l10n.adminWeeklyHoursClosedThisDay),
                      value: _closed[i],
                      onChanged: (bool v) => setState(() => _closed[i] = v),
                    ),
                    if (!_closed[i]) ...<Widget>[
                      TextFormField(
                        controller: _open[i],
                        decoration: InputDecoration(
                          labelText: l10n.adminLabelOpenTime,
                        ),
                        maxLength: 5,
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _close[i],
                        decoration: InputDecoration(
                          labelText: l10n.adminLabelCloseTime,
                        ),
                        maxLength: 5,
                        keyboardType: TextInputType.datetime,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(l10n.adminWeeklyHoursOvernight),
                        value: _overnight[i],
                        onChanged: (bool? v) =>
                            setState(() => _overnight[i] = v ?? false),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (i < 6) const Divider(height: 24),
        ],
      ],
    );
  }
}
