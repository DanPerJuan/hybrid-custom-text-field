import 'package:flutter/material.dart';
import 'package:hybrid_custom_text_field/hybrid_custom_text_field.dart';

class DefaultHome extends StatelessWidget {
  const DefaultHome({super.key});

  @override
  Widget build(BuildContext context) {
    final countries = [
      Country('Argentina', 'AR', Icon(Icons.flag_outlined)),
      Country('Antigua', 'AG', Icon(Icons.back_hand)),
      Country('Spain', 'ES', Icon(Icons.cabin)),
      Country('France', 'FR', Icon(Icons.dangerous)),
      Country('Germany', 'DE', Icon(Icons.earbuds)),
      Country('Germany', 'DE', Icon(Icons.face)),
      Country('Germany', 'DE', Icon(Icons.face_2)),
      Country('Germany', 'DE', Icon(Icons.qr_code)),
      Country('Antarctica', 'AQ', Icon(Icons.abc)),
      Country('Germany', 'DE', Icon(Icons.battery_2_bar)),
    ];

    final collages = [
      Collage('Argentina', 1, Icon(Icons.flag_outlined)),
      Collage('Antigua', 2, Icon(Icons.back_hand)),
      Collage('Spain', 4, Icon(Icons.cabin)),
      Collage('France', 7, Icon(Icons.dangerous)),
      Collage('Germany', 9, Icon(Icons.earbuds)),
      Collage('Germany', 5, Icon(Icons.face)),
      Collage('Germany', 8, Icon(Icons.face_2)),
      Collage('Germany', 11, Icon(Icons.qr_code)),
      Collage('Antarctica', 3, Icon(Icons.abc)),
      Collage('Germany', 0, Icon(Icons.battery_2_bar)),
    ];

    return Scaffold(
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
              info: 'Registro del usuario',
              hint: '123456789',
              label: 'DNI',
              //containerHeight: 100,
              suffixIcon: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                child: Icon(Icons.abc),
              ), // si esta el de contraseña no funciona
              bottom: 'Escribe solo el numero de tu DNI',
              controller: TextEditingController(),
              enable: true, // no cambia pero no te deja clicar
              isPassword: false, // añadir el poder cambiar el icono de la contraseña
              prefixIcon: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10), child: Icon(Icons.person)),
              config: HybridBaseTextFieldConfig(isRequired: true, minLength: 2, maxLength: 5),
            ),

            /*HybridCustomBaseTextField(
              label: 'Nombre (Opcional)',
              //containerHeight: 100,
              suffixIcon: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                child: Icon(Icons.abc),
              ), // si esta el de contraseña no funciona
              controller: TextEditingController(),
              enable: true, // no cambia pero no te deja clicar
              isPassword: false, // añadir el poder cambiar el icono de la contraseña
              prefixIcon: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10), child: Icon(Icons.person)),
              config: HybridBaseTextFieldConfig(isRequired: false, minLength: 2, maxLength: 5),
            ),*/
            HybridCustomPhoneTextField(
              label: 'Telefono',
              info: 'Informacion del telefono',
              bottom: 'Numero de telefono',
              onPrefixSelected: (country) {},
              onChanged: (phoneNumber) {},
              controller: TextEditingController(),
              showDialog: true,
              config: HybridPhoneTextFieldConfig(
                isRequired: true,
                countryViewOptions: CountryViewOptions.countryCodeWithFlag,
              ),
            ),

            HybridCustomSearchTextField(
              controller: TextEditingController(),
              label: 'Selecciona tu pais',
              items: countries,
              displayText: (item) => item.name,
              onItemSelected: (item) {
                debugPrint('Selected: ${item.name}');
              },
              config: HybridSearchTextFieldConfig(
                sortOrder: SearchSortOrder.alphabetical,
              ),
            ),

            HybridCustomSearchTextField(
              controller: TextEditingController(),
              label: 'Selecciona el numero',
              items: collages,
              displayText: (item) => item.name,
              onItemSelected: (item) {
                debugPrint('Selected: ${item.name}');
              },
              itemBuilder: (item) {
                return Card(
                  child: Row(
                    spacing: 15,
                    children: [
                      item.icon,
                      Text(item.name),
                      Spacer(),
                      Text("${item.phone}€"),
                      SizedBox(width: 10),
                    ],
                  ),
                );
              },
              sortValue: (item) => item.phone,
              config: HybridSearchTextFieldConfig(
                sortOrder: SearchSortOrder.numericAscending,
              ),
            ),
          ],
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

class Collage {
  final String name;
  final int phone;
  final Icon icon;

  Collage(this.name, this.phone, this.icon);
}
