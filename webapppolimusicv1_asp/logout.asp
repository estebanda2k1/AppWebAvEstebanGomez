<%@ Language="VBScript" CodePage="65001" %>
<% Option Explicit %>
<%
' =====================================================================
'  SONORA · logout.asp
'  Destruye la sesión y devuelve al usuario a la pantalla de login
' =====================================================================
Response.Buffer = True
Response.CharSet = "utf-8"

Session.Contents.RemoveAll()
Session.Abandon()

Response.Redirect "login.asp"
Response.End
%>
