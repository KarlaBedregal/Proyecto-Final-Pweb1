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
if (param('nombre_usuario') && param('contrasena')) {
    # Recuperar los datos del formulario
    my $nombre_usuario = param('nombre_usuario');
    my $contrasena = param('contrasena');

    # Recuperar el hash de la contraseña desde la base de datos
    my $sth = $dbh->prepare("SELECT contrasena FROM usuarios WHERE nombre_usuario = ?")
        or die "No se pudo preparar la consulta: $DBI::errstr";
    $sth->execute($nombre_usuario)
        or die "No se pudo ejecutar la consulta: $DBI::errstr";
    
    # Verificar si se encontró el usuario
    if (my $row = $sth->fetchrow_hashref) {
        # Comparar la contraseña ingresada con el hash almacenado
        my $contrasena_hash = $row->{contrasena};
        if (sha256_hex($contrasena) eq $contrasena_hash) {
            # Si la contraseña es correcta
            print header(), start_html('Inicio de sesión exitoso'),
                  h1('¡Bienvenido!'),
                  p('Has iniciado sesión correctamente.'),
                  end_html;
        } else {
            # Si la contraseña es incorrecta
            print header(), start_html('Error'),
                  h1('Error en el inicio de sesión'),
                  p('La contraseña es incorrecta.'),
                  end_html;
        }
    } else {
        # Si no se encuentra el usuario
        print header(), start_html('Error'),
              h1('Error en el inicio de sesión'),
              p('El nombre de usuario no existe.'),
              end_html;
    }
} else {
    # Si el formulario no ha sido enviado, mostrar el formulario de inicio de sesión
    print header(), start_html('Iniciar Sesión'),
          h1('Formulario de Ingreso'),
          start_form(-action => "/cgi-bin/iniciar_sesion.pl", -method => "POST"),
          p('Nombre de usuario: '), textfield('nombre_usuario'),
          p('Contraseña: '), password_field('contrasena'),
          p(submit('Iniciar Sesión')),
          end_form(), end_html;
}

# Cerrar la conexión
$dbh->disconnect();
