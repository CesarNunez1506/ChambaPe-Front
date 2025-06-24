import 'package:chamba_app/models/service_request_model.dart';
import 'package:chamba_app/models/user_model.dart' as model_user;
import 'package:chamba_app/navigation/app_routes.dart';
import 'package:chamba_app/providers/auth_provider.dart';
import 'package:chamba_app/services/api_service.dart';
import 'package:chamba_app/utils/constants.dart';
import 'package:chamba_app/utils/helpers.dart';
import 'package:chamba_app/widgets/custom_card.dart';
import 'package:chamba_app/widgets/service_request_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  final ApiService _apiService = ApiService();
  Future<List<ServiceRequest>>? _ongoingRequestsFuture;
  Future<List<ServiceRequest>>? _pastRequestsFuture;
  model_user.User? _currentUser;

  @override
  void initState() {
    super.initState();
    // Defer _loadRequests until after the first frame to ensure Provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (_currentUser != null) {
        _loadRequests();
      } else {
        // If user is somehow null, redirect to login (should be handled by router guards ideally)
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    });
  }

  void _loadRequests() {
    if (_currentUser == null) return;
    setState(() {
      // Combine pending and accepted into "Ongoing/Pending"
      _ongoingRequestsFuture = _apiService.getClientServiceRequests(_currentUser!.id)
          .then((requests) => requests.where((req) =>
              req.status == ServiceStatus.pending ||
              req.status == ServiceStatus.accepted ||
              req.status == ServiceStatus.inProgress).toList());

      _pastRequestsFuture = _apiService.getClientServiceRequests(_currentUser!.id)
          .then((requests) => requests.where((req) =>
              req.status == ServiceStatus.completed ||
              req.status == ServiceStatus.cancelled).toList());
    });
  }

  void _navigateToCreateService() async {
    final result = await Navigator.pushNamed(context, AppRoutes.clientCreateService);
    if (result == true && mounted) {
      _loadRequests();
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if(mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.landing, (route) => false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    _currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;


    if (_currentUser == null) {
      // This should ideally not be reached if navigation guards are in place.
      // It's a fallback.
      return Scaffold(
        appBar: AppBar(title: const Text('Panel de Cliente')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: Usuario no autenticado.'),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
              //   child: const Text('Ir a Iniciar Sesión'),
              // )
            ],
          ),
        ),
      );
    }

    // Ensure futures are initialized if _loadRequests hasn't run yet or currentUser was initially null
    if (_ongoingRequestsFuture == null || _pastRequestsFuture == null) {
       _loadRequests(); // Attempt to load if not already
       // Show loading indicator while futures are being set up
       return Scaffold(appBar: AppBar(title: const Text("Panel de Cliente")), body: const Center(child: CircularProgressIndicator()));
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver historial completo',
            onPressed: () {
               Navigator.pushNamed(context, AppRoutes.clientTaskHistory);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadRequests();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bienvenido, ${_currentUser?.name ?? 'Cliente'}!', style: textTheme.headlineSmall),
              const SizedBox(height: kDefaultPadding),
              _buildQuickServiceSection(context),
              const SizedBox(height: kLargePadding),
              Text('Servicios en Curso/Pendientes', style: textTheme.titleLarge),
              const SizedBox(height: kSmallPadding),
              _buildRequestsList(_ongoingRequestsFuture!, isEmptyText: "No tienes servicios activos o pendientes."),
              const SizedBox(height: kLargePadding),
              Text('Historial de Servicios', style: textTheme.titleLarge),
              const SizedBox(height: kSmallPadding),
              _buildRequestsList(_pastRequestsFuture!, isPast: true, isEmptyText: "No tienes servicios en tu historial."),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateService,
        label: const Text('Nuevo Servicio'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildQuickServiceSection(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '¿Necesitas ayuda rápida?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kSmallPadding),
          Text(
            'Publica un nuevo servicio y te asignaremos un trabajador disponible al instante.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: kDefaultPadding),
          ElevatedButton.icon(
            icon: const Icon(Icons.flash_on),
            onPressed: _navigateToCreateService,
            label: const Text('Solicitar Servicio Rápido'),
             style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: kSmallPadding)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(Future<List<ServiceRequest>> futureRequests, {bool isPast = false, required String isEmptyText}) {
    return FutureBuilder<List<ServiceRequest>>(
      future: futureRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar servicios: ${snapshot.error.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.error)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: kLargePadding, horizontal: kDefaultPadding),
              child: Text(isEmptyText, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center,),
            )
          );
        }

        final requests = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return ServiceRequestCard(
              request: request,
              userType: model_user.UserType.client, // Client's perspective
              onTap: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.clientServiceDetails, arguments: request.id);
                if (result == true && mounted) { // If detail screen indicates a change (e.g., cancellation, rating)
                  _loadRequests();
                }
              },
            );
          },
        );
      },
    );
  }
}
