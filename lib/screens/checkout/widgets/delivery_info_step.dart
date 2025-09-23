import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../provider/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../services/location_service.dart';
import '../../../services/here_maps_service.dart';
import 'store_selector.dart';
import 'delivery_time_selector.dart';

class DeliveryInfoStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onFormDataChanged;
  final VoidCallback onNext;

  const DeliveryInfoStep({
    super.key,
    required this.formData,
    required this.onFormDataChanged,
    required this.onNext,
  });

  @override
  State<DeliveryInfoStep> createState() => _DeliveryInfoStepState();
}

class _DeliveryInfoStepState extends State<DeliveryInfoStep> {
  final _formKey = GlobalKey<FormState>();

  // Contact Information
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  // Delivery Address
  late final TextEditingController _addressController;
  late final TextEditingController _noteController;

  // Location data
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _wards = [];
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;

  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedWardId;
  String? _selectedWardName;

  // Address verification status
  String? _addressVerificationMessage;
  bool _isAddressVerified = false;

  // Address suggestions
  List<Map<String, dynamic>> _addressSuggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;

  // Scroll controller to prevent auto-scroll when time picker opens
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _fullNameController = TextEditingController(text: widget.formData['fullName'] ?? '');
    _emailController = TextEditingController(text: widget.formData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.formData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.formData['address'] ?? '');
    _noteController = TextEditingController(text: widget.formData['note'] ?? '');

    // Add listener to address controller to get coordinates when address changes
    _addressController.addListener(_onAddressChanged);

    // Initialize selected values from form data
    _selectedDistrictId = widget.formData['districtId'];
    _selectedDistrictName = widget.formData['district'];
    _selectedWardId = widget.formData['wardId'];
    _selectedWardName = widget.formData['ward'];

    // Load districts on init
    _loadDistricts();

    // Pre-fill user information from customer details if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      final customerDetails = authProvider.customerDetails;

      // Priority: customerDetails > currentUser
      if (customerDetails != null) {
        // Load from customer details (preferred)
        if (_fullNameController.text.isEmpty) {
          final firstName = customerDetails['firstName'] ?? '';
          final lastName = customerDetails['lastName'] ?? '';
          _fullNameController.text = '$firstName $lastName'.trim();
        }
        if (_emailController.text.isEmpty) {
          _emailController.text = customerDetails['email'] ?? '';
        }
        if (_phoneController.text.isEmpty) {
          _phoneController.text = customerDetails['phone'] ?? '';
        }

        // Load default address if available
        if (_addressController.text.isEmpty && customerDetails['defaultAddress'] != null) {
          final defaultAddress = customerDetails['defaultAddress'];
          if (defaultAddress is Map<String, dynamic>) {
            _addressController.text = defaultAddress['street'] ?? '';
            // Set district and ward from default address
            if (defaultAddress['district'] != null) {
              _selectedDistrictName = defaultAddress['district'];
            }
            if (defaultAddress['ward'] != null) {
              _selectedWardName = defaultAddress['ward'];
            }
          }
        }

        // Load customer coupons if available
        if (customerDetails['coupons'] != null) {
          widget.onFormDataChanged('customerCoupons', customerDetails['coupons']);
        }
      } else if (user != null && _fullNameController.text.isEmpty) {
        // Fallback to current user if no customer details
        _fullNameController.text = user.fullName ?? '';
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _addressController.removeListener(_onAddressChanged);
    _debounceTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onAddressChanged() {
    _updateFormData();
    // Reset verification status when address changes
    setState(() {
      _addressVerificationMessage = null;
      _isAddressVerified = false;
    });
  }

  void _onAddressTextChanged(String value) {
    _onAddressChanged(); // Call the existing method for form updates
    
    final query = value.trim();
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Clear suggestions if query is too short
    if (query.length < 3) {
      setState(() {
        _addressSuggestions = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    // Start new timer for debounced API call
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadAddressSuggestions(query);
    });
  }

  Future<void> _loadAddressSuggestions(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final suggestions = await HereMapsService.getAddressSuggestions(
        query,
        ward: _selectedWardName,
        district: _selectedDistrictName,
        city: 'TP. Hồ Chí Minh'
      );

      if (mounted) {
        setState(() {
          _addressSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addressSuggestions = [];
          _isLoadingSuggestions = false;
        });
      }
      debugPrint('Error loading address suggestions: $e');
    }
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) {
    // Update address field
    _addressController.text = suggestion['street'] ?? '';

    // Get coordinates directly from suggestion (HERE Maps provides them)
    final latitude = suggestion['lat'];
    final longitude = suggestion['lng'];

    if (latitude != null && longitude != null) {
      // Update form data with coordinates (ensure they are double)
      widget.onFormDataChanged('latitude', (latitude as num).toDouble());
      widget.onFormDataChanged('longitude', (longitude as num).toDouble());

      // Mark address as verified since we have coordinates
      setState(() {
        _isAddressVerified = true;
        _addressVerificationMessage = 'Address verified';
      });

      // No snackbar needed - verification message shows in UI
    }

    // Update district and ward if available
    final suggestionDistrict = suggestion['district'];

    if (suggestionDistrict != null && suggestionDistrict.isNotEmpty) {
      // Try to find matching district in our list
      try {
        final matchingDistrict = _districts.firstWhere(
          (district) => district['name'].toString().toLowerCase().contains(suggestionDistrict.toLowerCase()) ||
                       suggestionDistrict.toLowerCase().contains(district['name'].toString().toLowerCase()),
        );

        setState(() {
          _selectedDistrictId = matchingDistrict['code'].toString();
          _selectedDistrictName = matchingDistrict['name'];
          _selectedWardId = null;
          _selectedWardName = null;
          _wards = [];
        });
        _loadWards(matchingDistrict['code'].toString());
      } catch (e) {
        // District not found in our list, keep current selection
      }
    }

    // Clear suggestions
    setState(() {
      _addressSuggestions = [];
    });

    _updateFormData();
  }

  Future<void> _loadDistricts() async {
    setState(() {
      _isLoadingDistricts = true;
    });

    try {
      final districts = await LocationService.getDistricts();
      if (mounted) {
        setState(() {
          _districts = districts.isNotEmpty ? districts : _getFallbackDistricts();
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _districts = _getFallbackDistricts();
          _isLoadingDistricts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load districts list: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFallbackDistricts() {
    return [
      {'code': 760, 'name': 'Quận 1'},
      {'code': 761, 'name': 'Quận 2'},
      {'code': 762, 'name': 'Quận 3'}
    ];
  }

  Future<void> _loadWards(String districtId) async {
    setState(() {
      _isLoadingWards = true;
      _wards = [];
      _selectedWardId = null;
      _selectedWardName = null;
    });

    try {
      final wards = await LocationService.getWards(districtId);
      if (mounted) {
        setState(() {
          _wards = wards.isNotEmpty ? wards : _getFallbackWards(districtId);
          _isLoadingWards = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _wards = _getFallbackWards(districtId);
          _isLoadingWards = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load wards list: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFallbackWards(String districtId) {
    // Return some common wards for the selected district
    // This is a simplified fallback - in real app you might want more comprehensive data
    return [
      {'code': '${districtId}01', 'name': 'Phường 1'},
      {'code': '${districtId}02', 'name': 'Phường 2'},
      {'code': '${districtId}03', 'name': 'Phường 3'},
      {'code': '${districtId}04', 'name': 'Phường 4'},
      {'code': '${districtId}05', 'name': 'Phường 5'},
    ];
  }

  void _updateFormData() {
    widget.onFormDataChanged('fullName', _fullNameController.text);
    widget.onFormDataChanged('email', _emailController.text);
    widget.onFormDataChanged('phone', _phoneController.text);
    widget.onFormDataChanged('address', _addressController.text);
    widget.onFormDataChanged('city', 'Hồ Chí Minh');
    widget.onFormDataChanged('district', _selectedDistrictName);
    widget.onFormDataChanged('districtId', _selectedDistrictId);
    widget.onFormDataChanged('ward', _selectedWardName);
    widget.onFormDataChanged('wardId', _selectedWardId);
    widget.onFormDataChanged('note', _noteController.text);
  }

  void _calculateShippingFee(Store store) {
    // Base fee: 10,000 VND + 5,000 VND per km
    const int baseFee = 10000;
    const int feePerKm = 5000;

    final distance = (store.distance as num).toDouble();
    final shippingFee = baseFee + (distance * feePerKm).round();

    widget.onFormDataChanged('shippingFee', shippingFee);
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      _updateFormData();
      widget.onNext();
    }
  }

  // Helper function to remove Vietnamese accents
  String _removeVietnameseAccents(String text) {
    const vietnameseChars = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const englishChars = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    String result = text;
    for (int i = 0; i < vietnameseChars.length; i++) {
      result = result.replaceAll(vietnameseChars[i], englishChars[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      primary: false, // Disable primary scroll controller to prevent auto-scroll
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Information Section
            _buildSectionHeader('Contact Information'),
            const SizedBox(height: 16),
            _buildContactInformation(),

            const SizedBox(height: 24),

            // Delivery Address Section (moved up)
            _buildSectionHeader('Delivery Address'),
            const SizedBox(height: 16),
            _buildDeliveryAddress(),

            const SizedBox(height: 24),

            // Select Delivery Store Section (moved up)
            _buildSectionHeader('Select Delivery Store'),
            const SizedBox(height: 16),
            StoreSelector(
              key: ValueKey('${widget.formData['latitude']}_${widget.formData['longitude']}'),
              selectedStore: widget.formData['selectedStore'],
              userLatitude: widget.formData['latitude'],
              userLongitude: widget.formData['longitude'],
              onStoreSelected: (store) {
                widget.onFormDataChanged('selectedStore', store);
                // Calculate shipping fee when store is selected
                _calculateShippingFee(store);
              },
            ),

            const SizedBox(height: 24),

            // Delivery Time Section
            _buildSectionHeader('Delivery Time'),
            const SizedBox(height: 16),
            DeliveryTimeSelector(
              selectedDateTime: widget.formData['deliveryTime'],
              onTimeSelected: (dateTime) {
                print('DeliveryInfoStep: onTimeSelected called with: $dateTime');
                widget.onFormDataChanged('deliveryTime', dateTime);
                print('DeliveryInfoStep: formData updated, current deliveryTime: ${widget.formData['deliveryTime']}');
              },
            ),

            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _handleNext,
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildContactInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _fullNameController,
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Invalid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Invalid phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'TP. Hồ Chí Minh',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // District
          _isLoadingDistricts
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading districts...'),
                  ],
                ),
              )
            : Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final searchText = textEditingValue.text.toLowerCase();
                  final searchTextNoAccents = _removeVietnameseAccents(searchText);

                  return _districts
                      .where((district) {
                        final districtName = district['name'].toString().toLowerCase();
                        final districtNameNoAccents = _removeVietnameseAccents(districtName);

                        // Search both with and without accents
                        return districtName.contains(searchText) ||
                               districtNameNoAccents.contains(searchTextNoAccents);
                      })
                      .map((district) => district['name'].toString());
                },
                onSelected: (String selection) {
                  final selectedDistrict = _districts.firstWhere(
                    (district) => district['name'].toString() == selection,
                  );
                  setState(() {
                    _selectedDistrictId = selectedDistrict['code'].toString();
                    _selectedDistrictName = selectedDistrict['name'];
                    _selectedWardId = null;
                    _selectedWardName = null;
                    _wards = [];
                    // Reset verification status when district changes
                    _addressVerificationMessage = null;
                    _isAddressVerified = false;
                  });
                  _updateFormData();
                  _loadWards(selectedDistrict['code'].toString());
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  // Set initial value if we have a selected district
                  if (_selectedDistrictName != null && fieldTextEditingController.text.isEmpty) {
                    fieldTextEditingController.text = _selectedDistrictName!;
                  }
                  return TextFormField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      labelText: 'District',
                      hintText: _districts.isEmpty ? 'No district data available' : 'Enter district name (without accents: quan 1, tan binh...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: _districts.isEmpty ? null : const Icon(Icons.search),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a district';
                      }
                      return null;
                    },
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        width: MediaQuery.of(context).size.width - 32,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
          if (_districts.isEmpty && !_isLoadingDistricts)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: _loadDistricts,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Ward
          _isLoadingWards
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading wards...'),
                  ],
                ),
              )
            : Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty || _selectedDistrictId == null) {
                    return const Iterable<String>.empty();
                  }
                  final searchText = textEditingValue.text.toLowerCase();
                  final searchTextNoAccents = _removeVietnameseAccents(searchText);

                  return _wards
                      .where((ward) {
                        final wardName = ward['name'].toString().toLowerCase();
                        final wardNameNoAccents = _removeVietnameseAccents(wardName);

                        // Search both with and without accents
                        return wardName.contains(searchText) ||
                               wardNameNoAccents.contains(searchTextNoAccents);
                      })
                      .map((ward) => ward['name'].toString());
                },
                onSelected: (String selection) {
                  final selectedWard = _wards.firstWhere(
                    (ward) => ward['name'].toString() == selection,
                  );
                  setState(() {
                    _selectedWardId = selectedWard['code'].toString();
                    _selectedWardName = selectedWard['name'];
                    // Reset verification status when ward changes
                    _addressVerificationMessage = null;
                    _isAddressVerified = false;
                  });
                  _updateFormData();
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted) {
                  // Set initial value if we have a selected ward
                  if (_selectedWardName != null && fieldTextEditingController.text.isEmpty) {
                    fieldTextEditingController.text = _selectedWardName!;
                  }
                  return TextFormField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Ward',
                      hintText: _selectedDistrictId == null
                        ? 'Please select district first'
                        : _wards.isEmpty
                          ? 'No wards available'
                          : 'Enter ward name (without accents: phuong 1, phu tho...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: _wards.isEmpty ? null : const Icon(Icons.search),
                      filled: _selectedDistrictId == null,
                      fillColor: _selectedDistrictId == null ? Colors.grey.shade50 : null,
                    ),
                    enabled: _selectedDistrictId != null,
                    validator: (value) {
                      if (_selectedDistrictId != null && (value == null || value.isEmpty)) {
                        return 'Please select a ward';
                      }
                      return null;
                    },
                  );
                },
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        width: MediaQuery.of(context).size.width - 32,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () {
                                onSelected(option);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
          const SizedBox(height: 16),

          // Detailed Address
          CustomTextField(
            controller: _addressController,
            labelText: 'Detailed Address',
            hintText: 'Example: 123 ABC Street, Ward XYZ',
            onChanged: _onAddressTextChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter detailed address';
              }
              return null;
            },
          ),

          // Address Suggestions
          if (_isLoadingSuggestions)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Finding addresses...'),
                ],
              ),
            )
          else if (_addressSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _addressSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _addressSuggestions[index];
                  return InkWell(
                    onTap: () => _onSuggestionSelected(suggestion),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: index < _addressSuggestions.length - 1
                            ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                            : null,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion['street'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                if (suggestion['address'] != null && suggestion['address'] != suggestion['street'])
                                  Text(
                                    suggestion['address'],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // Address verification message
          if (_addressVerificationMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isAddressVerified ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isAddressVerified ? Colors.green.shade200 : Colors.red.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAddressVerified ? Icons.check_circle : Icons.error,
                    color: _isAddressVerified ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _addressVerificationMessage!,
                      style: TextStyle(
                        color: _isAddressVerified ? Colors.green.shade800 : Colors.red.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          // Notes
          CustomTextField(
            controller: _noteController,
            labelText: 'Notes (Optional)',
            hintText: 'Example: Deliver during office hours',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}