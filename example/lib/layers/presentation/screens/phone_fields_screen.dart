import 'package:flutter/material.dart';
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';

/// Showcases [HybridCustomPhoneTextField] with different configurations:
///
/// - All [CountryViewOptions] variants
/// - Bottom sheet vs dialog picker
/// - Pre-selected country
/// - Required validation
/// - Disabled field
/// - Custom country list
class PhoneFieldsScreen extends StatefulWidget {
  const PhoneFieldsScreen({super.key});

  @override
  State<PhoneFieldsScreen> createState() => _PhoneFieldsScreenState();
}

class _PhoneFieldsScreenState extends State<PhoneFieldsScreen> {
  String _selectedCountry = '';

  // A reduced country list to demo the custom list feature
  final List<CountryEntity> _shortList = CountriesHelper.countries
      .where((c) => ['ES', 'US', 'GB', 'FR', 'DE', 'MX', 'AR', 'BR'].contains(c.code))
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── CountryViewOptions ────────────────────────────────────────────────
        _Section('CountryViewOptions'),

        _Label('countryCodeOnly (default)'),
        HybridCustomPhoneTextField(
          config: HybridPhoneTextFieldConfig(
            countryViewOptions: CountryViewOptions.countryCodeOnly,
          ),
          onChanged: (state) {},
        ),
        _Gap(),

        _Label('countryCodeWithFlag'),
        HybridCustomPhoneTextField(
          config: HybridPhoneTextFieldConfig(
            countryViewOptions: CountryViewOptions.countryCodeWithFlag,
          ),
          onChanged: (state) {},
        ),
        _Gap(),

        _Label('countryFlagOnly'),
        HybridCustomPhoneTextField(
          config: HybridPhoneTextFieldConfig(
            countryViewOptions: CountryViewOptions.countryFlagOnly,
          ),
          onChanged: (state) {},
        ),
        _Gap(),

        _Label('countryNameOnly'),
        HybridCustomPhoneTextField(
          config: HybridPhoneTextFieldConfig(
            countryViewOptions: CountryViewOptions.countryNameOnly,
          ),
          onChanged: (state) {},
        ),
        _Gap(),

        _Label('countryNameWithFlag'),
        HybridCustomPhoneTextField(
          config: HybridPhoneTextFieldConfig(
            countryViewOptions: CountryViewOptions.countryNameWithFlag,
          ),
          onChanged: (state) {},
        ),
        _Gap(height: 24),

        // ── Picker presentation ───────────────────────────────────────────────
        _Section('Presentación del selector'),

        _Label('Bottom sheet (default)'),
        HybridCustomPhoneTextField(
          label: 'Teléfono (bottom sheet)',
          config: HybridPhoneTextFieldConfig(
            showDialog: false,
            countryViewOptions: CountryViewOptions.countryCodeWithFlag,
          ),
          onChanged: (state) {},
        ),
        _Gap(),

        _Label('Dialog'),
        HybridCustomPhoneTextField(
          label: 'Teléfono (dialog)',
          config: HybridPhoneTextFieldConfig(
            showDialog: true,
            countryViewOptions: CountryViewOptions.countryCodeWithFlag,
          ),
          onChanged: (state) {},
        ),
        _Gap(height: 24),

        // ── Validation + callbacks ────────────────────────────────────────────
        _Section('Validación y callbacks'),

        HybridCustomPhoneTextField(
          label: 'Teléfono',
          bottom: 'Incluye el prefijo de tu país',
          config: HybridPhoneTextFieldConfig(
            validations: [ValidationConstants.isRequired()],
            countryViewOptions: CountryViewOptions.countryCodeWithFlag,
          ),
          onChanged: (state) {},
          onPrefixSelected: (country) {
            setState(() => _selectedCountry = '${country.flag} ${country.name} (+${country.dialCode})');
          },
        ),
        _Gap(height: 6),
        if (_selectedCountry.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'País seleccionado: $_selectedCountry',
              style: const TextStyle(fontSize: 12, color: Color(0xFF1D4ED8)),
            ),
          ),
        _Gap(height: 24),

        // ── Pre-selected country ──────────────────────────────────────────────
        _Section('País preseleccionado'),

        HybridCustomPhoneTextField(
          label: 'Teléfono (España preseleccionada)',
          config: HybridPhoneTextFieldConfig(
            countryViewOptions: CountryViewOptions.countryCodeWithFlag,
            selectedCountry: CountriesHelper.countries.firstWhere((c) => c.code == 'ES'),
          ),
          onChanged: (state) {},
        ),
        _Gap(height: 24),

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
        _Gap(height: 24),

        // ── Disabled ──────────────────────────────────────────────────────────
        _Section('Campo deshabilitado'),

        HybridCustomPhoneTextField(
          label: 'Teléfono (deshabilitado)',
          enable: false,
          config: HybridPhoneTextFieldConfig(),
          onChanged: (state) {},
        ),
        _Gap(height: 32),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
    );
  }
}

class _Gap extends StatelessWidget {
  final double height;
  const _Gap({this.height = 12});

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}
