<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>
<html lang="es" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic | Canciones</title>
    <style>
        :root {
            --background: #090b12;
            --surface: #121621;
            --surface-raised: #1a2030;
            --line: rgba(255,255,255,.09);
            --muted: #8e98ac;
            --text: #f7f8fb;
            --accent: #9b7bff;
            --accent-strong: #c3adff;
            --shadow: 0 24px 70px rgba(0,0,0,.35);
        }

        * { box-sizing: border-box; }
        html, body { min-height: 100%; }
        body {
            margin: 0;
            background: radial-gradient(circle at 80% -10%, #27203f 0, transparent 32rem), var(--background);
            color: var(--text);
            font-family: "Segoe UI", Arial, sans-serif;
        }
        a { color: inherit; text-decoration: none; }
        button, input { font: inherit; }
        .app-shell { display: flex; min-height: 100vh; }
        .sidebar {
            align-items: flex-start;
            background: rgba(10,12,19,.78);
            border-right: 1px solid var(--line);
            display: flex;
            flex-direction: column;
            padding: 28px 20px;
            position: fixed;
            top: 0; bottom: 0; left: 0;
            width: 248px;
        }
        .brand { align-items: center; display: flex; gap: 11px; margin: 0 10px 52px; }
        .brand-mark {
            align-items: center;
            background: linear-gradient(135deg, var(--accent), #6f5dd9);
            border-radius: 12px;
            box-shadow: 0 8px 26px rgba(155,123,255,.3);
            display: flex;
            font-size: 19px;
            font-weight: 800;
            height: 38px;
            justify-content: center;
            width: 38px;
        }
        .brand-name { font-size: 19px; font-weight: 700; letter-spacing: -.5px; }
        .nav-label { color: #647087; font-size: 10px; font-weight: 700; letter-spacing: 1.6px; margin: 0 12px 13px; text-transform: uppercase; }
        .nav-link {
            align-items: center;
            border-radius: 11px;
            color: var(--muted);
            display: flex;
            gap: 13px;
            margin: 3px 0;
            padding: 12px;
            transition: .2s ease;
        }
        .nav-link:hover, .nav-link.active { background: rgba(155,123,255,.14); color: var(--text); }
        .nav-link.active { box-shadow: inset 3px 0 var(--accent); color: var(--accent-strong); }
        .nav-icon { font-size: 17px; width: 20px; }
        .sidebar-footer { border-top: 1px solid var(--line); margin-top: auto; padding: 20px 10px 0; width: 100%; }
        .logout { color: #aab3c5; display: inline-flex; gap: 10px; font-size: 13px; }
        .main { margin-left: 248px; max-width: 1440px; padding: 30px 5%; width: calc(100% - 248px); }
        .sr-only { height: 1px; margin: -1px; overflow: hidden; position: absolute; width: 1px; clip: rect(0,0,0,0); }
        .topbar { align-items: center; display: flex; gap: 22px; justify-content: space-between; margin-bottom: 48px; }
        .welcome small { color: var(--muted); display: block; font-size: 13px; margin-bottom: 7px; }
        .welcome h1 { font-size: clamp(26px, 3vw, 38px); letter-spacing: -1.5px; margin: 0; }
        .profile { align-items: center; display: flex; gap: 12px; }
        .profile img { border: 2px solid rgba(255,255,255,.18); border-radius: 50%; height: 42px; object-fit: cover; width: 42px; }
        .profile strong { display: block; font-size: 13px; }
        .profile span { color: var(--muted); font-size: 11px; }
        .hero {
            background: linear-gradient(120deg, #282047, #1a2035 58%, #131824);
            border: 1px solid rgba(195,173,255,.18);
            border-radius: 24px;
            box-shadow: var(--shadow);
            display: flex;
            justify-content: space-between;
            margin-bottom: 34px;
            min-height: 190px;
            overflow: hidden;
            padding: 30px 34px;
            position: relative;
        }
        .hero:after { border: 1px solid rgba(255,255,255,.08); border-radius: 50%; content: ""; height: 260px; position: absolute; right: 7%; top: -110px; width: 260px; }
        .hero-copy { max-width: 530px; position: relative; z-index: 1; }
        .eyebrow { color: var(--accent-strong); font-size: 11px; font-weight: 700; letter-spacing: 1.6px; text-transform: uppercase; }
        .hero h2 { font-size: clamp(23px, 3vw, 34px); letter-spacing: -1.2px; margin: 13px 0 9px; }
        .hero p { color: #bac0d0; font-size: 14px; margin: 0; }
        .hero-notes { align-items: center; display: flex; gap: 12px; position: relative; z-index: 1; }
        .note { align-items: center; background: rgba(255,255,255,.07); border-radius: 50%; display: flex; font-size: 18px; height: 47px; justify-content: center; width: 47px; }
        .section-head { align-items: end; display: flex; justify-content: space-between; margin-bottom: 18px; }
        .section-head h2 { font-size: 21px; margin: 0; }
        .section-head p { color: var(--muted); font-size: 12px; margin: 0; }
        .search {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 10px;
            color: var(--text);
            outline: 0;
            padding: 11px 14px 11px 38px;
            width: min(230px, 42vw);
        }
        .search:focus { border-color: var(--accent); }
        .search-wrap { position: relative; }
        .search-wrap:before { color: var(--muted); content: "⌕"; font-size: 21px; left: 12px; position: absolute; top: 5px; }
        .song-list { display: grid; gap: 12px; }
        .song-card {
            align-items: center;
            background: rgba(18,22,33,.88);
            border: 1px solid var(--line);
            border-radius: 16px;
            display: grid;
            gap: 18px;
            grid-template-columns: 34px 52px minmax(150px, 1fr) minmax(180px, 1.2fr) 70px;
            padding: 12px 16px 12px 12px;
            transition: border-color .2s, transform .2s, background .2s;
        }
        .song-card:hover { background: var(--surface-raised); border-color: rgba(195,173,255,.35); transform: translateY(-2px); }
        .cover { border-radius: 11px; height: 52px; object-fit: cover; width: 52px; }
        .song-title { font-size: 14px; font-weight: 700; margin: 0 0 4px; }
        .song-meta, .song-index { color: var(--muted); font-size: 12px; }
        .audio-wrap audio { height: 34px; max-width: 100%; width: 100%; }
        .plays { color: var(--muted); font-size: 12px; text-align: right; }
        .plays strong { color: var(--text); display: block; font-size: 15px; margin-bottom: 2px; }
        .empty { color: var(--muted); padding: 40px; text-align: center; }
        .now-playing {
            align-items: center;
            background: rgba(20,24,36,.94);
            border: 1px solid rgba(195,173,255,.2);
            border-radius: 15px;
            bottom: 22px;
            box-shadow: var(--shadow);
            display: flex;
            gap: 13px;
            opacity: 0;
            padding: 11px 16px;
            pointer-events: none;
            position: fixed;
            right: 28px;
            transform: translateY(15px);
            transition: .25s ease;
            z-index: 3;
        }
        .now-playing.visible { opacity: 1; pointer-events: auto; transform: translateY(0); }
        .now-playing-icon { color: var(--accent-strong); font-size: 18px; }
        .now-playing small { color: var(--muted); display: block; font-size: 10px; }
        .now-playing strong { display: block; font-size: 12px; max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        @media (max-width: 800px) {
            .sidebar { height: 65px; padding: 12px 16px; width: 100%; z-index: 2; }
            .brand { margin: 0; }
            .brand-name, .nav-label, .nav-link span, .sidebar-footer { display: none; }
            .sidebar nav { display: flex; gap: 4px; position: absolute; right: 14px; top: 10px; }
            .nav-link { margin: 0; padding: 10px; }
            .main { margin-left: 0; padding: 96px 5% 110px; width: 100%; }
            .topbar { margin-bottom: 30px; }
            .hero { min-height: 170px; padding: 24px; }
            .hero-notes { display: none; }
            .song-card { grid-template-columns: 26px 46px 1fr 54px; }
            .cover { height: 46px; width: 46px; }
            .audio-wrap { grid-column: 3 / 5; }
            .plays { grid-column: 4; grid-row: 1; }
        }
        @media (max-width: 480px) {
            .profile div { display: none; }
            .section-head { align-items: stretch; flex-direction: column; gap: 14px; }
            .search { width: 100%; }
            .search-wrap { width: 100%; }
            .song-card { gap: 11px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="app-shell">
            <aside class="sidebar">
                <a class="brand" href="Song.aspx" aria-label="PoliMusic, inicio">
                    <span class="brand-mark">♫</span>
                    <span class="brand-name">PoliMusic</span>
                </a>
                <nav aria-label="Navegación principal">
                    <p class="nav-label">Biblioteca</p>
                    <a class="nav-link active" href="Song.aspx"><span class="nav-icon">◉</span><span>Canciones</span></a>
                    <a class="nav-link" href="Song.aspx#playlist"><span class="nav-icon">▣</span><span>Playlists</span></a>
                </nav>
                <div class="sidebar-footer">
                    <a class="logout" href="Logout.aspx"><span>↪</span> Cerrar sesión</a>
                </div>
            </aside>

            <main class="main">
                <header class="topbar">
                    <div class="welcome">
                        <small>Tu espacio musical</small>
                        <h1>Hola, <asp:Literal ID="litUserName" runat="server" /> <span aria-hidden="true">✦</span></h1>
                    </div>
                    <div class="profile">
                        <asp:Image ID="imgUser" runat="server" AlternateText="Foto de perfil" />
                        <div><strong><asp:Literal ID="litProfileName" runat="server" /></strong><span>Oyente PoliMusic</span></div>
                    </div>
                </header>

                <section class="hero" aria-labelledby="hero-title">
                    <div class="hero-copy">
                        <span class="eyebrow">Descubre tu próxima canción</span>
                        <h2 id="hero-title">Tu música, tu momento.</h2>
                        <p>Explora la biblioteca y dale play a las canciones que te acompañan hoy.</p>
                    </div>
                    <div class="hero-notes" aria-hidden="true"><span class="note">♪</span><span class="note">♫</span><span class="note">♩</span></div>
                </section>

                <section aria-labelledby="songs-title">
                    <div class="section-head">
                        <div><h2 id="songs-title">Todas las canciones</h2><p><asp:Literal ID="litSongCount" runat="server" /> disponibles para escuchar</p></div>
                        <div class="search-wrap"><label class="sr-only" for="songSearch">Buscar canciones</label><input id="songSearch" class="search" type="search" placeholder="Buscar canción..." autocomplete="off" /></div>
                    </div>
                    <div id="songList" class="song-list">
                        <asp:Literal ID="litSongs" runat="server" />
                    </div>
                </section>
            </main>
        </div>
        <div id="nowPlaying" class="now-playing" aria-live="polite">
            <span class="now-playing-icon">♫</span>
            <div><small>Reproduciendo ahora</small><strong id="nowPlayingTitle">-</strong></div>
        </div>
    </form>
    <script>
        (function () {
            var search = document.getElementById("songSearch");
            var cards = document.querySelectorAll(".song-card");
            var nowPlaying = document.getElementById("nowPlaying");
            var nowPlayingTitle = document.getElementById("nowPlayingTitle");

            function findCard(element) {
                while (element && element !== document) {
                    if ((" " + element.className + " ").indexOf(" song-card ") !== -1) {
                        return element;
                    }
                    element = element.parentNode;
                }
                return null;
            }

            function updateNowPlaying(audio) {
                var card = findCard(audio);
                var title = card ? card.querySelector(".song-title") : null;
                if (title) {
                    nowPlayingTitle.textContent = title.textContent;
                    nowPlaying.classList.add("visible");
                }
            }

            Array.prototype.forEach.call(document.querySelectorAll(".song-card audio"), function (audio) {
                audio.addEventListener("play", function () {
                    Array.prototype.forEach.call(document.querySelectorAll(".song-card audio"), function (other) {
                        if (other !== audio) { other.pause(); }
                    });
                    updateNowPlaying(audio);
                });
                audio.addEventListener("ended", function () { nowPlaying.classList.remove("visible"); });
            });

            search.addEventListener("input", function () {
                var query = search.value.toLowerCase().trim();
                Array.prototype.forEach.call(cards, function (card) {
                    card.hidden = query && card.getAttribute("data-title").indexOf(query) === -1;
                });
            });
        }());
    </script>
</body>
</html>
