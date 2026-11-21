import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/v2_tokens.dart';
import '../budget/repository/budget_repository.dart';
import 'components/v2_spending_tracker_card.dart';

class _PlanItem {
  final String id;
  final String title;
  final int amount;
  final bool isSelected;

  const _PlanItem({
    required this.id,
    required this.title,
    required this.amount,
    this.isSelected = true,
  });
}

class V2BudgetPlannerScreen extends StatefulWidget {
  final BudgetRepository repository;

  const V2BudgetPlannerScreen({super.key, required this.repository});

  @override
  State<V2BudgetPlannerScreen> createState() => _V2BudgetPlannerScreenState();
}

class _V2BudgetPlannerScreenState extends State<V2BudgetPlannerScreen> {
  final List<_PlanItem> _items = [];
  String _rawDigits = '';
  bool _showNumpad = true;
  String? _editingId;
  String? _editingAmountId;
  String _sortMode = 'oldest'; // 'oldest' | 'highest' | 'lowest'
  final TextEditingController _editController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const String _draftKey = 'v2_planner_draft';

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _items.clear();
        for (final e in list) {
          _items.add(
            _PlanItem(
              id: e['id'] as String,
              title: e['title'] as String,
              amount: e['amount'] as int,
              isSelected: (e['isSelected'] as bool?) ?? false,
            ),
          );
        }
        _applySort();
      });
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _items
          .map(
            (e) => {
              'id': e.id,
              'title': e.title,
              'amount': e.amount,
              'isSelected': e.isSelected,
            },
          )
          .toList(),
    );
    await prefs.setString(_draftKey, encoded);
  }

  @override
  void dispose() {
    _editController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onKeyTap(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == 'back') {
        if (_rawDigits.isNotEmpty) {
          _rawDigits = _rawDigits.substring(0, _rawDigits.length - 1);
        }
        return;
      }
      if (key == '.000') {
        if (_rawDigits.isEmpty || _rawDigits == '0') return;
        if (_rawDigits.length + 3 <= 12) {
          _rawDigits += '000';
        }
        return;
      }
      if (_rawDigits.length >= 12) return;
      if (_rawDigits == '0') {
        _rawDigits = key;
      } else {
        _rawDigits += key;
      }
    });
  }

  String _formatDigits(String digits) {
    if (digits.isEmpty) return '0';
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - 1 - i;
      buffer.write(digits[i]);
      if (reverseIndex > 0 && reverseIndex % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  String _formatRp(int amount) {
    final isNeg = amount < 0;
    return '${isNeg ? '-' : ''}Rp ${_formatDigits(amount.abs().toString())}';
  }

  void _startAmountEdit(int index) {
    HapticFeedback.mediumImpact();
    final item = _items[index];
    setState(() {
      _editingId = null;
      _editingAmountId = item.id;
      _rawDigits = item.amount.toString();
      _showNumpad = true;
    });
  }

  void _addItem() {
    final amount = int.tryParse(_rawDigits) ?? 0;
    if (amount <= 0) return;

    HapticFeedback.mediumImpact();
    setState(() {
      if (_editingAmountId != null) {
        final idx = _items.indexWhere((e) => e.id == _editingAmountId);
        if (idx != -1) {
          final old = _items[idx];
          _items[idx] = _PlanItem(
            id: old.id,
            title: old.title,
            amount: amount,
            isSelected: old.isSelected,
          );
        }
        _editingAmountId = null;
      } else {
        _items.add(
          _PlanItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: 'Plan #${_items.length + 1}',
            amount: amount,
          ),
        );
      }
      _applySort();
      _rawDigits = '';
    });
    _saveDraft();
    if (_sortMode == 'oldest' && _editingAmountId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  void _applySort() {
    if (_sortMode == 'highest') {
      _items.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortMode == 'lowest') {
      _items.sort((a, b) => a.amount.compareTo(b.amount));
    } else {
      _items.sort((a, b) => a.id.compareTo(b.id));
    }
  }

  void _startInlineEdit(int index) {
    final current = _items[index];
    setState(() {
      _showNumpad = false;
      _editingId = current.id;
      _editController.text = current.title;
      _editController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: current.title.length,
      );
    });
  }

  void _commitInlineEdit(int index) {
    final current = _items[index];
    final newTitle = _editController.text.trim();
    setState(() {
      if (newTitle.isNotEmpty) {
        _items[index] = _PlanItem(
          id: current.id,
          title: newTitle,
          amount: current.amount,
          isSelected: current.isSelected,
        );
      }
      _editingId = null;
    });
    _saveDraft();
  }

  void _toggleSelect(int index) {
    HapticFeedback.selectionClick();
    final item = _items[index];
    setState(() {
      _items[index] = _PlanItem(
        id: item.id,
        title: item.title,
        amount: item.amount,
        isSelected: !item.isSelected,
      );
    });
    _saveDraft();
  }

  Future<void> _saveSelectedToExpenses() async {
    final selected = _items.where((e) => e.isSelected).toList();
    if (selected.isEmpty) return;
    for (final item in selected) {
      await widget.repository.addExpense(
        item.amount,
        note: item.title,
        categoryId: 'Planned',
      );
    }
    if (!mounted) return;
    setState(() {
      _items.removeWhere((e) => e.isSelected);
    });
    _saveDraft();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${selected.length} selected items to expenses'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetCurrent = widget.repository.remainingWeeklySpendable;
    final totalPlanned = _items.fold<int>(0, (sum, e) => sum + e.amount);
    final finalRemaining = budgetCurrent - totalPlanned;
    final isOver = finalRemaining < 0;

    const double horizontalPadding = 24.1;
    const double listItemRadius = 8.2;
    const double sheetRadius = 32.0;
    const double displayAmountSize = 23.9;
    const double keyHeight = 60.5;
    const double keyGap = 6.0;
    const double keyRadius = 28.0;

    final selectedCount = _items.where((e) => e.isSelected).length;

    return PopScope(
      canPop: !_showNumpad,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showNumpad) {
          setState(() => _showNumpad = false);
        }
      },
      child: Scaffold(
      backgroundColor: V2Colors.bgPrimary,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Save (selectedCount) on top-right
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: V2Colors.surfaceCard,
                        border: Border.all(color: V2Colors.borderSubtle),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: V2Colors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Text('Trip Planner', style: V2Typography.cardTitle(size: 16)),
                  InkWell(
                    onTap: selectedCount == 0 ? null : _saveSelectedToExpenses,
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selectedCount == 0
                            ? V2Colors.surfaceCard
                            : V2Colors.semanticPositive,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selectedCount == 0
                              ? V2Colors.borderSubtle
                              : V2Colors.semanticPositive,
                        ),
                      ),
                      child: Text(
                        selectedCount == 0 ? 'Save' : 'Save ($selectedCount)',
                        style: TextStyle(
                          color: selectedCount == 0
                              ? V2Colors.textMuted
                              : V2Colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Scrollable Card + Flat Todo List
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  bottom: _editingId != null ? 280 : 16,
                ),
                children: [
                  V2SpendingTrackerCard(
                    availableText: _formatRp(finalRemaining),
                    limitText: _formatRp(totalPlanned),
                    progress: budgetCurrent > 0
                        ? (totalPlanned / budgetCurrent).clamp(0.0, 1.0)
                        : 0.0,
                  ),
                  const SizedBox(height: 12),
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Tap numpad below & press + to add plan',
                          style: V2Typography.labelMuted(size: 13),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              for (final opt in const [
                                (id: 'oldest', label: 'Earliest'),
                                (id: 'highest', label: 'Highest'),
                                (id: 'lowest', label: 'Lowest'),
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _sortMode = opt.id;
                                        _applySort();
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _sortMode == opt.id
                                            ? V2Colors.accentPrimary
                                                .withValues(alpha: 0.18)
                                            : V2Colors.surfaceCard,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: _sortMode == opt.id
                                              ? V2Colors.accentPrimary
                                              : V2Colors.borderSubtle,
                                        ),
                                      ),
                                      child: Text(
                                        opt.label,
                                        style: TextStyle(
                                          color: _sortMode == opt.id
                                              ? V2Colors.accentPrimary
                                              : V2Colors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(_items.length, (index) {
                          final item = _items[index];
                          final isEditingAmount = _editingAmountId == item.id;
                          return Column(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onLongPress: () => _startAmountEdit(index),
                                child: Container(
                                  color: isEditingAmount
                                      ? V2Colors.accentPrimary
                                          .withValues(alpha: 0.08)
                                      : Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () => _toggleSelect(index),
                                      borderRadius: BorderRadius.circular(999),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 160),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item.isSelected
                                              ? V2Colors.semanticPositive
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: item.isSelected
                                                ? V2Colors.semanticPositive
                                                : V2Colors.textMuted,
                                            width: 1.8,
                                          ),
                                        ),
                                        child: item.isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: V2Colors.bgPrimary,
                                                size: 14,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _editingId == item.id
                                          ? TextField(
                                              controller: _editController,
                                              autofocus: true,
                                              style: V2Typography.cardTitle(
                                                size: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: 4,
                                                ),
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color:
                                                        V2Colors.accentPrimary,
                                                  ),
                                                ),
                                              ),
                                              onSubmitted: (_) =>
                                                  _commitInlineEdit(index),
                                              onTapOutside: (_) =>
                                                  _commitInlineEdit(index),
                                            )
                                          : InkWell(
                                              onTap: () =>
                                                  _startInlineEdit(index),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      item.title,
                                                      style:
                                                          V2Typography.cardTitle(
                                                        size: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.edit_outlined,
                                                    size: 14,
                                                    color: V2Colors.textMuted,
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '-${_formatRp(item.amount)}',
                                      style:
                                          V2Typography.displayBalance(size: 14)
                                              .copyWith(
                                        color: V2Colors.semanticWarning,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      tooltip: 'Remove',
                                      onPressed: () {
                                        setState(() => _items.removeAt(index));
                                        _saveDraft();
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: V2Colors.textMuted,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ),
                              if (index < _items.length - 1)
                                const Divider(
                                  color: V2Colors.borderSubtle,
                                  height: 1,
                                ),
                            ],
                          );
                        }),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Collapsible Custom Numpad Sheet
            if (_editingId != null)
              const SizedBox.shrink()
            else if (!_showNumpad)
              GestureDetector(
                onTap: () => setState(() => _showNumpad = true),
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < -150) {
                    setState(() => _showNumpad = true);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  decoration: const BoxDecoration(
                    color: V2Colors.surfaceCard,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(sheetRadius),
                    ),
                    border: Border(
                      top: BorderSide(color: V2Colors.borderSubtle),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: V2Colors.textMuted.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '+ Add Plan',
                        style: TextStyle(
                          color: V2Colors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  horizontalPadding,
                  14,
                  horizontalPadding,
                  12,
                ),
                decoration: const BoxDecoration(
                  color: V2Colors.surfaceCard,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(sheetRadius),
                  ),
                  border: Border(
                    top: BorderSide(color: V2Colors.borderSubtle),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onVerticalDragEnd: (details) {
                        if ((details.primaryVelocity ?? 0) > 150) {
                          setState(() => _showNumpad = false);
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: V2Colors.textMuted.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Hide Numpad',
                          onPressed: () => setState(() => _showNumpad = false),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: V2Colors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Rp ${_formatDigits(_rawDigits)}',
                            style: V2Typography.displayBalance(
                              size: displayAmountSize,
                            ).copyWith(
                              color: _rawDigits.isEmpty
                                  ? V2Colors.textMuted
                                  : V2Colors.textPrimary,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _rawDigits.isEmpty ? null : _addItem,
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _rawDigits.isEmpty
                                  ? V2Colors.surfaceElevated
                                  : V2Colors.accentPrimary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: _rawDigits.isEmpty
                                  ? V2Colors.textMuted
                                  : V2Colors.bgPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _NumpadRow(
                      keys: const ['1', '2', '3'],
                      keyHeight: keyHeight,
                      keyGap: keyGap,
                      keyRadius: keyRadius,
                      onKeyTap: _onKeyTap,
                    ),
                    const SizedBox(height: keyGap),
                    _NumpadRow(
                      keys: const ['4', '5', '6'],
                      keyHeight: keyHeight,
                      keyGap: keyGap,
                      keyRadius: keyRadius,
                      onKeyTap: _onKeyTap,
                    ),
                    const SizedBox(height: keyGap),
                    _NumpadRow(
                      keys: const ['7', '8', '9'],
                      keyHeight: keyHeight,
                      keyGap: keyGap,
                      keyRadius: keyRadius,
                      onKeyTap: _onKeyTap,
                    ),
                    const SizedBox(height: keyGap),
                    _NumpadRow(
                      keys: const ['.000', '0', 'back'],
                      keyHeight: keyHeight,
                      keyGap: keyGap,
                      keyRadius: keyRadius,
                      onKeyTap: _onKeyTap,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}

class _NumpadRow extends StatelessWidget {
  final List<String> keys;
  final double keyHeight;
  final double keyGap;
  final double keyRadius;
  final ValueChanged<String> onKeyTap;

  const _NumpadRow({
    required this.keys,
    required this.keyHeight,
    required this.keyGap,
    required this.keyRadius,
    required this.onKeyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(keys.length, (index) {
        final key = keys[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == keys.length - 1 ? 0 : keyGap,
            ),
            child: InkWell(
              onTap: () => onKeyTap(key),
              borderRadius: BorderRadius.circular(keyRadius),
              child: Container(
                height: keyHeight,
                decoration: BoxDecoration(
                  color: V2Colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(keyRadius),
                  border: Border.all(color: V2Colors.borderSubtle),
                ),
                alignment: Alignment.center,
                child: key == 'back'
                    ? const Icon(
                        Icons.backspace_outlined,
                        color: V2Colors.textPrimary,
                        size: 18,
                      )
                    : Text(
                        key,
                        style: V2Typography.displayBalance(
                          size: key == '.000' ? 19.7 * 0.82 : 19.7,
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
