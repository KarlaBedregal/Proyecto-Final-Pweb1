#!/usr/bin/perl
use CGI qw(:standard);
use DBI;
use utf8;  # Asegura que el código fuente esté en UTF-8
binmode(STDOUT, ":utf8"); 

# Configuración de conexión a la base de datos
my $dsn = "DBI:mysql:database=mi_base_de_datos;host=localhost";
my $usuario = "mi_usuario";
my $contraseña = "mi_contraseña";
my $dbh = DBI->connect($dsn, $usuario, $contraseña) or die "No se pudo conectar a la base de datos: $DBI::errstr";

# Obtener datos del formulario
my $username = param('username');
my $email = param('email');
my $password = param('password');

if (!$username || !$email || !$password) {
    print "Content-type: text/html\n\n";
    print header();
    print "<h1>Error: Todos los campos son obligatorios.</h1>";
    exit;
}

# Consulta para verificar si ya existe el usuario o correo
my $sth_check = $dbh->prepare("SELECT COUNT(*) FROM usuarios WHERE username = ? OR email = ?");
$sth_check->execute($username, $email) or die "Error al verificar el usuario: $DBI::errstr";
my ($exists) = $sth_check->fetchrow_array();

if ($exists > 0) {
    # Usuario ya registrado
    print "Content-type: text/html\n\n";
    print header();
    print "<h1>Error: El usuario o correo ya está registrado.</h1>";
    print "<p><a href='../iniciar_sesion.html'>Iniciar sesion</a></p>";
} else {
    # Encriptar la contraseña
    use Digest::SHA qw(sha256_hex);
    my $hashed_password = sha256_hex($password);

    # Insertar un nuevo usuario
    my $sth_insert = $dbh->prepare("INSERT INTO usuarios (username, email, password) VALUES (?, ?, ?)");
    $sth_insert->execute($username, $email, $hashed_password) or die "No se pudo insertar el usuario: $DBI::errstr";
    
    # Respuesta al usuario
    print "Content-type: text/html\n";
    print "Location: ../iniciar_sesion.html\n\n";  # Cambia la URL según la ubicación de tu página de inicio de sesión
    exit; 

    $sth_insert->finish();
}

# Cerrar la conexión a la base de datos
$sth_check->finish();
$dbh->disconnect();
