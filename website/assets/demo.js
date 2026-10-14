// Playable mini board for the landing page.
// Boards are built in reverse removal order, so every board is solvable:
// each new arrow is placed only where its path to the edge is clear of the
// arrows already on the board (those are the ones removed after it).
(function () {
  const board = document.getElementById("board");
  if (!board) return;
  const msg = document.getElementById("demo-msg");
  const leftEl = document.getElementById("demo-left");
  const heartsEl = document.getElementById("demo-hearts");
  const N = 5;
  const TARGET = 13;
  const DIRS = [
    { dr: -1, dc: 0, ch: "↑", name: "up" },
    { dr: 1, dc: 0, ch: "↓", name: "down" },
    { dr: 0, dc: -1, ch: "←", name: "left" },
    { dr: 0, dc: 1, ch: "→", name: "right" },
  ];
  let grid, left, hearts;

  function pathClear(g, r, c, d) {
    for (let rr = r + d.dr, cc = c + d.dc; rr >= 0 && rr < N && cc >= 0 && cc < N; rr += d.dr, cc += d.dc) {
      if (g[rr][cc]) return false;
    }
    return true;
  }

  function generate() {
    for (let attempt = 0; attempt < 50; attempt++) {
      const g = Array.from({ length: N }, () => Array(N).fill(null));
      let placed = 0;
      for (let tries = 0; tries < 400 && placed < TARGET; tries++) {
        const r = Math.floor(Math.random() * N);
        const c = Math.floor(Math.random() * N);
        if (g[r][c]) continue;
        const d = DIRS[Math.floor(Math.random() * 4)];
        if (!pathClear(g, r, c, d)) continue;
        g[r][c] = d;
        placed++;
      }
      if (placed >= TARGET - 2) return g;
    }
  }

  function render() {
    board.innerHTML = "";
    board.style.gridTemplateColumns = `repeat(${N}, 1fr)`;
    board.style.overflow = "hidden";
    left = 0;
    for (let r = 0; r < N; r++) {
      for (let c = 0; c < N; c++) {
        const d = grid[r][c];
        if (!d) {
          const empty = document.createElement("div");
          empty.className = "cell";
          board.appendChild(empty);
          continue;
        }
        left++;
        const b = document.createElement("button");
        b.className = "cell arrow";
        b.textContent = d.ch;
        b.setAttribute("aria-label", `Arrow pointing ${d.name}`);
        b.addEventListener("click", () => tap(r, c, b));
        board.appendChild(b);
      }
    }
    leftEl.textContent = left;
    hearts = 3;
    showHearts();
    msg.textContent = "Tap an arrow to slide it off the board.";
  }

  function tap(r, c, el) {
    const d = grid[r][c];
    if (!d || hearts === 0) return;
    if (!pathClear(grid, r, c, d)) {
      el.classList.remove("blocked");
      void el.offsetWidth;
      el.classList.add("blocked");
      setTimeout(() => el.classList.remove("blocked"), 400);
      hearts--;
      showHearts();
      msg.textContent = hearts ? "Blocked! That cost a heart." : "Out of hearts. Tap New board to try again.";
      return;
    }
    grid[r][c] = null;
    left--;
    leftEl.textContent = left;
    el.style.transform = `translate(${d.dc * 600}%, ${d.dr * 600}%)`;
    el.classList.add("gone");
    msg.textContent = left ? "Nice. Keep going." : "Board cleared! 🎉";
  }

  function showHearts() {
    heartsEl.textContent = "❤️".repeat(hearts) + "🤍".repeat(3 - hearts);
    heartsEl.setAttribute("aria-label", `${hearts} hearts left`);
  }

  function reset() {
    grid = generate();
    render();
  }

  document.getElementById("demo-new").addEventListener("click", reset);
  reset();
})();
