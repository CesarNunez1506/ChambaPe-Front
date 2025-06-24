import 'package:chamba_app/models/user_model.dart';

enum ServiceStatus { pending, accepted, inProgress, completed, cancelled, rejected }

class ServiceRequest {
  final String id;
  final String clientId; // ID of the client who requested the service
  final String? workerId; // ID of the worker assigned (nullable if not yet assigned)
  final String category;
  final String description; // Optional, could be added
  final String address;
  final DateTime dateTime; // Requested date and time for the service
  final ServiceStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? estimatedCost; // Optional
  final double? finalCost; // Optional
  final int? clientRatingForWorker; // Rating given by client to worker
  final String? clientReviewForWorker; // Review given by client to worker
  final int? workerRatingForClient; // Rating given by worker to client (less common but possible)
  final String? workerReviewForClient; // Review given by worker to client

  // Potentially include User objects if data is denormalized or fetched together
  final User? client;
  final User? worker;

  ServiceRequest({
    required this.id,
    required this.clientId,
    this.workerId,
    required this.category,
    this.description = '',
    required this.address,
    required this.dateTime,
    this.status = ServiceStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.estimatedCost,
    this.finalCost,
    this.clientRatingForWorker,
    this.clientReviewForWorker,
    this.workerRatingForClient,
    this.workerReviewForClient,
    this.client,
    this.worker,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      workerId: json['worker_id'] as String?,
      category: json['category'] as String,
      description: json['description'] as String? ?? '',
      address: json['address'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      status: _serviceStatusFromString(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
      finalCost: (json['final_cost'] as num?)?.toDouble(),
      clientRatingForWorker: json['client_rating_for_worker'] as int?,
      clientReviewForWorker: json['client_review_for_worker'] as String?,
      workerRatingForClient: json['worker_rating_for_client'] as int?,
      workerReviewForClient: json['worker_review_for_client'] as String?,
      client: json['client'] != null ? User.fromJson(json['client'] as Map<String, dynamic>) : null,
      worker: json['worker'] != null ? User.fromJson(json['worker'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'worker_id': workerId,
      'category': category,
      'description': description,
      'address': address,
      'date_time': dateTime.toIso8601String(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'estimated_cost': estimatedCost,
      'final_cost': finalCost,
      'client_rating_for_worker': clientRatingForWorker,
      'client_review_for_worker': clientReviewForWorker,
      'worker_rating_for_client': workerRatingForClient,
      'worker_review_for_client': workerReviewForClient,
      'client': client?.toJson(),
      'worker': worker?.toJson(),
    };
  }

  static ServiceStatus _serviceStatusFromString(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'pending':
        return ServiceStatus.pending;
      case 'accepted':
        return ServiceStatus.accepted;
      case 'inprogress':
      case 'in_progress':
        return ServiceStatus.inProgress;
      case 'completed':
        return ServiceStatus.completed;
      case 'cancelled':
        return ServiceStatus.cancelled;
      case 'rejected':
        return ServiceStatus.rejected;
      default:
        return ServiceStatus.pending;
    }
  }

  // Example placeholder for UI development
  static ServiceRequest get placeholder => ServiceRequest(
    id: 'sr_placeholder_id',
    clientId: User.placeholderClient.id,
    workerId: User.placeholderWorker.id,
    category: 'Jardinería',
    description: 'Cortar el césped y podar arbustos pequeños. Herramientas no incluidas.',
    address: 'Av. Arequipa 123, Lince, Lima',
    dateTime: DateTime.now().add(const Duration(days: 2, hours: 3)), // 2 days from now at 3 PM
    status: ServiceStatus.accepted,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    updatedAt: DateTime.now(),
    client: User.placeholderClient,
    worker: User.placeholderWorker,
    estimatedCost: 80.00,
  );

  static List<ServiceRequest> get sampleRequests => [
    ServiceRequest(
      id: 'sr_1',
      clientId: 'client_123',
      category: 'Plomería',
      address: 'Calle Los Pinos 789, San Isidro',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      status: ServiceStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      client: User.placeholderClient.copyWith(name: "Ana Torres"),
      description: 'Fuga en el grifo de la cocina.',
      estimatedCost: 120.0,
    ),
    ServiceRequest(
      id: 'sr_2',
      clientId: 'client_456',
      workerId: User.placeholderWorker.id,
      category: 'Pintura',
      address: 'Av. Javier Prado Este 101, La Molina',
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 9)),
      status: ServiceStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      client: User.placeholderClient.copyWith(name: "Carlos Luna"),
      worker: User.placeholderWorker,
      description: 'Pintar una habitación de 3x4 metros, color blanco.',
      estimatedCost: 350.0,
    ),
     ServiceRequest(
      id: 'sr_3',
      clientId: 'client_789',
      workerId: 'worker_002',
      category: 'Limpieza',
      address: 'Jr. de la Union 555, Cercado de Lima',
      dateTime: DateTime.now().subtract(const Duration(days: 2)), // Past task
      status: ServiceStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2, hours: -3)), // Completed 3 hours after start
      client: User.placeholderClient.copyWith(name: "Sofia Vega"),
      worker: User.placeholderWorker.copyWith(name: "Luis Gómez", id: "worker_002", averageRating: 4.5, totalRatings: 30, isVerified: false),
      description: 'Limpieza profunda de departamento de 2 habitaciones.',
      finalCost: 150.0,
      clientRatingForWorker: 5,
      clientReviewForWorker: "Excelente trabajo, muy profesional y puntual."
    ),
  ];
}

// Helper extension for User copyWith (if not part of User model itself)
extension UserCopyWith on User {
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    UserType? userType,
    String? profilePictureUrl,
    bool? isVerified,
    double? averageRating,
    int? totalRatings,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      userType: userType ?? this.userType,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isVerified: isVerified ?? this.isVerified,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
  }
}
