import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:infosage_patient/database/user_info_repository.dart';
import 'package:infosage_patient/screens/drug_scanned.dart';
import 'package:infosage_patient/screens/medication_details_screen.dart';
import 'package:infosage_patient/utilities/fhir_utils.dart';

import '../entities/test_entities/medication.dart';


class QrScanScreen extends StatefulWidget {
  static const String route = '/scan_qr';
  const QrScanScreen({Key? key}) : super(key: key);

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Qr Code'), centerTitle: true),
      body: MobileScanner(
          allowDuplicates: false,
          onDetect: (barcode, args) async {
            String errorMessage = "Invalid QR code";
            if (barcode.rawValue == null) {
              debugPrint('Failed to scan Qr Code');
            } else {
              try {
                var data = jsonDecode(barcode.rawValue!);
                Medication medication = await ApiFhir.getMedication(data['medication']);
                if (data['substitution'] != null){
                  ApiFhir.getMedication(data['substitution']).then((substitution) {
                    Navigator.popAndPushNamed(
                        context,
                        DrugScannedScreen.route,
                        arguments: {
                          'medication': medication,
                          'substitution': substitution,
                        }
                    );
                  });
                } else {
                  ApiFhir.getMedication(data['medication']).then((medication){
                    Navigator.popAndPushNamed(
                        context,
                        MedicationDetailsScreen.route,
                        arguments: {'medication': medication}
                    );
                  });
                }
              } catch (error) {
                debugPrint(error.toString());
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                ));
              }
            }
          }),
    );
  }
}
