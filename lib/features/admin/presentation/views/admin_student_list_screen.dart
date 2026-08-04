import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:herr_khaled/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:herr_khaled/features/admin/presentation/cubit/admin_state.dart';
import 'package:herr_khaled/features/admin/presentation/views/admin_student_edit_screen.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
class AdminStudentListScreen extends StatelessWidget {
  const AdminStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate('student_management'),
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: const Color(0xFF0E4C93),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: context.translate('add_student'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminStudentEditScreen(),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminLoadedState) {
            final students = state.students;
            if (students.isEmpty) {
              return Center(
                child: Text(
                  context.translate('no_students_found'),
                  style: GoogleFonts.cairo(fontSize: 16),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    tileColor: Colors.white,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF0E4C93),
                      child: Text(
                        student.firstName[0],
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${student.firstName} ${student.lastName}',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${student.email}\n${student.phone}',
                      style: GoogleFonts.cairo(fontSize: 13),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded,
                              color: Color(0xFF0E4C93)),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminStudentEditScreen(
                                student: student,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded,
                              color: Colors.redAccent),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => AlertDialog(
                                title: Text(
                                  context.translate('confirm_delete'),
                                  style: GoogleFonts.cairo(),
                                ),
                                content: Text(
                                  context.translate('delete_student_prompt'),
                                  style: GoogleFonts.cairo(),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      context.translate('cancel'),
                                      style: GoogleFonts.cairo(),
                                    ),
                                    onPressed: () => Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: Text(
                                      context.translate('delete'),
                                      style: GoogleFonts.cairo(
                                          color: Colors.redAccent),
                                    ),
                                    onPressed: () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              context.read<AdminCubit>().deleteStudent(student.id);
                              CustomSnackBar.show(
                                context,
                                message: context.translate('student_deleted'),
                                type: SnackBarType.success,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Unexpected state'));
        },
      ),
    );
  }
}
