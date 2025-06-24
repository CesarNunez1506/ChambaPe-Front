import 'package:chamba_app/models/subscription_plan_model.dart';
import 'package:chamba_app/models/user_model.dart' as model_user;
import 'package:chamba_app/providers/auth_provider.dart';
import 'package:chamba_app/services/api_service.dart';
import 'package:chamba_app/utils/constants.dart';
import 'package:chamba_app/utils/helpers.dart';
import 'package:chamba_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final ApiService _apiService = ApiService();
  Future<List<SubscriptionPlan>>? _plansFuture;
  model_user.User? _currentUser;
  SubscriptionPlan? _currentSubscription;
  bool _isLoadingSubscription = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
      _plansFuture = _apiService.getSubscriptionPlans();
      _loadCurrentSubscription();
    });
  }

  Future<void> _loadCurrentSubscription() async {
    if (_currentUser == null || !mounted) {
      if (mounted) setState(() => _isLoadingSubscription = false);
      return;
    }
    if (mounted) setState(() => _isLoadingSubscription = true);
    try {
      _currentSubscription = await _apiService.getCurrentUserSubscription(_currentUser!.id);
    } catch (e) {
      if (mounted) Helpers.showSnackBar(context, "Error cargando tu suscripción: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingSubscription = false);
    }
  }

  Future<void> _subscribeToPlan(SubscriptionPlan plan) async {
    if (_currentUser == null) {
      Helpers.showSnackBar(context, 'Debes iniciar sesión para suscribirte.', isError: true);
      return;
    }
    if (_currentSubscription?.id == plan.id) {
      Helpers.showSnackBar(context, 'Ya estás suscrito a este plan.');
      return;
    }

    bool? confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Confirmar Suscripción',
      content: '¿Deseas suscribirte al plan ${plan.name} por ${Helpers.formatCurrency(plan.price)}/mes?',
      confirmText: 'Sí, Suscribirme',
      cancelText: 'Ahora No'
    );

    if (confirmed == true && mounted) {
      try {
        Helpers.showLoadingDialog(context, message: 'Procesando suscripción...');
        bool success = await _apiService.subscribeToPlan(_currentUser!.id, plan.id);
        if(mounted) Helpers.hideLoadingDialog(context);

        if (success) {
          if(mounted) Helpers.showSnackBar(context, '¡Suscripción al plan ${plan.name} exitosa!');
          _loadCurrentSubscription();
        } else {
          if(mounted) Helpers.showSnackBar(context, 'No se pudo completar la suscripción.', isError: true);
        }
      } catch (e) {
        if(mounted) {
          Helpers.hideLoadingDialog(context);
          Helpers.showSnackBar(context, 'Error al suscribirse: ${e.toString()}', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
     _currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Planes de Suscripción')),
      body: _plansFuture == null || _isLoadingSubscription
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<SubscriptionPlan>>(
              future: _plansFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar planes: ${snapshot.error.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.error)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay planes disponibles en este momento.'));
                }

                final plans = snapshot.data!;
                plans.sort((a, b) {
                  if (a.isPopular && !b.isPopular) return -1;
                  if (!a.isPopular && b.isPopular) return 1;
                  return b.price.compareTo(a.price);
                });

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadCurrentSubscription(); // Reload current subscription as well
                     if (mounted) {
                       setState(() { // Re-assign future to trigger FutureBuilder
                         _plansFuture = _apiService.getSubscriptionPlans();
                       });
                     }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_currentUser?.userType == model_user.UserType.worker) ...[
                           Text(
                            "Potencia tus oportunidades como trabajador con nuestros planes:",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: kSmallPadding),
                        ],
                        if (_currentSubscription != null)
                          _buildCurrentSubscriptionCard(_currentSubscription!),

                        ...plans.map((plan) => _buildPlanCard(plan, isCurrentPlan: _currentSubscription?.id == plan.id)).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCurrentSubscriptionCard(SubscriptionPlan plan) {
    final theme = Theme.of(context);
    return CustomCard(
      color: plan.getPlanColor(context).withOpacity(0.15),
      margin: const EdgeInsets.only(bottom: kLargePadding, top: kSmallPadding),
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tu Plan Actual:",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: kSmallPadding),
          Text(
            plan.name,
            style: theme.textTheme.headlineSmall?.copyWith(color: plan.getPlanColor(context), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Precio: ${Helpers.formatCurrency(plan.price)}/mes",
            style: theme.textTheme.bodyLarge,
          ),
          // TODO: Add more details like renewal date, specific benefits unlocked
          // Example: Text("Se renueva el: ${Helpers.formatDate(DateTime.now().add(Duration(days:30)))}"),
        ],
      ),
    );
  }


  Widget _buildPlanCard(SubscriptionPlan plan, {bool isCurrentPlan = false}) {
    final theme = Theme.of(context);
    final planColor = plan.getPlanColor(context);
    final bool isWorker = _currentUser?.userType == model_user.UserType.worker;

    return CustomCard(
      elevation: plan.isPopular ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: kSmallPadding),
      borderColor: plan.isPopular ? planColor : (isCurrentPlan ? theme.colorScheme.primary : null),
      borderWidth: plan.isPopular ? 2.5 : (isCurrentPlan ? 1.5 : 0),
      padding: EdgeInsets.zero, // Padding will be handled by inner Stack's child
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: planColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: kSmallPadding),
                Text(
                  plan.price == 0 ? 'Gratis' : '${Helpers.formatCurrency(plan.price)}/mes',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: kDefaultPadding),
                Text('Beneficios:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: kSmallPadding),
                ...plan.benefits.map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 20, color: theme.colorScheme.secondary),
                          const SizedBox(width: kSmallPadding),
                          Expanded(child: Text(benefit, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    )),
                const SizedBox(height: kLargePadding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : () => _subscribeToPlan(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan ? Colors.grey.shade400 : planColor,
                      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding * 0.8),
                      disabledBackgroundColor: Colors.grey.shade400,
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        color: planColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      )
                    ),
                    child: Text(
                      isCurrentPlan ? 'Plan Actual' : (plan.tier == PlanTier.free && _currentSubscription != null ? 'Cambiar a Gratuito' : 'Contratar Plan'),
                       style: TextStyle(color: (isCurrentPlan ? Colors.grey.shade700 : planColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (plan.isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding * 0.75, vertical: kSmallPadding / 2),
                decoration: BoxDecoration(
                  color: planColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(kDefaultBorderRadius -1), // Match CustomCard radius
                    bottomLeft: Radius.circular(kDefaultBorderRadius),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
           if (plan.tier == PlanTier.premium && isWorker) // Show priority badge only for workers on premium
             Positioned(
              bottom: 70, // Adjust as needed based on button height
              left: kDefaultPadding,
              right: kDefaultPadding,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: kSmallPadding /2, horizontal: kSmallPadding),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(kDefaultBorderRadius /2),
                  // border: Border.all(color: Colors.amber.shade600, width: 0.5)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_purple500_outlined, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "Prioridad en asignaciones automáticas",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                      ),
                    )
                  ],
                ),
              )
            )
        ],
      ),
    );
  }
}
