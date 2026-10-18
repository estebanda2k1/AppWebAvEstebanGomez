/* ============================================================
   SONORA · app.js
   Reproductor + filtros + CRUD (modo demo y modo ASP)
   ============================================================ */
(function () {
  'use strict';

  var $ = function (sel, root) { return (root || document).querySelector(sel); };
  var $$ = function (sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); };

  var body = document.body;
  var isDemo = body.getAttribute('data-mode') === 'demo';
  var role = document.documentElement.getAttribute('data-role') || body.getAttribute('data-role') || 'normal';
  var isAdmin = role === 'admin';

  /* ==========================================================
     SESIÓN (demo: simula Session("username") de login.asp)
     ========================================================== */
  function getSession() {
    if (window.SONORA_SESSION) return window.SONORA_SESSION;
    try {
      var raw = sessionStorage.getItem('sonora_session');
      if (raw) return JSON.parse(raw);
    } catch (e) {}
    return { username: 'admin', role: 'admin' };
  }

  var session = getSession();

  function paintSession() {
    if (!isDemo) return; // en la versión ASP el servidor ya pintó los datos de sesión
    var label = session.role === 'admin' ? 'Administrador' : 'Usuario';
    $$('[data-bind="user"]').forEach(function (el) { el.textContent = session.username; });
    $$('[data-bind="role"]').forEach(function (el) { el.textContent = label; });
    $$('[data-bind="initial"]').forEach(function (el) {
      el.textContent = (session.username || '?').charAt(0).toUpperCase();
    });
    var chip = $('#roleChip');
    if (chip) {
      chip.textContent = session.role === 'admin' ? 'ADMIN' : 'USUARIO';
      chip.classList.toggle('normal', session.role !== 'admin');
    }
  }

  /* ==========================================================
     TOAST
     ========================================================== */
  var toastEl = $('#toast');
  var toastTimer = null;

  function toast(msg, type) {
    if (!toastEl) return;
    toastEl.textContent = msg;
    toastEl.className = 'toast show' + (type ? ' ' + type : '');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toastEl.className = 'toast'; }, 2800);
  }

  window.sonoraToast = toast;

  /* ==========================================================
     REPRODUCTOR
     ========================================================== */
  var audio = $('#audio');
  var currentRow = null;
  var shuffle = false;
  var repeat = false;

  var ICON_PLAY = '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5.14v13.72a1 1 0 0 0 1.52.85l11.14-6.86a1 1 0 0 0 0-1.7L9.52 4.29A1 1 0 0 0 8 5.14z"/></svg>';
  var ICON_PAUSE = '<svg viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="4.5" width="4.2" height="15" rx="1.4"/><rect x="13.8" y="4.5" width="4.2" height="15" rx="1.4"/></svg>';

  function rows() { return $$('#songRows tr'); }

  function rowInfo(tr) {
    return {
      id: tr.getAttribute('data-id'),
      src: tr.getAttribute('data-src'),
      title: tr.getAttribute('data-title'),
      artist: tr.getAttribute('data-artist'),
      emoji: tr.getAttribute('data-emoji') || '🎵',
      genre: tr.getAttribute('data-genre') || 'Pop',
      gradient: tr.getAttribute('data-gradient') || 'g-default'
    };
  }

  function genreClass(genre) {
    var map = {
      'Pop': 'g-pop', 'Rock': 'g-rock', 'Electrónica': 'g-electro', 'Electronica': 'g-electro',
      'Jazz': 'g-jazz', 'Indie': 'g-indie', 'Latina': 'g-latina', 'Acústica': 'g-acustica',
      'Acustica': 'g-acustica', 'Synthpop': 'g-synthpop'
    };
    return map[genre] || 'g-default';
  }

  function fmtTime(s) {
    if (!isFinite(s) || s < 0) s = 0;
    var m = Math.floor(s / 60);
    var r = Math.floor(s % 60);
    return m + ':' + (r < 10 ? '0' : '') + r;
  }

  function paintSlider(el, pct) {
    if (!el) return;
    pct = Math.max(0, Math.min(100, pct));
    el.value = pct;
    el.style.background =
      'linear-gradient(90deg, var(--accent) 0%, var(--accent) ' + pct + '%, rgba(255,255,255,0.14) ' + pct + '%, rgba(255,255,255,0.14) 100%)';
  }

  function markPlaying(tr) {
    $$('#songRows tr.is-playing').forEach(function (r) { r.classList.remove('is-playing'); });
    if (tr) tr.classList.add('is-playing');
    var btn = $('#btnPlay');
    if (btn) btn.innerHTML = (audio && !audio.paused) ? ICON_PAUSE : ICON_PLAY;
  }

  function loadSong(tr, autoplay) {
    if (!tr || !audio) return;
    var info = rowInfo(tr);
    currentRow = tr;

    audio.src = info.src;
    audio.load();

    var cover = $('#playerCover');
    if (cover) {
      cover.textContent = info.emoji;
      cover.className = 'now-cover ' + info.gradient;
    }
    var t = $('#playerTitle');
    var a = $('#playerArtist');
    if (t) t.textContent = info.title;
    if (a) a.textContent = info.artist;

    markPlaying(tr);
    paintSlider($('#seek'), 0);
    var cur = $('#timeCur');
    if (cur) cur.textContent = '0:00';

    if (autoplay) {
      var p = audio.play();
      if (p && p.catch) p.catch(function () {});
    }
  }

  function togglePlay() {
    if (!audio) return;
    if (!currentRow) {
      var first = rows()[0];
      if (first) { loadSong(first, true); return; }
      toast('No hay canciones en el listado', 'warn');
      return;
    }
    if (audio.paused) {
      var p = audio.play();
      if (p && p.catch) p.catch(function () {});
    } else {
      audio.pause();
    }
  }

  function step(dir) {
    var list = rows();
    if (!list.length) return;
    var idx = currentRow ? list.indexOf(currentRow) : -1;

    if (shuffle) {
      var r = idx;
      while (list.length > 1 && r === idx) r = Math.floor(Math.random() * list.length);
      loadSong(list[r], true);
      return;
    }

    var next = idx + dir;
    if (next < 0) next = list.length - 1;
    if (next >= list.length) next = 0;
    loadSong(list[next], true);
  }

  if (audio) {
    audio.addEventListener('play', function () {
      markPlaying(currentRow);
      var btn = $('#btnPlay');
      if (btn) btn.innerHTML = ICON_PAUSE;
    });

    audio.addEventListener('pause', function () {
      var btn = $('#btnPlay');
      if (btn) btn.innerHTML = ICON_PLAY;
    });

    audio.addEventListener('timeupdate', function () {
      var pct = audio.duration ? (audio.currentTime / audio.duration) * 100 : 0;
      paintSlider($('#seek'), pct);
      var cur = $('#timeCur');
      if (cur) cur.textContent = fmtTime(audio.currentTime);
      var tot = $('#timeTot');
      if (tot) tot.textContent = fmtTime(audio.duration);
    });

    audio.addEventListener('loadedmetadata', function () {
      var tot = $('#timeTot');
      if (tot) tot.textContent = fmtTime(audio.duration);
    });

    audio.addEventListener('ended', function () {
      if (repeat) { audio.play(); return; }
      step(1);
    });

    audio.addEventListener('error', function () {
      toast('No se pudo cargar el audio de la pista', 'err');
    });
  }

  /* ---- controles globales ---- */
  var btnPlay = $('#btnPlay');
  if (btnPlay) btnPlay.addEventListener('click', togglePlay);

  var btnPrev = $('#btnPrev');
  if (btnPrev) btnPrev.addEventListener('click', function () { step(-1); });

  var btnNext = $('#btnNext');
  if (btnNext) btnNext.addEventListener('click', function () { step(1); });

  var seek = $('#seek');
  if (seek) {
    seek.addEventListener('input', function () {
      if (!audio || !audio.duration) return;
      audio.currentTime = (seek.value / 100) * audio.duration;
      paintSlider(seek, seek.value);
    });
  }

  var vol = $('#volume');
  if (vol) {
    var savedVol = Number(localStorage.getItem('sonora_vol'));
    var initial = isFinite(savedVol) && savedVol > 0 ? savedVol : 78;
    if (audio) audio.volume = initial / 100;
    paintSlider(vol, initial);
    vol.addEventListener('input', function () {
      var v = Number(vol.value);
      if (audio) audio.volume = v / 100;
      paintSlider(vol, v);
      try { localStorage.setItem('sonora_vol', String(v)); } catch (e) {}
    });
  }

  var btnShuffle = $('#btnShuffle');
  if (btnShuffle) {
    btnShuffle.addEventListener('click', function () {
      shuffle = !shuffle;
      btnShuffle.classList.toggle('is-on', shuffle);
      toast(shuffle ? 'Aleatorio activado' : 'Aleatorio desactivado');
    });
  }

  var btnRepeat = $('#btnRepeat');
  if (btnRepeat) {
    btnRepeat.addEventListener('click', function () {
      repeat = !repeat;
      btnRepeat.classList.toggle('is-on', repeat);
      if (audio) audio.loop = repeat;
      toast(repeat ? 'Repetir activado' : 'Repetir desactivado');
    });
  }

  /* ---- play all ---- */
  var btnPlayAll = $('#btnPlayAll');
  if (btnPlayAll) {
    btnPlayAll.addEventListener('click', function () {
      var list = rows();
      if (!list.length) { toast('No hay canciones para reproducir', 'warn'); return; }
      loadSong(list[0], true);
      toast('Reproduciendo la lista completa');
    });
  }

  /* ---- click en la tabla ---- */
  document.addEventListener('click', function (ev) {
    var btn = ev.target.closest ? ev.target.closest('[data-action="play"]') : null;
    if (btn) {
      var tr = btn.closest('tr');
      if (tr === currentRow && audio && !audio.paused) {
        audio.pause();
      } else if (tr === currentRow && audio && audio.paused) {
        audio.play();
      } else {
        loadSong(tr, true);
      }
      return;
    }

    // doble clic en cualquier parte de la fila = reproducir
    var row = ev.target.closest ? ev.target.closest('#songRows tr') : null;
    if (row && ev.target.closest('a,form,button,input,select')) return;
    if (row) loadSong(row, true);
  });

  document.addEventListener('dblclick', function (ev) {
    var row = ev.target.closest ? ev.target.closest('#songRows tr') : null;
    if (row) loadSong(row, true);
  });

  /* ---- teclado ---- */
  document.addEventListener('keydown', function (ev) {
    var tag = (ev.target.tagName || '').toLowerCase();
    if (tag === 'input' || tag === 'textarea' || tag === 'select') return;
    if (ev.code === 'Space') { ev.preventDefault(); togglePlay(); }
    if (ev.code === 'ArrowRight' && ev.altKey) { ev.preventDefault(); step(1); }
    if (ev.code === 'ArrowLeft' && ev.altKey) { ev.preventDefault(); step(-1); }
  });

  /* ==========================================================
     BUSCADOR Y FILTROS
     ========================================================== */
  var searchInput = $('#search');
  var genreSelect = $('#filterGenre');
  var counter = $('#counter');
  var empty = $('#empty');

  function applyFilters() {
    var q = (searchInput ? searchInput.value : '').trim().toLowerCase();
    var g = genreSelect ? genreSelect.value : '';
    var visible = 0;

    rows().forEach(function (tr) {
      var txt = (tr.getAttribute('data-search') || tr.textContent).toLowerCase();
      var genre = tr.getAttribute('data-genre') || '';
      var ok = (!q || txt.indexOf(q) !== -1) && (!g || genre === g);
      tr.style.display = ok ? '' : 'none';
      if (ok) {
        visible++;
        var num = tr.querySelector('.num');
        if (num) num.textContent = String(visible).padStart(2, '0');
      }
    });

    if (empty) empty.classList.toggle('show', visible === 0);

    if (counter) {
      counter.innerHTML = '<b>' + visible + '</b> de <b>' + rows().length + '</b> canciones';
    }
  }

  if (searchInput) searchInput.addEventListener('input', applyFilters);
  if (genreSelect) genreSelect.addEventListener('change', applyFilters);

  /* ==========================================================
     ESTADÍSTICAS DEL HERO
     ========================================================== */
  function toSeconds(str) {
    var p = String(str || '0:00').split(':');
    return (Number(p[0]) || 0) * 60 + (Number(p[1]) || 0);
  }

  function paintStats() {
    var list = rows();
    var total = list.reduce(function (acc, tr) {
      return acc + toSeconds(tr.getAttribute('data-duration'));
    }, 0);
    var genres = {};
    list.forEach(function (tr) { genres[tr.getAttribute('data-genre')] = 1; });

    var sTotal = $('#statTotal');
    if (sTotal) sTotal.textContent = list.length;
    var sTime = $('#statTime');
    if (sTime) sTime.textContent = Math.round(total / 60) + ' min';
    var sGenres = $('#statGenres');
    if (sGenres) sGenres.textContent = Object.keys(genres).length;
    if (counter) counter.innerHTML = '<b>' + list.length + '</b> de <b>' + list.length + '</b> canciones';
  }

  /* ==========================================================
     MODO DEMO · render + CRUD
     ========================================================== */
  var store = window.SONORA_DEMO;

  function renderRows() {
    var tbody = $('#songRows');
    if (!tbody || !store) return;

    var list = store.all();
    tbody.innerHTML = '';

    list.forEach(function (s, i) {
      var g = genreClass(s.genre);
      var dur = store.durationOf(s);
      var tr = document.createElement('tr');
      tr.setAttribute('data-id', s.id);
      tr.setAttribute('data-src', s.file);
      tr.setAttribute('data-title', s.title);
      tr.setAttribute('data-artist', s.artist);
      tr.setAttribute('data-emoji', s.emoji);
      tr.setAttribute('data-genre', s.genre);
      tr.setAttribute('data-gradient', g);
      tr.setAttribute('data-duration', dur);
      tr.setAttribute('data-search', (s.title + ' ' + s.artist + ' ' + s.album + ' ' + s.genre + ' ' + s.year).toLowerCase());
      tr.style.animationDelay = (i * 0.035) + 's';

      tr.innerHTML =
        '<td class="num">' + String(i + 1).padStart(2, '0') + '</td>' +
        '<td class="c-song">' +
          '<div class="song">' +
            '<div class="cover ' + g + '">' + s.emoji +
              '<span class="eq"><i></i><i></i><i></i><i></i></span>' +
            '</div>' +
            '<div class="song-meta">' +
              '<span class="song-title">' + esc(s.title) + '</span>' +
              '<span class="song-artist">' + esc(s.artist) + '</span>' +
            '</div>' +
          '</div>' +
        '</td>' +
        '<td class="cell-album">' + esc(s.album) + '</td>' +
        '<td><span class="tag">' + esc(s.genre) + '</span></td>' +
        '<td class="year">' + esc(s.year) + '</td>' +
        '<td class="dur">' + dur + '</td>' +
        '<td class="t-right">' +
          '<div class="actions">' +
            '<button class="icon-btn play" data-action="play" title="Reproducir">' + ICON_PLAY + '</button>' +
            '<button class="icon-btn admin-only" data-action="edit" data-id="' + s.id + '" title="Editar">' + ICON_EDIT + '</button>' +
            '<button class="icon-btn del admin-only" data-action="delete" data-id="' + s.id + '" title="Eliminar">' + ICON_TRASH + '</button>' +
          '</div>' +
        '</td>';

      tbody.appendChild(tr);
    });

    paintStats();
    applyFilters();
  }

  var ICON_EDIT = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/></svg>';
  var ICON_TRASH = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/></svg>';

  function esc(v) {
    return String(v == null ? '' : v)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  /* ---- modal ---- */
  var modal = $('#modalSong');
  var form = $('#formSong');
  var confirmModal = $('#modalConfirm');
  var pendingDelete = null;

  function openModal(song) {
    if (!modal) return;
    $('#modalTitle').textContent = song ? 'Editar canción' : 'Nueva canción';
    $('#modalSub').textContent = song ? 'Actualiza los datos de la pista.' : 'Agrega una pista al listado.';
    $('#fId').value = song ? song.id : '';
    var act = $('#fAction');
    if (act) act.value = song ? 'update' : 'create';
    $('#fTitle').value = song ? song.title : '';
    $('#fArtist').value = song ? song.artist : '';
    $('#fAlbum').value = song ? song.album : '';
    $('#fGenre').value = song ? song.genre : 'Pop';
    $('#fYear').value = song ? song.year : new Date().getFullYear();
    $('#fEmoji').value = song ? song.emoji : '🎵';
    $('#fFile').value = song ? song.file : 'audio/track1.wav';
    modal.classList.add('is-open');
    setTimeout(function () { $('#fTitle').focus(); }, 120);
  }

  function closeModal() {
    if (modal) modal.classList.remove('is-open');
  }

  // ---- bindings comunes: demo y versión ASP ----
  var btnNew = $('#btnNew');
  if (btnNew) btnNew.addEventListener('click', function () { openModal(null); });

  $$('[data-close]').forEach(function (el) {
    el.addEventListener('click', function () {
      var box = el.closest ? el.closest('.modal') : null;
      if (box) box.classList.remove('is-open');
    });
  });

  $$('.modal').forEach(function (m) {
    m.addEventListener('click', function (ev) {
      if (ev.target === m) m.classList.remove('is-open');
    });
  });

  document.addEventListener('keydown', function (ev) {
    if (ev.key === 'Escape') {
      $$('.modal.is-open').forEach(function (m) { m.classList.remove('is-open'); });
    }
  });

  if (isDemo) {
    renderRows();

    // editar / eliminar
    document.addEventListener('click', function (ev) {
      var edit = ev.target.closest ? ev.target.closest('[data-action="edit"]') : null;
      if (edit) {
        var s = store.get(edit.getAttribute('data-id'));
        if (s) openModal(s);
        return;
      }

      var del = ev.target.closest ? ev.target.closest('[data-action="delete"]') : null;
      if (del) {
        var song = store.get(del.getAttribute('data-id'));
        if (!song) return;
        pendingDelete = song;
        $('#confirmText').innerHTML = '¿Eliminar <b>' + esc(song.title) + '</b> de <b>' + esc(song.artist) + '</b>? Esta acción no se puede deshacer.';
        confirmModal.classList.add('is-open');
        return;
      }

      var yes = ev.target.closest ? ev.target.closest('#confirmYes') : null;
      if (yes) {
        if (pendingDelete) {
          if (currentRow && currentRow.getAttribute('data-id') === String(pendingDelete.id)) {
            if (audio) audio.pause();
            currentRow = null;
            var t = $('#playerTitle');
            var a = $('#playerArtist');
            if (t) t.textContent = 'Sin reproducción';
            if (a) a.textContent = 'Selecciona una canción del listado';
          }
          store.remove(pendingDelete.id);
          toast('Canción eliminada del listado', 'err');
          pendingDelete = null;
          confirmModal.classList.remove('is-open');
          renderRows();
        }
        return;
      }
    });

    // guardar
    if (form) {
      form.addEventListener('submit', function (ev) {
        ev.preventDefault();
        var data = {
          title: $('#fTitle').value.trim(),
          artist: $('#fArtist').value.trim(),
          album: $('#fAlbum').value.trim(),
          genre: $('#fGenre').value,
          year: $('#fYear').value,
          emoji: $('#fEmoji').value.trim() || '🎵',
          file: $('#fFile').value
        };

        if (!data.title || !data.artist) {
          toast('El título y el artista son obligatorios', 'warn');
          return;
        }

        var id = $('#fId').value;
        if (id) {
          store.update(id, data);
          toast('Canción actualizada correctamente');
        } else {
          store.create(data);
          toast('Canción agregada al listado');
        }

        closeModal();
        renderRows();
      });
    }

    var btnReset = $('#btnReset');
    if (btnReset) {
      btnReset.addEventListener('click', function () {
        store.reset();
        renderRows();
        toast('Listado restaurado');
      });
    }
  } else {
    // modo ASP: el servidor ya renderizó las filas
    paintStats();
    applyFilters();
  }

  /* ==========================================================
     LOGOUT
     ========================================================== */
  $$('[data-action="logout"]').forEach(function (el) {
    el.addEventListener('click', function (ev) {
      if (isDemo) {
        ev.preventDefault();
        try { sessionStorage.removeItem('sonora_session'); } catch (e) {}
        window.location.href = 'login.html';
      }
    });
  });

  /* ==========================================================
     INIT
     ========================================================== */
  paintSession();
  paintSlider($('#seek'), 0);

  var tot = $('#timeTot');
  if (tot) tot.textContent = '0:00';

  // mensaje de bienvenida dinámico
  var wu = $('#welcomeUser');
  if (wu && !wu.textContent.trim()) wu.textContent = session.username;
})();
