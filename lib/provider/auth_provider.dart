import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/phone_auth_service.dart';
import '../services/service.dart';
import '../apis/endpoint.dart';

// AuthProvider manages authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final ApiService _apiService = ApiService();

  User? _currentUser;
  Map<String, dynamic>? _customerDetails;
  Map<String, dynamic>? _membershipInfo;
  List<Map<String, dynamic>> _orderHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get customerDetails => _customerDetails;
  Map<String, dynamic>? get membershipInfo => _membershipInfo;
  List<Map<String, dynamic>> get orderHistory => _orderHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Initialize provider
  Future<void> init() async {
    await _authService.init();
    await checkAuthStatus();
  }

  // Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _clearError();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      _setError('Failed to check authentication status');
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);

      if (response.success) {
        _currentUser = response.user;
        // Fetch customer details from backend
        await _fetchCustomerDetails(email);
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register user
  Future<bool> register(String email, String password, {String? firstName, String? lastName}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(email, password, firstName: firstName, lastName: lastName);

      if (response.success) {
        // Don't set currentUser yet - wait for email verification
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register user with mobile (OTP)
  Future<bool> mobileRegister(String email, String password, {String? firstName, String? lastName}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.mobileRegister(email, password, firstName: firstName, lastName: lastName);

      if (response.success) {
        // Don't set currentUser yet - wait for OTP verification
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Mobile registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In
  Future<bool> googleSignIn() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.googleSignIn();

      if (response.success) {
        _currentUser = response.user;
        // Fetch customer details from backend if user has email
        if (_currentUser?.email != null && _currentUser!.email.isNotEmpty) {
          await _fetchCustomerDetails(_currentUser!.email);
        }
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Google sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phone authentication - Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      // Set callbacks for PhoneAuthService
      _phoneAuthService.setCallbacks(
        onVerificationCompleted: () {
          _setLoading(false);
          _setError('Auto-verification completed');
        },
        onVerificationFailed: (String error) {
          _setLoading(false);
          _setError(error);
        },
        onCodeSent: () {
          _setLoading(false);
          _setError('OTP sent successfully'); // Use as success message
        },
      );

      await _phoneAuthService.sendOTP(phoneNumber);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to send OTP: ${e.toString()}');
      return false;
    }
  }

  // Phone authentication - Verify OTP
  Future<bool> verifyOTP(String smsCode) async {
    _setLoading(true);
    _clearError();

    try {
      // First verify OTP with Firebase
      final firebaseResult = await _phoneAuthService.verifyOTP(smsCode);

      if (firebaseResult['success'] == true) {
        // Get phone number from Firebase result
        final phoneNumber = firebaseResult['phoneNumber'];

        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
          _setError('Phone number not found from Firebase verification');
          return false;
        }

        // Now call our backend API to get user data and JWT token
        final response = await _authService.phoneLoginMobile(phoneNumber);

        if (response.success) {
          _currentUser = response.user;

          // Try to fetch customer details from backend using email from response
          if (_currentUser?.email != null && _currentUser!.email.isNotEmpty) {
            try {
              // Ensure token is stored before making API call
              await Future.delayed(Duration(milliseconds: 100));
              await _fetchCustomerDetails(_currentUser!.email);

              // Update current user with customer details
              if (_customerDetails != null && _customerDetails!['email'] != null) {
                _currentUser = User(
                  id: _customerDetails!['id'] ?? _currentUser!.id,
                  email: _customerDetails!['email'],
                  phone: _customerDetails!['phone'] ?? _currentUser!.phone,
                  fullName: _customerDetails!['firstName'] != null && _customerDetails!['lastName'] != null
                      ? '${_customerDetails!['firstName']} ${_customerDetails!['lastName']}'
                      : _currentUser!.fullName,
                );
              }
            } catch (e) {
              // Don't fail the entire login if customer details fetch fails
            }
          }

          notifyListeners();
          return true;
        } else {
          _setError(response.message);
          return false;
        }
      } else {
        _setError(firebaseResult['message'] ?? 'Firebase OTP verification failed');
        return false;
      }
    } catch (e) {
      _setError('OTP verification failed: ${e.toString()}');
      return false;
    } finally {
      // Only set loading to false after a short delay to allow navigation to complete
      Future.delayed(const Duration(milliseconds: 200), () {
        _setLoading(false);
      });
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();
      await _phoneAuthService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed');
    } finally {
      _setLoading(false);
    }
  }

  // Update customer profile
  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    _setLoading(true);
    _clearError();

    try {
      if (_customerDetails == null) {
        _setError('Customer details not available');
        return false;
      }

      // Ensure email is included in the update data for backend to find the customer
      if (_customerDetails!['email'] != null && !updateData.containsKey('email')) {
        updateData['email'] = _customerDetails!['email'];
      }

      final response = await _apiService.put(
        ApiEndpoints.updateProfile,
        body: updateData,
      );

      if (response is String && response.contains('successfully')) {
        // Update local customer details with new data
        _customerDetails = {..._customerDetails!, ...updateData};
        
        // Update current user if name fields are updated
        if (updateData.containsKey('firstName') || updateData.containsKey('lastName')) {
          final firstName = updateData['firstName'] ?? _customerDetails!['firstName'] ?? '';
          final lastName = updateData['lastName'] ?? _customerDetails!['lastName'] ?? '';
          final fullName = '$firstName $lastName'.trim();
          
          if (_currentUser != null) {
            _currentUser = User(
              id: _currentUser!.id,
              email: updateData['email'] ?? _currentUser!.email,
              phone: updateData['phone'] ?? _currentUser!.phone,
              fullName: fullName.isNotEmpty ? fullName : _currentUser!.fullName,
            );
          }
        }

        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      if (e is ApiError) {
        _setError(e.message);
      } else {
        _setError('Failed to update profile: ${e.toString()}');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change user password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      if (_customerDetails == null || _customerDetails!['email'] == null) {
        _setError('User information not available');
        return false;
      }

      final email = _customerDetails!['email'];
      final requestData = {
        'email': email,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      final response = await _apiService.put(
        ApiEndpoints.changePassword,
        body: requestData,
      );

      if (response is String && response.contains('successfully')) {
        notifyListeners();
        return true;
      } else {
        _setError('Failed to change password');
        return false;
      }
    } catch (e) {
      if (e is ApiError) {
        _setError(e.message);
      } else {
        _setError('Failed to change password: ${e.toString()}');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load user data on app start
  Future<void> loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        // Fetch customer details if user has email
        if (_currentUser?.email != null && _currentUser!.email.isNotEmpty) {
          await _fetchCustomerDetails(_currentUser!.email);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh customer details (call this when entering profile screen)
  Future<void> refreshCustomerDetails() async {
    if (_currentUser?.email != null && _currentUser!.email.isNotEmpty) {
      await _fetchCustomerDetails(_currentUser!.email);
      notifyListeners();
    } else {
      print('⚠️ Cannot refresh customer details: no email available');
    }
  }

  // Fetch customer details from backend
  Future<void> _fetchCustomerDetails(String email) async {
    try {

      // Call actual API to get customer details
      final customerResponse = await _apiService.get(ApiEndpoints.getProfile(email));

      if (customerResponse is Map<String, dynamic>) {
        // Store the actual customer data from API
        _customerDetails = customerResponse;

        // Extract membership info if available
        _membershipInfo = {
          'level': customerResponse['membershipLevel'] ?? 'Bronze',
          'points': customerResponse['loyaltyPoints'] ?? 0,
          'benefits': [
            'Earn points on every order',
            'Exclusive promotions and discounts',
            'Priority customer support',
            'Free delivery on orders over \$50',
            'Birthday special offers'
          ]
        };

        // For now, keep mock order history until we have real order API
        _orderHistory = [
          {
            'id': 'ORD-001',
            'date': '2024-01-15',
            'status': 'Delivered',
            'total': 45.99,
            'items': ['Grilled Chicken Salad', 'Protein Shake']
          },
          {
            'id': 'ORD-002',
            'date': '2024-01-10',
            'status': 'Delivered',
            'total': 32.50,
            'items': ['Salmon Bowl', 'Green Smoothie']
          }
        ];
      } else {
        print('❌ Customer response is not a Map: $customerResponse');
        // Fallback to mock data
        _customerDetails = {
          'id': 'CUST-${email.hashCode}',
          'email': email,
          'membershipLevel': 'Bronze',
          'loyaltyPoints': 150,
          'createdAt': '2024-01-01',
          'status': 'Active'
        };

        _membershipInfo = {
          'level': 'Bronze',
          'points': 150,
          'benefits': [
            'Earn points on every order',
            'Exclusive promotions and discounts',
            'Priority customer support'
          ]
        };

        _orderHistory = [];
      }
    } catch (e) {
      print('❌ Error type: ${e.runtimeType}');
      if (e is ApiError) {
        print('❌ API Error message: ${e.message}');
        print('❌ API Error status code: ${e.statusCode}');
      }

      // Fallback to mock data on error
      _customerDetails = {
        'id': 'CUST-${email.hashCode}',
        'email': email,
        'membershipLevel': 'Bronze',
        'loyaltyPoints': 150,
        'createdAt': '2024-01-01',
        'status': 'Active'
      };

      _membershipInfo = {
        'level': 'Bronze',
        'points': 150,
        'benefits': [
          'Earn points on every order',
          'Exclusive promotions and discounts',
          'Priority customer support'
        ]
      };

      _orderHistory = [];
    }
  }
}