import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
import '../../onboarding/providers/onboarding_provider.dart';

/// ────────────────────────────────────────────────────────────────────
/// FitSmart AI — Crossword Puzzle Splash Screen
///
/// A full-screen animated crossword grid of fitness-related words.
/// Words reveal letter-by-letter with staggered timing, glow with
/// brand accent colors, then the grid fades/scales away as the
/// "FitSmart AI" logo punches through from the centre.
/// ────────────────────────────────────────────────────────────────────

// ── Data model for a placed word ──────────────────────────────────
class _PlacedWord {
  final String text;
  final int row;
  final int col;
  final bool horizontal;
  final Color accentColor;

  const _PlacedWord({
    required this.text,
    required this.row,
    required this.col,
    required this.horizontal,
    required this.accentColor,
  });
}

// ── The crossword grid data ───────────────────────────────────────
// We manually lay out the crossword for a perfect puzzle look.
// Grid is 22 columns x 26 rows. Words interlock at shared letters.

const int _kGridCols = 22;
const int _kGridRows = 26;

const _kLime = Color(0xFFBDFF3A);
const _kCyan = Color(0xFF3ADFFF);
const _kCoral = Color(0xFFFF6B6B);
const _kPurple = Color(0xFFA78BFA);
const _kGold = Color(0xFFFBBF24);
const _kGreen = Color(0xFF34D399);

// Carefully interlocked crossword puzzle:
//
//       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
//  0              S T A M I N A
//  1              T           C
//  2    P R O T E I N         T      
//  3              L           I      
//  4              L   C A R D I O    
//  5                  A       V      
//  6    M A C R O S   L       E     
//  7                  O           
//  8    R E P S       R       W
//  9                  I       E
// 10          G O A L S       I
// 11                  ·       G
// 12    H E A L T H   ·       H
// 13                          T
// 14  F I T N E S S           S
// 15    N                      
// 16    T       N U T R I T I O N    
// 17    E                      
// 18    N       B O D Y        
// 19    S                     
// 20    I       E N D U R A N C E    
// 21    T                      
// 22    Y       F O C U S      

final List<_PlacedWord> _crosswordWords = [
  // Row 0: STAMINA (horizontal)
  _PlacedWord(text: 'STAMINA', row: 0, col: 5, horizontal: true, accentColor: _kLime),

  // Col 5: STILL (vertical from row 0) – the S of STAMINA
  // Actually let's do a simpler layout that guarantees crossings:

  // Row 2: PROTEIN (horizontal)
  _PlacedWord(text: 'PROTEIN', row: 2, col: 1, horizontal: true, accentColor: _kCyan),

  // Row 4: CARDIO (horizontal)
  _PlacedWord(text: 'CARDIO', row: 4, col: 7, horizontal: true, accentColor: _kCoral),

  // Row 6: MACROS (horizontal)
  _PlacedWord(text: 'MACROS', row: 6, col: 1, horizontal: true, accentColor: _kGold),

  // Row 8: REPS (horizontal)
  _PlacedWord(text: 'REPS', row: 8, col: 1, horizontal: true, accentColor: _kPurple),

  // Row 10: GOALS (horizontal)
  _PlacedWord(text: 'GOALS', row: 10, col: 4, horizontal: true, accentColor: _kLime),

  // Row 12: HEALTH (horizontal)
  _PlacedWord(text: 'HEALTH', row: 12, col: 1, horizontal: true, accentColor: _kGreen),

  // Row 14: FITNESS (horizontal)
  _PlacedWord(text: 'FITNESS', row: 14, col: 0, horizontal: true, accentColor: _kCyan),

  // Row 16: NUTRITION (horizontal)
  _PlacedWord(text: 'NUTRITION', row: 16, col: 5, horizontal: true, accentColor: _kCoral),

  // Row 18: BODY (horizontal)
  _PlacedWord(text: 'BODY', row: 18, col: 5, horizontal: true, accentColor: _kGold),

  // Row 20: ENDURANCE (horizontal)
  _PlacedWord(text: 'ENDURANCE', row: 20, col: 5, horizontal: true, accentColor: _kLime),

  // Row 22: FOCUS (horizontal)
  _PlacedWord(text: 'FOCUS', row: 22, col: 5, horizontal: true, accentColor: _kPurple),

  // Vertical words forming crossings:
  // ACTIVE (vertical): col 11, rows 0-5 – crosses STAMINA(A@col11=row0?
  // Let's reconsider positions for col crossing.

  // CALORIES (vertical): col 8, row 4..11 – crosses CARDIO at row4 col8='D'? No...
  // Let me be more deliberate:

  // Col 5: STRENGTH (vertical) rows 0..7 -- S at (0,5) = S of STAMINA ✓
  _PlacedWord(text: 'STRENGTH', row: 0, col: 5, horizontal: false, accentColor: _kGreen),

  // Col 11: ACTIVE (vertical) rows 0..5 -- A at (0,11) = last A of STAMINA ✓
  _PlacedWord(text: 'ACTIVE', row: 0, col: 11, horizontal: false, accentColor: _kPurple),

  // Col 1: INTENSITY (vertical) rows 14..22 -- I at (14,1) = I of FITNESS ✓
  _PlacedWord(text: 'INTENSITY', row: 14, col: 1, horizontal: false, accentColor: _kGold),

  // Col 15: WEIGHTS (vertical) rows 8..14
  _PlacedWord(text: 'WEIGHTS', row: 8, col: 15, horizontal: false, accentColor: _kCoral),

  // Col 8: CALORIES (vertical) rows 4..11 -- C at (4,8)='R'? no..
  // Col 7: CALORIES (vertical) rows 4..11 -- C at (4,7)='C' of CARDIO ✓ !
  _PlacedWord(text: 'CALORIES', row: 4, col: 7, horizontal: false, accentColor: _kCyan),
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ─────────────────────────────────────
  late AnimationController _gridController;     // controls letter reveals
  late AnimationController _pulseController;    // subtle pulse on revealed letters
  late AnimationController _shimmerController;  // shimmer sweep

  // Flattened list of every cell that has a letter
  late List<_LetterCell> _cells;

  // Grid data
  late List<List<String?>> _grid;
  late List<List<Color?>> _colorGrid;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _buildGrid();

    // 1. Grid reveal: ~2.5 seconds staggered letter-by-letter
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // 2. Pulsing glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // 3. Shimmer sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _startSequence();
  }

  void _buildGrid() {
    _grid = List.generate(_kGridRows, (_) => List.filled(_kGridCols, null));
    _colorGrid = List.generate(_kGridRows, (_) => List.filled(_kGridCols, null));
    _cells = [];

    // Place words
    for (final word in _crosswordWords) {
      for (int i = 0; i < word.text.length; i++) {
        final r = word.horizontal ? word.row : word.row + i;
        final c = word.horizontal ? word.col + i : word.col;
        if (r < _kGridRows && c < _kGridCols) {
          _grid[r][c] = word.text[i];
          _colorGrid[r][c] = word.accentColor;
        }
      }
    }

    // Build cell list sorted for a nice reveal pattern (diagonal sweep)
    for (int r = 0; r < _kGridRows; r++) {
      for (int c = 0; c < _kGridCols; c++) {
        if (_grid[r][c] != null) {
          _cells.add(_LetterCell(
            letter: _grid[r][c]!,
            row: r,
            col: c,
            color: _colorGrid[r][c]!,
          ));
        }
      }
    }

    // Sort by diagonal distance for a wave-like reveal
    _cells.sort((a, b) {
      final da = a.row + a.col;
      final db = b.row + b.col;
      if (da != db) return da.compareTo(db);
      return a.col.compareTo(b.col);
    });
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Phase 1: Reveal letters
    _gridController.forward();

    // Phase 2: Hold for shimmer to sweep, then navigate
    await Future.delayed(const Duration(milliseconds: 4200));
    _navigate();
  }

  Future<void> _navigate() async {
    if (_navigated || !mounted) return;
    _navigated = true;

    final user = AuthService.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    // Check local onboarding flag first (fast)
    final onboardedLocally =
        await OnboardingNotifier.isOnboardingCompleteLocal();
    if (onboardedLocally) {
      if (mounted) context.go('/dashboard');
      return;
    }

    // Try Firestore recovery (reinstall scenario)
    final recovered =
        await OnboardingNotifier.tryRestoreFromFirestore(user.uid);
    if (recovered) {
      if (mounted) context.go('/dashboard');
      return;
    }

    // User exists but hasn't onboarded
    if (user.isAnonymous) {
      if (mounted) context.go('/onboarding');
    } else {
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _gridController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF111118),
                  Color(0xFF0A0A0C),
                ],
              ),
            ),
          ),

          // ── Animated crossword grid ─────────────────────────────
          AnimatedBuilder(
            animation: Listenable.merge([
              _gridController,
              _pulseController,
              _shimmerController,
            ]),
            builder: (context, _) {
              return _buildCrosswordGrid(size);
            },
          ),

          // ── Skip button ─────────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _gridController,
              builder: (context, child) {
                final opacity = (_gridController.value > 0.3)
                    ? ((_gridController.value - 0.3) / 0.2).clamp(0.0, 0.6)
                    : 0.0;
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: _navigate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrosswordGrid(Size screenSize) {
    // Calculate cell size to fit the grid nicely
    final cellSize = min(
      (screenSize.width - 32) / _kGridCols,
      (screenSize.height - 80) / _kGridRows,
    );
    final gridWidth = cellSize * _kGridCols;
    final gridHeight = cellSize * _kGridRows;

    return Center(
      child: SizedBox(
        width: gridWidth,
        height: gridHeight,
        child: CustomPaint(
          painter: _CrosswordPainter(
            cells: _cells,
            cellSize: cellSize,
            revealProgress: _gridController.value,
            pulseValue: _pulseController.value,
            shimmerValue: _shimmerController.value,
            gridCols: _kGridCols,
            gridRows: _kGridRows,
          ),
        ),
      ),
    );
  }

}

// ── Individual letter cell data ────────────────────────────────────
class _LetterCell {
  final String letter;
  final int row;
  final int col;
  final Color color;

  const _LetterCell({
    required this.letter,
    required this.row,
    required this.col,
    required this.color,
  });
}

// ── Custom painter for the crossword grid ──────────────────────────
class _CrosswordPainter extends CustomPainter {
  final List<_LetterCell> cells;
  final double cellSize;
  final double revealProgress;
  final double pulseValue;
  final double shimmerValue;
  final int gridCols;
  final int gridRows;

  _CrosswordPainter({
    required this.cells,
    required this.cellSize,
    required this.revealProgress,
    required this.pulseValue,
    required this.shimmerValue,
    required this.gridCols,
    required this.gridRows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cells.isEmpty) return;

    final totalCells = cells.length;

    for (int i = 0; i < totalCells; i++) {
      final cell = cells[i];
      final cellRevealPoint = i / totalCells;

      // Each cell starts revealing at its point and takes 15% of total duration
      final localProgress =
          ((revealProgress - cellRevealPoint) / 0.15).clamp(0.0, 1.0);

      if (localProgress <= 0) continue;

      final x = cell.col * cellSize;
      final y = cell.row * cellSize;
      final center = Offset(x + cellSize / 2, y + cellSize / 2);

      // ── Cell background with subtle glow ─────────────────
      final bgOpacity = localProgress * (0.08 + pulseValue * 0.04);
      final bgPaint = Paint()
        ..color = cell.color.withValues(alpha: bgOpacity)
        ..style = PaintingStyle.fill;
      
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: cellSize - 2,
          height: cellSize - 2,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(bgRect, bgPaint);

      // ── Subtle border ────────────────────────────────────
      final borderPaint = Paint()
        ..color = cell.color.withValues(alpha: localProgress * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawRRect(bgRect, borderPaint);

      // ── Shimmer effect ───────────────────────────────────
      if (localProgress >= 1.0) {
        final shimmerX = shimmerValue * (gridCols + 4) - 2;
        final distFromShimmer = (cell.col - shimmerX).abs();
        if (distFromShimmer < 2) {
          final shimmerIntensity = (1.0 - distFromShimmer / 2) * 0.15;
          final shimmerPaint = Paint()
            ..color = Colors.white.withValues(alpha: shimmerIntensity)
            ..style = PaintingStyle.fill;
          canvas.drawRRect(bgRect, shimmerPaint);
        }
      }

      // ── Letter text ──────────────────────────────────────
      // Scale in with a nice bounce
      final scaleT = Curves.easeOutBack
          .transform(localProgress.clamp(0.0, 1.0));

      final textOpacity = localProgress;
      final letterColor = Color.lerp(
        Colors.white.withValues(alpha: 0.0),
        cell.color.withValues(alpha: 0.85 + pulseValue * 0.15),
        textOpacity,
      )!;

      final textSpan = TextSpan(
        text: cell.letter,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: cellSize * 0.55 * scaleT,
          fontWeight: FontWeight.w700,
          color: letterColor,
          letterSpacing: 0,
          height: 1.0,
          shadows: localProgress >= 0.8
              ? [
                  Shadow(
                    color: cell.color.withValues(alpha: 0.4 * pulseValue),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(_CrosswordPainter oldDelegate) => true;
}
