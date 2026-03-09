import 'package:flutter/material.dart';
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';

/// Showcases [HybridCustomSearchTextField] with different configurations:
///
/// - Default (no sort)
/// - Alphabetical sort
/// - Reverse alphabetical sort
/// - Numeric ascending sort
/// - Custom item builder
/// - With validation (required)
/// - Disabled field
class SearchFieldsScreen extends StatefulWidget {
  const SearchFieldsScreen({super.key});

  @override
  State<SearchFieldsScreen> createState() => _SearchFieldsScreenState();
}

class _SearchFieldsScreenState extends State<SearchFieldsScreen> {
  String _selectedLanguage = '';
  String _selectedCity = '';

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

  final List<_City> _cities = const [
    _City('Madrid', 3305000),
    _City('Barcelona', 1620000),
    _City('Valencia', 791000),
    _City('Sevilla', 684000),
    _City('Zaragoza', 681000),
    _City('Málaga', 574000),
    _City('Murcia', 453000),
    _City('Palma', 416000),
    _City('Las Palmas', 378000),
    _City('Bilbao', 346000),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Sort orders ───────────────────────────────────────────────────────
        _Section('Orden de resultados'),

        _Label('none — orden original de la lista'),
        HybridCustomSearchTextField<_Language>(
          hint: 'Buscar idioma (sin ordenar)...',
          items: _languages,
          displayedText: (item) => item.name,
          onItemSelected: (item) => setState(() => _selectedLanguage = item.name),
          config: HybridSearchTextFieldConfig(sortOrder: SearchSortOrder.none),
        ),
        _Gap(),

        _Label('alphabetical — A → Z'),
        HybridCustomSearchTextField<_Language>(
          hint: 'Buscar idioma (A→Z)...',
          items: _languages,
          displayedText: (item) => item.name,
          onItemSelected: (item) => setState(() => _selectedLanguage = item.name),
          config: HybridSearchTextFieldConfig(sortOrder: SearchSortOrder.alphabetical),
        ),
        _Gap(),

        _Label('alphabeticalReverse — Z → A'),
        HybridCustomSearchTextField<_Language>(
          hint: 'Buscar idioma (Z→A)...',
          items: _languages,
          displayedText: (item) => item.name,
          onItemSelected: (item) => setState(() => _selectedLanguage = item.name),
          config: HybridSearchTextFieldConfig(sortOrder: SearchSortOrder.alphabeticalReverse),
        ),
        _Gap(height: 6),
        if (_selectedLanguage.isNotEmpty) _InfoChip('Seleccionado: $_selectedLanguage'),
        _Gap(height: 24),

        // ── Numeric sort ──────────────────────────────────────────────────────
        _Section('Orden numérico'),

        _Label('numericDescending — mayor población primero'),
        HybridCustomSearchTextField<_City>(
          hint: 'Buscar ciudad...',
          items: _cities,
          displayedText: (item) => item.name,
          onItemSelected: (item) => setState(() => _selectedCity = item.name),
          config: HybridSearchTextFieldConfig(
            sortOrder: SearchSortOrder.numericDescending,
            sortValue: (item) => (item as _City).population,
          ),
          itemBuilder: (city) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    city.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '${(city.population / 1000).toStringAsFixed(0)}k hab.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ),
        _Gap(height: 6),
        if (_selectedCity.isNotEmpty) _InfoChip('Seleccionado: $_selectedCity'),
        _Gap(height: 24),

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
        _Gap(height: 24),

        // ── With validation ───────────────────────────────────────────────────
        _Section('Con validación'),

        HybridCustomSearchTextField<_Language>(
          label: 'Idioma (obligatorio)',
          hint: 'Selecciona un idioma...',
          info: 'Selecciona tu idioma preferido',
          items: _languages,
          displayedText: (item) => item.name,
          onItemSelected: (item) {},
          config: HybridSearchTextFieldConfig(
            validations: [ValidationConstants.isRequired()],
            sortOrder: SearchSortOrder.alphabetical,
          ),
        ),
        _Gap(height: 24),

        // ── Disabled ──────────────────────────────────────────────────────────
        _Section('Campo deshabilitado'),

        HybridCustomSearchTextField<_Language>(
          label: 'Idioma (deshabilitado)',
          enable: false,
          items: _languages,
          displayedText: (item) => item.name,
          onItemSelected: (item) {},
          config: HybridSearchTextFieldConfig(),
        ),
        _Gap(height: 32),
      ],
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _Language {
  final String name;
  final String flag;
  final String code;
  final int rank;

  const _Language(this.name, this.flag, this.code, this.rank);
}

class _City {
  final String name;
  final int population;

  const _City(this.name, this.population);
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

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF1D4ED8))),
    );
  }
}

class _Gap extends StatelessWidget {
  final double height;
  const _Gap({this.height = 12});

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}
