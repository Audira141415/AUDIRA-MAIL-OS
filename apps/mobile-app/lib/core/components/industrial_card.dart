import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/industrial_theme.dart';

class IndustrialCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isInteractive;
  final VoidCallback? onTap;

  const IndustrialCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.isInteractive = false,
    this.onTap,
  });

  @override
  State<IndustrialCard> createState() => _IndustrialCardState();
}

class _IndustrialCardState extends State<IndustrialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.isInteractive ? (_) => setState(() => _isHovered = true) : null,
      onTapUp: widget.isInteractive ? (_) => setState(() => _isHovered = false) : null,
      onTapCancel: widget.isInteractive ? () => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.chassis,
          borderRadius: IndustrialTheme.radiusLg,
          boxShadow: _isHovered ? IndustrialTheme.shadowFloating : IndustrialTheme.shadowCard,
        ),
        child: ClipRRect(
          borderRadius: IndustrialTheme.radiusLg,
          child: Stack(
            children: [
              Padding(
                padding: widget.padding,
                child: widget.child,
              ),
              // Screw details (Top left)
              Positioned(
                top: 12,
                left: 12,
                child: _buildScrew(),
              ),
              // Screw details (Top right)
              Positioned(
                top: 12,
                right: 12,
                child: _buildScrew(),
              ),
              // Screw details (Bottom left)
              Positioned(
                bottom: 12,
                left: 12,
                child: _buildScrew(),
              ),
              // Screw details (Bottom right)
              Positioned(
                bottom: 12,
                right: 12,
                child: _buildScrew(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrew() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.recessed,
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(1, 1),
            blurRadius: 1,
          ),
          BoxShadow(
            color: Colors.black12,
            offset: Offset(-1, -1),
            blurRadius: 1,
          ),
        ],
      ),
    );
  }
}
