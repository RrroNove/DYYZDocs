// ===== DYYZDocs 多页面共用脚本 =====

// 侧边栏整体收起/展开(桌面端)
function toggleSidebar() {
  document.body.classList.toggle('nav-collapsed');
}

// 侧边栏分组展开/收起
function toggleGroup(btn) {
  const group = btn.closest('.nav-group');
  group.classList.toggle('open');
  btn.setAttribute('aria-label', group.classList.contains('open') ? '折叠' : '展开');
  saveNavState(); // 保存展开状态,跨页面保持一致
}

// 移动端抽屉菜单
function openNav() {
  document.getElementById('sideNav').classList.add('open');
  document.getElementById('overlay').classList.add('show');
}
function closeNav() {
  document.getElementById('sideNav').classList.remove('open');
  document.getElementById('overlay').classList.remove('show');
}

// 点击导航链接后收起移动端菜单
document.querySelectorAll('.nav-links a').forEach(a => {
  a.addEventListener('click', closeNav);
});

// ---------- 分组展开状态跨页面保持(默认全部展开,可全页面跳转) ----------
const NAV_KEY = 'dyyzdocs-nav-groups';

function saveNavState() {
  try {
    const state = Array.from(document.querySelectorAll('.nav-group'))
      .map(g => (g.classList.contains('open') ? 1 : 0));
    localStorage.setItem(NAV_KEY, JSON.stringify(state));
  } catch (e) { /* 忽略(如隐私模式) */ }
}

function restoreNavState() {
  try {
    const raw = localStorage.getItem(NAV_KEY);
    if (!raw) return; // 无历史记录时保持默认:全部展开
    const state = JSON.parse(raw);
    Array.from(document.querySelectorAll('.nav-group')).forEach((g, i) => {
      if (state[i] === 1) { g.classList.add('open'); } else { g.classList.remove('open'); }
      const toggle = g.querySelector('.nav-group-head .nav-group-toggle');
      if (toggle) toggle.setAttribute('aria-label', g.classList.contains('open') ? '折叠' : '展开');
    });
  } catch (e) { /* 忽略解析错误 */ }
}

restoreNavState();
