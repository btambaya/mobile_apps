import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

/// PIN entry widget with numeric keypad
class PinEntryWidget extends StatefulWidget {
  final int pinLength;
  final Function(String pin) onPinComplete;
  final String? errorMessage;
  final bool isLoading;

  const PinEntryWidget({
    super.key,
    this.pinLength = 4,
    required this.onPinComplete,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  State<PinEntryWidget> createState() => PinEntryWidgetState();
}

class PinEntryWidgetState extends State<PinEntryWidget> {
  String _enteredPin = '';

  void _onKeyPressed(String key) {
    if (widget.isLoading) return;
    
    HapticFeedback.lightImpact();
    
    if (key == 'delete') {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        });
      }
    } else if (_enteredPin.length < widget.pinLength) {
      setState(() {
        _enteredPin += key;
      });
      
      // Check if PIN complete
      if (_enteredPin.length == widget.pinLength) {
        widget.onPinComplete(_enteredPin);
      }
    }
  }

  void clearPin() {
    setState(() => _enteredPin = '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pinLength,
            (index) => _buildPinDot(index < _enteredPin.length, isDark),
          ),
        ),
        
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.errorMessage!,
            style: ThryveTypography.bodySmall.copyWith(
              color: ThryveColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        
        const SizedBox(height: 32),
        
        // Numeric keypad
        _buildKeypad(isDark),
      ],
    );
  }

  Widget _buildPinDot(bool filled, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled 
            ? ThryveColors.accent 
            : Colors.transparent,
        border: Border.all(
          color: filled 
              ? ThryveColors.accent 
              : (isDark ? ThryveColors.textSecondary : ThryveColors.divider),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildKeypad(bool isDark) {
    return Column(
      children: [
        _buildKeyRow(['1', '2', '3'], isDark),
        const SizedBox(height: 16),
        _buildKeyRow(['4', '5', '6'], isDark),
        const SizedBox(height: 16),
        _buildKeyRow(['7', '8', '9'], isDark),
        const SizedBox(height: 16),
        _buildKeyRow(['', '0', 'delete'], isDark),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80, height: 60);
        }
        return _buildKey(key, isDark);
      }).toList(),
    );
  }

  Widget _buildKey(String key, bool isDark) {
    final isDelete = key == 'delete';
    
    return GestureDetector(
      onTap: () => _onKeyPressed(key),
      child: Container(
        width: 80,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isDelete 
              ? Colors.transparent 
              : (isDark ? ThryveColors.surfaceDark : ThryveColors.surface),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isDelete
              ? Icon(
                  Icons.backspace_outlined,
                  color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  size: 24,
                )
              : Text(
                  key,
                  style: ThryveTypography.headlineMedium.copyWith(
                    color: isDark ? ThryveColors.textPrimaryDark : ThryveColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
