import 'package:appwrite/appwrite.dart';

const canton = 'Quito';
const parroquia = 'Centro Histórico';

const recintos = [
  {
    'nombre': 'Escuela Fiscal Simón Bolívar',
    'numero_jrv': 3,
  },
  {
    'nombre': 'Colegio Nacional Mejía',
    'numero_jrv': 5,
  },
  {
    'nombre': 'Unidad Educativa Manuela Cañizares',
    'numero_jrv': 4,
  },
  {
    'nombre': 'Escuela República de Colombia',
    'numero_jrv': 2,
  },
  {
    'nombre': 'Colegio 24 de Mayo',
    'numero_jrv': 3,
  },
  {
    'nombre': 'Unidad Educativa Montúfar',
    'numero_jrv': 4,
  },
  {
    'nombre': 'Escuela Juan Montalvo',
    'numero_jrv': 2,
  },
  {
    'nombre': 'Colegio Experimental Juan Pío Montúfar',
    'numero_jrv': 3,
  },
  {
    'nombre': 'Unidad Educativa Benalcázar',
    'numero_jrv': 5,
  },
  {
    'nombre': 'Escuela Pedro Carbo',
    'numero_jrv': 2,
  },
];

void main() async {
  final client = Client()
      .setEndpoint('http://localhost/v1')
      .setProject('control-electoral');

  final account = Account(client);
  final databases = Databases(client);

  try {
    await account.createEmailPasswordSession(
      email: 'admin@electoral.ec',
      password: 'Admin123!',
    );
  } catch (e) {
    print('Error al iniciar sesión: $e');
    print('Asegúrate de que el usuario admin exista en Auth.');
    return;
  }

  final databaseId = 'control_electoral_db';
  final collectionId = 'recintos';

  for (final recinto in recintos) {
    try {
      final doc = await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: {
          'canton': canton,
          'parroquia': parroquia,
          'nombre': recinto['nombre'],
          'numero_jrv': recinto['numero_jrv'],
        },
      );
      print('Creado: ${recinto['nombre']} (ID: ${doc.$id})');
    } catch (e) {
      print('Error al crear ${recinto['nombre']}: $e');
    }
  }

  print('Precarga de recintos completada (${recintos.length} recintos).');
}
