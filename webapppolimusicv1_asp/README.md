# SONORA — Song List

Aplicación web tipo reproductor de música, **inspirada en Spotify pero con
identidad visual propia** (violeta profundo + coral + ámbar). Incluye listado de
canciones, reproducción de audio y un CRUD protegido por roles.

> Todos los recursos son originales: el diseño, la paleta, el logotipo y las
> 8 pistas de audio (sintetizadas con Python, sin samples de terceros).

---

## 1. Contenido del proyecto

```
sonora/
├── index.html          Demo navegable (no necesita servidor)
├── login.html          Login de la demo (simula la sesión)
├── login.asp           Login real con Session("username") / Session("role")
├── songs.asp           Listado + CRUD protegido por rol
├── logout.asp          Cierre de sesión (Session.Abandon)
├── css/styles.css      Todo el diseño (paleta, tabla, reproductor, modales)
├── js/app.js           Reproductor, buscador, filtros y CRUD de la demo
├── js/demo-store.js    Datos y persistencia (localStorage) de la demo
├── data/songs.txt      Datos de la versión ASP: id|título|artista|álbum|género|año|duración|emoji|archivo
├── audio/track1-8.wav  Pistas de audio originales
├── tools/gen_audio.py  Script que generó las pistas
├── PROMPT.md           Prompt maestro para reproducir el proyecto
└── docs/               Capturas de referencia
```

## 2. Cuentas de prueba

| Usuario | Contraseña | Rol    | Permisos                                  |
|---------|------------|--------|-------------------------------------------|
| `admin` | `admin123` | admin  | Leer, crear, editar y eliminar canciones  |
| `user`  | `user123`  | normal | Solo leer y reproducir                    |

## 3. Opción A — Demo estática (rápida, sin servidor)

1. Abre `index.html` en el navegador.
2. Te redirige a `login.html`: elige **Administrador** o **Usuario normal**
   (o escribe las credenciales).
3. Listo: verás la bienvenida con tu nombre, el listado y el reproductor.

Si el navegador bloquea el almacenamiento de sesión en `file://`, sirve la
carpeta por HTTP:

```bash
cd sonora
python -m http.server 8000
# abre http://localhost:8000/login.html
```

En esta demo el rol se guarda en `sessionStorage` imitando lo que hace
`Session("username")` en ASP, y las canciones se guardan en `localStorage`
para que el CRUD sea persistente. El botón **Restaurar** devuelve el listado
original.

## 4. Opción B — Versión ASP clásico (la del enunciado)

Requisitos: Windows con **IIS** y la característica **ASP** habilitada.

1. Copia la carpeta `sonora/` dentro de `C:\inetpub\wwwroot\`.
2. Habilita ASP:
   *Panel de control → Programas → Activar o desactivar características de
   Windows → Servicios de Internet Information Server → Servicios de World Wide
   Web → Desarrollo de aplicaciones → ASP*.
3. En el Administrador de IIS, sobre el sitio: **Documento predeterminado** →
   agrega `login.asp` (o navega directamente a
   `http://localhost/sonora/login.asp`).
4. Asigna permisos de **escritura** a la cuenta `IIS_IUSRS` sobre
   `sonora\data\` (el CRUD escribe `songs.txt`).
5. Entra con `admin / admin123` o `user / user123`.

### Cómo funciona la sesión

- `login.asp` valida las credenciales y ejecuta:
  ```asp
  Session("username") = u
  Session("role") = "admin"   ' o "normal"
  ```
- `songs.asp` es la primera línea la que comprueba:
  ```asp
  If Len(Session("username") & "") = 0 Then Response.Redirect "login.asp"
  ```
- La bienvenida se pinta con `Server.HTMLEncode(Session("username"))`.
- `logout.asp` ejecuta `Session.Contents.RemoveAll()` y `Session.Abandon()`.

### Cómo se protege el CRUD

En `songs.asp`, **antes** de renderizar, se comprueba el rol:

```asp
If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    If isAdmin And Len(postAction) > 0 Then
        ' create / update / delete
    End If
End If
```

Si un usuario `normal` intenta enviar el formulario por su cuenta, la petición
se ignora: no basta con ocultar los botones. Además, la clase CSS `admin-only`
y el renderizado condicional `<% If isAdmin Then %>` ocultan las acciones en la
interfaz.

### Dónde se guardan los datos

`data/songs.txt`, un registro por línea:

```
id|título|artista|álbum|género|año|duración|emoji|archivo
1|Neón de Medianoche|Lúmina|Ciudad Eléctrica|Synthpop|2024|0:27|🌃|audio/track1.wav
```

La lectura y escritura usan `ADODB.Stream` con `Charset = "utf-8"` para que los
acentos y los emojis se conserven.

## 5. Funcionalidades de la pantalla de canciones

- **Bienvenida** con el nombre de la sesión y el rol activo (chip ADMIN / USUARIO).
- **Texto de presentación** del listado: «A continuación se presenta el listado
  de canciones — Song List».
- **Tabla HTML** con portada degradada por género, badge de género, año y duración.
- **Reproductor**: play/pausa, anterior, siguiente, progreso con búsqueda,
  volumen, aleatorio y repetir. La fila en reproducción se resalta con una barra
  coral y un ecualizador animado sobre la portada.
- **Buscador en vivo** (título, artista, álbum, género, año) y **filtro por género**.
- **CRUD con modales** (solo admin) y confirmación antes de eliminar.
- **Notificaciones toast** y **atajos**: `Espacio` play/pausa, `Alt + ←/→` cambiar de pista.
- **Responsive**: en pantallas angostas la barra lateral se oculta y el
  reproductor se reorganiza.

## 6. Personalizar los colores

Todo el tema vive en variables CSS al inicio de `css/styles.css`:

```css
:root {
  --bg-0: #0a0613;      /* fondo profundo */
  --accent: #ff5d8f;    /* coral principal */
  --accent-2: #ffb454;  /* ámbar (badges, chip admin) */
  --accent-3: #7c5cff;  /* violeta eléctrico */
  --accent-4: #3fe0c8;  /* turquesa (rol normal) */
  --grad-brand: linear-gradient(120deg, #ff5d8f, #b05cff 55%, #7c5cff);
}
```

Cambia esos valores y toda la interfaz (botones, gradientes, ecualizador,
resaltado de la fila activa) se actualiza sola.

## 7. Regenerar el audio

```bash
python tools/gen_audio.py
```

Genera 8 pistas WAV monofónicas de 24–35 s con progresiones de acordes
distintas. No requiere librerías externas.
