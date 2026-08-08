/* ========================================================
   LOADER
======================================================== */
window.addEventListener('load', () => {
  const loader = document.getElementById('loader');
  setTimeout(() => loader.classList.add('hide'), 400);
});

/* ========================================================
   NAVBAR SCROLL STATE + PROGRESS BAR
======================================================== */
const navbar = document.getElementById('navbar');
const progressBar = document.getElementById('progress-bar');
const toTopBtn = document.getElementById('toTop');

window.addEventListener('scroll', () => {
  const scrollTop = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const pct = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
  progressBar.style.width = pct + '%';

  navbar.classList.toggle('scrolled', scrollTop > 40);
  toTopBtn.classList.toggle('show', scrollTop > 700);
}, { passive: true });

toTopBtn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));

/* ========================================================
   MOBILE NAV TOGGLE
======================================================== */
const navToggle = document.getElementById('navToggle');
const navLinks = document.getElementById('navLinks');
navToggle.addEventListener('click', () => navLinks.classList.toggle('open'));
navLinks.querySelectorAll('a').forEach(a => a.addEventListener('click', () => navLinks.classList.remove('open')));

/* ========================================================
   SCROLL REVEAL ANIMATIONS
======================================================== */
const revealEls = document.querySelectorAll('.reveal');
const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('in');
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });
revealEls.forEach(el => revealObserver.observe(el));

/* ========================================================
   COUNTER ANIMATIONS
======================================================== */
function animateCounter(el) {
  const target = parseFloat(el.getAttribute('data-count'));
  const decimals = parseInt(el.getAttribute('data-decimal') || '0');
  const isCurrency = el.getAttribute('data-currency') === '1';
  const duration = 1600;
  const start = performance.now();

  function formatNum(v) {
    if (isCurrency) {
      return '₹' + Math.round(v).toLocaleString('en-IN');
    }
    return decimals > 0 ? v.toFixed(decimals) : Math.round(v).toLocaleString('en-IN');
  }

  function step(now) {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    const value = target * eased;
    el.textContent = formatNum(value);
    if (progress < 1) requestAnimationFrame(step);
    else el.textContent = formatNum(target);
  }
  requestAnimationFrame(step);
}

const counters = document.querySelectorAll('.count');
const counterObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      animateCounter(entry.target);
      counterObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.4 });
counters.forEach(c => counterObserver.observe(c));

/* ========================================================
   SIDEBAR ACTIVE STATE
======================================================== */
const sidebarItems = document.querySelectorAll('#sidebar li');
const sectionTargets = Array.from(sidebarItems).map(li => document.getElementById(li.dataset.target)).filter(Boolean);

sidebarItems.forEach(li => {
  li.addEventListener('click', () => {
    const target = document.getElementById(li.dataset.target);
    if (target) target.scrollIntoView({ behavior: 'smooth' });
  });
});

function updateSidebar() {
  let currentId = sectionTargets[0] ? sectionTargets[0].id : null;
  const scrollPos = window.scrollY + window.innerHeight * 0.35;
  sectionTargets.forEach(sec => {
    if (sec.offsetTop <= scrollPos) currentId = sec.id;
  });
  sidebarItems.forEach(li => li.classList.toggle('active', li.dataset.target === currentId));
}
window.addEventListener('scroll', updateSidebar, { passive: true });
updateSidebar();

/* ========================================================
   ACCORDION
======================================================== */
document.querySelectorAll('.acc-head').forEach(head => {
  head.addEventListener('click', () => {
    const item = head.closest('.acc-item');
    const wasOpen = item.classList.contains('open');
    item.parentElement.querySelectorAll('.acc-item').forEach(i => i.classList.remove('open'));
    if (!wasOpen) item.classList.add('open');
  });
});

/* ========================================================
   HERO CANVAS — ANALYTICS PARTICLE / LINE-CHART VISUAL
======================================================== */
(function heroCanvas() {
  const canvas = document.getElementById('heroCanvas');
  const ctx = canvas.getContext('2d');
  let w, h, points = [];

  function resize() {
    w = canvas.width = canvas.offsetWidth * devicePixelRatio;
    h = canvas.height = canvas.offsetHeight * devicePixelRatio;
  }
  window.addEventListener('resize', resize);
  resize();

  const NUM = 46;
  for (let i = 0; i < NUM; i++) {
    points.push({
      x: Math.random() * w,
      y: Math.random() * h,
      vx: (Math.random() - 0.5) * 0.35 * devicePixelRatio,
      vy: (Math.random() - 0.5) * 0.35 * devicePixelRatio,
      r: Math.random() * 1.8 + 1
    });
  }

  function draw() {
    ctx.clearRect(0, 0, w, h);
    points.forEach(p => {
      p.x += p.vx; p.y += p.vy;
      if (p.x < 0 || p.x > w) p.vx *= -1;
      if (p.y < 0 || p.y > h) p.vy *= -1;
    });
    for (let i = 0; i < points.length; i++) {
      for (let j = i + 1; j < points.length; j++) {
        const dx = points[i].x - points[j].x, dy = points[i].y - points[j].y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 170 * devicePixelRatio) {
          ctx.strokeStyle = `rgba(96,165,250,${0.14 * (1 - dist / (170 * devicePixelRatio))})`;
          ctx.lineWidth = 1;
          ctx.beginPath();
          ctx.moveTo(points[i].x, points[i].y);
          ctx.lineTo(points[j].x, points[j].y);
          ctx.stroke();
        }
      }
    }
    points.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(147,197,253,0.55)';
      ctx.fill();
    });
    requestAnimationFrame(draw);
  }
  draw();
})();

/* ========================================================
   CHART.JS GLOBAL DEFAULTS
======================================================== */
if (window.Chart) {
  Chart.defaults.font.family = "'Inter', sans-serif";
  Chart.defaults.color = '#A9B4CC';
  Chart.defaults.borderColor = 'rgba(255,255,255,.08)';
  Chart.defaults.scale.grid.color = 'rgba(255,255,255,.08)';
  Chart.defaults.plugins.legend.labels.boxWidth = 12;
  Chart.defaults.plugins.legend.labels.font = { size: 11, weight: '600' };
}

const PALETTE = ['#3B82F6', '#F59E0B', '#10B981', '#EC4899', '#8B5CF6', '#14B8A6', '#F87171', '#FACC15'];
const NAVY = '#F1F5FB';
const VISION_COLORS = { Bifocal: '#3B82F6', Near: '#14B8A6', Distance: '#F59E0B', Progressive: '#EC4899' };

function makeChart(id, config) {
  const el = document.getElementById(id);
  if (!el) return;
  const obs = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        new Chart(el.getContext('2d'), config);
        obs.unobserve(el);
      }
    });
  }, { threshold: 0.15 });
  obs.observe(el);
}

/* ---- Lifecycle funnel ---- */
makeChart('chartFunnel', {
  type: 'bar',
  data: {
    labels: ['Walk-in Visitors', 'Buyer Customers', 'Repeated Customers', 'Churned (repeat)'],
    datasets: [{
      label: 'Customers',
      data: [8000, 3721, 1051, 235],
      backgroundColor: PALETTE,
      borderRadius: 8
    }]
  },
  options: {
    indexAxis: 'y',
    plugins: { legend: { display: false }, title: { display: true, text: 'Customer Lifecycle Funnel', font: { size: 13, weight: '700' }, color: NAVY } },
    scales: { x: { grid: { display: false } }, y: { grid: { display: false } } }
  }
});

/* ---- Revenue split: repeat vs one-time ---- */
makeChart('chartRevenueSplit', {
  type: 'doughnut',
  data: {
    labels: ['Repeated Customers Revenue (53%)', 'One-Time Buyers Revenue (47%)'],
    datasets: [{ data: [53, 47], backgroundColor: [PALETTE[0], PALETTE[1]] }]
  },
  options: { plugins: { title: { display: true, text: 'Revenue: Repeat vs One-Time Buyers', font: { size: 13, weight: '700' }, color: NAVY }, legend: { position: 'bottom' } } }
});

/* ---- Age group data table + charts ---- */
const ageData = [
  { group: "20's Customer", visited: 1328, buyers: 623, conv: 46.91, repeated: 172, retention: 27.61, churn: 44, churnRate: 7.06, revenue: 7751143, share: 16.56 },
  { group: "30's Customer", visited: 1214, buyers: 537, conv: 44.23, repeated: 134, retention: 24.95, churn: 33, churnRate: 6.15, revenue: 6458010, share: 13.80 },
  { group: "40's Customer", visited: 1157, buyers: 523, conv: 45.20, repeated: 152, retention: 29.06, churn: 30, churnRate: 5.74, revenue: 6598649, share: 14.10 },
  { group: "50's Customer", visited: 1152, buyers: 555, conv: 48.18, repeated: 164, retention: 29.55, churn: 34, churnRate: 6.13, revenue: 6870009, share: 14.68 },
  { group: "Old Age Customers (60+)", visited: 2920, buyers: 1373, conv: 47.02, repeated: 392, retention: 28.55, churn: 85, churnRate: 6.19, revenue: 17440454, share: 37.26 },
  { group: "Teenage Customer", visited: 229, buyers: 110, conv: 48.03, repeated: 37, retention: 33.64, churn: 9, churnRate: 8.18, revenue: 1693148, share: 3.62 },
];

(function fillAgeTable() {
  const tbody = document.querySelector('#ageTable tbody');
  if (!tbody) return;
  ageData.forEach(d => {
    tbody.innerHTML += `<tr><td>${d.group}</td><td>${d.visited.toLocaleString()}</td><td>${d.buyers.toLocaleString()}</td><td>${d.conv}%</td><td>${d.repeated}</td><td>${d.retention}%</td><td>${d.churn}</td><td>${d.churnRate}%</td><td>₹${d.revenue.toLocaleString('en-IN')}</td><td>${d.share}%</td></tr>`;
  });
  const totalRev = ageData.reduce((s, d) => s + d.revenue, 0);
  tbody.innerHTML += `<tr><td>TOTAL</td><td>8,000</td><td>3,721</td><td>46.51%</td><td>1,051</td><td>28.25%</td><td>235</td><td>6.32%</td><td>₹${totalRev.toLocaleString('en-IN')}</td><td>100%</td></tr>`;
})();

makeChart('chartAgeFunnel', {
  type: 'bar',
  data: {
    labels: ageData.map(d => d.group.replace(' Customer', '').replace(' Customers', '')),
    datasets: [
      { label: 'Visited', data: ageData.map(d => d.visited), backgroundColor: '#3B82F6', borderRadius: 6 },
      { label: 'Buyers', data: ageData.map(d => d.buyers), backgroundColor: '#F59E0B', borderRadius: 6 },
      { label: 'Repeated', data: ageData.map(d => d.repeated), backgroundColor: '#10B981', borderRadius: 6 }
    ]
  },
  options: { plugins: { title: { display: true, text: 'Visited / Buyers / Repeated by Age', font: { size: 13, weight: '700' }, color: NAVY } }, scales: { x: { grid: { display: false } } } }
});

makeChart('chartAgeConversion', {
  type: 'bar',
  data: {
    labels: ageData.map(d => d.group.replace(' Customer', '').replace(' Customers', '')),
    datasets: [{ label: 'Conversion %', data: ageData.map(d => d.conv), backgroundColor: PALETTE, borderRadius: 6 }]
  },
  options: { plugins: { title: { display: true, text: 'Conversion Rate by Age Group', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } }, scales: { y: { min: 40, max: 50 } } }
});

/* ---- Vision type ---- */
makeChart('chartVisionType', {
  type: 'pie',
  data: {
    labels: ['Bifocal (25.5%)', 'Near (24.9%)', 'Distance (24.9%)', 'Progressive (24.8%)'],
    datasets: [{ data: [2043, 1989, 1988, 1980], backgroundColor: [VISION_COLORS.Bifocal, VISION_COLORS.Near, VISION_COLORS.Distance, VISION_COLORS.Progressive] }]
  },
  options: { plugins: { title: { display: true, text: 'Distribution of Vision Types', font: { size: 13, weight: '700' }, color: NAVY }, legend: { position: 'bottom' } } }
});

/* ---- Payment mode ---- */
makeChart('chartPayment', {
  type: 'bar',
  data: {
    labels: ['Cash', 'Card', 'UPI'],
    datasets: [{ label: 'Revenue (₹)', data: [16196941, 15674327, 14940145], backgroundColor: [PALETTE[0], PALETTE[1], PALETTE[2]], borderRadius: 8 }]
  },
  options: { plugins: { title: { display: true, text: 'Revenue Collected by Payment Mode', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } } }
});

/* ---- Revenue by Vision Type ---- */
makeChart('chartVisionRevenue', {
  type: 'doughnut',
  data: {
    labels: ['Progressive (26% — ₹121.06L)', 'Distance (25% — ₹117.82L)', 'Bifocal (25% — ₹117.32L)', 'Near (24% — ₹111.91L)'],
    datasets: [{ data: [121.06, 117.82, 117.32, 111.91], backgroundColor: [VISION_COLORS.Progressive, VISION_COLORS.Distance, VISION_COLORS.Bifocal, VISION_COLORS.Near] }]
  },
  options: { plugins: { title: { display: true, text: 'Revenue by Vision Type (₹ Lakh)', font: { size: 13, weight: '700' }, color: NAVY }, legend: { position: 'bottom', labels: { font: { size: 10.5 } } } } }
});

/* ---- New vs Referral revenue ---- */
makeChart('chartNewReferral', {
  type: 'doughnut',
  data: {
    labels: ['New Customers (90% — ₹420.47L)', 'Referral Customers (10% — ₹47.64L)'],
    datasets: [{ data: [420.47, 47.64], backgroundColor: [PALETTE[0], PALETTE[3]] }]
  },
  options: { plugins: { title: { display: true, text: 'Revenue Contribution: New vs Referral', font: { size: 13, weight: '700' }, color: NAVY }, legend: { position: 'bottom' } } }
});

/* ---- Top 50 age distribution ---- */
makeChart('chartTop50Age', {
  type: 'bar',
  data: {
    labels: ['Old Age', "20's", "40's", "50's", "30's", 'Teenage'],
    datasets: [{ label: 'Count in Top 50', data: [16, 9, 9, 6, 5, 5], backgroundColor: PALETTE, borderRadius: 8 }]
  },
  options: { plugins: { title: { display: true, text: 'Top 50 Customers by Age Group', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } } }
});

makeChart('chartLoyaltyBreakdown', {
  type: 'doughnut',
  data: {
    labels: ['Top 50 Revenue (4.64%)', 'Rest of Business (95.36%)'],
    datasets: [{ data: [4.64, 95.36], backgroundColor: [PALETTE[3], '#2A3450'] }]
  },
  options: { plugins: { title: { display: true, text: 'Top 50 Share of Total Revenue', font: { size: 13, weight: '700' }, color: NAVY }, legend: { position: 'bottom' } } }
});

/* ---- Churn charts ---- */
makeChart('chartChurnType', {
  type: 'bar',
  data: {
    labels: ['First-Time Buyers', 'Repeated Customers'],
    datasets: [
      { label: 'Total', data: [2670, 1051], backgroundColor: '#3B82F6', borderRadius: 8 },
      { label: 'Churned', data: [1380, 235], backgroundColor: '#F87171', borderRadius: 8 }
    ]
  },
  options: { plugins: { title: { display: true, text: 'Churn: First-Time vs Repeat Buyers', font: { size: 13, weight: '700' }, color: NAVY } } }
});

makeChart('chartChurnAge', {
  type: 'bar',
  data: {
    labels: ["20's", "30's", "40's", "50's", 'Old Age', 'Teenage'],
    datasets: [
      { label: 'First-Time Churn', data: [248, 207, 189, 197, 504, 35], backgroundColor: '#F59E0B', borderRadius: 6 },
      { label: 'Repeat Churn', data: [44, 33, 30, 34, 85, 9], backgroundColor: '#F87171', borderRadius: 6 }
    ]
  },
  options: { plugins: { title: { display: true, text: 'Churned Customers by Age Group', font: { size: 13, weight: '700' }, color: NAVY } } }
});

/* ---- Referral charts ---- */
makeChart('chartReferralAge', {
  type: 'bar',
  data: {
    labels: ["20's", "30's", "40's", "50's", 'Old Age (60+)', 'Teenage'],
    datasets: [{ label: 'Referral Revenue (₹L)', data: [7.34, 7.32, 6.10, 6.91, 18.40, 1.56], backgroundColor: PALETTE, borderRadius: 8 }]
  },
  options: { plugins: { title: { display: true, text: 'Referral Revenue by Age Group', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } } }
});

makeChart('chartReferrerType', {
  type: 'doughnut',
  data: {
    labels: ['Non-Buyer Referrers (56%)', 'Buyer Referrers (44%)'],
    datasets: [{ data: [56, 44], backgroundColor: [PALETTE[4], PALETTE[0]] }]
  },
  options: { plugins: { title: { display: true, text: 'Revenue by Referrer Type', font: { size: 13, weight: '700' }, color: NAVY }, legend: { position: 'bottom' } } }
});

/* ---- Staff charts ---- */
makeChart('chartStaffRevenue', {
  type: 'bar',
  data: {
    labels: ['Gautam C.', 'Anmol G.', 'Utkarsh H.', 'Tara S.', 'Dhriti M.', 'Neelima S.'],
    datasets: [{ label: 'Revenue (₹L)', data: [26.82, 25.50, 25.01, 24.79, 24.79, 18.36], backgroundColor: PALETTE, borderRadius: 8 }]
  },
  options: { plugins: { title: { display: true, text: 'Top & Bottom Revenue — Staff (₹ Lakh)', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } } }
});

makeChart('chartStaffConversion', {
  type: 'bar',
  data: {
    labels: ['Tara Swamy', 'Gautam C.', 'Sai Keer', 'Luke Kata', 'Owen N.', 'Neelima Sibal'],
    datasets: [{ label: 'Conversion %', data: [50.52, 49.77, 49.35, 48.48, 48.37, 39.68], backgroundColor: PALETTE, borderRadius: 8 }]
  },
  options: { plugins: { title: { display: true, text: 'Conversion Rate Range — Staff', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } } }
});

/* ---- Product charts ---- */
makeChart('chartProductRevenue', {
  type: 'bar',
  data: {
    labels: ['Glass', 'Lens Solution', 'Sunglass', 'Frame', 'Contact Lens'],
    datasets: [{ label: 'Revenue (₹L)', data: [148.49, 77.88, 76.79, 74.85, 73.83], backgroundColor: PALETTE, borderRadius: 8 }]
  },
  options: { plugins: { title: { display: true, text: 'Revenue by Product Category (₹ Lakh)', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } } }
});

makeChart('chartProductQty', {
  type: 'doughnut',
  data: {
    labels: ['Glass', 'Sunglass', 'Lens Solution', 'Frame', 'Contact Lens'],
    datasets: [{ data: [3980, 2040, 2038, 1984, 1968], backgroundColor: PALETTE }]
  },
  options: { plugins: { title: { display: true, text: 'Units Sold by Product Category', font: { size: 13, weight: '700' }, color: NAVY }, legend: { position: 'bottom' } } }
});

/* ---- Brand charts ---- */
makeChart('chartBrandFrame', {
  type: 'bar',
  data: {
    labels: ['Calvin Klein', 'Local Brand', 'Essilor', 'K&D', 'Prada', 'Ray Ban', 'NOVA'],
    datasets: [{ label: 'Units Sold', data: [220, 216, 212, 208, 198, 180, 177], backgroundColor: PALETTE, borderRadius: 6 }]
  },
  options: { indexAxis: 'y', plugins: { title: { display: true, text: 'Frame — Units Sold by Brand', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } } }
});

makeChart('chartBrandSunglass', {
  type: 'bar',
  data: {
    labels: ['Local Brand', 'Ray Ban'],
    datasets: [{ label: 'Units Sold', data: [1021, 1019], backgroundColor: [PALETTE[0], PALETTE[1]], borderRadius: 8 }]
  },
  options: { plugins: { title: { display: true, text: 'Sunglasses — Local Brand vs Ray-Ban', font: { size: 13, weight: '700' }, color: NAVY }, legend: { display: false } } }
});

/* ========================================================
   SCHEMA BOX CLICK (mini info)
======================================================== */
document.querySelectorAll('.schema-box').forEach(box => {
  box.addEventListener('click', () => {
    box.style.transform = 'scale(0.97)';
    setTimeout(() => box.style.transform = '', 150);
  });
});

/* ========================================================
   HORIZONTAL NAVIGATION ARROW
   ======================================================== */

document.addEventListener("DOMContentLoaded", () => {

    const navLinks = document.getElementById("navLinks");
    const navScrollNext = document.getElementById("navScrollNext");

    if (!navLinks || !navScrollNext) return;

    function updateNavArrow() {

        const maxScrollLeft =
            navLinks.scrollWidth - navLinks.clientWidth;

        // Hide arrow when there is nothing left to scroll
        if (navLinks.scrollLeft >= maxScrollLeft - 5) {
            navScrollNext.classList.add("hidden");
        } else {
            navScrollNext.classList.remove("hidden");
        }
    }

    navScrollNext.addEventListener("click", () => {

        // Find the first navigation item that is currently
        // partially or completely outside the visible area
        const links = [...navLinks.querySelectorAll(":scope > a")];

        const containerLeft = navLinks.getBoundingClientRect().left;
        const containerRight = navLinks.getBoundingClientRect().right;

        const nextHiddenLink = links.find(link => {

            const rect = link.getBoundingClientRect();

            return rect.right > containerRight + 5;
        });

        if (nextHiddenLink) {

            const linkLeft =
                nextHiddenLink.offsetLeft;

            navLinks.scrollTo({
                left: linkLeft - 20,
                behavior: "smooth"
            });

        } else {

            // Fallback: scroll by one navigation step
            navLinks.scrollBy({
                left: 280,
                behavior: "smooth"
            });
        }

        // Update arrow state after scrolling
        setTimeout(updateNavArrow, 450);
    });

    // Update arrow when user manually scrolls
    navLinks.addEventListener("scroll", updateNavArrow);

    // Initial state
    updateNavArrow();

});