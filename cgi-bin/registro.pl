#!/usr/bin/perl
use CGI qw(:standard);
use DBI;
use utf8;  # Asegura que el código fuente esté en UTF-8
binmode(STDOUT, ":utf8"); 

my $q = CGI->new;

# Configuración de conexión a la base de datos
my $dsn = "DBI:mysql:database=mi_base_de_datos;host=localhost";
my $usuario = "mi_usuario";
my $contraseña = "mi_contraseña";
my $dbh = DBI->connect($dsn, $usuario, $contraseña) or die "No se pudo conectar a la base de datos: $DBI::errstr";

# Obtener datos del formulario
my $nombre = param('nombre');
my $apellido = param('apellido');
my $fecha_nacimiento = param('fecha_nacimiento');
my $usuario = param('usuario');
my $correo = param('correo');
my $password = param('password');
my $confirmar_password = $q->param('confirmar_password');
my $edad = param('edad');
my $genero = param('genero');
my $telefono = param('telefono');

if ($password ne $confirmar_password) {
    print $q->header(-type => 'text/html');
    print $q->start_html('Error');
    print "Las contraseñas no coinciden. Por favor, intente nuevamente.";
    print $q->end_html;
    exit;
}

if ($telefono !~ /^\d{9}$/) {
    print $q->header(-type => 'text/html');
    print $q->start_html('Error');
    print "El teléfono debe contener exactamente 9 dígitos numéricos.";
    print $q->end_html;
    exit;
}

if (!$nombre || !$apellido || !$fecha_nacimiento || !$usuario || !$correo || !$password || !$edad || !$genero || !$telefono) {
    print "Content-type: text/html\n\n";
    print header();
    print "<h1>Error: Todos los campos son obligatorios.</h1>";
    exit;
}

# Consulta para verificar si ya existe el usuario o correo
my $sth_check = $dbh->prepare("SELECT COUNT(*) FROM usuarios WHERE usuario = ? OR correo = ?");
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

    my $sth_insert = $dbh->prepare("INSERT INTO usuarios (nombre, apellido, fecha_nacimiento, usuario, correo, password, edad, genero, telefono) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $sth_insert->execute($nombre, $apellido, $fecha_nacimiento, $usuario, $correo, $hashed_password, $edad, $genero, $telefono) or die "No se pudo insertar el usuario: $DBI::errstr";
    
    # Respuesta al usuario
    print "Content-type: text/html\n";
    print "Location: ../iniciar_sesion.html\n\n";  # Cambia la URL según la ubicación de tu página de inicio de sesión
    exit; 

    $sth_insert->finish();
}

# Cerrar la conexión a la base de datos
$sth_check->finish();
$dbh->disconnect();
