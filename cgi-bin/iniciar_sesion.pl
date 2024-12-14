#!/usr/bin/perl
use CGI qw(:standard);
use DBI;
use Digest::SHA qw(sha256_hex);
use utf8;  # Asegura que el código fuente esté en UTF-8
binmode(STDOUT, ":utf8"); 

# Configuración de conexión a la base de datos
my $dsn = "DBI:mysql:database=mi_base_de_datos;host=localhost";
my $usuario = "mi_usuario";
my $contraseña = "mi_contraseña";
my $dbh = DBI->connect($dsn, $usuario, $contraseña) or die "No se pudo conectar a la base de datos: $DBI::errstr";

# Obtener datos del formulario
my $username = param('usuario');
my $password = param('password');

# Encriptar la contraseña (usando SHA-256, por ejemplo)
my $hashed_password = sha256_hex($password);

# Consulta para verificar las credenciales del usuario
my $sth = $dbh->prepare("SELECT * FROM usuarios WHERE usuario = ? AND password = ?");
$sth->execute($username, $hashed_password);

# Verificar si hay un usuario con las credenciales proporcionadas
if (my $row = $sth->fetchrow_hashref) {
    # Redirigir a la página principal
    print "Content-type: text/html\n";
    print "Location: ../descargador.html\n\n";  # Cambia la URL según la ubicación de tu página principal
} else {
    # Si no se encuentra el usuario o la contraseña es incorrecta
    print header();
    print "<h1>Error de inicio de sesión</h1>";
    print "<p>El nombre de usuario o la contraseña son incorrectos. Regístrate aquí -> <a href='../registro.html'>Intenta nuevamente</a>.</p>";
}

# Cerrar la conexión a la base de datos
$sth->finish();
$dbh->disconnect();
