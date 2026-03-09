import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/validation_text_field_entity.dart';
import 'hybrid_base_text_field_config.dart';

/// Configuration for [HybridCustomSearchTextField].
///
/// ### Global params (inheritable via [HybridTextField.searchConfig])
/// - [textInputAction] — keyboard action button (defaults to [TextInputAction.search])
/// - [shouldDisplayErrorWhenClicked] — show errors only while focused
/// - [textCapitalization] — OS auto-capitalisation
/// - [keyboardType] — soft keyboard layout
/// - [sortOrder] — how filtered results are sorted
///
/// ### Per-field params
/// - [validations], [sortValue]
///
/// ### Validation
///
/// All validation rules are provided via [validations]. Use [ValidationConstants]
/// to build common rules:
/// ```dart
/// config: HybridSearchTextFieldConfig(
///   validations: [ValidationConstants.isRequired()],
/// )
/// ```
///
/// > **Note on `copyWith`:** inherited base params that are not relevant to
/// > search fields (`singleLine`, `minLines`, `maxLines`, `inputFormatters`,
/// > `passwordVisibleImage`, `passwordHiddenImage`, `dateFormatterType`) are
/// > accepted for Dart override compatibility but have no effect — they are
/// > not forwarded to the search widget.
class HybridSearchTextFieldConfig extends HybridBaseTextFieldConfig {
  // ── Search global param (explicit* pattern) ────────────────────────────────

  final SearchSortOrder? explicitSortOrder;

  SearchSortOrder get sortOrder => explicitSortOrder ?? SearchSortOrder.none;

  /// Search fields default to [TextInputAction.search] instead of `done`.
  @override
  TextInputAction get textInputAction => explicitTextInputAction ?? TextInputAction.search;

  // ── Search per-field param ─────────────────────────────────────────────────

  /// Extracts a numeric value from an item for numeric sort orders.
  ///
  /// Required when [sortOrder] is [SearchSortOrder.numericAscending] or
  /// [SearchSortOrder.numericDescending].
  final int Function(dynamic item)? sortValue;

  /// Creates a [HybridSearchTextFieldConfig].
  ///
  /// Only exposes params that are relevant to the search text field widget.
  HybridSearchTextFieldConfig({
    // Base global params relevant to search
    TextInputAction? textInputAction,
    bool? shouldDisplayErrorWhenClicked,
    TextCapitalization? textCapitalization,
    TextInputType? keyboardType,
    // Base per-field params relevant to search
    List<ValidationTextFieldEntity>? validations,
    // Search global param
    SearchSortOrder? sortOrder,
    // Search per-field param
    this.sortValue,
  })  : explicitSortOrder = sortOrder,
        super(
          textInputAction: textInputAction,
          shouldDisplayErrorWhenClicked: shouldDisplayErrorWhenClicked,
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          validations: validations,
        );

  /// Merges [this] (global search config) with [other] (widget-level config).
  ///
  /// Only propagates params that are relevant to the search widget.
  @override
  HybridSearchTextFieldConfig mergeWith(HybridBaseTextFieldConfig? other) {
    if (other == null) return this;
    final base = super.mergeWith(other);
    final otherSearch = other is HybridSearchTextFieldConfig ? other : null;
    return HybridSearchTextFieldConfig(
      // Base global (search-relevant)
      textInputAction: base.explicitTextInputAction,
      shouldDisplayErrorWhenClicked: base.explicitShouldDisplayErrorWhenClicked,
      textCapitalization: base.explicitTextCapitalization,
      keyboardType: base.explicitKeyboardType,
      // Base per-field (search-relevant, widget wins)
      validations: other.validations,
      // Search global (widget wins if set)
      sortOrder: otherSearch?.explicitSortOrder ?? explicitSortOrder,
      // Search per-field (widget wins)
      sortValue: otherSearch?.sortValue ?? sortValue,
    );
  }

  /// Returns a copy of this config with the given fields replaced.
  ///
  /// Params from the base class that are not relevant to the search widget
  /// (`singleLine`, `minLines`, `maxLines`, `inputFormatters`,
  /// `passwordVisibleImage`, `passwordHiddenImage`, `dateFormatterType`) are
  /// accepted for Dart override compatibility but have no effect.
  @override
  HybridSearchTextFieldConfig copyWith({
    // Base global — search-relevant
    TextInputAction? textInputAction,
    bool? shouldDisplayErrorWhenClicked,
    TextCapitalization? textCapitalization,
    TextInputType? keyboardType,
    // Base per-field — search-relevant
    List<ValidationTextFieldEntity>? validations,
    // Base per-field — accepted for override compat., not forwarded
    bool? singleLine,
    int? minLines,
    int? maxLines,
    List<TextInputFormatter>? inputFormatters,
    Widget? passwordVisibleImage,
    Widget? passwordHiddenImage,
    HybridTextFieldFormatterDateType? dateFormatterType,
    // Search-specific
    SearchSortOrder? sortOrder,
    int Function(dynamic item)? sortValue,
  }) {
    return HybridSearchTextFieldConfig(
      textInputAction: textInputAction ?? explicitTextInputAction,
      shouldDisplayErrorWhenClicked:
          shouldDisplayErrorWhenClicked ?? explicitShouldDisplayErrorWhenClicked,
      textCapitalization: textCapitalization ?? explicitTextCapitalization,
      keyboardType: keyboardType ?? explicitKeyboardType,
      validations: validations ?? this.validations,
      sortOrder: sortOrder ?? explicitSortOrder,
      sortValue: sortValue ?? this.sortValue,
    );
  }
}

/// Defines the sort order applied to the filtered results list.
enum SearchSortOrder {
  /// No sorting — results appear in the original order of [items].
  none,

  /// Alphabetical A → Z.
  alphabetical,

  /// Reverse alphabetical Z → A.
  alphabeticalReverse,

  /// Numeric ascending — smallest number first.
  /// Requires [HybridSearchTextFieldConfig.sortValue].
  numericAscending,

  /// Numeric descending — largest number first.
  /// Requires [HybridSearchTextFieldConfig.sortValue].
  numericDescending,
}
