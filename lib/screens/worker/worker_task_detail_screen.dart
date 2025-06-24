import 'package:chamba_app/models/service_request_model.dart';
import 'package:chamba_app/models/user_model.dart' as model_user;
import 'package:chamba_app/providers/auth_provider.dart';
import 'package:chamba_app/services/api_service.dart';
import 'package:chamba_app/utils/constants.dart';
import 'package:chamba_app/utils/helpers.dart';
import 'package:chamba_app/widgets/custom_card.dart';
import 'package:chamba_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

class WorkerTaskDetailScreen extends StatefulWidget {
  final String taskId;
  const WorkerTaskDetailScreen({super.key, required this.taskId});

  @override
  State<WorkerTaskDetailScreen> createState() => _WorkerTaskDetailScreenState();
}

class _WorkerTaskDetailScreenState extends State<WorkerTaskDetailScreen> {
  final ApiService _apiService = ApiService();
  Future<ServiceRequest?>? _taskDetailFuture;
  model_user.User? _currentUser;

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      _loadTaskDetails();
    });
  }

  void _loadTaskDetails() {
    if (mounted) {
      setState(() {
        _taskDetailFuture = _apiService.getServiceRequestDetails(widget.taskId);
      });
    }
  }

  Future<void> _updateTaskStatus(ServiceRequest task, ServiceStatus newStatus) async {
    String actionVerb = "";
    switch (newStatus) {
      case ServiceStatus.inProgress: actionVerb = "iniciar"; break;
      case ServiceStatus.completed: actionVerb = "completar"; break;
      default: actionVerb = "actualizar"; // Should not happen with current buttons
    }

    bool? confirmed = await Helpers.showConfirmationDialog(
      context,
      title: '${Helpers.capitalizeFirstLetter(actionVerb)} Trabajo',
      content: '¿Estás seguro de que deseas ${actionVerb.toLowerCase()} este trabajo?',
      confirmText: 'Sí, ${Helpers.capitalizeFirstLetter(actionVerb)}',
      cancelText: 'No'
    );

    if (confirmed == true && mounted) {
      try {
        Helpers.showLoadingDialog(context, message: "${Helpers.capitalizeFirstLetter(actionVerb)}ndo trabajo...");
        // Ensure workerId is passed, especially if it's not already on the task object from a previous state.
        // For worker actions, workerId should be the current user's ID.
        await _apiService.updateServiceRequestStatus(task.id, newStatus, workerId: _currentUser?.id ?? task.workerId);
        if(mounted) {
          Helpers.hideLoadingDialog(context);
          Helpers.showSnackBar(context, 'Trabajo ${newStatus == ServiceStatus.inProgress ? "iniciado" : "completado"} con éxito.');
          _loadTaskDetails(); // Refresh details
          Navigator.of(context).pop(true); // Indicate change to previous screen
        }
      } catch (e) {
        if(mounted) {
          Helpers.hideLoadingDialog(context);
          Helpers.showSnackBar(context, 'Error al ${actionVerb.toLowerCase()} trabajo: ${e.toString()}', isError: true);
        }
      }
    }
  }

  // Example: Launching maps (ensure url_launcher is in pubspec.yaml)
  // Future<void> _launchMaps(String? address) async {
  //   if (address == null || address.isEmpty) {
  //     Helpers.showSnackBar(context, 'Dirección no disponible.', isError: true);
  //     return;
  //   }
  //   final query = Uri.encodeComponent(address);
  //   // Using a generic maps URL that works on both platforms
  //   final Uri mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  //   if (await canLaunchUrl(mapsUrl)) {
  //     await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
  //   } else {
  //     Helpers.showSnackBar(context, 'No se pudo abrir la aplicación de mapas.', isError: true);
  //   }
  // }

  // Example: Launching phone dialer
  // Future<void> _callClient(String? phoneNumber) async {
  //   if (phoneNumber == null || phoneNumber.isEmpty) {
  //      Helpers.showSnackBar(context, 'Número de teléfono no disponible.', isError: true);
  //      return;
  //   }
  //   final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  //    if (await canLaunchUrl(phoneUri)) {
  //     await launchUrl(phoneUri);
  //   } else {
  //     Helpers.showSnackBar(context, 'No se pudo iniciar la llamada.', isError: true);
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Trabajo')),
      body: _taskDetailFuture == null
      ? const Center(child: CircularProgressIndicator())
      : FutureBuilder<ServiceRequest?>(
        future: _taskDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error al cargar detalles: ${snapshot.error?.toString() ?? "Trabajo no encontrado"}'));
          }

          final task = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadTaskDetails(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaskSummary(task),
                  const SizedBox(height: kDefaultPadding),
                  if (task.client != null) ...[
                    _buildPartyInfo(task.client!, "Información del Cliente"),
                    const SizedBox(height: kDefaultPadding),
                  ],
                  _buildStatusSpecificInfo(task), // Shows client's rating for worker
                  const SizedBox(height: kLargePadding),
                  _buildActionButtons(task),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskSummary(ServiceRequest task) {
    final textTheme = Theme.of(context).textTheme;
    return CustomCard(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task.category, style: textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              Chip(
                label: Text(Helpers.capitalizeFirstLetter(task.status.name), style: textTheme.labelSmall?.copyWith(color: Colors.white)),
                backgroundColor: Helpers.getStatusColor(task.status, Theme.of(context).colorScheme),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              )
            ],
          ),
          const SizedBox(height: kDefaultPadding),
          _buildDetailRow(Icons.calendar_today_outlined, 'Fecha y Hora:', Helpers.formatDateTime(task.dateTime)),
          _buildDetailRow(Icons.location_on_outlined, 'Dirección:', task.address),
          if (task.description.isNotEmpty)
            _buildDetailRow(Icons.description_outlined, 'Descripción:', task.description),
          if (task.estimatedCost != null)
            _buildDetailRow(Icons.monetization_on_outlined, 'Pago Estimado:', Helpers.formatCurrency(task.estimatedCost)),
          if (task.finalCost != null) // Usually shown when completed
            _buildDetailRow(Icons.payment_outlined, 'Pago Final:', Helpers.formatCurrency(task.finalCost)),
        ],
      ),
    );
  }

  Widget _buildPartyInfo(model_user.User party, String title) {
    final textTheme = Theme.of(context).textTheme;
    return CustomCard(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: kDefaultPadding),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: UserAvatar(user: party, radius: 28),
            title: Text(party.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text(party.address ?? 'Dirección no especificada', style: textTheme.bodySmall),
            // trailing: Row( // Actions like Call, Message, Map
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     IconButton(
            //       icon: Icon(Icons.phone_outlined, color: Theme.of(context).primaryColor),
            //       tooltip: 'Llamar al cliente',
            //       onPressed: () => _callClient(party.phoneNumber),
            //     ),
            //     // IconButton(
            //     //   icon: Icon(Icons.message_outlined, color: Theme.of(context).primaryColor),
            //     //   tooltip: 'Enviar mensaje',
            //     //   onPressed: () { /* TODO: Chat with client */ },
            //     // ),
            //   ],
            // ),
          ),
          // if (party.address != null && party.address!.isNotEmpty)
          //   Padding(
          //     padding: const EdgeInsets.only(top: kSmallPadding),
          //     child: SizedBox(
          //       width: double.infinity,
          //       child: OutlinedButton.icon(
          //         icon: const Icon(Icons.directions_outlined),
          //         label: const Text('Ver en Mapa'),
          //         onPressed: () => _launchMaps(party.address),
          //       ),
          //     ),
          //   )
        ],
      ),
    );
  }

   Widget _buildStatusSpecificInfo(ServiceRequest task) {
    // For worker, show client's rating if available
    if (task.status == ServiceStatus.completed && task.clientRatingForWorker != null) {
      return CustomCard(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calificación Recibida del Cliente', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: kSmallPadding),
            Row(
              children: List.generate(5, (idx) => Icon(idx < task.clientRatingForWorker! ? Icons.star : Icons.star_border, color: Colors.amber, size: 24,)),
            ),
            if(task.clientReviewForWorker != null && task.clientReviewForWorker!.isNotEmpty) ...[
              const SizedBox(height: kSmallPadding),
              Text('Comentario del cliente: "${task.clientReviewForWorker!}"', style: const TextStyle(fontStyle: FontStyle.italic)),
            ]
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }


  Widget _buildActionButtons(ServiceRequest task) {
    List<Widget> buttons = [];
     final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: kSmallPadding, horizontal: kDefaultPadding),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );


    if (task.status == ServiceStatus.accepted) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_fill_outlined),
          label: const Text('Iniciar Trabajo'),
          onPressed: () => _updateTaskStatus(task, ServiceStatus.inProgress),
          style: buttonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)),
        ),
      );
    }

    if (task.status == ServiceStatus.inProgress) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Completar Trabajo'),
          onPressed: () => _updateTaskStatus(task, ServiceStatus.completed),
          style: buttonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary)),
        ),
      );
    }

    // Worker rating client is not part of this flow per requirements (client rates worker)
    // if (task.status == ServiceStatus.completed && task.workerRatingForClient == null && task.client != null) {
    //   buttons.add(
    //     ElevatedButton.icon(
    //       icon: const Icon(Icons.star_outline_rounded),
    //       label: const Text('Calificar Cliente'),
    //       onPressed: () { /* TODO: Implement worker rating client if needed */ },
    //       style: buttonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Colors.amber.shade700)),
    //     ),
    //   );
    // }

    if (buttons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
        child: Text("No hay acciones disponibles para este trabajo en este momento.", style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((btn) => Padding(padding: const EdgeInsets.only(bottom: kSmallPadding), child: btn)).toList(),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor.withOpacity(0.8)),
          const SizedBox(width: kDefaultPadding * 0.75),
          Text('$label ', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
