// Placeholder for API service implementation
// This file would contain functions to interact with a backend API.
// For now, it will just have mock functions returning sample data.

import 'dart:convert';
import 'package:chamba_app/models/user_model.dart';
import 'package:chamba_app/models/service_request_model.dart';
import 'package:chamba_app/models/subscription_plan_model.dart';
// import 'package:http/http.dart' as http; // Uncomment when using real HTTP requests
// import 'package:chamba_app/utils/constants.dart'; // For API base URL and endpoints

class ApiService {
  // Simulates a delay as if a network request is being made
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // --- Authentication ---
  Future<User?> login(String email, String password) async {
    await _simulateNetworkDelay();
    print('API: Attempting login for $email');
    // Simulate success for a generic user, or failure
    if (email == "cliente@example.com" && password == "password") {
      return User.placeholderClient;
    } else if (email == "trabajador@example.com" && password == "password") {
      return User.placeholderWorker;
    }
    // Simulate error
    // throw Exception('Invalid credentials');
    return null;
  }

  Future<User?> register(User user, String password) async {
    await _simulateNetworkDelay();
    print('API: Attempting registration for ${user.name} as ${user.userType.name}');
    // Simulate successful registration by returning the user with an ID
    return user.copyWith(id: 'new_${user.userType.name}_id_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> logout() async {
    await _simulateNetworkDelay();
    print('API: User logged out');
    // In a real app, invalidate token, clear session, etc.
  }

  Future<bool> requestPasswordReset(String email) async {
    await _simulateNetworkDelay();
    print('API: Requesting password reset for $email');
    return true; // Simulate success
  }

  // --- User Profile ---
  Future<User?> getUserProfile(String userId) async {
    await _simulateNetworkDelay();
    print('API: Fetching profile for user $userId');
    if (userId == User.placeholderClient.id) return User.placeholderClient;
    if (userId == User.placeholderWorker.id) return User.placeholderWorker;
    return null; // Or throw Exception('User not found');
  }

  Future<User?> updateUserProfile(User user) async {
    await _simulateNetworkDelay();
    print('API: Updating profile for ${user.name}');
    return user; // Simulate successful update
  }

  // --- Service Requests (Tasks) ---
  Future<ServiceRequest> createServiceRequest(ServiceRequest request) async {
    await _simulateNetworkDelay();
    print('API: Creating service request for category ${request.category}');
    // Simulate successful creation by returning the request with an ID and createdAt
    return request.copyWith(
      id: 'sr_new_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      status: ServiceStatus.pending // Initial status
    );
  }

  Future<List<ServiceRequest>> getClientServiceRequests(String clientId, {ServiceStatus? status}) async {
    await _simulateNetworkDelay();
    print('API: Fetching service requests for client $clientId, status: ${status?.name}');
    var requests = ServiceRequest.sampleRequests.where((req) => req.clientId == clientId).toList();
    if (status != null) {
      requests = requests.where((req) => req.status == status).toList();
    }
    return requests;
  }

  Future<List<ServiceRequest>> getWorkerServiceRequests(String workerId, {ServiceStatus? status}) async {
    await _simulateNetworkDelay();
    print('API: Fetching service requests for worker $workerId, status: ${status?.name}');
    var requests = ServiceRequest.sampleRequests.where((req) => req.workerId == workerId).toList();
    if (status != null) {
      requests = requests.where((req) => req.status == status).toList();
    }
    // Add a new pending request for the placeholder worker to demonstrate acceptance flow
    if (workerId == User.placeholderWorker.id && (status == null || status == ServiceStatus.pending)) {
       requests.insert(0, ServiceRequest(
        id: 'sr_new_pending_${DateTime.now().millisecondsSinceEpoch}',
        clientId: 'client_temp_id',
        category: 'Gasfitería',
        address: 'Av. El Sol 123, Chorrillos',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 14)), // Tomorrow 2 PM
        status: ServiceStatus.pending,
        createdAt: DateTime.now(),
        client: User.placeholderClient.copyWith(name: "Laura Palma", id: "client_temp_id"),
        description: "Revisión de tuberías y posible cambio de caño en baño.",
        estimatedCost: 90.0,
      ));
    }
    return requests;
  }

  Future<ServiceRequest?> getServiceRequestDetails(String serviceRequestId) async {
    await _simulateNetworkDelay();
    print('API: Fetching details for service request $serviceRequestId');
    return ServiceRequest.sampleRequests.firstWhere((req) => req.id == serviceRequestId, orElse: () => ServiceRequest.placeholder);
  }

  Future<ServiceRequest> updateServiceRequestStatus(String serviceRequestId, ServiceStatus newStatus, {String? workerId}) async {
    await _simulateNetworkDelay();
    print('API: Updating status for $serviceRequestId to ${newStatus.name}, worker: $workerId');
    ServiceRequest originalRequest = ServiceRequest.sampleRequests.firstWhere((req) => req.id == serviceRequestId, orElse: () => ServiceRequest.placeholder);

    // In a real scenario, you'd send this to the backend. Here we simulate it.
    return originalRequest.copyWith(
      status: newStatus,
      workerId: workerId ?? originalRequest.workerId, // Assign worker if status is 'accepted'
      updatedAt: DateTime.now(),
      // If accepted, assign the placeholder worker if no specific workerId is passed
      worker: (newStatus == ServiceStatus.accepted && workerId == null && originalRequest.worker == null)
              ? User.placeholderWorker
              : originalRequest.worker,
    );
  }

  Future<ServiceRequest> rateService(String serviceRequestId, String userId, UserType userType, int rating, String review) async {
    await _simulateNetworkDelay();
    print('API: User $userId ($userType) rated service $serviceRequestId with $rating stars. Review: $review');
    ServiceRequest originalRequest = ServiceRequest.sampleRequests.firstWhere((req) => req.id == serviceRequestId, orElse: () => ServiceRequest.placeholder);
     if (userType == UserType.client) {
      return originalRequest.copyWith(clientRatingForWorker: rating, clientReviewForWorker: review, updatedAt: DateTime.now());
    } else {
      return originalRequest.copyWith(workerRatingForClient: rating, workerReviewForClient: review, updatedAt: DateTime.now());
    }
  }

  // --- Subscriptions ---
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    await _simulateNetworkDelay();
    print('API: Fetching subscription plans');
    return SubscriptionPlan.samplePlans;
  }

  Future<bool> subscribeToPlan(String userId, String planId) async {
    await _simulateNetworkDelay();
    print('API: User $userId subscribing to plan $planId');
    // Simulate success
    return true;
  }

  Future<SubscriptionPlan?> getCurrentUserSubscription(String userId) async {
    await _simulateNetworkDelay();
    print('API: Fetching current subscription for user $userId');
    // Simulate user having a basic plan
    if (userId == User.placeholderWorker.id) {
      return SubscriptionPlan.samplePlans.firstWhere((plan) => plan.tier == PlanTier.basic);
    }
    return null; // No active subscription or free tier
  }
}


// Helper extensions for ServiceRequest copyWith (if not part of model itself)
extension ServiceRequestCopyWith on ServiceRequest {
  ServiceRequest copyWith({
    String? id,
    String? clientId,
    String? workerId,
    String? category,
    String? description,
    String? address,
    DateTime? dateTime,
    ServiceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? estimatedCost,
    double? finalCost,
    int? clientRatingForWorker,
    String? clientReviewForWorker,
    int? workerRatingForClient,
    String? workerReviewForClient,
    User? client,
    User? worker,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      workerId: workerId ?? this.workerId,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      finalCost: finalCost ?? this.finalCost,
      clientRatingForWorker: clientRatingForWorker ?? this.clientRatingForWorker,
      clientReviewForWorker: clientReviewForWorker ?? this.clientReviewForWorker,
      workerRatingForClient: workerRatingForClient ?? this.workerRatingForClient,
      workerReviewForClient: workerReviewForClient ?? this.workerReviewForClient,
      client: client ?? this.client,
      worker: worker ?? this.worker,
    );
  }
}
