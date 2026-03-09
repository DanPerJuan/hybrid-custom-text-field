import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../hybrid_custom_text_field.dart';
import '../../utils/floating_label_outline_input_border.dart';
import '../hybrid_library_field_class.dart';
import 'bloc/hybrid_custom_search_text_field_bloc.dart';

/// A generic search text field that shows a floating overlay with filtered
/// results as the user types.
///
/// The field is backed by [HybridCustomSearchTextFieldBloc]. The full item list is
/// loaded on init, and filtering is delegated to the bloc through
/// [HybridCustomTextFieldSearchChanged] and [HybridCustomTextFieldSearchTapped].
///
/// **Filtering** is done with the [displayedText] callback — the bloc compares
/// each item's display string against the typed query using `contains`.
///
/// **Sorting** is applied when the user taps the field and is configured via
/// [HybridSearchTextFieldConfig.sortOrder]. For numeric sorts, provide
/// [sortValue] to extract the comparable number from each item.
class HybridCustomSearchTextField<T> extends HybridLibraryField {
  /// Placeholder text shown inside the field when it is empty.
  final String? hint;

  /// Floating label displayed inside the [InputDecoration].
  final String? label;

  /// Supporting text rendered below the field when there is no error.
  final String? bottom;

  /// Descriptive text rendered above the field.
  /// Color switches to [HybridSearchTextFieldTheme.errorTextColor] on error.
  final String? info;

  /// Optional external controller. An internal instance is created when `null`.
  final TextEditingController? controller;

  /// Callback triggered when the user changes the text.
  final void Function(HybridFieldState)? onChanged;

  /// Called when the user taps the field (after the bloc event is dispatched).
  final VoidCallback? onTap;

  /// Called when the user taps outside the field and focus is lost.
  final VoidCallback? onTapOutside;

  /// Controls whether the field accepts input. When `false`, the field uses
  /// disabled colors and ignores taps.
  final bool enable;

  /// Custom trailing icon. Replaces the default clear (×) button.
  final Widget? suffixIcon;

  /// Custom leading icon. Replaces the default search icon.
  final Widget? prefixIcon;

  /// Validation, keyboard behaviour and sort configuration.
  /// Falls back to a default [HybridSearchTextFieldConfig] when not provided.
  final HybridSearchTextFieldConfig config;

  /// Visual theme tokens (colors, borders, typography, results overlay, etc.).
  /// Falls back to [HybridTextField.searchTheme] when not provided.
  final HybridSearchTextFieldTheme theme;

  /// Optional external [FocusNode]. An internal node is created when `null`.
  final FocusNode? focusNode;

  /// Full list of items to search through. Loaded into the bloc on mount via
  /// [HybridCustomTextFieldSearchStarted].
  final List<T> items;

  /// Extracts the display string from an item. Used both for filtering
  /// (the bloc compares this string against the query) and for auto-populating
  /// the controller text when the user selects an item.
  final String Function(dynamic item) displayedText;

  /// Called with the selected item when the user taps a result row.
  final ValueChanged<T> onItemSelected;

  /// Optional builder for each result row. When `null`, a default [ListTile]
  /// rendered with [displayedText] is used.
  final Widget Function(T item)? itemBuilder;

  /// Stable identifier used by [HybridCustomTextFieldForm] to track this
  /// field's error state. Auto-generated when `null`.
  final String? fieldId;

  /// Creates a [HybridCustomSearchTextField].
  ///
  /// [items], [displayedText] and [onItemSelected] are required.
  /// [controller] and [focusNode] are optional.
  HybridCustomSearchTextField({
    super.key,
    this.hint,
    this.label,
    this.bottom,
    this.info,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.enable = true,
    this.suffixIcon,
    this.prefixIcon,
    HybridSearchTextFieldTheme? theme,
    HybridSearchTextFieldConfig? config,
    this.focusNode,
    this.fieldId,
    required this.items,
    required this.displayedText,
    required this.onItemSelected,
    this.itemBuilder,
  }) : theme = theme ?? HybridTextField.searchTheme,
       config = config ?? HybridSearchTextFieldConfig();

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = HybridTextField.searchConfig.mergeWith(config);

    return BlocProvider(
      create: (_) =>
          HybridCustomSearchTextFieldBloc(config: effectiveConfig)
            ..add(HybridCustomSearchTextFieldStarted(items: items)),
      child: _HybridCustomSearchTextFieldView<T>(parent: this, effectiveConfig: effectiveConfig),
    );
  }
}

class _HybridCustomSearchTextFieldView<T> extends StatefulWidget {
  final HybridCustomSearchTextField<T> parent;
  final HybridSearchTextFieldConfig effectiveConfig;

  const _HybridCustomSearchTextFieldView({required this.parent, required this.effectiveConfig});

  @override
  State<_HybridCustomSearchTextFieldView<T>> createState() => _HybridCustomSearchTextFieldViewState<T>();
}

class _HybridCustomSearchTextFieldViewState<T> extends State<_HybridCustomSearchTextFieldView<T>> {
  /// Focus node — either provided by the parent or created locally.
  late final FocusNode _focusNode;

  /// When `true`, error messages are shown regardless of focus state.
  bool _forceShowErrors = false;

  /// `true` once the user has typed in the field at least once.
  bool _isTouched = false;

  /// Stores the pointer-down position to distinguish a real tap from a drag
  /// in [onTapUpOutside].
  Offset _lastTapPosition = Offset.zero;

  /// Shortcut to the bloc. Reads without subscribing to rebuilds.
  HybridCustomSearchTextFieldBloc get _bloc => context.read<HybridCustomSearchTextFieldBloc>();

  /// Resolved config (global merged with widget-level).
  HybridSearchTextFieldConfig get _config => widget.effectiveConfig;

  /// [LayerLink] that anchors the overlay to the field's position on screen.
  final LayerLink _layerLink = LayerLink();

  /// Current overlay entry. `null` when the results overlay is not visible.
  OverlayEntry? _overlayEntry;

  /// Key used to measure the rendered size of the field so the overlay can
  /// match its width.
  final GlobalKey _fieldKey = GlobalKey();

  /// Controller — either provided by the parent or created locally.
  late TextEditingController _controller;

  /// Listener stored so it can be removed in [dispose].
  late final VoidCallback _controllerListener;

  /// Last value dispatched to the bloc.
  String _lastDispatchedValue = '';

  /// Stable form field id.
  late final String _formFieldId;

  /// Cached scope reference.
  HybridFormScope? _scope;

  @override
  void initState() {
    super.initState();
    _formFieldId = widget.parent.fieldId ?? UniqueKey().toString();
    _focusNode = widget.parent.focusNode ?? FocusNode();
    _controller = widget.parent.controller ?? TextEditingController();
    _controllerListener = () {
      setState(() {});
      final text = _controller.text;
      if (text != _lastDispatchedValue) {
        _lastDispatchedValue = text;
        _bloc.add(
          HybridCustomSearchTextFieldChanged(
            value: text,
            displayedText: widget.parent.displayedText,
          ),
        );
      }
    };
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_controllerListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = HybridFormScope.maybeOf(context);
    if (scope != _scope) {
      _scope = scope;
      _scope?.register(
        _formFieldId,
        onValidate: () => setState(() => _forceShowErrors = true),
        onReset: _handleReset,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_controllerListener);
    if (widget.parent.focusNode == null) _focusNode.dispose();
    if (widget.parent.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleReset() {
    _controller.clear(); // triggers _controllerListener → dispatches Changed(value: '')
    setState(() {
      _forceShowErrors = false;
      _isTouched = false;
    });
    _scope?.reportTouched(_formFieldId, false);
  }

  /// Safely removes the overlay entry and clears the reference.
  void _removeOverlay() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
    }
    _overlayEntry = null;
  }

  void _onFocusChange() => setState(() {
    if (_focusNode.hasFocus && !_isTouched) {
      _isTouched = true;
      _scope?.reportTouched(_formFieldId, true);
    }
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<HybridCustomSearchTextFieldBloc, HybridCustomSearchTextFieldState>(
      listenWhen: (prev, curr) => prev.data.hasError != curr.data.hasError,
      listener: (_, state) => _scope?.reportError(_formFieldId, state.data.hasError),
      child: _body(),
    );
  }

  BlocBuilder<HybridCustomSearchTextFieldBloc, HybridCustomSearchTextFieldState> _body() {
    return BlocBuilder<HybridCustomSearchTextFieldBloc, HybridCustomSearchTextFieldState>(
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.data.showResults && state.data.filteredItems.isNotEmpty && _focusNode.hasFocus) {
            if (_overlayEntry == null) {
              _showOverlay(state);
            } else {
              _removeOverlay();
              _showOverlay(state);
            }
          } else {
            _focusNode.addListener(() {
              if (!_focusNode.hasFocus) {
                Future.delayed(
                  const Duration(milliseconds: 150),
                  () => _removeOverlay(),
                );
              }
            });
          }
        });

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.parent.info != null) ...[
                const SizedBox(height: 4),
                _info(hasError: _shouldShowError(state.data.hasError)),
              ],
              const SizedBox(height: 8),
              _textField(state: state),
              const SizedBox(height: 5),
              if (widget.parent.bottom != null) _bottomMessage(),
              ?_errorMessage(state: state),
            ],
          ),
        );
      },
    );
  }

  Widget _info({required bool hasError}) {
    return Text(
      widget.parent.info!,
      style: widget.parent.theme.descriptionStyle.copyWith(
        color: hasError ? widget.parent.theme.errorTextColor : widget.parent.theme.descriptionColor,
      ),
    );
  }

  Widget _textField({required HybridCustomSearchTextFieldState state}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: _shouldShowDouble(_shouldShowError(state.data.hasError))
          ? BoxDecoration(
              borderRadius: widget.parent.theme.resolvedDoubleBorderRadius,
              border: Border.all(
                color: _doubleColor(_shouldShowError(state.data.hasError)),
                width: widget.parent.theme.doubleBorderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            )
          : const BoxDecoration(),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: SizedBox(
          key: _fieldKey,
          height: widget.parent.theme.containerHeight,
          child: TextFormField(
            focusNode: _focusNode,
            controller: _controller,
            validator: (value) {
              if (state.data.hasError) return state.data.errorMessage;
              return null;
            },
            enabled: widget.parent.enable,
            textAlign: widget.parent.theme.textAlign,
            textAlignVertical: widget.parent.theme.textAlignVertical,
            keyboardType: _config.keyboardType,
            textInputAction: _config.textInputAction,
            textCapitalization: _config.textCapitalization,
            inputFormatters: _config.inputFormatters,
            cursorColor: widget.parent.theme.cursorColor,
            style: widget.parent.theme.textStyle.copyWith(
              color: widget.parent.enable ? widget.parent.theme.textColor : widget.parent.theme.disabledTextColor,
            ),
            onChanged: (value) {
              if (!_isTouched) {
                setState(() => _isTouched = true);
                _scope?.reportTouched(_formFieldId, true);
              }
              widget.parent.onChanged?.call(
                HybridFieldState(
                  value: value,
                  hasError: state.data.hasError,
                  errorMessage: state.data.errorMessage,
                ),
              );
            },
            onTap: () {
              _bloc.add(
                HybridCustomSearchTextFieldTapped(
                  displayedText: widget.parent.displayedText,
                ),
              );
              widget.parent.onTap?.call();
            },
            onTapOutside: (event) {
              _bloc.add(HybridCustomSearchTextFieldDismissed());
              _lastTapPosition = event.position;
            },
            onTapUpOutside: (event) {
              if (_lastTapPosition == event.position) {
                FocusScope.of(context).unfocus();
                widget.parent.onTapOutside?.call();
              }
            },
            decoration: _inputDecoration(state),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDouble(bool hasError) {
    final s = widget.parent.theme;
    if (!widget.parent.enable) return s.doubleBorderColor != null;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor != null || s.doubleBorderColor != null;
    }
    if (hasError) {
      return s.doubleErrorBorderColor != null || s.doubleBorderColor != null;
    }
    return s.doubleBorderColor != null;
  }

  Color _doubleColor(bool hasError) {
    final s = widget.parent.theme;
    if (!widget.parent.enable) return s.doubleBorderColor ?? s.getDisabledBorderColor;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor ?? s.doubleBorderColor ?? s.getFocusedBorderColor;
    }
    if (hasError) {
      return s.doubleErrorBorderColor ?? s.doubleBorderColor ?? s.getErrorBorderColor;
    }
    return s.doubleBorderColor ?? s.getBorderColor;
  }

  InputDecoration _inputDecoration(HybridCustomSearchTextFieldState state) {
    return InputDecoration(
      isDense: false,
      filled: true,
      fillColor: widget.parent.enable ? widget.parent.theme.fillColor : widget.parent.theme.disabledFillColor,
      error: _shouldShowError(state.data.hasError) ? const SizedBox.shrink() : null,
      hintTextDirection: widget.parent.theme.hintTextDirection,
      hintMaxLines: widget.parent.theme.hintMaxLines,
      enabled: widget.parent.enable,
      hintText: widget.parent.hint,
      hintStyle: widget.parent.theme.hintStyle,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefixIcon: _prefixIcon(),
      suffixIcon: _suffixIcon(),
      labelText: widget.parent.label,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: widget.parent.theme.contentPadding,
      border: _enabledBorder(_shouldShowError(state.data.hasError)),
      enabledBorder: _enabledBorder(_shouldShowError(state.data.hasError)),
      focusedBorder: _focusedBorder(_shouldShowError(state.data.hasError)),
      disabledBorder: _disabledBorder(),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _errorBorder(),
      errorText: null,
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }

  FloatingLabelOutlineInputBorder _border(Color color, double width) {
    return FloatingLabelOutlineInputBorder(
      borderRadius: widget.parent.theme.borderRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  FloatingLabelOutlineInputBorder _enabledBorder(bool hasError) => _border(
    hasError ? widget.parent.theme.getErrorBorderColor : widget.parent.theme.getBorderColor,
    widget.parent.theme.borderWidth,
  );

  FloatingLabelOutlineInputBorder _focusedBorder(bool hasError) => _border(
    widget.parent.theme.getFocusedBorderColor,
    widget.parent.theme.focusedBorderWidth,
  );

  FloatingLabelOutlineInputBorder _disabledBorder() =>
      _border(widget.parent.theme.getDisabledBorderColor, widget.parent.theme.borderWidth);

  FloatingLabelOutlineInputBorder _errorBorder() => _border(
    _focusNode.hasFocus ? widget.parent.theme.getFocusedBorderColor : widget.parent.theme.getErrorBorderColor,
    widget.parent.theme.borderWidth,
  );

  void _showOverlay(HybridCustomSearchTextFieldState state) {
    _removeOverlay();

    final overlay = Overlay.of(context, rootOverlay: true);
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        if (!state.data.showResults || state.data.filteredItems.isEmpty) {
          return const SizedBox.shrink();
        }
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + widget.parent.theme.resultSeparation),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: _resultsList(state),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _resultsList(HybridCustomSearchTextFieldState state) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.parent.theme.resultsMaxHeight),
      decoration:
          widget.parent.theme.resultsDecoration ??
          BoxDecoration(
            color: widget.parent.theme.fillColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(blurRadius: 2, offset: const Offset(0, 1), color: Colors.black26)],
          ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: state.data.filteredItems.length,
        itemBuilder: (context, index) {
          final item = state.data.filteredItems[index] as T;
          return _resultItem(item: item, isLast: index == state.data.filteredItems.length - 1);
        },
      ),
    );
  }

  Widget _resultItem({required T item, required bool isLast}) {
    void onSelect() {
      final text = widget.parent.displayedText(item);
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
      _bloc.add(HybridCustomSearchTextFieldItemSelected(item: item));
      widget.parent.onItemSelected(item);
    }

    final content = widget.parent.itemBuilder != null
        ? InkWell(onTap: onSelect, child: widget.parent.itemBuilder!(item))
        : ListTile(
            dense: true,
            title: Text(
              widget.parent.displayedText(item),
              style: widget.parent.theme.textStyle.copyWith(
                color: widget.parent.theme.textColor,
              ),
            ),
            onTap: onSelect,
          );

    if (!widget.parent.theme.shouldShowDivider || isLast) {
      return content;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        widget.parent.theme.divider ?? const Divider(height: 1),
      ],
    );
  }

  Widget _prefixIcon() {
    if (widget.parent.prefixIcon != null) return widget.parent.prefixIcon!;
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 15),
      child: Icon(Icons.search, color: Color(0xFFBDBDBD)),
    );
  }

  Widget? _suffixIcon() {
    if (widget.parent.suffixIcon != null) return widget.parent.suffixIcon!;
    if (_focusNode.hasFocus) {
      return Padding(
        padding: EdgeInsetsGeometry.only(right: 10, left: 10),
        child: IconButton(
          icon: Icon(Icons.close, color: Color(0xFFBDBDBD)),
          onPressed: () {
            _controller.clear();
            FocusScope.of(context).unfocus();
          },
        ),
      );
    }
    return null;
  }

  Widget _bottomMessage() {
    return SizedBox(
      height: 16,
      child: Text(
        widget.parent.bottom!,
        style: widget.parent.theme.supportingTextStyle.copyWith(
          color: widget.parent.theme.supportingTextColor,
        ),
      ),
    );
  }

  bool _shouldShowError(bool hasError) {
    if (!hasError) return false;
    if (_forceShowErrors) return true;
    if (!_isTouched) return false;
    if (!_config.shouldDisplayErrorWhenClicked) return true;
    return _focusNode.hasFocus;
  }

  Widget? _errorMessage({required HybridCustomSearchTextFieldState state}) {
    if (!_shouldShowError(state.data.hasError)) return null;
    return SizedBox(
      height: 16,
      child: Text(state.data.errorMessage!, style: widget.parent.theme.errorStyle),
    );
  }
}
