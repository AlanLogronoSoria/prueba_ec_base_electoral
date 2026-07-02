const sdk = require('node-appwrite');

module.exports = async function (context) {
  const { req, res, log, error } = context;

  const client = new sdk.Client()
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject(process.env.APPWRITE_PROJECT_ID)
    .setKey(process.env.APPWRITE_API_KEY);

  const users = new sdk.Users(client);
  const databases = new sdk.Databases(client);

  const databaseId = process.env.APPWRITE_DATABASE_ID;
  const usuariosCollectionId = process.env.APPWRITE_USUARIOS_COLLECTION_ID;
  const defaultPassword = process.env.DEFAULT_PASSWORD || 'Ecuador2026';

  const jwt = req.headers['x-appwrite-user-jwt'];
  if (!jwt) {
    return res.json({ ok: false, message: 'No autorizado: JWT requerido' }, 401);
  }

  client.setJWT(jwt);
  const account = new sdk.Account(client);

  let caller;
  try {
    caller = await account.get();
  } catch (e) {
    log('Error obteniendo caller: ' + e.message);
    return res.json({ ok: false, message: 'Sesion invalida' }, 401);
  }

  const callerId = caller.$id;

  let callerRole;
  try {
    const callerDoc = await databases.getDocument(
      databaseId,
      usuariosCollectionId,
      callerId
    );
    callerRole = callerDoc.rol;
  } catch (e) {
    log('Error obteniendo rol del caller: ' + e.message);
    return res.json({ ok: false, message: 'Caller no encontrado en usuarios' }, 403);
  }

  let payload;
  try {
    payload = JSON.parse(req.body);
  } catch (e) {
    return res.json({ ok: false, message: 'Body invalido: debe ser JSON' }, 400);
  }

  const { cedula, nombres, apellidos, telefono, correo, rol, recintoId } = payload;

  if (!cedula || !nombres || !apellidos || !telefono || !correo || !rol) {
    return res.json({ ok: false, message: 'Faltan campos obligatorios' }, 400);
  }

  if (rol === 'coordinador_recinto' && callerRole !== 'coordinador_provincial') {
    return res.json({ ok: false, message: 'Solo coordinador provincial puede crear coordinadores de recinto' }, 403);
  }
  if (rol === 'veedor' && callerRole !== 'coordinador_recinto') {
    return res.json({ ok: false, message: 'Solo coordinador de recinto puede crear veedores' }, 403);
  }

  let newUser;
  try {
    newUser = await users.create(
      sdk.ID.unique(),
      correo,
      undefined,
      defaultPassword,
      `${nombres} ${apellidos}`
    );
    log(`Usuario Auth creado: ${newUser.$id}`);
  } catch (e) {
    log('Error creando Auth user: ' + e.message);
    return res.json({ ok: false, message: e.message }, 500);
  }

  const userId = newUser.$id;
  const documentData = {
    cedula,
    nombres,
    apellidos,
    telefono,
    correo,
    rol,
    primer_login: true,
    creado_por: callerId,
  };
  if (recintoId) {
    documentData.recinto_id = recintoId;
  }

  const docPermissions = [
    sdk.Permission.read(sdk.Role.user(userId)),
    sdk.Permission.update(sdk.Role.user(userId)),
    sdk.Permission.read(sdk.Role.user(callerId)),
    sdk.Permission.update(sdk.Role.user(callerId)),
  ];

  let userDoc;
  try {
    userDoc = await databases.createDocument(
      databaseId,
      usuariosCollectionId,
      userId,
      documentData,
      docPermissions
    );
    log(`Documento usuarios creado: ${userDoc.$id}`);
  } catch (e) {
    log('Error creando documento: ' + e.message);
    try {
      await users.delete(userId);
    } catch (_) {}
    return res.json({ ok: false, message: 'Error al crear documento: ' + e.message }, 500);
  }

  try {
    await users.createVerification(userId);
  } catch (_) {
    log('Aviso: no se pudo enviar verificacion de email');
  }

  return res.json({
    ok: true,
    userId: userId,
    document: userDoc,
  });
};
