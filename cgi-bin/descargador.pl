#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use File::Path qw(make_path);
use File::Spec;
use Encode;
use utf8;

my $cgi = CGI->new;

print $cgi->header('text/html; charset=UTF-8');
print $cgi->start_html('Descargar Video');

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

        if ($? != 0) {
            print "<p>Error al descargar el video: $download_output</p>";
        } else {
            print "<h2>Video descargado exitosamente en formato $extension.</h2>";
        }

        # Mostrar lista de archivos en el directorio
        print "<h2>Archivos disponibles en el directorio:</h2>";
        opendir(my $dh, $path) or die "No se pudo abrir el directorio '$path': $!";
        my @files = readdir($dh);
        closedir($dh);

        print "<ul>";
        foreach my $file (@files) {
            next if $file =~ /^\./; # Ignorar archivos ocultos
            print "<li>" . encode('UTF-8', $file) . "</li>";
        }
        print "</ul>";

        # Enlace al directorio accesible
        my $enlace_directorio = $nuevo_directorio ? $nuevo_directorio : $directorio;
        print "<h3>Para ver sus descargas, haga click: <a href='/descargas/$enlace_directorio'>Ver archivos</a></h3>";
    } else {
        print "<p>Error: Proporcione una URL válida.</p>";
    }
}
    # Finalizar HTML
    print $cgi->end_html;
