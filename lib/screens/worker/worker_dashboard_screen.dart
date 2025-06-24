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

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Future<List<ServiceRequest>>? _availableJobsFuture;
  Future<List<ServiceRequest>>? _ongoingJobsFuture;
  Future<List<ServiceRequest>>? _pastJobsFuture;
  model_user.User? _currentUser;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (_currentUser != null) {
        _loadJobs();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _loadJobs() {
    if (_currentUser == null || !mounted) return;
    setState(() {
      _availableJobsFuture = _apiService.getWorkerServiceRequests(_currentUser!.id, status: ServiceStatus.pending);
      _ongoingJobsFuture = _apiService.getWorkerServiceRequests(_currentUser!.id).then((requests) =>
          requests.where((req) => req.status == ServiceStatus.accepted || req.status == ServiceStatus.inProgress).toList());
      _pastJobsFuture = _apiService.getWorkerServiceRequests(_currentUser!.id).then((requests) =>
          requests.where((req) => req.status == ServiceStatus.completed || req.status == ServiceStatus.cancelled || req.status == ServiceStatus.rejected).toList());
    });
  }

  Future<void> _handleJobAction(ServiceRequest job, bool accepted) async {
    final newStatus = accepted ? ServiceStatus.accepted : ServiceStatus.rejected;
    final actionText = accepted ? "aceptado" : "rechazado";
    if (!mounted || _currentUser == null) return;

    try {
      Helpers.showLoadingDialog(context, message: "Procesando...");
      await _apiService.updateServiceRequestStatus(job.id, newStatus, workerId: _currentUser!.id);
      if (mounted) {
        Helpers.hideLoadingDialog(context);
        Helpers.showSnackBar(context, 'Trabajo ${job.category} $actionText.');
        _loadJobs();
      }
    } catch (e) {
      if (mounted) {
        Helpers.hideLoadingDialog(context);
        Helpers.showSnackBar(context, 'Error al $actionText trabajo: ${e.toString()}', isError: true);
      }
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
      return Scaffold(appBar: AppBar(title: const Text('Panel de Trabajador')), body: const Center(child: Text('Error: Usuario no autenticado.')));
    }

    if (_availableJobsFuture == null) { // Initial loading state before futures are set
        return Scaffold(appBar: AppBar(title: const Text("Panel de Trabajador")), body: const Center(child: CircularProgressIndicator()));
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${_currentUser?.name ?? 'Trabajador'}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.subscriptions_outlined),
            tooltip: 'Mis Suscripciones',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.subscriptions),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _handleLogout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.new_releases_outlined), text: 'Disponibles'),
            Tab(icon: Icon(Icons.construction_outlined), text: 'En Curso'),
            Tab(icon: Icon(Icons.history_outlined), text: 'Historial'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async { _loadJobs(); },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildJobsList(_availableJobsFuture!, JobListViewType.available, "No hay nuevos trabajos disponibles."),
            _buildJobsList(_ongoingJobsFuture!, JobListViewType.ongoing, "No tienes trabajos en curso."),
            _buildJobsList(_pastJobsFuture!, JobListViewType.past, "No tienes trabajos en tu historial."),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(Future<List<ServiceRequest>> futureJobs, JobListViewType viewType, String emptyListText) {
    return FutureBuilder<List<ServiceRequest>>(
      future: futureJobs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Text('Error al cargar trabajos: ${snapshot.error.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kDefaultPadding * 2),
              child: Text(emptyListText, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center,),
            )
          );
        }

        final jobs = snapshot.data!;
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(kDefaultPadding / 2),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            if (viewType == JobListViewType.available) {
              return _buildAvailableJobCard(job);
            }
            // For ongoing and past jobs, use the standard ServiceRequestCard
            return ServiceRequestCard(
              request: job,
              userType: model_user.UserType.worker,
              onTap: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.workerTaskDetails, arguments: job.id);
                if (result == true && mounted) { // If detail screen indicates a change
                  _loadJobs();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAvailableJobCard(ServiceRequest job) {
    final theme = Theme.of(context);
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: kSmallPadding, horizontal: kSmallPadding / 2),
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nuevo Trabajo Disponible", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: kSmallPadding),
          _buildInfoRow(Icons.category_outlined, "Categoría:", job.category),
          _buildInfoRow(Icons.location_on_outlined, "Distrito/Zona:", job.address.split(',').first.trim()), // Show only district for brevity
          _buildInfoRow(Icons.schedule_outlined, "Horario:", Helpers.formatDateTime(job.dateTime)),
          if (job.description.isNotEmpty)
            _buildInfoRow(Icons.description_outlined, "Detalles:", job.description, maxLines: 2),
          if (job.estimatedCost != null)
            _buildInfoRow(Icons.monetization_on_outlined, "Pago Estimado:", Helpers.formatCurrency(job.estimatedCost)),
          const SizedBox(height: kDefaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close_rounded),
                  label: const Text("Rechazar"),
                  onPressed: () => _handleJobAction(job, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: kSmallPadding / 1.5)
                  ),
                ),
              ),
              const SizedBox(width: kSmallPadding),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: const Text("Aceptar"),
                  onPressed: () => _handleJobAction(job, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: kSmallPadding / 1.5)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text("$label ", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

enum JobListViewType { available, ongoing, past }
