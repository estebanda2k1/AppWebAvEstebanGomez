/* ============================================================
   SONORA · Almacén de datos para la DEMO estática (index.html)
   Replica el archivo data/songs.txt que usa songs.asp.
   Persiste en localStorage para que el CRUD sea real.
   ============================================================ */
window.SONORA_DEMO = (function () {
  'use strict';

  var KEY = 'sonora_songs_v1';

  var SEED = [
    { id: 1, title: 'Neón de Medianoche', artist: 'Lúmina', album: 'Ciudad Eléctrica', genre: 'Synthpop', year: 2024, emoji: '🌃', file: 'audio/track1.wav' },
    { id: 2, title: 'Café a las Seis', artist: 'Bruno Salas', album: 'Mañanas Lentas', genre: 'Jazz', year: 2022, emoji: '☕', file: 'audio/track2.wav' },
    { id: 3, title: 'Gravedad Cero', artist: 'Astral Kid', album: 'Órbita', genre: 'Electrónica', year: 2025, emoji: '🚀', file: 'audio/track3.wav' },
    { id: 4, title: 'Lluvia en el Retrovisor', artist: 'Valeria Norte', album: 'Ruta 9', genre: 'Indie', year: 2023, emoji: '🌧️', file: 'audio/track4.wav' },
    { id: 5, title: 'Tambor de Sal', artist: 'Costa Brava Sound', album: 'Marea', genre: 'Latina', year: 2021, emoji: '🥁', file: 'audio/track5.wav' },
    { id: 6, title: 'Vidrio Roto', artist: 'Kira Vane', album: 'Cristal', genre: 'Rock', year: 2020, emoji: '💎', file: 'audio/track6.wav' },
    { id: 7, title: 'Jardín de Cobre', artist: 'Mateo Rey', album: 'Botánica', genre: 'Acústica', year: 2024, emoji: '🌿', file: 'audio/track7.wav' },
    { id: 8, title: 'Última Llamada', artist: 'Nova Sur', album: 'Aeropuerto', genre: 'Pop', year: 2025, emoji: '✈️', file: 'audio/track8.wav' }
  ];

  // duración real de cada pista generada
  var DURATIONS = {
    'audio/track1.wav': '0:27',
    'audio/track2.wav': '0:31',
    'audio/track3.wav': '0:25',
    'audio/track4.wav': '0:33',
    'audio/track5.wav': '0:29',
    'audio/track6.wav': '0:24',
    'audio/track7.wav': '0:35',
    'audio/track8.wav': '0:28'
  };

  var memory = null;

  function read() {
    if (memory) return memory;
    var arr = null;
    try {
      var raw = localStorage.getItem(KEY);
      if (raw) arr = JSON.parse(raw);
    } catch (e) {}
    if (!Array.isArray(arr) || !arr.length) arr = SEED.slice();
    memory = arr;
    return arr;
  }

  function write(list) {
    memory = list; // respaldo en memoria si el navegador bloquea localStorage
    try { localStorage.setItem(KEY, JSON.stringify(list)); } catch (e) {}
  }

  function nextId(list) {
    return list.reduce(function (m, s) { return Math.max(m, Number(s.id) || 0); }, 0) + 1;
  }

  return {
    durations: DURATIONS,

    all: function () { return read(); },

    get: function (id) {
      return read().filter(function (s) { return String(s.id) === String(id); })[0] || null;
    },

    create: function (data) {
      var list = read();
      var song = {
        id: nextId(list),
        title: data.title,
        artist: data.artist,
        album: data.album || '—',
        genre: data.genre || 'Pop',
        year: Number(data.year) || new Date().getFullYear(),
        emoji: data.emoji || '🎵',
        file: data.file || 'audio/track1.wav'
      };
      list.push(song);
      write(list);
      return song;
    },

    update: function (id, data) {
      var list = read();
      list = list.map(function (s) {
        if (String(s.id) !== String(id)) return s;
        return {
          id: s.id,
          title: data.title,
          artist: data.artist,
          album: data.album || '—',
          genre: data.genre || s.genre,
          year: Number(data.year) || s.year,
          emoji: data.emoji || s.emoji,
          file: data.file || s.file
        };
      });
      write(list);
    },

    remove: function (id) {
      write(read().filter(function (s) { return String(s.id) !== String(id); }));
    },

    durationOf: function (song) {
      return DURATIONS[song.file] || '0:30';
    },

    reset: function () {
      memory = SEED.slice();
      try { localStorage.removeItem(KEY); } catch (e) {}
      return memory;
    }
  };
})();
