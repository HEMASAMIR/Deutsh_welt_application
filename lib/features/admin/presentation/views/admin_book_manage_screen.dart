import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../books/data/models/book_api_model.dart';
import '../../../books/presentation/cubit/admin_books_cubit.dart';
import '../../../books/presentation/cubit/admin_books_state.dart';

class AdminBookManageScreen extends StatelessWidget {
  const AdminBookManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminBooksCubit>()..fetchAllBooks(),
      child: const _AdminBookManageBody(),
    );
  }
}

class _AdminBookManageBody extends StatelessWidget {
  const _AdminBookManageBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/deutsch_welt.jpeg',
                height: 28,
                width: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.menu_book_rounded),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'إدارة الكتب (Admin)',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'تحديث القائمة',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            onPressed: () => context.read<AdminBooksCubit>().fetchAllBooks(),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add_rounded, color: AppColors.success, size: 20),
            label: Text(
              'إضافة كتاب',
              style: GoogleFonts.cairo(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _openAddBookDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AdminBooksCubit, AdminBooksState>(
        listener: (context, state) {
          if (state is AdminBookOperationSuccess) {
            CustomSnackBar.show(context, message: state.message, type: SnackBarType.success);
          } else if (state is AdminBookOperationError) {
            CustomSnackBar.show(context, message: state.message, type: SnackBarType.error);
          } else if (state is AdminBooksError) {
            CustomSnackBar.show(context, message: state.message, type: SnackBarType.error);
          }
        },
        builder: (context, state) {
          // ── Determine what list to show ──────────────────────────────────
          List<AdminBookApiModel> books = [];
          bool isRefreshing = false;

          if (state is AdminBooksLoaded) {
            books = state.books;
          } else if (state is AdminBooksLoading) {
            books = state.cachedBooks;
            isRefreshing = books.isEmpty; // full-screen spinner only on first load
          } else if (state is AdminBookOperationLoading) {
            books = state.cachedBooks;
          } else if (state is AdminBookUsersLoaded) {
            // keep showing books list if we have cached data
            books = context.read<AdminBooksCubit>().state is AdminBooksLoaded
                ? (context.read<AdminBooksCubit>().state as AdminBooksLoaded).books
                : [];
          }

          // Full-screen initial loading spinner
          if (isRefreshing && books.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error with no cached data
          if (state is AdminBooksError && books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: GoogleFonts.cairo(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AdminBooksCubit>().fetchAllBooks(),
                    child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            );
          }

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books_outlined, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('لا توجد كتب مضافة بعد', style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: Text('أضف أول كتاب', style: GoogleFonts.cairo()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _openAddBookDialog(context),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => context.read<AdminBooksCubit>().fetchAllBooks(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 200 + (index * 80)),
                      child: _AdminBookTile(book: book),
                    );
                  },
                ),
              ),
              // Subtle top loading bar when refreshing with cached data
              if (isRefreshing || state is AdminBookOperationLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    color: AppColors.primaryBlue,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openAddBookDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedLevel = 'A1';
    bool isActive = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('إضافة كتاب جديد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'اسم الكتاب',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'المستوى',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: DropdownButton<String>(
                    value: selectedLevel,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: ['A1', 'A2', 'B1', 'B2'].map((lvl) {
                      return DropdownMenuItem(value: lvl, child: Text(lvl));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedLevel = val);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'السعر (EGP)',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('متاح للطلاب (Active)', style: GoogleFonts.cairo(fontSize: 14)),
                  value: isActive,
                  onChanged: (val) => setDialogState(() => isActive = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final price = priceCtrl.text.trim();
                if (name.isEmpty || price.isEmpty) {
                  CustomSnackBar.show(context, message: 'برجاء أدخال الاسم والسعر', type: SnackBarType.warning);
                  return;
                }

                final formData = FormData.fromMap({
                  'name': name,
                  'level': selectedLevel,
                  'price': price,
                  'is_active': isActive,
                });

                Navigator.pop(dialogCtx);
                context.read<AdminBooksCubit>().createBook(formData);
              },
              child: Text('إضافة ✅', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// _AdminBookTile
// ──────────────────────────────────────────────────────────────────────────────
class _AdminBookTile extends StatelessWidget {
  final AdminBookApiModel book;

  const _AdminBookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Level badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  book.level,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  book.name,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              // Active/Inactive badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: book.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  book.isActive ? 'متاح ✅' : 'مغلق ❌',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: book.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السعر: ${book.formattedPrice}',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIcon(
                    icon: Icons.edit_rounded,
                    color: AppColors.primaryBlue,
                    tooltip: 'تعديل',
                    onTap: () => _openEditBookDialog(context, book),
                  ),
                  const SizedBox(width: 4),
                  _ActionIcon(
                    icon: Icons.people_rounded,
                    color: Colors.purple,
                    tooltip: 'صلاحيات الطلاب',
                    onTap: () => _openBookUsersDialog(context, book),
                  ),
                  const SizedBox(width: 4),
                  _ActionIcon(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.red,
                    tooltip: 'حذف',
                    onTap: () => _confirmDelete(context, book),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEditBookDialog(BuildContext context, AdminBookApiModel book) {
    final nameCtrl = TextEditingController(text: book.name);
    final priceCtrl = TextEditingController(text: book.price);
    String selectedLevel = ['A1', 'A2', 'B1', 'B2'].contains(book.level) ? book.level : 'A1';
    bool isActive = book.isActive;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل الكتاب 📝', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'اسم الكتاب',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'المستوى',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: DropdownButton<String>(
                    value: selectedLevel,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: ['A1', 'A2', 'B1', 'B2'].map((lvl) {
                      return DropdownMenuItem(value: lvl, child: Text(lvl));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedLevel = val);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'السعر الجديد (EGP) 💰',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('متاح للبيع والتصفح (Active)', style: GoogleFonts.cairo(fontSize: 14)),
                  value: isActive,
                  onChanged: (val) => setDialogState(() => isActive = val),
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price = priceCtrl.text.trim();

                final formData = FormData.fromMap({
                  'name': name,
                  'level': selectedLevel,
                  'price': price,
                  'is_active': isActive,
                });

                Navigator.pop(dialogCtx);
                context.read<AdminBooksCubit>().editBook(book.id, formData);
              },
              child: Text('حفظ التعديلات', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openBookUsersDialog(BuildContext context, AdminBookApiModel book) {
    final userIdCtrl = TextEditingController();

    // Trigger fetching users for this book
    context.read<AdminBooksCubit>().fetchBookUsers(book.id);

    showDialog(
      context: context,
      builder: (ctx) => BlocBuilder<AdminBooksCubit, AdminBooksState>(
        builder: (ctx, state) {
          final users = state is AdminBookUsersLoaded && state.bookId == book.id
              ? state.users
              : <BookUserAccess>[];
          final isLoadingUsers = state is AdminBooksLoading || state is AdminBookOperationLoading;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.people_alt_rounded, color: Colors.purple, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'صلاحيات: ${book.name}',
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grant access row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: userIdCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'User ID للطالب',
                            isDense: true,
                            prefixIcon: const Icon(Icons.person_search_rounded, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final uid = int.tryParse(userIdCtrl.text.trim());
                          if (uid != null) {
                            ctx.read<AdminBooksCubit>().grantAccess(bookId: book.id, userId: uid);
                            userIdCtrl.clear();
                          }
                        },
                        child: Text('منح 🔓', style: GoogleFonts.cairo(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الطلاب الذين لديهم وصول:',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  if (isLoadingUsers)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (users.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'لا يوجد طلاب لديهم وصول حالياً',
                        style: GoogleFonts.cairo(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final u = users[i];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                              child: Text(
                                u.displayName.isNotEmpty ? u.displayName[0] : '?',
                                style: GoogleFonts.cairo(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                            title: Text(u.displayName, style: GoogleFonts.cairo(fontSize: 13)),
                            subtitle: Text(u.userEmail, style: GoogleFonts.cairo(fontSize: 11)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded,
                                  color: Colors.red, size: 20),
                              tooltip: 'سحب الصلاحية',
                              onPressed: () {
                                ctx.read<AdminBooksCubit>().revokeAccess(
                                    bookId: book.id, userId: u.userId);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إغلاق', style: GoogleFonts.cairo()),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminBookApiModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تأكيد الحذف', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            const SizedBox(height: 12),
            Text(
              'هل أنت متأكد من حذف كتاب\n"${book.name}"؟\n\nهذا الإجراء لا يمكن التراجع عنه.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBooksCubit>().deleteBook(book.id);
            },
            child: Text('حذف نهائياً 🗑️', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Small reusable icon action button
// ──────────────────────────────────────────────────────────────────────────────
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
