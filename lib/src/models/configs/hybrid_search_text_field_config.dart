import 'package:flutter/services.dart';

import '../entities/validation_text_field_entity.dart';
import 'hybrid_text_field_config.dart';

class HybridSearchTextFieldConfig extends HybridTextFieldConfig {
  /// {@macro HybridTextFieldConfig.textInputAction}
  @override
  final TextInputAction textInputAction;

  /// {@macro HybridTextFieldConfig.maxLength}
  @override
  final int? maxLength;

  /// {@macro HybridTextFieldConfig.minLength}
  @override
  final int? minLength;

  /// {@macro HybridTextFieldConfig.isRequired}
  @override
  final bool isRequired;

  /// {@macro HybridTextFieldConfig.shouldDisplayErrorWhenClicked}
  @override
  final bool shouldDisplayErrorWhenClicked;

  /// {@macro HybridTextFieldConfig.validations}
  @override
  final List<ValidationTextFieldEntity>? validations;

  /// Key board type in the field
  final TextInputType keyboardType;

  /// Optional list of [TextInputFormatter]s applied to input.
  final List<TextInputFormatter>? inputFormatters;

  /// Text capitalization behaviour.
  final TextCapitalization textCapitalization;

  /// How the filtered results are sorted after each keystroke.
  /// Defaults to [SearchSortOrder.none] — original list order.
  /// Search
  final SearchSortOrder sortOrder;

  /// Extracts a numeric value from an item for numeric sort orders.
  ///
  /// Required when [HybridSearchTextFieldConfig.sortOrder] is
  /// [SearchSortOrder.numericAscending] or [SearchSortOrder.numericDescending].
  ///
  /// ```dart
  /// sortValue: (item) => item.price,
  /// ```
  final int Function(dynamic item)? sortValue;

  HybridSearchTextFieldConfig({
    this.textInputAction = TextInputAction.search,
    this.maxLength,
    this.minLength,
    this.isRequired = false,
    this.shouldDisplayErrorWhenClicked = false,
    this.validations,
    this.sortOrder = SearchSortOrder.none,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.sortValue,
  });

  HybridSearchTextFieldConfig copyWith({
    TextInputAction? textInputAction,
    int? maxLength,
    int? minLength,
    bool? isRequired,
    bool? shouldDisplayErrorWhenClicked,
    List<ValidationTextFieldEntity>? validations,
    SearchSortOrder? sortOrder,
    int Function(dynamic item)? sortValue,
  }) {
    return HybridSearchTextFieldConfig(
      textInputAction: textInputAction ?? this.textInputAction,
      maxLength: maxLength ?? this.maxLength,
      minLength: minLength ?? this.minLength,
      isRequired: isRequired ?? this.isRequired,
      shouldDisplayErrorWhenClicked: shouldDisplayErrorWhenClicked ?? this.shouldDisplayErrorWhenClicked,
      validations: validations ?? this.validations,
      sortOrder: sortOrder ?? this.sortOrder,
      sortValue: sortValue ?? this.sortValue,
    );
  }
}

/// Defines the sort order applied to the filtered results list.
enum SearchSortOrder {
  /// No sorting — results appear in the original order of [items].
  none,

  /// Alphabetical A → Z (uses [String.compareTo]).
  alphabetical,

  /// Reverse alphabetical Z → A.
  alphabeticalReverse,

  /// Numeric ascending — smallest number first.
  /// The [sortValue] callback must return a [num] for this to work.
  numericAscending,

  /// Numeric descending — largest number first.
  /// The [sortValue] callback must return a [num] for this to work.
  numericDescending,
}
