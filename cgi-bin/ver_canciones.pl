#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use File::Spec;
use utf8;

my $cgi = CGI->new;
my $directorio = $cgi->param('directorio') || 'Mis favoritos';
my $path = File::Spec->catfile('/descargas', $directorio);

print $cgi->header('text/html; charset=UTF-8');
print $cgi->start_html('Canciones Descargadas');

print "<h1>Canciones Descargadas en '$directorio'</h1>";

opendir(my $dh, $path) or die "No se pudo abrir el directorio '$path': $!";
my @files = readdir($dh);
closedir($dh);

print "<ul>";
foreach my $file (@files) {
    next if $file =~ /^\./; # Omitir archivos ocultos
    print "<li>$file</li>";
}
print "</ul>";

print "<a href='/cgi-bin/descargador.pl'>Regresar a la página principal</a>";

print $cgi->end_html;

