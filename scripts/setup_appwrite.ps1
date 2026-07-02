# Script de configuración para Appwrite - Control Electoral 2026
# Requisito: Tener instalado Appwrite CLI (npm i -g appwrite-cli)
# Ejecutar: appwrite login primero

param(
    [string]$DatabaseId = "control_electoral_db"
)

Write-Host "=== Configurando base de datos: $DatabaseId ===" -ForegroundColor Cyan

# 1. Crear la base de datos
Write-Host "`nCreando base de datos..." -ForegroundColor Yellow
appwrite databases create --databaseId $DatabaseId --name "Base de Datos Control Electoral"

# 2. Crear colección: usuarios
Write-Host "`nCreando colección: usuarios..." -ForegroundColor Yellow
appwrite databases createCollection --databaseId $DatabaseId --collectionId "usuarios" --name "Usuarios" --permission document --read "users" --write "users"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "cedula" --size 10 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "nombres" --size 100 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "apellidos" --size 100 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "telefono" --size 20 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "correo" --size 100 --required true --xdefault ""
appwrite databases createEnumAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "rol" --elements "coordinador_provincial","coordinador_recinto","veedor" --required true --xdefault "veedor"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "recinto_id" --size 50 --required false
appwrite databases createBooleanAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "primer_login" --required true --xdefault true
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "usuarios" --key "auth_user_id" --size 50 --required false
appwrite databases createIndex --databaseId $DatabaseId --collectionId "usuarios" --key "idx_cedula" --type key --attributes "cedula" --orders "ASC"

# 3. Crear colección: recintos
Write-Host "`nCreando colección: recintos..." -ForegroundColor Yellow
appwrite databases createCollection --databaseId $DatabaseId --collectionId "recintos" --name "Recintos" --permission document --read "users" --write "users"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "recintos" --key "canton" --size 100 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "recintos" --key "parroquia" --size 100 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "recintos" --key "nombre_recinto" --size 200 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "recintos" --key "numero_jrv" --size 20 --required false
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "recintos" --key "coordinador_id" --size 50 --required false

# 4. Crear colección: mesas
Write-Host "`nCreando colección: mesas..." -ForegroundColor Yellow
appwrite databases createCollection --databaseId $DatabaseId --collectionId "mesas" --name "Mesas" --permission document --read "users" --write "users"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "mesas" --key "recinto_id" --size 50 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "mesas" --key "numero_jrv" --size 20 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "mesas" --key "veedor_id" --size 50 --required false

# 5. Crear colección: organizaciones_politicas
Write-Host "`nCreando colección: organizaciones_politicas..." -ForegroundColor Yellow
appwrite databases createCollection --databaseId $DatabaseId --collectionId "organizaciones_politicas" --name "Organizaciones Politicas" --permission document --read "users" --write "users"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "organizaciones_politicas" --key "nombre" --size 200 --required true --xdefault ""
appwrite databases createEnumAttribute --databaseId $DatabaseId --collectionId "organizaciones_politicas" --key "dignidad" --elements "alcalde","prefecto" --required true --xdefault "alcalde"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "organizaciones_politicas" --key "candidato" --size 200 --required true --xdefault ""

# 6. Crear colección: actas
Write-Host "`nCreando colección: actas..." -ForegroundColor Yellow
appwrite databases createCollection --databaseId $DatabaseId --collectionId "actas" --name "Actas" --permission document --read "users" --write "users"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "actas" --key "mesa_id" --size 50 --required true --xdefault ""
appwrite databases createEnumAttribute --databaseId $DatabaseId --collectionId "actas" --key "dignidad" --elements "alcalde","prefecto" --required true --xdefault "alcalde"
appwrite databases createIntegerAttribute --databaseId $DatabaseId --collectionId "actas" --key "total_sufragantes" --required true --xdefault 0
appwrite databases createIntegerAttribute --databaseId $DatabaseId --collectionId "actas" --key "votos_nulos" --required true --xdefault 0
appwrite databases createIntegerAttribute --databaseId $DatabaseId --collectionId "actas" --key "votos_blancos" --required true --xdefault 0
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "actas" --key "foto_url" --size 500 --required false
appwrite databases createFloatAttribute --databaseId $DatabaseId --collectionId "actas" --key "gps_lat" --required false
appwrite databases createFloatAttribute --databaseId $DatabaseId --collectionId "actas" --key "gps_lng" --required false
appwrite databases createEnumAttribute --databaseId $DatabaseId --collectionId "actas" --key "estado" --elements "pendiente","registrada" --required true --xdefault "pendiente"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "actas" --key "created_by" --size 50 --required true --xdefault ""
appwrite databases createDatetimeAttribute --databaseId $DatabaseId --collectionId "actas" --key "updated_at" --required false

# 7. Crear colección: votos_por_organizacion
Write-Host "`nCreando colección: votos_por_organizacion..." -ForegroundColor Yellow
appwrite databases createCollection --databaseId $DatabaseId --collectionId "votos_por_organizacion" --name "Votos por Organizacion" --permission document --read "users" --write "users"
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "votos_por_organizacion" --key "acta_id" --size 50 --required true --xdefault ""
appwrite databases createStringAttribute --databaseId $DatabaseId --collectionId "votos_por_organizacion" --key "organizacion_id" --size 50 --required true --xdefault ""
appwrite databases createIntegerAttribute --databaseId $DatabaseId --collectionId "votos_por_organizacion" --key "cantidad_votos" --required true --xdefault 0

Write-Host "`n=== Configuracion completada exitosamente ===" -ForegroundColor Green
Write-Host "Recuerda crear los usuarios en Authentication > Users con email = {cedula}@electoral.ec" -ForegroundColor Cyan
