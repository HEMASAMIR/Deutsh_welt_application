import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../data/models/student_model.dart';
import '../cubit/admin_cubit.dart';

class AdminStudentEditScreen extends StatefulWidget {
  final StudentModel? student;

  const AdminStudentEditScreen({super.key, this.student});

  @override
  State<AdminStudentEditScreen> createState() => _AdminStudentEditScreenState();
}

class _AdminStudentEditScreenState extends State<AdminStudentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late String _selectedCourse;
  late bool _isActive;

  bool get _isEditing => widget.student != null;

  final List<String> _courseLevels = [
    'كورس A1 - المبتدئين',
    'كورس A2 - التأسيس',
    'كورس B1 - المتوسط',
    'كورس B2 - المتقدم',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.student?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: widget.student?.lastName ?? '');
    _emailCtrl = TextEditingController(text: widget.student?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.student?.phone ?? '');
    _selectedCourse = widget.student?.courseLevel ?? _courseLevels.first;
    _isActive = widget.student?.isActive ?? true;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AdminCubit>();

    if (_isEditing) {
      final updated = widget.student!.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        courseLevel: _selectedCourse,
        isActive: _isActive,
      );
      cubit.updateStudent(updated);
    } else {
      final newStudent = StudentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        courseLevel: _selectedCourse,
        joinedDate: DateTime.now(),
        isActive: _isActive,
      );
      cubit.addStudent(newStudent);
    }

    CustomSnackBar.show(
      context,
      message: _isEditing
          ? context.translate('student_updated')
          : context.translate('student_added'),
      type: SnackBarType.success,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing
              ? context.translate('edit_student')
              : context.translate('add_student'),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0E4C93),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _firstNameCtrl,
                label: context.translate('first_name'),
                icon: Icons.person_rounded,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? context.translate('field_required') : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameCtrl,
                label: context.translate('last_name'),
                icon: Icons.person_outline_rounded,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? context.translate('field_required') : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailCtrl,
                label: context.translate('email'),
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.translate('field_required');
                  }
                  if (!val.contains('@')) {
                    return context.translate('invalid_email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneCtrl,
                label: context.translate('phone'),
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? context.translate('field_required') : null,
              ),
              const SizedBox(height: 16),
              // Course Level Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedCourse,
                  decoration: InputDecoration(
                    labelText: context.translate('course_level'),
                    labelStyle: GoogleFonts.cairo(fontSize: 13),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.school_rounded,
                        color: AppColors.primaryBlue, size: 20),
                  ),
                  style: GoogleFonts.cairo(
                      fontSize: 14, color: AppColors.textPrimary),
                  items: _courseLevels
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level, style: GoogleFonts.cairo()),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCourse = val);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Active Switch
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isActive
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color:
                              _isActive ? AppColors.success : AppColors.error,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.translate('active_student'),
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isActive,
                      activeThumbColor: AppColors.primaryBlue,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: Icon(
                    _isEditing ? Icons.save_rounded : Icons.person_add_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isEditing
                        ? context.translate('save_changes')
                        : context.translate('add_student'),
                    style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saveStudent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primaryBlue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
