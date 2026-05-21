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
      debugShowCheckedModeBanner: false,
      title: 'Blockchain Web Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D4BFF)),
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
  static const double _blockWidth = 165;
  static const double _blockHeight = 110;
  static const double _hGap = 20;
  static const double _vGap = 50;

  final List<BlockModel> _blocks = [];
  late final AnimationController _linkController;

  @override
  void initState() {
    super.initState();
    _linkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
      transaction: 'GENESIS',
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
    final transaction = 'TX: $sender->$receiver | \$$amount';

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
        title: const Text('Blockchain Visual Builder'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createBankTransactionBlock,
        icon: const Icon(Icons.account_balance_wallet_outlined),
        label: const Text('Create Bank Transaction'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cols = max(
            1,
            ((constraints.maxWidth + _hGap) / (_blockWidth + _hGap)).floor(),
          );

          final positions = <Offset>[];
          for (var i = 0; i < _blocks.length; i++) {
            final row = i ~/ cols;
            final col = i % cols;
            final x = col * (_blockWidth + _hGap);
            final y = row * (_blockHeight + _vGap);
            positions.add(Offset(x, y));
          }

          final rows = ((_blocks.length - 1) ~/ cols) + 1;
          final boardHeight = max(
            constraints.maxHeight,
            rows * (_blockHeight + _vGap) + 100,
          ).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: SizedBox(
              width: constraints.maxWidth - 32,
              height: boardHeight,
              child: AnimatedBuilder(
                animation: _linkController,
                builder: (context, _) {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(constraints.maxWidth - 32, boardHeight),
                        painter: FreeRoamArrowPainter(
                          positions: positions,
                          blockWidth: _blockWidth,
                          blockHeight: _blockHeight,
                          latestProgress: _linkController.value,
                        ),
                      ),
                      ...List.generate(_blocks.length, (index) {
                        final p = positions[index];
                        return Positioned(
                          left: p.dx,
                          top: p.dy,
                          child: BlockCard(
                            block: _blocks[index],
                            width: _blockWidth,
                            height: _blockHeight,
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class BlockCard extends StatelessWidget {
  const BlockCard({
    required this.block,
    required this.width,
    required this.height,
    super.key,
  });

  final BlockModel block;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF7A8CFF), Color(0xFF2D4BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 12,
            offset: Offset(6, 8),
          ),
          BoxShadow(
            color: Color(0x33FFFFFF),
            blurRadius: 2,
            offset: Offset(-2, -2),
          ),
        ],
        border: Border.all(color: const Color(0xFFB7C1FF), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BLOCK ${block.index}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(block.transaction, maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Text('Prev: ${block.previousHash.substring(0, min(6, block.previousHash.length))}...'),
              Text('Hash: ${block.hash.substring(0, min(6, block.hash.length))}...'),
            ],
          ),
        ),
      ),
    );
  }
}

class FreeRoamArrowPainter extends CustomPainter {
  FreeRoamArrowPainter({
    required this.positions,
    required this.blockWidth,
    required this.blockHeight,
    required this.latestProgress,
  });

  final List<Offset> positions;
  final double blockWidth;
  final double blockHeight;
  final double latestProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) {
      return;
    }

    final linePaint = Paint()
      ..color = const Color(0xFF00BFA5)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 1; i < positions.length; i++) {
      final startBlock = positions[i - 1];
      final endBlock = positions[i];

      final start = Offset(startBlock.dx + blockWidth * 0.5, startBlock.dy + blockHeight);
      final end = Offset(endBlock.dx + blockWidth * 0.5, endBlock.dy);

      final ctrl1 = Offset(start.dx + (end.dx - start.dx) * 0.2, start.dy + 35);
      final ctrl2 = Offset(end.dx - (end.dx - start.dx) * 0.2, end.dy - 35);

      final fullPath = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, end.dx, end.dy);

      if (i == positions.length - 1) {
        final metric = fullPath.computeMetrics().first;
        final partial = metric.extractPath(0, metric.length * latestProgress);
        canvas.drawPath(partial, linePaint);

        if (latestProgress >= 0.98) {
          _drawArrowHead(canvas, end, ctrl2, linePaint);
        }
      } else {
        canvas.drawPath(fullPath, linePaint);
        _drawArrowHead(canvas, end, ctrl2, linePaint);
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, Offset from, Paint linePaint) {
    final direction = (tip - from);
    final normalized = direction / direction.distance;
    final perp = Offset(-normalized.dy, normalized.dx);

    final p1 = tip - normalized * 12 + perp * 6;
    final p2 = tip - normalized * 12 - perp * 6;

    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p2.dx, p2.dy);

    canvas.drawPath(arrowPath, linePaint);
  }

  @override
  bool shouldRepaint(covariant FreeRoamArrowPainter oldDelegate) {
    return oldDelegate.positions != positions ||
        oldDelegate.latestProgress != latestProgress;
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
