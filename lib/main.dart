import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const BlockchainApp());
}

class BlockchainApp extends StatelessWidget {
  const BlockchainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blockchain Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BlockchainPage(),
    );
  }
}

class BlockchainPage extends StatefulWidget {
  const BlockchainPage({super.key});

  @override
  State<BlockchainPage> createState() => _BlockchainPageState();
}

class _BlockchainPageState extends State<BlockchainPage>
    with SingleTickerProviderStateMixin {
  final List<BlockModel> _blocks = [];
  late final AnimationController _linkController;

  @override
  void initState() {
    super.initState();
    _linkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _createGenesisBlock();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _createGenesisBlock() {
    final genesis = BlockModel(
      index: 0,
      previousHash: '0',
      transaction: 'GENESIS BLOCK',
      timestamp: DateTime.now(),
      nonce: 0,
    );
    setState(() => _blocks.add(genesis));
  }

  void _createBankTransactionBlock() {
    final random = Random();
    final sender = _fakeNames[random.nextInt(_fakeNames.length)];
    final receiver = _fakeNames[random.nextInt(_fakeNames.length)];
    final amount = (random.nextDouble() * 5000 + 10).toStringAsFixed(2);
    final transaction = 'BANK TX: $sender -> $receiver | \$$amount';

    final previous = _blocks.last;
    final newBlock = BlockModel(
      index: _blocks.length,
      previousHash: previous.hash,
      transaction: transaction,
      timestamp: DateTime.now(),
      nonce: random.nextInt(99999),
    );

    setState(() => _blocks.add(newBlock));
    _linkController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Node Simulator'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createBankTransactionBlock,
        icon: const Icon(Icons.account_balance),
        label: const Text('Create Bank Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Node Ledger (${_blocks.length} blocks)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _blocks.length,
                separatorBuilder: (context, index) {
                  final isLatestLink = index == _blocks.length - 2;
                  return SizedBox(
                    height: 56,
                    child: AnimatedBuilder(
                      animation: _linkController,
                      builder: (context, child) {
                        final t = isLatestLink ? _linkController.value : 1.0;
                        return CustomPaint(
                          painter: LinkPainter(progress: t),
                          child: child,
                        );
                      },
                      child: Center(
                        child: Text(
                          isLatestLink
                              ? 'Linking new block...'
                              : 'Linked to next block',
                          style: TextStyle(
                            color: isLatestLink
                                ? Colors.indigo
                                : Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemBuilder: (context, index) => BlockCard(block: _blocks[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlockCard extends StatelessWidget {
  const BlockCard({required this.block, super.key});

  final BlockModel block;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Block #${block.index}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Transaction: ${block.transaction}'),
            const SizedBox(height: 6),
            Text('Previous Hash: ${block.previousHash}'),
            const SizedBox(height: 6),
            Text('Current Hash: ${block.hash}'),
            const SizedBox(height: 6),
            Text('Timestamp: ${block.timestamp.toIso8601String()}'),
          ],
        ),
      ),
    );
  }
}

class LinkPainter extends CustomPainter {
  LinkPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * 0.15, size.height / 2);
    final end = Offset(size.width * 0.85, size.height / 2);
    final current = Offset.lerp(start, end, progress) ?? end;
    canvas.drawLine(start, current, linePaint);

    if (progress >= 1) {
      final arrowPath = Path()
        ..moveTo(end.dx - 10, end.dy - 6)
        ..lineTo(end.dx, end.dy)
        ..lineTo(end.dx - 10, end.dy + 6);
      canvas.drawPath(arrowPath, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant LinkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class BlockModel {
  BlockModel({
    required this.index,
    required this.previousHash,
    required this.transaction,
    required this.timestamp,
    required this.nonce,
  });

  final int index;
  final String previousHash;
  final String transaction;
  final DateTime timestamp;
  final int nonce;

  String get hash {
    final raw = '$index|$previousHash|$transaction|${timestamp.microsecondsSinceEpoch}|$nonce';
    return raw.hashCode.toUnsigned(32).toRadixString(16).padLeft(8, '0');
  }
}

const List<String> _fakeNames = [
  'Alice',
  'Bob',
  'Charlie',
  'Diana',
  'Eve',
  'Frank',
  'Grace',
];
