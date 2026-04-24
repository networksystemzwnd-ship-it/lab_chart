import 'package:lab_chart/features/lab/domain/entities/student_assignment.dart';

import '../entities/lab_system.dart';

// The "Contract"
abstract class LabRepository {
  // Returns a list of systems (or a specific Failure/Success type like Dartz)
  Future<List<LabSystem>> getLabSystems();

  // Saves an assignment
  Future<void> assignStudent(String systemId, StudentAssignment assignment);

  // Updates an existing assignment for a system
  Future<void> updateStudentAssignment(
    String systemId,
    StudentAssignment oldAssignment,
    StudentAssignment updatedAssignment,
  );

  // Deletes an assignment from a system
  Future<void> deleteStudentAssignment(
    String systemId,
    StudentAssignment assignment,
  );
}
