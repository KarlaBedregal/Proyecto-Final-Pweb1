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
    print "Location: ../descargador.html\n\n";  
} else {
    # Si no se encuentra el usuario o la contraseña es incorrecta
    print header();
    print start_html(
        -title => "Error de inicio de sesión",
        -style => { -code => q{
            body {
                background: linear-gradient(to bottom, #E0FFFF, #008080); /* Degradado de celeste a verde agua */
                color: #FFFFFF; /* Texto blanco */
                font-family: Arial, sans-serif;
                text-align: center;
                padding: 50px;
                height: 100vh; /* Altura total de la ventana */
                margin: 0; /* Eliminar márgenes */
            }
            h1 {
                color: #FFFFFF; /* Encabezado en blanco */
                text-shadow: 2px 2px 4px #004D40; /* Sombra para destacar */
            }
            a {
                color: #004D40; /* Verde oscuro */
                text-decoration: none;
                font-weight: bold;
            }
            a:hover {
                color: #00796B; /* Verde agua más claro */
            }
        } }
    );
    print "<h1>Error de inicio de sesión</h1>";
    print "<p>El nombre de usuario o la contraseña son incorrectos. Registrate aqui -> <a href='../registro.html'>Intenta nuevamente</a>.</p>";
    print end_html();
}

# Cerrar la conexión a la base de datos
$sth->finish();
$dbh->disconnect();
