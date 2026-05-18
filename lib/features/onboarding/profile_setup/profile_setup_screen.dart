import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../auth/bloc/auth_event_state.dart';
import '../../auth/bloc/auth_bloc.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Repositories
  final _universityRepo = UniversityRepository();
  final _facultyRepo = FacultyRepository();

  // Form data
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _gender;
  
  // Data from Supabase
  List<University> _universities = [];
  List<Faculty> _faculties = [];
  List<AcademicYear> _academicYears = [];
  
  University? _selectedUniversity;
  Faculty? _selectedFaculty;
  AcademicYear? _selectedAcademicYear;
  
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUniversities() async {
    setState(() => _isLoading = true);
    try {
      final universities = await _universityRepo.getAllUniversities();
      setState(() => _universities = universities);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تحميل الجامعات')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFaculties(String universityId) async {
    setState(() => _isLoading = true);
    try {
      final faculties = await _facultyRepo.getFacultiesByUniversity(universityId);
      setState(() {
        _faculties = faculties;
        _academicYears = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تحميل الكليات')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAcademicYears(String facultyId) async {
    setState(() => _isLoading = true);
    try {
      // Get faculties with years included
      final result = await _facultyRepo.getFacultiesWithYears(_selectedUniversity!.id);
      
      // Find the selected faculty and extract its years
      for (final item in result) {
        if (item['id'] == facultyId) {
          final yearsData = item['academic_years'] as List<dynamic>?;
          if (yearsData != null) {
            setState(() {
              _academicYears = yearsData
                  .map((y) => AcademicYear.fromJson(y as Map<String, dynamic>))
                  .toList();
            });
          }
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تحميل السنوات الدراسية')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0: return _firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _gender != null;
      case 1: return true; // Egypt pre-selected
      case 2: return _selectedUniversity != null;
      case 3: return _selectedFaculty != null;
      case 4: return _selectedAcademicYear != null;
      case 5: return true;
      default: return false;
    }
  }

  void _finishOnboarding() {
    // Use the AuthBloc to complete onboarding and save to Supabase
    context.read<AuthBloc>().add(CompleteOnboardingRequested(
      fullName: '${_firstNameController.text} ${_lastNameController.text}',
      gender: _gender!,
      universityId: _selectedUniversity!.id,
      facultyId: _selectedFaculty!.id,
      academicYearId: _selectedAcademicYear!.id,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Navigate to home when onboarding is complete
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${_currentStep + 1} / $_totalSteps',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentStep + 1) / _totalSteps,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoPage(),
                  _buildLocationPage(),
                  _buildUniversityPage(),
                  _buildFacultyPage(),
                  _buildAcademicYearPage(),
                  _buildWelcomePage(),
                ],
              ),
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(24),
              child: GradientButton(
                text: _currentStep == _totalSteps - 1
                    ? AppStrings.finish
                    : AppStrings.next,
                onPressed: _canProceed
                    ? (_currentStep == _totalSteps - 1 ? _finishOnboarding : _nextPage)
                    : () {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  // ============ Step 1: Personal Info ============
  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.person_outline_rounded, size: 48, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(AppStrings.personalInfo, style: Theme.of(context).textTheme.displaySmall),
          ),
          const SizedBox(height: 32),
          Text(AppStrings.firstName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(hintText: AppStrings.firstName),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.lastName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(hintText: AppStrings.lastName),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.gender, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _genderCard(AppStrings.male, Icons.male_rounded, 'male')),
              const SizedBox(width: 16),
              Expanded(child: _genderCard(AppStrings.female, Icons.female_rounded, 'female')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderCard(String label, IconData icon, String value) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: selected ? AppColors.accent : AppColors.textHint),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              color: selected ? AppColors.accent : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }

  // ============ Step 2: Location ============
  Widget _buildLocationPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.location_on_outlined, size: 48, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.location, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Row(
              children: [
                const Text('🇪🇬', style: TextStyle(fontSize: 36)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.egypt, style: Theme.of(context).textTheme.headlineMedium),
                    Text('المنطقة التعليمية', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ Step 3: University ============
  Widget _buildUniversityPage() {
    final query = _searchController.text.toLowerCase();
    final filtered = _universities.where((u) {
      final nameEn = u.nameEn ?? '';
      return u.nameAr.toLowerCase().contains(query) || nameEn.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(AppStrings.selectUniversity, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final uni = filtered[index];
                  final selected = _selectedUniversity?.id == uni.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedUniversity = uni;
                        _selectedFaculty = null;
                        _selectedAcademicYear = null;
                      });
                      // Load faculties for selected university
                      _loadFaculties(uni.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.accent : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  uni.nameAr,
                                  style: TextStyle(
                                    color: selected ? AppColors.accent : AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                if (uni.nameEn != null)
                                  Text(
                                    uni.nameEn!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                                  ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============ Step 5: Faculty ============
  Widget _buildFacultyPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(AppStrings.selectFaculty, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          if (_selectedUniversity != null)
            Text(
              _selectedUniversity!.nameAr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _faculties.length,
                itemBuilder: (context, index) {
                  final fac = _faculties[index];
                  final selected = _selectedFaculty?.id == fac.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFaculty = fac;
                        _selectedAcademicYear = null;
                      });
                      // Load academic years for selected faculty
                      _loadAcademicYears(fac.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.accent : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (fac.isPrimary)
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsetsDirectional.only(end: 10),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fac.nameAr,
                                  style: TextStyle(
                                    color: selected ? AppColors.accent : AppColors.textPrimary,
                                    fontWeight: fac.isPrimary ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                if (fac.nameEn != null)
                                  Text(
                                    fac.nameEn!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                                  ),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============ Step 6: Academic Year ============
  Widget _buildAcademicYearPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.calendar_today_rounded, size: 42, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.selectYear, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 24),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _academicYears.length,
                itemBuilder: (context, index) {
                  final year = _academicYears[index];
                  final selected = _selectedAcademicYear?.id == year.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAcademicYear = year),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.accent : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent.withValues(alpha: 0.2)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${year.yearNumber}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? AppColors.accent : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            year.nameAr,
                            style: TextStyle(
                              fontSize: 16,
                              color: selected ? AppColors.accent : AppColors.textPrimary,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          if (selected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============ Step 7: Welcome ============
  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.check_circle_outline, size: 64, color: AppColors.accent),
            ),
            const SizedBox(height: 32),
            Text(
              'مرحباً، ${_firstNameController.text}!',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'تم إعداد ملفك الشخصي بنجاح',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildInfoRow('الجامعة', _selectedUniversity?.nameAr ?? ''),
                  const Divider(height: 24),
                  _buildInfoRow('الكلية', _selectedFaculty?.nameAr ?? ''),
                  const Divider(height: 24),
                  _buildInfoRow('السنة', _selectedAcademicYear?.nameAr ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'ابدأ رحلتك التعليمية الآن!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
