import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../auth/login.dart';
import '../routes/navigate.dart';
import '../service/auth_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with TickerProviderStateMixin {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // User references
  DocumentReference? userDocRef;
  String profileImageUrl = '';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // User data with default values (will be updated from Firebase Auth and Firestore)
  String userName = "User"; // Default name
  String userEmail = ""; // Will be populated from Firebase Auth
  String userLocation = "Mumbai, India";
  String userProfession = "Software Developer";
  File? _profileImage;

  // UI state
  bool _isExpanded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeUserData();
    _startInitialAnimations();
  }

  Future<void> _requestGalleryPermission() async {
    setState(() => _isLoading = true);

    // For Android 11+, we need manageExternalStorage for full file access
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.request();

      if (status.isGranted) {
        await _pickImage();
        return;
      } else if (status.isDenied || status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission required to access all files.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'SETTINGS',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
        setState(() => _isLoading = false);
      }
    } else {
      // For iOS and older Android versions, use photos permission
      var status = await Permission.photos.request();

      if (status.isGranted) {
        await _pickImage();
        return;
      } else if (status.isDenied || status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission required to access photos.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'SETTINGS',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeAnimations() {
    // Fade animation for profile info
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Scale animation for profile picture
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Slide animation for buttons
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
  }

  void _startInitialAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });
  }

  void _initializeUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      // Set email from Firebase Auth
      setState(() {
        userEmail = user.email ?? '';
      });

      userDocRef = _firestore.collection('users').doc(user.uid);
      _loadUserProfile();
      _setupRealtimeListener();
    }
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      userDocRef = _firestore.collection('users').doc(user.uid);

      try {
        final doc = await userDocRef!.get();
        if (doc.exists) {
          setState(() {
            // Keep the default "User" name if no name is stored, otherwise use stored name
            userName = doc['name'] ?? userName;
            // Always use email from Firebase Auth (this ensures it's always current)
            userEmail = user.email ?? userEmail;
            userLocation = doc['location'] ?? userLocation;
            userProfession = doc['profession'] ?? doc['job'] ?? userProfession;
            profileImageUrl = doc['profileImageUrl'] ?? '';
          });
        } else {
          // Create user document if it doesn't exist
          await _createUserDocument();
        }
      } catch (e) {
        if (e.toString().contains('PERMISSION_DENIED')) {
          _showErrorSnackBar(
            'Permission denied. Please check your Firestore security rules.',
          );
        } else {
          _showErrorSnackBar('Error loading profile: $e');
        }
      }
    }
  }

  void _setupRealtimeListener() {
    final user = _auth.currentUser;
    if (user != null) {
      // Create a reference to the specific user document
      userDocRef = _firestore.collection('users').doc(user.uid);

      // Listen to changes in the user document
      userDocRef!.snapshots().listen(
        (DocumentSnapshot snapshot) {
          if (snapshot.exists && mounted) {
            setState(() {
              // Update name from Firestore but keep default if not set
              userName = snapshot['name'] ?? userName;
              // Always use email from Firebase Auth to ensure consistency
              userEmail = user.email ?? userEmail;
              userLocation = snapshot['location'] ?? userLocation;
              userProfession =
                  snapshot['profession'] ?? snapshot['job'] ?? userProfession;
              profileImageUrl = snapshot['profileImageUrl'] ?? '';
            });
          }
        },
        onError: (error) {
          // Handle permission errors gracefully
          if (error.toString().contains('PERMISSION_DENIED')) {
            _showErrorSnackBar(
              'Permission denied. Please check your Firestore security rules.',
            );
          } else {
            _showErrorSnackBar('Error listening to profile updates: $error');
          }
        },
      );
    }
  }

  Future<void> _createUserDocument() async {
    final user = _auth.currentUser;
    if (user != null && userDocRef != null) {
      try {
        await userDocRef!.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? userName,
          'name': userName, // Will be "User" by default
          'location': userLocation,
          'profession': userProfession,
          'job': userProfession,
          'profileImageUrl': profileImageUrl,
          'publicProfile': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local state to reflect the email from Firebase Auth
        setState(() {
          userEmail = user.email ?? '';
        });
      } catch (e) {
        if (e.toString().contains('PERMISSION_DENIED')) {
          _showErrorSnackBar('Permission denied. Cannot create user profile.');
        } else {
          _showErrorSnackBar('Error creating user document: $e');
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isLoading = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && userDocRef != null) {
        final user = _auth.currentUser;
        if (user != null) {
          // Create a reference with a unique file name to avoid conflicts
          final ref = _storage.ref().child(
            'profile-pictures/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          // Convert XFile to File
          final File imageFile = File(image.path);

          try {
            // Upload to Firebase Storage with error handling
            final uploadTask = ref.putFile(imageFile);

            // Wait for upload to complete and get download URL
            final TaskSnapshot snapshot = await uploadTask;
            final downloadUrl = await snapshot.ref.getDownloadURL();

            // Update Firestore with new image URL
            await userDocRef!.set({
              'profileImageUrl': downloadUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            setState(() {
              profileImageUrl = downloadUrl;
              _profileImage = imageFile;
            });

            _showSuccessSnackBar('Profile picture updated successfully');
          } catch (e) {
            // Handle specific Firebase Storage errors
            if (e.toString().contains('object does not exist') ||
                e.toString().contains('404')) {
              _showErrorSnackBar(
                'Storage bucket not configured properly. Please check Firebase Storage setup.',
              );
            } else {
              _showErrorSnackBar('Error uploading image: $e');
            }
          }
        }

        _scaleController.reset();
        _scaleController.forward();
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Try the main logout method first
      try {
        await AuthService.logout();
      } catch (e) {
        // If main logout fails due to SharedPreferences, try simple logout
        print('Main logout failed, trying simple logout: $e');
        await AuthService.logoutSimple();
      }

      // Close loading indicator
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Navigate to onboarding/login page
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', // Changed from '/OnboardingRoute' to match your routes
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: () => _performLogout(context),
            ),
          ),
        );
      }
    }
  }

  Future<void> _performSimpleLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Use simple logout that doesn't depend on SharedPreferences
      await FirebaseAuth.instance.signOut();

      // Close loading indicator
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Navigate to onboarding/login page
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/onboarding', (route) => false);
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showQuickEditNameDialog() {
    final nameController = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              hintText: 'Enter your name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate name is not empty
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await _updateUserName(nameController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserName(String name) async {
    try {
      if (userDocRef != null) {
        await userDocRef!.set({
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          userName = name;
        });

        _showSuccessSnackBar('Name updated successfully');
      }
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED')) {
        _showErrorSnackBar('Permission denied. Cannot update name.');
      } else {
        _showErrorSnackBar('Error updating name: $e');
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final locationController = TextEditingController(text: userLocation);
    final professionController = TextEditingController(text: userProfession);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your name',
                  ),
                ),
                const SizedBox(height: 16),
                // Email field (read-only)
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    hintText: userEmail,
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: professionController,
                  decoration: const InputDecoration(
                    labelText: 'Profession',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate name is not empty
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await _updateUserProfile(
                  nameController.text.trim(),
                  locationController.text.trim(),
                  professionController.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserProfile(
    String name,
    String location,
    String profession,
  ) async {
    try {
      if (userDocRef != null) {
        await userDocRef!.set({
          'name': name,
          'location': location,
          'profession': profession,
          'job': profession,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        setState(() {
          userName = name;
          userLocation = location;
          userProfession = profession;
        });

        _showSuccessSnackBar('Profile updated successfully');
      }
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED')) {
        _showErrorSnackBar('Permission denied. Cannot update profile.');
      } else {
        _showErrorSnackBar('Error updating profile: $e');
      }
    }
  }

  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (profileImageUrl.isNotEmpty) {
      return NetworkImage(profileImageUrl);
    }
    return null;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Picture Section with Hero Animation
            Hero(
              tag: 'profile-picture',
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildProfilePicture(),
              ),
            ),

            const SizedBox(height: 30),

            // Profile Information with Fade Animation
            FadeTransition(opacity: _fadeAnimation, child: _buildProfileInfo()),

            const SizedBox(height: 40),

            // Action Buttons with Slide Animation
            SlideTransition(
              position: _slideAnimation,
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _requestGalleryPermission,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue, Colors.purple],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image:
                    _getProfileImage() != null
                        ? DecorationImage(
                          image: _getProfileImage()!,
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  _getProfileImage() == null
                      ? const Icon(Icons.person, size: 80, color: Colors.grey)
                      : null,
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Camera icon overlay
          if (!_isLoading)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Email
          Row(
            children: [
              const Icon(Icons.email_outlined, color: Colors.green),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail.isNotEmpty ? userEmail : 'No email provided',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Expandable section
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isExpanded ? 'Show Less' : 'Show More',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Expandable content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? 80 : 0,
            child:
                _isExpanded
                    ? Column(
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              userLocation,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.work_outline,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              userProfession,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    )
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Edit Profile Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _showEditProfileDialog,
            icon: const Icon(Icons.edit),
            label: const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Settings Button

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }
}
