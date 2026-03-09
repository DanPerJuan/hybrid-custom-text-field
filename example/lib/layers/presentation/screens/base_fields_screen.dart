import 'package:flutter/material.dart';
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';

/// Showcases [HybridCustomBaseTextField] in a variety of configurations:
///
/// - Email (required + email validation)
/// - Password (required + min/max length)
/// - URL
/// - DNI
/// - Credit card number
/// - Date MM/YY with auto-formatter
/// - Multiline description
/// - Custom validator (uppercase letters only)
/// - shouldDisplayErrorWhenClicked: true  (error visible only while focused)
/// - shouldDisplayErrorWhenClicked: false (error persists after blur)
/// - Disabled field
/// - With info label and bottom text
/// - External TextEditingController
class BaseFieldsScreen extends StatefulWidget {
  const BaseFieldsScreen({super.key});

  @override
  State<BaseFieldsScreen> createState() => _BaseFieldsScreenState();
}

class _BaseFieldsScreenState extends State<BaseFieldsScreen> {
  final _externalController = TextEditingController();
  String _externalValue = '';
  String _emailState = '';

  @override
  void dispose() {
    _externalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Common validations ────────────────────────────────────────────────
        _Section('Validaciones comunes'),

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
        _Gap(),
        _Chip(_emailState),
        _Gap(),

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
        _Gap(),

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
        _Gap(),

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
        _Gap(height: 24),

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
        _Gap(),

        HybridCustomBaseTextField(
          label: 'Fecha de nacimiento (DD/MM/AAAA)',
          hint: '25/12/1990',
          config: HybridBaseTextFieldConfig(
            validations: [ValidationConstants.isRequired()],
            dateFormatterType: HybridTextFieldFormatterDateType.ddmmyyyy,
          ),
          onChanged: (state) {},
        ),
        _Gap(height: 24),

        // ── Custom validator ──────────────────────────────────────────────────
        _Section('Validador personalizado'),

        HybridCustomBaseTextField(
          label: 'Código de producto',
          hint: 'AB123456',
          info: 'Formato: 2 letras mayúsculas + 6 dígitos',
          config: HybridBaseTextFieldConfig(
            validations: [
              ValidationConstants.isRequired(),
              ValidationTextFieldEntity(
                regex: RegExp(r'^[A-Z]{2}\d{6}$'),
                errorMessage: 'Formato inválido (ej: AB123456)',
              ),
            ],
          ),
          onChanged: (state) {},
        ),
        _Gap(height: 24),

        // ── Error display behaviour ───────────────────────────────────────────
        _Section('Comportamiento del error'),

        const Text(
          'shouldDisplayErrorWhenClicked: false — el error persiste al perder el foco',
          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
        _Gap(height: 6),
        HybridCustomBaseTextField(
          label: 'Campo requerido (persiste)',
          hint: 'Escribe algo...',
          config: HybridBaseTextFieldConfig(
            shouldDisplayErrorWhenClicked: false,
            validations: [ValidationConstants.isRequired()],
          ),
          onChanged: (state) {},
        ),
        _Gap(height: 12),

        const Text(
          'shouldDisplayErrorWhenClicked: true — el error solo se muestra con foco',
          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
        _Gap(height: 6),
        HybridCustomBaseTextField(
          label: 'Campo requerido (solo con foco)',
          hint: 'Escribe algo...',
          config: HybridBaseTextFieldConfig(
            shouldDisplayErrorWhenClicked: true,
            validations: [ValidationConstants.isRequired()],
          ),
          onChanged: (state) {},
        ),
        _Gap(height: 24),

        // ── Multiline ─────────────────────────────────────────────────────────
        _Section('Multilínea'),

        HybridCustomBaseTextField(
          label: 'Descripción',
          hint: 'Cuéntanos algo sobre ti...',
          config: HybridBaseTextFieldConfig(
            singleLine: false,
            minLines: 3,
            maxLines: 5,
            validations: [ValidationConstants.maxLength(200)],
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
          ),
          onChanged: (state) {},
        ),
        _Gap(height: 24),

        // ── Disabled ──────────────────────────────────────────────────────────
        _Section('Campo deshabilitado'),

        HybridCustomBaseTextField(
          label: 'Campo de solo lectura',
          hint: 'No editable',
          enabled: false,
          config: HybridBaseTextFieldConfig(),
          onChanged: (state) {},
        ),
        _Gap(height: 24),

        // ── External controller ───────────────────────────────────────────────
        _Section('Controlador externo'),

        HybridCustomBaseTextField(
          label: 'Nombre completo',
          hint: 'Juan García',
          controller: _externalController,
          config: HybridBaseTextFieldConfig(
            validations: [
              ValidationConstants.isRequired(),
              ValidationConstants.minLength(3),
            ],
          ),
          onChanged: (state) => setState(() => _externalValue = state.value),
        ),
        _Gap(height: 8),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: () {
                  _externalController.text = 'Juan García';
                  setState(() => _externalValue = _externalController.text);
                },
                child: const Text('Rellenar'),
              ),
            ),
            Expanded(
              child: FilledButton.tonal(
                onPressed: () {
                  _externalController.clear();
                  setState(() => _externalValue = '');
                },
                child: const Text('Limpiar'),
              ),
            ),
          ],
        ),
        if (_externalValue.isNotEmpty) ...[
          _Gap(height: 4),
          _Chip('Valor: $_externalValue'),
        ],
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

class _Gap extends StatelessWidget {
  final double height;
  const _Gap({this.height = 12});

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: label.startsWith('✓') ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: label.startsWith('✓') ? const Color(0xFF166534) : const Color(0xFF991B1B),
        ),
      ),
    );
  }
}
