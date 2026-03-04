import 'package:flutter/material.dart';

import '../hybrid_library_field_class.dart';

/// Marks a widget as a tracked field inside [HybridCustomTextFieldForm].
///
/// The [child] should be one of:
/// - [HybridCustomBaseTextField]
/// - [HybridCustomPhoneTextField]
/// - [HybridCustomSearchTextField]
///
/// ### Connecting to the form
/// The field itself reads [HybridFormScope.maybeOf] inside its own
/// [onChanged] callback to merge form validations and report errors.
/// All built-in Hybrid fields do this automatically.

class HybridFormField extends StatelessWidget {
  final String? id;
  final HybridLibraryField child;

  const HybridFormField({
    super.key,
    this.id,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => child;
}
