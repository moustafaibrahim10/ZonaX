import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/network/dio_factory.dart';
import '../../../core/theme/app_colors.dart';
import '../data/datasources/remote/auth_api_service.dart';
import '../data/datasources/local/auth_local_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import 'bloc/register_bloc.dart';
import 'bloc/register_event.dart';
import 'bloc/register_state.dart';
import '../../home/presentation/screens/main_screen.dart';
import 'terms_acceptance_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = DioFactory.getDio();
        final apiService = AuthApiService(dio);
        final localDataSource = AuthLocalDataSourceImpl(
          const FlutterSecureStorage(),
          Hive.box('app_box'),
        );
        final authRepo = AuthRepositoryImpl(apiService, localDataSource);
        return RegisterBloc(authRepo);
      },
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  // Form Keys for Validations
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();
  final _formKeyStep4 = GlobalKey<FormState>();

  // Step 1 Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  // Step 2 Controllers
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();

  // Step 3 Controllers
  final _licenseCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();

  // Step 4 Controllers
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _streetCtrl.dispose();
    _licenseCtrl.dispose();
    _plateCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _showErrorDialog(BuildContext context, String message, AppColors colors) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface, // Dynamic Surface
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 12),
              Text("Error", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
            textAlign: TextAlign.left,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Dismiss", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.failure && state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          _showErrorDialog(context, state.errorMessage!, appColors);
        } else if (state.status == RegisterStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const TermsAcceptanceScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: state.currentStep == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && state.currentStep > 0) {
              context.read<RegisterBloc>().add(PreviousStepTapped());
            }
          },
          child: Scaffold(
            backgroundColor: appColors.background,
            appBar: AppBar(
              backgroundColor: appColors.background,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: appColors.textPrimary),
                onPressed: () {
                  if (state.currentStep > 0) {
                    context.read<RegisterBloc>().add(PreviousStepTapped());
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text("Create Account", style: TextStyle(color: appColors.textPrimary)),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildStepper(context, state.currentStep, appColors),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: _buildCurrentStep(context, state, appColors),
                    ),
                  ),
                  _buildBottomBar(context, state, appColors),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepper(BuildContext context, int currentStep, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          final isActive = index <= currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? colors.accent : colors.inputBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, RegisterState state, AppColors colors) {
    switch (state.currentStep) {
      case 0:
        return _buildPersonalDetails(colors);
      case 1:
        return _buildContactInfo(colors);
      case 2:
        return _buildVehicleInfo(colors);
      case 3:
        return _buildSecurity(state, colors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalDetails(AppColors colors) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Personal Details", "Let's get to know you", colors),
          const SizedBox(height: 30),
          _buildFieldLabel('First Name', colors),
          _buildStyledTextField(
            controller: _firstNameCtrl,
            hintText: 'John',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            validator: (value) => (value == null || value.trim().isEmpty) ? 'First name is required' : null,
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Last Name', colors),
          _buildStyledTextField(
            controller: _lastNameCtrl,
            hintText: 'Doe',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.familyName],
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Last name is required' : null,
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Age', colors),
          _buildStyledTextField(
            controller: _ageCtrl,
            hintText: '25',
            prefixIcon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Age is required';
              final age = int.tryParse(value);
              if (age == null) return 'Must be a valid number';
              if (age < 18) return 'You must be at least 18 years old';
              return null;
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(AppColors colors) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Contact Info", "How can we reach you?", colors),
          const SizedBox(height: 30),
          _buildFieldLabel('Phone Number', colors),
          _buildStyledTextField(
            controller: _phoneCtrl,
            hintText: '100 123 4567',
            prefixWidget: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined, color: colors.inputIcon, size: 20),
                  const SizedBox(width: 8),
                  Text('+20', style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            keyboardType: TextInputType.phone,
            maxLength: 10,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Phone number is required';
              if (value.length != 10) return 'Phone number must be exactly 10 digits';
              return null;
            },
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('City', colors),
          _buildStyledTextField(
            controller: _cityCtrl,
            hintText: 'Cairo',
            prefixIcon: Icons.location_city_outlined,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.addressCity],
            validator: (value) => (value == null || value.trim().isEmpty) ? 'City is required' : null,
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Street', colors),
          _buildStyledTextField(
            controller: _streetCtrl,
            hintText: '123 Main St',
            prefixIcon: Icons.streetview_outlined,
            keyboardType: TextInputType.streetAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.fullStreetAddress],
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Street address is required' : null,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo(AppColors colors) {
    return Form(
      key: _formKeyStep3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Vehicle Info", "Tell us about your ride", colors),
          const SizedBox(height: 30),
          _buildFieldLabel('License Number', colors),
          _buildStyledTextField(
            controller: _licenseCtrl,
            hintText: 'LIC-987654',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.trim().isEmpty) ? 'License number is required' : null,
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Plate Number', colors),
          _buildStyledTextField(
            controller: _plateCtrl,
            hintText: 'ABC-1234',
            prefixIcon: Icons.directions_car_outlined,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Plate number is required';
              // Supports Arabic/English letters, Arabic/English numbers, spaces, and dashes
              final regex = RegExp(r'^[\u0621-\u064A\u0660-\u0669a-zA-Z0-9\s\-]+$');
              if (!regex.hasMatch(value)) return 'Invalid format. Use English/Arabic letters and numbers.';
              if (value.length < 2 || value.length > 10) return 'Plate number must be 2 to 10 characters';
              return null;
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurity(RegisterState state, AppColors colors) {
    return Form(
      key: _formKeyStep4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Security", "Secure your account", colors),
          const SizedBox(height: 30),
          _buildFieldLabel('Password', colors),
          _buildStyledPasswordField(
            controller: _passwordCtrl,
            hintText: 'StrongPassword123!',
            showPassword: state.isPasswordVisible,
            textInputAction: TextInputAction.next,
            onVisibilityToggle: () => context.read<RegisterBloc>().add(const TogglePasswordVisibility(isConfirm: false)),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 8) return 'Minimum 8 characters required';
              if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain at least one uppercase letter';
              if (!RegExp(r'[a-z]').hasMatch(value)) return 'Must contain at least one lowercase letter';
              if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain at least one number';
              if (!RegExp(r'[!@#\$&*~%]').hasMatch(value)) return 'Must contain at least one special character';
              return null;
            },
            colors: colors,
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Confirm Password', colors),
          _buildStyledPasswordField(
            controller: _confirmPasswordCtrl,
            hintText: 'StrongPassword123!',
            showPassword: state.isConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            onVisibilityToggle: () => context.read<RegisterBloc>().add(const TogglePasswordVisibility(isConfirm: true)),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildFieldLabel(String label, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w400)),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    Widget? prefixWidget,
    required AppColors colors,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<String>? autofillHints,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      style: TextStyle(color: colors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
        prefixIcon: prefixWidget ?? (prefixIcon != null ? Icon(prefixIcon, color: colors.inputIcon, size: 20) : null),
        filled: true,
        fillColor: colors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.inputBorder, width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.inputBorder, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }

  Widget _buildStyledPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool showPassword,
    required VoidCallback onVisibilityToggle,
    required TextInputAction textInputAction,
    required AppColors colors,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      textInputAction: textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      style: TextStyle(color: colors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colors.textHint, fontSize: 14),
        prefixIcon: Icon(Icons.lock_outline_rounded, color: colors.inputIcon, size: 20),
        suffixIcon: GestureDetector(
          onTap: onVisibilityToggle,
          child: Icon(showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: colors.inputIcon, size: 20),
        ),
        filled: true,
        fillColor: colors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.inputBorder, width: 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.inputBorder, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, RegisterState state, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.background,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: state.status == RegisterStatus.loading
              ? null
              : () {
                  FocusScope.of(context).unfocus(); // Dismiss keyboard
                  
                  if (state.currentStep == 0) {
                    if (!_formKeyStep1.currentState!.validate()) return;
                    context.read<RegisterBloc>().add(SubmitStep1(
                      firstName: _firstNameCtrl.text,
                      lastName: _lastNameCtrl.text,
                      age: int.tryParse(_ageCtrl.text) ?? 18,
                    ));
                  } else if (state.currentStep == 1) {
                    if (!_formKeyStep2.currentState!.validate()) return;
                    context.read<RegisterBloc>().add(SubmitStep2(
                      phoneNumber: _phoneCtrl.text,
                      city: _cityCtrl.text,
                      street: _streetCtrl.text,
                    ));
                  } else if (state.currentStep == 2) {
                    if (!_formKeyStep3.currentState!.validate()) return;
                    context.read<RegisterBloc>().add(SubmitStep3(
                      licenseNumber: _licenseCtrl.text,
                      plateNumber: _plateCtrl.text,
                    ));
                  } else if (state.currentStep == 3) {
                    if (!_formKeyStep4.currentState!.validate()) return;
                    context.read<RegisterBloc>().add(RegisterSubmitted(
                      password: _passwordCtrl.text,
                      confirmPassword: _confirmPasswordCtrl.text,
                    ));
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: state.status == RegisterStatus.loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  state.currentStep < 3 ? "Continue" : "Create Account",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
        ),
      ),
    );
  }
}
