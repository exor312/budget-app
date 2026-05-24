import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<bool> addAccount({required String name, String? iconKey}) async {
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

/// Maps a string icon key to a Material IconData.
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

  const Account({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  IconData get icon => iconKeyToData(iconKey);

  String encode() => '$id|$name|$iconKey';

  static Account decode(String s) {
    final parts = s.split('|');
    return Account(
      id: parts[0],
      name: parts[1],
      iconKey: parts.length > 2 ? parts[2] : 'credit_card',
    );
  }
}
