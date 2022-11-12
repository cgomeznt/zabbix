En la WIKI aplicaciones\Diagramas de Arquitectura
Hay un archivo llamado "Inventario_de_Arquitectura.xlsx" que tiene el inventario de las arquitecturas que tiene Soporte Web.
Este inventario ayuda a saber de una arquitectura cual es el nombre del PDF

Abrir el PDF de la arquitectura que se requiera crear el Mapa.
Cuando se abra el PDF con Adobe Acrobat pulsar CTRL-L
Capturar la imagen con Snagit Editor y copiarla.
En Snagit Editor ir al menu y seleccionar Nuevo.
En el pop-up de New Image colocar en Width: 1200 y en Height: 1200
La imagen que ya habiamos copiado la pegamos en esta nueva New Image.
De forma manual la ajustamos a que se visualice bien.
En el Snagit Editor seleccionamos Save As y guardamos la imagen con el mismo nombre del PDF pero en la siguiente ruta:
aplicaciones\Diagramas de Arquitectura\Imagenes
Luego nos vamos al Zabbix en: Administración -> General y en la parte superior derecha buscar images.
Despues de haber seleccionado images, en type seleccionamos Background y pulsar el boton Create Background.
En Name colocar el mismo nombre que se ha utilizado en el PDF y en la Imagen.
Le damos Seleccionar Archivo y buscamos la imagen que anteriormente habiamos cargado.
En el mismo Zabbix nos vamos a Monitoring - Maps - All Maps y pulsamos en el boton de Create Maps.
En el Name le colocamos un nombre simple de asociar con la plataforma, ejemplo (IST 7.3)
En Width  y Height colocar 1200 
En Background image, seleccionamos la imagen de Background que habiamos agregado anteriormente y pulsamos add
En Monitoring - Maps seleccionamos All Maps y buscamos el mapa creado y en la URL veremos el sysmapid, ese es el valor que utilizaremos en el script llamado /usr/local/bin/check_maps.sh

Por ultimo en el el valor obtenido de la URL en sysmapid lo agregamos en el archivo /usr/local/bin/check_maps.sh
Ejempo el sysmapid fue 75

  <td align=center bgcolor=white>IST CCR (7.3)</td>
  <td bgcolor="'$colorcelda75'"' echo '"> <a href="https://zabbix.credicard.com.ve/zabbix.php?action=map.view&sysmapid=75" target="_blank"">'$tipoalerta75'</a> </td>




