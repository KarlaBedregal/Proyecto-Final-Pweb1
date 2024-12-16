#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use File::Spec;
use Encode;
use utf8;

my $cgi = CGI->new;

print $cgi->header('text/html; charset=UTF-8');
print $cgi->start_html('Configuración de mis descargas');

# Parámetros del formulario
my $formato_inicial = $cgi->param('selectmenuinicial') || 'mp4';
my $formato_final = $cgi->param('selectmenufinal') || 'mp4';
my $resolucion = $cgi->param('selectedresolucion');
my $proporcion_imagen = $cgi->param('selectedproporcionimagen');
my $audio_inicial = $cgi->param('selectedaudioinicial');
my $frecuencia = $cgi->param('selectedfrecuencia');
my $canales = $cgi->param('selectedcanales');
my $accion = $cgi->param('accion');

if ($frecuencia eq '44.1') {
    $frecuencia = 44100;
} elsif ($frecuencia eq '48') {
    $frecuencia = 48000;
} elsif ($frecuencia eq '96') {
    $frecuencia = 96000;
} elsif ($frecuencia eq '192') {
    $frecuencia = 192000;  # Añadir 192 kHz en Hz
}

if ($canales eq 'mono') {
    $canales = 1;  # Mono corresponde a 1 canal
} elsif ($canales eq 'stereo') {
    $canales = 2;  # Estéreo corresponde a 2 canales
} elsif ($canales eq '5.1') {
    $canales = 6;  # 5.1 Surround corresponde a 6 canales
} elsif ($canales eq '7.1') {
    $canales = 8;  # 7.1 Surround corresponde a 8 canales
}

# Asignar el valor adecuado de resolución
if ($resolucion eq '480p') {
    $resolucion = '640x480';  # Resolución 480p
} elsif ($resolucion eq '720p') {
    $resolucion = '1280x720';  # Resolución 720p
} elsif ($resolucion eq '1080p') {
    $resolucion = '1920x1080';  # Resolución 1080p
} elsif ($resolucion eq '1440p') {
    $resolucion = '2560x1440';  # Resolución 1440p
} elsif ($resolucion eq '2160p') {
    $resolucion = '3840x2160';  # Resolución 2160p (4K)
} elsif ($resolucion eq '4320p') {
    $resolucion = '7680x4320';  # Resolución 4320p (8K)
}

# Asignar la proporción de imagen
if ($proporcion_imagen eq '4.3') {
    $proporcion_imagen = '4:3';  # Proporción 4:3
} elsif ($proporcion_imagen eq '16.9') {
    $proporcion_imagen = '16:9';  # Proporción 16:9
} elsif ($proporcion_imagen eq '21.9') {
    $proporcion_imagen = '21:9';  # Proporción 21:9
} elsif ($proporcion_imagen eq '1.1') {
    $proporcion_imagen = '1:1';   # Proporción 1:1
} elsif ($proporcion_imagen eq '16.10') {
    $proporcion_imagen = '16:10';  # Proporción 16:10
}

# Asignar el valor adecuado de codificación de audio
if ($audio_inicial eq 'mp3') {
    $audio_inicial = 'libmp3lame';  # Codificación MP3
} elsif ($audio_inicial eq 'aac') {
    $audio_inicial = 'libfdk_aac';  # Codificación AAC
} elsif ($audio_inicial eq 'flac') {
    $audio_inicial = 'flac';         # Codificación FLAC
} elsif ($audio_inicial eq 'wav') {
    $audio_inicial = 'pcm_s16le';    # Codificación WAV
} elsif ($audio_inicial eq 'ogg') {
    $audio_inicial = 'libvorbis';    # Codificación OGG
} elsif ($audio_inicial eq 'opus') {
    $audio_inicial = 'libopus';      # Codificación Opus
}


# Comprobar si se presionó el botón "Convertir"
if ($accion && $accion eq 'convertir') {
    print "<h2>Conversión en proceso...</h2>";

    # Obtener el video seleccionado para convertir
    my $video_descargado = $cgi->param('video_descargado');
    
    if ($video_descargado) {
        # Mostrar información sobre la conversión
        print "<p>Convertiendo el video '$video_descargado' de $formato_inicial a $formato_final...</p>";

        
        # Comando de conversión con ffmpeg
        my $input_file = "/descargas/$video_descargado";
        my $output_file = "/descargas/$video_descargado.convertido.$formato_final";
        
        unless (-e $input_file) {
            print "<p>El archivo de entrada no se encontró en la ruta: $input_file</p>";
        }

        my $command;
        if ($formato_final eq 'mp3') {
            $command = "ffmpeg -i $input_file -vn -ar 44100 -ac $canales -b:a 192k $output_file";
        } else {
            $command = "ffmpeg -i $input_file -s $resolucion -aspect $proporcion_imagen -ar $frecuencia -ac $canales -c:v libx264 -c:a aac -b:a 192k $output_file";
        }
        # Ejecutar el comando
        my $output = `$command 2>&1`;  # Capturar salida y errores
        if ($?) {
            print "<p>Hubo un error al intentar convertir el video:</p><pre>$output</pre>";
        } else {
            print "<p>El video ha sido convertido con éxito. :)</p>";
        }        
        if (-s '/tmp/ffmpeg_error.log') {
            open my $fh, '<', '/tmp/ffmpeg_error.log';
            my @error_log = <$fh>;
            close $fh;
            print "<p>Error de ffmpeg:</p><pre>@error_log</pre>";
        } else {
            print "<p>El video ha sido convertido con éxito. Puedes descargarlo <a href='/descargas/$video_descargado.convertido.$formato_final'>aquí</a>.</p>";
            print '<video width="640" height="360" controls>
            <source src="/descargas/' . $video_descargado . '.convertido.' . $formato_final . '" type="video/mp4">
            Your browser does not support the video tag.
            </video><br><br>';
        }
    } else {
        print "<p>No se seleccionó un video para convertir.</p>";
    }
} else {
    # Mostrar el formulario de configuración cuando no se ha hecho la conversión
    print "<h1>LOADING...</h1>";
}

# Ruta del directorio de descargas
my $path = '/descargas';
opendir(my $dh, $path) or die "No se pudo abrir el directorio '$path': $!";
my @categorias = readdir($dh);
closedir($dh);


# Comenzamos el formulario
print <<HTML;
<head>
    <link rel="stylesheet" href="../html/config.css">
</head>
<h1>Configuración</h1>
<form action="/cgi-bin/config.pl" method="GET">
  <strong>Convertir &nbsp;De&nbsp;&nbsp;</strong>
  <select id="menuconfinicial" name="selectmenuinicial">
    <option value="mp4" @{[ $formato_inicial eq 'mp4' ? 'selected' : '' ]}>MP4</option>
    <option value="mp3" @{[ $formato_inicial eq 'mp3' ? 'selected' : '' ]}>MP3</option>
    <option value="avi" @{[ $formato_inicial eq 'avi' ? 'selected' : '' ]}>AVI</option>
  </select>
  
  <strong>&nbsp;a&nbsp;</Strong>
  
  <select id="menuconfifinal" name="selectmenufinal">
    <option value="mp4" @{[ $formato_final eq 'mp4' ? 'selected' : '' ]}>MP4</option>
    <option value="mp3" @{[ $formato_final eq 'mp3' ? 'selected' : '' ]}>MP3</option>
    <option value="avi" @{[ $formato_final eq 'avi' ? 'selected' : '' ]}>AVI</option>
  </select><br><br>   

  <strong>Seleccione el video</strong><br>
  <select id="video" name="video_descargado">
HTML

# Generar las opciones del <select> con los videos disponibles de todas las categorías
foreach my $categoria (@categorias) {
    next if $categoria =~ /^\./;  
    
    # Ruta completa para la categoría
    my $directorio_categoria = "$path/$categoria";
    
    # Comprobar si es un directorio
    if (-d $directorio_categoria) {
        opendir(my $dh_categoria, $directorio_categoria) or die "No se pudo abrir el directorio '$directorio_categoria': $!";
        my @videos = readdir($dh_categoria);
        closedir($dh_categoria);

        # Si hay videos en esta categoría, los agregamos al <select>
        foreach my $video (@videos) {
            next if $video =~ /^\./;  # Excluir directorios ocultos

            # Mostrar el video en la lista
            print "<option value='$categoria/$video'>$video</option>\n";
        }
    }
}

print <<HTML;
  </select><br><br>

  <strong>Propiedades del video de salida</strong><br>

  <p>Resolución 
    <select id="resolucion" name="selectedresolucion">
      <option value="480p" @{[ $resolucion eq '480p' ? 'selected' : '' ]}>480p (SD)</option>
      <option value="720p" @{[ $resolucion eq '720p' ? 'selected' : '' ]}>720P (HD)</option>
      <option value="1080p" @{[ $resolucion eq '1080p' ? 'selected' : '' ]}>1080P (Full HD)</option>
      <option value="1440p" @{[ $resolucion eq '1440p' ? 'selected' : '' ]}>1440 (Quad HD o 2K)</option>
      <option value="2160p" @{[ $resolucion eq '2160p' ? 'selected' : '' ]}>2160P (4K o Ultra HD)</option>
      <option value="4320p" @{[ $resolucion eq '4320p' ? 'selected' : '' ]}>4320p (8K)</option>
    </select>
  </p>

  <p>Proporción de la imagen 
    <select id="proporcionimagen" name="selectedproporcionimagen">
      <option value="4.3" @{[ $proporcion_imagen eq '4.3' ? 'selected' : '' ]}>4:3</option>
      <option value="16.9" @{[ $proporcion_imagen eq '16.9' ? 'selected' : '' ]}>16:9</option>
      <option value="21.9" @{[ $proporcion_imagen eq '21.9' ? 'selected' : '' ]}>21:9</option>
      <option value="1.1" @{[ $proporcion_imagen eq '1.1' ? 'selected' : '' ]}>1:1</option>
      <option value="16.10" @{[ $proporcion_imagen eq '16.10' ? 'selected' : '' ]}>16:10</option>
    </select>
  </p><br><br>

  <strong>Propiedades del audio de salida</strong><br>
  <p>Codificación de audio 
    <select id="inicialaudiomp3" name="selectedaudioinicial">
      <option value="mp3" @{[ $audio_inicial eq 'mp3' ? 'selected' : '' ]}>MP3 - libmp3lame</option>
      <option value="aac" @{[ $audio_inicial eq 'aac' ? 'selected' : '' ]}>AAC - libfdk_aac</option>
      <option value="flac" @{[ $audio_inicial eq 'flac' ? 'selected' : '' ]}>FLAC - libFLAC</option>
      <option value="wav" @{[ $audio_inicial eq 'wav' ? 'selected' : '' ]}>WAV</option>
      <option value="ogg" @{[ $audio_inicial eq 'ogg' ? 'selected' : '' ]}>OGG - libvorbis</option>
      <option value="opus" @{[ $audio_inicial eq 'opus' ? 'selected' : '' ]}>Opus - libopus</option>
    </select>
  </p>

  <p>Frecuencia 
  <select id="frecuencia" name="selectedfrecuencia">
    <option value="44.1" @{[ $frecuencia eq '44.1' ? 'selected' : '' ]}>44.1 kHz</option>
    <option value="48" @{[ $frecuencia eq '48' ? 'selected' : '' ]}>48 kHz</option>
    <option value="96" @{[ $frecuencia eq '96' ? 'selected' : '' ]}>96 kHz</option>
    <option value="192" @{[ $frecuencia eq '192' ? 'selected' : '' ]}>192 kHz</option>
  </select>
</p>

  <p>Canales 
    <select id="canales" name="selectedcanales">
      <option value="mono" @{[ $canales eq 'mono' ? 'selected' : '' ]}>Mono</option>
      <option value="stereo" @{[ $canales eq 'stereo' ? 'selected' : '' ]}>Estéreo</option>
      <option value="5.1" @{[ $canales eq '5.1' ? 'selected' : '' ]}>5.1 Surround</option>
      <option value="7.1" @{[ $canales eq '7.1' ? 'selected' : '' ]}>7.1 Surround</option>
    </select>
  </p><br>

  <button type="submit" name="accion" value="convertir">Convertir</button>
</form>
HTML

print $cgi->end_html;