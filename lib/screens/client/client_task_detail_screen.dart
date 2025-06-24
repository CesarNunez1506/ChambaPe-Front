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

class ClientTaskDetailScreen extends StatefulWidget {
  final String taskId;
  const ClientTaskDetailScreen({super.key, required this.taskId});

  @override
  State<ClientTaskDetailScreen> createState() => _ClientTaskDetailScreenState();
}

class _ClientTaskDetailScreenState extends State<ClientTaskDetailScreen> {
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


  Future<void> _cancelService(ServiceRequest task) async {
    bool? confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Cancelar Servicio',
      content: '¿Estás seguro de que deseas cancelar este servicio? Esta acción podría tener costos asociados dependiendo del estado del servicio y las políticas de cancelación.',
      confirmText: 'Sí, Cancelar',
      cancelText: 'No, Mantener'
    );
    if (confirmed == true && mounted) {
      try {
        Helpers.showLoadingDialog(context, message: "Cancelando servicio...");
        await _apiService.updateServiceRequestStatus(task.id, ServiceStatus.cancelled);
        if(mounted) {
          Helpers.hideLoadingDialog(context);
          Helpers.showSnackBar(context, 'Servicio cancelado con éxito.');
          _loadTaskDetails(); // Refresh details
          Navigator.of(context).pop(true); // Indicate to previous screen that data changed
        }
      } catch (e) {
        if(mounted) {
          Helpers.hideLoadingDialog(context);
          Helpers.showSnackBar(context, 'Error al cancelar: ${e.toString()}', isError: true);
        }
      }
    }
  }

  Future<void> _rateWorker(ServiceRequest task) async {
    if (task.worker == null || _currentUser == null) return;

    int? localRating; // Use a local variable for the dialog
    String localReview = '';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        int currentRatingForDialog = task.clientRatingForWorker ?? 0;
        TextEditingController reviewController = TextEditingController(text: task.clientReviewForWorker ?? '');

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Calificar a ${task.worker!.name}'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu experiencia con ${task.worker!.name}:', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: kDefaultPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < currentRatingForDialog ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              currentRatingForDialog = index + 1;
                            });
                            localRating = currentRatingForDialog;
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    CustomTextField( // Using CustomTextField for consistency
                      controller: reviewController,
                      labelText: 'Comentario (opcional)',
                      hintText: 'Describe tu experiencia...',
                      maxLines: 3,
                      onChanged: (value) => localReview = value,
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  child: const Text('Enviar'),
                  onPressed: (localRating == null || localRating == 0) ? null : () async {
                    Navigator.of(dialogContext).pop(); // Close dialog first
                    try {
                      Helpers.showLoadingDialog(context, message: "Enviando calificación...");
                      await _apiService.rateService(task.id, _currentUser!.id, model_user.UserType.client, localRating!, localReview);
                      if(mounted) {
                        Helpers.hideLoadingDialog(context);
                        Helpers.showSnackBar(context, 'Calificación enviada. ¡Gracias!');
                        _loadTaskDetails(); // Refresh details
                         Navigator.of(context).pop(true); // Indicate to previous screen that data changed
                      }
                    } catch (e) {
                       if(mounted) {
                        Helpers.hideLoadingDialog(context);
                        Helpers.showSnackBar(context, 'Error al enviar calificación: ${e.toString()}', isError: true);
                       }
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Servicio')),
      body: _taskDetailFuture == null
      ? const Center(child: CircularProgressIndicator()) // Show loader if future is not yet initialized
      : FutureBuilder<ServiceRequest?>(
        future: _taskDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error al cargar detalles: ${snapshot.error?.toString() ?? "Servicio no encontrado"}'));
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
                  if (task.worker != null) ...[
                    _buildPartyInfo(task.worker!, "Trabajador Asignado"),
                    const SizedBox(height: kDefaultPadding),
                  ] else if (task.status == ServiceStatus.pending)...[
                     _buildPartyInfo(null, "Buscando Trabajador"),
                    const SizedBox(height: kDefaultPadding),
                  ],
                  _buildStatusSpecificInfo(task),
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
            _buildDetailRow(Icons.monetization_on_outlined, 'Costo Estimado:', Helpers.formatCurrency(task.estimatedCost)),
          if (task.finalCost != null)
            _buildDetailRow(Icons.payment_outlined, 'Costo Final:', Helpers.formatCurrency(task.finalCost)),
        ],
      ),
    );
  }

  Widget _buildPartyInfo(model_user.User? party, String title) {
    final textTheme = Theme.of(context).textTheme;
    return CustomCard(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: kDefaultPadding),
          if (party != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: UserAvatar(user: party, radius: 28),
              title: Text(party.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (party.userType == model_user.UserType.worker) ...[
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text('${party.averageRating.toStringAsFixed(1)} (${party.totalRatings} calif.)', style: textTheme.bodySmall),
                      ],
                    ),
                    if (party.isVerified)
                      Row(
                        children: [
                          Icon(Icons.verified_user, color: Theme.of(context).colorScheme.secondary, size: 16),
                          const SizedBox(width: 4),
                          Text(kVerifiedText, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                  ] else ... [
                     Text(party.email, style: textTheme.bodySmall), // Example for client info
                  ]
                ],
              ),
              // trailing: (party.userType == model_user.UserType.worker)
              // ? IconButton(icon: Icon(Icons.message_outlined, color: Theme.of(context).primaryColor), onPressed: () { /* TODO: Chat with worker */ })
              // : null,
            )
          else
            Row(
              children: [
                const CircularProgressIndicator(strokeWidth: 2.0),
                const SizedBox(width: kDefaultPadding),
                Text("Esperando asignación...", style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusSpecificInfo(ServiceRequest task) {
    if (task.status == ServiceStatus.completed && task.clientRatingForWorker != null) {
      return CustomCard(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu Calificación para ${task.worker?.name ?? "el trabajador"}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: kSmallPadding),
            Row(
              children: List.generate(5, (idx) => Icon(idx < task.clientRatingForWorker! ? Icons.star : Icons.star_border, color: Colors.amber, size: 24)),
            ),
            if(task.clientReviewForWorker != null && task.clientReviewForWorker!.isNotEmpty) ...[
              const SizedBox(height: kSmallPadding),
              Text('Comentario: "${task.clientReviewForWorker!}"', style: const TextStyle(fontStyle: FontStyle.italic)),
            ]
          ],
        ),
      );
    }
    return const SizedBox.shrink(); // No specific info for other statuses for now
  }

  Widget _buildActionButtons(ServiceRequest task) {
    List<Widget> buttons = [];
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: kSmallPadding, horizontal: kDefaultPadding),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );

    // Can cancel if pending or accepted (before work starts, business rule dependent)
    if (task.status == ServiceStatus.pending || task.status == ServiceStatus.accepted) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar Servicio'),
          onPressed: () => _cancelService(task),
          style: buttonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.error)),
        ),
      );
    }

    // Can rate if completed and not yet rated by client
    if (task.status == ServiceStatus.completed && task.clientRatingForWorker == null && task.worker != null) {
      buttons.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.star_rate_outlined),
          label: const Text('Calificar Trabajador'),
          onPressed: () => _rateWorker(task),
          style: buttonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Colors.amber.shade700)),
        ),
      );
    }

    // TODO: Add "Contact Worker" button if task.status is accepted or inProgress and worker is assigned
    // Example:
    // if ((task.status == ServiceStatus.accepted || task.status == ServiceStatus.inProgress) && task.worker != null) {
    //   buttons.add(ElevatedButton.icon(icon: Icon(Icons.message_outlined), label: Text("Contactar a ${task.worker!.name}"), onPressed: (){}, style: buttonStyle));
    // }


    if (buttons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
        child: Text("No hay acciones disponibles para este servicio en este momento.", style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
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
