#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use File::Path qw(make_path);
use File::Spec;
use Encode;
use DBI;
use File::Basename;
use utf8;  # Asegura que el código fuente esté en UTF-8
binmode(STDOUT, ":utf8"); 

my $cgi = CGI->new;

# Configuración de conexión a la base de datos
my $dsn = "DBI:mysql:database=mi_base_de_datos;host=localhost";
my $usuario = "mi_usuario";
my $contraseña = "mi_contraseña";
my $dbh = DBI->connect($dsn, $usuario, $contraseña) or die "No se pudo conectar a la base de datos: $DBI::errstr";


print $cgi->header('text/html; charset=UTF-8');

print <<EOF;
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Usuario</title>
    <style>
    body {
        font-family: Arial, sans-serif;
        background-color: #ffffff;
        margin: 0;
        padding: 0;
        height: 100vh; /* Asegura que el cuerpo ocupe toda la altura de la ventana */
        display: flex;
        align-items: center; /* Centra verticalmente */
        flex-direction: column; /* Para que todo esté alineado en columna */
    }

    * {
        box-sizing: border-box; /* Ajusta el tamaño para todos los elementos */
    }

    h1 {
        font-size: 2rem;
        color: #4facfe;
        margin-bottom: 50px; 
        text-align: center; /* Alinea el título al centro */
    }

    p {
        text-align: center;   /* Centra el texto */
        font-size: 0.8rem;    /* Tamaño de fuente pequeño */
        color: #333;          /* Puedes cambiar el color si lo deseas */
        margin: 10px 0;       /* Añade algo de espacio arriba y abajo */
    }


    label {
        color: #2e2708ab; /* Cambia el color del texto */
        font-size: 16px; /* Tamaño de fuente opcional */
        margin-bottom: 5px; /* Espaciado opcional */
        display: block; /* Asegura que el label ocupe toda la línea */
    }

    form {
        width: 100%;
        max-width: 400px; /* Tamaño máximo del formulario */
        padding: 20px;
        border-radius: 20px;
        background-color: rgba(255, 255, 255, 0); /* Fondo semitransparente */
        border: 1px solid #1c1c1c00;
    }

    .input-group {
        display: flex;
        justify-content: space-between;
        margin-bottom: 20px;
    }

    .input-group div {
        width: 48%;
    }

    input[type="text"], 
    input[type="password"], 
    input[type="email"], 
    input[type="date"], 
    input[type="number"], 
    input[type="tel"],
    select {
        width: 100%;
        padding: 10px;
        margin-bottom: 20px;
        border: 1px solid #382a1c; /* Cambia el color del borde */
        border-radius: 30px;
        background-color: rgba(158, 103, 48, 0); /* Cambia el color de fondo si lo deseas */
        color: #1b1b1b; /* Cambia el color del texto */
    }

    /* Estilo cuando el campo está en foco (al hacer clic) */
    input[type="text"]:focus, 
    input[type="password"]:focus, 
    input[type="email"]:focus, 
    input[type="date"]:focus, 
    input[type="number"]:focus, 
    select:focus {
        border-color: #33b819; /* Cambia el borde al hacer foco */
        outline: none; /* Elimina el contorno predeterminado */
    }

    input[type="submit"] {
        background-color: #6dd436;
        color: white;
        padding: 12px 18px; /* Aumenté el padding para hacerlo más grande */
        border: none;
        border-radius: 8px; /* Bordes más redondeados */
        cursor: pointer;
        width: 100%;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* Agregué sombra */
        transition: all 0.3s ease; /* Transición suave para hover */
    }

    input[type="submitt"] {
        background-color: #6dd436;
        color: white;
        margin: 20px 25px; 
        padding: 12px 18px; /* Aumenté el padding para hacerlo más grande */
        border: none;
        border-radius: 8px; /* Bordes más redondeados */
        cursor: pointer;
        width: 100%;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* Agregué sombra */
        transition: all 0.3s ease; /* Transición suave para hover */
    }
</style>

</head>

<body>
<div class="contenedor-flex">
EOF

my $is_ajax = $cgi->param('directorio'); 

if ($is_ajax) {
    # Solicitud AJAX: Solo actualizar el directorio y devolver la respuesta
    my $directorio = $cgi->param('directorio') || 'Mis favoritos';
    print $directorio;
} else {
    # Parámetros del formulario
    my $url = $cgi->param('url');
    my $directorio = $cgi->param('select') || 'favoritos';
    my $nuevo_directorio = $cgi->param('nuevo_directorio') || '';
    my $accion = $cgi->param('action');

    # Si se recibe un nuevo directorio, limpiamos caracteres no válidos
    if ($nuevo_directorio) {
        $nuevo_directorio =~ s/[^a-zA-Z0-9_\-]//g; # Solo caracteres válidos
        if ($nuevo_directorio eq '') {
            print "<p>Error: El nombre del nuevo directorio no es válido.</p>";
            print $cgi->end_html;
            exit;
        }
    }

    # Determina el directorio de descarga
    my $path;
    if ($nuevo_directorio) {
        $path = File::Spec->catfile('/descargas', $nuevo_directorio);
        # Crear el directorio si no existe y manejar errores
        eval { make_path($path) unless -d $path; };
        if ($@) {
            print "<p>Error al crear el directorio '$nuevo_directorio': $@</p>";
            print $cgi->end_html;
            exit;
        }
        print "<p>Directorio personalizado creado: $nuevo_directorio</p>";
    } else {
        $path = File::Spec->catfile('/descargas', $directorio);
        eval { make_path($path) unless -d $path; };
        if ($@) {
            print "<p>Error al crear el directorio '$directorio': $@</p>";
            print $cgi->end_html;
            exit;
        }
    }

    # Verificar si la URL es válida
    if ($url && $url =~ /^https?:\/\/[^\s]+$/) {
        my $download_command;
        my $extension;

        # Construir el comando de descarga según la acción seleccionada
        if ($accion eq 'descargar_mp4') {
            $extension = 'mp4';
            $download_command = "yt-dlp --no-overwrites -f mp4 --restrict-filenames -o '$path/%(title)s-%(autonumber)s.%(ext)s' $url";
        } elsif ($accion eq 'descargar_mp3') {
            $extension = 'mp3';
            $download_command = "yt-dlp --no-overwrites -x --audio-format mp3 --restrict-filenames -o '$path/%(title)s-%(autonumber)s.%(ext)s' $url";
        } elsif ($accion eq 'descargar_avi') {
            $extension = 'avi';
            $download_command = "yt-dlp --no-overwrites --recode-video avi --restrict-filenames -o '$path/%(title)s-%(autonumber)s.%(ext)s' $url";
        } else {
            print "<p>Error: Acción no válida.</p>";
            print $cgi->end_html;
            exit;
        }

        # Ejecutar el comando de descarga
        my $download_output = `$download_command 2>&1`;
        my $directorio_guardado = $nuevo_directorio || $directorio;
        if ($? != 0) {
            print "<p>Error al descargar el video: $download_output</p>";
        } else {
            print "<h1>Video descargado exitosamente en formato $extension.</h1>";
            my $filename = "$path/" . (glob "$path/*.$extension")[0]; 
            my $metadata_json = `yt-dlp -j $url`;

            use JSON;
            my $metadata = decode_json($metadata_json);

            # Extraer los datos de la URL del video
            my $nombre_cancion = $metadata->{title} || 'Desconocido';
            $directorio_guardado = $nuevo_directorio || $directorio;

            my $insertardatosvideos = $dbh->prepare("INSERT INTO canciones (nombre_cancion, url, formato, directorio) VALUES (?, ?, ?, ?)");
            $insertardatosvideos->execute($nombre_cancion, $url, $extension, $directorio_guardado);

        }
        print "<form action='/cgi-bin/ver_canciones.pl' method='get'>";
        print "<input type='hidden' name='directorio' value='$directorio_guardado'>";
        print "<input type='submit' value='Ver Historial de canciones'>";
        print "</form>";

        
    } else {
        print "<p>Error: Proporcione una URL válida.</p>";
    }
}
print "</div>";
# Finalizar HTML
print $cgi->end_html;
