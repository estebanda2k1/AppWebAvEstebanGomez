<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' =====================================================================
'  SONORA · songs.asp  (listado de canciones · Song List)
'  - Lee el usuario y el rol desde la sesión creada en login.asp
'  - Solo el rol "admin" puede ejecutar el CRUD (validado en servidor)
'  - Los datos se guardan en data/songs.txt (formato: campos con "|")
' =====================================================================
Response.Buffer = True
Response.CharSet = "utf-8"
Response.CodePage = 65001
Session.CodePage = 65001

' ---------- 1. control de acceso ----------
If Len(Session("username") & "") = 0 Then
    Response.Redirect "login.asp"
    Response.End
End If

Dim currentUser, currentRole, roleLabel, isAdmin
currentUser = Session("username")
currentRole = Session("role")
If Len(currentRole & "") = 0 Then currentRole = "normal"
isAdmin = (LCase(currentRole) = "admin")
If isAdmin Then
    roleLabel = "Administrador"
Else
    roleLabel = "Usuario"
End If

Dim dataFile
dataFile = Server.MapPath("data/songs.txt")

' ---------- 2. funciones auxiliares ----------
Function ReadAllText()
    Dim st
    On Error Resume Next
    ReadAllText = ""
    Set st = Server.CreateObject("ADODB.Stream")
    st.Type = 2
    st.Charset = "utf-8"
    st.Open
    st.LoadFromFile dataFile
    ReadAllText = st.ReadText(-1)
    st.Close
    Set st = Nothing
    On Error GoTo 0
End Function

Sub WriteAllText(txt)
    Dim st
    Set st = Server.CreateObject("ADODB.Stream")
    st.Type = 2
    st.Charset = "utf-8"
    st.Open
    st.WriteText txt
    st.SaveToFile dataFile, 2
    st.Close
    Set st = Nothing
End Sub

Function NormLines(txt)
    Dim s
    s = Replace(txt, vbCrLf, vbLf)
    s = Replace(s, vbCr, vbLf)
    NormLines = s
End Function

Function Sanitize(v)
    Dim s
    s = CStr(v)
    s = Replace(s, "|", " ")
    s = Replace(s, vbCr, " ")
    s = Replace(s, vbLf, " ")
    Sanitize = Trim(s)
End Function

Function FieldOf(line, idx)
    Dim parts
    parts = Split(line, "|")
    If idx <= UBound(parts) Then
        FieldOf = parts(idx)
    Else
        FieldOf = ""
    End If
End Function

Function GenreClass(g)
    Select Case LCase(g)
        Case "pop"
            GenreClass = "g-pop"
        Case "rock"
            GenreClass = "g-rock"
        Case "electrónica", "electronica"
            GenreClass = "g-electro"
        Case "jazz"
            GenreClass = "g-jazz"
        Case "indie"
            GenreClass = "g-indie"
        Case "latina"
            GenreClass = "g-latina"
        Case "acústica", "acustica"
            GenreClass = "g-acustica"
        Case "synthpop"
            GenreClass = "g-synthpop"
        Case Else
            GenreClass = "g-default"
    End Select
End Function

Function SelIf(a, b)
    If LCase(CStr(a)) = LCase(CStr(b)) Then
        SelIf = " selected"
    Else
        SelIf = ""
    End If
End Function

' ---------- 3. CRUD (solo administrador) ----------
Dim allText, lines, i, newText, maxId, newId, rec, postAction
Dim fId, fTitle, fArtist, fAlbum, fGenre, fYear, fEmoji, fFile

postAction = LCase(Sanitize(Request.Form("action")))

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    If isAdmin And Len(postAction) > 0 Then

        allText = NormLines(ReadAllText())
        lines = Split(allText, vbLf)

        If postAction = "create" Or postAction = "update" Then
            fId     = Sanitize(Request.Form("id"))
            fTitle  = Sanitize(Request.Form("title"))
            fArtist = Sanitize(Request.Form("artist"))
            fAlbum  = Sanitize(Request.Form("album"))
            fGenre  = Sanitize(Request.Form("genre"))
            fYear   = Sanitize(Request.Form("year"))
            fEmoji  = Sanitize(Request.Form("emoji"))
            fFile   = Sanitize(Request.Form("file"))

            If Len(fEmoji) = 0 Then fEmoji = "🎵"
            If Len(fAlbum) = 0 Then fAlbum = "-"
            If Len(fYear) = 0 Then fYear = "2025"
            If Len(fFile) = 0 Then fFile = "audio/track1.wav"

            If Len(fTitle) > 0 And Len(fArtist) > 0 Then

                If postAction = "create" Then
                    maxId = 0
                    For i = 0 To UBound(lines)
                        If Len(Trim(lines(i))) > 0 Then
                            If IsNumeric(FieldOf(lines(i), 0)) Then
                                If CLng(FieldOf(lines(i), 0)) > maxId Then
                                    maxId = CLng(FieldOf(lines(i), 0))
                                End If
                            End If
                        End If
                    Next
                    newId = maxId + 1
                    rec = CStr(newId) & "|" & fTitle & "|" & fArtist & "|" & fAlbum & "|" & fGenre & "|" & fYear & "|0:30|" & fEmoji & "|" & fFile
                    newText = Trim(allText)
                    If Len(newText) > 0 Then newText = newText & vbLf
                    WriteAllText newText & rec & vbLf
                Else
                    newText = ""
                    For i = 0 To UBound(lines)
                        If Len(Trim(lines(i))) > 0 Then
                            If FieldOf(lines(i), 0) = fId Then
                                newText = newText & fId & "|" & fTitle & "|" & fArtist & "|" & fAlbum & "|" & fGenre & "|" & fYear & "|" & FieldOf(lines(i), 6) & "|" & fEmoji & "|" & fFile & vbLf
                            Else
                                newText = newText & lines(i) & vbLf
                            End If
                        End If
                    Next
                    WriteAllText newText
                End If

            End If

            Response.Redirect "songs.asp?msg=" & postAction
            Response.End
        End If

        If postAction = "delete" Then
            fId = Sanitize(Request.Form("id"))
            newText = ""
            For i = 0 To UBound(lines)
                If Len(Trim(lines(i))) > 0 Then
                    If FieldOf(lines(i), 0) <> fId Then
                        newText = newText & lines(i) & vbLf
                    End If
                End If
            Next
            WriteAllText newText
            Response.Redirect "songs.asp?msg=deleted"
            Response.End
        End If

    End If
End If

' ---------- 4. mensajes y estado del formulario ----------
Dim msg, msgText, msgType, editingId, modalAction, modalOpen
Dim eTitle, eArtist, eAlbum, eGenre, eYear, eEmoji, eFile

msg = LCase(Sanitize(Request.QueryString("msg")))
msgText = ""
msgType = ""

If msg = "create" Then
    msgText = "Canción agregada al listado correctamente."
ElseIf msg = "update" Then
    msgText = "Canción actualizada correctamente."
ElseIf msg = "deleted" Then
    msgText = "Canción eliminada del listado."
    msgType = "err"
End If

editingId = Sanitize(Request.QueryString("edit"))
modalAction = "create"
eTitle = ""
eArtist = ""
eAlbum = ""
eGenre = "Pop"
eYear = ""
eEmoji = "🎵"
eFile = "audio/track1.wav"

If Len(editingId) > 0 Then
    allText = NormLines(ReadAllText())
    lines = Split(allText, vbLf)
    For i = 0 To UBound(lines)
        If Len(Trim(lines(i))) > 0 Then
            If FieldOf(lines(i), 0) = editingId Then
                eTitle = FieldOf(lines(i), 1)
                eArtist = FieldOf(lines(i), 2)
                eAlbum = FieldOf(lines(i), 3)
                eGenre = FieldOf(lines(i), 4)
                eYear = FieldOf(lines(i), 5)
                eEmoji = FieldOf(lines(i), 7)
                eFile = FieldOf(lines(i), 8)
                modalAction = "update"
            End If
        End If
    Next
End If

If modalAction = "update" Then
    modalOpen = " is-open"
Else
    modalOpen = ""
End If

' ---------- 5. datos para la tabla ----------
allText = NormLines(ReadAllText())
lines = Split(allText, vbLf)
%>
<!DOCTYPE html>
<html lang="es" data-role="<%=currentRole%>">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>SONORA · Song List</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/styles.css">
</head>
<body data-mode="asp" data-role="<%=currentRole%>">

<div class="app">

  <!-- ============================ SIDEBAR ============================ -->
  <aside class="sidebar">
    <div class="brand">
      <svg class="brand-mark" viewBox="0 0 40 40" aria-hidden="true">
        <defs>
          <linearGradient id="bm" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stop-color="#ff5d8f"/>
            <stop offset=".55" stop-color="#b05cff"/>
            <stop offset="1" stop-color="#7c5cff"/>
          </linearGradient>
        </defs>
        <rect x="1" y="1" width="38" height="38" rx="12" fill="url(#bm)"/>
        <g fill="#180a1f">
          <rect x="4"    y="17" width="3.2" height="6"  rx="1.6"/>
          <rect x="8.8"  y="14" width="3.2" height="12" rx="1.6"/>
          <rect x="13.6" y="11" width="3.2" height="18" rx="1.6"/>
          <rect x="18.4" y="9"  width="3.2" height="22" rx="1.6"/>
          <rect x="23.2" y="11" width="3.2" height="18" rx="1.6"/>
          <rect x="28"   y="14" width="3.2" height="12" rx="1.6"/>
          <rect x="32.8" y="17" width="3.2" height="6"  rx="1.6"/>
        </g>
      </svg>
      <span class="brand-name">SONORA</span>
    </div>

    <nav class="nav">
      <a class="nav-item is-active" href="songs.asp">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V21h14V9.5"/><path d="M9.5 21v-6h5v6"/></svg>
        Inicio
      </a>
      <a class="nav-item" href="#lista">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m15.5 8.5-2 5.5-5.5 2 2-5.5z"/></svg>
        Explorar
      </a>
      <a class="nav-item" href="#lista">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5v14"/><path d="M9 5v14"/><path d="M14 5v14"/><path d="m19 5 1.5 14"/></svg>
        Biblioteca
      </a>
    </nav>

    <div>
      <p class="side-title">Tus playlists</p>
      <ul class="playlist">
        <li><a href="#lista"><span class="dot"></span> Favoritas de la semana</a></li>
        <li><a href="#lista"><span class="dot c2"></span> Para programar</a></li>
        <li><a href="#lista"><span class="dot c3"></span> Noche de sintetizadores</a></li>
        <li><a href="#lista"><span class="dot c4"></span> Café &amp; lluvia</a></li>
      </ul>
    </div>

    <div class="side-foot">
      <div class="avatar"><%=UCase(Left(currentUser, 1))%></div>
      <div>
        <p class="side-user"><%=Server.HTMLEncode(currentUser)%></p>
        <p class="side-role"><%=roleLabel%></p>
      </div>
    </div>
  </aside>

  <!-- ============================== MAIN ============================== -->
  <main class="main">

    <header class="topbar">
      <div class="welcome">
        <h1>¡Bienvenido, <span class="hl" id="welcomeUser"><%=Server.HTMLEncode(currentUser)%></span>! 👋</h1>
        <p>Tu sesión está activa como <b><%=roleLabel%></b>. Disfruta de tu biblioteca musical.</p>
      </div>
      <div class="top-actions">
        <span class="chip<% If Not isAdmin Then %> normal<% End If %>" id="roleChip"><% If isAdmin Then %>ADMIN<% Else %>USUARIO<% End If %></span>
        <a class="btn ghost" href="logout.asp" data-action="logout" title="Cerrar sesión">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="m16 17 5-5-5-5"/><path d="M21 12H9"/></svg>
          Cerrar sesión
        </a>
      </div>
    </header>

    <!-- HERO -->
    <section class="hero">
      <div class="hero-text">
        <p class="eyebrow">Biblioteca musical</p>
        <h2>Song List</h2>
        <p class="hero-sub">
          A continuación se presenta el listado de canciones — <strong>Song List</strong> — de tu biblioteca.
          Puedes reproducir cualquier pista, buscar por título, artista, álbum o género; y si tu rol es
          <strong>administrador</strong>, también crear, editar y eliminar registros.
        </p>
        <div class="hero-stats">
          <div class="stat"><b id="statTotal">0</b><span>Canciones</span></div>
          <div class="stat"><b id="statTime">0 min</b><span>Duración</span></div>
          <div class="stat"><b id="statGenres">0</b><span>Géneros</span></div>
        </div>
        <button class="btn primary" id="btnPlayAll">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.14v13.72a1 1 0 0 0 1.52.85l11.14-6.86a1 1 0 0 0 0-1.7L9.52 4.29A1 1 0 0 0 8 5.14z"/></svg>
          Reproducir todo
        </button>
      </div>
      <div class="hero-art">
        <svg viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.9)" stroke-width="1.4" stroke-linecap="round">
          <circle cx="12" cy="12" r="9.2"/>
          <circle cx="12" cy="12" r="2.4"/>
          <path d="M12 2.8v6.8M12 14.4v6.8M2.8 12h6.8M14.4 12h6.8" opacity=".55"/>
        </svg>
      </div>
    </section>

    <!-- ENCABEZADO DEL LISTADO -->
    <div class="section-head" id="lista">
      <div>
        <h3>Listado de canciones</h3>
        <p>Song List · tabla de pistas disponibles en la biblioteca</p>
      </div>
    </div>

    <!-- TOOLBAR -->
    <div class="toolbar">
      <div class="search">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
        <input type="search" id="search" placeholder="Buscar canción, artista, álbum…" autocomplete="off">
      </div>

      <select class="select" id="filterGenre">
        <option value="">Todos los géneros</option>
        <option>Pop</option>
        <option>Rock</option>
        <option>Electrónica</option>
        <option>Jazz</option>
        <option>Indie</option>
        <option>Latina</option>
        <option>Acústica</option>
        <option>Synthpop</option>
      </select>

      <% If isAdmin Then %>
      <button class="btn primary admin-only" id="btnNew">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
        Nueva canción
      </button>
      <% End If %>

      <span class="counter" id="counter"><b>0</b> de <b>0</b> canciones</span>
    </div>

    <!-- TABLA -->
    <div class="table-card">
      <div class="table-wrap">
        <table class="songs">
          <thead>
            <tr>
              <th>#</th>
              <th>Canción</th>
              <th>Álbum</th>
              <th>Género</th>
              <th>Año</th>
              <th>Duración</th>
              <th class="t-right">Acciones</th>
            </tr>
          </thead>
          <tbody id="songRows">
<%
Dim num, ln, idv, tTitle, tArtist, tAlbum, tGenre, tYear, tDur, tEmoji, tFile, gclass, searchStr
num = 0
For Each ln In lines
    If Len(Trim(ln)) > 0 Then
        idv     = FieldOf(ln, 0)
        tTitle  = FieldOf(ln, 1)
        tArtist = FieldOf(ln, 2)
        tAlbum  = FieldOf(ln, 3)
        tGenre  = FieldOf(ln, 4)
        tYear   = FieldOf(ln, 5)
        tDur    = FieldOf(ln, 6)
        tEmoji  = FieldOf(ln, 7)
        tFile   = FieldOf(ln, 8)
        gclass  = GenreClass(tGenre)
        searchStr = LCase(tTitle & " " & tArtist & " " & tAlbum & " " & tGenre & " " & tYear)
        num = num + 1
%>
            <tr data-id="<%=Server.HTMLEncode(idv)%>"
                data-src="<%=Server.HTMLEncode(tFile)%>"
                data-title="<%=Server.HTMLEncode(tTitle)%>"
                data-artist="<%=Server.HTMLEncode(tArtist)%>"
                data-emoji="<%=Server.HTMLEncode(tEmoji)%>"
                data-genre="<%=Server.HTMLEncode(tGenre)%>"
                data-gradient="<%=gclass%>"
                data-duration="<%=Server.HTMLEncode(tDur)%>"
                data-search="<%=Server.HTMLEncode(searchStr)%>">
              <td class="num"><%=Right("0" & num, 2)%></td>
              <td class="c-song">
                <div class="song">
                  <div class="cover <%=gclass%>"><%=tEmoji%>
                    <span class="eq"><i></i><i></i><i></i><i></i></span>
                  </div>
                  <div class="song-meta">
                    <span class="song-title"><%=Server.HTMLEncode(tTitle)%></span>
                    <span class="song-artist"><%=Server.HTMLEncode(tArtist)%></span>
                  </div>
                </div>
              </td>
              <td class="cell-album"><%=Server.HTMLEncode(tAlbum)%></td>
              <td><span class="tag"><%=Server.HTMLEncode(tGenre)%></span></td>
              <td class="year"><%=Server.HTMLEncode(tYear)%></td>
              <td class="dur"><%=Server.HTMLEncode(tDur)%></td>
              <td class="t-right">
                <div class="actions">
                  <button class="icon-btn play" data-action="play" title="Reproducir">
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.14v13.72a1 1 0 0 0 1.52.85l11.14-6.86a1 1 0 0 0 0-1.7L9.52 4.29A1 1 0 0 0 8 5.14z"/></svg>
                  </button>
                  <% If isAdmin Then %>
                  <a class="icon-btn admin-only" href="songs.asp?edit=<%=Server.URLEncode(idv)%>#lista" title="Editar">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/></svg>
                  </a>
                  <form method="post" action="songs.asp" onsubmit="return confirm('¿Eliminar esta canción del listado?');" style="display:inline">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%=Server.HTMLEncode(idv)%>">
                    <button type="submit" class="icon-btn del admin-only" title="Eliminar">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/></svg>
                    </button>
                  </form>
                  <% End If %>
                </div>
              </td>
            </tr>
<%
    End If
Next
%>
          </tbody>
        </table>
      </div>

      <div class="empty" id="empty">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
        <p>No se encontraron canciones con ese criterio de búsqueda.</p>
      </div>
    </div>

  </main>

  <!-- =========================== REPRODUCTOR =========================== -->
  <footer class="player">
    <div class="now">
      <div class="now-cover" id="playerCover">🎧</div>
      <div class="now-meta">
        <p class="now-title" id="playerTitle">Sin reproducción</p>
        <p class="now-artist" id="playerArtist">Selecciona una canción del listado</p>
      </div>
    </div>

    <div class="center-controls">
      <div class="controls">
        <button class="ctrl" id="btnShuffle" title="Aleatorio">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M16 3h5v5"/><path d="M4 20 21 3"/><path d="M21 16v5h-5"/><path d="M15 15l6 6"/><path d="M4 4l5 5"/></svg>
        </button>
        <button class="ctrl" id="btnPrev" title="Anterior">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M18 5.5v13a1 1 0 0 1-1.55.83L8 13.5v5a1 1 0 0 1-2 0v-13a1 1 0 0 1 2 0v5l8.45-5.83A1 1 0 0 1 18 5.5z"/></svg>
        </button>
        <button class="ctrl main" id="btnPlay" title="Reproducir / Pausar">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.14v13.72a1 1 0 0 0 1.52.85l11.14-6.86a1 1 0 0 0 0-1.7L9.52 4.29A1 1 0 0 0 8 5.14z"/></svg>
        </button>
        <button class="ctrl" id="btnNext" title="Siguiente">
          <svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 5.5v13a1 1 0 0 0 1.55.83L16 13.5v5a1 1 0 0 0 2 0v-13a1 1 0 0 0-2 0v5L7.55 4.67A1 1 0 0 0 6 5.5z"/></svg>
        </button>
        <button class="ctrl" id="btnRepeat" title="Repetir">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M17 2l4 4-4 4"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><path d="M7 22l-4-4 4-4"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
        </button>
      </div>
      <div class="progress-row">
        <span class="time" id="timeCur">0:00</span>
        <input type="range" class="slider" id="seek" min="0" max="100" step="0.1" value="0" aria-label="Progreso de la canción">
        <span class="time" id="timeTot">0:00</span>
      </div>
    </div>

    <div class="right-controls">
      <svg class="vol" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M11 5 6 9H3v6h3l5 4z"/><path d="M15.5 8.5a5 5 0 0 1 0 7"/><path d="M18.5 5.5a9 9 0 0 1 0 13"/></svg>
      <div class="vol-wrap">
        <input type="range" class="slider" id="volume" min="0" max="100" step="1" value="78" aria-label="Volumen">
      </div>
    </div>
  </footer>
</div>

<audio id="audio" preload="metadata"></audio>

<% If isAdmin Then %>
<!-- ======================= MODAL CREAR / EDITAR ======================= -->
<div class="modal<%=modalOpen%>" id="modalSong" role="dialog" aria-modal="true">
  <div class="modal-box">
    <div class="modal-head">
      <div>
        <h3 id="modalTitle"><% If modalAction = "update" Then %>Editar canción<% Else %>Nueva canción<% End If %></h3>
        <p id="modalSub"><% If modalAction = "update" Then %>Actualiza los datos de la pista.<% Else %>Agrega una pista al listado.<% End If %></p>
      </div>
      <button class="icon-btn" data-close title="Cerrar">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M6 6l12 12M18 6 6 18"/></svg>
      </button>
    </div>

    <form id="formSong" method="post" action="songs.asp">
      <div class="modal-body">
        <input type="hidden" name="action" id="fAction" value="<%=modalAction%>">
        <input type="hidden" name="id" id="fId" value="<%=Server.HTMLEncode(editingId)%>">

        <div class="field full">
          <label for="fTitle">Título *</label>
          <input id="fTitle" name="title" type="text" placeholder="Ej. Neón de Medianoche" value="<%=Server.HTMLEncode(eTitle)%>" required>
        </div>

        <div class="field">
          <label for="fArtist">Artista *</label>
          <input id="fArtist" name="artist" type="text" placeholder="Ej. Lúmina" value="<%=Server.HTMLEncode(eArtist)%>" required>
        </div>

        <div class="field">
          <label for="fAlbum">Álbum</label>
          <input id="fAlbum" name="album" type="text" placeholder="Ej. Ciudad Eléctrica" value="<%=Server.HTMLEncode(eAlbum)%>">
        </div>

        <div class="field">
          <label for="fGenre">Género</label>
          <select id="fGenre" name="genre">
            <option<%=SelIf(eGenre, "Pop")%>>Pop</option>
            <option<%=SelIf(eGenre, "Rock")%>>Rock</option>
            <option<%=SelIf(eGenre, "Electrónica")%>>Electrónica</option>
            <option<%=SelIf(eGenre, "Jazz")%>>Jazz</option>
            <option<%=SelIf(eGenre, "Indie")%>>Indie</option>
            <option<%=SelIf(eGenre, "Latina")%>>Latina</option>
            <option<%=SelIf(eGenre, "Acústica")%>>Acústica</option>
            <option<%=SelIf(eGenre, "Synthpop")%>>Synthpop</option>
          </select>
        </div>

        <div class="field">
          <label for="fYear">Año</label>
          <input id="fYear" name="year" type="number" min="1900" max="2100" placeholder="2025" value="<%=Server.HTMLEncode(eYear)%>">
        </div>

        <div class="field">
          <label for="fEmoji">Portada (emoji)</label>
          <input id="fEmoji" name="emoji" type="text" maxlength="4" placeholder="🎵" value="<%=Server.HTMLEncode(eEmoji)%>">
        </div>

        <div class="field full">
          <label for="fFile">Archivo de audio</label>
          <select id="fFile" name="file">
            <option value="audio/track1.wav"<%=SelIf(eFile, "audio/track1.wav")%>>track1.wav</option>
            <option value="audio/track2.wav"<%=SelIf(eFile, "audio/track2.wav")%>>track2.wav</option>
            <option value="audio/track3.wav"<%=SelIf(eFile, "audio/track3.wav")%>>track3.wav</option>
            <option value="audio/track4.wav"<%=SelIf(eFile, "audio/track4.wav")%>>track4.wav</option>
            <option value="audio/track5.wav"<%=SelIf(eFile, "audio/track5.wav")%>>track5.wav</option>
            <option value="audio/track6.wav"<%=SelIf(eFile, "audio/track6.wav")%>>track6.wav</option>
            <option value="audio/track7.wav"<%=SelIf(eFile, "audio/track7.wav")%>>track7.wav</option>
            <option value="audio/track8.wav"<%=SelIf(eFile, "audio/track8.wav")%>>track8.wav</option>
          </select>
        </div>
      </div>

      <div class="modal-foot">
        <a class="btn ghost" href="songs.asp">Cancelar</a>
        <button type="submit" class="btn primary">Guardar canción</button>
      </div>
    </form>
  </div>
</div>
<% End If %>

<div class="toast" id="toast"></div>

<script src="js/app.js"></script>
<% If Len(msgText) > 0 Then %>
<script>
  window.addEventListener('load', function () {
    if (window.sonoraToast) { window.sonoraToast('<%=msgText%>', '<%=msgType%>'); }
  });
</script>
<% End If %>
</body>
</html>
