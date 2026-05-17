#!/bin/bash
# Open Focus Tracker — safe JSON injection via base64

LOG_FILE="$HOME/.local/share/pomodoro-log.json"
TRACKER_FILE="$HOME/.local/share/focus-tracker.html"

[[ -f "$LOG_FILE" ]] || { mkdir -p "$(dirname "$LOG_FILE")"; printf '[]' > "$LOG_FILE"; }

# Encode log data safely as base64 to avoid shell/sed injection issues
LOG_B64=$(base64 -w 0 "$LOG_FILE")

cat > "$TRACKER_FILE" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Focus Tracker</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js"></script>
  <style>
    :root {
      --base:    #1e1e2e; --mantle:  #181825; --crust:   #11111b;
      --surface0:#313244; --surface1:#45475a; --overlay1:#7f849c;
      --text:    #cdd6f4; --subtext: #a6adc8;
      --blue:    #89b4fa; --mauve:   #cba6f7; --pink:    #f5c2e7;
      --red:     #f38ba8; --peach:   #fab387; --yellow:  #f9e2af;
      --green:   #a6e3a1; --teal:    #94e2d5; --lavender:#b4befe;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      font-family: 'Segoe UI', system-ui, sans-serif;
      background: var(--base);
      color: var(--text);
      padding: 24px;
      min-height: 100vh;
    }
    .container { max-width: 1400px; margin: 0 auto; }

    header {
      text-align: center;
      margin-bottom: 36px;
      padding: 20px 24px;
      background: color-mix(in srgb, var(--blue) 8%, transparent);
      border: 1px solid color-mix(in srgb, var(--blue) 25%, transparent);
      border-radius: 14px;
    }
    header h1 { font-size: 2.2rem; color: var(--blue); }
    header p  { color: var(--subtext); margin-top: 6px; }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 16px; margin-bottom: 28px;
    }
    .stat-card {
      background: var(--mantle);
      border: 1px solid var(--surface0);
      border-radius: 12px; padding: 22px;
      transition: border-color .2s, transform .2s;
    }
    .stat-card:hover {
      border-color: color-mix(in srgb, var(--blue) 45%, transparent);
      transform: translateY(-3px);
    }
    .stat-label  { font-size:.8rem; color:var(--subtext); letter-spacing:.08em; text-transform:uppercase; margin-bottom:8px; }
    .stat-value  { font-size:2.2rem; font-weight:700; color:var(--blue); }
    .stat-sub    { font-size:.8rem; color:var(--overlay1); margin-top:4px; }

    .charts-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(460px, 1fr));
      gap: 24px; margin-bottom: 24px;
    }
    .chart-wrap {
      background: var(--mantle);
      border: 1px solid var(--surface0);
      border-radius: 12px; padding: 22px;
    }
    .chart-wrap h3 { color:var(--blue); text-align:center; margin-bottom:16px; font-size:1.05rem; }

    /* ── Tag section ── */
    .tag-header {
      text-align: center; font-size:1.35rem; color:var(--mauve);
      padding:12px; margin: 28px 0 18px;
      background: color-mix(in srgb, var(--mauve) 8%, transparent);
      border: 1px solid color-mix(in srgb, var(--mauve) 20%, transparent);
      border-radius: 10px;
    }
    .filter-row {
      display:flex; flex-wrap:wrap; gap:8px;
      justify-content:center; margin-bottom:18px;
    }
    .filter-btn {
      padding:5px 14px; border-radius:20px;
      border:1px solid color-mix(in srgb, var(--mauve) 35%, transparent);
      background:transparent; color:var(--mauve);
      cursor:pointer; font-size:.85rem; transition:all .15s;
    }
    .filter-btn:hover, .filter-btn.active {
      background: color-mix(in srgb, var(--mauve) 18%, transparent);
      border-color: var(--mauve);
    }
    .tag-grid {
      display:grid;
      grid-template-columns:repeat(auto-fill, minmax(200px,1fr));
      gap:14px; margin-bottom:24px;
    }
    .tag-card {
      background:var(--mantle);
      border:1px solid color-mix(in srgb, var(--mauve) 18%, transparent);
      border-radius:12px; padding:18px; transition:all .2s;
    }
    .tag-card:hover {
      border-color: color-mix(in srgb, var(--mauve) 50%, transparent);
      transform:translateY(-3px);
    }
    .tag-name    { font-size:1rem; font-weight:600; margin-bottom:6px; }
    .tag-time    { font-size:1.75rem; font-weight:700; color:var(--pink); }
    .tag-sessions{ font-size:.78rem; color:var(--overlay1); margin-top:3px; }
    .tag-bar-bg  { margin-top:10px; background:var(--surface0); border-radius:4px; height:5px; overflow:hidden; }
    .tag-bar-fg  { height:100%; border-radius:4px; transition:width .5s ease; }

    .tag-charts-row {
      display:grid; grid-template-columns:1fr 1fr; gap:24px; margin-bottom:24px;
    }

    @media(max-width:900px){ .tag-charts-row{ grid-template-columns:1fr; } }
    @media(max-width:700px){ .charts-grid  { grid-template-columns:1fr; } }
  </style>
</head>
<body>
<div class="container">

  <header>
    <h1>🎯 Focus Tracker</h1>
    <p>Your Pomodoro session history</p>
  </header>

  <div class="stats-grid">
    <div class="stat-card"><div class="stat-label">Today</div>
      <div class="stat-value" id="todayTime">—</div>
      <div class="stat-sub"  id="todaySess">—</div></div>
    <div class="stat-card"><div class="stat-label">This Week</div>
      <div class="stat-value" id="weekTime">—</div>
      <div class="stat-sub"  id="weekSess">—</div></div>
    <div class="stat-card"><div class="stat-label">This Month</div>
      <div class="stat-value" id="monthTime">—</div>
      <div class="stat-sub"  id="monthSess">—</div></div>
    <div class="stat-card"><div class="stat-label">All Time</div>
      <div class="stat-value" id="totalTime">—</div>
      <div class="stat-sub"  id="totalSess">—</div></div>
  </div>

  <div class="charts-grid">
    <div class="chart-wrap"><h3>Last 7 Days</h3><canvas id="chart7"></canvas></div>
    <div class="chart-wrap"><h3>Last 30 Days</h3><canvas id="chart30"></canvas></div>
  </div>

  <div class="chart-wrap" style="max-width:800px;margin:0 auto 24px">
    <h3>Weekly Comparison (last 4 weeks)</h3>
    <canvas id="chartWeeks"></canvas>
  </div>

  <div class="tag-header">🏷️ Time by Tag</div>

  <div class="filter-row">
    <button class="filter-btn active" data-period="all"   onclick="setFilter(this)">All Time</button>
    <button class="filter-btn"        data-period="today" onclick="setFilter(this)">Today</button>
    <button class="filter-btn"        data-period="week"  onclick="setFilter(this)">This Week</button>
    <button class="filter-btn"        data-period="month" onclick="setFilter(this)">This Month</button>
  </div>

  <div class="tag-grid" id="tagGrid"></div>

  <div class="tag-charts-row">
    <div class="chart-wrap"><h3>Tag Distribution</h3><canvas id="tagPie"></canvas></div>
    <div class="chart-wrap"><h3>Hours per Tag</h3><canvas id="tagBar"></canvas></div>
  </div>

</div>

<script>
  // ── Decode base64 log injected by the shell script ──────────
  const _b64 = document.currentScript.dataset.log;
  let sessions = [];
  try {
    sessions = JSON.parse(atob(_b64));
  } catch(e) {
    console.warn("Could not parse session log:", e);
  }

  // ── Palette ─────────────────────────────────────────────────
  const COLORS = ['#cba6f7','#89b4fa','#a6e3a1','#f5c2e7',
                  '#fab387','#f38ba8','#94e2d5','#f9e2af',
                  '#b4befe','#eba0ac'];

  // ── Helpers ─────────────────────────────────────────────────
  const fmt = m => `${Math.floor(m/60)}h ${Math.floor(m%60)}m`;
  const localDate = d => {
    const off = d.getTimezoneOffset();
    return new Date(d - off*60000).toISOString().slice(0,10);
  };

  function filterPeriod(period) {
    const now = new Date(), today = localDate(now);
    return sessions.filter(s => {
      const d = new Date(s.timestamp);
      if (period === 'today') return localDate(d) === today;
      const ago = new Date(now);
      if (period === 'week')  { ago.setDate(ago.getDate()-7);  return d >= ago; }
      if (period === 'month') { ago.setDate(ago.getDate()-30); return d >= ago; }
      return true;
    });
  }

  // ── Stats ───────────────────────────────────────────────────
  function updateStats() {
    ['all','week','month','today'].forEach(p => {
      const s = filterPeriod(p);
      const m = s.reduce((a,x)=>a+x.minutes,0);
      const k = p === 'all' ? 'total' : p;
      document.getElementById(k+'Time').textContent = fmt(m);
      document.getElementById(k+'Sess').textContent = `${s.length} session${s.length!==1?'s':''}`;
    });
  }

  // ── Daily data ──────────────────────────────────────────────
  function dailyData(days) {
    const now = new Date(), map = {};
    for (let i = days-1; i >= 0; i--) {
      const d = new Date(now); d.setDate(d.getDate()-i);
      map[localDate(d)] = 0;
    }
    sessions.forEach(s => {
      const k = localDate(new Date(s.timestamp));
      if (k in map) map[k] += s.minutes;
    });
    return map;
  }

  function weeklyComparison() {
    const now = new Date();
    const labels=[], data=[];
    for (let i=3; i>=0; i--) {
      const end = new Date(now); end.setDate(end.getDate()-i*7); end.setHours(23,59,59,999);
      const start = new Date(end); start.setDate(start.getDate()-6); start.setHours(0,0,0,0);
      labels.push(`${start.toLocaleDateString('en',{month:'short',day:'numeric'})} – ${end.toLocaleDateString('en',{month:'short',day:'numeric'})}`);
      data.push(+(sessions.filter(s=>{ const d=new Date(s.timestamp); return d>=start&&d<=end; })
        .reduce((a,x)=>a+x.minutes,0)/60).toFixed(2));
    }
    return { labels, data };
  }

  // ── Chart factory ───────────────────────────────────────────
  const SCALE_OPTS = {
    y: { beginAtZero:true, ticks:{ color:'#a6adc8' }, grid:{ color:'rgba(137,180,250,.08)' } },
    x: { ticks:{ color:'#a6adc8' }, grid:{ color:'rgba(137,180,250,.08)' } }
  };
  let c7, c30, cW, cPie, cBar;

  function buildMainCharts() {
    const d7  = dailyData(7),  d30 = dailyData(30);
    const lbl = (d, fmt='short') => new Date(d).toLocaleDateString('en',{month:fmt,day:'numeric'});

    if(c7)  c7.destroy();
    c7 = new Chart(document.getElementById('chart7'),{
      type:'bar',
      data:{ labels:Object.keys(d7).map(lbl),
             datasets:[{data:Object.values(d7), backgroundColor:'rgba(137,180,250,.55)',
                        borderColor:'#89b4fa', borderWidth:2, borderRadius:5}] },
      options:{ responsive:true, plugins:{legend:{display:false}},
                scales:{ ...SCALE_OPTS,
                  y:{ ...SCALE_OPTS.y, ticks:{ ...SCALE_OPTS.y.ticks,
                    callback:v=>Math.floor(v/60)+'h'+(v%60?Math.floor(v%60)+'m':'') }} } }
    });

    if(c30) c30.destroy();
    c30 = new Chart(document.getElementById('chart30'),{
      type:'line',
      data:{ labels:Object.keys(d30).map(lbl),
             datasets:[{data:Object.values(d30), backgroundColor:'rgba(166,227,161,.15)',
                        borderColor:'#a6e3a1', borderWidth:2.5, fill:true, tension:.4,
                        pointRadius:2}] },
      options:{ responsive:true, plugins:{legend:{display:false}},
                scales:{ ...SCALE_OPTS } }
    });

    const wkly = weeklyComparison();
    if(cW)  cW.destroy();
    cW = new Chart(document.getElementById('chartWeeks'),{
      type:'bar',
      data:{ labels:wkly.labels,
             datasets:[{data:wkly.data, backgroundColor:'rgba(245,194,231,.55)',
                        borderColor:'#f5c2e7', borderWidth:2, borderRadius:5}] },
      options:{ responsive:true, plugins:{legend:{display:false}},
                scales:{ ...SCALE_OPTS,
                  y:{ ...SCALE_OPTS.y, ticks:{ ...SCALE_OPTS.y.ticks, callback:v=>v+'h' }},
                  x:{ ticks:{ color:'#a6adc8', maxRotation:25 }, grid:{ color:'rgba(137,180,250,.08)' } } } }
    });
  }

  // ── Tag section ─────────────────────────────────────────────
  function buildTagData(list) {
    const map={};
    list.forEach(s=>{
      const t=s.tag||'#general';
      map[t]??={minutes:0,sessions:0};
      map[t].minutes+=s.minutes; map[t].sessions++;
    });
    return Object.entries(map).sort((a,b)=>b[1].minutes-a[1].minutes);
  }

  function renderTags(tagData) {
    const grid=document.getElementById('tagGrid');
    if(!tagData.length){
      grid.innerHTML='<p style="color:var(--overlay1);text-align:center;grid-column:1/-1">No sessions in this period.</p>';
      return;
    }
    const max=tagData[0][1].minutes;
    grid.innerHTML=tagData.map(([tag,d],i)=>{
      const c=COLORS[i%COLORS.length], pct=max>0?d.minutes/max*100:0;
      return `<div class="tag-card">
        <div class="tag-name" style="color:${c}">${tag}</div>
        <div class="tag-time">${fmt(d.minutes)}</div>
        <div class="tag-sessions">${d.sessions} session${d.sessions!==1?'s':''}</div>
        <div class="tag-bar-bg"><div class="tag-bar-fg" style="width:${pct}%;background:${c}"></div></div>
      </div>`;
    }).join('');
  }

  function renderTagCharts(tagData) {
    const labels=tagData.map(([t])=>t);
    const data  =tagData.map(([,d])=>+(d.minutes/60).toFixed(2));
    const bgs   =tagData.map((_,i)=>COLORS[i%COLORS.length]+'99');
    const bds   =tagData.map((_,i)=>COLORS[i%COLORS.length]);

    if(cPie) cPie.destroy();
    cPie=new Chart(document.getElementById('tagPie'),{
      type:'doughnut',
      data:{ labels, datasets:[{data, backgroundColor:bgs, borderColor:bds, borderWidth:2}] },
      options:{ responsive:true,
                plugins:{ legend:{ labels:{ color:'#a6adc8' } },
                          tooltip:{ callbacks:{ label:ctx=>` ${ctx.label}: ${ctx.parsed.toFixed(1)}h` }}}}
    });

    if(cBar) cBar.destroy();
    cBar=new Chart(document.getElementById('tagBar'),{
      type:'bar',
      data:{ labels, datasets:[{data, backgroundColor:bgs, borderColor:bds, borderWidth:2, borderRadius:5}] },
      options:{ responsive:true, plugins:{legend:{display:false}},
                scales:{ ...SCALE_OPTS,
                  y:{ ...SCALE_OPTS.y, ticks:{ ...SCALE_OPTS.y.ticks, callback:v=>v+'h' }} } }
    });
  }

  let currentPeriod='all';
  function setFilter(btn){
    document.querySelectorAll('.filter-btn').forEach(b=>b.classList.remove('active'));
    btn.classList.add('active');
    currentPeriod=btn.dataset.period;
    refreshTags();
  }
  function refreshTags(){
    const td=buildTagData(filterPeriod(currentPeriod));
    renderTags(td); renderTagCharts(td);
  }

  // ── Boot ────────────────────────────────────────────────────
  updateStats();
  buildMainCharts();
  refreshTags();
</script>
HTMLEOF

# Safely inject log data via a data attribute on the last script tag
# Use python3 for reliable base64 (avoids line-wrap issues with bash base64 -w 0 on some distros)
LOG_B64=$(python3 -c "import base64,sys; print(base64.b64encode(open(sys.argv[1],'rb').read()).decode())" "$LOG_FILE" 2>/dev/null || base64 -w 0 "$LOG_FILE")

# Patch the placeholder script tag to carry the data
sed -i "s|const _b64 = document.currentScript.dataset.log;|const _b64 = '${LOG_B64}';|" "$TRACKER_FILE"

# Open in whatever browser is available
for browser in xdg-open brave firefox chromium; do
    if command -v "$browser" &>/dev/null; then
        "$browser" "$TRACKER_FILE" 2>/dev/null &
        break
    fi
done
