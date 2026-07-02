import 'package:appwrite/appwrite.dart';

void main() async {
  final client = Client()
      .setEndpoint('http://localhost/v1')
      .setProject('control-electoral');

  final account = Account(client);
  final databases = Databases(client);

  // First login with an admin account
  try {
    await account.createEmailPasswordSession(
      email: 'admin@electoral.ec',
      password: 'Admin123!',
    );
  } catch (e) {
    print('Error al iniciar sesión: $e');
    return;
  }

  final databaseId = 'control_electoral_db';
  final collectionId = 'organizaciones_politicas';

  final organizaciones = [
    // Alcalde
    {
      'nombre': 'Movimiento Fuerza Ecuador',
      'candidato': 'Carlos Mendoza',
      'dignidad': 'alcalde',
    },
    {
      'nombre': 'Partido Social Cristiano',
      'candidato': 'María González',
      'dignidad': 'alcalde',
    },
    {
      'nombre': 'Movimiento Revolución Ciudadana',
      'candidato': 'José Paredes',
      'dignidad': 'alcalde',
    },
    {
      'nombre': 'Movimiento CREO',
      'candidato': 'Ana Castillo',
      'dignidad': 'alcalde',
    },
    {
      'nombre': 'Partido Izquierda Democrática',
      'candidato': 'Luis Torres',
      'dignidad': 'alcalde',
    },
    // Prefecto
    {
      'nombre': 'Movimiento Fuerza Ecuador',
      'candidato': 'Roberto Vega',
      'dignidad': 'prefecto',
    },
    {
      'nombre': 'Partido Social Cristiano',
      'candidato': 'Carmen Suárez',
      'dignidad': 'prefecto',
    },
    {
      'nombre': 'Movimiento Revolución Ciudadana',
      'candidato': 'Pedro Molina',
      'dignidad': 'prefecto',
    },
    {
      'nombre': 'Movimiento CREO',
      'candidato': 'Diana Ríos',
      'dignidad': 'prefecto',
    },
    {
      'nombre': 'Partido Izquierda Democrática',
      'candidato': 'Felipe Ortega',
      'dignidad': 'prefecto',
    },
  ];

  for (final org in organizaciones) {
    try {
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: org,
      );
      print('Creada: ${org['nombre']} - ${org['candidato']}');
    } catch (e) {
      print('Error al crear ${org['nombre']}: $e');
    }
  }

  print('Precarga completada.');
}
