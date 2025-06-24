import 'package:chamba_app/navigation/app_routes.dart';
import 'package:chamba_app/utils/constants.dart';
import 'package:flutter/material.dart';
// import 'package:chamba_app/widgets/responsive_layout.dart'; // If using for web/desktop adaptations

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Replace with your actual logo widget or Image.asset(kLogoPath)
            Icon(Icons.construction, color: colorScheme.onPrimary, size: 30),
            const SizedBox(width: 8),
            Text(kAppName, style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to Client Dashboard (or Auth if not logged in)
              // This logic would typically be handled by checking auth state
              Navigator.pushNamed(context, AppRoutes.clientDashboard);
              // print('Buscar Servicio pressed');
            },
            child: Text('Buscar Servicio', style: TextStyle(color: colorScheme.onPrimary)),
          ),
          TextButton(
            onPressed: () {
              // Navigate to Worker Dashboard (or Auth if not logged in)
              Navigator.pushNamed(context, AppRoutes.workerDashboard);
              // print('Ofrecer Servicio pressed');
            },
            child: Text('Ofrecer Servicio', style: TextStyle(color: colorScheme.onPrimary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: mediaQuery.size.height * 0.05),
            // Replace with a more engaging image or illustration
            // Could be Image.asset('assets/images/landing_hero.png', height: mediaQuery.size.height * 0.25)
            Icon(Icons.home_repair_service, size: 100, color: colorScheme.primary),
            SizedBox(height: mediaQuery.size.height * 0.03),
            Text(
              'Conectamos tus necesidades con profesionales de confianza en Perú.',
              style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kDefaultPadding),
            Text(
              'Encuentra jardineros, plomeros, pintores y más, formales y verificados, listos para ayudarte. O si eres un trabajador, ofrece tus servicios a una amplia red de clientes.',
              style: textTheme.bodyLarge?.copyWith(height: 1.5), // Improved line spacing
              textAlign: TextAlign.center,
            ),
            SizedBox(height: mediaQuery.size.height * 0.05),
            // Benefits Section
            _buildBenefitItem(
              context,
              Icons.verified_user_outlined,
              'Trabajadores Verificados',
              'Todos nuestros profesionales pasan por un proceso de verificación (Certijoven, Certiadulto).',
            ),
            _buildBenefitItem(
              context,
              Icons.schedule_outlined,
              'Flexibilidad y Rapidez',
              'Encuentra ayuda cuando la necesites, con asignación automática tipo Yango.',
            ),
            _buildBenefitItem(
              context,
              Icons.payments_outlined,
              'Pagos Seguros',
              'Transacciones protegidas y transparentes dentro de la plataforma (simulado).',
            ),
            SizedBox(height: mediaQuery.size.height * 0.06),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 0.8)),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                        // print('Registrarse pressed');
                      },
                      child: const Text('Registrarse'),
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 0.8),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                        // print('Iniciar Sesión pressed');
                      },
                      child: const Text('Iniciar Sesión'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: mediaQuery.size.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String title, String subtitle) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kSmallPadding + 4, horizontal: kSmallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: colorScheme.secondary),
          const SizedBox(width: kDefaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
