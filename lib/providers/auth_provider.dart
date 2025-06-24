import 'package:flutter/foundation.dart';
import 'package:chamba_app/models/user_model.dart';
import 'package:chamba_app/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  // To expose ApiService for direct calls if needed (e.g. forgot password)
  ApiService get apiService => _apiService;


  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // _tryAutoLogin(); // Consider if auto-login is needed
  }

  Future<void> _setLoading(bool loading) async {
    // Added a small delay to ensure UI updates correctly if state changes rapidly.
    // This can prevent race conditions or janky UI updates in some cases.
    await Future.delayed(Duration.zero);
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
  }

  Future<bool> login(String email, String password) async {
    await _setLoading(true);
    _setError(null);

    try {
      final user = await _apiService.login(email, password);
      if (user != null) {
        _currentUser = user;
        // TODO: Store token/user data securely (e.g., using flutter_secure_storage)
        // await _secureStorage.write(key: 'authToken', value: user.apiToken); // Assuming User model has apiToken
        // await _secureStorage.write(key: 'userId', value: user.id);
        await _setLoading(false);
        return true;
      } else {
        _setError('Credenciales inválidas o usuario no encontrado.');
        await _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión o servidor: ${e.toString()}');
      await _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String address,
    required String phone,
    required UserType userType,
  }) async {
    await _setLoading(true);
    _setError(null);

    try {
      // Ensure User model is correctly imported and used
      User newUser = User(
        id: '', // ID will be assigned by backend
        name: name,
        email: email,
        phoneNumber: phone,
        address: address,
        userType: userType,
        // isVerified, averageRating, totalRatings will have defaults or be set by backend
      );
      final registeredUser = await _apiService.register(newUser, password);
      if (registeredUser != null) {
        // Optionally log in the user directly or prompt them to log in.
        // For now, we just indicate success.
        await _setLoading(false);
        return true;
      } else {
        _setError('No se pudo completar el registro. Intenta de nuevo.');
        await _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error durante el registro: ${e.toString()}');
      await _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _setLoading(true); // Show loading while clearing things up
    _currentUser = null;
    _setError(null);
    // TODO: Clear token/user data from secure storage
    // await _secureStorage.deleteAll();
    await _apiService.logout(); // Inform the backend if necessary
    await _setLoading(false);
  }

  // Specific method for password reset if managed through provider
  Future<bool> requestPasswordReset(String email) async {
    await _setLoading(true);
    _setError(null);
    try {
      bool success = await _apiService.requestPasswordReset(email);
      // API might always return true for security, actual email sending is backend's job.
      await _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error al solicitar reseteo: ${e.toString()}');
      await _setLoading(false);
      return false;
    }
  }


  void clearErrorMessage() {
    _setError(null);
    notifyListeners(); // Notify if only error message changes without loading state
  }

  // For direct use if user object is updated elsewhere (e.g. profile update)
  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
