import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../hybrid_custom_text_field.dart';
import '../../utils/floating_label_outline_input_border.dart';
import '../hybrid-custom-text-field-form/bloc/hybrid_custom_text_field_form_bloc.dart';
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
///
/// ### Basic usage
/// ```dart
/// HybridCustomSearchTextField<CountryEntity>(
///   hint: 'Search country',
///   items: countries,
///   displayText: (c) => c.name,
///   onItemSelected: (c) => print(c.dialCode),
///   itemBuilder: (c) => ListTile(
///     leading: Text(c.flag),
///     title: Text(c.name),
///   ),
///   config: HybridSearchTextFieldConfig(
///     sortOrder: SearchSortOrder.alphabetical,
///   ),
/// )
/// ```
class HybridCustomSearchTextField<T> extends HybridLibraryField {
  /// Placeholder text shown inside the field when it is empty.
  final String? hint;

  /// Floating label displayed inside the [InputDecoration].
  final String? label;

  /// Supporting text rendered below the field when there is no error.
  final String? bottom;

  /// Descriptive text rendered above the field.
  /// Color switches to [HybridTextFieldStyle.errorTextColor] on error.
  final String? info;

  /// Optional external controller. An internal instance is created when `null`.
  final TextEditingController? controller;

  /// Called on every keystroke with the current field value.
  final void Function(String, bool)? onChanged;

  /// Called when the user taps the field (after the bloc event is dispatched).
  final VoidCallback? onTap;

  /// Called when the user taps outside the field and focus is lost.
  final VoidCallback? onTapOutside;

  /// Controls whether the field accepts input. When `false`, the field uses
  /// disabled colors and ignores taps.
  final bool enabled;

  /// Custom trailing icon. Replaces the default clear (×) button.
  final Widget? suffixIcon;

  /// Custom leading icon. Replaces the default search icon.
  final Widget? prefixIcon;

  /// Validation, keyboard behaviour and sort configuration.
  /// Falls back to [HybridTextField.searchConfig] when not provided.
  final HybridSearchTextFieldConfig config;

  /// Visual style tokens (colors, borders, typography, etc.).
  /// Falls back to [HybridTextField.style] when not provided.
  final HybridTextFieldStyle style;

  /// Optional external [FocusNode]. An internal node is created when `null`.
  final FocusNode? focusNode;

  /// Fixed height of the [TextFormField] container in logical pixels.
  final double containerHeight;

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

  /// Maximum height of the results overlay in logical pixels. Defaults to `200`.
  /// Content beyond this limit is scrollable.
  final double resultsMaxHeight;

  /// Custom decoration for the results overlay container.
  /// Defaults to a white rounded card with a subtle shadow.
  final BoxDecoration? resultsDecoration;

  /// Whether to show a divider between each result row.
  final bool shouldShowDivider;

  /// Custom divider widget. When `null`, a default divider is used.
  final Widget? divider;

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
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    HybridTextFieldStyle? style,
    HybridSearchTextFieldConfig? config,
    this.focusNode,
    this.containerHeight = 62,
    required this.items,
    required this.displayedText,
    required this.onItemSelected,
    this.itemBuilder,
    this.resultsMaxHeight = 200,
    this.resultsDecoration,
    this.shouldShowDivider = false,
    this.divider,
  }) : style = style ?? HybridTextField.style,
       config = config ?? HybridTextField.searchConfig;

  @override
  Widget build(BuildContext context) {
    final scope = HybridFormScope.maybeOf(context);

    return BlocProvider(
      /// Provide an isolated bloc instance and immediately fire the started
      /// event so validations are loaded from the config.
      create: (_) {
        final fieldBloc = HybridCustomSearchTextFieldBloc(config: config)
          ..add(HybridCustomSearchTextFieldStarted(items: items));

        /// If inside a form, ask the form bloc to compute the merged validation
        /// list (field validations first, form validations appended).
        /// The form bloc responds with HybridCustomTextFieldFormValidationsReady,
        /// which the BlocListener below forwards to this field's bloc.
        if (scope != null) {
          scope.formBloc.add(
            HybridCustomTextFieldFormFieldStarted(
              fieldConfig: config,
              fieldId: scope.fieldId,
            ),
          );
        }

        return fieldBloc;
      },
      child: _HybridCustomSearchTextFieldView<T>(
        parent: this,
        scope: scope,
      ),
    );
  }
}

class _HybridCustomSearchTextFieldView<T> extends StatefulWidget {
  final HybridCustomSearchTextField<T> parent;
  final HybridFormScope? scope;

  const _HybridCustomSearchTextFieldView({required this.parent, this.scope});

  @override
  State<_HybridCustomSearchTextFieldView<T>> createState() => _HybridCustomSearchTextFieldViewState<T>();
}

class _HybridCustomSearchTextFieldViewState<T> extends State<_HybridCustomSearchTextFieldView<T>> {
  /// Focus node — either provided by the parent or created locally.
  late final FocusNode _focusNode;

  /// Stores the pointer-down position to distinguish a real tap from a drag
  /// in [onTapUpOutside].
  Offset _lastTapPosition = Offset.zero;

  /// Shortcut to the bloc. Reads without subscribing to rebuilds.
  HybridCustomSearchTextFieldBloc get _bloc => context.read<HybridCustomSearchTextFieldBloc>();

  /// [LayerLink] that anchors the overlay to the field's position on screen.
  final LayerLink _layerLink = LayerLink();

  /// Current overlay entry. `null` when the results overlay is not visible.
  OverlayEntry? _overlayEntry;

  /// Key used to measure the rendered size of the field so the overlay can
  /// match its width.
  final GlobalKey _fieldKey = GlobalKey();

  /// Controller — either provided by the parent or created locally.
  late TextEditingController _controller;

  @override
  void initState() {
    _focusNode = widget.parent.focusNode ?? FocusNode();
    _controller = widget.parent.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  /// Safely removes the overlay entry and clears the reference.
  void _removeOverlay() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
    }
    _overlayEntry = null;
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HybridCustomSearchTextFieldBloc, HybridCustomSearchTextFieldState>(
      listenWhen: (previous, current) => previous.data.filteredItems != current.data.filteredItems,
      listener: (context, state) {
        _controller;
      },
      child: widget.scope != null
          ? BlocListener<HybridCustomTextFieldFormBloc, HybridCustomTextFieldFormState>(
              bloc: widget.scope!.formBloc,
              listenWhen: (_, state) =>
                  state is HybridCustomTextFieldFormSuccess && state.data.fieldId == widget.scope!.fieldId,
              listener: (_, state) {
                if (state is HybridCustomTextFieldFormSuccess) {
                  _bloc.add(
                    HybridCustomBaseTextFieldFormValidationsReceived(
                      mergedValidations: state.data.validations,
                    ),
                  );
                }
              },
              child: _body(),
            )
          : _body(),
    );
  }

  BlocBuilder<HybridCustomSearchTextFieldBloc, HybridCustomSearchTextFieldState> _body() {
    return BlocBuilder<HybridCustomSearchTextFieldBloc, HybridCustomSearchTextFieldState>(
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.data.shouldShowResults && state.data.filteredItems.isNotEmpty && _focusNode.hasFocus) {
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
                _info(hasError: state.data.hasError),
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

  /// Renders the [info] label above the field.
  /// Color is [errorTextColor] on error, otherwise [descriptionColor].
  Widget _info({required bool hasError}) {
    return Text(
      widget.parent.info!,
      style: widget.parent.style.descriptionStyle.copyWith(
        color: hasError ? widget.parent.style.errorTextColor : widget.parent.style.descriptionColor,
      ),
    );
  }

  /// Builds the main text field.
  ///
  /// Wrapped in a [CompositedTransformTarget] so the floating results overlay
  /// can track the field's position via [_layerLink].
  Widget _textField({required HybridCustomSearchTextFieldState state}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: _shouldShowDoubleBorder(state.data.hasError)
          ? BoxDecoration(
              borderRadius: widget.parent.style.resolvedDoubleBorderRadius,
              border: Border.all(
                color: _doubleBorderColor(state.data.hasError),
                width: widget.parent.style.doubleBorderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            )
          : const BoxDecoration(),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: SizedBox(
          key: _fieldKey,
          height: widget.parent.containerHeight,
          child: TextFormField(
            focusNode: _focusNode,
            controller: _controller,
            validator: (value) {
              if (state.data.hasError) return state.data.errorMessage;
              return null;
            },
            enabled: widget.parent.enabled,
            textAlign: widget.parent.style.textAlign,
            textAlignVertical: widget.parent.style.textAlignVertical,
            keyboardType: widget.parent.config.keyboardType,
            textInputAction: widget.parent.config.textInputAction,
            textCapitalization: widget.parent.config.textCapitalization,
            inputFormatters: widget.parent.config.inputFormatters,
            cursorColor: widget.parent.style.cursorColor,
            style: widget.parent.style.textStyle.copyWith(
              color: widget.parent.enabled ? widget.parent.style.textColor : widget.parent.style.disabledTextColor,
            ),
            onChanged: (value) {
              _bloc.add(
                HybridCustomSearchTextFieldChanged(
                  value: value.toString(),
                  displayedText: widget.parent.displayedText,
                ),
              );
              widget.parent.onChanged?.call(value, state.data.hasError);
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

  /// Returns `true` when the outer double-border decoration should be visible.
  bool _shouldShowDoubleBorder(bool hasError) {
    final s = widget.parent.style;
    if (!widget.parent.enabled) return s.doubleBorderColor != null;
    if (_focusNode.hasFocus) {
      return s.doubleFocusedBorderColor != null || s.doubleBorderColor != null;
    }
    if (hasError) {
      return s.doubleErrorBorderColor != null || s.doubleBorderColor != null;
    }
    return s.doubleBorderColor != null;
  }

  /// Resolves the outer double-border color.
  Color _doubleBorderColor(bool hasError) {
    final s = widget.parent.style;
    if (!widget.parent.enabled) return s.doubleBorderColor ?? s.getDisabledBorderColor;
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
      fillColor: widget.parent.enabled ? widget.parent.style.fillColor : widget.parent.style.disabledFillColor,
      error: state.data.hasError ? const SizedBox.shrink() : null,
      hintTextDirection: widget.parent.style.hintTextDirection,
      hintMaxLines: widget.parent.style.hintMaxLines,
      enabled: widget.parent.enabled,
      hintText: widget.parent.hint,
      hintStyle: widget.parent.style.hintStyle,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefixIcon: _prefixIcon(),
      suffixIcon: _suffixIcon(),
      labelText: widget.parent.label,
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: widget.parent.style.contentPadding,
      border: _enabledBorder(state.data.hasError),
      enabledBorder: _enabledBorder(state.data.hasError),
      focusedBorder: _focusedBorder(state.data.hasError),
      disabledBorder: _disabledBorder(),
      errorBorder: _errorBorder(),
      focusedErrorBorder: _errorBorder(),
      errorText: null,
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }

  FloatingLabelOutlineInputBorder _border(Color color, double width) {
    return FloatingLabelOutlineInputBorder(
      borderRadius: widget.parent.style.borderRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Border shown when the field is enabled but not focused.
  FloatingLabelOutlineInputBorder _enabledBorder(bool hasError) => _border(
    hasError ? widget.parent.style.getErrorBorderColor : widget.parent.style.getBorderColor,
    widget.parent.style.borderWidth,
  );

  /// Border shown while the field is focused.
  FloatingLabelOutlineInputBorder _focusedBorder(bool hasError) => _border(
    widget.parent.style.getFocusedBorderColor,
    widget.parent.style.focusedBorderWidth,
  );

  /// Border shown when the field is disabled.
  FloatingLabelOutlineInputBorder _disabledBorder() =>
      _border(widget.parent.style.getDisabledBorderColor, widget.parent.style.borderWidth);

  /// Border used when [TextFormField] enters error state.
  FloatingLabelOutlineInputBorder _errorBorder() => _border(
    _focusNode.hasFocus ? widget.parent.style.getFocusedBorderColor : widget.parent.style.getErrorBorderColor,
    widget.parent.style.borderWidth,
  );

  /// Inserts a new [OverlayEntry] positioned directly below the field using
  /// [CompositedTransformFollower] anchored to [_layerLink].
  ///
  /// Any existing overlay is removed first so the list always reflects the
  /// current bloc state.
  void _showOverlay(HybridCustomSearchTextFieldState state) {
    _removeOverlay();

    final overlay = Overlay.of(context, rootOverlay: true);
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        if (!state.data.shouldShowResults || state.data.filteredItems.isEmpty) {
          return const SizedBox.shrink();
        }
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: _results(state),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  /// Builds the scrollable results list shown inside the overlay.
  Widget _results(HybridCustomSearchTextFieldState state) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.parent.resultsMaxHeight),
      decoration:
          widget.parent.resultsDecoration ??
          BoxDecoration(
            color: widget.parent.style.fillColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(blurRadius: 8, offset: const Offset(0, 4))],
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

  /// Builds a single result row.
  ///
  /// Uses the consumer-provided [itemBuilder] when available. Falls back to a
  /// default [ListTile] that renders [displayText].
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
              style: widget.parent.style.textStyle.copyWith(
                color: widget.parent.style.textColor,
              ),
            ),
            onTap: onSelect,
          );

    if (!widget.parent.shouldShowDivider || isLast) {
      return content;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        widget.parent.divider ?? const Divider(height: 1),
      ],
    );
  }

  /// Leading icon: consumer-provided [prefixIcon] or a default search icon.
  Widget _prefixIcon() {
    if (widget.parent.prefixIcon != null) return widget.parent.prefixIcon!;
    return Padding(
      padding: EdgeInsetsGeometry.only(left: 15),
      child: Icon(Icons.search, color: Color(0xFFBDBDBD)),
    );
  }

  /// Trailing icon:
  /// - Consumer-provided [suffixIcon] when set.
  /// - A clear (×) button when the field has focus, which clears the
  ///   controller and removes focus.
  /// - `null` when the field is not focused and no custom icon is provided.
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

  /// Supporting text shown below the field when there is no error.
  Widget _bottomMessage() {
    return SizedBox(
      height: 16,
      child: Text(
        widget.parent.bottom!,
        style: widget.parent.style.supportingTextStyle.copyWith(
          color: widget.parent.style.supportingTextColor,
        ),
      ),
    );
  }

  /// Renders the validation error message below the field.
  Widget? _errorMessage({required HybridCustomSearchTextFieldState state}) {
    return state.data.hasError && !widget.parent.config.shouldDisplayErrorWhenClicked ||
            state.data.hasError && widget.parent.config.shouldDisplayErrorWhenClicked && _focusNode.hasFocus
        ? SizedBox(
            height: 16,
            child: Text(state.data.errorMessage!, style: widget.parent.style.errorStyle),
          )
        : null;
  }
}
