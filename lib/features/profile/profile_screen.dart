import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/supabase_client.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event_state.dart' as app_auth;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = '';
  String _universityName = '';
  String _facultyName = '';
  String _yearName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authBloc = context.read<AuthBloc>();
    final state = authBloc.state;
    
    if (state is app_auth.Authenticated) {
      final user = state.user;
      _fullName = user.fullName ?? '';
      
      // Load university, faculty, year names from database
      try {
        if (user.universityId != null) {
          final uniResp = await SupabaseService.client
              .from('universities')
              .select('name_ar')
              .eq('id', user.universityId!)
              .maybeSingle();
          _universityName = uniResp?['name_ar'] ?? '';
        }
        
        if (user.facultyId != null) {
          final facResp = await SupabaseService.client
              .from('faculties')
              .select('name_ar')
              .eq('id', user.facultyId!)
              .maybeSingle();
          _facultyName = facResp?['name_ar'] ?? '';
        }
        
        if (user.academicYearId != null) {
          final yearResp = await SupabaseService.client
              .from('academic_years')
              .select('name_ar')
              .eq('id', user.academicYearId!)
              .maybeSingle();
          _yearName = yearResp?['name_ar'] ?? '';
        }
      } catch (e) {
        // Silently handle errors
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  void _logout() {
    context.read<AuthBloc>().add(app_auth.LogoutRequested());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoading) ...[const Center(child: CircularProgressIndicator())]
            else ...[  
            const SizedBox(height: 20),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _fullName.isNotEmpty ? _fullName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fullName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              _facultyName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Info cards
            _buildInfoCard(Icons.account_balance, 'الجامعة', _universityName),
            _buildInfoCard(Icons.school, 'الكلية', _facultyName),
            _buildInfoCard(Icons.calendar_today, 'السنة الدراسية', _yearName),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Menu items
            _buildMenuItem(Icons.edit_outlined, AppStrings.editProfile, () {}),
            _buildMenuItem(Icons.settings_outlined, AppStrings.settings, () {}),
            _buildMenuItem(Icons.help_outline, AppStrings.help, () {}),
            _buildMenuItem(Icons.info_outline, AppStrings.about, () {}),
            const SizedBox(height: 16),
            _buildMenuItem(
              Icons.logout_rounded,
              AppStrings.logout,
              _logout,
              isDestructive: true,
            ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: isDestructive ? AppColors.error : AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: isDestructive ? AppColors.error : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
