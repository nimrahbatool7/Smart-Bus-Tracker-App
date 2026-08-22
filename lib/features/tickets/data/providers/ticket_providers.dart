import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/app_exception.dart';

// ── Wallet ─────────────────────────────────────────────────────────────────

class WalletState {
  const WalletState({required this.balance, required this.transactions});
  final double balance;
  final List<WalletTransaction> transactions;
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });
  final String   id;
  final String   type;   // 'top_up' | 'ticket_purchase' | 'refund'
  final double   amount;
  final String   description;
  final DateTime createdAt;

  bool get isCredit => type == 'top_up' || type == 'refund';

  factory WalletTransaction.fromMap(Map<String, dynamic> m) {
    return WalletTransaction(
      id:          m['id']          as String,
      type:        m['type']        as String,
      amount:      double.tryParse(m['amount'].toString()) ?? 0,
      description: m['description'] as String? ?? '',
      createdAt:   DateTime.parse(m['created_at'] as String),
    );
  }
}

final walletProvider =
    FutureProvider.autoDispose<WalletState>((ref) async {
  final uid = SupabaseConfig.currentUser?.id;
  if (uid == null) throw const NotAuthenticatedException();

  try {
    // Fetch balance
    final walletRow = await SupabaseConfig.client
        .from('wallets')
        .select('balance')
        .eq('user_id', uid)
        .single();

    final balance =
        double.tryParse(walletRow['balance'].toString()) ?? 0.0;

    // Fetch last 20 transactions
    final txRows = await SupabaseConfig.client
        .from('wallet_transactions')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(20);

    final transactions = (txRows as List)
        .map((r) => WalletTransaction.fromMap(r as Map<String, dynamic>))
        .toList();

    return WalletState(balance: balance, transactions: transactions);
  } catch (e) {
    throw mapException(e);
  }
});

// ── Passes ──────────────────────────────────────────────────────────────────

class PassModel {
  const PassModel({
    required this.id,
    required this.typeName,
    required this.routeName,
    required this.validFrom,
    required this.validUntil,
    required this.status,
    required this.qrToken,
    required this.purchasedAt,
  });

  final String   id;
  final String   typeName;
  final String   routeName;   // 'All Routes' when route_id is null
  final DateTime validFrom;
  final DateTime validUntil;
  final String   status;      // 'active' | 'expired' | 'revoked'
  final String   qrToken;
  final DateTime purchasedAt;

  bool get isActive  => status == 'active' && validUntil.isAfter(DateTime.now());
  bool get isExpired => !isActive;

  factory PassModel.fromMap(Map<String, dynamic> m) {
    final type  = m['ticket_types'] as Map<String, dynamic>? ?? {};
    final route = m['routes']       as Map<String, dynamic>?;

    return PassModel(
      id:          m['id']           as String,
      typeName:    type['name']      as String? ?? 'Pass',
      routeName:   route?['name']    as String? ?? 'All Routes',
      validFrom:   DateTime.parse(m['valid_from']    as String),
      validUntil:  DateTime.parse(m['valid_until']   as String),
      status:      m['status']       as String,
      qrToken:     m['qr_token']     as String,
      purchasedAt: DateTime.parse(m['purchased_at']  as String),
    );
  }
}

/// Active passes for the current user (valid today).
final activePassesProvider =
    FutureProvider.autoDispose<List<PassModel>>((ref) async {
  final uid = SupabaseConfig.currentUser?.id;
  if (uid == null) throw const NotAuthenticatedException();

  final today = DateTime.now().toIso8601String().substring(0, 10);

  try {
    final rows = await SupabaseConfig.client
        .from('passes')
        .select('*, ticket_types(name), routes(name)')
        .eq('user_id', uid)
        .eq('status', 'active')
        .gte('valid_until', today)
        .order('valid_until');

    return (rows as List)
        .map((r) => PassModel.fromMap(r as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw mapException(e);
  }
});

/// Historical (expired/revoked) passes for the current user.
final passHistoryProvider =
    FutureProvider.autoDispose<List<PassModel>>((ref) async {
  final uid = SupabaseConfig.currentUser?.id;
  if (uid == null) throw const NotAuthenticatedException();

  final today = DateTime.now().toIso8601String().substring(0, 10);

  try {
    final rows = await SupabaseConfig.client
        .from('passes')
        .select('*, ticket_types(name), routes(name)')
        .eq('user_id', uid)
        .or('status.eq.expired,status.eq.revoked,valid_until.lt.$today')
        .order('valid_until', ascending: false)
        .limit(20);

    return (rows as List)
        .map((r) => PassModel.fromMap(r as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw mapException(e);
  }
});

// ── Ticket types (for BuyTicketScreen) ─────────────────────────────────────

class TicketTypeModel {
  const TicketTypeModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    this.description,
  });
  final String  id;
  final String  name;
  final double  price;
  final int     durationDays;
  final String? description;

  factory TicketTypeModel.fromMap(Map<String, dynamic> m) {
    return TicketTypeModel(
      id:           m['id']           as String,
      name:         m['name']         as String,
      price:        double.tryParse(m['price'].toString()) ?? 0,
      durationDays: m['duration_days'] as int,
      description:  m['description']  as String?,
    );
  }
}

final ticketTypesProvider =
    FutureProvider.autoDispose<List<TicketTypeModel>>((ref) async {
  try {
    final rows = await SupabaseConfig.client
        .from('ticket_types')
        .select()
        .eq('is_active', true)
        .order('price');
    return (rows as List)
        .map((r) => TicketTypeModel.fromMap(r as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw mapException(e);
  }
});

// ── Purchase notifier ───────────────────────────────────────────────────────

class PurchaseNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> purchase({
    required String ticketTypeId,
    String? routeId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final uid = SupabaseConfig.currentUser?.id;
      if (uid == null) throw const NotAuthenticatedException();
      await SupabaseConfig.client.rpc('purchase_pass', params: {
        'p_ticket_type_id': ticketTypeId,
        'p_route_id':       routeId,
      });
    });
  }
}

final purchaseProvider =
    NotifierProvider.autoDispose<PurchaseNotifier, AsyncValue<void>>(
  PurchaseNotifier.new,
);
