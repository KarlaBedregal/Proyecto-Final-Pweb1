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

# Parámetros del formulario
my $url = $cgi->param('url');
my $directorio = $cgi->param('select') || 'root';
my $nuevo_directorio = $cgi->param('nuevo_directorio') || '';
my $accion = $cgi->param('action');

# Determina el directorio de descarga
my $path;
if ($nuevo_directorio) {
    $path = File::Spec->catfile('/descargas', $nuevo_directorio);
    make_path($path) unless -d $path;
    print "<p>Directorio personalizado creado: $nuevo_directorio</p>";
} else {
    $path = File::Spec->catfile('/descargas', $directorio);
}

# Verificar si la URL es válida
if ($url && $url =~ /^https?:\/\/[^\s]+$/) {
    my $video_descargado;

    # Verificar si ya hay archivos descargados
    my @archivos_descargados = glob("$path/*.mp4");
    if (@archivos_descargados) {
        $video_descargado = $archivos_descargados[0];
        print "<h2>Video ya descargado: $video_descargado</h2>";
    } else {
        # Descargar el video en la mejor calidad posible
        my $download_command = "yt-dlp --restrict-filenames -f best -o '$path/%(title)s.%(ext)s' $url";
        my $download_output = `$download_command 2>&1`;

        if ($? != 0) {
            print "<p>Error al descargar el video: $download_output</p>";
        } else {
            my @archivos_descargados = glob("$path/*.mp4");
            $video_descargado = $archivos_descargados[0];
            print "<h2>Video descargado: $video_descargado</h2>";
        }
    }

    # Mostrar lista de archivos en el directorio
    print "<h2>Archivos disponibles en el directorio:</h2>";
    opendir(my $dh, $path) or die "No se pudo abrir el directorio '$path': $!";
    my @files = readdir($dh);
    closedir($dh);

    print "<ul>";
    foreach my $file (@files) {
        next if $file =~ /^\./;
        print "<li>" . encode('UTF-8', $file) . "</li>";
    }
    print "</ul>";

    # Enlace al directorio accesible
    print "<h3>Para ver sus descargas, haga click: <a href='/descargas/$nuevo_directorio'>Ver archivos</a></h3>";
} else {
    print "<p>Error: Proporcione una URL válida.</p>";
}

print $cgi->end_html;
