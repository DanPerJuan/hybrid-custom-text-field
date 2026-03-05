import 'package:flutter/material.dart';
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';

class DefaultHome extends StatefulWidget {
  const DefaultHome({super.key});

  @override
  State<DefaultHome> createState() => _DefaultHomeState();
}

class _DefaultHomeState extends State<DefaultHome> {
  @override
  Widget build(BuildContext context) {
    final countries = [
      Country('Argentina', 'AR', Icon(Icons.flag_outlined)),
      Country('Antigua', 'AG', Icon(Icons.back_hand)),
      Country('France', 'FR', Icon(Icons.dangerous)),
      Country('Germany', 'DE', Icon(Icons.earbuds)),
      Country('Spain', 'ES', Icon(Icons.cabin)),
      Country('Portugal', 'DE', Icon(Icons.face_2)),
      Country('Italy', 'DE', Icon(Icons.qr_code)),
      Country('Antarctica', 'AQ', Icon(Icons.abc)),
    ];

    final numbers = [
      1,
      4,
      3,
      5,
      9,
      6,
      2,
      7,
      8,
    ];

    bool formHasError = false;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Hybrid Custom Text Field',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              HybridCustomBaseTextField(
                info: 'Registro de usuario',
                hint: '123456789A',
                label: 'DNI',
                suffixIcon: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                  child: Icon(Icons.abc),
                ),
                onChanged: (value, hasError) {},
                bottom: 'Escribe solo el numero de tu DNI',
                controller: TextEditingController(),
                enabled: true,
                isPassword: true,
                prefixIcon: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10), child: Icon(Icons.person)),
                config: HybridBaseTextFieldConfig(
                  isRequired: true,
                  validationType: HybridTextFieldValidationType.dni,
                ),
              ),

              HybridCustomPhoneTextField(
                label: 'Telefono',
                bottom: 'Numero de telefono',
                onPrefixSelected: (country) {},
                onChanged: (phoneNumber, hasError) {
                  if (hasError) {
                    print('Kowalski tenemos un problema');
                  }
                },
                controller: TextEditingController(),
                config: HybridPhoneTextFieldConfig(
                  showDialog: false,
                  isRequired: true,
                  countryViewOptions: CountryViewOptions.countryCodeWithFlag,
                ),
              ),

              HybridCustomSearchTextField(
                controller: TextEditingController(),
                label: 'Selecciona tu pais',
                items: countries,
                displayedText: (item) => item.name,
                onItemSelected: (item) {
                  debugPrint('Selected: ${item.name}');
                },
                config: HybridSearchTextFieldConfig(
                  sortOrder: SearchSortOrder.alphabetical,
                ),
                itemBuilder: (item) {
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Row(
                      spacing: 15,
                      children: [
                        item.icon,
                        Text(item.name),
                        Spacer(),
                        Text("${item.code}€"),
                      ],
                    ),
                  );
                },
              ),

              HybridCustomSearchTextField(
                controller: TextEditingController(),
                label: 'Selecciona dias de vacaciones',
                items: numbers,
                displayedText: (item) => item.toString(),
                onItemSelected: (item) {
                  debugPrint('Selected: ${item}');
                },
                shouldShowDivider: true,
                config: HybridSearchTextFieldConfig(
                  sortOrder: SearchSortOrder.numericAscending,
                  sortValue: (item) => item,
                ),
              ),

              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Informacion de la tarjeta de credito',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              /*HybridCustomTextFieldForm(
                config: HybridFormConfig(
                  isRequired: true,
                ),
                onFormChanged: (hasError) {
                  setState(() {
                    formHasError = hasError;
                  });
                },
                children: [
                  HybridFormField(
                    child: HybridCustomBaseTextField(
                      hint: 'Nombre',
                      label: 'Nombre',
                      config: HybridBaseTextFieldConfig(),
                    ),
                  ),
                  HybridFormField(
                    child: HybridCustomBaseTextField(
                      hint: 'Email',
                      config: HybridBaseTextFieldConfig(validationType: HybridTextFieldValidationType.email),
                    ),
                  ),
                  HybridFormField(
                    child: HybridCustomPhoneTextField(label: 'Teléfono'),
                  ),
                  HybridFormField(
                    child: HybridCustomSearchTextField(
                      controller: TextEditingController(),
                      label: 'Selecciona dias de vacaciones',
                      items: numbers,
                      displayText: (item) => item.toString(),
                      onItemSelected: (item) {
                        debugPrint('Selected: ${item}');
                      },
                      config: HybridSearchTextFieldConfig(
                        sortOrder: SearchSortOrder.numericAscending,
                        sortValue: (item) => item,
                      ),
                    ),
                  ),
                ],
              ),*/
              HybridCustomTextFieldForm(
                config: HybridFormConfig(isRequired: true),
                onFormChanged: (hasError) {
                  setState(() {
                    formHasError = hasError;
                  });
                },
                children: [
                  HybridFormField(
                    child: HybridCustomBaseTextField(
                      label: 'Numero de tarjeta',
                      config: HybridBaseTextFieldConfig(
                        singleLine: true,
                        validationType: HybridTextFieldValidationType.creditCard,
                      ),
                    ),
                  ),
                  HybridFormField(
                    child: HybridCustomBaseTextField(
                      label: 'MM/AA',
                      config: HybridBaseTextFieldConfig(dateFormatterType: HybridTextFieldFormatterDateType.mmyy),
                    ),
                  ),
                  HybridFormField(
                    child: HybridCustomPhoneTextField(label: 'Teléfono'),
                  ),
                ],
              ),

              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: formHasError
                      ? WidgetStateProperty.all(Colors.grey)
                      : WidgetStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  print('Form has error: $formHasError');
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Country {
  final String name;
  final String code;
  final Icon icon;

  Country(this.name, this.code, this.icon);
}
