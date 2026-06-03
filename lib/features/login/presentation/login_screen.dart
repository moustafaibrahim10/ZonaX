import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/network/dio_factory.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_images.dart';
import '../../auth/data/datasources/local/auth_local_data_source.dart';
import '../../auth/data/repositories/auth_repository_impl.dart';
import '../../auth/data/datasources/remote/auth_api_service.dart';
import '../../auth/presentation/register_screen.dart';
import '../../home/presentation/screens/main_screen.dart';
import 'blocs/login_bloc.dart';
import 'forgot_password_screen.dart';

// ---------------------------------------------------------------------------
// Entry point — wraps the screen with its BlocProvider
// ---------------------------------------------------------------------------

/// The Login feature's root widget.
///
/// Provides [LoginBloc] to the widget subtree and renders [_LoginView].
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
        return LoginBloc(authRepo);
      },
      child: const _LoginView(),
    );
  }
}

// ---------------------------------------------------------------------------
// View — contains BlocListener + BlocBuilder
// ---------------------------------------------------------------------------

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) {
        return (current.status == LoginStatus.failure &&
                current.errorMessage != null) ||
            (current.status == LoginStatus.success);
      },
      listener: _handleStateChanges,
      child: Scaffold(
        backgroundColor: Theme.of(context).extension<AppColors>()!.background,
        body: const SafeArea(
          top: false, // Because hero image goes to the top edge
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_HeroImage(), _LoginFormSection()],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, LoginState state) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    if (state.status == LoginStatus.failure && state.errorMessage != null) {
      _showErrorDialog(context, state.errorMessage!, appColors);
    } else if (state.status == LoginStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signed in successfully!'),
          backgroundColor: appColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  void _showErrorDialog(
    BuildContext context,
    String message,
    AppColors colors,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C), // Premium Dark
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                "Error",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Dismiss",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Hero / banner image at the top
// ---------------------------------------------------------------------------

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.loginImage,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    appColors.background.withValues(alpha: 0.85),
                    appColors.background,
                  ],
                  stops: const [0.4, 0.85, 1.0],
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment(0, -0.4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_LoginIcon(), SizedBox(height: 12), _TitleBlock()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main form section
// ---------------------------------------------------------------------------

class _LoginFormSection extends StatefulWidget {
  const _LoginFormSection();

  @override
  State<_LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<_LoginFormSection> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const _PhoneNumberField(),
            const SizedBox(height: 16),
            const _PasswordField(),
            const SizedBox(height: 4),
            const _ForgotPasswordButton(),
            const SizedBox(height: 24),
            _buildSignInButton(context),
            const SizedBox(height: 24),
            const _CreateAccountSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
      builder: (context, state) {
        return SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      context.read<LoginBloc>().add(const SignInSubmitted());
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: appColors.accent,
              disabledBackgroundColor: appColors.accent.withValues(alpha: 0.5),
              elevation: 4,
              shadowColor: appColors.accent.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: state.isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: appColors.background,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Sign In',
                    style: TextStyle(
                      color: appColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Login arrow icon
// ---------------------------------------------------------------------------

class _LoginIcon extends StatelessWidget {
  const _LoginIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.login_rounded, color: Colors.white, size: 38),
    );
  }
}

// ---------------------------------------------------------------------------
// Title + subtitle
// ---------------------------------------------------------------------------

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Column(
      children: [
        Text(
          'ZonaX',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: appColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 32,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Drive smarter, earn more',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: appColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Phone field
// ---------------------------------------------------------------------------

class _PhoneNumberField extends StatefulWidget {
  const _PhoneNumberField();

  @override
  State<_PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<_PhoneNumberField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Phone Number'),
        const SizedBox(height: 8),
        _StyledTextField(
          controller: _controller,
          hintText: '100 123 4567',
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: appColors.inputIcon,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '+20',
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          onChanged: (value) => _onPhoneChanged(context, value),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            if (value.length != 10) {
              return 'Phone number must be exactly 10 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _onPhoneChanged(BuildContext context, String value) {
    context.read<LoginBloc>().add(PhoneNumberChanged(phoneNumber: value));
  }
}

// ---------------------------------------------------------------------------
// Password field
// ---------------------------------------------------------------------------

class _PasswordField extends StatefulWidget {
  const _PasswordField();

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) =>
          prev.isPasswordVisible != curr.isPasswordVisible,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(label: 'Password'),
            const SizedBox(height: 8),
            _StyledTextField(
              controller: _controller,
              hintText: 'Enter your password',
              obscureText: !state.isPasswordVisible,
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: appColors.inputIcon,
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: () => _onToggleVisibility(context),
                child: Icon(
                  state.isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: appColors.inputIcon,
                  size: 20,
                ),
              ),
              onChanged: (value) => _onPasswordChanged(context, value),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Password is required'
                  : null,
            ),
          ],
        );
      },
    );
  }

  void _onPasswordChanged(BuildContext context, String value) {
    context.read<LoginBloc>().add(PasswordChanged(password: value));
  }

  void _onToggleVisibility(BuildContext context) {
    context.read<LoginBloc>().add(const TogglePasswordVisibility());
  }
}

// ---------------------------------------------------------------------------
// Forgot password button
// ---------------------------------------------------------------------------

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _onForgotPasswordTapped(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Forgot password?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: appColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  void _onForgotPasswordTapped(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }
}

// ---------------------------------------------------------------------------
// Create Account section
// ---------------------------------------------------------------------------

class _CreateAccountSection extends StatelessWidget {
  const _CreateAccountSection();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Column(
      children: [
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: appColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        const _CreateAccountButton(),
      ],
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _onCreateAccountPressed(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: appColors.accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          'Create Account',
          style: TextStyle(
            color: appColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _onCreateAccountPressed(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }
}

// ---------------------------------------------------------------------------
// Shared reusable widgets
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Text(
      label,
      style: TextStyle(color: appColors.textSecondary, fontSize: 13),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.maxLength,
  });

  final String hintText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(color: appColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: appColors.textHint, fontSize: 15),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: appColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: appColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
