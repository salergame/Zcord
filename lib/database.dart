import 'package:postgres/postgres.dart';

class Database {
  final PostgreSQLConnection connection;

  Database()
      : connection = PostgreSQLConnection(
          'localhost', 
          5432,   
          'Zcord', // Имя вашей базы данных
          username: 'Zcord_user', // Ваше имя пользователя
          password: '1234567', // Ваш пароль
        );

  Future<void> open() async {
    await connection.open();
    ('Подключение к базе данных установлено!');
  }

  Future<void> close() async {
    await connection.close();
    ('Подключение к базе данных закрыто!');
  }

  // Добавьте дополнительные методы для выполнения запросов
  Future<List<Map<String, Map<String, dynamic>>>> query(String sql) async {
    return await connection.mappedResultsQuery(sql);
  }
}
