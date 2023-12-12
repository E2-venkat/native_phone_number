import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

export 'package:pin_input_text_field/pin_input_text_field.dart';

class PhoneNumberAndSmsAutoFillClass {
  static PhoneNumberAndSmsAutoFillClass? _singleton;
  static const MethodChannel _channel = const MethodChannel('phone_number_sms');
  final StreamController<String> _code = StreamController.broadcast();

  factory PhoneNumberAndSmsAutoFillClass() => _singleton ??= PhoneNumberAndSmsAutoFillClass._();

  PhoneNumberAndSmsAutoFillClass._() {
    _channel.setMethodCallHandler(_didReceive);
  }

  Future<void> _didReceive(MethodCall method) async {
    if (method.method == 'smscode') {
      _code.add(method.arguments);
    }
  }

  Stream<String> get code => _code.stream;

  Future<String?> get hint async {
    final String? hint = await _channel.invokeMethod('requestPhoneHint');

    print('checking the phone hint inside the sms autofill package $hint');
    return hint;
  }

  Future<void> listenForCode({String smsCodeRegexPattern = '\\d{4,6}'}) async {
    await _channel.invokeMethod('listenForCode', <String, String>{'smsCodeRegexPattern': smsCodeRegexPattern});
  }

  Future<void> unregisterListener() async {
    await _channel.invokeMethod('unregisterListener');
  }

  Future<String> get getAppSignature async {
    final String? appSignature = await _channel.invokeMethod('getAppSignature');
    return appSignature ?? '';
  }
}

class PinFieldAutoFill extends StatefulWidget {
  final int codeLength;
  final bool autoFocus;
  final TextEditingController? controller;
  final String? currentCode;
  final Function(String)? onCodeSubmitted;
  final Function(String?)? onCodeChanged;
  final PinDecoration? decoration;
  final FocusNode? focusNode;
  final Cursor? cursor;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enableInteractiveSelection, enabled;
  final String? smsCodeRegexPattern;
  final List<TextInputFormatter>? inputFormatters;

  const PinFieldAutoFill(
      {Key? key,
      this.keyboardType = const TextInputType.numberWithOptions(),
      this.textInputAction = TextInputAction.done,
      this.focusNode,
      this.cursor,
      this.inputFormatters,
      this.enableInteractiveSelection = true,
      this.enabled = true,
      this.controller,
      this.decoration,
      this.onCodeSubmitted,
      this.onCodeChanged,
      this.currentCode,
      this.autoFocus = false,
      this.codeLength = 6,
      this.smsCodeRegexPattern})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PinFieldAutoFillState();
  }
}

class _PinFieldAutoFillState extends State<PinFieldAutoFill> with CodeAutoFill {
  late TextEditingController controller;
  bool _shouldDisposeController = false;

  @override
  Widget build(BuildContext context) {
    return PinInputTextField(
      enabled: widget.enabled,
      pinLength: widget.codeLength,
      decoration: widget.decoration ??
          UnderlineDecoration(colorBuilder: FixedColorBuilder(Colors.black), textStyle: TextStyle(color: Colors.black)),
      focusNode: widget.focusNode,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      autocorrect: false,
      cursor: widget.cursor,
      autofillHints: const <String>[AutofillHints.oneTimeCode],
      textCapitalization: TextCapitalization.none,
      toolbarOptions: ToolbarOptions(paste: true),
      keyboardType: widget.keyboardType,
      autoFocus: widget.autoFocus,
      controller: controller,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      onSubmit: widget.onCodeSubmitted,
    );
  }

  @override
  void initState() {
    _shouldDisposeController = widget.controller == null;
    controller = widget.controller ?? TextEditingController(text: '');
    code = widget.currentCode;
    codeUpdated();
    controller.addListener(() {
      if (controller.text != code) {
        code = controller.text;
        if (widget.onCodeChanged != null) {
          widget.onCodeChanged!(code);
        }
      }
    });
    listenForCode(smsCodeRegexPattern: widget.smsCodeRegexPattern);
    super.initState();
  }

  @override
  void didUpdateWidget(PinFieldAutoFill oldWidget) {
    if (widget.controller != null && widget.controller != controller) {
      controller.dispose();
      controller = widget.controller!;
    }

    if (widget.currentCode != oldWidget.currentCode || widget.currentCode != code) {
      code = widget.currentCode;
      codeUpdated();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void codeUpdated() {
    if (controller.text != code) {
      controller.value = TextEditingValue(text: code ?? '');
      if (widget.onCodeChanged != null) {
        widget.onCodeChanged!(code ?? '');
      }
    }
  }

  @override
  void dispose() {
    cancel();
    if (_shouldDisposeController) {
      controller.dispose();
    }
    unregisterListener();
    super.dispose();
  }
}

class PhoneFormFieldHint extends StatelessWidget {
  final bool autoFocus, enabled;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator? validator;
  final InputDecoration? decoration;
  final TextField? child;

  const PhoneFormFieldHint({
    Key? key,
    this.child,
    this.controller,
    this.inputFormatters,
    this.validator,
    this.decoration,
    this.autoFocus = false,
    this.enabled = true,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PhoneFieldHint(
        key: key,
        child: child,
        inputFormatters: inputFormatters,
        controller: controller,
        validator: validator,
        decoration: decoration,
        autoFocus: autoFocus,
        enabled: enabled,
        focusNode: focusNode,
        isFormWidget: true);
  }
}

class PhoneFieldHint extends StatelessWidget {
  final bool autoFocus;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;
  final TextField? child;

  final bool?  enableSuggestions;

  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final TextStyle? textStyle;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool? readOnly;
  final ToolbarOptions? toolbarOptions;

  const PhoneFieldHint({
    Key? key,
    this.child,
    this.controller,
    this.inputFormatters,
    this.decoration,
    this.autoFocus = false,
    this.focusNode,
    this.enableSuggestions = true,
    this.textInputType = TextInputType.number,
    this.textInputAction = TextInputAction.none,
    this.textCapitalization = TextCapitalization.none,
    this.textStyle = const TextStyle(),
    this.strutStyle = const StrutStyle(),
    this.textAlign = TextAlign.center,
    this.textAlignVertical = TextAlignVertical.center,
    this.textDirection = TextDirection.ltr,
    this.readOnly = false,
    this.toolbarOptions =const ToolbarOptions(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _PhoneFieldHint(
        key: key,
        child: child,
        inputFormatters: inputFormatters,
        controller: controller,
        decoration: decoration,
        autoFocus: autoFocus,
        focusNode: focusNode,
        isFormWidget: false,
      textInputType: textInputType,
      enableSuggestions: enableSuggestions!,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization!,
      textStyle: textStyle,
      strutStyle: strutStyle,
      textAlign: textAlign!,
      textAlignVertical: textAlignVertical,
      textDirection: textDirection,
      readOnly: readOnly!,
      toolbarOptions: toolbarOptions,

    );
  }
}

class _PhoneFieldHint extends StatefulWidget {
  final bool autoFocus, enabled;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator? validator;
  final bool isFormWidget;
  final InputDecoration? decoration;
  final TextField? child;
  final bool?  enableSuggestions;

  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final TextStyle? textStyle;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool? readOnly;
  final ToolbarOptions? toolbarOptions;

  const _PhoneFieldHint({
    Key? key,
    this.child,
    this.controller,
    this.inputFormatters,
    this.validator,
    this.isFormWidget = false,
    this.decoration,
    this.autoFocus = false,
    this.enabled = true,
    this.focusNode,
    this.enableSuggestions,
    this.textInputType,
    this.textInputAction,
    this.textCapitalization,
    this.textStyle,
    this.strutStyle,
    this.textAlign,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly,
    this.toolbarOptions,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PhoneFieldHintState();
  }
}

class _PhoneFieldHintState extends State<_PhoneFieldHint> {
  final PhoneNumberAndSmsAutoFillClass _autoFill = PhoneNumberAndSmsAutoFillClass();
  late TextEditingController _controller;
  late List<TextInputFormatter> _inputFormatters;
  late FocusNode _focusNode;
  bool _hintShown = false;
  bool _isUsingInternalController = false;
  bool _isUsingInternalFocusNode = false;

late  bool? _enableSuggestions;

late TextInputType? _textInputType;
late TextInputAction? _textInputAction;
late TextCapitalization? _textCapitalization;
late TextStyle? _textStyle;
late StrutStyle? _strutStyle;
late TextAlign? _textAlign;
late TextAlignVertical? _textAlignVertical;
late TextDirection? _textDirection;

  late bool? _readOnly;
  late ToolbarOptions? _toolbarOptions;

  @override
  void initState() {

    print('checking the text input action ${widget.textInputAction}');

    _controller = widget.controller ?? widget.child?.controller ?? _createInternalController();
    _inputFormatters = widget.inputFormatters ?? widget.child?.inputFormatters ?? [];
    _focusNode = widget.focusNode ?? widget.child?.focusNode ?? _createInternalFocusNode();
    _enableSuggestions = widget.enableSuggestions ??  widget.enableSuggestions;
    _textInputType = widget.textInputType ??  widget.textInputType;
    _textInputAction = widget.textInputAction ??  widget.textInputAction;
    _textCapitalization = widget.textCapitalization ??  widget.textCapitalization;
    _textStyle = widget.textStyle ??  widget.textStyle;
    _strutStyle = widget.strutStyle ??  widget.strutStyle;
    _textAlign = widget.textAlign ??  widget.textAlign;
    _textAlignVertical = widget.textAlignVertical ??  widget.textAlignVertical;
    _textDirection = widget.textDirection ??  widget.textDirection;
    _readOnly = widget.readOnly ??  widget.readOnly;
    _toolbarOptions = widget.toolbarOptions ??  widget.toolbarOptions;

    _focusNode.addListener(() async {
      if (_focusNode.hasFocus && !_hintShown) {
        _hintShown = true;
        scheduleMicrotask(() {
          _askPhoneHint();
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.decoration ??
        InputDecoration(
          suffixIcon: Platform.isAndroid
              ? IconButton(
                  icon: Icon(Icons.phonelink_setup),
                  onPressed: () async {
                    print('pressing the hint button');
                    _hintShown = true;
                    await _askPhoneHint();
                  },
                )
              : null,
        );

    return widget.child ?? _createField(widget.isFormWidget, decoration, widget.validator);
  }

  @override
  void dispose() {
    if (_isUsingInternalController) {
      _controller.dispose();
    }

    if (_isUsingInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Widget _createField(bool isFormWidget, InputDecoration decoration, FormFieldValidator? validator) {
    return isFormWidget ? _createTextFormField(decoration, validator) : _createTextField(decoration);
  }

  Widget _createTextField(InputDecoration decoration) {
    return TextField(
      enabled: widget.enabled,
      autofocus: widget.autoFocus,
      focusNode: _focusNode,
      autofillHints: [AutofillHints.telephoneNumber],
      inputFormatters: _inputFormatters,
      decoration: decoration,
      controller: _controller,
      keyboardType: _textInputType,
      enableSuggestions: _enableSuggestions!,
      textInputAction: _textInputAction,
      textCapitalization: _textCapitalization!,
      style: _textStyle,
      strutStyle: _strutStyle,
      textAlign: _textAlign!,
      textAlignVertical: _textAlignVertical,
      textDirection: _textDirection,
      readOnly: _readOnly!,
      toolbarOptions: _toolbarOptions,
    );
  }

  Widget _createTextFormField(InputDecoration decoration, FormFieldValidator? validator) {
    return TextFormField(
      enabled: widget.enabled,
      validator: validator,
      autofocus: widget.autoFocus,
      focusNode: _focusNode,
      autofillHints: [AutofillHints.telephoneNumber],
      inputFormatters: _inputFormatters,
      decoration: decoration,
      controller: _controller,
      enableSuggestions: _enableSuggestions!,
      keyboardType: TextInputType.phone,
    );
  }

  Future<void> _askPhoneHint() async {
    String? hint = await _autoFill.hint;
    print('check the hint value $hint');
    _controller.value = TextEditingValue(text: hint ?? '');
  }

  TextEditingController _createInternalController() {
    _isUsingInternalController = true;
    return TextEditingController(text: '');
  }

  FocusNode _createInternalFocusNode() {
    _isUsingInternalFocusNode = true;
    return FocusNode();
  }
}

class TextFieldPinAutoFill extends StatefulWidget {
  final int codeLength;
  final bool autoFocus, enabled;
  final FocusNode? focusNode;
  final String? currentCode;
  final Function(String)? onCodeSubmitted;
  final Function(String)? onCodeChanged;
  final InputDecoration decoration;
  final bool obscureText;
  final TextStyle? style;
  final String? smsCodeRegexPattern;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldPinAutoFill(
      {Key? key,
      this.focusNode,
      this.obscureText = false,
      this.onCodeSubmitted,
      this.style,
      this.inputFormatters,
      this.onCodeChanged,
      this.decoration = const InputDecoration(),
      this.currentCode,
      this.autoFocus = false,
      this.enabled = true,
      this.codeLength = 6,
      this.smsCodeRegexPattern})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TextFieldPinAutoFillState();
  }
}

mixin CodeAutoFill {
  final PhoneNumberAndSmsAutoFillClass _autoFill = PhoneNumberAndSmsAutoFillClass();
  String? code;
  StreamSubscription? _subscription;

  void listenForCode({String? smsCodeRegexPattern}) {
    _subscription = _autoFill.code.listen((code) {
      this.code = code;
      codeUpdated();
    });
    (smsCodeRegexPattern == null)
        ? _autoFill.listenForCode()
        : _autoFill.listenForCode(smsCodeRegexPattern: smsCodeRegexPattern);
  }

  Future<void> cancel() async {
    return _subscription?.cancel();
  }

  Future<void> unregisterListener() {
    return _autoFill.unregisterListener();
  }

  void codeUpdated();
}

class _TextFieldPinAutoFillState extends State<TextFieldPinAutoFill> with CodeAutoFill {
  final TextEditingController _textController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      autofocus: widget.autoFocus,
      focusNode: widget.focusNode,
      maxLength: widget.codeLength,
      decoration: widget.decoration,
      style: widget.style,
      inputFormatters: widget.inputFormatters,
      autofillHints: const <String>[AutofillHints.oneTimeCode],
      onSubmitted: widget.onCodeSubmitted,
      onChanged: widget.onCodeChanged,
      keyboardType: TextInputType.numberWithOptions(),
      controller: _textController,
      obscureText: widget.obscureText,
    );
  }

  @override
  void initState() {
    code = widget.currentCode;
    codeUpdated();
    listenForCode(smsCodeRegexPattern: widget.smsCodeRegexPattern);
    super.initState();
  }

  @override
  void codeUpdated() {
    if (_textController.text != code) {
      _textController.value = TextEditingValue(text: code ?? '');
      if (widget.onCodeChanged != null) {
        widget.onCodeChanged!(code ?? '');
      }
    }
  }

  @override
  void didUpdateWidget(TextFieldPinAutoFill oldWidget) {
    if (widget.currentCode != oldWidget.currentCode || widget.currentCode != _getCode()) {
      code = widget.currentCode;
      codeUpdated();
    }
    super.didUpdateWidget(oldWidget);
  }

  String _getCode() {
    return _textController.value.text;
  }

  @override
  void dispose() {
    cancel();
    _textController.dispose();
    unregisterListener();
    super.dispose();
  }
}
