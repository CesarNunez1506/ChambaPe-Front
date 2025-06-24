import 'package:chamba_app/providers/auth_provider.dart';
import 'package:chamba_app/utils/constants.dart';
import 'package:chamba_app/utils/helpers.dart';
import 'package:chamba_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // In a real app, the provider method would call an API endpoint.
      // For now, simulating this.
      // bool success = await authProvider.requestPasswordReset(_emailController.text.trim());

      // Simulate API call from ApiService directly for now as provider method may not exist
      bool success = await authProvider.apiService.requestPasswordReset(_emailController.text.trim());


      if (mounted) {
        if (success) {
          Helpers.showSnackBar(
            context,
            'Si existe una cuenta para ${_emailController.text.trim()}, recibirás un correo con instrucciones.',
            duration: const Duration(seconds: 5),
          );
          // Optionally navigate back or to login screen after a delay
          // Future.delayed(Duration(seconds: 2), () => Navigator.of(context).pop());
        } else {
          // This else might not be hit if the API always returns true for security reasons
          Helpers.showSnackBar(context, 'Error al procesar la solicitud.', isError: true);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Contraseña')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding * 1.5),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '¿Olvidaste tu contraseña?',
                  style: textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kDefaultPadding),
                Text(
                  'Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu contraseña.',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kLargePadding),
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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitRequest(),
                ),
                const SizedBox(height: kLargePadding),
                authProvider.isLoading // Assuming AuthProvider has an isLoading for this
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 0.9)),
                        onPressed: _submitRequest,
                        child: const Text('Enviar Instrucciones'),
                      ),
                const SizedBox(height: kDefaultPadding),
                TextButton(
                  onPressed: authProvider.isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Volver a Iniciar Sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
