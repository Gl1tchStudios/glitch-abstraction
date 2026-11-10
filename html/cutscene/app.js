// /cutsceneadmin browser (glitch-abstraction client/cutscene/admin.lua). Same catalog, photos and "did not load"
// marks as the glitch-admin Troll browser. Put in = server/cutscene/cutscene.lua PlayFor (own bucket, map streamed
// where the scene is, back on the same spot after).
(() => {
  const RES = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'glitch-abstraction';
  const post = (name, data) => fetch(`https://${RES}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data || {}) }).catch(() => {});
  const $ = s => document.querySelector(s);
  const esc = v => String(v == null ? '' : v).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const FILM = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M7 4v16M17 4v16M3 9h4M3 15h4M17 9h4M17 15h4"/></svg>';
  const WARN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M12 3l9.5 17h-19z"/><path d="M12 10v4M12 17v.01"/></svg>';
  const TABS = [['featured', 'Featured'], ['story', 'Story Mode'], ['online', 'GTA Online'], ['dlc', 'DLC'], ['other', 'Test scenes']];

  const S = { data: null, tab: 'featured', set: null, q: '', sel: null, target: null, fill: 'off', picks: [], aceOpen: false };
  const all = () => (S.data && S.data.list) || [];
  const players = () => (S.data && S.data.players) || [];
  const inTab = (c, t) => t === 'featured' ? !!c.featured : (c.src || 'other') === t;
  const byName = n => all().find(c => c.value === n);
  const playerName = id => { const p = players().find(x => x.id === id); return p ? (p.char || p.name) : `#${id}`; };

  function filtered() {
    const q = S.q.trim().toLowerCase();
    let list = all().filter(c => q ? true : inTab(c, S.tab));
    if (!q && S.set) list = list.filter(c => (c.set || 'Other') === S.set);
    if (q) list = list.filter(c => [c.value, c.mission, c.part, c.desc, c.set, c.srcLabel].some(v => (v || '').toLowerCase().includes(q)));
    if (S.tab === 'featured' && !q) list.sort((a, b) => (a.featured || 99) - (b.featured || 99));
    return list;
  }

  function thumb(c, big) {
    if (c.img) return `<img src="${esc(c.img)}" alt="" loading="lazy" onerror="this.outerHTML='<div class=&quot;noimg&quot;>No preview</div>'">`;
    if (c.bad) return `<div class="noimg bad">${WARN}<span>Did not load</span></div>`;
    return `<div class="noimg">${FILM}<span>${big ? 'No preview photo yet' : 'No preview'}</span></div>`;
  }

  function fillBox(c) {
    if (!c || c.src === 'story') return '';
    const btn = (v, l) => `<button class="${S.fill === v ? 'on' : ''}" data-a="fill" data-v="${v}">${l}</button>`;
    const others = players().filter(p => p.id !== S.target);
    const max = (S.data && S.data.fillerSlots) || 3;
    const picks = S.fill === 'pick' ? `<div class="picks scroll">${others.map(p => `<label class="pick"><input type="checkbox" data-a="pickp" value="${p.id}" ${S.picks.includes(p.id) ? 'checked' : ''}>
        <span class="grow">${esc(p.char || p.name)}</span><small class="faint">${p.id}</small></label>`).join('') || '<div class="empty">Nobody else is in the city.</div>'}</div>` : '';
    return `<div class="box"><h3>Filler characters</h3><div class="seg">${btn('off', 'Off')}${btn('random', 'Random')}${btn('pick', 'Pick players')}</div>
      <small class="faint">${S.fill === 'random' ? `Players in the city first, then random characters from the database, up to ${max}.`
        : S.fill === 'pick' ? `Up to ${max}, in their saved look.` : 'The other slots stay empty.'}</small>${picks}</div>`;
  }

  function detail() {
    const c = byName(S.sel);
    if (!c) return '<div class="empty">Pick a cutscene to see its photo and description.</div>';
    const t = S.target, me = S.data && S.data.me;
    const who = t === me ? 'me' : playerName(t);
    return `<div class="big">${thumb(c, true)}</div>
      <h2>${esc(c.mission || c.value)} ${c.guess ? '<span class="chip warn">unconfirmed</span>' : ''}</h2>
      <div class="row"><span class="chip ours">${esc(c.srcLabel || 'Other')}</span><span class="chip">${esc(c.set || '')}</span></div>
      <code>${esc(c.value)}</code>
      <div class="desc">${esc(c.desc || 'No description.')}</div>
      ${c.bad ? `<div class="bad">Last photo try: ${esc(c.bad)}. It may not play.</div>` : ''}
      ${fillBox(c)}
      <div class="actions">
        <button class="btn primary" data-a="play" ${t ? '' : 'disabled'}>Put ${esc(who)} in</button>
        ${t !== me ? `<button class="btn" data-a="play" data-watch="1" ${t ? '' : 'disabled'}>Put in + watch</button>` : ''}
        <button class="btn" data-a="preview">Preview on my screen</button>
        <button class="btn danger" data-a="stop" ${t ? '' : 'disabled'}>Stop for ${esc(who)}</button>
      </div>`;
  }

  function render(keepScroll) {
    const app = $('#app');
    if (!S.data) { app.hidden = true; return; }
    app.hidden = false;
    const list = filtered(), q = S.q.trim();
    const counts = Object.fromEntries(TABS.map(([id]) => [id, all().filter(c => inTab(c, id)).length]));
    const sets = new Map();
    if (!q) for (const c of all()) if (inTab(c, S.tab)) sets.set(c.set || 'Other', (sets.get(c.set || 'Other') || 0) + 1);
    const setRows = sets.size > 1 ? [`<button class="btn ${!S.set ? 'on' : ''}" data-a="set" data-v=""><span>All</span><small>${counts[S.tab]}</small></button>`]
      .concat([...sets.entries()].map(([n, k]) => `<button class="btn ${S.set === n ? 'on' : ''}" data-a="set" data-v="${esc(n)}"><span>${esc(n)}</span><small>${k}</small></button>`)).join('') : '';
    const top = keepScroll && $('#list') ? $('#list').scrollTop : 0;
    const typing = document.activeElement && document.activeElement.id === 'q';
    const me = S.data.me;
    app.innerHTML = `
      <div class="head"><div><h1>Cutscenes</h1><div class="sub">${all().length} scenes, ${all().filter(c => c.img).length} with a photo. The map loads where the scene plays; everyone goes back to where they stood after.</div></div>
        <span class="grow"></span>
        <label class="faint">Player</label>
        <select class="input" id="target">${players().map(p => `<option value="${p.id}" ${p.id === S.target ? 'selected' : ''}>${p.id === me ? 'Me' : esc(p.char || p.name)} (${p.id})${p.busy ? ' - in a cutscene' : ''}</option>`).join('')}</select>
        <button class="btn sm" data-a="refresh" title="Players and photos again">Refresh</button>
        ${S.data.canEditAce ? `<button class="btn sm" data-a="ace" title="Who may open this">Access</button>` : ''}
        <button class="btn" data-a="close">Close</button></div>
      <div class="row"><div class="seg">${TABS.filter(([id]) => counts[id] || id === S.tab).map(([id, l]) => `<button class="${id === S.tab ? 'on' : ''}" data-a="tab" data-v="${id}">${l}<small>${counts[id]}</small></button>`).join('')}</div>
        <span class="grow"></span><input class="input" id="q" placeholder="Search name, mission, description" value="${esc(S.q)}" autocomplete="off" style="width:300px"></div>
      <div class="grid ${setRows ? '' : 'nosets'}">${setRows ? `<div class="sets scroll">${setRows}</div>` : ''}
        <div class="list scroll" id="list">${list.map(c => `<button class="card ${S.sel === c.value ? 'on' : ''}" data-a="pick" data-v="${esc(c.value)}" title="${esc(c.desc || c.value)}">
          <div class="thumb">${thumb(c)}${c.guess ? '<span class="guess">unconfirmed</span>' : ''}</div>
          <div class="meta"><b>${esc(c.mission || c.value)}</b><small>${esc(c.part || '')}</small><code>${esc(c.value)}</code></div></button>`).join('') || '<div class="empty">Nothing matches.</div>'}</div>
        <div class="detail scroll" id="detail">${detail()}</div></div>
      <div class="faint">${list.length} shown</div>
      ${S.aceOpen ? `<div class="modal"><div><h3>Who may open /cutsceneadmin</h3>
        <div class="faint">The ACE a player needs. Now: <b>${esc(S.data.ace)}</b> (config: ${esc(S.data.aceDefault)}). Leave it empty to go back to the config value.</div>
        <input class="input" id="ace" value="${esc(S.data.ace)}" autocomplete="off">
        <div class="row"><span class="grow"></span><button class="btn" data-a="aceClose">Cancel</button><button class="btn primary" data-a="aceSave">Save</button></div></div></div>` : ''}`;
    if ($('#list')) $('#list').scrollTop = top;
    const qi = $('#q');
    if (typing && qi) { qi.focus(); qi.setSelectionRange(qi.value.length, qi.value.length); }
  }

  function toast(text, kind) {
    const el = document.createElement('div');
    el.className = `toast ${kind || ''}`;
    el.textContent = text;
    $('#toasts').appendChild(el);
    setTimeout(() => el.remove(), 5000);
  }

  function play(watch) {
    if (!S.sel || !S.target) return;
    post('cut_play', { target: S.target, name: S.sel, watch: !!watch, fillers: S.fill, picks: S.fill === 'pick' ? S.picks.join(',') : '' });
  }

  document.addEventListener('click', e => {
    const el = e.target.closest('[data-a]');
    if (!el || el.tagName === 'INPUT') return;
    const a = el.dataset.a, v = el.dataset.v;
    if (a === 'close') return post('cut_close');
    if (a === 'refresh') return post('cut_refresh');
    if (a === 'tab') { S.tab = v; S.set = null; S.q = ''; return render(); }
    if (a === 'set') { S.set = v || null; return render(); }
    if (a === 'pick') {
      S.sel = v;
      document.querySelectorAll('.card').forEach(b => b.classList.toggle('on', b.dataset.v === v));
      $('#detail').innerHTML = detail();
      return;
    }
    if (a === 'fill') { S.fill = v; $('#detail').innerHTML = detail(); return; }
    if (a === 'play') return play(el.dataset.watch === '1');
    if (a === 'preview') { if (S.sel) post('cut_play', { target: S.data.me, name: S.sel, fillers: S.fill, picks: S.fill === 'pick' ? S.picks.join(',') : '' }); return; }
    if (a === 'stop') { if (S.target) post('cut_stop', { target: S.target }); return; }
    if (a === 'ace') { S.aceOpen = true; return render(true); }
    if (a === 'aceClose') { S.aceOpen = false; return render(true); }
    if (a === 'aceSave') { post('cut_setAce', { ace: ($('#ace') || {}).value || '' }); S.aceOpen = false; return render(true); }
  });

  document.addEventListener('change', e => {
    if (e.target.id === 'target') { S.target = Number(e.target.value); S.picks = S.picks.filter(id => id !== S.target); return render(true); }
    if (e.target.dataset.a === 'pickp') {
      const max = (S.data && S.data.fillerSlots) || 3;
      const on = [...document.querySelectorAll('[data-a="pickp"]:checked')].map(i => Number(i.value));
      if (on.length > max) { e.target.checked = false; toast(`${max} at most: a cutscene has ${max} other slots.`, 'error'); return; }
      S.picks = on;
    }
  });

  let searchTimer = null;
  document.addEventListener('input', e => {
    if (e.target.id !== 'q') return;
    S.q = e.target.value;
    S.set = null;
    clearTimeout(searchTimer);
    searchTimer = setTimeout(render, 150);
  });

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape' && S.data) { if (S.aceOpen) { S.aceOpen = false; render(true); } else post('cut_close'); }
  });

  window.addEventListener('message', ev => {
    const m = ev.data || {};
    if (m.type === 'open' || m.type === 'data') {
      const keepSel = S.sel;
      S.data = m.data;
      if (!players().some(p => p.id === S.target)) S.target = S.data.me;
      S.sel = keepSel && byName(keepSel) ? keepSel : null;
      render(m.type === 'data');
      if (m.type === 'open' && $('#q')) $('#q').focus();
    } else if (m.type === 'close') {
      S.data = null; S.aceOpen = false;
      render();
    } else if (m.type === 'toast') {
      toast(m.text, m.kind);
      if (m.ace && S.data) { S.data.ace = m.ace; }
    }
  });
})();
