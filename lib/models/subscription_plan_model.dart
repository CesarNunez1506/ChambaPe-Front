import 'package:flutter/material.dart';

enum PlanTier { free, basic, premium }

class SubscriptionPlan {
  final String id;
  final String name;
  final PlanTier tier;
  final double price; // Monthly price
  final List<String> benefits;
  final String? priceId; // For payment gateway integration (e.g., Stripe Price ID)
  final bool isPopular; // To highlight a specific plan

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
    required this.benefits,
    this.priceId,
    this.isPopular = false,
  });

  // Factory constructor for creating a new SubscriptionPlan instance from a map
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: _planTierFromString(json['tier'] as String?),
      price: (json['price'] as num).toDouble(),
      benefits: List<String>.from(json['benefits'] as List<dynamic>),
      priceId: json['price_id'] as String?,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  // Method to convert a SubscriptionPlan instance to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier.name,
      'price': price,
      'benefits': benefits,
      'price_id': priceId,
      'is_popular': isPopular,
    };
  }

  static PlanTier _planTierFromString(String? tierStr) {
    switch (tierStr?.toLowerCase()) {
      case 'free':
        return PlanTier.free;
      case 'basic':
        return PlanTier.basic;
      case 'premium':
        return PlanTier.premium;
      default:
        return PlanTier.free; // Default to free if unknown
    }
  }

  // Sample plans for UI development
  static List<SubscriptionPlan> get samplePlans => [
    SubscriptionPlan(
      id: 'plan_free_01',
      name: 'Gratuito',
      tier: PlanTier.free,
      price: 0.00,
      benefits: [
        'Publicar hasta 3 servicios al mes',
        'Recibir ofertas de trabajadores',
        'Acceso limitado a historial',
      ],
    ),
    SubscriptionPlan(
      id: 'plan_basic_01',
      name: 'Básico',
      tier: PlanTier.basic,
      price: 19.99, // Example price in local currency (e.g., PEN)
      benefits: [
        'Publicar hasta 10 servicios al mes',
        'Soporte por chat',
        'Acceso completo a historial',
        'Menor comisión por servicio (trabajador)',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'plan_premium_01',
      name: 'Premium',
      tier: PlanTier.premium,
      price: 49.99, // Example price
      benefits: [
        'Publicaciones ilimitadas de servicios',
        'Prioridad en asignaciones automáticas (trabajador)',
        'Soporte prioritario 24/7',
        'Sin comisión por servicio (trabajador)',
        'Verificación destacada (trabajador)',
        'Acceso a estadísticas avanzadas',
      ],
      priceId: 'price_premium_monthly_live', // Example Stripe Price ID
    ),
  ];

  // Helper to get a color based on plan tier, useful for UI
  Color getPlanColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (tier) {
      case PlanTier.free:
        return Colors.grey.shade400;
      case PlanTier.basic:
        return colorScheme.secondary; // Use app's secondary color
      case PlanTier.premium:
        return colorScheme.primary; // Use app's primary color
      default:
        return Colors.grey;
    }
  }
}
