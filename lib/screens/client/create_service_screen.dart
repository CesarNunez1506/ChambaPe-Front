import 'package:chamba_app/models/service_request_model.dart';
import 'package:chamba_app/models/user_model.dart' as model_user;
import 'package:chamba_app/providers/auth_provider.dart';
import 'package:chamba_app/services/api_service.dart';
import 'package:chamba_app/utils/constants.dart';
import 'package:chamba_app/utils/helpers.dart';
import 'package:chamba_app/widgets/custom_textfield.dart';
import 'package:chamba_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  model_user.User? _currentUser;

  String? _selectedCategory;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (_currentUser?.address != null && _currentUser!.address!.isNotEmpty) {
      _addressController.text = _currentUser!.address!;
    }
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days:1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _submitServiceRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      Helpers.showSnackBar(context, 'Por favor selecciona una categoría.', isError: true);
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      Helpers.showSnackBar(context, 'Por favor selecciona fecha y hora.', isError: true);
      return;
    }

    if (_currentUser == null) {
      Helpers.showSnackBar(context, 'Error: Usuario no autenticado. Por favor, inicia sesión.', isError: true);
      // Optionally navigate to login: Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    setState(() => _isLoading = true);

    final DateTime combinedDateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    ServiceRequest newRequest = ServiceRequest(
      id: '',
      clientId: _currentUser!.id,
      category: _selectedCategory!,
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      dateTime: combinedDateTime,
      createdAt: DateTime.now(),
    );

    try {
      final createdRequest = await _apiService.createServiceRequest(newRequest);
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showSnackBar(context, 'Servicio "${createdRequest.category}" solicitado con éxito.');
        _showAssignedWorkerDialog(createdRequest);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showSnackBar(context, 'Error al solicitar servicio: ${e.toString()}', isError: true);
      }
    }
  }

  void _showAssignedWorkerDialog(ServiceRequest request) {
    // Simulate fetching an assigned worker for demo purposes
    // In a real app, this worker info would come from the backend response or a subsequent fetch
    final assignedWorker = model_user.User.placeholderWorker.copyWith(
      name: "Ana García", // Example
      profilePictureUrl: 'https://via.placeholder.com/150/4CAF50/FFFFFF?Text=AG', // Green background
      averageRating: 4.7,
      totalRatings: 35,
      isVerified: true,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultBorderRadius)),
          titlePadding: const EdgeInsets.only(top: kDefaultPadding, bottom: kSmallPadding),
          contentPadding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kSmallPadding),
          actionsPadding: const EdgeInsets.all(kSmallPadding),
          title: Text('¡Trabajador Asignado!', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(user: assignedWorker, radius: 36),
              const SizedBox(height: kDefaultPadding),
              Text('Te tocó:', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                assignedWorker.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: kSmallPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) => Icon(
                    index < assignedWorker.averageRating.floor() ? Icons.star :
                    (assignedWorker.averageRating > index && assignedWorker.averageRating < index + 1) ? Icons.star_half : Icons.star_border,
                    color: Colors.amber, size: 20,
                  )),
                  const SizedBox(width: kSmallPadding),
                  Text("(${assignedWorker.totalRatings})", style: Theme.of(context).textTheme.bodySmall)
                ]
              ),
              if(assignedWorker.isVerified) ...[
                const SizedBox(height: kSmallPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, color: Theme.of(context).colorScheme.secondary, size: 18),
                    const SizedBox(width: 4),
                    Text(kVerifiedText, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                )
              ],
              const SizedBox(height: kDefaultPadding),
              Text("Categoría: ${request.category}", style: Theme.of(context).textTheme.bodySmall),
              Text("Fecha: ${Helpers.formatDateTime(request.dateTime)}", style: Theme.of(context).textTheme.bodySmall),

            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                Helpers.showLoadingDialog(context, message: "Cancelando...");
                await _apiService.updateServiceRequestStatus(request.id, ServiceStatus.cancelled);
                if(mounted) {
                  Helpers.hideLoadingDialog(context);
                  Helpers.showSnackBar(context, 'Solicitud cancelada.');
                  Navigator.of(context).pop(true); // Go back and refresh dashboard
                }
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
              child: const Text('Confirmar'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                Helpers.showLoadingDialog(context, message: "Confirmando...");
                // In a real app, this might just confirm the client's side, worker still needs to accept.
                // Or it could directly assign if the system is designed that way.
                await _apiService.updateServiceRequestStatus(request.id, ServiceStatus.accepted, workerId: assignedWorker.id);
                 if(mounted){
                  Helpers.hideLoadingDialog(context);
                  Helpers.showSnackBar(context, '${assignedWorker.name} confirmado para tu servicio.');
                  Navigator.of(context).pop(true); // Go back and refresh dashboard
                 }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Nuevo Servicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cuéntanos qué necesitas', style: textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: kLargePadding),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Categoría del Servicio',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                hint: const Text('Selecciona una categoría'),
                isExpanded: true,
                items: kServiceCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() { _selectedCategory = newValue; });
                },
                validator: (value) => value == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: kDefaultPadding),
              CustomTextField(
                controller: _addressController,
                labelText: 'Dirección del Servicio',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) => value == null || value.isEmpty ? 'Ingresa la dirección' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: kDefaultPadding),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Descripción Adicional (Opcional)',
                hintText: 'Ej: "Necesito pintar la sala de color blanco humo."',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: kLargePadding),
              Text('Horario Deseado', style: textTheme.titleLarge),
              const SizedBox(height: kSmallPadding),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                           border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedDate != null ? DateFormat('EEE, dd MMM yyyy', 'es_ES').format(_selectedDate!) : 'Seleccionar',
                           style: textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: kSmallPadding),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                           prefixIcon: Icon(Icons.access_time_outlined),
                           border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedTime != null ? _selectedTime!.format(context) : 'Seleccionar',
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kLargePadding * 1.5),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Solicitar Ahora'),
                        onPressed: _submitServiceRequest,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 0.9),
                          textStyle: textTheme.labelLarge,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
