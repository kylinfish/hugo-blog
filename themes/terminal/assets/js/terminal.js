(function () {
  // copy button on every code block in a post
  document.querySelectorAll('.post-body pre').forEach(function (pre) {
    var box = pre.closest('.highlight');
    if (!box) {
      box = document.createElement('div');
      box.className = 'highlight';
      pre.parentNode.insertBefore(box, pre);
      box.appendChild(pre);
    }
    if (box.querySelector('.copy-btn')) return;
    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'copy-btn';
    btn.textContent = 'copy';
    btn.addEventListener('click', function () {
      // with line numbers the code lives in the last table cell
      var code = box.querySelector('.lntd:last-child code') || box.querySelector('code') || pre;
      navigator.clipboard.writeText(code.innerText).then(function () {
        btn.textContent = 'copied!';
        btn.classList.add('done');
      }, function () {
        btn.textContent = 'error';
      });
      setTimeout(function () {
        btn.textContent = 'copy';
        btn.classList.remove('done');
      }, 1500);
    });
    box.appendChild(btn);
  });

  // highlight the TOC entry of the section being read
  var links = document.querySelectorAll('.toc-side a');
  if (!links.length || !('IntersectionObserver' in window)) return;
  var byId = {};
  links.forEach(function (a) {
    // CJK heading ids are percent-encoded in href but not in the DOM
    byId[decodeURIComponent(a.hash.slice(1))] = a;
  });
  var observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (e) {
      if (!e.isIntersecting || !byId[e.target.id]) return;
      links.forEach(function (a) { a.classList.remove('active'); });
      byId[e.target.id].classList.add('active');
    });
  }, { rootMargin: '-72px 0px -70% 0px' });
  Object.keys(byId).forEach(function (id) {
    var h = document.getElementById(id);
    if (h) observer.observe(h);
  });
})();

// color schemes: header listbox + vim-style ":colorscheme <name>"
(function () {
  var cs = window.__cs;
  var root = document.documentElement;
  if (!cs) return;
  var system = matchMedia('(prefers-color-scheme: light)');

  function current() { return root.dataset.themeMode === 'auto' ? 'auto' : root.dataset.theme; }

  function apply(id) {
    var auto = id === 'auto';
    root.dataset.themeMode = auto ? 'auto' : 'manual';
    root.dataset.theme = auto ? (system.matches ? cs.light : cs.dark) : id;
    try {
      if (auto) localStorage.removeItem('theme'); else localStorage.setItem('theme', id);
    } catch (e) {}
    sync();
  }

  var btn = document.querySelector('.cs-btn');
  var list = document.getElementById('cs-list');
  var options = list ? [].slice.call(list.querySelectorAll('[role="option"]')) : [];
  var meta = document.querySelector('meta[name="theme-color"]');

  function sync() {
    var cur = current();
    if (btn) btn.querySelector('.cs-name').textContent = cur;
    options.forEach(function (o) { o.setAttribute('aria-selected', String(o.dataset.id === cur)); });
    if (meta) meta.content = getComputedStyle(root).getPropertyValue('--bg-alt').trim();
  }

  system.addEventListener('change', function () { if (current() === 'auto') apply('auto'); });
  sync();

  // listbox
  if (btn && list) {
    var active = 0;
    var focusOption = function (i) {
      active = (i + options.length) % options.length;
      options.forEach(function (o, j) { o.classList.toggle('focus', j === active); });
      list.setAttribute('aria-activedescendant', options[active].id);
    };
    var open = function () {
      list.hidden = false;
      btn.setAttribute('aria-expanded', 'true');
      focusOption(Math.max(0, options.findIndex(function (o) { return o.dataset.id === current(); })));
      list.focus();
    };
    var close = function (refocus) {
      list.hidden = true;
      btn.setAttribute('aria-expanded', 'false');
      if (refocus) btn.focus();
    };
    btn.addEventListener('click', function () { if (list.hidden) open(); else close(false); });
    options.forEach(function (o, i) {
      o.addEventListener('click', function () { apply(o.dataset.id); close(true); });
      o.addEventListener('mousemove', function () { focusOption(i); });
    });
    list.addEventListener('keydown', function (e) {
      if (e.key === 'ArrowDown') { focusOption(active + 1); e.preventDefault(); }
      else if (e.key === 'ArrowUp') { focusOption(active - 1); e.preventDefault(); }
      else if (e.key === 'Enter' || e.key === ' ') { apply(options[active].dataset.id); close(true); e.preventDefault(); }
      else if (e.key === 'Escape' || e.key === 'Tab') { close(e.key === 'Escape'); }
    });
    document.addEventListener('click', function (e) {
      if (!list.hidden && !e.target.closest('.cs')) close(false);
    });
  }

  // ":" command line
  var form = document.querySelector('.cmdline');
  var msg = document.querySelector('.cmd-msg');
  if (!form || !msg) return;
  var input = form.elements.cmd;
  var names = ['auto'].concat(cs.ids);
  var msgTimer;

  function say(text, isError) {
    msg.textContent = text;
    msg.classList.toggle('err', !!isError);
    msg.hidden = false;
    clearTimeout(msgTimer);
    msgTimer = setTimeout(function () { msg.hidden = true; }, 3000);
  }
  function hide() { form.hidden = true; input.value = ''; }

  function run(line) {
    var m = line.trim().match(/^(colo(?:rscheme)?)(?:\s+(\S+))?$/);
    if (!m) return line.trim() && say('E492: Not an editor command: ' + line.trim(), true);
    if (!m[2]) return say(current());
    if (names.indexOf(m[2]) < 0) return say("E185: Cannot find color scheme '" + m[2] + "'", true);
    apply(m[2]);
    say(':colorscheme ' + m[2]);
  }

  document.addEventListener('keydown', function (e) {
    if (e.key !== ':' || e.ctrlKey || e.metaKey || e.altKey || !form.hidden) return;
    var t = e.target;
    if (t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName)) return;
    e.preventDefault();
    form.hidden = false;
    msg.hidden = true;
    input.focus();
  });

  var cycle = null;
  input.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') { hide(); return; }
    if (e.key !== 'Tab') { cycle = null; return; }
    e.preventDefault();
    var m = input.value.match(/^(colo(?:rscheme)?\s+)(\S*)$/);
    if (!m) { if ('colorscheme'.indexOf(input.value) === 0) input.value = 'colorscheme '; return; }
    if (!cycle) cycle = { prefix: m[1], hits: names.filter(function (n) { return n.indexOf(m[2]) === 0; }), i: -1 };
    if (!cycle.hits.length) return;
    cycle.i = (cycle.i + (e.shiftKey ? -1 : 1) + cycle.hits.length) % cycle.hits.length;
    input.value = cycle.prefix + cycle.hits[cycle.i];
  });
  input.addEventListener('blur', function () { setTimeout(hide, 0); });
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    var line = input.value;
    hide();
    run(line);
  });
})();
