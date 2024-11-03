import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  static final AuthService _instance = AuthService._internal();

  // Construtor factory para retornar sempre a mesma instância
  factory AuthService() {
    return _instance;
  }

  // Construtor privado
  AuthService._internal();

  UserModel? get currentUser => _currentUser;

  String _hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  Future<UserModel?> register(String name, String email, String password) async {
    try {
      var userQuery = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (userQuery.docs.isNotEmpty) {
        throw Exception('Email já cadastrado');
      }

      String hashedPassword = _hashPassword(password);
      String userId = _firestore.collection('users').doc().id;

      UserModel newUser = UserModel(
        id: userId,
        name: name,
        email: email,
        password: '',
      );

      await _firestore.collection('users').doc(userId).set({
        ...newUser.toMap(),
        'password': hashedPassword,
      });

      _currentUser = newUser;
      print('Usuário registrado e logado: ${_currentUser?.toMap()}');
      return newUser;
    } catch (e) {
      print('Erro no registro: $e');
      return null;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      print('Tentando login com email: $email');
      var userQuery = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (userQuery.docs.isEmpty) {
        throw Exception('Credenciais inválidas');
      }

      UserModel user = UserModel.fromMap(userQuery.docs.first.data() as Map<String, dynamic>);
      if (!BCrypt.checkpw(password, userQuery.docs.first['password'])) {
        throw Exception('Credenciais inválidas');
      }

      _currentUser = user;
      print('Usuário logado com sucesso: ${_currentUser?.toMap()}');
      return _currentUser;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  void logout() {
    print('Logout realizado. Usuário anterior: ${_currentUser?.toMap()}');
    _currentUser = null;
  }

  Future<void> updatePassword(String userId, String currentPassword, String newPassword) async {
    try {
      var userDoc = await _firestore.collection('users').doc(userId).get();
      if (!BCrypt.checkpw(currentPassword, userDoc['password'])) {
        throw Exception('Senha atual incorreta');
      }

      String hashedNewPassword = _hashPassword(newPassword);
      await _firestore.collection('users').doc(userId).update({
        'password': hashedNewPassword,
      });
      print('Senha atualizada com sucesso para o usuário: $userId');
    } catch (e) {
      print('Erro ao atualizar senha: $e');
      throw e;
    }
  }
}