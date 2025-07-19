import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

enum IOSTextFieldStyle {
  grouped,    // iOS 群組樣式 (圓角矩形，有背景)
  plain,      // iOS 純文字樣式 (只有底線)
  rounded,    // iOS 圓角樣式 (全圓角)
}

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? hintText; // Added hintText parameter
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final IOSTextFieldStyle style;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool showCharacterCount;
  final String? errorText;

  const AppTextField({
    Key? key,
    this.controller,
    this.label,
    this.placeholder,
    this.hintText, // Added hintText parameter
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.style = IOSTextFieldStyle.grouped,
    this.padding,
    this.backgroundColor,
    this.showCharacterCount = false,
    this.errorText,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> with TickerProviderStateMixin {
  bool _obscureText = false;
  late FocusNode _focusNode;
  bool _isFocused = false;
  late AnimationController _animationController;
  late Animation<double> _labelAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _labelAnimation = Tween<double>(
      begin: 1.0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _borderColorAnimation = ColorTween(
      begin: AppTheme.separatorColor,
      end: AppTheme.primaryColor,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case IOSTextFieldStyle.grouped:
        return _buildGroupedTextField();
      case IOSTextFieldStyle.plain:
        return _buildPlainTextField();
      case IOSTextFieldStyle.rounded:
        return _buildRoundedTextField();
    }
  }

  Widget _buildGroupedTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Text(
              widget.label!.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.secondaryTextColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppTheme.secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(IOSConstants.radiusMedium),
            border: Border.all(
              color: widget.errorText != null 
                  ? AppTheme.errorColor 
                  : _isFocused 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: _buildTextField(),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              widget.helperText!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
        ],
        if (widget.showCharacterCount && widget.maxLength != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlainTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.errorText != null 
                    ? AppTheme.errorColor 
                    : _isFocused 
                        ? AppTheme.primaryColor 
                        : AppTheme.separatorColor,
                width: _isFocused ? 2 : 1,
              ),
            ),
          ),
          child: _buildTextField(showBorder: false),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRoundedTextField() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: widget.errorText != null 
              ? AppTheme.errorColor 
              : _isFocused 
                  ? AppTheme.primaryColor 
                  : Colors.transparent,
          width: _isFocused ? 2 : 1,
        ),
      ),
      child: _buildTextField(),
    );
  }

  Widget _buildTextField({bool showBorder = true}) {
    // Use hintText if provided, otherwise fall back to placeholder
    final String? displayHint = widget.hintText ?? widget.placeholder;
    
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      autofocus: widget.autofocus,
      textCapitalization: widget.textCapitalization,
      style: const TextStyle(
        fontSize: 17,
        color: AppTheme.textColor,
        fontFamily: '.SF Pro Text',
      ),
      decoration: InputDecoration(
        hintText: displayHint,
        prefixIcon: widget.prefix,
        suffixIcon: _buildSuffixIcon(),
        filled: false,
        contentPadding: widget.padding ?? 
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: showBorder ? InputBorder.none : const UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        enabledBorder: showBorder ? InputBorder.none : const UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: showBorder ? InputBorder.none : const UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        errorBorder: showBorder ? InputBorder.none : const UnderlineInputBorder(
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: AppTheme.tertiaryTextColor,
          fontSize: 17,
          fontFamily: '.SF Pro Text',
        ),
        counterText: '', // 隱藏預設字數統計
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    List<Widget> suffixWidgets = [];
    
    // 密碼顯示/隱藏按鈕
    if (widget.obscureText) {
      suffixWidgets.add(
        CupertinoButton(
          padding: const EdgeInsets.all(8),
          minSize: 0,
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: AppTheme.secondaryTextColor,
            size: 20,
          ),
        ),
      );
    }
    
    // 自定義後綴
    if (widget.suffix != null) {
      suffixWidgets.add(widget.suffix!);
    }
    
    // 清除按鈕（當有內容時顯示）
    if (widget.enabled && 
        !widget.readOnly && 
        widget.controller?.text.isNotEmpty == true &&
        _isFocused) {
      suffixWidgets.add(
        CupertinoButton(
          padding: const EdgeInsets.all(8),
          minSize: 0,
          onPressed: () {
            widget.controller?.clear();
            widget.onChanged?.call('');
          },
          child: const Icon(
            CupertinoIcons.clear_circled_solid,
            color: AppTheme.tertiaryTextColor,
            size: 18,
          ),
        ),
      );
    }
    
    if (suffixWidgets.isEmpty) return null;
    
    if (suffixWidgets.length == 1) {
      return suffixWidgets.first;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: suffixWidgets,
    );
  }
}

// iOS 風格的 FormField 版本（支持驗證）
class IOSFormField extends FormField<String> {
  IOSFormField({
    Key? key,
    String? initialValue,
    String? label,
    String? placeholder,
    String? hintText, // Added hintText parameter
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    FormFieldValidator<String>? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    Widget? prefix,
    Widget? suffix,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    IOSTextFieldStyle style = IOSTextFieldStyle.grouped,
    bool showCharacterCount = false,
    TextEditingController? controller,
    FocusNode? focusNode,
  }) : super(
    key: key,
    initialValue: controller?.text ?? initialValue,
    validator: validator,
    enabled: enabled,
    builder: (FormFieldState<String> state) {
      final effectiveController = controller ?? TextEditingController(text: state.value);
      
      return AppTextField(
        controller: effectiveController,
        focusNode: focusNode,
        label: label,
        placeholder: placeholder,
        hintText: hintText, // Pass hintText parameter
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: (value) {
          state.didChange(value);
          onChanged?.call(value);
        },
        onSubmitted: onSubmitted,
        prefix: prefix,
        suffix: suffix,
        enabled: enabled,
        readOnly: readOnly,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        style: style,
        showCharacterCount: showCharacterCount,
        errorText: state.errorText,
      );
    },
  );
}

// iOS 風格的搜尋欄
class IOSSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onCancel;
  final bool showCancelButton;
  final bool autofocus;

  const IOSSearchBar({
    Key? key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onCancel,
    this.showCancelButton = true,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<IOSSearchBar> createState() => _IOSSearchBarState();
}

class _IOSSearchBarState extends State<IOSSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isActive = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.tertiaryTextColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: const TextStyle(
                fontSize: 17,
                color: AppTheme.textColor,
                fontFamily: '.SF Pro Text',
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder ?? '搜尋',
                hintStyle: const TextStyle(
                  color: AppTheme.tertiaryTextColor,
                  fontSize: 17,
                ),
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: AppTheme.tertiaryTextColor,
                  size: 20,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        minSize: 0,
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                        child: const Icon(
                          CupertinoIcons.clear_circled_solid,
                          color: AppTheme.tertiaryTextColor,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ),
        if (widget.showCancelButton && _isActive) ...[
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _focusNode.unfocus();
              widget.onCancel?.call();
            },
            child: const Text(
              '取消',
              style: TextStyle(
                fontSize: 17,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}