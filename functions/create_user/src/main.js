const sdk = require('node-appwrite');

module.exports = async function (context) {
  const { req, res, log, error } = context;

  log('[FN] === CREATE USER FUNCTION START ===');

  const serverClient = new sdk.Client()
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject(process.env.APPWRITE_PROJECT_ID)
    .setKey(process.env.APPWRITE_API_KEY);

  const users = new sdk.Users(serverClient);
  const databases = new sdk.Databases(serverClient);

  const accountClient = new sdk.Client()
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject(process.env.APPWRITE_PROJECT_ID);

  const databaseId = process.env.APPWRITE_DATABASE_ID;
  const usuariosCollectionId = process.env.APPWRITE_USUARIOS_COLLECTION_ID;
  const defaultPassword = process.env.DEFAULT_PASSWORD || 'Ecuador2026';

  const jwt = req.headers['x-appwrite-user-jwt'];
  log('[FN] JWT present: ' + !!jwt);
  if (jwt) {
    accountClient.setJWT(jwt);
  } else {
    accountClient.setKey(process.env.APPWRITE_API_KEY);
    log('[FN] WARN: No JWT, using API key fallback');
  }

  const account = new sdk.Account(accountClient);

  let caller;
  try {
    caller = await account.get();
    log('[FN] Caller ID: ' + caller.$id);
  } catch (e) {
    log('[FN] ERROR obteniendo caller: ' + e.message);
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
    log('[FN] Caller role: ' + callerRole);
  } catch (e) {
    log('[FN] ERROR obteniendo rol del caller: ' + e.message);
    return res.json({ ok: false, message: 'Caller no encontrado en usuarios' }, 403);
  }

  let payload;
  try {
    payload = JSON.parse(req.body);
    log('[FN] Body parsed OK');
  } catch (e) {
    log('[FN] ERROR parsing body: ' + e.message);
    return res.json({ ok: false, message: 'Body invalido: debe ser JSON' }, 400);
  }

  const { cedula, nombres, apellidos, telefono, correo, rol, recintoId } = payload;

  log(`[FN] Payload: cedula=${cedula} correo=${correo} rol=${rol} recintoId=${recintoId || 'N/A'}`);

  if (!cedula || !nombres || !apellidos || !telefono || !correo || !rol) {
    log('[FN] ERROR: Faltan campos obligatorios');
    return res.json({ ok: false, message: 'Faltan campos obligatorios' }, 400);
  }

  log(`[FN] Role check: caller=${callerRole} requested=${rol}`);

  if (rol === 'coordinador_recinto' && callerRole !== 'coordinador_provincial') {
    log('[FN] ERROR: Caller no autorizado para crear coordinador_recinto');
    return res.json({ ok: false, message: 'Solo coordinador provincial puede crear coordinadores de recinto' }, 403);
  }
  if (rol === 'veedor' && callerRole !== 'coordinador_recinto') {
    log('[FN] ERROR: Caller no autorizado para crear veedor');
    return res.json({ ok: false, message: 'Solo coordinador de recinto puede crear veedores' }, 403);
  }

  log('[FN] Role validation passed, calling users.create()...');

  let newUser;
  try {
    newUser = await users.create(
      sdk.ID.unique(),
      correo,
      undefined,
      defaultPassword,
      `${nombres} ${apellidos}`
    );
    log('[FN] Auth user created: ' + newUser.$id);
  } catch (e) {
    log('[FN] ERROR in users.create: ' + e.message);
    log('[FN] Stack: ' + (e.stack || ''));
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
    password_changed: false,
    email_verified: false,
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

  log('[FN] Calling databases.createDocument()...');

  let userDoc;
  try {
    userDoc = await databases.createDocument(
      databaseId,
      usuariosCollectionId,
      userId,
      documentData,
      docPermissions
    );
    log('[FN] Document created: ' + userDoc.$id);
  } catch (e) {
    log('[FN] ERROR in createDocument: ' + e.message);
    log('[FN] Stack: ' + (e.stack || ''));
    try {
      await users.delete(userId);
      log('[FN] Rollback: deleted auth user ' + userId);
    } catch (_) {}
    return res.json({ ok: false, message: 'Error al crear documento: ' + e.message }, 500);
  }

  try {
    await users.createVerification(userId);
    log('[FN] Verification email sent');
  } catch (_) {
    log('[FN] Warning: no se pudo enviar verificacion');
  }

  log('[FN] === SUCCESS === userId=' + userId);
  return res.json({
    ok: true,
    userId: userId,
    document: userDoc,
  });
};
