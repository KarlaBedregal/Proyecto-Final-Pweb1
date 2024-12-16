<table><tr><th colspan="1" rowspan="2">![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.001.png)</th><th colspan="1" rowspan="2" valign="top"><b>UNIVERSIDAD NACIONAL DE SAN AGUSTÍN FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMA</b></th><th colspan="1">![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.002.png)</th></tr>
<tr><td colspan="1"><b>Página:</b> 1</td></tr>
</table>

**INFORME DE LABORATORIO**



|**INFORMACIÓN BÁSICA**||||||
| - | :- | :- | :- | :- | :- |
|**ASIGNATURA:**|**PROGRAMACIÓN WEB 1**|||||
|**TÍTULO DE LA PRÁCTICA:**|*TRABAJO FINAL*|||||
|**NÚMERO DE PRÁCTICA:**|*8*|**AÑO LECTIVO:**|*2024 - B*|**NRO. SEMESTRE:**|*II*|
|**FECHA DE PRESENTACIÓN**|*16/12/2024*|**HORA DE PRESENTACIÓN**|*16:00:00 PM*|||
|<p>**INTEGRANTE (s):**</p><p>Karla Miluska Bedregal Coaguila Oroche Yajo Paola Fernanda</p>|**NOTA:**|||||
|**DOCENTE:** *M.Sc. Richart Escobedo Quispe*||||||



|**SOLUCIÓN Y RESULTADOS**|
| - |
|<p>**I. PROYECTO**</p><p>**DOWNLOADERBYTE**</p><p>Descripción:</p><p>El proyecto consiste en una aplicación web que permite a los usuarios registrarse, iniciar sesión y acceder a una plataforma para descargar videos de YouTube en diversos formatos (MP3, MP4 y AVI). Después de ingresar un enlace de YouTube, el usuario puede elegir el formato de descarga y proceder con la descarga. Una vez completada, los archivos descargados se almacenan en una base de datos, organizada según la lista seleccionada antes de la descarga.</p><p>La plataforma incluye un CRUD (Crear, Leer, Actualizar, Eliminar) que permite modificar el nombre de las canciones descargadas o eliminarlas de la lista. Además, el sistema ofrece la opción de cambiar propiedades de los videos, como resolución, proporción de imagen y codificación de audio. Las canciones modificadas se almacenan en un arreglo y se ponen nuevamente a disposición del usuario para su conversión.</p>|

Para hacer más ameno el proceso de descarga, se han integrado pequeños juegos en JavaScript,![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.003.png) permitiendo al usuario disfrutar mientras se procesan los archivos. Además, la aplicación incluye una página de vista previa de los videos convertidos y descargados, proporcionando al usuario una experiencia completa desde la descarga hasta la visualización de los archivos.

2. **EQUIPOS, MATERIALES Y TEMAS UTILIZADOS**
- Sistema Operativo Ubuntu GNU Linux 22.04 Kernel 6.8.0-47-generic
- Visual Studio Code
- Editor de textos
- GitHub
- CGI::Session
- AJAX
- JSON
- XMLHttpRequest
- CGI (Common Gateway Interface)
- FFmpeg
- yt-dlp
- YouTube
- MariaDB
- MySQL
- Apache2
- UTF-8
- File::Spec
- Repositorio en github
3. **URL DE REPOSITORIO GITHUB [https://github.com/KarlaBedregal/Proyecto-Final-Pweb1.git**](https://github.com/KarlaBedregal/Proyecto-Final-Pweb1.git)**
3. **ESTRUCTURA DEL PROYECTO**

**├── Bedregal\_Oroche\_proyectofinal.zip ├── cgi-bin**

**│ ├── cerrar\_sesion.pl**

**│ ├── config.pl**

**│ ├── delete\_song.pl**

**│ ├── descargador.pl**

**│ ├── descargas.pl**

**│ ├── iniciar\_sesion.pl![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.004.png)**

**│ ├── registro.pl**

**│ ├── update\_song.pl**

**│ └── ver\_canciones.pl**

**├── Dockerfile**

**├── html**

**│ ├── config.css**

**│ ├── config.html**

**│ ├── descargador.html**

**│ ├── estilo1.css**

**│ ├── estilosdescargador.css**

**│ ├── index.html**

**│ ├── iniciar\_sesion.html**

**│ ├── registro.html**

**│ └── styles.css**

**├── images**

**│ ├── iconodownloaderbyte.png**

**│ └── imagen.jpg**

**├── init.sql**

**├── readme.md**

**└── TRABAJO FINAL informe pweb.docx (1).pdf**

**VI. DIAGRAMA DE LA BASE DE DATOS**



|**usuarios**|
| - |
|<p>id (PK)</p><p>nombre</p><p>apellido</p>fecha\_nacimiento</p><p>usuario</p><p>correo</p><p>edad</p>genero</p><p>telefono</p><p>fecha_registro</p>
|**canciones**|
|<p>id (PK)</p><p>nombre_cancion</p><p>url</p>formato</p><p>fecha_descarga</p><p>directorio</p>

<tr><td colspan="5"><p><b>VII. CÓDIGO FUENTE DEL PROYECTO</b></p><p>● PERL</p><p>1. registro.pl</p><p>&emsp;Este código Perl recibe datos de un formulario web, valida que las contraseñas coincidan, que el teléfono tenga 9 dígitos y que no falten campos obligatorios. Luego, verifica si el usuario o correo ya existen en la base de datos. Si no están registrados, encripta la contraseña y guarda los datos en la base de datos. Si el registro es exitoso, redirige al usuario a la página de inicio de sesión.</p><p>2. iniciar_sesion.pl</p><p>&emsp;Este código Perl maneja el inicio de sesión de un usuario. Recibe el nombre de usuario y la contraseña desde un formulario web, encripta la contraseña con SHA-256 y verifica si las credenciales coinciden con algún registro en la base de datos. Si las credenciales son correctas, redirige al usuario a la página principal. Si son incorrectas, muestra un mensaje de error e invita al usuario a registrarse o intentarlo nuevamente.</p><p>3. cerrar_sesion.pl</p><p>&emsp;Este código Perl maneja el cierre de sesión de un usuario. Al ejecutarse, imprime un mensaje de éxito indicando que la sesión se ha cerrado correctamente y proporciona un enlace para regresar a la página principal. Utiliza la función header() para definir el</p></td></tr>
</table>

encabezado HTTP y start\_html() y end\_html() para generar la estructura HTML de la página.![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.005.png)

4. descargador.pl

   Este código Perl gestiona la descarga de videos desde una URL proporcionada por el usuario. Primero, obtiene parámetros del formulario, como la URL del video y la acción de descarga (MP4, MP3, o AVI). Si se proporciona un nuevo directorio, crea ese directorio en el sistema de archivos. Luego, dependiendo de la acción, ejecuta un comando yt-dlp para descargar el video en el formato seleccionado. Si la descarga es exitosa, guarda los detalles del video en una base de datos MySQL. Además, proporciona un enlace para ver las canciones descargadas y un botón para cerrar sesión. También maneja errores como URL inválidas o problemas al crear directorios.

5. descargas.pl

   Este código Perl gestiona la visualización, edición y eliminación de canciones almacenadas en una base de datos. Al principio, se conecta a la base de datos MySQL y obtiene la acción y el ID de la canción que se desea editar o eliminar. Si se recibe una solicitud de eliminación, elimina la canción correspondiente de la base de datos.

   Luego, consulta y muestra una lista de directorios distintos donde se almacenan las canciones. Para cada directorio, consulta las canciones dentro de él y las muestra en una tabla con opciones para editar o eliminar cada canción. Los enlaces para editar y eliminar canciones usan funciones AJAX para interactuar con el servidor sin recargar la página.

   Además, incluye un modal para editar el nombre de la canción, con un formulario que se activa al hacer clic en "Editar". Al enviar la actualización, se usa un XMLHttpRequest para enviar los datos al script update\_song.pl y actualizar el nombre de la canción en la base de datos. Similarmente, el enlace de eliminar envía una solicitud para borrar la canción.

   También hay un botón para volver atrás y otro para cambiar las propiedades de las descargas.

   Este código incluye la interacción con la base de datos y la actualización dinámica de la página mediante AJAX, haciendo que la experiencia del usuario sea fluida y sin recargar la página.

6. update\_song.pl

   Este script Perl actualiza el nombre de una canción en una base de datos MySQL. Obtiene el id\_cancion y el nombre\_cancion desde los parámetros de la solicitud, y si ambos están presentes, ejecuta una consulta UPDATE para modificar el nombre de la canción en la base de datos. Finalmente, responde al usuario con un mensaje indicando que la![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.006.png) canción ha sido actualizada exitosamente.

7. delete\_song.pl

   Este script Perl elimina una canción de una base de datos MySQL. Obtiene el id\_cancion desde los parámetros de la solicitud, y si el ID está presente, ejecuta una consulta DELETE para eliminar la canción correspondiente en la base de datos. Luego, responde al usuario confirmando que la canción ha sido eliminada exitosamente.

8. config.pl

   Este código es un script en Perl que maneja un formulario web para configurar la conversión de videos. Utiliza CGI para crear la interfaz HTML, donde se pueden seleccionar opciones de conversión de formato, resolución, proporción de imagen y propiedades de audio. Los parámetros del formulario permiten elegir el formato de entrada y salida (como MP4, MP3, AVI), la resolución del video, la proporción de imagen, y la codificación de audio. Cuando el usuario selecciona un video y hace clic en "Convertir", el script ejecuta un comando ffmpeg para realizar la conversión del archivo de video según las opciones seleccionadas. Los resultados se muestran en la página, indicando si la conversión fue exitosa o si hubo errores. Además, genera una lista de videos disponibles en el servidor, permitiendo que el usuario seleccione el video que desea convertir.

9. ver\_canciones.pl

   El script Perl genera una página web que muestra una lista de archivos de un directorio específico dentro de /descargas, cuyo nombre se pasa como parámetro en la URL. Si no se proporciona un nombre de directorio, se usa un valor por defecto. Muestra los archivos en formato de lista HTML, omitiendo los archivos ocultos, y ofrece un enlace para regresar a la página principal.

- init.sql

  Este conjunto de sentencias SQL crea una base de datos llamada mi\_base\_de\_datos si no existe, luego crea un usuario mi\_usuario con contraseña mi\_contraseña, otorgándole todos los privilegios sobre la base de datos. Después, define dos tablas: una para almacenar información de usuarios (usuarios), que incluye campos como nombre, correo, contraseña y teléfono, y otra para gestionar canciones descargadas (canciones), con atributos como nombre, URL, formato y el directorio donde se guarda. Además, ambas tablas tienen campos para registrar la fecha de creación, con restricciones de integridad como![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.007.png) la comprobación de edad mínima en la tabla de usuarios.

- Comandos de construcción del dockerfile

  docker build -t iproyecto .

  docker run -d -p 8092:80 -p 3307:3306 --name cproyecto iproyecto

**VIII. CONCLUSIONES/RECOMENDACIONES**

**Conclusiones**

- Aplicación completa y fácil de usar: La aplicación permite a los usuarios registrarse, iniciar sesión y descargar videos de YouTube de forma sencilla. Además, se pueden convertir los videos a diferentes formatos y gestionar los archivos descargados, todo desde una sola plataforma.
- Interactividad y personalización: Gracias al sistema CRUD, los usuarios pueden cambiar el nombre de las canciones o eliminarlas, lo que les da más control sobre sus descargas. Además, la opción de cambiar las propiedades de los videos (como la resolución y la calidad del audio) es una gran ventaja, ya que hace que los archivos sean aún más personalizados.
- Entretenimiento durante la espera: Una de las cosas que hace que la aplicación sea más divertida es que agregamos juegos básicos en JavaScript. Esto ayuda a que el tiempo de espera para descargar o convertir videos no sea aburrido, lo que mejora la experiencia del usuario.
- Facilidad de uso: La aplicación está diseñada para que los usuarios puedan navegar de forma fácil y rápida. No importa si alguien es nuevo en esto o ya tiene algo de experiencia con las descargas de videos, la interfaz es intuitiva y facilita todo el proceso.
- Tecnologías bien utilizadas: Usar herramientas como CGI, AJAX, FFmpeg y yt-dlp fue clave para que la aplicación funcione de manera eficiente y rápida. Cada tecnología tiene un papel importante y contribuye a que el proceso de descarga y conversión sea fluido.

  **Recomendaciones**

- Mejorar el rendimiento: Aunque la aplicación funciona bien con pocos usuarios, si más personas empiezan a usarla al mismo tiempo, podría volverse más lenta. Sería bueno optimizarla para manejar más tráfico sin que se cuelgue o se demore mucho.
- Más opciones de personalización: Aunque ya hay algunas opciones para cambiar las propiedades de los videos, podría ser útil agregar más características, como elegir diferentes calidades de video o añadir subtítulos si están disponibles.
- Hacer el diseño más atractivo: Aunque la aplicación funciona bien, su diseño podría ser más bonito y moderno. Mejorar la apariencia de los botones, las imágenes y las opciones haría que la aplicación sea más atractiva para los usuarios.
- Agregar más fuentes: Actualmente, la aplicación solo permite descargar de YouTube, pero sería genial agregar otras plataformas, como Vimeo, para que los usuarios tengan más opciones.
- Mejorar la gestión de sesiones: El uso de CGI::Session está bien para la gestión de usuarios, pero en el futuro podríamos pensar en algo más avanzado, como tokens JWT, para manejar las sesiones de una manera más segura y eficiente, especialmente si la aplicación crece y tiene más usuarios.![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.008.png)



|**RÚBRICA DE CALIFICACIÓN**|||||||
| - | :- | :- | :- | :- | :- | :- |
||||||||
|**ÍTEM**|**DESCRIPCIÓN**|**EXCELENTE**|**PROCESO**|**DEFICIENT E**|**AUTO-EVAL UACIÓN**||
|**Código fuente**|Hay porciones de código fuente importantes con numeración y explicaciones detalladas de sus funciones.|4|2|1|3||
|**Ejecución**|Se incluyen ejecuciones/pruebas del código fuente explicadas gradualmente hasta llegar al código final del requerimiento del laboratorio.|4|2|1|4||
|**Pregunta**|<p>Se responde con completitud a la pregunta formulada en la tarea. (El profesor puede preguntar para refrendar calificación).</p><p>Si no se le entregó pregunta, usted recopile información relevante para el laboratorio desde diferentes medios, referenciandola correctamente (máximo 2 caras).</p>|4|2|1|3||
|**Ortografía**|El documento no muestra errores ortográficos.|4|2|1|4||
|**Madurez**|<p>El Informe muestra de manera general una evolución de la madurez del código fuente,</p><p>explicaciones puntuales pero precisas y un acabado impecable. (El profesor puede preguntar para refrendar calificación).</p>|4|2|1|2||
||**CALIFICACIÓN**|20|10|5|16||
||||||||
**REFERENCIAS Y BIBLIOGRAFÍA![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.009.png)**

*CICEI. (n.d.). Tutorial de Perl: Capítulo 6 - Operadores aritméticos. Retrieved from ![](Aspose.Words.ef2d1588-01c8-4089-a7a1-4a02ce65d4f5.010.png)[https://www2.iib.uam.es/bioinfo/curso/perl/tutoriales/cicei/cap6.htm*](https://www2.iib.uam.es/bioinfo/curso/perl/tutoriales/cicei/cap6.htm)*

*Perl 5 Porters. (n.d.). perlop - Perl operators. Retrieved from [https://perldoc.perl.org/perlop* ](https://perldoc.perl.org/perlop)[https://docs.google.com/document/d/1v5hXZU88QdhELTcDjdEpnfZCaej-FnZM/edit#heading=h.gjdgxs ](https://docs.google.com/document/d/1v5hXZU88QdhELTcDjdEpnfZCaej-FnZM/edit#heading=h.gjdgxs)[https://github.com/rescobedoulasalle/docker/tree/main ](https://github.com/rescobedoulasalle/docker/tree/main)<https://github.com/KarlaBedregal/calculadora_CGI/commits/main/>*
