import 'package:flutter/material.dart';
import '../../models/drawer.dart';
import '../../models/hobby_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';

class ListHobbiesScreen extends StatefulWidget {
  @override
  _ListHobbiesScreenState createState() => _ListHobbiesScreenState();
}

class _ListHobbiesScreenState extends State<ListHobbiesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  late Future<List<HobbyModel>> _hobbiesFuture;

  @override
  void initState() {
    super.initState();
    _loadHobbies();
  }

  void _loadHobbies() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _hobbiesFuture = _databaseService.getUserHobbies(user.id);
      });
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
        title: Text('Meus Hobbies'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder<List<HobbyModel>>(
        future: _hobbiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Erro ao carregar hobbies: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Erro ao carregar hobbies',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum hobby registrado',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final hobbies = snapshot.data!;
          return ListView.builder(
            itemCount: hobbies.length,
            itemBuilder: (context, index) {
              final hobby = hobbies[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                    hobby.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hobby.description),
                      SizedBox(height: 4),
                      Text(
                        'Registrado em: ${_formatDate(hobby.registeredDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/add_hobby',
                            arguments: hobby,
                          );
                          if (result == true) {
                            _loadHobbies();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, hobby),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_hobby'),
        child: Icon(Icons.add),
        tooltip: 'Adicionar Hobby',
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _showDeleteDialog(BuildContext context, HobbyModel hobby) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir "${hobby.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteHobby(hobby.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hobby excluído com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _loadHobbies();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir hobby'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}