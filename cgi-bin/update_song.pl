#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $cgi = CGI->new;
my $dbh = DBI->connect("DBI:mysql:database=mi_base_de_datos;host=localhost", "mi_usuario", "mi_contraseña") or die "No se pudo conectar a la base de datos: $DBI::errstr";

my $id_cancion = $cgi->param('id_cancion');
my $nombre_cancion = $cgi->param('nombre_cancion');

if ($id_cancion && $nombre_cancion) {
    my $sth = $dbh->prepare("UPDATE canciones SET nombre_cancion = ? WHERE id = ?");
    $sth->execute($nombre_cancion, $id_cancion);
}

print $cgi->header('text/html; charset=UTF-8');
print "Canción actualizada con éxito.";

