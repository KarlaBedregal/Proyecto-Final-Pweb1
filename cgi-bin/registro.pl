#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use DBI;
use Digest::SHA qw(sha256_hex);

# Conexión a la base de datos
my $dbh = DBI->connect("DBI:mysql:usuarios_db", "user", "mi_password")
    or die "No se pudo conectar a la base de datos: $DBI::errstr";

# Si el formulario fue enviado
if (param('nombre') && param('apellidos') && param('nombre_usuario') && param('edad') && param('genero') && param('telefono') && param('correo') && param('contrasena') && param('contrasena_confirmacion')) {

    # Recuperar datos del formulario
    my $nombre = param('nombre');
    my $apellidos = param('apellidos');
    my $nombre_usuario = param('nombre_usuario');
    my $edad = param('edad');
    my $genero = param('genero');
    my $telefono = param('telefono');
    my $correo = param('correo');
    my $contrasena = param('contrasena');
    my $contrasena_confirmacion = param('contrasena_confirmacion');

    if ($contrasena ne $contrasena_confirmacion) {
    print header(), start_html('Error'), h1('Las contraseñas no coinciden'), end_html;
    exit;
    }

    use Digest::SHA qw(sha256_hex);
    my $contrasena_hash = sha256_hex($contrasena);

    # Insertar datos en la base de datos
    my $sth = $dbh->prepare("INSERT INTO usuarios (nombre, apellidos, nombre_usuario, edad, genero, telefono, correo, contrasena) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
    or die "No se pudo preparar la consulta: $DBI::errstr";
    $sth->execute($nombre, $apellidos, $nombre_usuario, $edad, $genero, $telefono, $correo, $contrasena_hash)
    or die "No se pudo ejecutar la consulta: $DBI::errstr";

    # Respuesta de éxito
    print header(), start_html('Registro Exitoso'), h1('¡Registro Exitoso!'),
          p('Tu cuenta ha sido creada correctamente.'),
          p('Puedes ir a la página de inicio de sesión.'),
          end_html;
} else {
    # Si el formulario no ha sido enviado, mostrar el formulario HTML
    print header(), start_html('Registro'),
          h1('Formulario de Registro'),
          start_form(-action => "/cgi-bin/registro.pl", -method => "POST"),
          p('Nombre: '), textfield('nombre'),
          p('Correo: '), textfield('correo'),
          p('Contraseña: '), password_field('contrasena'),
          p(submit('Registrar')),
          end_form(), end_html;
}

# Cerrar la conexión
$dbh->disconnect();
