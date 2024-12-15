#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $cgi = CGI->new;

# Configuración de conexión a la base de datos
my $dsn = "DBI:mysql:database=mi_base_de_datos;host=localhost";
my $usuario = "mi_usuario";
my $contraseña = "mi_contraseña";
my $dbh = DBI->connect($dsn, $usuario, $contraseña) or die "No se pudo conectar a la base de datos: $DBI::errstr";

# Obtener la acción (editar, eliminar) y el ID de la canción a editar/eliminar
my $accion = $cgi->param('action') || '';
my $id_cancion = $cgi->param('id_cancion') || '';

# Si se recibe una acción de eliminar
if ($accion eq 'eliminar' && $id_cancion) {
    my $sth = $dbh->prepare("DELETE FROM canciones WHERE id = ?");
    $sth->execute($id_cancion);
    print $cgi->header('text/html; charset=UTF-8');
    print "<h3>Canción eliminada con éxito.</h3>";
}

# Consultar la base de datos
my $query = "SELECT * FROM canciones";
my $sth = $dbh->prepare($query);
$sth->execute();

print $cgi->header('text/html; charset=UTF-8');
print $cgi->start_html('Tabla de Canciones');

# Mostrar el nombre del directorio
my $directorio = 'Mis favoritos';  # Aquí puedes cambiar el directorio dinámicamente si lo necesitas
print "<h2>Directorio: $directorio</h2>";

# Mostrar los datos de la tabla
print "<h3>Tabla de Canciones:</h3>";
print "<table border='1'>";
print "<tr><th>ID</th><th>Nombre Canción</th><th>URL</th><th>Formato</th><th>Directorio</th><th>Fecha Descarga</th><th>Acciones</th></tr>";

while (my $row = $sth->fetchrow_hashref) {
    print "<tr>";
    print "<td>" . $row->{id} . "</td>";
    print "<td>" . $row->{nombre_cancion} . "</td>";
    print "<td>" . $row->{url} . "</td>";
    print "<td>" . $row->{formato} . "</td>";
    print "<td>" . $row->{directorio} . "</td>";
    print "<td>" . $row->{fecha_descarga} . "</td>";

    # Enlaces para editar y eliminar con AJAX
    print "<td>";
    print "<a href='#' onclick='editarCancion(" . $row->{id} . ", \"" . $row->{nombre_cancion} . "\")'>Editar</a> | ";
    print "<a href='#' onclick='eliminarCancion(" . $row->{id} . ")'>Eliminar</a>";
    print "</td>";

    print "</tr>";
}

print "</table>";

# Agregar el modal de edición
print <<'HTML';
<!-- Modal para editar -->
<div id="modalEdit" style="display:none;">
    <div style="background-color:#fff; padding:20px; width:300px; margin:auto; border:1px solid #ccc; box-shadow:0 4px 8px rgba(0, 0, 0, 0.1);">
        <h3>Editar Canción</h3>
        <form id="editForm">
            <input type="hidden" id="editId">
            <label for="nombre_cancion">Nuevo nombre: </label>
            <input type="text" id="editNombre" required>
            <br><br>
            <button type="button" onclick="submitEdit()">Actualizar</button>
            <button type="button" onclick="cerrarModal()">Cerrar</button>
        </form>
    </div>
</div>

<script>
    function editarCancion(id, nombre) {
        // Mostrar el modal y establecer el valor del campo
        document.getElementById('editId').value = id;
        document.getElementById('editNombre').value = nombre;
        document.getElementById('modalEdit').style.display = 'block';
    }

    function cerrarModal() {
        // Ocultar el modal
        document.getElementById('modalEdit').style.display = 'none';
    }

    function submitEdit() {
        var id = document.getElementById('editId').value;
        var nombre = document.getElementById('editNombre').value;

        // Realizar la solicitud AJAX para editar la canción
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'update_song.pl', true);  // Apuntar a un script Perl de actualización
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4 && xhr.status == 200) {
                alert('Canción actualizada');
                cerrarModal();
                location.reload();  // Recargar la página para reflejar el cambio
            }
        };
        xhr.send('action=editar&id_cancion=' + id + '&nombre_cancion=' + encodeURIComponent(nombre));
    }

    function eliminarCancion(id) {
        if (confirm('¿Estás seguro de que quieres eliminar esta canción?')) {
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'delete_song.pl', true);  // Apuntar a un script Perl de eliminación
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function () {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    alert('Canción eliminada');
                    location.reload();  // Recargar la página para reflejar la eliminación
                }
            };
            xhr.send('action=eliminar&id_cancion=' + id);
        }
    }
</script>
HTML

print $cgi->end_html;


