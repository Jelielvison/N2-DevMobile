import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hobby_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hobbies CRUD
  Future<String> createHobby(HobbyModel hobby) async {
    try {
      DocumentReference docRef = await _firestore.collection('hobbies').add(hobby.toMap());
      return docRef.id;
    } catch (e) {
      print('Erro ao criar hobby: $e');
      throw Exception('Falha ao criar hobby: $e');
    }
  }

  Future<List<HobbyModel>> getUserHobbies(String userId) async {
    try {
      print('Buscando hobbies para o usuário: $userId');
      QuerySnapshot snapshot = await _firestore
          .collection('hobbies')
          .where('userId', isEqualTo: userId)
          .get();

      print('Número de hobbies encontrados: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        return HobbyModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Erro ao buscar hobbies: $e');
      return [];
    }
  }

  Future<HobbyModel?> getHobbyById(String hobbyId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('hobbies').doc(hobbyId).get();

      if (!doc.exists) {
        return null;
      }

      return HobbyModel.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    } catch (e) {
      print('Erro ao buscar hobby: $e');
      throw Exception('Falha ao buscar hobby: $e');
    }
  }

  Future<void> updateHobby(String hobbyId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('hobbies').doc(hobbyId).update(data);
    } catch (e) {
      print('Erro ao atualizar hobby: $e');
      throw Exception('Falha ao atualizar hobby: $e');
    }
  }

  Future<void> deleteHobby(String hobbyId) async {
    try {
      await _firestore.collection('hobbies').doc(hobbyId).delete();
      print('Hobby deletado com sucesso: $hobbyId');
    } catch (e) {
      print('Erro ao deletar hobby: $e');
      throw e;
    }
  }

  // Funções relacionadas ao usuário
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Erro ao atualizar usuário: $e');
      throw Exception('Falha ao atualizar usuário: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      throw Exception('Falha ao buscar dados do usuário: $e');
    }
  }

  // Função para buscar hobbies com paginação
  Future<List<HobbyModel>> getPaginatedUserHobbies({
    required String userId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection('hobbies')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return HobbyModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      print('Erro ao buscar hobbies paginados: $e');
      return [];
    }
  }
}