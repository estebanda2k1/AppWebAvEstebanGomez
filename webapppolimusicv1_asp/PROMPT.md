# PROMPT MAESTRO — Clon de Spotify con roles y CRUD (ASP + HTML/CSS/JS)

> Copia y pega este prompt completo en cualquier asistente de IA para reproducir
> el proyecto desde cero. Es el mismo prompt que se usó para construir SONORA.

---

## 1. Rol

Actúa como **desarrollador web full-stack senior** especializado en interfaces de
producto y en **ASP clásico (VBScript)**. Escribe código completo, funcional y
comentado en español. No uses frameworks: solo **HTML5 + CSS3 + JavaScript
vanilla** y, para la capa de servidor, **ASP clásico** con variables de sesión.

## 2. Objetivo

Construir una aplicación web tipo **reproductor de música (inspirada en Spotify,
pero con identidad visual propia)** cuya pantalla principal sea el **listado de
canciones**. La aplicación debe manejar **dos roles** (normal y administrador) y
permitir el **CRUD de canciones únicamente al rol administrador**.

> Importante: no copies logotipos, marcas, tipografías registradas ni recursos
> gráficos de Spotify. El diseño, la paleta, el nombre del producto y los audios
> deben ser originales.

## 3. Stack y estructura

- **Front-end:** `index.html` (demo navegable) + `css/styles.css` + `js/app.js`
- **Back-end:** `login.asp`, `songs.asp`, `logout.asp` (ASP clásico / VBScript)
- **Datos:** `data/songs.txt` (registros separados por `|`)
- **Audio:** carpeta `audio/` con pistas libres de derechos (o sintetizadas)
- **Sesión:** `Session("username")` y `Session("role")`

## 4. Requisitos funcionales (obligatorios)

1. **Dos roles:** `normal` y `admin`.
2. **CRUD solo para admin:** crear, leer, actualizar y eliminar canciones.
   El rol `normal` solo puede **leer y reproducir**. La restricción debe
   validarse **en el servidor** (`If isAdmin Then ...`), no solo ocultando botones.
3. **Diseño original:** colores propios (no el verde de Spotify), layout con
   barra lateral, encabezado, hero, tabla y reproductor inferior fijo.
4. **Mensaje de bienvenida con el nombre del usuario logueado**, leído desde la
   variable de sesión que se guardó en `login.asp`:
   `¡Bienvenido, <nombre>!`.
5. **Cierre de sesión (logout):** destruye la sesión (`Session.Abandon()`) y
   redirige a `login.asp`.
6. **Texto que anuncia el listado:** un párrafo visible que diga
   «A continuación se presenta el listado de canciones — Song List».
7. **Tabla HTML con estilos CSS propios:** columnas #, canción (portada + título
   + artista), álbum, género, año, duración y acciones.
8. **Reproducción de las canciones:** reproductor con play/pausa, anterior,
   siguiente, barra de progreso, volumen, aleatorio y repetir; resalta la fila
   que se está reproduciendo con un ecualizador animado.
9. **Extras deseables:** buscador en vivo, filtro por género, contadores,
   notificaciones tipo *toast*, modales para crear/editar y confirmar borrado,
   diseño responsive.

## 5. Diseño

- **Paleta:** violeta profundo de fondo (`#0a0613`, `#110b1f`), coral
  (`#ff5d8f`), ámbar (`#ffb454`), violeta eléctrico (`#7c5cff`) y turquesa
  (`#3fe0c8`) como acento secundario.
- **Tipografía:** *Sora* para títulos, *Inter* para texto, monoespaciada para
  números, duraciones y años.
- **Estilo:** glassmorphism sutil, bordes de 1px translúcidos, degradados
  radiales de fondo, sombras profundas, radios de 14–28px.
- **Componentes:** sidebar con logo y playlists, topbar con bienvenida y chip de
  rol, hero con estadísticas, toolbar (buscador + filtro + botón «Nueva
  canción»), tabla con cabecera fija, reproductor inferior y modales.

## 6. Modelo de datos

Cada canción: `id | título | artista | álbum | género | año | duración | emoji
| archivo de audio`.

Usuarios de prueba:

| Usuario | Contraseña | Rol    |
|---------|-----------|--------|
| admin   | admin123  | admin  |
| user    | user123   | normal |

## 7. Entregables

1. `login.asp` — formulario que valida credenciales y guarda la sesión.
2. `songs.asp` — listado + CRUD protegido por rol + reproductor.
3. `logout.asp` — cierre de sesión.
4. `index.html` + `login.html` — demo estática equivalente, sin servidor.
5. `css/styles.css`, `js/app.js`, `data/songs.txt`, `audio/`.
6. `README.md` con instrucciones de instalación en IIS.

## 8. Criterios de aceptación

- [ ] Al entrar como `user` no aparece ningún botón de crear/editar/eliminar.
- [ ] Al entrar como `admin` aparecen las tres acciones y funcionan.
- [ ] La bienvenida muestra exactamente el usuario con el que se inició sesión.
- [ ] «Cerrar sesión» vuelve al login y `songs.asp` deja de ser accesible.
- [ ] La tabla muestra todas las canciones con estilos aplicados.
- [ ] Al pulsar play suena la canción y la fila queda resaltada.
- [ ] El buscador y el filtro por género reducen la tabla sin recargar.
