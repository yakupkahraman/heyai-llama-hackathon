import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:heylex/core/components/glass_effect_container.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/auth/providers/user_provider.dart';
import 'package:heylex/features/home/components/settings_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name');
      _userEmail = prefs.getString('email');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        title: Text("Profil", style: TextStyle(fontFamily: "OpenDyslexic")),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              GlassEffectContainer(
                child: ListTile(
                  contentPadding: EdgeInsets.only(
                    left: 16,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  leading: _isLoading
                      ? CircleAvatar()
                      : CircleAvatar(
                          child: Text(
                            _userName?.isNotEmpty == true
                                ? _userName![0].toUpperCase()
                                : _userEmail?.isNotEmpty == true
                                ? _userEmail![0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontFamily: "OpenDyslexic",
                              color: ThemeConstants.creamColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  title: _isLoading
                      ? Text("Yükleniyor...")
                      : Text(_userName ?? "Kullanıcı adı yok"),
                  subtitle: _isLoading
                      ? Text("")
                      : Text(_userEmail ?? "Email yok"),
                ),
              ),
              SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: GlassEffectContainer(
                  child: Column(
                    children: [
                      SettingsListTile(
                        title: "Planım",
                        leadingIcon: Icons.wallet,
                        onTap: () {
                          context.push('/my-plans');
                        },
                      ),
                      SettingsListTile(
                        title: "Çıkış",
                        leadingIcon: Icons.logout,
                        onTap: () async {
                          final userProvider = Provider.of<UserProvider>(
                            context,
                            listen: false,
                          );
                          await userProvider.logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
