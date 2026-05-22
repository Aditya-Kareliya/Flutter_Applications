import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../logic/tip_provider.dart';
import '../../../../preview_app/logic/preview_provider.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final TextEditingController _billController = TextEditingController();

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = context.watch<PlatformProvider>();
    final isAndroid = platform.isMaterialPlatform;
    final isTablet = platform.isTabletPlatform;

    return isAndroid ? _androidScaffold(context, isTablet) : _iosScaffold(context, isTablet);
  }

  // ================= ANDROID =================
  Widget _androidScaffold(BuildContext context, bool isTablet) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split & Tip', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: isTablet ? _androidSplit(context) : _androidBody(context),
    );
  }

  Widget _androidBody(BuildContext context) {
    return Consumer<TipProvider>(
      builder: (_, p, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _androidCurrency(p),
            const SizedBox(height: 12),

            _mCard(_main(p)),
            const SizedBox(height: 16),

            _mCard(_breakdown(p)),
            const SizedBox(height: 16),

            _mCard(_androidInputs(p)),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                p.saveBill();
                _billController.clear();
              },
              child: const Text("Save Bill"),
            ),

            if (p.history.isNotEmpty) ...[const SizedBox(height: 24), _androidWalletStack(context, p)],
          ],
        );
      },
    );
  }

  Widget _androidSplit(BuildContext context) {
    return Consumer<TipProvider>(
      builder: (_, p, _) {
        return Row(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _mCard(_androidInputs(p)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      p.saveBill();
                      _billController.clear();
                    },
                    child: const Text("Save Bill"),
                  ),
                  if (p.history.isNotEmpty) ...[const SizedBox(height: 24), _androidWalletStack(context, p)],
                ],
              ),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [_mCard(_main(p)), const SizedBox(height: 16), _mCard(_breakdown(p))]),
            ),
          ],
        );
      },
    );
  }

  Widget _mCard(Widget child) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _androidCurrency(TipProvider p) {
    return DropdownButton<Currency>(
      value: p.currency,
      isExpanded: true,
      items: Currency.values.map((e) => DropdownMenuItem(value: e, child: Text(e.code))).toList(),
      onChanged: (c) {
        if (c != null) p.updateCurrency(c);
      },
    );
  }

  // ================= IOS =================
  Widget _iosScaffold(BuildContext context, bool isTablet) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Split & Tip', style: TextStyle(fontWeight: FontWeight.w900)),
        leading: CupertinoButton(padding: EdgeInsets.zero, child: const Icon(CupertinoIcons.back), onPressed: () => context.go('/')),
      ),
      child: SafeArea(bottom: false, child: isTablet ? _iosSplit(context) : _iosBody(context)),
    );
  }

  Widget _iosBody(BuildContext context) {
    return Consumer<TipProvider>(
      builder: (_, p, _) {
        return Container(
          color: CupertinoColors.systemGroupedBackground.resolveFrom(context),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _iosCurrency(p),
              const SizedBox(height: 16),

              _iosWalletHero(context, p),
              const SizedBox(height: 16),

              _iosWalletBreakdown(context, p),
              const SizedBox(height: 16),

              _iosWalletInputs(context, p),
              const SizedBox(height: 16),

              CupertinoButton.filled(
                onPressed: () {
                  p.saveBill();
                  _billController.clear();
                },
                child: const Text("Save Bill"),
              ),

              if (p.history.isNotEmpty) ...[const SizedBox(height: 24), _iosWalletStackUltra(context, p)],
            ],
          ),
        );
      },
    );
  }

  Widget _iosSplit(BuildContext context) {
    return Consumer<TipProvider>(
      builder: (_, p, _) {
        return Row(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _iosWalletInputs(context, p),
                  const SizedBox(height: 16),
                  CupertinoButton.filled(
                    onPressed: () {
                      p.saveBill();
                      _billController.clear();
                    },
                    child: const Text("Save Bill"),
                  ),
                  if (p.history.isNotEmpty) ...[const SizedBox(height: 24), _iosWalletStackUltra(context, p)],
                ],
              ),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [_iosWalletHero(context, p), const SizedBox(height: 16), _iosWalletBreakdown(context, p)]),
            ),
          ],
        );
      },
    );
  }

  Widget _iosCurrency(TipProvider p) {
    return CupertinoSlidingSegmentedControl<Currency>(
      groupValue: p.currency,
      children: const {Currency.inr: Text('₹'), Currency.usd: Text('\$'), Currency.eur: Text('€'), Currency.gbp: Text('£')},
      onValueChanged: (c) {
        if (c != null) p.updateCurrency(c);
      },
    );
  }

  // ================= 🍎 APPLE WALLET ULTRA =================
  Widget _iosWalletStackUltra(BuildContext context, TipProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text('HISTORY', style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 13)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context), borderRadius: BorderRadius.circular(10)),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: p.history.length,
            separatorBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Divider(height: 1, color: CupertinoColors.separator),
            ),
            itemBuilder: (context, i) {
              final bill = p.history[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${p.currency.symbol}${bill.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text("Split between ${bill.people}", style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 14)),
                      ],
                    ),
                    Text("${bill.date.day}/${bill.date.month}/${bill.date.year}", style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 14)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= ANDROID WALLET =================
  Widget _androidWalletStack(BuildContext context, TipProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "History",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: p.history.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final bill = p.history[i];
              return ListTile(
                title: Text("${p.currency.symbol}${bill.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Split between ${bill.people}"),
                trailing: Text("${bill.date.day}/${bill.date.month}/${bill.date.year}"),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= REST =================
  Widget _iosWalletHero(BuildContext context, TipProvider p) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total per person'),
          const SizedBox(height: 10),
          Text('${p.currency.symbol}${p.perPerson.toStringAsFixed(2)}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
          Text('${p.people} people'),
        ],
      ),
    );
  }

  Widget _iosWalletBreakdown(BuildContext context, TipProvider p) {
    return Column(
      children: [
        _row('Subtotal', '${p.currency.symbol}${p.subtotal.toStringAsFixed(2)}'),
        _row('Tip', '${p.currency.symbol}${p.totalTip.toStringAsFixed(2)}'),
        _row('Tax', '${p.currency.symbol}${p.totalTax.toStringAsFixed(2)}'),
        const Divider(),
        _row('Total', '${p.currency.symbol}${p.total.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _iosWalletInputs(BuildContext context, TipProvider p) {
    return Column(
      children: [
        CupertinoTextField(
          controller: _billController,
          placeholder: 'Bill Amount',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            color: CupertinoColors.label.resolveFrom(context),
          ),
          placeholderStyle: TextStyle(color: CupertinoColors.placeholderText.resolveFrom(context)),
          onChanged: p.updateBill,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tip Percentage'),
            Text('${p.tipPercent.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(width: double.infinity,child: CupertinoSlider(value: p.tipPercent, min: 0, max: 50, onChanged: p.updateTip)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Split Between'),
            Text('${p.people} People', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(width:double.infinity,child: CupertinoSlider(value: p.people.toDouble(), min: 1, max: 20, onChanged: p.updatePeople)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Round Up'),
            CupertinoSwitch(value: p.roundUp, onChanged: p.toggleRoundUp),
          ],
        ),
      ],
    );
  }

  Widget _androidInputs(TipProvider p) {
    return Column(
      children: [
        TextField(
          controller: _billController,
          decoration: const InputDecoration(labelText: 'Bill Amount'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: p.updateBill,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tip Percentage'),
            Text('${p.tipPercent.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: p.tipPercent, min: 0, max: 50, onChanged: p.updateTip),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Split Between'),
            Text('${p.people} People', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: p.people.toDouble(), min: 1, max: 20, onChanged: p.updatePeople),
        SwitchListTile(contentPadding: EdgeInsets.zero, value: p.roundUp, onChanged: p.toggleRoundUp, title: const Text("Round Up")),
      ],
    );
  }

  Widget _main(TipProvider p) {
    return Column(
      children: [
        Text('${p.currency.symbol}${p.perPerson.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
        Text('Split between ${p.people}'),
      ],
    );
  }

  Widget _breakdown(TipProvider p) {
    return Column(
      children: [
        _row('Subtotal', '${p.currency.symbol}${p.subtotal.toStringAsFixed(2)}'),
        _row('Tip', '${p.currency.symbol}${p.totalTip.toStringAsFixed(2)}'),
        _row('Tax', '${p.currency.symbol}${p.totalTax.toStringAsFixed(2)}'),
        const Divider(),
        _row('Total', '${p.currency.symbol}${p.total.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v)]),
    );
  }
}
