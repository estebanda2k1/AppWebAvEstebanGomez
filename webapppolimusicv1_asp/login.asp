<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' =====================================================================
'  SONORA · login.asp
'  Valida credenciales y guarda el usuario y el rol en variables de sesión
'  (Session("username") y Session("role")), que luego se leen en songs.asp
' =====================================================================
Response.Buffer = True
Response.CharSet = "utf-8"
Response.CodePage = 65001

Dim u, p, errMsg
errMsg = ""

' Si ya hay sesión activa, ir directo al listado
If Len(Session("username") & "") > 0 And Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
    Response.Redirect "songs.asp"
    Response.End
End If

If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
    u = Trim(Request.Form("username"))
    p = Trim(Request.Form("password"))

    If LCase(u) = "admin" And p = "admin123" Then
        Session("username") = u
        Session("role") = "admin"
        Response.Redirect "songs.asp"
        Response.End
    ElseIf LCase(u) = "user" And p = "user123" Then
        Session("username") = u
        Session("role") = "normal"
        Response.Redirect "songs.asp"
        Response.End
    Else
        errMsg = "Usuario o contraseña incorrectos. Verifica tus datos e inténtalo de nuevo."
    End If
End If
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>SONORA · Iniciar sesión</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/styles.css">
</head>
<body>

<div class="auth">
  <div class="auth-card">
    <div class="auth-brand">
      <svg class="brand-mark" viewBox="0 0 40 40" aria-hidden="true">
        <defs>
          <linearGradient id="bm2" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stop-color="#ff5d8f"/>
            <stop offset=".55" stop-color="#b05cff"/>
            <stop offset="1" stop-color="#7c5cff"/>
          </linearGradient>
        </defs>
        <rect x="1" y="1" width="38" height="38" rx="12" fill="url(#bm2)"/>
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

    <h1>Iniciar sesión</h1>
    <p class="lead">Accede a tu biblioteca. El rol de tu cuenta determina<br>si puedes administrar el listado de canciones.</p>

    <div class="alert<% If Len(errMsg) > 0 Then %> show<% End If %>" id="alert">
      <%=Server.HTMLEncode(errMsg)%>
    </div>

    <form method="post" action="login.asp" autocomplete="off">
      <div class="field">
        <label for="username">Usuario</label>
        <input id="username" name="username" type="text" placeholder="admin" required>
      </div>
      <div class="field">
        <label for="password">Contraseña</label>
        <input id="password" name="password" type="password" placeholder="••••••••" required>
      </div>
      <button class="btn primary" type="submit">Entrar a SONORA</button>
    </form>

    <div class="demo-accounts">
      <p>Cuentas de prueba</p>
      <div class="demo-grid">
        <div class="demo-btn" style="cursor:default">
          <b>Administrador</b>
          <span>admin / admin123</span>
        </div>
        <div class="demo-btn" style="cursor:default">
          <b>Usuario normal</b>
          <span>user / user123</span>
        </div>
      </div>
    </div>
  </div>
</div>

</body>
</html>
