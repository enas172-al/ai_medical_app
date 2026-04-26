import 'package:ai_medical_app/core/services/processing_service.dart';
import 'package:ai_medical_app/core/models/parsed_lab_candidate.dart';

void main() {
  print('--- Testing Decision Engine ---');
  
  // 1. Glucose: 105 (Normal 70-100) -> High, Severity ?
  print(ProcessingService.computeStatus(105, 70, 100)); // High
  print(ProcessingService.computeSeverity(105, 70, 100)); // Normal (because 105 < 120)

  // 2. Glucose: 130 (Normal 70-100) -> High, Warning
  print(ProcessingService.computeStatus(130, 70, 100)); 
  print(ProcessingService.computeSeverity(130, 70, 100)); 
  
  // 3. Glucose: 400 -> Danger
  print(ProcessingService.computeSeverity(400, 70, 100));
}
