import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/auth/presentation/register_screen.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';

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
      create: (_) => LoginBloc(),
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
        // Only show snackbar when transitioning TO failure state
        // AND when there's an error message (to avoid showing empty snackbars)
        return current.status == LoginStatus.failure && 
               previous.status != LoginStatus.failure &&
               current.errorMessage != null;
      },
      listener: _handleStateChanges,
      child: Scaffold(
        backgroundColor: Theme.of(context).extension<AppColors>()!.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _HeroImage(),
                _LoginFormSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reacts to side-effect states such as navigation or showing a snackbar.
  ///
  /// Should handle [LoginStatus.success] by navigating to the home screen,
  /// and [LoginStatus.failure] by showing an error snackbar.
  void _handleStateChanges(BuildContext context, LoginState state) {
    if (state.status == LoginStatus.failure && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    // Success is handled by AuthGate listening to Supabase auth state
  }
}

// ---------------------------------------------------------------------------
// Hero / banner image at the top
// ---------------------------------------------------------------------------

/// Displays the full-width hero photograph at the top of the screen.
///
/// The image fades into the dark background via a bottom gradient overlay.
class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/Login_Image.jpg', fit: BoxFit.cover),
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
                  stops: const [0.5, 0.85, 1.0],
                ),
              ),
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

/// Contains the login icon, title, subtitle, form fields, and action buttons.
class _LoginFormSection extends StatelessWidget {
  const _LoginFormSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          SizedBox(height: 8),
          _LoginIcon(),
          SizedBox(height: 20),
          _TitleBlock(),
          SizedBox(height: 36),
          _PhoneNumberField(),
          SizedBox(height: 16),
          _PasswordField(),
          SizedBox(height: 8),
          _ForgotPasswordButton(),
          SizedBox(height: 28),
          _SignInButton(),
          SizedBox(height: 24),
          _CreateAccountSection(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Login arrow icon
// ---------------------------------------------------------------------------

/// Renders the arrow-right-into-bracket login icon shown below the hero image.
class _LoginIcon extends StatelessWidget {
  const _LoginIcon();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Icon(
        Icons.login_rounded,
        color: appColors.textPrimary,
        size: 40,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Title + subtitle
// ---------------------------------------------------------------------------

/// Displays the "ZonaX" title and "Drive smarter, earn more" subtitle.
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
            fontWeight: FontWeight.w700,
            fontSize: 30,
            letterSpacing: 0.3,
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
// Email field (Phone login)
// ---------------------------------------------------------------------------

/// Input field for the user's phone number (displayed as Email).
///
/// Dispatches [PhoneNumberChanged] on every keystroke.
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
        _FieldLabel(label: 'Email'),
        const SizedBox(height: 8),
        _StyledTextField(
          controller: _controller,
          hintText: 'example@gmail.com',
          prefixIcon: Icon(
            Icons.email_outlined,
            color: appColors.inputIcon,
            size: 20,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _onPhoneChanged(context, value),
        ),
      ],
    );
  }

  /// Dispatches [PhoneNumberChanged] to [LoginBloc].
  ///
  /// Should be called with the latest value from the text field.
  void _onPhoneChanged(BuildContext context, String value) {
    context.read<LoginBloc>().add(PhoneNumberChanged(phoneNumber: value));
  }
}

// ---------------------------------------------------------------------------
// Password field
// ---------------------------------------------------------------------------

/// Input field for the user's password, with visibility toggle.
///
/// Dispatches [PasswordChanged] on every keystroke and
/// [TogglePasswordVisibility] when the eye icon is tapped.
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
            ),
          ],
        );
      },
    );
  }

  /// Dispatches [PasswordChanged] to [LoginBloc].
  ///
  /// Should be called with the latest value from the text field.
  void _onPasswordChanged(BuildContext context, String value) {
    context.read<LoginBloc>().add(PasswordChanged(password: value));
  }

  /// Dispatches [TogglePasswordVisibility] to [LoginBloc].
  ///
  /// Should flip the obscure-text state of the password field.
  void _onToggleVisibility(BuildContext context) {
    context.read<LoginBloc>().add(const TogglePasswordVisibility());
  }
}

// ---------------------------------------------------------------------------
// Forgot password button
// ---------------------------------------------------------------------------

/// Text button aligned to the right, navigating to the forgot-password flow.
class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => _onForgotPasswordTapped(context),
        child: Text(
          'Forgot password?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: appColors.accent,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// Dispatches [ForgotPasswordTapped] to [LoginBloc].
  ///
  /// Should trigger navigation to the forgot-password screen.
  void _onForgotPasswordTapped(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign In button
// ---------------------------------------------------------------------------

/// Text-style primary action button for signing in.
///
/// Shows a loading indicator while [LoginStatus.loading] is active.
class _SignInButton extends StatelessWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
      builder: (context, state) {
        return Center(
          child: state.isLoading
              ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: appColors.textPrimary,
              strokeWidth: 2,
            ),
          )
              : GestureDetector(
            onTap: () => _onSignInPressed(context),
            child: Text(
              'Sign In',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: appColors.signInText,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Dispatches [SignInSubmitted] to [LoginBloc].
  ///
  /// Should validate form inputs before dispatching the event.
  void _onSignInPressed(BuildContext context) {
    // TODO: Implement logic
    context.read<LoginBloc>().add(const SignInSubmitted());
  }
}

// ---------------------------------------------------------------------------
// Create Account section
// ---------------------------------------------------------------------------

/// Bottom section with "Don't have an account?" label and the outlined
/// "Create Account" button.
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
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        _CreateAccountButton(),
      ],
    );
  }
}

/// Outlined button navigating to the registration screen.
class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () => _onCreateAccountPressed(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: appColors.accent, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          foregroundColor: appColors.textPrimary,
        ),
        child: Text(
          'Create Account',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: appColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  /// Dispatches [CreateAccountTapped] to [LoginBloc].
  ///
  /// Should navigate the user to the sign-up / registration screen.
  void _onCreateAccountPressed(BuildContext context) {
    context.read<LoginBloc>().add(const CreateAccountTapped());
    // Navigate to registration screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// Shared reusable widgets
// ---------------------------------------------------------------------------

/// Small label rendered above each input field.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: appColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

/// A styled [TextFormField] that matches the dark-themed design.
///
/// Accepts optional [prefixIcon], [suffixIcon], and [obscureText] parameters
/// and reports changes via [onChanged].
class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  final String hintText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: appColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: appColors.textHint,
          fontSize: 14,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon != null
            ? Padding(
          padding: const EdgeInsets.only(right: 12),
          child: suffixIcon,
        )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        filled: true,
        fillColor: appColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
