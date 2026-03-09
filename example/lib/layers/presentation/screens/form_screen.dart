import 'package:flutter/material.dart';
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';

/// Showcases [HybridCustomTextFieldForm] with [HybridFormController]:
///
/// - Register / login form with validate() on submit
/// - Credit card form with per-field targeted reset
/// - HybridFormState: hasError, fieldErrors, fieldTouched
/// - Controller.validate() / reset() — full and per-field
///
/// ⚠️ ListView + controller: each form has a [ValueKey] so Flutter can track
/// it by identity when a conditional sibling widget (e.g. the _StateInspector)
/// is inserted/removed and shifts surrounding positions in the list.
/// The library keeps the form alive off-screen via AutomaticKeepAliveClientMixin,
/// but the key is still required to survive position shifts.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // ── Login form ─────────────────────────────────────────────────────────────

  final _loginController = HybridFormController();
  HybridFormState? _loginForm;

  // ── Credit card form ───────────────────────────────────────────────────────

  final _cardController = HybridFormController();
  HybridFormState? _cardForm;
  bool _cardSubmitted = false;

  @override
  void dispose() {
    _loginController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // ── Login form ───────────────────────────────────────────────────────
        _Section('Formulario de acceso'),
        const Text(
          'Pulsa "Entrar" para forzar la validación de todos los campos. '
          'El estado de cada campo se muestra debajo.',
          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 12),

        HybridCustomTextFieldForm(
          key: const ValueKey('login_form'),
          controller: _loginController,
          spacing: 12,
          onFormChanged: (form) => setState(() => _loginForm = form),
          children: [
            HybridCustomBaseTextField(
              label: 'Email',
              hint: 'usuario@ejemplo.com',
              fieldId: 'login_email',
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
            ),
            SizedBox(),
            HybridCustomBaseTextField(
              label: 'Contraseña',
              hint: 'Mínimo 8 caracteres',
              fieldId: 'login_password',
              isPassword: true,
              config: HybridBaseTextFieldConfig(
                validations: [
                  ValidationConstants.isRequired(),
                  ValidationConstants.minLength(8),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Form state inspector
        if (_loginForm != null) _StateInspector(form: _loginForm!),

        const SizedBox(height: 12),

        Row(
          spacing: 8,
          children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: (_loginForm?.hasError ?? true) ? const Color(0xFF9CA3AF) : const Color(0xFF2563EB),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _loginController.validate();
                  if (!(_loginForm?.hasError ?? true)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Acceso correcto')),
                    );
                  }
                },
                child: const Text('Entrar'),
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(80, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _loginController.reset();
                setState(() => _loginForm = null);
              },
              child: const Text('Reset'),
            ),
          ],
        ),

        const SizedBox(height: 32),

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
        ),

        const SizedBox(height: 12),

        if (_cardForm != null) _StateInspector(form: _cardForm!),

        const SizedBox(height: 12),

        // Targeted reset buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SmallButton(
              label: 'Reset número',
              onTap: () => _cardController.reset('card_number'),
            ),
            _SmallButton(
              label: 'Reset fecha',
              onTap: () => _cardController.reset('card_expiry'),
            ),
            _SmallButton(
              label: 'Reset CVC',
              onTap: () => _cardController.reset('card_cvc'),
            ),
            _SmallButton(
              label: 'Reset todo',
              onTap: () {
                _cardController.reset();
                setState(() => _cardForm = null);
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: (_cardForm?.hasError ?? true) ? const Color(0xFF9CA3AF) : const Color(0xFF2563EB),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            setState(() => _cardSubmitted = true);
            _cardController.validate();
            if (!(_cardForm?.hasError ?? true)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago procesado correctamente')),
              );
            }
          },
          child: const Text(
            'Pagar',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

/// Displays the current [HybridFormState] as a small table.
class _StateInspector extends StatelessWidget {
  final HybridFormState form;
  const _StateInspector({required this.form});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row('hasError', form.hasError.toString()),
          const SizedBox(height: 4),
          ...form.fieldErrors.entries.map((e) {
            final touched = form.fieldTouched[e.key] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _Row(
                e.key,
                '${e.value ? "error" : "ok"} · ${touched ? "tocado" : "sin tocar"}',
                valueColor: e.value ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String key_;
  final String value;
  final Color? valueColor;
  const _Row(this.key_, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          key_,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 11),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

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
