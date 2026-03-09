# hybrid_custom_text_field

<p align="center">
<img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/banner.png" width="100%" alt="Banner">
</p>

A Flutter library that provides three fully-featured text field widgets — base, phone and search — with built-in BLoC-powered validation, a global configuration/theme singleton, form integration and a typed state contract for callbacks.

---

## Table of contents

- [Installation](#installation)
- [Global setup](#global-setup)
- [Widgets](#widgets)
  - [HybridCustomBaseTextField](#hybridcustombasetextfield)
  - [HybridCustomPhoneTextField](#hybridcustomphonetextfield)
  - [HybridCustomSearchTextField](#hybridcustomsearchtextfield)
  - [HybridCustomTextFieldForm](#hybridcustomtextfieldform)
- [Configuration](#configuration)
  - [HybridBaseTextFieldConfig](#hybridbasetextfieldconfig)
  - [HybridPhoneTextFieldConfig](#hybridphonetextfieldconfig)
  - [HybridSearchTextFieldConfig](#hybridsearchtextfieldconfig)
  - [Global config inheritance](#global-config-inheritance)
- [Validation](#validation)
  - [ValidationConstants](#validationconstants)
  - [Custom validators](#custom-validators)
- [Themes](#themes)
  - [HybridTextFieldTheme](#hybridtextfieldtheme)
  - [HybridPhoneTextFieldTheme](#hybridphonetextfieldtheme)
  - [HybridSearchTextFieldTheme](#hybridsearchtextfieldtheme)
- [State contracts](#state-contracts)
- [HybridFormController](#hybridformcontroller)
- [UsageAndExamples](#usage-and-examples)

---

## Installation

```yaml
dependencies:
  hybrid_custom_text_field:
    git:
      url: https://github.com/rudoapps/hybrid-custom-text-field.git
```

```dart
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';
```

---

## Global setup

Call `HybridTextField.config()` once in `main()` before `runApp`. Any param left `null` keeps its default value. Every widget falls back to these globals unless overridden at widget level.

```dart
void main() {
  HybridTextField.config(
    // ── Themes ──────────────────────────────────────────────────────────────
    theme: HybridTextFieldTheme(
      borderColor: const Color(0xFFD1D5DB),
      borderRadius: BorderRadius.circular(12),
      focusedBorderColor: const Color(0xFF2563EB),
      focusedBorderWidth: 2,
      errorBorderColor: const Color(0xFFEF4444),
      containerHeight: 58,
    ),
    phoneTheme: HybridPhoneTextFieldTheme(
      borderRadius: BorderRadius.circular(12),
      prefixesListTheme: CustomPrefixesListTheme(
        radioColor: const Color(0xFF2563EB),
      ),
    ),
    searchTheme: HybridSearchTextFieldTheme(
      borderRadius: BorderRadius.circular(12),
      showDivider: true,
    ),

    // ── Configs ─────────────────────────────────────────────────────────────
    // Global params propagate to every widget of that type.
    // Per-field params (validations, dateFormatterType, …) always come from
    // the widget-level config.
    baseConfig: HybridBaseTextFieldConfig(
      shouldDisplayErrorWhenClicked: false,
      textInputAction: TextInputAction.next,
    ),
    phoneConfig: HybridPhoneTextFieldConfig(
      countryViewOptions: CountryViewOptions.countryCodeWithFlag,
    ),
    searchConfig: HybridSearchTextFieldConfig(
      sortOrder: SearchSortOrder.alphabetical,
    ),
  );

  runApp(const MyApp());
}
```

---

## Widgets

### HybridCustomBaseTextField

A general-purpose text field with built-in validation, optional floating label, supporting/error text and a password-visibility toggle.

```dart
HybridCustomBaseTextField(
  label: 'Email',
  hint: 'user@example.com',
  config: HybridBaseTextFieldConfig(
    validations: [
      ValidationConstants.isRequired(),
      ValidationConstants.email(),
    ],
  ),
  onChanged: (HybridFieldState state) {
    print('value: ${state.value}, hasError: ${state.hasError}');
  },
)
```

| Parameter      | Type                               | Description                                          |
| -------------- | ---------------------------------- | ---------------------------------------------------- |
| `label`        | `String?`                          | Floating label inside the field                      |
| `hint`         | `String?`                          | Placeholder text                                     |
| `info`         | `String?`                          | Label above the field (turns red on error)           |
| `bottom`       | `String?`                          | Supporting text below (hidden when error is visible) |
| `config`       | `HybridBaseTextFieldConfig?`       | Validation and keyboard config                       |
| `theme`        | `HybridTextFieldTheme?`            | Visual theme (falls back to global)                  |
| `controller`   | `TextEditingController?`           | External controller (optional)                       |
| `focusNode`    | `FocusNode?`                       | External focus node (optional)                       |
| `fieldId`      | `String?`                          | Stable ID for form integration                       |
| `isPassword`   | `bool`                             | Enables obscure text + visibility toggle             |
| `enable`       | `bool`                             | Disables interaction when `false`                    |
| `prefixIcon`   | `Widget?`                          | Leading icon widget                                  |
| `suffixIcon`   | `Widget?`                          | Trailing icon (ignored when `isPassword: true`)      |
| `onChanged`    | `void Function(HybridFieldState)?` | Fired on every keystroke                             |
| `onTap`        | `VoidCallback?`                    | Fired when field is tapped                           |
| `onTapOutside` | `VoidCallback?`                    | Fired when focus is lost by tapping outside          |

---

### HybridCustomPhoneTextField

A phone number input with a tappable country-prefix selector. The country picker opens as a modal bottom sheet or dialog.

```dart
HybridCustomPhoneTextField(
  label: 'Phone',
  config: HybridPhoneTextFieldConfig(
    validations: [ValidationConstants.isRequired()],
    countryViewOptions: CountryViewOptions.countryCodeWithFlag,
    showDialog: false, // bottom sheet (default)
  ),
  onChanged: (HybridFieldState state) {},
  onPrefixSelected: (CountryEntity country) {
    print(country.dialCode);
  },
)
```

| Parameter          | Type                               | Description                          |
| ------------------ | ---------------------------------- | ------------------------------------ |
| `label`            | `String?`                          | Floating label                       |
| `info`             | `String?`                          | Label above (turns red on error)     |
| `bottom`           | `String?`                          | Supporting text below                |
| `config`           | `HybridPhoneTextFieldConfig?`      | Validation and country picker config |
| `theme`            | `HybridPhoneTextFieldTheme?`       | Visual theme (falls back to global)  |
| `controller`       | `TextEditingController?`           | External controller                  |
| `focusNode`        | `FocusNode?`                       | External focus node                  |
| `fieldId`          | `String?`                          | Stable ID for form integration       |
| `enable`           | `bool`                             | Disables field when `false`          |
| `suffixIcon`       | `Widget?`                          | Trailing icon                        |
| `onChanged`        | `void Function(HybridFieldState)?` | Fired on every keystroke             |
| `onPrefixSelected` | `Function(CountryEntity)?`         | Fired when user picks a country      |
| `onTap`            | `VoidCallback?`                    | Fired when field is tapped           |
| `onTapOutside`     | `VoidCallback?`                    | Fired on focus loss                  |

---

### HybridCustomSearchTextField

A generic search field with a floating results overlay. Results are filtered with the `displayText` callback and sorted according to `HybridSearchTextFieldConfig.sortOrder`.

```dart
HybridCustomSearchTextField<MyItem>(
  label: 'Search',
  hint: 'Type to filter…',
  items: myItems,
  displayText: (item) => item.name,
  onItemSelected: (item) => print(item.id),
  itemBuilder: (item) => ListTile(title: Text(item.name)),
  config: HybridSearchTextFieldConfig(
    sortOrder: SearchSortOrder.alphabetical,
  ),
)
```

| Parameter        | Type                               | Description                                               |
| ---------------- | ---------------------------------- | --------------------------------------------------------- |
| `items`          | `List<T>`                          | **Required.** Full list to search through                 |
| `displayText`    | `String Function(T)`               | **Required.** Extracts the searchable string from an item |
| `onItemSelected` | `ValueChanged<T>`                  | **Required.** Called when user taps a result              |
| `itemBuilder`    | `Widget Function(T)?`              | Custom row builder; uses `ListTile` when null             |
| `label`          | `String?`                          | Floating label                                            |
| `hint`           | `String?`                          | Placeholder text                                          |
| `info`           | `String?`                          | Label above (turns red on error)                          |
| `bottom`         | `String?`                          | Supporting text below                                     |
| `config`         | `HybridSearchTextFieldConfig?`     | Sort and validation config                                |
| `theme`          | `HybridSearchTextFieldTheme?`      | Visual theme (falls back to global)                       |
| `controller`     | `TextEditingController?`           | External controller                                       |
| `focusNode`      | `FocusNode?`                       | External focus node                                       |
| `fieldId`        | `String?`                          | Stable ID for form integration                            |
| `enable`         | `bool`                             | Disables field when `false`                               |
| `prefixIcon`     | `Widget?`                          | Replaces default search icon                              |
| `suffixIcon`     | `Widget?`                          | Replaces default clear (×) button                         |
| `onChanged`      | `void Function(HybridFieldState)?` | Fired on every keystroke                                  |
| `onTap`          | `VoidCallback?`                    | Fired on tap (after overlay opens)                        |
| `onTapOutside`   | `VoidCallback?`                    | Fired on focus loss                                       |

---

### HybridCustomTextFieldForm

Aggregates the validation state of any Hybrid field widgets placed in `children`. Non-Hybrid widgets (Text, Divider, etc.) are rendered as-is without any form interaction.

```dart
final _controller = HybridFormController();

HybridCustomTextFieldForm(
  controller: _controller,
  spacing: 12,
  onFormChanged: (HybridFormState form) {
    setState(() => _hasError = form.hasError);
  },
  children: [
    HybridCustomBaseTextField(
      label: 'Email',
      config: HybridBaseTextFieldConfig(
        validations: [ValidationConstants.isRequired(), ValidationConstants.email()],
      ),
    ),
    HybridCustomBaseTextField(
      label: 'Password',
      isPassword: true,
      config: HybridBaseTextFieldConfig(
        validations: [ValidationConstants.isRequired(), ValidationConstants.minLength(8)],
      ),
    ),
  ],
)

// Force all fields to display errors (e.g. on submit tap):
_controller.validate();

// Reset all fields to empty:
_controller.reset();

// Check aggregate state:
print(_controller.hasError);
print(_controller.fieldErrors); // Map<String, bool>
print(_controller.fieldTouched); // Map<String, bool>
```

| Parameter            | Type                              | Description                                 |
| -------------------- | --------------------------------- | ------------------------------------------- |
| `children`           | `List<Widget>`                    | **Required.** Child widgets                 |
| `controller`         | `HybridFormController?`           | Imperative controller                       |
| `onFormChanged`      | `void Function(HybridFormState)?` | Fired on every aggregate state change       |
| `spacing`            | `double`                          | Vertical gap between children (default `0`) |
| `mainAxisAlignment`  | `MainAxisAlignment`               | Column alignment (default `start`)          |
| `crossAxisAlignment` | `CrossAxisAlignment`              | Column alignment (default `start`)          |

#### Usage inside a `ListView` ⚠️

When the form is placed inside a `ListView` (or any lazy-scrolling widget) with an external `HybridFormController`, two rules must be followed:

**1 — Always provide a `ValueKey`.**

If any sibling widget above the form is conditionally shown/hidden (e.g. a state inspector), inserting or removing it shifts all subsequent positions in the list. Without a key, Flutter recreates the form's state at the new position, losing the connection between the controller and the form.

```dart
HybridCustomTextFieldForm(
  key: const ValueKey('my_form'), // ← required in ListView
  controller: _formController,
  children: [...],
)
```

**2 — The library handles scroll automatically.**

`HybridCustomTextFieldForm` uses `AutomaticKeepAliveClientMixin` internally: when a `controller` is provided, the form stays alive even after scrolling out of the viewport. You do not need to do anything extra — just provide the `key`.

---

## Configuration

### HybridBaseTextFieldConfig

```dart
HybridBaseTextFieldConfig(
  // ── Global params (inheritable from HybridTextField.baseConfig) ──────────
  textInputAction: TextInputAction.next,
  shouldDisplayErrorWhenClicked: false, // see "Error display behaviour" below
  textCapitalization: TextCapitalization.none,
  keyboardType: TextInputType.text,

  // ── Per-field params ─────────────────────────────────────────────────────
  validations: [
    ValidationConstants.isRequired(),
    ValidationConstants.email(),
  ],
  dateFormatterType: HybridTextFieldFormatterDateType.mmyy, // auto-formats + validates
  singleLine: true,
  minLines: 1,
  maxLines: 1,
  inputFormatters: [],
  passwordVisibleImage: Icon(Icons.visibility),
  passwordHiddenImage: Icon(Icons.visibility_off),
)
```

#### Error display behaviour — `shouldDisplayErrorWhenClicked`

| Value               | Behaviour                                                                    |
| ------------------- | ---------------------------------------------------------------------------- |
| `false` _(default)_ | Error shown after the user types at least once. Persists after losing focus. |
| `true`              | Error shown only while the field has focus. Disappears on blur.              |

Errors are **never** shown before the user first interacts with the field, regardless of this flag. The form's `validate()` call overrides this and forces errors to show immediately.

#### Date formatter types

When `dateFormatterType` is set, the matching input formatter and validation rule are applied automatically:

| Value      | Format     | Example      |
| ---------- | ---------- | ------------ |
| `mmyy`     | MM/YY      | `12/26`      |
| `mmyyyy`   | MM/YYYY    | `12/2026`    |
| `ddmmyyyy` | DD/MM/YYYY | `25/12/2026` |

<table>
<td><img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/base_date_example_1.png" width="450" alt="baseDate"></td>
<td><img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/base_date_example_1_1.png" width="425" alt="baseDate"> </td>
</table>

```dart
// ── Date formatter ────────────────────────────────────────────────────
_Section('Formateo automático de fecha'),

HybridCustomBaseTextField(
  label: 'Fecha de expiración (MM/AA)',
  hint: '12/26',
  config: HybridBaseTextFieldConfig(
    validations: [ValidationConstants.isRequired()],
    dateFormatterType: HybridTextFieldFormatterDateType.mmyy,
  ),
  onChanged: (state) {},
),

HybridCustomBaseTextField(
  label: 'Fecha de nacimiento (DD/MM/AAAA)',
  hint: '25/12/1990',
  config: HybridBaseTextFieldConfig(
    validations: [ValidationConstants.isRequired()],
    dateFormatterType: HybridTextFieldFormatterDateType.ddmmyyyy,
  ),
  onChanged: (state) {},
),
```

---

### HybridPhoneTextFieldConfig

Inherits all global params from `HybridBaseTextFieldConfig` plus phone-specific ones.

```dart
HybridPhoneTextFieldConfig(
  // ── Global params (base) ─────────────────────────────────────────────────
  textInputAction: TextInputAction.done,
  shouldDisplayErrorWhenClicked: false,

  // ── Global params (phone-specific) ───────────────────────────────────────
  countryViewOptions: CountryViewOptions.countryCodeWithFlag,
  showDialog: false, // true = Dialog, false = ModalBottomSheet

  // ── Per-field params ─────────────────────────────────────────────────────
  validations: [ValidationConstants.isRequired()],
  countries: myCustomCountryList, // override built-in list
  selectedCountry: CountriesHelper.countries.first, // pre-selected country
)
```

shouldShowDialog: false - shouldShowDialog: true

<table>
<td> <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/phone_bottom_sheet.png" width='300' alt="phoneBottomSheet"></td>
<td> <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/phone_dialog.png" width='300' alt="phoneDialog"></td>
</table>

#### `CountryViewOptions`

| Value                 | Displays          |
| --------------------- | ----------------- |
| `countryCodeOnly`     | `+34` _(default)_ |
| `countryNameOnly`     | `Spain`           |
| `countryFlagOnly`     | `🇪🇸`              |
| `countryCodeWithFlag` | `🇪🇸 +34`          |
| `countryNameWithFlag` | `🇪🇸 Spain`        |

<img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/phone_country_view_options.png" alt="phoneCountryView">

---

### HybridSearchTextFieldConfig

Inherits all global params from `HybridBaseTextFieldConfig` plus search-specific ones.

```dart
HybridSearchTextFieldConfig(
  // ── Global params (base) ─────────────────────────────────────────────────
  textInputAction: TextInputAction.search, // default for search fields
  shouldDisplayErrorWhenClicked: false,
  textCapitalization: TextCapitalization.none,
  keyboardType: TextInputType.text,

  // ── Global params (search-specific) ──────────────────────────────────────
  sortOrder: SearchSortOrder.alphabetical,

  // ── Per-field params ─────────────────────────────────────────────────────
  validations: [ValidationConstants.isRequired()],
  sortValue: (item) => item.rank, // required for numeric sort orders
)
```

#### `SearchSortOrder`

| Value                 | Description                           |
| --------------------- | ------------------------------------- |
| `none`                | Original list order _(default)_       |
| `alphabetical`        | A → Z                                 |
| `alphabeticalReverse` | Z → A                                 |
| `numericAscending`    | Smallest first — requires `sortValue` |
| `numericDescending`   | Largest first — requires `sortValue`  |

---

### Global config inheritance

Config params follow a **3-level hierarchy**: global → type → widget.

- **Global params** (`textInputAction`, `shouldDisplayErrorWhenClicked`, etc.): widget-level value wins if set, otherwise falls back to global.
- **Per-field params** (`validations`, `dateFormatterType`, etc.): always come from the widget-level config.

```dart
// Global: all fields default to TextInputAction.next
HybridTextField.config(
  baseConfig: HybridBaseTextFieldConfig(textInputAction: TextInputAction.next),
);

// Widget override: this field uses TextInputAction.done instead
HybridCustomBaseTextField(
  config: HybridBaseTextFieldConfig(textInputAction: TextInputAction.done),
)
```

---

## Validation

### ValidationConstants

All methods accept an optional `errorMessage` to override the default Spanish message.

```dart
ValidationConstants.isRequired(errorMessage: 'This field is required')
ValidationConstants.minLength(8, errorMessage: 'At least 8 characters')
ValidationConstants.maxLength(50, errorMessage: 'Max 50 characters')
ValidationConstants.minMaxLength(8, 50, errorMessage: 'Between 8 and 50 characters')
ValidationConstants.email(errorMessage: 'Invalid email')
ValidationConstants.url(errorMessage: 'Invalid URL')
ValidationConstants.dni(errorMessage: 'Invalid DNI')
ValidationConstants.creditCard(errorMessage: 'Invalid card number')
ValidationConstants.dateMMYY(errorMessage: 'Invalid date (MM/YY)')
ValidationConstants.dateMMYYYY(errorMessage: 'Invalid date (MM/YYYY)')
ValidationConstants.dateDDMMYYYY(errorMessage: 'Invalid date (DD/MM/YYYY)')
```

Rules are evaluated in list order — the **first failing rule** provides the error message.

```dart
validations: [
  ValidationConstants.isRequired(), // checked first
  ValidationConstants.email(),      // checked second (only if not empty)
]
```

### Custom validators

Create a `ValidationTextFieldEntity` with any regex:

```dart
validations: [
  ValidationConstants.isRequired(),
  ValidationTextFieldEntity(
    regex: RegExp(r'^[A-Z]{2}\d{6}$'),
    errorMessage: 'Format: 2 letters + 6 digits (e.g. AB123456)',
  ),
]
```

---

## Themes

All theme classes share the same base properties from `HybridTextFieldTheme`. Only configure the params you need — every field has sensible defaults.

### HybridTextFieldTheme

```dart
HybridTextFieldTheme(
  // ── Typography ─────────────────────────────────────────────────────────
  textStyle: TextStyle(fontSize: 16),
  hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
  errorStyle: TextStyle(fontSize: 10, color: Colors.red),
  supportingTextStyle: TextStyle(fontSize: 12),
  descriptionStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),

  // ── Colors ──────────────────────────────────────────────────────────────
  textColor: Colors.black,
  fillColor: Colors.white,
  cursorColor: Colors.black,
  errorTextColor: Colors.red,

  // ── Inner border ─────────────────────────────────────────────────────────
  borderColor: Color(0xFFD1D5DB),
  focusedBorderColor: Color(0xFF2563EB),
  errorBorderColor: Color(0xFFEF4444),
  disabledBorderColor: Colors.grey,
  borderWidth: 1.0,
  focusedBorderWidth: 2.0,
  borderRadius: BorderRadius.circular(12),

  // ── Double border (optional outer glow ring) ──────────────────────────
  doubleBorderColor: null,             // null = disabled
  doubleFocusedBorderColor: Color(0xFF93C5FD),
  doubleErrorBorderColor: Color(0xFFFCA5A5),
  doubleBorderWidth: 2.0,
  doubleBorderRadius: BorderRadius.circular(16), // auto-computed if null

  // ── Layout ───────────────────────────────────────────────────────────────
  containerHeight: 58,
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
)
```

### HybridPhoneTextFieldTheme

Extends `HybridTextFieldTheme` with:

```dart
HybridPhoneTextFieldTheme(
  // ... all HybridTextFieldTheme params ...
  prefixesListTheme: CustomPrefixesListTheme(
    radioColor: Color(0xFF2563EB),
  ),
  dialogTheme: CountryPickerDialogTheme(),
)
```

### HybridSearchTextFieldTheme

Extends `HybridTextFieldTheme` with:

```dart
HybridSearchTextFieldTheme(
  // ... all HybridTextFieldTheme params ...
  resultsMaxHeight: 200,
  resultsDecoration: BoxDecoration(...), // custom overlay container
  showDivider: true,
  divider: Divider(height: 1, color: Colors.grey),
)
```

---

## State contracts

### HybridFieldState

Passed to `onChanged` on every field.

```dart
onChanged: (HybridFieldState state) {
  print(state.value);        // current text
  print(state.hasError);     // true when any validation rule fails
  print(state.errorMessage); // message of the first failing rule, or null
}
```

### HybridFormState

Passed to `HybridCustomTextFieldForm.onFormChanged`.

```dart
onFormChanged: (HybridFormState form) {
  form.hasError;              // true when any registered field has an error
  form.fieldErrors;           // Map<fieldId, bool>
  form.fieldTouched;          // Map<fieldId, bool> — true after first interaction
}
```

---

## HybridFormController

Provides imperative control over a `HybridCustomTextFieldForm`.

```dart
final _controller = HybridFormController();

// ── Force all fields to show their errors ─────────────────────────────────
_controller.validate();

// ── Reset all fields to empty ─────────────────────────────────────────────
_controller.reset();

// ── Operate on a specific field ───────────────────────────────────────────
_controller.validate('emailFieldId');
_controller.reset('emailFieldId');

// ── Read aggregate state ──────────────────────────────────────────────────
_controller.hasError;              // bool
_controller.fieldErrors;           // Map<String, bool>
_controller.fieldTouched;          // Map<String, bool>
_controller.fieldHasError('id');   // bool
_controller.isTouched('id');       // bool

// ── Listen to state changes ───────────────────────────────────────────────
_controller.addListener(() {
  print(_controller.hasError);
});

// ── Always dispose ────────────────────────────────────────────────────────
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

> Fields inside a form auto-register using the `fieldId` widget param (auto-generated if not provided). Pass an explicit `fieldId` when you need to target a specific field via `validate(id)` or `reset(id)`.

> **`ListView` warning** — if the form is inside a `ListView`, always pass a `ValueKey` to `HybridCustomTextFieldForm`. See [Usage inside a ListView](#usage-inside-a-listview-️) for details.

## Usage and Examples

### 1. BaseTextField different simple examples

<table>
<td><img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/base_example_1.png" width="900" alt="base"></td>
<td><img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/base_example_1_1.png" width="800" alt="base1"></td>
</table>

```dart
HybridCustomBaseTextField(
  label: 'Email',
  hint: 'usuario@ejemplo.com',
  prefixIcon: const Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Icon(Icons.email_outlined, color: Color(0xFF6B7280)),
  ),
  config: HybridBaseTextFieldConfig(
    validations: [
      ValidationConstants.isRequired(),
      ValidationConstants.email(),
    ],
  ),
  onChanged: (state) => setState(() => _emailState = state.hasError ? '✗ ${state.errorMessage}' : '✓ válido'),
),
_Chip(_emailState),

HybridCustomBaseTextField(
  label: 'Contraseña',
  hint: 'Mínimo 8 caracteres',
  isPassword: true,
  config: HybridBaseTextFieldConfig(
    validations: [
      ValidationConstants.isRequired(),
      ValidationConstants.minMaxLength(8, 32),
    ],
  ),
  onChanged: (state) {},
),

HybridCustomBaseTextField(
  label: 'URL',
  hint: 'https://ejemplo.com',
  prefixIcon: const Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Icon(Icons.link_outlined, color: Color(0xFF6B7280)),
  ),
  config: HybridBaseTextFieldConfig(
    validations: [
      ValidationConstants.isRequired(),
      ValidationConstants.url(),
    ],
    keyboardType: TextInputType.url,
  ),
  onChanged: (state) {},
),

HybridCustomBaseTextField(
  label: 'DNI',
  hint: '12345678A',
  info: 'Documento Nacional de Identidad',
  bottom: '8 dígitos + 1 letra mayúscula',
  config: HybridBaseTextFieldConfig(
    validations: [
      ValidationConstants.isRequired(),
      ValidationConstants.dni(),
    ],
  ),
  onChanged: (state) {},
),
```

### 2. PhoneTextField with should show dialog false and limit countries

<div style="display: flex; flex-direction: column; gap: 10px;">
  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/phone_example_1.png" width="400" alt="phone">
  
  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/phone_example_1_1.png" width="400" alt="phone1">
</div>

```dart
// ── Custom country list ───────────────────────────────────────────────
_Section('Lista de países personalizada'),

_Label('Solo 8 países disponibles'),
HybridCustomPhoneTextField(
  label: 'Teléfono (lista reducida)',
  config: HybridPhoneTextFieldConfig(
    countryViewOptions: CountryViewOptions.countryCodeWithFlag,
    countries: _shortList,
  ),
  onChanged: (state) {},
),
```

### 3. SearchTextField with list of languages sorted by A -> Z and custom builder

<div style="display: flex; flex-direction: column; gap: 10px;">
  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/search_example_1.png" width="400" alt="search">
  
  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/search_example_1_1.png" width="400" alt="search1">
</div>

```dart
final List<_Language> _languages = const [
  _Language('Español', '🇪🇸', 'es', 1),
  _Language('English', '🇬🇧', 'en', 2),
  _Language('Français', '🇫🇷', 'fr', 3),
  _Language('Deutsch', '🇩🇪', 'de', 4),
  _Language('Italiano', '🇮🇹', 'it', 5),
  _Language('Português', '🇧🇷', 'pt', 6),
  _Language('日本語', '🇯🇵', 'ja', 7),
  _Language('中文', '🇨🇳', 'zh', 8),
  _Language('한국어', '🇰🇷', 'ko', 9),
  _Language('Русский', '🇷🇺', 'ru', 10),
  _Language('العربية', '🇸🇦', 'ar', 11),
  _Language('हिन्दी', '🇮🇳', 'hi', 12),
];

// ── Custom item builder ───────────────────────────────────────────────
_Section('Builder personalizado'),

HybridCustomSearchTextField<_Language>(
  label: 'Idioma preferido',
  hint: 'Buscar idioma...',
  items: _languages,
  displayedText: (item) => item.name,
  onItemSelected: (item) {},
  config: HybridSearchTextFieldConfig(sortOrder: SearchSortOrder.alphabetical),
  itemBuilder: (item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        spacing: 12,
        children: [
          Text(item.flag, style: const TextStyle(fontSize: 22)),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            item.code.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  },
),
```

### 4. FormTextField with validations

<table>
<td>  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/form_example_1.png" width="390" alt="search"></td>
<td>  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/form_example_1_1.png" width="400" alt="search"></td>
<td>  <img src="https://raw.githubusercontent.com/rudoapps/hybrid-hub-vault/main/flutter/images/hybrid-custom-text-field/form_example_1_2.png" width="400" alt="search"></td>
</table>

```dart
// ── Credit card form ─────────────────────────────────────────────────
_Section('Tarjeta de crédito'),
const Text(
  'Pulsa "Pagar" para validar. Prueba "Reset campo" para limpiar '
  'un campo concreto por su fieldId.',
  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
),
const SizedBox(height: 12),

HybridCustomTextFieldForm(
  key: const ValueKey('card_form'),
  controller: _cardController,
  spacing: 12,
  onFormChanged: (form) => setState(() {
    _cardForm = form;
    if (_cardSubmitted && !form.hasError) {
      _cardSubmitted = false;
    }
  }),
  children: [
    HybridCustomBaseTextField(
      label: 'Número de tarjeta',
      hint: '1234 5678 9012 3456',
      fieldId: 'card_number',
      config: HybridBaseTextFieldConfig(
        validations: [
          ValidationConstants.isRequired(),
          ValidationConstants.creditCard(),
        ],
        keyboardType: TextInputType.number,
      ),
    ),
    Row(
      spacing: 12,
      children: [
        Expanded(
          child: HybridCustomBaseTextField(
            label: 'MM/AA',
            hint: '12/26',
            fieldId: 'card_expiry',
            config: HybridBaseTextFieldConfig(
              validations: [ValidationConstants.isRequired()],
              dateFormatterType: HybridTextFieldFormatterDateType.mmyy,
            ),
          ),
        ),
        Expanded(
          child: HybridCustomBaseTextField(
            label: 'CVC',
            hint: '123',
            fieldId: 'card_cvc',
            isPassword: true,
            config: HybridBaseTextFieldConfig(
              maxLength: 3,
              validations: [
                ValidationConstants.isRequired(),
                ValidationConstants.minLength(3),
              ],
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
          ),
        ),
      ],
    ),
  ],
)
```

## Credits

Built with:

- [flutter_bloc](https://pub.dev/packages/flutter_bloc)

## Author ✒️

- **Daniela Perez Juan** - _Flutter Developer_ - [dperez@laberit.com](dperez@laberit.com)

---

With ❤️ by Laberit Flutter Team 😊

![Rudo Apps](https://rudo.es/wp-content/uploads/logo-rudo.svg)
