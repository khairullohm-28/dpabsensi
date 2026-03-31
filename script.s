// GANTI URL INI DENGAN URL DEPLOYMENT APPS SCRIPT KAMU YANG BARU!
const GAS_API_URL = "https://script.google.com/macros/s/AKfycby4-fnbo4pflvc3-JlcPa-gHYXklSZsZx-k05h96XgqFDAH2ONzyQfJf-GQmXGXjTfg/exec";

// ==========================================
// 1. JEMBATAN API (Proxy untuk google.script.run)
// ==========================================
const google = {
    script: {
        run: new Proxy({}, {
            get: function(target, prop) {
                if (prop === 'withSuccessHandler' || prop === 'withFailureHandler') {
                    return function(callback) {
                        return createRunner(callback, prop);
                    };
                }
                return createRunner(null, null)[prop];
            }
        })
    }
};

function createRunner(callback, type) {
    let successCb = type === 'withSuccessHandler' ? callback : null;
    let failureCb = type === 'withFailureHandler' ? callback : (err => console.error(err));

    let runner = new Proxy({}, {
        get: function(target, actionName) {
            if (actionName === 'withSuccessHandler') {
                return function(cb) { successCb = cb; return runner; };
            }
            if (actionName === 'withFailureHandler') {
                return function(cb) { failureCb = cb; return runner; };
            }
            
            // Eksekusi pemanggilan ke backend Apps Script
            return function(...args) {
                fetch(GAS_API_URL, {
                    method: 'POST',
                    body: JSON.stringify({ action: actionName, args: args })
                })
                .then(res => res.json())
                .then(data => {
                    if (successCb) successCb(data);
                })
                .catch(err => {
                    if (failureCb) failureCb(err);
                });
            };
        }
    });
    return runner;
}

// ==========================================
// 2. ROUTING (Pengganti URL Parameter)
// ==========================================
const urlParams = new URLSearchParams(window.location.search);
const page = urlParams.get('page') || 'employee';

function renderApp() {
    const root = document.getElementById('app-root');
    
    if (page === 'admin') {
        document.title = "Admin HR";
        root.innerHTML = "<div class='app'><aside class='sidebar'><div class='sidebar-header'><div class='logo-icon'><i data-lucide='briefcase' style='width:22px;height:22px'></i></div><div class='logo-text'><h1 id='sidebar-title'>Admin HR</h1><p>Portal</p></div></div><nav class='nav'><div class='nav-item active' data-page='dashboard' onclick='showPage(\"dashboard\")'><i data-lucide='home'></i><span>Dashboard</span></div><div class='nav-item' data-page='laporan' onclick='showPage(\"laporan\")'><i data-lucide='clipboard-check'></i><span>Rekap Bulanan</span></div><div class='nav-item' data-page='karyawan' onclick='showPage(\"karyawan\")'><i data-lucide='users'></i><span>Data Karyawan</span></div><div class='nav-item' data-page='izin' onclick='showPage(\"izin\")'><i data-lucide='calendar-x'></i><span>Pengajuan Izin</span></div><div class='nav-item' data-page='pengaturan' onclick='showPage(\"pengaturan\")'><i data-lucide='settings'></i><span>Pengaturan</span></div></nav><div class='sidebar-footer'><div class='user'><div class='user-avatar'>HR</div><div class='user-info'>Admin HR<p>Portal Setting</p></div></div></div></aside><main class='main'><div class='topbar'><h2 id='page-title'>Dashboard</h2><div class='topbar-right'><div class='search-box'><i data-lucide='search' style='width:16px;color:var(--gray)'></i><input type='text' placeholder='Cari karyawan...'></div><div class='topbar-icon' onclick='window.location.href=\"?page=employee\"' title='Log Out Admin' style='cursor:pointer'><i data-lucide='log-out' style='width:20px;color:var(--danger)'></i></div></div></div><div class='content' id='main-content'></div></main></div><div class='modal-overlay' id='modal'></div><div class='toast-container' id='toasts'></div>";
        initAdmin();
    } 
    else if (page === 'register') {
        document.title = "Daftar Karyawan";
        root.innerHTML = '<div class="mobile-app"><div style="padding:20px;display:flex;align-items:center;gap:10px;margin-bottom:10px"><i data-lucide="chevron-left" onclick="window.history.back()" style="cursor:pointer"></i><h2 style="font-size:18px;font-weight:700;color:var(--text)">Data Karyawan</h2></div><div style="text-align:center;margin-bottom:30px;position:relative"><div style="width:120px;height:120px;background:#e2e8f0;border-radius:50%;margin:0 auto;overflow:hidden;border:4px solid #fff;box-shadow:0 4px 10px rgba(0,0,0,0.1);position:relative"><img id="preview-img" style="width:100%;height:100%;object-fit:cover;display:none"><div id="placeholder-icon" style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;color:#94a3b8"><i data-lucide="user" style="width:60px;height:60px"></i></div></div><div onclick="document.getElementById(\'file-in\').click()" style="position:absolute;bottom:0;left:50%;transform:translateX(30px);width:40px;height:40px;background:#10b981;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;border:3px solid #fff;cursor:pointer"><i data-lucide="camera" style="width:20px"></i></div><input type="file" id="file-in" hidden accept="image/*" onchange="previewFile(this)"></div><div style="text-align:center;margin-bottom:30px"><h3 style="font-size:18px;font-weight:700">Unggah Foto</h3><p style="color:#10b981;font-size:13px">Pilih foto profil terbaik Anda</p></div><div style="padding:0 20px"><div class="form-group"><label class="form-label">Nama Lengkap</label><div style="position:relative"><input type="text" class="form-input" id="reg-nama" placeholder="Contoh: Budi Santoso" style="padding-right:40px"><i data-lucide="user" style="position:absolute;right:12px;top:12px;width:18px;color:#94a3b8"></i></div></div><div class="form-group"><label class="form-label">Nomor Karyawan</label><div style="position:relative"><input type="text" class="form-input" id="reg-nik" placeholder="Contoh: EMP-12345" style="padding-right:40px"><div style="position:absolute;right:12px;top:12px;display:flex;align-items:center;justify-content:center;background:#94a3b8;color:white;font-size:10px;padding:2px 4px;border-radius:4px;height:18px">123</div></div></div><div style="background:#ecfdf5;border:1px solid #a7f3d0;padding:16px;border-radius:12px;display:flex;gap:12px;margin:30px 0 40px"><i data-lucide="info" style="min-width:20px;color:#10b981"></i><p style="font-size:12px;color:#065f46;line-height:1.5">Pastikan data yang Anda masukkan sudah sesuai dengan kartu identitas resmi perusahaan untuk keperluan administrasi.</p></div><button class="btn btn-primary" id="save-btn" onclick="submitReg()" style="width:100%;height:50px;font-size:16px;background:#10b981;border:none;display:flex;align-items:center;justify-content:center;gap:10px">Simpan Data <i data-lucide="check-circle" style="width:20px"></i></button></div><div id="loading-overlay" style="position:fixed;inset:0;background:rgba(255,255,255,0.9);z-index:99;display:none;flex-direction:column;align-items:center;justify-content:center"><div class="loader"></div><p id="load-text" style="margin-top:20px;font-weight:600;color:#1e293b">Memproses...</p></div></div>';
        initRegister();
    } 
    else {
        document.title = "Portal Karyawan";
        root.innerHTML = "<div class='mobile-app' id='app-container'></div><div class='toast-container' id='toasts'></div>";
        initEmployee();
    }
    lucide.createIcons();
}

// Eksekusi saat web dibuka
document.addEventListener('DOMContentLoaded', renderApp);

// ==========================================
// 3. LOGIKA APLIKASI (Diekstrak dari string JS lama)
// ==========================================

// --- ADMIN LOGIC ---
var currentPage='dashboard';var employees=[];var attendance=[];var izinList=[];var stats={};var appShifts=[];var compName='Admin HR';var filterDivisi='Semua';var colors=['blue','green','orange','purple','cyan'];var filterMonth='';var uploadedImg=null;

function initAdmin() { loadData(); }
function getColor(i){return colors[i%colors.length];}
function getInit(n){if(!n)return'';var p=n.split(' ');if(p.length===1)return p[0].substring(0,2).toUpperCase();return(p[0][0]+p[1][0]).toUpperCase();}
function showPage(p){currentPage=p;document.querySelectorAll('.nav-item').forEach(function(n){n.classList.remove('active');});document.querySelector('[data-page="'+p+'"]').classList.add('active');var t={'dashboard':'Dashboard','laporan':'Rekap Bulanan','karyawan':'Data Karyawan','izin':'Pengajuan Izin','pengaturan':'Pengaturan'};document.getElementById('page-title').textContent=t[p];renderPage();}
function renderPage(){if(currentPage==='dashboard')renderDashboard();else if(currentPage==='laporan')renderLaporan();else if(currentPage==='karyawan')renderKaryawan();else if(currentPage==='izin')renderIzin();else if(currentPage==='pengaturan')renderPengaturan();}

function loadData(){
    google.script.run.withSuccessHandler(function(r){compName=r; document.getElementById('sidebar-title').innerText=r; if(currentPage==='pengaturan'){var setEl=document.getElementById('set-comp-name');if(setEl)setEl.value=r;}}).getCompanySettings();
    google.script.run.withSuccessHandler(function(r){if(r.success)stats=r.stats;renderPage();}).withFailureHandler(function(e){alert('Err Stats:'+e);}).getStats();
    google.script.run.withSuccessHandler(function(r){if(r.success)appShifts=r.data; if(currentPage==='pengaturan')renderPengaturan();}).getShifts(); 
    google.script.run.withSuccessHandler(function(r){if(r.success)izinList=r.data; if(currentPage==='izin')renderIzin();}).getIzinList(); 
    google.script.run.withSuccessHandler(function(r){if(r.success){attendance=r.attendance;renderPage();}else{alert('Server Error: '+r.message);}}).getAttendanceLog();
    google.script.run.withSuccessHandler(function(r){if(r.success)employees=r.employees;renderPage();}).getEmployeeList();
}

// [GABUNGKAN SISA KODE JS ADMIN, EMPLOYEE, DAN REGISTER DI SINI DARI FILE LAMA]
// Karena barisnya ratusan, silakan copy/paste langsung sisa function seperti renderDashboard, renderLaporan, doAbsen, submitIzinForm, dll ke bawah sini tanpa tanda kutip ganda ("").
