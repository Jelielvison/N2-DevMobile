import 'package:flutter/material.dart';
import '../../models/drawer.dart';
import '../../models/hobby_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class AddHobbyScreen extends StatefulWidget {
  final HobbyModel? hobby;
  const AddHobbyScreen({Key? key, this.hobby}) : super(key: key);

  @override
  State<AddHobbyScreen> createState() => _AddHobbyScreenState();
}

class _AddHobbyScreenState extends State<AddHobbyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndInitialize();
  }

  Future<void> _checkAuthAndInitialize() async {
    if (_authService.currentUser == null) {
      print('Usuário não autenticado, redirecionando para login...');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    if (widget.hobby != null) {
      _nameController.text = widget.hobby!.name;
      _descriptionController.text = widget.hobby!.description;
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHobby() async {
    if (_authService.currentUser == null) {
      print('Usuário não está logado no momento do salvamento');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não está logado. Por favor, faça login.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('Iniciando salvamento do hobby...');
      print('Usuário atual: ${_authService.currentUser?.toMap()}');

      final hobby = HobbyModel(
        id: widget.hobby?.id ?? '',
        userId: _authService.currentUser!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        registeredDate: widget.hobby?.registeredDate ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('Objeto Hobby criado: ${hobby.toMap()}');

      String hobbyId;
      if (widget.hobby != null) {
        print('Atualizando hobby existente...');
        await _databaseService.updateHobby(hobby.id, hobby.toMap());
        hobbyId = hobby.id;
      } else {
        print('Criando novo hobby...');
        hobbyId = await _databaseService.createHobby(hobby);
      }

      print('Hobby salvo com sucesso. ID: $hobbyId');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.hobby != null
              ? 'Hobby atualizado com sucesso!'
              : 'Hobby adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e, stackTrace) {
      print('Erro ao salvar hobby: $e');
      print('StackTrace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar hobby: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hobby != null ? 'Editar Hobby' : 'Novo Hobby'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Hobby',
                  hintText: 'Ex: Fotografia, Pintura, etc',
                  prefixIcon: Icon(Icons.sports_esports),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o nome do hobby';
                  }
                  if (value.trim().length < 3) {
                    return 'O nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva seu hobby...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  if (value.trim().length < 10) {
                    return 'A descrição deve ter pelo menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveHobby,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  widget.hobby != null ? 'Atualizar' : 'Adicionar',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}