import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late String _name;
  bool _editingName = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _name = user?.displayName ?? 'Your Name';
    _nameController.text = _name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _editName() async {
    setState(() => _editingName = true);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Edit Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _name = _nameController.text.trim();
                    _editingName = false;
                  });
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && _name.isNotEmpty) {
                    await user.updateDisplayName(_name);
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
    setState(() => _editingName = false);
  }

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF3B30),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      try {
        await ref.read(authRepositoryProvider).signOut();
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'your@email.com';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child:
                      user?.photoURL != null
                          ? ClipOval(
                            child: Image.network(
                              user!.photoURL!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Icon(
                                    Icons.person,
                                    color: Colors.grey[400],
                                    size: 50,
                                  ),
                            ),
                          )
                          : Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 50,
                          ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _editName,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7C9F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Color(0xFF2166E3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(color: Color(0xFF6E6E6E), fontSize: 16),
            ),
            const SizedBox(height: 32),
            _ProfileOption(
              icon: Icons.help_outline_rounded,
              label: 'Help Center',
              onTap: () {},
            ),
            _ProfileOption(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () {},
            ),
            _ProfileOption(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              iconColor: const Color(0xFFFF3B30),
              textColor: const Color(0xFFFF3B30),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF2166E3),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor ?? const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
