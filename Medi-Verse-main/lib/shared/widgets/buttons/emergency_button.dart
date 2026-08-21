import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable Material 3 Enterprise Emergency SOS Action Button
class EmergencyButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final String? subtitle;
  final double size;
  final bool isFullWidth;
  final bool isLoading;

  const EmergencyButton({
    super.key,
    required this.onTap,
    this.label = 'EMERGENCY SOS',
    this.subtitle,
    this.size = 130.0,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.esi1Critical,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: AppColors.esi1Critical.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: widget.isLoading ? null : widget.onTap,
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emergency_rounded, size: 24, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            if (!widget.isLoading) widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glowing Pulse Ring
              Container(
                width: widget.size * 1.45,
                height: widget.size * 1.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.esi1Critical.withValues(alpha: 0.15),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15), duration: 1200.ms)
                  .fade(begin: 0.3, end: 0.7),

              // Middle Soft Ring
              Container(
                width: widget.size * 1.22,
                height: widget.size * 1.22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.esi1Critical.withValues(alpha: 0.25),
                ),
              ),

              // Core SOS Action Circle
              AnimatedScale(
                scale: _isPressed ? 0.94 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3B5C), Color(0xFFFF6B00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.esi1Critical.withValues(alpha: 0.45),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      else ...[
                        const Icon(
                          Icons.emergency_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
