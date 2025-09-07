// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:contacts_service/contacts_service.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Contacts App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: ContactsScreen(),
//     );
//   }
// }

// class ContactsScreen extends StatefulWidget {
//   @override
//   _ContactsScreenState createState() => _ContactsScreenState();
// }

// class _ContactsScreenState extends State<ContactsScreen> {
//   List<Contact> contacts = [];
//   bool isLoading = true;
//   bool permissionGranted = false;
//   bool permissionDenied = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionStatus();
//   }

//   Future<void> _checkPermissionStatus() async {
//     // Check current permission status
//     PermissionStatus status = await Permission.contacts.status;

//     setState(() {
//       if (status == PermissionStatus.granted) {
//         permissionGranted = true;
//         permissionDenied = false;
//         _loadContacts();
//       } else if (status == PermissionStatus.denied ||
//           status == PermissionStatus.restricted ||
//           status == PermissionStatus.permanentlyDenied) {
//         permissionGranted = false;
//         permissionDenied = true;
//         isLoading = false;
//       } else {
//         // If status is undetermined, request permission
//         _requestPermissionAndLoadContacts();
//       }
//     });
//   }

//   Future<void> _requestPermissionAndLoadContacts() async {
//     // Request contacts permission
//     PermissionStatus permission = await Permission.contacts.request();

//     setState(() {
//       if (permission == PermissionStatus.granted) {
//         permissionGranted = true;
//         permissionDenied = false;
//         _loadContacts();
//       } else {
//         isLoading = false;
//         permissionGranted = false;
//         permissionDenied = true;
//         _showPermissionDialog();
//       }
//     });
//   }

//   Future<void> _loadContacts() async {
//     try {
//       Iterable<Contact> contactsList = await ContactsService.getContacts();
//       setState(() {
//         contacts = contactsList.toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error loading contacts: $e')));
//     }
//   }

//   void _showPermissionDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Permission Required'),
//           content: Text(
//             'This app needs access to your contacts to display them. '
//             'Please grant contacts permission in the app settings.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 openAppSettings();
//               },
//               child: Text('Open Settings'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showContactBottomSheet(Contact contact) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return ContactBottomSheet(contact: contact);
//       },
//     );
//   }

//   void _showUserProfileBottomSheet() {
//     // Create a mock user profile - in a real app, you'd get this from user preferences/database
//     Contact userProfile = Contact(
//       displayName: 'My Profile',
//       phones: [Item(label: 'mobile', value: '+1234567890')],
//       emails: [Item(label: 'personal', value: 'user@example.com')],
//     );

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return ContactBottomSheet(contact: userProfile, isUserProfile: true);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Contacts'),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.account_circle),
//             onPressed: _showUserProfileBottomSheet,
//             tooltip: 'My Profile',
//           ),
//         ],
//       ),
//       body: _buildBody(),
//     );
//   }

//   Widget _buildBody() {
//     if (isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading contacts...'),
//           ],
//         ),
//       );
//     }

//     if (!permissionGranted) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.contacts, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               permissionDenied
//                   ? 'Contacts Access Denied'
//                   : 'Contacts Access Required',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 permissionDenied
//                     ? 'You have denied contacts permission. Please grant access in app settings to view your contacts.'
//                     : 'To view your contacts, please grant access to contacts when prompted.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed:
//                   permissionDenied
//                       ? openAppSettings
//                       : _requestPermissionAndLoadContacts,
//               child: Text(
//                 permissionDenied ? 'Open Settings' : 'Grant Permission',
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (contacts.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.contact_phone, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text('No contacts found', style: TextStyle(fontSize: 18)),
//             SizedBox(height: 8),
//             ElevatedButton(onPressed: _loadContacts, child: Text('Retry')),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: _loadContacts,
//       child: ListView.separated(
//         itemCount: contacts.length,
//         separatorBuilder: (context, index) => Divider(height: 1),
//         itemBuilder: (context, index) {
//           Contact contact = contacts[index];
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.blue.shade100,
//               child: Text(
//                 _getInitials(contact.displayName ?? ''),
//                 style: TextStyle(
//                   color: Colors.blue.shade700,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             title: Text(
//               contact.displayName ?? 'Unknown',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             subtitle: Text(
//               _getContactSubtitle(contact),
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//             onTap: () => _showContactBottomSheet(contact),
//             trailing: Icon(Icons.chevron_right, color: Colors.grey),
//           );
//         },
//       ),
//     );
//   }

//   String _getInitials(String name) {
//     if (name.isEmpty) return '?';
//     List<String> nameParts = name.trim().split(' ');
//     if (nameParts.length >= 2) {
//       return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
//     }
//     return name[0].toUpperCase();
//   }

//   String _getContactSubtitle(Contact contact) {
//     if (contact.phones?.isNotEmpty == true) {
//       return contact.phones!.first.value ?? '';
//     } else if (contact.emails?.isNotEmpty == true) {
//       return contact.emails!.first.value ?? '';
//     }
//     return 'No phone or email';
//   }
// }

// class ContactBottomSheet extends StatelessWidget {
//   final Contact contact;
//   final bool isUserProfile;

//   const ContactBottomSheet({
//     Key? key,
//     required this.contact,
//     this.isUserProfile = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Handle bar
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           SizedBox(height: 20),

//           // Profile section
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundColor:
//                     isUserProfile
//                         ? Colors.green.shade100
//                         : Colors.blue.shade100,
//                 child: Icon(
//                   isUserProfile ? Icons.account_circle : Icons.person,
//                   size: 40,
//                   color:
//                       isUserProfile
//                           ? Colors.green.shade700
//                           : Colors.blue.shade700,
//                 ),
//               ),
//               SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       contact.displayName ?? 'Unknown',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     if (isUserProfile)
//                       Text(
//                         'Your Profile',
//                         style: TextStyle(
//                           color: Colors.green.shade600,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(height: 32),

//           // Contact details
//           _buildContactInfo(context),

//           SizedBox(height: 32),

//           // Close button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text('Close'),
//             ),
//           ),

//           // Add bottom padding for safe area
//           SizedBox(height: MediaQuery.of(context).padding.bottom),
//         ],
//       ),
//     );
//   }

//   Widget _buildContactInfo(BuildContext context) {
//     List<Widget> infoWidgets = [];

//     // Phone numbers
//     if (contact.phones?.isNotEmpty == true) {
//       infoWidgets.add(_buildSectionTitle('Phone Numbers'));
//       for (Item phone in contact.phones!) {
//         if (phone.value?.isNotEmpty == true) {
//           infoWidgets.add(
//             _buildInfoTile(Icons.phone, phone.value!, phone.label ?? 'Phone'),
//           );
//         }
//       }
//       infoWidgets.add(SizedBox(height: 16));
//     }

//     // Email addresses
//     if (contact.emails?.isNotEmpty == true) {
//       infoWidgets.add(_buildSectionTitle('Email Addresses'));
//       for (Item email in contact.emails!) {
//         if (email.value?.isNotEmpty == true) {
//           infoWidgets.add(
//             _buildInfoTile(Icons.email, email.value!, email.label ?? 'Email'),
//           );
//         }
//       }
//     }

//     if (infoWidgets.isEmpty) {
//       return Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             Icon(Icons.info_outline, color: Colors.grey.shade600),
//             SizedBox(width: 12),
//             Text(
//               'No contact information available',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: infoWidgets,
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Colors.grey.shade700,
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoTile(IconData icon, String value, String label) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.blue.shade600, size: 20),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   value,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//                 Text(
//                   label.toLowerCase(),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
