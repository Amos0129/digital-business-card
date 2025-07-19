// lib/widgets/ios_field.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class IOSField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final String? helperText;
  final bool required;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const IOSField({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.helperText,
    this.required = false,
    this.controller,
    this.focusNode,
  });

  // 常用類型快捷建構子
  static Widget email({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    String? errorText,
    bool required = false,
    TextEditingController? controller,
  }) {
    return IOSField(
      label: label,
      placeholder: placeholder ?? '請輸入電子郵件',
      value: value,
      onChanged: onChanged,
      prefixIcon: CupertinoIcons.mail,
      keyboardType: TextInputType.emailAddress,
      errorText: errorText,
      required: required,
      controller: controller,
    );
  }

  static Widget password({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    String? errorText,
    bool required = false,
    TextEditingController? controller,
  }) {
    return _PasswordField(
      label: label,
      placeholder: placeholder ?? '請輸入密碼',
      value: value,
      onChanged: onChanged,
      errorText: errorText,
      required: required,
      controller: controller,
    );
  }

  static Widget phone({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    String? errorText,
    bool required = false,
    TextEditingController? controller,
  }) {
    return IOSField(
      label: label,
      placeholder: placeholder ?? '請輸入電話號碼',
      value: value,
      onChanged: onChanged,
      prefixIcon: CupertinoIcons.phone,
      keyboardType: TextInputType.phone,
      errorText: errorText,
      required: required,
      controller: controller,
    );
  }

  static Widget multiline({
    String? label,
    String? placeholder,
    String? value,
    ValueChanged<String>? onChanged,
    int maxLines = 3,
    int? maxLength,
    String? errorText,
    bool required = false,
    TextEditingController? controller,
  }) {
    return IOSField(
      label: label,
      placeholder: placeholder,
      value: value,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      errorText: errorText,
      required: required,
      controller: controller,
    );
  }

  @override
  State<IOSField> createState() => _IOSFieldState();
}

class _IOSFieldState extends State<IOSField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) _buildLabel(),
        _buildField(),
        if (widget.errorText != null || widget.helperText != null) _buildHelper(),
      ],
    );
  }

  Widget _buildLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            widget.label!,
            style: AppTheme.footnote.copyWith(
              color: AppTheme.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.required)
            Text(
              ' *',
              style: AppTheme.footnote.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField() {
    return Container(
      decoration: BoxDecoration(
        color: widget.enabled ? AppTheme.cardColor : AppTheme.separatorColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
        border: Border.all(
          color: widget.errorText != null
              ? AppTheme.errorColor
              : _hasFocus
                  ? AppTheme.primaryColor
                  : AppTheme.separatorColor,
          width: _hasFocus ? 2 : 1,
        ),
        boxShadow: _hasFocus ? [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: CupertinoTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widget.placeholder,
        obscureText: widget.obscureText,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.all(16),
        style: AppTheme.body.copyWith(
          color: widget.enabled ? AppTheme.textColor : AppTheme.secondaryTextColor,
        ),
        placeholderStyle: AppTheme.body.copyWith(
          color: AppTheme.secondaryTextColor,
        ),
        prefix: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  widget.prefixIcon,
                  color: _hasFocus ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
                  size: 20,
                ),
              )
            : null,
        suffix: widget.suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: widget.suffix,
              )
            : null,
      ),
    );
  }

  Widget _buildHelper() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Text(
        widget.errorText ?? widget.helperText ?? '',
        style: AppTheme.caption1.copyWith(
          color: widget.errorText != null ? AppTheme.errorColor : AppTheme.secondaryTextColor,
        ),
      ),
    );
  }
}

// 密碼輸入框（帶顯示/隱藏切換）
class _PasswordField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool required;
  final TextEditingController? controller;

  const _PasswordField({
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.errorText,
    this.required = false,
    this.controller,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return IOSField(
      label: widget.label,
      placeholder: widget.placeholder,
      value: widget.value,
      onChanged: widget.onChanged,
      prefixIcon: CupertinoIcons.lock,
      obscureText: _obscureText,
      errorText: widget.errorText,
      required: widget.required,
      controller: widget.controller,
      suffix: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 24,
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Icon(
          _obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          color: AppTheme.secondaryTextColor,
          size: 20,
        ),
      ),
    );
  }
}

// 搜尋輸入框
class IOSSearchField extends StatefulWidget {
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const IOSSearchField({
    super.key,
    this.placeholder,
    this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  State<IOSSearchField> createState() => _IOSSearchFieldState();
}

class _IOSSearchFieldState extends State<IOSSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.separatorColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
      ),
      child: CupertinoTextField(
        controller: _controller,
        placeholder: widget.placeholder ?? '搜尋',
        onChanged: widget.onChanged,
        decoration: const BoxDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        style: AppTheme.body,
        placeholderStyle: AppTheme.body.copyWith(
          color: AppTheme.secondaryTextColor,
        ),
        prefix: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Icon(
            CupertinoIcons.search,
            color: AppTheme.secondaryTextColor,
            size: 20,
          ),
        ),
        suffix: _hasText
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 24,
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                    widget.onChanged?.call('');
                  },
                  child: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: AppTheme.secondaryTextColor,
                    size: 20,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}