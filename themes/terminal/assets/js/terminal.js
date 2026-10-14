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
