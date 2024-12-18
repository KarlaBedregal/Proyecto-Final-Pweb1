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
my $query_directorio = "SELECT DISTINCT directorio FROM canciones";
my $sth_directorio = $dbh->prepare($query_directorio);
$sth_directorio->execute();

print $cgi->header('text/html; charset=UTF-8');

print <<EOF;
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tabla de descargas</title>
    <img src="../images/perrito2.png" alt="perrito2" class="perrito2">
    <a href="../descargador.html" id="principal">Ir a la pagina principal</a>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(to right, #00bfff, #7fffd4); /* Gradiente de celeste a verde agua */
            margin: 0 20px;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        * {
            box-sizing: border-box;
        }

        h1 {
            font-size: 3rem;
            color: #1a589c;
            margin-bottom: 50px;
            text-align: center;
        }

        table {
            width: 80%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            padding: 12px;
            text-align: center;
            border: 1px solid #ddd;
        }

        th {
            background-color: #4facfe;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        button {
            padding: 8px 16px;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-editar {
            background-color: #4facfe; /* Azul para Editar */
        }

        .btn-eliminar {
            background-color: #ff6347; /* Rojo para Eliminar */
        }

        .btn-editar:hover, .btn-eliminar:hover {
            opacity: 0.8;
        }

        .contenedor-flex {
            display: flex;
            justify-content: space-between;
            width: 100%;
            margin-top: 20px;
        }

        .perrito2 {
        width: 200px;
        height: auto;
        position: fixed; /* Fija la imagen en la pantalla */
        bottom: 20px; /* Distancia de 20px desde el borde inferior */
        right: 20px; /* Distancia de 20px desde el borde izquierdo */
        z-index: 1000; /* Asegura que la imagen esté sobre otros elementos */
        }

        #principal {
        position: fixed;      /* Fija el elemento en la pantalla */
        top: 20px;            /* A 20px desde la parte superior */
        right: 20px;          /* A 20px desde la parte derecha */
        background-color: #FF6347; /* Color de fondo (tomate) */
        color: white;         /* Color del texto */
        padding: 10px 20px;   /* Espaciado dentro del enlace */
        border-radius: 10px;  /* Bordes redondeados */
        font-weight: bold;    /* Negrita */
        text-decoration: none; /* Quitar subrayado */
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Sombra para destacarlo */
        transition: all 0.3s ease; /* Transición suave */
        }

        #principal:hover {
            background-color: #FF4500; /* Cambiar color de fondo al pasar el mouse */
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2); /* Cambiar la sombra al pasar el mouse */
        }

        }

    </style>
</head>

<body>
<div class="contenedor-flex">
    <div>
        <h1>Tabla de Canciones</h1>
        <div>
            <h2>Lista de Directorios</h2>
EOF

while (my $dir_row = $sth_directorio->fetchrow_hashref) {
    my $directorio = $dir_row->{directorio};
    print "<h3>Lista: $directorio</h3>";

    # Consultar las canciones de ese directorio
    my $query_canciones = "SELECT * FROM canciones WHERE directorio = ?";
    my $sth_canciones = $dbh->prepare($query_canciones);
    $sth_canciones->execute($directorio);

    print "<table>";
    print "<tr><th>ID</th><th>Nombre Canción</th><th>URL</th><th>Directorio</th><th>Fecha Descarga</th><th>Acciones</th></tr>";

    while (my $row = $sth_canciones->fetchrow_hashref) {
        print "<tr>";
        print "<td>" . $row->{id} . "</td>";
        print "<td>" . $row->{nombre_cancion} . "</td>";
        print "<td>" . $row->{url} . "</td>";
        print "<td>" . $row->{formato} . "</td>";
        print "<td>" . $row->{fecha_descarga} . "</td>";

        # Botones para editar y eliminar
        print "<td>";
        print "<button class='btn-editar' onclick='editarCancion(" . $row->{id} . ", \"" . $row->{nombre_cancion} . "\")'>Editar</button> | ";
        print "<button class='btn-eliminar' onclick='eliminarCancion(" . $row->{id} . ")'>Eliminar</button>";
        print "</td>";
        print "</tr>";
    }
    print "</table>";
}

# Modal para editar
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
        document.getElementById('editId').value = id;
        document.getElementById('editNombre').value = nombre;
        document.getElementById('modalEdit').style.display = 'block';
    }

    function cerrarModal() {
        document.getElementById('modalEdit').style.display = 'none';
    }

    function submitEdit() {
        var id = document.getElementById('editId').value;
        var nombre = document.getElementById('editNombre').value;

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'update_song.pl', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4 && xhr.status == 200) {
                alert('Canción actualizada');
                cerrarModal();
                location.reload();
            }
        };
        xhr.send('action=editar&id_cancion=' + id + '&nombre_cancion=' + encodeURIComponent(nombre));
    }

    function eliminarCancion(id) {
        if (confirm('¿Estás seguro de que quieres eliminar esta canción?')) {
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'delete_song.pl', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function () {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    alert('Canción eliminada');
                    location.reload();
                }
            };
            xhr.send('action=eliminar&id_cancion=' + id);
        }
    }
</script>

</div>
</div>
</body>
</html>
HTML

print $cgi->end_html;