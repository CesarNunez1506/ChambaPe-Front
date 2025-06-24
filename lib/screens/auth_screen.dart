import 'package:chamba_app/models/user_model.dart' as model_user; // Aliased
import 'package:chamba_app/navigation/app_routes.dart';
import 'package:chamba_app/providers/auth_provider.dart';
import 'package:chamba_app/utils/constants.dart';
import 'package:chamba_app/utils/helpers.dart';
import 'package:chamba_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Using aliased model_user.UserType to avoid conflict with AuthScreen's internal enum if any.
// However, it's better to use the one from the model directly.
// For this file, I'll remove the local UserType enum and use model_user.UserType.

class AuthScreen extends StatefulWidget {
  final bool isLoginScreen; // true for login, false for registration

  const AuthScreen({super.key, this.isLoginScreen = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  model_user.UserType _selectedUserType = model_user.UserType.client; // Default for registration

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;


  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLoginScreen;
  }

  void _toggleFormType() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      // Clear controllers if needed, or Form.reset() might handle it.
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _addressController.clear();
      _phoneController.clear();
      // Reset error messages from provider if any
      Provider.of<AuthProvider>(context, listen: false).clearErrorMessage();
    });
  }

  Future<void> _submitForm() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool success = false;
      if (_isLogin) {
        success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (success && mounted) {
          Helpers.showSnackBar(context, 'Inicio de sesión exitoso!');
          // Navigate to appropriate dashboard based on user type
          final userType = authProvider.currentUser?.userType;
          if (userType == model_user.UserType.client) {
            Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.clientDashboard, (route) => false);
          } else if (userType == model_user.UserType.worker) {
            Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.workerDashboard, (route) => false);
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.landing, (route) => false); // Fallback
          }
        }
      } else {
        // Registration
        if (_selectedUserType == null) {
           Helpers.showSnackBar(context, 'Por favor selecciona un tipo de usuario.', isError: true);
           return;
        }
        success = await authProvider.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          userType: _selectedUserType,
        );
        if (success && mounted) {
          Helpers.showSnackBar(context, '¡Registro exitoso! Por favor inicia sesión.');
          _toggleFormType(); // Switch to login screen
        }
      }

      if (!success && mounted && authProvider.errorMessage != null) {
        Helpers.showSnackBar(context, authProvider.errorMessage!, isError: true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = Provider.of<AuthProvider>(context); // Listen to changes for isLoading

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Iniciar Sesión' : 'Crear Cuenta'),
        leading: IconButton( // Ensure leading is present for back navigation
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding * 1.5), // Consistent padding
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _isLogin ? 'Bienvenido de Vuelta' : 'Únete a Chamba Perú',
                  style: textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kLargePadding),
                if (!_isLogin) ...[
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Nombre Completo',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu nombre';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: kDefaultPadding),
                  // User Type Selection for Registration
                  Text('Soy un:', style: textTheme.titleMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: RadioListTile<model_user.UserType>(
                          title: const Text('Cliente'),
                          value: model_user.UserType.client,
                          groupValue: _selectedUserType,
                          onChanged: (model_user.UserType? value) {
                            setState(() { _selectedUserType = value!; });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<model_user.UserType>(
                          title: const Text('Trabajador'),
                          value: model_user.UserType.worker,
                          groupValue: _selectedUserType,
                          onChanged: (model_user.UserType? value) {
                            setState(() { _selectedUserType = value!; });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kDefaultPadding),
                ],
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !Helpers.isValidEmail(value)) {
                      return 'Por favor ingresa un correo válido';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: kDefaultPadding),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixIconTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                  textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                  onFieldSubmitted: _isLogin ? (_) => _submitForm() : null,
                ),
                if (!_isLogin) ...[
                  const SizedBox(height: kDefaultPadding),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    onSuffixIconTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (value) {
                      if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: kDefaultPadding),
                  CustomTextField(
                    controller: _addressController,
                    labelText: 'Dirección',
                    prefixIcon: Icons.location_on_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor ingresa tu dirección';
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: kDefaultPadding),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Teléfono (9xxxxxxxx)',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty || !Helpers.isValidPhoneNumber(value, minLength: 9)) {
                        return 'Ingresa un número de teléfono válido (9 dígitos)';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                     onFieldSubmitted: (_) => _submitForm(),
                  ),
                ],
                const SizedBox(height: kLargePadding),
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 0.9)),
                        onPressed: _submitForm,
                        child: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                      ),
                const SizedBox(height: kDefaultPadding),
                TextButton(
                  onPressed: authProvider.isLoading ? null : _toggleFormType,
                  child: Text(_isLogin
                      ? '¿No tienes cuenta? Regístrate'
                      : '¿Ya tienes cuenta? Inicia Sesión'),
                ),
                if (_isLogin)
                  TextButton(
                    onPressed: authProvider.isLoading ? null : () {
                      // TODO: Navigate to Forgot Password Screen
                       Navigator.pushNamed(context, AppRoutes.forgotPassword); // Assuming route exists
                       Helpers.showSnackBar(context, 'Funcionalidad de recuperar contraseña pendiente.');
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
