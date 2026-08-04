import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/student_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/book_model.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit() : super(AdminInitialState()) {
    loadData();
  }

  // Default book by Herr Khaled
  final List<BookModel> _books = [
    const BookModel(
      id: 'book_1',
      title: 'منهج Herr / خالد الحلواني في تعلم اللغة الألمانية',
      subtitle: 'دليلك الشامل من A1 إلى B1',
      description:
          'كتاب متكامل صممه Herr / خالد الحلواني بعد سنوات من الخبرة في تدريس اللغة الألمانية. '
          'يغطي الكتاب المستويات من A1 حتى B1 بأسلوب مبسط وممتع ومجرب.',
      price: 199.0,
      pdfUrl: 'https://drive.google.com/file/d/SAMPLE_PDF_ID/view',
      benefits: [
        'شرح تفصيلي ومبسط للألمانية 100%',
        'تغطية كاملة لمقررات A1 و A2 و B1',
        'تدريبات تفاعلية شاملة الإجابات النموذجية كاملةً',
        'جمل حوارية ألمانية جاهزة للاستخدام فوراً',
        'تحضير شامل لامتحانات الجوتة Goethe و telc و ÖSD',
        'أكثر من 200 صفحة مع رسومات توضيحية وملخصات',
      ],
      totalPages: 220,
      isAvailable: true,
      adminWhatsApp: '+201055287454',
    ),
  ];

  final List<StudentModel> _students = [
    StudentModel(
      id: '1',
      firstName: 'محمود',
      lastName: 'عبد الله',
      email: 'mahmoud@gmail.com',
      phone: '01012345678',
      courseLevel: 'كورس A1 - المبتدئين',
      joinedDate: DateTime.now().subtract(const Duration(days: 2)),
      isActive: true,
    ),
    StudentModel(
      id: '2',
      firstName: 'أحمد',
      lastName: 'حسن',
      email: 'ahmed.hassan@gmail.com',
      phone: '01122334455',
      courseLevel: 'كورس A2 - التأسيس',
      joinedDate: DateTime.now().subtract(const Duration(days: 5)),
      isActive: true,
    ),
    StudentModel(
      id: '3',
      firstName: 'سارة',
      lastName: 'محمد',
      email: 'sara.m@gmail.com',
      phone: '01298765432',
      courseLevel: 'كورس B1 - المتوسط',
      joinedDate: DateTime.now().subtract(const Duration(days: 10)),
      isActive: true,
    ),
    StudentModel(
      id: '4',
      firstName: 'عمر',
      lastName: 'خالد',
      email: 'omar.khaled@gmail.com',
      phone: '01555443322',
      courseLevel: 'كورس A1 - المبتدئين',
      joinedDate: DateTime.now().subtract(const Duration(days: 15)),
      isActive: false,
    ),
    StudentModel(
      id: '5',
      firstName: 'منى',
      lastName: 'أحمد',
      email: 'mona.a@gmail.com',
      phone: '01099887766',
      courseLevel: 'كورس B2 - المتقدم',
      joinedDate: DateTime.now().subtract(const Duration(days: 20)),
      isActive: true,
    ),
  ];

  final List<CourseModel> _courses = [
    const CourseModel(
      id: '1',
      title: 'كورس A1 - المبتدئين',
      level: 'A1',
      description: 'كورس تأسيس اللغة الألمانية من الصفر للمبتدئين',
      price: 450.0,
      enrolledCount: 42,
      isActive: true,
    ),
    const CourseModel(
      id: '2',
      title: 'كورس A2 - التأسيس',
      level: 'A2',
      description: 'تطوير مهارات المحادثة وقواعد المستوى الثاني',
      price: 550.0,
      enrolledCount: 38,
      isActive: true,
    ),
    const CourseModel(
      id: '3',
      title: 'كورس B1 - المتوسط',
      level: 'B1',
      description: 'التحضير الشامل لامتحانات الجوتة وإتقان اللغة',
      price: 700.0,
      enrolledCount: 29,
      isActive: true,
    ),
    const CourseModel(
      id: '4',
      title: 'كورس B2 - المتقدم',
      level: 'B2',
      description: 'المستوى المتقدم للعمل والدراسة في ألمانيا',
      price: 850.0,
      enrolledCount: 19,
      isActive: true,
    ),
  ];

  final List<VideoModel> _videos = [
    const VideoModel(
      id: 'v1',
      courseId: '1',
      courseTitle: 'كورس A1 - المبتدئين',
      title: 'الدرس 1: التحيات والتعارف بالألمانية',
      videoUrl: 'https://example.com/video1.mp4',
      duration: '15:30',
      lessonNumber: 1,
      isLocked: false,
    ),
    const VideoModel(
      id: 'v2',
      courseId: '1',
      courseTitle: 'كورس A1 - المبتدئين',
      title: 'الدرس 2: الأبجدية النطق الصحيح',
      videoUrl: 'https://example.com/video2.mp4',
      duration: '20:45',
      lessonNumber: 2,
      isLocked: false,
    ),
    const VideoModel(
      id: 'v3',
      courseId: '2',
      courseTitle: 'كورس A2 - التأسيس',
      title: 'الدرس 1: قواعد Grammatik المستوى الثاني',
      videoUrl: 'https://example.com/video3.mp4',
      duration: '18:10',
      lessonNumber: 1,
      isLocked: false,
    ),
    const VideoModel(
      id: 'v4',
      courseId: '3',
      courseTitle: 'كورس B1 - المتوسط',
      title: 'الدرس 1: مهارات المحادثة والتعبير B1 Sprechen',
      videoUrl: 'https://example.com/video4.mp4',
      duration: '22:15',
      lessonNumber: 1,
      isLocked: false,
    ),
    const VideoModel(
      id: 'v5',
      courseId: '4',
      courseTitle: 'كورس B2 - المتقدم',
      title: 'الدرس 1: قواعد المستوى المتقدم B2 Grammatik & Passiv',
      videoUrl: 'https://example.com/video5.mp4',
      duration: '25:40',
      lessonNumber: 1,
      isLocked: false,
    ),
    const VideoModel(
      id: 'v6',
      courseId: '4',
      courseTitle: 'كورس B2 - المتقدم',
      title: 'الدرس 2: مهارات الكتابة والمقال B2 Schreiben & Redemittel',
      videoUrl: 'https://example.com/video6.mp4',
      duration: '28:10',
      lessonNumber: 2,
      isLocked: false,
    ),
  ];

  final List<CommentModel> _comments = [
    CommentModel(
      id: 'c1',
      videoId: 'v1',
      userName: 'محمود عبد الله',
      userAvatar: '',
      courseTitle: 'كورس A1 - المبتدئين',
      commentText: 'الشرح رائع جداً يا هير، المحاضرات مبسطة والتطبيقات عملية جداً!',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isApproved: false,
    ),
    CommentModel(
      id: 'c2',
      videoId: 'v3',
      userName: 'سارة محمد',
      userAvatar: '',
      courseTitle: 'كورس B1 - المتوسط',
      commentText: 'هل في إمكانية لإضافة المزيد من التدريبات على قواعد الـ Grammatik؟',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      isApproved: false,
    ),
    CommentModel(
      id: 'c3',
      videoId: 'v2',
      userName: 'علي حسن',
      userAvatar: '',
      courseTitle: 'كورس A2 - التأسيس',
      commentText: 'بفضل الله ثم Herr / خالد الحلواني نجحت في امتحان الجوتة بتقدير ممتاز!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isApproved: true,
    ),
    CommentModel(
      id: 'c4',
      videoId: 'v1',
      userName: 'فاطمة الزهراء',
      userAvatar: '',
      courseTitle: 'كورس B2 - المتقدم',
      commentText: 'المنصة ممتازة جداً والمتابعة من التيم سهلت عليا حاجات كتير.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isApproved: true,
    ),
  ];

  void loadData() {
    emit(AdminLoadingState());
    emit(AdminLoadedState(
      students: List.from(_students),
      courses: List.from(_courses),
      videos: List.from(_videos),
      comments: List.from(_comments),
      books: List.from(_books),
    ));
  }

  // ─── Student Operations (أشخاص / طلاب) ──────────────────────────────

  void addStudent(StudentModel student) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _students.insert(0, student);
      emit(currentState.copyWith(students: List.from(_students)));
    }
  }

  void updateStudent(StudentModel updatedStudent) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      final index = _students.indexWhere((s) => s.id == updatedStudent.id);
      if (index != -1) {
        _students[index] = updatedStudent;
        emit(currentState.copyWith(students: List.from(_students)));
      }
    }
  }

  void deleteStudent(String id) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _students.removeWhere((s) => s.id == id);
      emit(currentState.copyWith(students: List.from(_students)));
    }
  }

  // ─── Course Operations (كورسات) ───────────────────────────────────

  void addCourse(CourseModel course) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _courses.insert(0, course);
      emit(currentState.copyWith(courses: List.from(_courses)));
    }
  }

  void updateCourse(CourseModel updatedCourse) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
      if (index != -1) {
        _courses[index] = updatedCourse;
        emit(currentState.copyWith(courses: List.from(_courses)));
      }
    }
  }

  void deleteCourse(String id) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _courses.removeWhere((c) => c.id == id);
      emit(currentState.copyWith(courses: List.from(_courses)));
    }
  }

  // ─── Video Operations (فيديوهات) ───────────────────────────────────

  void addVideo(VideoModel video) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _videos.insert(0, video);
      emit(currentState.copyWith(videos: List.from(_videos)));
    }
  }

  void updateVideo(VideoModel updatedVideo) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      final index = _videos.indexWhere((v) => v.id == updatedVideo.id);
      if (index != -1) {
        _videos[index] = updatedVideo;
        emit(currentState.copyWith(videos: List.from(_videos)));
      }
    }
  }

  void deleteVideo(String id) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _videos.removeWhere((v) => v.id == id);
      emit(currentState.copyWith(videos: List.from(_videos)));
    }
  }

  // ─── Comment Operations & Moderation (كومنتات) ─────────────────────

  void approveComment(String id) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      final index = _comments.indexWhere((c) => c.id == id);
      if (index != -1) {
        _comments[index] = _comments[index].copyWith(isApproved: true);
        emit(currentState.copyWith(comments: List.from(_comments)));
      }
    }
  }

  void toggleCommentApproval(String id) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      final index = _comments.indexWhere((c) => c.id == id);
      if (index != -1) {
        _comments[index] = _comments[index].copyWith(isApproved: !_comments[index].isApproved);
        emit(currentState.copyWith(comments: List.from(_comments)));
      }
    }
  }

  void addComment(CommentModel comment) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _comments.insert(0, comment);
      emit(currentState.copyWith(comments: List.from(_comments)));
    }
  }

  void updateComment(CommentModel updatedComment) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      final index = _comments.indexWhere((c) => c.id == updatedComment.id);
      if (index != -1) {
        _comments[index] = updatedComment;
        emit(currentState.copyWith(comments: List.from(_comments)));
      }
    }
  }

  void deleteComment(String id) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _comments.removeWhere((c) => c.id == id);
      emit(currentState.copyWith(comments: List.from(_comments)));
    }
  }

  // ─── Filters & Search ────────────────────────────────────────────────

  void search(String query) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  void filterByCourse(String course) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      emit(currentState.copyWith(filterCourse: course));
    }
  }

  // ─── Book Operations (كتاب الهير) ─────────────────────────────────────

  void updateBook(BookModel updatedBook) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      final index = _books.indexWhere((b) => b.id == updatedBook.id);
      if (index != -1) {
        _books[index] = updatedBook;
      }
      emit(currentState.copyWith(books: List.from(_books)));
    }
  }

  void deleteBook(String id) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _books.removeWhere((b) => b.id == id);
      emit(currentState.copyWith(books: List.from(_books)));
    }
  }

  void addBook(BookModel book) {
    if (state is AdminLoadedState) {
      final currentState = state as AdminLoadedState;
      _books.insert(0, book);
      emit(currentState.copyWith(books: List.from(_books)));
    }
  }
}
