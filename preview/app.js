/* AI Taksi · Telegram-inspired OFFLINE prototype.
 * All sample records are fictional. No API, SMS, payment or GPS requests are made.
 */
const iconPaths={
 home:'<path d="m3 10 9-7 9 7v10a1 1 0 0 1-1 1h-5v-7H9v7H4a1 1 0 0 1-1-1z"/>',
 search:'<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
 car:'<path d="m5 12 2-6h10l2 6M5 12h14l2 3v4H3v-4l2-3Z"/><path d="M7 19v2M17 19v2M7 15h1M16 15h1"/>',
 bus:'<rect x="5" y="3" width="14" height="17" rx="3"/><path d="M5 11h14M8 17h2M14 17h2M7 20v2M17 20v2"/>',
 pin:'<path d="M20 10c0 5-8 12-8 12S4 15 4 10a8 8 0 1 1 16 0Z"/><circle cx="12" cy="10" r="2.5"/>',
 place:'<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
 calendar:'<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 10h18M8 15h3"/>',
 bell:'<path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9ZM10 21h4"/>',
 person:'<circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/>',
 chat:'<path d="M21 11a8 8 0 0 1-8 8 10 10 0 0 1-4-.9L3 21l2-5A8 8 0 1 1 21 11Z"/>',
 star:'<path d="m12 2 3.2 6.4 7 1-5 4.9 1.2 7L12 18l-6.4 3.3 1.2-7-5-4.9 7-1L12 2Z"/>',
 chevron:'<path d="m9 18 6-6-6-6"/>',
 back:'<path d="m15 18-6-6 6-6M9 12h12"/>',
 arrow:'<path d="M4 12h16m-6-6 6 6-6 6"/>',
 check:'<path d="m4 12 5 5L20 6"/>',
 close:'<path d="M5 5 19 19M19 5 5 19"/>',
 clock:'<circle cx="12" cy="12" r="9"/><path d="M12 7v5l4 2"/>',
 users:'<circle cx="9" cy="8" r="3"/><path d="M3 19v-2a6 6 0 0 1 12 0v2H3ZM17 5a3 3 0 0 1 0 6M17 14a5 5 0 0 1 4 5"/>',
 shield:'<path d="m12 2 9 4v6c0 5-4 9-9 10-5-1-9-5-9-10V6l9-4Z"/><path d="m8 12 3 3 5-6"/>',
 money:'<rect x="2" y="5" width="20" height="14" rx="2"/><circle cx="12" cy="12" r="3"/><path d="M5 9h2M17 15h2"/>',
 bookmark:'<path d="M6 3h12v18l-6-4-6 4V3Z"/>',
 moon:'<path d="M20 16a8 8 0 0 1-12-12 8 8 0 1 0 12 12Z"/>',
 sun:'<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
 logout:'<path d="M10 3H4v18h6M14 7l5 5-5 5M8 12h11"/>',
 edit:'<path d="m3 17 11-11 4 4-11 11-4 1 1-5Zm9-9 4 4M15 5l2-2 4 4-2 2"/>',
 plus:'<path d="M12 4v16M4 12h16"/>',
 minus:'<path d="M4 12h16"/>',
 route:'<circle cx="6" cy="18" r="2"/><circle cx="18" cy="5" r="2"/><path d="M8 18h5c7 0 1-8 5-11M12 10H8c-4 0-4 4-4 4"/>',
 train:'<rect x="5" y="3" width="14" height="16" rx="3"/><path d="M5 11h14M8 15h2M14 15h2M8 19l-2 3M16 19l2 3"/>',
 building:'<path d="M4 22V4l9-2v20M13 8h7v14M7 7h2M7 11h2M7 15h2M16 12h2M16 16h2M2 22h20"/>',
 lock:'<rect x="4" y="10" width="16" height="12" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3M12 15v2"/>',
 send:'<path d="m22 2-7 20-4-9-9-4L22 2ZM11 13 22 2"/>',
 share:'<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><path d="M9 11l6-5M9 13l6 5"/>',
 chart:'<path d="M4 20V12M10 20V8M16 20V4M22 20V10"/>',
 settings:'<circle cx="12" cy="12" r="3"/><path d="m9.5 2-.4 2.4-2 1-2.1-1.2-2 3.4 2 1.4v2.2l-2 1.5 2 3.3 2.2-1.2 2 1 .3 2.3h4.5l.4-2.4 2-1 2.1 1.2 2-3.3-2-1.5V9l2-1.4-2-3.4-2.2 1.2-2-1L14 2H9.5Z"/>',
 volume:'<path d="M4 9h4l5-4v14l-5-4H4V9ZM17 9l5 6M22 9l-5 6"/>',
 woman:'<circle cx="12" cy="8" r="5"/><path d="M12 13v8M8 17h8"/>',
 filter:'<path d="M4 6h16M7 12h10M10 18h4"/>',
 info:'<circle cx="12" cy="12" r="10"/><path d="M12 11v6M12 7h.01"/>',
 trophy:'<path d="M7 3h10v7a5 5 0 0 1-10 0V3ZM7 6H3v2a5 5 0 0 0 4 5M17 6h4v2a5 5 0 0 1-4 5M12 15v5M8 20h8"/>',
 refresh:'<path d="M20 7v5h-5M4 17v-5h5M5 9a7 7 0 0 1 12-3l3 4M19 15a7 7 0 0 1-12 3l-3-4"/>',
};
const I=(name,size=22)=>`<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${iconPaths[name]||iconPaths.info}</svg>`;
const esc=(v)=>String(v??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const origins=[['kosonsoy','Kosonsoy','Tuman markazi'],['toraqorgon','To‘raqo‘rg‘on','Markaziy bekat · demo'],['chust','Chust','Shahar markazi · demo'],['yangiqorgon','Yangiqo‘rg‘on','Markaziy bekat · demo'],['pop','Pop','Markaziy bekat · demo'],['namangan','Namangan','Shahar markazi']];
const destinations=[
 ['yuksalish','Yuksalish · NamDU kampusi','Davlatobod, Yuksalish massivi','Universitet'],
 ['namdu','Namangan davlat universiteti','Asosiy kampus · NamDU','Universitet'],
 ['texnika','Namangan davlat texnika universiteti','NamDTU','Universitet'],
 ['pedagogika','Namangan davlat pedagogika instituti','Pedagogika yo‘nalishlari','Universitet'],
 ['ubs','University of Business and Science','Namangan kampusi','Universitet'],
 ['davlatobod','Davlatobod markazi','Shahar hududi','Shahar'],
 ['shahar','Namangan shahar markazi','Markaziy hudud','Shahar'],
 ['vokzal','Namangan temir yo‘l vokzali','Vokzal','Transport'],
 ['avtovokzal','Namangan avtovokzali','Avtovokzal · demo','Transport'],
 ['bozor','Chorsu bozori','Savdo hududi · demo','Shahar'],
 ['shifoxona','Namangan tibbiyot markazi','Tibbiyot hududi · demo','Shahar'],
];
const stops=['Kosonsoy markazi','Kosonsoy dehqon bozori','Kosonsoy janub','29-maktab oldi · demo','To‘raqo‘rg‘on bekati · demo','Yangiqo‘rg‘on chorrahasi · demo','Namangan kirish','Davlatobod bekati'];
const vehicles=[['cobalt','Chevrolet Cobalt','Yengil',3,32000,4.8],['onix','Chevrolet Onix','Yengil',3,39000,4.9],['byd','BYD e2','Yengil',3,42000,4.9],['damas','Chevrolet Damas','Damas',8,20000,4.9],['sprinter','Mercedes Sprinter','Avtobus',14,19000,4.8],['isuzu','Isuzu SAZ','Avtobus',22,17000,4.7],['yutong','Yutong','Avtobus',28,15000,4.8]];
const offers=[
 ['A-201','kosonsoy','yuksalish','Sherzod','damas','01 A 123 BC','10:40',8,20000,5],
 ['A-202','kosonsoy','namdu','Islom','damas','50 B 227 CA','11:20',7,21000,7],
 ['A-203','toraqorgon','texnika','Javohir','cobalt','50 A 443 BK','07:30',3,33000,9],
 ['A-204','chust','pedagogika','Dilshod','sprinter','50 M 556 BA','08:10',12,19000,6],
 ['A-205','kosonsoy','ubs','Komil','onix','50 N 102 BB','07:45',3,38000,12],
 ['A-206','kosonsoy','davlatobod','Oybek','isuzu','50 R 872 BC','06:50',20,16000,11],
 ['A-207','yangiqorgon','vokzal','Ulug‘bek','byd','50 S 113 NA','09:30',3,41000,14],
 ['A-208','pop','avtovokzal','Alisher','yutong','50 K 378 BC','08:00',24,15000,10],
 ['A-209','namangan','shifoxona','Sardor','cobalt','50 H 992 BB','12:30',2,12000,13],
 ['A-210','kosonsoy','shahar','Bekzod','damas','50 A 111 AB','16:10',6,23000,8],
 ['A-211','toraqorgon','yuksalish','Farrux','sprinter','50 G 431 DA','09:10',11,20000,5],
 ['A-212','chust','bozor','Akmal','damas','50 P 557 BB','15:30',8,22000,7],
];
const history=[['18 noy','Kosonsoy → Yuksalish','Sherzod','Damas',20000],['16 noy','Kosonsoy → NamDU','Islom','Damas',21000],['13 noy','To‘raqo‘rg‘on → NamDTU','Javohir','Cobalt',33000],['11 noy','Kosonsoy → Davlatobod','Oybek','Isuzu',16000],['09 noy','Kosonsoy → Namangan','Komil','Onix',38000],['06 noy','Chust → NamDU','Dilshod','Sprinter',19000],['04 noy','Yangiqo‘rg‘on → Vokzal','Ulug‘bek','BYD',41000],['02 noy','Kosonsoy → Yuksalish','Sherzod','Damas',20000],['30 okt','Kosonsoy → NamDU','Islom','Damas',21000],['28 okt','Pop → Avtovokzal','Alisher','Yutong',15000]];
const notifications=[['Yuksalish yo‘nalishi','23-noyabrga yangi Damas taklifi','09:42','car'],['Safarni tasdiqlang','Bugun borasizmi? Javobni tanlang.','Kecha','calendar'],['Yangi bekatlar','Davlatobod va To‘raqo‘rg‘on · demo','18 noy','pin'],['Yangi transport turlari','Cobalt, Damas, Sprinter va Yutong','17 noy','bus'],['Xavfsizlik','Telefon raqamlari chatga yuborilmaydi','15 noy','shield'],['Baholash eslatmasi','Oldingi safaringizni baholang','12 noy','star'],['Ilova yangilandi','Yorug‘ va tungi rejim tayyor','10 noy','settings']];
const DEFAULT={logged:false,role:'rider',name:'Aziza',dark:false,tab:0,origin:'kosonsoy',dest:'yuksalish',pickup:stops[0],time:'13:00',days:[0,2],ride:'question',rating:0,groupSize:8,chat:[['Sherzod','Assalomu alaykum! 10:40 da bekatdaman.','10:28'],['Aziza','Rahmat, kutyapman.','10:29']],offerDecisions:{},picked:{},prices:{3:32000,8:20000,14:19000,22:17000,28:15000},favorites:['yuksalish','namdu'],womenOnly:false,quietRide:false,notifsRead:false,otp:false,overlay:null,cat:'Barchasi',search:'',driverFilter:'Barchasi'};
let s=Object.assign({},DEFAULT);
try{const p=JSON.parse(localStorage.getItem('aitaksi_telegram_demo_v1')||'null');if(p)s={...DEFAULT,...p,overlay:null,otp:false};}catch(e){}
const persist=()=>{try{localStorage.setItem('aitaksi_telegram_demo_v1',JSON.stringify({...s,overlay:null,otp:false}));}catch(e){}};
const originName=(id)=>(origins.find(x=>x[0]===id)||[0,id])[1];
const destName=(id)=>(destinations.find(x=>x[0]===id)||[0,id])[1];
const vehicle=(id)=>vehicles.find(v=>v[0]===id)||vehicles[3];
const fmt=(n)=>Number(n).toLocaleString('fr-FR').replace(/\u202f/g,' ');
const avatar=(text,ico='car',color='')=>`<div class="avatar ${color}">${I(ico,22)}</div>`;
const pill=(txt,kind='',ico='')=>`<span class="pill ${kind}">${ico?I(ico,12):''}${esc(txt)}</span>`;
const section=(title,extra='',act='')=>`<div class="section-head"><span>${title}</span>${extra?`<button data-action="${act}">${extra}</button>`:''}</div>`;
const button=(text,action,klass='btn',extra='')=>`<button class="${klass}" data-action="${action}" ${extra}>${text}</button>`;
const listRow=(ico,title,sub,act,right='')=>`<div class="listrow" role="button" tabindex="0" data-action="${act}">${avatar(title,ico)}<div class="grow"><div class="name">${esc(title)}</div><div class="desc">${esc(sub)}</div></div><div class="rt">${right||`<span class="chev">${I('chevron',18)}</span>`}</div></div>`;
const roleLabels=()=>['Asosiy',s.role==='driver'?'Takliflar':'Yo‘nalishlar',s.role==='driver'?'Tariflar':'Safarlar','Profil'];
const navIcons=()=>s.role==='driver'?['home','car','money','person']:['home','pin','calendar','person'];
const screenTitle=()=> s.role==='driver'?['Boshqaruv','Safar takliflari','Mening tariflarim','Profil'][s.tab]:['AI Taksi','Yo‘nalishlar','Mening safarlarim','Profil'][s.tab];
const header=()=>`<div class="topbar"><img class="appmark" src="assets/ai_taksi_icon_full.png" alt="Logo"><div class="app-title">${screenTitle()}</div><div class="top-right"><span class="demo-dot">DEMO</span>${s.tab===0&&s.role==='rider'?`<button class="icon-btn" title="Qidirish" data-action="tab" data-value="1">${I('search')}</button>`:''}<button class="icon-btn" title="Bildirishnomalar" data-action="overlay" data-value="notifications">${I('bell')}</button></div></div>`;
const foot=()=>`<div class="bottombar">${roleLabels().map((l,i)=>`<button class="navitem ${s.tab===i?'active':''}" data-action="tab" data-value="${i}">${I(navIcons()[i])}<span>${l}</span></button>`).join('')}</div>`;
const systemnav=()=>`<div class="systemnav"><span></span></div>`;
function renderLogin(){return `<div class="screen"><div class="login"><div style="text-align:right"><button class="icon-btn" data-action="theme" title="Mavzu">${I(s.dark?'sun':'moon')}</button></div><img class="login-logo" src="assets/ai_taksi_icon_full.png" alt="AI Taksi ilova belgisi"/><h2>AI Taksi</h2><p>Bir yo‘lda — birga, yanada qulay.</p><div style="text-align:center">${pill('OFFLINE DEMO','','info')}</div><div class="card"><div class="subheading" style="margin:0">Demo hisobingiz</div><div class="tiny muted" style="margin-top:5px">SMS yuborilmaydi. Test hisobni tanlang.</div><div class="role-buttons"><button data-action="role" data-value="rider" class="role ${s.role==='rider'?'active':''}">${I('person')}Yo‘lovchi</button><button data-action="role" data-value="driver" class="role ${s.role==='driver'?'active':''}">${I('car')}Haydovchi</button></div><div class="tiny bold" style="margin:0 0 7px">Ismingiz</div><input id="login-name" class="field" value="${esc(s.name)}" placeholder="Aziza" maxlength="45"/>${s.otp?`<div class="tiny bold" style="margin:14px 0 7px">Demo SMS kodi</div><input id="login-code" class="field" inputmode="numeric" maxlength="6" placeholder="123456"/> <div style="margin-top:8px">${pill('Sinov kodi: 123456','','lock')}</div>`:''}<div class="space"></div><button class="btn" style="width:100%" data-action="login">${s.otp?'Kod orqali kirish':'Demo sifatida kirish'} &nbsp;→</button><button class="btn soft" style="width:100%;margin-top:7px" data-action="otp">${s.otp?'Tez kirishga qaytish':'SMS kod kirishini sinash'}</button></div><p style="font-size:11px;line-height:1.5;margin-top:4px">Bu versiyada haqiqiy taksi, to‘lov, SMS yoki telefon raqamlaridan foydalanilmaydi.</p></div></div>`;}
function renderHome(){
 const matching=offers.filter(o=>o[1]===s.origin||o[2]===s.dest).slice(0,4);
 const statuses={question:['Bugun yo‘lga chiqasizmi?','Dushanba, 23 noyabr · test kuni'],offered:['Safar taklifi tayyor','Guruh va narxni ko‘ring'],confirmed:['Safaringiz tasdiqlandi','Damas · 10:40'],active:['Safar davom etmoqda','Haydovchi: Sherzod · demo'],completed:['Safar yakunlandi','Haydovchini baholashingiz mumkin'],declined:['Bugun bormaysiz','Istasangiz qayta tanlang']};
 const st=statuses[s.ride];
 return `<div class="title">Salom, ${esc(s.name)} 👋</div><div class="muted sm" style="margin-bottom:15px">Bugungi safaringizni birga rejalaymiz</div><div class="hero"><img src="assets/sunset_minibus.webp" alt="Sunset road with white minibus"><div class="hero-copy"><small>AI TAKSI / 2026</small><strong>Bir yo‘lda,<br>birga qulayroq.</strong><span>Kosonsoy · Namangan va boshqa yo‘nalishlar</span></div></div>${section('Yo‘nalishingiz')}<div class="card"><div class="route-row" data-action="sheet" data-value="origin"><div class="route-marker"><span></span><i></i></div><div class="texts"><small>Qayerdan</small><strong>${esc(originName(s.origin))}</strong></div><span class="chev">${I('chevron',17)}</span></div><div class="route-row" data-action="sheet" data-value="destination"><div class="route-marker"><b></b></div><div class="texts"><small>Qayerga</small><strong>${esc(destName(s.dest))}</strong></div><span class="chev">${I('chevron',17)}</span></div><div class="minis"><div class="mini">${I('clock')}<div><div class="lab">Yetib borish</div><div class="val">${esc(s.time)}</div></div></div><div class="mini">${I('users')}<div><div class="lab">Guruh</div><div class="val">${s.groupSize} kishi</div></div></div></div></div>
 ${section('Kundalik tasdiq')}<div class="card"><div class="row">${avatar('Kun','calendar')}<div class="grow"><strong style="font-size:15px">${st[0]}</strong><div class="muted sm" style="margin-top:4px">${st[1]}</div></div></div><div class="space"></div>${s.ride==='question'?`<div class="button-row">${button('✓ Ha, boraman','going','btn')}${button('Yo‘q','skip','btn ghost')}</div>`:button(s.ride==='declined'?'Qayta tanlash':'Safarni ko‘rish',s.ride==='declined'?'reset-ride':'to-trips','btn','style="width:100%"')}</div>
 ${section('Yaqin safar takliflari','Barchasi','to-dest')}<div class="card" style="padding:3px 13px">${matching.map(o=>listRow(vehicle(o[4])[3]>8?'bus':'car',destName(o[2]),`${o[6]} · ${vehicle(o[4])[1]} · ${o[7]} kishi`,`trip:${o[0]}`,`<div class="price">${fmt(o[8])}</div><div class="muted tiny">so‘m</div>`)).join('')}</div>
 ${section('Tezkor kirish')}<div class="quick-actions"><button class="quick" data-action="overlay" data-value="schedule">${I('calendar')}<span>Jadvalim</span></button><button class="quick" data-action="overlay" data-value="fleet">${I('car')}<span>Avtopark</span></button><button class="quick" data-action="overlay" data-value="safety">${I('shield')}<span>Xavfsizlik</span></button></div>`;
}
function renderDest(){const categories=['Barchasi','Universitet','Shahar','Transport','Saqlangan'];
 const list=destinations.filter(p=>(s.cat==='Barchasi'||(s.cat==='Saqlangan'&&s.favorites.includes(p[0]))||p[3]===s.cat)&&`${p[1]} ${p[2]}`.toLowerCase().includes(s.search.toLowerCase()));
 return `<div class="search">${I('search')}<input id="dest-search" placeholder="Manzil, universitet, hudud qidirish..." value="${esc(s.search)}"/></div><div class="filters">${categories.map(c=>`<button class="chip ${s.cat===c?'active':''}" data-action="category" data-value="${c}">${c}</button>`).join('')}</div>${section('Manzillar',`${list.length} ta`)}${list.length?`<div class="card" style="padding:3px 13px">${list.map(p=>listRow(p[3]==='Universitet'?'building':p[3]==='Transport'?'train':'pin',p[1],p[2],`dest:${p[0]}`,`<button class="icon-btn" data-action="favorite" data-value="${p[0]}" title="Saqlangan">${I('bookmark',19)}</button>${s.dest===p[0]?`<span style="color:var(--accent)">${I('check',18)}</span>`:''}`)).join('')}</div>`:`<div class="card empty">${I('search',42)}<strong>Topilmadi</strong>Boshqa nom bilan qidirib ko‘ring.</div>`}${section('Boshqa jo‘nash hududlari')}<div class="card" style="padding:3px 13px">${origins.map(p=>listRow('pin',p[1],p[2],`origin:${p[0]}`,s.origin===p[0]?`<span style="color:var(--accent)">${I('check')}</span>`:'' )).join('')}</div><div class="footnote">Barcha manzillar va transport takliflari mock ma’lumot. Haqiqiy joylashuv aniqlanmagan.</div>`;
}
function renderTrips(){
 return `${section('Joriy safar')}<div class="card"><div class="row">${avatar('S','car')}<div class="grow"><div class="bold med">${esc(destName(s.dest))}</div><div class="sm muted">${esc(originName(s.origin))} · ${esc(s.time)} gacha</div></div>${pill(({question:'Kutilmoqda',offered:'Taklif bor',confirmed:'Tasdiqlangan',active:'Yo‘lda',completed:'Yakunlangan',declined:'Bekor'})[s.ride])}</div><div class="line"></div><div class="row sm" style="padding:7px 0">${I('person',17)} <span class="muted grow">Haydovchi</span><b>Sherzod · Damas</b></div><div class="row sm" style="padding:7px 0">${I('clock',17)} <span class="muted grow">Olib ketish</span><b>10:40</b></div><div class="row sm" style="padding:7px 0">${I('pin',17)} <span class="muted grow">Bekat</span><b>${esc(s.pickup)}</b></div><div class="row sm" style="padding:7px 0">${I('money',17)} <span class="muted grow">Narx</span><b style="color:var(--accent)">20 000 so‘m</b></div><div class="space"></div>${s.ride==='question'?button('Bugun boraman','going','btn','style="width:100%"'):s.ride==='offered'?`<div class="button-row">${button('Tasdiqlash','confirm-trip')}${button('Rad etish','decline-trip','btn ghost')}</div>`:s.ride==='confirmed'?button('Safarni boshlash · demo','start-trip','btn','style="width:100%"'):s.ride==='active'?button('Safarni yakunlash · demo','finish-trip','btn','style="width:100%"'):s.ride==='declined'?button('Qayta rejalashtirish','reset-ride','btn soft','style="width:100%"'):`<div class="center"><div class="bold">${s.rating?`Rahmat! Baho: ${s.rating} / 5`:'Safarni baholang'}</div><div class="stars">${[1,2,3,4,5].map(i=>`<button class="starbutton" data-action="rate" data-value="${i}">${i<=s.rating?'★':'☆'}</button>`).join('')}</div>${button('Yangi demo safar','reset-ride','btn soft')}</div>`}${['confirmed','active','completed'].includes(s.ride)?`<div class="sp8"></div>${button(I('chat',16)+' Safar chati','overlay','btn ghost','data-value="chat" style="width:100%"')}`:''}</div>${section('Safar tarixi',`${history.length} ta`)}<div class="card" style="padding:3px 13px">${history.map(h=>listRow('route',h[1],`${h[0]} · ${h[3]} · ${h[2]}`,'history',`<strong class="sm">${fmt(h[4])}</strong>`)).join('')}</div>`;
}
function renderDriver(){return `<div class="row" style="margin:4px 0 18px">${avatar(s.name,'person')}<div class="grow"><div class="title" style="font-size:20px;margin:0">Salom, ${esc(s.name)}</div><div class="muted sm">Bugungi ish kuningiz · demo</div></div>${pill('Faol','green','check')}</div><div class="earnings"><small>Bugungi daromad · demo</small><strong>280 000 so‘m</strong><div class="growth">${I('chart',16)} &nbsp; +12% o‘tgan haftaga nisbatan</div></div><div class="space"></div><div class="statgrid"><div class="stat">${I('car')}<strong>5</strong><small>Taklif</small></div><div class="stat">${I('route')}<strong>3</strong><small>Safar</small></div><div class="stat">${I('star')}<strong>4.9</strong><small>Reyting</small></div></div>${section('Yangi takliflar','Barchasi','to-offers')}<div class="card" style="padding:3px 13px">${offers.filter(o=>!s.offerDecisions[o[0]]).slice(0,4).map(o=>listRow(vehicle(o[4])[3]>8?'bus':'car',destName(o[2]),`${o[6]} · ${o[7]} kishi · ${vehicle(o[4])[1]}`,`trip:${o[0]}`,`<span class="price">${fmt(o[8])}</span>`)).join('')}</div>${section('Tezkor amallar')}<div class="card" style="padding:3px 13px">${listRow('money','Narxlar','Guruh hajmi bo‘yicha tariflar','to-prices')}${listRow('route','Bekatlar ketma-ketligi','Qabul qilingan safarni ko‘rish','pickup:A-201')}</div>`;}
function renderDriverOffers(){
 const fs=['Barchasi','Yangi','Qabul qilingan','Rad etilgan'];const sel=offers.filter(o=>s.driverFilter==='Barchasi'||(s.driverFilter==='Yangi'&&!s.offerDecisions[o[0]])||(s.driverFilter==='Qabul qilingan'&&s.offerDecisions[o[0]]==='accepted')||(s.driverFilter==='Rad etilgan'&&s.offerDecisions[o[0]]==='declined'));
 return `<div class="filters" style="margin-top:0">${fs.map(f=>`<button data-action="driver-filter" data-value="${f}" class="chip ${s.driverFilter===f?'active':''}">${f}</button>`).join('')}</div><div class="row" style="justify-content:space-between;margin:14px 0">${pill('OFFLINE DEMO','','info')}<span class="muted tiny">${sel.length} ta taklif</span></div>${sel.length?sel.map(o=>{const d=s.offerDecisions[o[0]];return `<div class="list-card"><div class="offer-top">${avatar(o[3],vehicle(o[4])[3]>8?'bus':'car')}<div class="grow"><div class="name">${esc(destName(o[2]))}</div><div class="desc">${esc(originName(o[1]))} · ${o[6]}</div></div>${d?pill(d==='accepted'?'Qabul qilindi':'Rad etildi',d==='accepted'?'green':'red'):pill(`0${o[9]}:00`,'','clock')}</div><div class="line" style="margin-top:14px"></div><div class="row sm">${I('users',16)} ${o[7]} kishi &nbsp; ${I('clock',16)} ${o[6]}<div class="grow"></div><div class="price">${fmt(o[8])} so‘m</div></div><div class="space"></div>${d?'':`<div class="button-row">${button('Qabul qilish',`accept:${o[0]}`)}${button('Rad etish',`decline:${o[0]}`,'btn ghost')}</div>`}<div style="text-align:right;margin-top:10px"><button class="icon-btn" style="width:auto;font-size:12px;color:var(--accent);gap:5px;display:inline-flex" data-action="pickup" data-value="${o[0]}">${I('route',16)} Bekatlar</button></div></div>`}).join(''):`<div class="card empty">${I('car',42)}<strong>Taklif topilmadi</strong>Bu filtrda taklif yo‘q.</div>`}`;
}
function renderTariffs(){const prs=Object.entries(s.prices).sort((a,b)=>+a[0]-+b[0]);return `<div class="card row">${avatar('i','info')}<div class="muted sm grow" style="line-height:1.5">Narxlar guruhdagi yo‘lovchilar soniga bog‘liq. Bular haqiqiy tarif emas, sinov qiymatlar.</div></div>${section('Bir yo‘lovchi uchun')}<div class="card" style="padding:3px 13px">${prs.map(([k,v])=>listRow('money',`1–${k} yo‘lovchi`,`${fmt(v)} so‘m / kishi`,`price:${k}`,`<span class="price">${fmt(v)}</span>&nbsp;${I('edit',16)}`)).join('')}</div>${section('Transport toifalari')}<div class="card" style="padding:3px 13px">${listRow('car','Yengil','1–3 yo‘lovchi','nothing')}${listRow('car','Damas','4–8 yo‘lovchi','nothing')}${listRow('bus','Avtobus','9+ yo‘lovchi','nothing')}</div>`;}
function renderProfile(){return `<div class="card"><div class="profilehero">${avatar(s.name,'person')}<div class="grow"><div class="title" style="font-size:19px;margin:0">${esc(s.name)}</div><div class="muted sm" style="margin:4px 0 7px">${s.role==='rider'?'Yo‘lovchi':'Haydovchi'} · test hisob</div>${pill('OFFLINE DEMO')}</div></div></div>${section('Sozlamalar')}<div class="card"><div class="switchrow" data-action="theme"><div style="color:var(--accent)">${I(s.dark?'sun':'moon')}</div><div class="grow">Tungi rejim<div class="desc">Telegram uslubidagi mavzu</div></div><div class="toggle ${s.dark?'on':''}"><span></span></div></div>${listRow('bell','Bildirishnomalar','Mock ogohlantirishlar','overlay-notifications')}${listRow('bookmark','Saqlangan manzillar',`${s.favorites.length} ta manzil`,'to-dest')}${listRow('shield','Xavfsizlik markazi','Maskali aloqa, SOS konsepsiyasi','overlay-safety')}</div>${section('Safar afzalliklari')}<div class="card"><div class="switchrow" data-action="women"><div style="color:var(--accent)">${I('woman')}</div><div class="grow">Faqat ayollar guruhi<div class="desc">Demo sozlama</div></div><div class="toggle ${s.womenOnly?'on':''}"><span></span></div></div><div class="switchrow" data-action="quiet"><div style="color:var(--accent)">${I('volume')}</div><div class="grow">Tinch safar<div class="desc">Demo haydovchi ko‘rsatmasi</div></div><div class="toggle ${s.quietRide?'on':''}"><span></span></div></div></div>${section('Demo vositalari')}<div class="card">${listRow('refresh','Rejimni almashtirish','Yo‘lovchi ↔ haydovchi', 'role-switch')}${listRow('settings','Mock holatni tiklash','O‘zgartirishlarni bekor qilish','reset')}${listRow('logout','Hisobdan chiqish','Istalgan vaqtda qayta kiring','logout')}</div><div class="footnote center">AI Taksi · Telegram uslubidagi mustaqil dizayn. Telegram bilan bog‘liq emas. Barcha ma’lumot sinov uchun.</div>`;}
function screen(){if(s.role==='driver')return [renderDriver,renderDriverOffers,renderTariffs,renderProfile][s.tab]();return [renderHome,renderDest,renderTrips,renderProfile][s.tab]();}
function overlayFrame(title,content,footer=''){return `<div class="overlay"><div class="back-header"><button class="icon-btn" data-action="back" title="Orqaga">${I('back')}</button><div class="grow">${esc(title)}</div></div><div class="screen">${content}</div>${footer}${systemnav()}</div>`;}
function sheetFrame(title,body){return `<div class="sheet-overlay" data-action="back"><div class="sheet" data-stop="1"><div class="sheet-handle"></div><h3>${esc(title)}</h3>${body}</div></div>`;}
function renderOverlay(){if(!s.overlay)return '';const [kind,id]=s.overlay.split(':');
 if(kind==='sheet'){
  const data=id==='origin'?origins:id==='destination'?destinations:stops.map((x,i)=>[String(i),x,'Bekat · demo']);
  return sheetFrame(({origin:'Jo‘nash hududi',destination:'Borish manzili',pickup:'Olib ketish bekati'})[id],data.map(p=>listRow('pin',p[1],p[2],`choose-${id}:${p[0]}`)).join(''));
 }
 if(kind==='schedule')return overlayFrame('Haftalik reja',`<div class="card"><div class="subheading">Qaysi kunlari qatnaysiz?</div><div class="days">${['Du','Se','Ch','Pa','Ju','Sh','Ya'].map((d,i)=>`<button class="day ${s.days.includes(i)?'active':''}" data-action="day" data-value="${i}">${d}</button>`).join('')}</div><div class="selector" data-action="sheet" data-value="origin">${I('pin')}<div class="grow"><strong>Jo‘nash hududi</strong><small>${esc(originName(s.origin))}</small></div>${I('chevron',18)}</div><div class="selector" data-action="sheet" data-value="destination">${I('pin')}<div class="grow"><strong>Manzil</strong><small>${esc(destName(s.dest))}</small></div>${I('chevron',18)}</div><div class="selector" data-action="sheet" data-value="pickup">${I('place')}<div class="grow"><strong>Olib ketish bekati</strong><small>${esc(s.pickup)}</small></div>${I('chevron',18)}</div><div class="selector">${I('clock')}<div class="grow"><strong>Yetib borish vaqti</strong><small>${esc(s.time)}</small></div><input aria-label="Yetib borish vaqti" type="time" id="schedule-time" value="${esc(s.time)}" class="field" style="width:120px;padding:7px"/></div><div class="space"></div>${button('Rejani saqlash','save-schedule','btn','style="width:100%"')}</div><div class="footnote">Ushbu jadval faqat sizning qurilmangizdagi mock holatga ta’sir qiladi.</div>`);
 if(kind==='fleet'){const kind=s.groupSize<=3?'Yengil':s.groupSize<=8?'Damas':'Avtobus';return overlayFrame('Avtopark · demo',`<div class="card"><strong>Guruhingizda nechta kishi?</strong><div class="row" style="justify-content:center;gap:20px;margin:17px 0"><button class="btn ghost" data-action="group-minus">${I('minus')}</button><div class="center"><div class="title" style="font-size:30px;color:var(--accent)">${s.groupSize}</div><div class="muted sm">${kind}</div></div><button class="btn ghost" data-action="group-plus">${I('plus')}</button></div><div class="muted tiny">1–3 Yengil · 4–8 Damas · 9+ Avtobus</div></div>${section('Transport modellari')}${vehicles.map(v=>`<div class="list-card"><div class="row">${avatar(v[1],v[3]>8?'bus':'car')}<div class="grow"><strong class="med">${v[1]}</strong><div class="muted tiny">${v[2]} · ${v[3]} o‘rin · ★ ${v[5]}</div><div style="margin-top:5px">${pill(v[2]===kind&&v[3]>=s.groupSize?'Mos variant':'Namuna',v[2]===kind&&v[3]>=s.groupSize?'green':'gray')}</div></div><div class="price">${fmt(v[4])}<div class="muted tiny thin">so‘m/kishi</div></div></div></div>`).join('')}<div class="footnote">Narx va transport mavjudligi real emas.</div>`);}
 if(kind==='notifications')return overlayFrame('Bildirishnomalar',`${button('Hammasi o‘qildi','notifs-read','btn soft','style="width:100%"')}<div class="space"></div><div class="card" style="padding:3px 13px">${notifications.map(n=>listRow(n[3],n[0],`${n[1]} · ${n[2]}`,'notifs-read',s.notifsRead?'':`<span style="display:inline-block;width:8px;height:8px;background:var(--accent);border-radius:50%"></span>`)).join('')}</div>`);
 if(kind==='safety')return overlayFrame('Xavfsizlik markazi',`<div class="card"><div class="row">${avatar('X','shield')}<div class="grow"><strong>Xavfsizlik birinchi o‘rinda</strong><div class="muted sm" style="margin-top:6px">Haydovchilar tekshiruvi, maskali aloqa va monitoring — loyiha konsepsiyasi.</div></div></div></div>${section('Himoya funksiyalari')}<div class="card" style="padding:3px 13px">${listRow('lock','Telefon raqamlari yashirin','Chat raqam, @username va havolalarni bloklaydi','nothing')}${listRow('shield','Tekshirilgan haydovchi','Real ilovada admin tekshiruvi kerak','nothing')}${listRow('share','Safarni ulashish','Havola hozircha yaratilmaydi','demo-share')}${listRow('shield','SOS yordam','Haqiqiy ogohlantirish yuborilmaydi','demo-sos')}</div>`);
 if(kind==='chat'){const canChat=['confirmed','active','completed'].includes(s.ride)||Object.values(s.offerDecisions).some(x=>x==='accepted');return overlayFrame('Safar guruhi · demo',`<div class="pill" style="display:flex;white-space:normal">${I('lock',16)} Telefon, @username va havola yuborish mumkin emas.</div><div class="space"></div><div class="center">${pill('23 NOV · DEMO','gray')}</div><div class="space"></div>${s.chat.map(m=>`<div class="message ${m[0]==='Siz'||m[0]===s.name||m[0]==='Aziza'?'mine':''}"><div class="bubble"><div class="who">${esc(m[0])}</div><div>${esc(m[1])}</div><div class="time">${esc(m[2])}</div></div></div>`).join('')}`,`<div class="chatinput"><input id="chat-field" placeholder="${canChat?'Xabar yozing...':'Chat safar tasdiqlangach ochiladi'}" ${canChat?'':'disabled'}/><button data-action="chat-send" ${canChat?'':'disabled'} aria-label="Yuborish">${I('send')}</button></div>`);}
 if(kind==='trip'){const o=offers.find(x=>x[0]===id);if(!o)return '';const d=s.offerDecisions[id];return overlayFrame(`Safar ${o[0]}`,`<div class="card"><div class="row">${avatar(o[3],'person')}<div class="grow"><strong>${esc(o[3])}</strong><div class="muted sm">${vehicle(o[4])[1]} · ★ 4.9</div></div>${pill('Tekshirilgan','','shield')}</div><div class="space"></div><div class="line"></div><div class="listrow"><span class="muted grow">Qayerdan</span><strong class="sm">${esc(originName(o[1]))}</strong></div><div class="listrow"><span class="muted grow">Qayerga</span><strong class="sm">${esc(destName(o[2]))}</strong></div><div class="listrow"><span class="muted grow">Mashina raqami</span><strong class="sm">${o[5]}</strong></div><div class="listrow"><span class="muted grow">Jo‘nash</span><strong class="sm">${o[6]} · demo</strong></div><div class="listrow"><span class="muted grow">Yo‘lovchilar</span><strong class="sm">${o[7]} kishi</strong></div><div class="space"></div><div class="row"><div class="muted sm grow">Bir kishi uchun</div><div class="price" style="font-size:20px">${fmt(o[8])} so‘m</div></div><div class="space"></div>${s.role==='driver'?(d?pill(d==='accepted'?'Qabul qilindi':'Rad etildi',d==='accepted'?'green':'red'):`<div class="button-row">${button('Qabul qilish',`accept:${id}`)}${button('Rad etish',`decline:${id}`,'btn ghost')}</div>`):button('Safarni tasdiqlash · demo',`rider-offer:${id}`,'btn','style="width:100%"')}</div>${section('Safar bekatlari')}<div class="card" style="padding:3px 13px">${['Olib ketish bekati','Yo‘l bo‘yi bekati','Namangan kirish',destName(o[2])].map((t,i)=>listRow('pin',t,`Bekat ${i+1} · demo`,'nothing')).join('')}</div>`);}
 if(kind==='pickup'){const o=offers.find(x=>x[0]===id)||offers[0];return overlayFrame(`Bekatlar · ${o[0]}`,`<div class="card"><strong>${esc(originName(o[1]))} → ${esc(destName(o[2]))}</strong><div class="muted sm" style="margin-top:7px">${o[7]} yo‘lovchi · ${o[6]} · ${o[5]}</div></div>${section('Olib ketish ketma-ketligi')}<div class="card" style="padding:3px 13px">${[o[1]+' markazi','Yo‘l bo‘yi bekati','Namangan kirish',destName(o[2])].map((p,i)=>listRow(s.picked[`${id}-${i}`]?'check':'pin',p,`Bekat ${i+1} · demo`,`pick:${id}-${i}`,s.picked[`${id}-${i}`]?pill('Bajarildi','green'):pill('Belgilang'))).join('')}</div><div class="space"></div>${button('Guruh chati','overlay-chat','btn ghost','style="width:100%"')}`);}
 if(kind==='price')return sheetFrame('Tarifni o‘zgartirish',`<div class="tiny muted">1–${id} yo‘lovchi uchun narx (so‘m)</div><div class="space"></div><input id="price-field" class="field" type="number" min="1000" max="500000" value="${s.prices[id]}"/><div class="space"></div>${button('Saqlash',`price-save:${id}`,'btn','style="width:100%"')}`);
 return '';
}
function render(){const app=document.getElementById('app');const phone=document.getElementById('phone');phone.classList.toggle('dark',!!s.dark);app.innerHTML=`<div class="status"><span>9:41</span><small>▰ ▰ ●</small></div>${s.logged?`${header()}<div class="screen" id="main-screen">${screen()}</div>${foot()}${systemnav()}`:renderLogin()+systemnav()}${renderOverlay()}`;persist();}
function snack(message){let el=document.getElementById('snack');if(el)el.remove();el=document.createElement('div');el.id='snack';el.textContent=message;el.style.cssText='position:absolute;left:16px;right:16px;bottom:86px;background:#243f59;color:white;border-radius:11px;padding:12px 15px;font:600 12px system-ui;z-index:30;box-shadow:0 8px 25px #0003';document.getElementById('phone').appendChild(el);setTimeout(()=>el.remove(),2600);}
const close=()=>{s.overlay=null;render();};
function act(a,v,el){
 if(a==='theme'){s.dark=!s.dark;render();return;}
 if(a==='role'){s.role=v;s.name=v==='driver'?'Sherzod':'Aziza';render();return;}
 if(a==='otp'){s.otp=!s.otp;render();return;}
 if(a==='login'){const name=document.getElementById('login-name')?.value.trim();if(s.otp&&document.getElementById('login-code')?.value.trim()!=='123456'){snack('Demo kod: 123456');return;}s.name=(name|| (s.role==='driver'?'Sherzod':'Aziza')).slice(0,45);s.logged=true;s.tab=0;render();return;}
 if(a==='logout'){s.logged=false;s.overlay=null;render();return;}
 if(a==='tab'){s.tab=+v;s.search='';render();return;}
 if(a==='to-dest'){s.tab=1;render();return;}
 if(a==='to-offers'){s.tab=1;render();return;}
 if(a==='to-trips'){s.tab=2;render();return;}
 if(a==='to-prices'){s.tab=2;render();return;}
 if(a==='going'){s.ride='offered';render();return;}
 if(a==='skip'){s.ride='declined';render();return;}
 if(a==='confirm-trip'){s.ride='confirmed';render();return;}
 if(a==='decline-trip'){s.ride='declined';render();return;}
 if(a==='start-trip'){s.ride='active';render();return;}
 if(a==='finish-trip'){s.ride='completed';render();return;}
 if(a==='reset-ride'){s.ride='question';s.rating=0;render();return;}
 if(a==='rate'){s.rating=+v;render();return;}
 if(a==='category'){s.cat=v;render();return;}
 if(a==='favorite'){s.favorites=s.favorites.includes(v)?s.favorites.filter(x=>x!==v):[...s.favorites,v];render();return;}
 if(a==='driver-filter'){s.driverFilter=v;render();return;}
 if(a==='role-switch'){s.role=s.role==='driver'?'rider':'driver';s.tab=0;render();return;}
 if(a==='women'){s.womenOnly=!s.womenOnly;render();return;}
 if(a==='quiet'){s.quietRide=!s.quietRide;render();return;}
 if(a==='reset'){s={...DEFAULT,logged:true,role:s.role,name:s.name,dark:s.dark};render();snack('Demo holati tiklandi');return;}
 if(a==='nothing'||a==='history'){snack('Bu ko‘rinish demo ma’lumot bilan to‘ldirilgan.');return;}
 if(a==='notifs-read'||a==='overlay-notifications'){s.notifsRead=true;if(a.startsWith('overlay'))s.overlay='notifications';render();return;}
 if(a==='demo-share'||a==='demo-sos'){snack(a==='demo-sos'?'Bu demo SOS yubormaydi.':'Haqiqiy havola yuborilmaydi.');return;}
 if(a==='overlay'||a.startsWith('overlay-')){s.overlay=a==='overlay'?v:a.slice('overlay-'.length);render();return;}
 if(a==='sheet'){s.overlay=`sheet:${v}`;render();return;}
 if(a==='back'){close();return;}
 if(a==='day'){const i=+v;s.days=s.days.includes(i)?s.days.filter(x=>x!==i):[...s.days,i];render();return;}
 if(a==='save-schedule'){if(!s.days.length){snack('Kamida bitta kunni belgilang.');return;}s.time=document.getElementById('schedule-time')?.value||s.time;close();snack('Haftalik reja saqlandi · demo');return;}
 if(a==='group-minus'){s.groupSize=Math.max(1,s.groupSize-1);render();return;}
 if(a==='group-plus'){s.groupSize=Math.min(28,s.groupSize+1);render();return;}
 if(a==='chat-send'){const value=document.getElementById('chat-field')?.value.trim()||'';if(!value)return;
   const digits=value.replace(/\D/g,'');if(digits.length>=9||/@[A-Za-z0-9_]{2,}/.test(value)||/https?:\/\/|www\.|t\.me\b/i.test(value)){
      snack('Telefon, @username va havola yuborilmaydi.');return;}
   const canChat=['confirmed','active','completed'].includes(s.ride)||Object.values(s.offerDecisions).some(x=>x==='accepted');if(!canChat){snack('Avval safarni tasdiqlang.');return;}
   s.chat.push(['Siz',value.slice(0,400),'10:35']);render();return;}
 if(a.startsWith('price:')){s.overlay=`price:${a.slice(6)}`;render();return;}
 if(a.startsWith('price-save:')){const n=+document.getElementById('price-field')?.value;if(!Number.isFinite(n)||n<1000||n>500000){snack('1 000–500 000 so‘m oralig‘ida narx kiriting');return;}s.prices[a.slice(11)]=n;close();snack('Tarif saqlandi · demo');return;}
 if(a==='pickup'){s.overlay=`pickup:${v}`;render();return;}
 if(a.startsWith('pick:')){const id=a.slice(5);s.picked[id]=!s.picked[id];render();return;}
 if(a.startsWith('accept:')){s.offerDecisions[a.slice(7)]='accepted';render();return;}
 if(a.startsWith('decline:')){s.offerDecisions[a.slice(8)]='declined';render();return;}
 if(a.startsWith('rider-offer:')){s.ride='confirmed';close();snack('Safar tasdiqlandi · demo');return;}
 if(a.startsWith('trip:')){s.overlay=`trip:${a.slice(5)}`;render();return;}
 if(a.startsWith('dest:')){s.dest=a.slice(5);s.tab=0;render();snack('Manzil tanlandi');return;}
 if(a.startsWith('origin:')){s.origin=a.slice(7);render();return;}
 if(a.startsWith('choose-origin:')){s.origin=a.slice(14);close();snack('Hudud tanlandi');return;}
 if(a.startsWith('choose-destination:')){s.dest=a.slice(19);close();snack('Manzil tanlandi');return;}
 if(a.startsWith('choose-pickup:')){s.pickup=stops[+a.slice(14)]||stops[0];close();snack('Bekat tanlandi');return;}
}
document.addEventListener('click',e=>{const elem=e.target.closest('[data-action]');if(!elem)return;if(e.target.closest('[data-stop]')&&elem.classList.contains('sheet-overlay'))return;e.preventDefault();e.stopPropagation();act(elem.dataset.action,elem.dataset.value||'',elem);});
document.addEventListener('input',e=>{if(e.target.id==='dest-search'){s.search=e.target.value;const start=e.target.selectionStart;render();const n=document.getElementById('dest-search');if(n){n.focus();try{n.setSelectionRange(start,start);}catch(_){}}}});
document.addEventListener('keydown',e=>{if(e.key==='Escape'&&s.overlay)close();if(e.key==='Enter'&&e.target.id==='chat-field')act('chat-send');if(e.key==='Enter'&&e.target.closest('[data-action]')){e.target.click();}});
render();
