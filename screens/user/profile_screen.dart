import 'package:flutter/material.dart';
import '../../models/Drawer.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _showChangePassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      _nameController.text = user.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = _authService.currentUser;
        if (user == null) {
          throw Exception('Usuário não encontrado');
        }

        // Atualizar nome
        await _databaseService.updateUser(
          user.id,
          {'name': _nameController.text},
        );

        // Atualizar senha se necessário
        if (_showChangePassword &&
            _newPasswordController.text.isNotEmpty &&
            _currentPasswordController.text.isNotEmpty) {
          await _authService.updatePassword(
            user.id,
            _currentPasswordController.text,
            _newPasswordController.text,
          );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _showChangePassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 50,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: TextStyle(fontSize: 40),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Email: ${user.email}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              CheckboxListTile(
                title: Text('Alterar senha'),
                value: _showChangePassword,
                onChanged: (value) {
                  setState(() => _showChangePassword = value ?? false);
                },
              ),
              if (_showChangePassword) ...[
                SizedBox(height: 16),
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Senha atual',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_showChangePassword) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha atual';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nova senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_showChangePassword) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a nova senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nova senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_showChangePassword) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme a nova senha';
                      }
                      if (value != _newPasswordController.text) {
                        return 'As senhas não conferem';
                      }
                    }
                    return null;
                  },
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Salvar Alterações',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _authService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: Text('Sair da conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}