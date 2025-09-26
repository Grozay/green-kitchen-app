import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../theme/app_colors.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;
  String? _selectedGender;
  bool _isEmailLogin = false;
  bool _isPhoneLogin = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerDetails = authProvider.customerDetails;
    final user = authProvider.currentUser;

    // Initialize controllers with current data - handle null safely
    _emailController = TextEditingController(text: customerDetails?['email']?.toString() ?? user?.email ?? '');
    _firstNameController = TextEditingController(text: customerDetails?['firstName']?.toString() ?? '');
    _lastNameController = TextEditingController(text: customerDetails?['lastName']?.toString() ?? '');
    _phoneController = TextEditingController(text: customerDetails?['phone']?.toString() ?? user?.phone ?? '');
    _birthDateController = TextEditingController(text: _formatBirthDate(customerDetails?['birthDate']?.toString()));
    _selectedGender = customerDetails?['gender']?.toString();

    // Determine login type to disable fields
    _determineLoginType(customerDetails);
  }

  void _determineLoginType(Map<String, dynamic>? customerDetails) {
    if (customerDetails == null) return;

    // Check the specific login type flags from customerDetails
    _isEmailLogin = customerDetails['isEmailLogin'] == true;
    _isPhoneLogin = customerDetails['isPhoneLogin'] == true;

    // Fallback: If flags not set, determine from oauthProvider or existing data
    if (!_isEmailLogin && !_isPhoneLogin) {
      final oauthProvider = customerDetails['oauthProvider']?.toString();
      if (oauthProvider != null && oauthProvider.isNotEmpty) {
        // If OAuth provider exists, it's OAuth login
        _isEmailLogin = true; // OAuth typically uses email
      } else {
        // Check if user has email or phone as primary login
        final email = customerDetails['email']?.toString();
        final phone = customerDetails['phone']?.toString();
        if (email != null && email.isNotEmpty) {
          _isEmailLogin = true;
        }
        if (phone != null && phone.isNotEmpty) {
          _isPhoneLogin = true;
        }
      }
    }
  }

  String _formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return '';
    try {
      final date = DateTime.parse(birthDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return birthDate;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDateController.text.isNotEmpty
          ? DateTime.tryParse(_birthDateController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Prepare update data
    final updateData = <String, dynamic>{};

    // Only include fields that are not disabled and have changed
    final emailText = _emailController.text.trim();
    final firstNameText = _firstNameController.text.trim();
    final lastNameText = _lastNameController.text.trim();
    final phoneText = _phoneController.text.trim();
    final birthDateText = _birthDateController.text.trim();

    if (!_isEmailLogin && emailText.isNotEmpty) {
      updateData['email'] = emailText;
    }
    if (firstNameText.isNotEmpty) {
      updateData['firstName'] = firstNameText;
    }
    if (lastNameText.isNotEmpty) {
      updateData['lastName'] = lastNameText;
    }
    if (!_isPhoneLogin && phoneText.isNotEmpty) {
      updateData['phone'] = phoneText;
    }
    if (_selectedGender != null && _selectedGender!.isNotEmpty) {
      updateData['gender'] = _selectedGender;
    }
    if (birthDateText.isNotEmpty) {
      updateData['birthDate'] = birthDateText;
    }

    if (updateData.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to save')),
        );
      }
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await authProvider.updateProfile(updateData);

      // Hide loading
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pop(); // Close edit dialog
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage ?? 'Failed to update profile')),
          );
        }
      }
    } catch (e) {
      // Hide loading
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isEmailLogin,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.email),
                            helperText: _isEmailLogin ? 'Cannot edit email (Email login)' : null,
                            helperStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (!_isEmailLogin && (value == null || value.isEmpty)) {
                              return 'Please enter your email';
                            }
                            if (!_isEmailLogin && value != null && !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // First Name Field
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            hintText: 'Enter your first name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Last Name Field
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            hintText: 'Enter your last name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          enabled: !_isPhoneLogin,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            hintText: 'Enter your phone number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.phone),
                            helperText: _isPhoneLogin ? 'Cannot edit phone (Phone login)' : null,
                            helperStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (!_isPhoneLogin && (value == null || value.isEmpty)) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Gender Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.people),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'MALE', child: Text('Male')),
                            DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                            DropdownMenuItem(value: 'UNDEFINED', child: Text('Undefined')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Birth Date Field
                        TextFormField(
                          controller: _birthDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Birth Date',
                            hintText: 'Select your birth date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                          onTap: () => _selectDate(context),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.inputBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}