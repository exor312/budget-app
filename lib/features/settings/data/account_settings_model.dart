import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Valid account types.
const List<String> accountTypes = [
  'cash',
  'debit',
  'credit_card',
  'loan',
  'stocks',
];

/// Human-readable label for each account type.
String accountTypeLabel(String type) {
  const labels = {
    'cash': 'Cash',
    'debit': 'Debit',
    'credit_card': 'Credit Card',
    'loan': 'Loan',
    'stocks': 'Stocks',
  };
  return labels[type] ?? 'Cash';
}

/// Icon data for each account type.
IconData accountTypeIcon(String type) {
  const iconMap = {
    'cash': Icons.account_balance_wallet,
    'debit': Icons.credit_card,
    'credit_card': Icons.credit_card,
    'loan': Icons.account_balance,
    'stocks': Icons.trending_up,
  };
  return iconMap[type] ?? Icons.credit_card;
}

/// Maps a string icon key to a Material IconData (legacy — kept for backward compat).
IconData iconKeyToData(String key) {
  const iconMap = <String, IconData>{
    'wallet': Icons.account_balance_wallet,
    'credit_card': Icons.credit_card,
    'account_balance': Icons.account_balance,
    'savings': Icons.savings,
    'payments': Icons.payments,
    'money': Icons.money,
    'card': Icons.card_membership,
    'bank': Icons.account_balance,
  };
  return iconMap[key] ?? Icons.credit_card;
}

/// A user-defined account (card or bank account).
class Account {
  final String id;
  final String name;
  final String iconKey;
  final String type;

  const Account({
    required this.id,
    required this.name,
    required this.iconKey,
    this.type = 'cash',
  });

  IconData get icon => iconKeyToData(iconKey);

  /// Encode: id|name|iconKey|type
  String encode() => '$id|$name|$iconKey|$type';

  /// Decode with backward compatibility:
  /// Old format (3 parts): id|name|iconKey → defaults type to 'cash'
  /// New format (4 parts): id|name|iconKey|type
  static Account decode(String s) {
    final parts = s.split('|');
    return Account(
      id: parts[0],
      name: parts[1],
      iconKey: parts.length > 2 ? parts[2] : 'credit_card',
      type: parts.length > 3 ? parts[3] : 'cash',
    );
  }
}

/// Manages user-defined accounts (cards, bank accounts) stored in SharedPreferences.
/// Provides add, remove, and query operations. Default "Cash" account always exists.
class AccountSettingsModel extends ChangeNotifier {
  AccountSettingsModel() {
    _load();
  }

  static const String _accountsKey = 'user_accounts';
  static const String _defaultAccountId = 'cash';

  List<Account> _accounts = [];

  /// All accounts including the default "Cash" account.
  List<Account> get accounts => List.unmodifiable(_accounts);

  /// The default Cash account.
  Account get defaultAccount => _accounts.firstWhere(
        (a) => a.id == _defaultAccountId,
        orElse: () => const Account(
          id: _defaultAccountId,
          name: 'Cash',
          iconKey: 'wallet',
          type: 'cash',
        ),
      );

  /// Whether any custom accounts exist beyond Cash.
  bool get hasCustomAccounts => _accounts.length > 1;

  /// Find an account by ID. Falls back to Cash if not found.
  Account findById(String id) {
    return _accounts.firstWhere(
      (a) => a.id == id,
      orElse: () => defaultAccount,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_accountsKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      _accounts = jsonList.map((s) => Account.decode(s)).toList();
    }
    // Ensure Cash always exists
    if (_accounts.isEmpty) {
      _accounts = [
        const Account(
          id: _defaultAccountId,
          name: 'Cash',
          iconKey: 'wallet',
          type: 'cash',
        ),
      ];
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _accountsKey,
      _accounts.where((a) => a.id != _defaultAccountId).map((a) => a.encode()).toList(),
    );
  }

  /// Add a new custom account. Returns false if name is empty or duplicate.
  Future<bool> addAccount({
    required String name,
    String? iconKey,
    String type = 'debit',
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (_accounts.any((a) => a.name.toLowerCase() == trimmed.toLowerCase())) {
      return false;
    }
    final id = 'acc_${DateTime.now().millisecondsSinceEpoch}';
    _accounts.add(Account(
      id: id,
      name: trimmed,
      iconKey: iconKey ?? 'credit_card',
      type: type,
    ));
    await _save();
    notifyListeners();
    return true;
  }

  /// Remove a custom account. Cannot remove Cash.
  bool removeAccount(String accountId) {
    if (accountId == _defaultAccountId) return false;
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index == -1) return false;
    _accounts.removeAt(index);
    _save();
    notifyListeners();
    return true;
  }
}
