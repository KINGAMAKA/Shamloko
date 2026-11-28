const C='shamloko-v6-profile-actions-2026-11-28',ASSETS=['./','index.html','icon-192.png'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(C).then(c=>c.addAll(ASSETS)).catch(()=>{}));self.skipWaiting();});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==C).map(x=>caches.delete(x)))));self.clients.claim();});
self.addEventListener('fetch',e=>{const r=e.request,u=new URL(r.url);if(r.method!=='GET'||u.origin!==location.origin)return;e.respondWith(fetch(r,{cache:'no-store'}).then(res=>{if(res.ok){const copy=res.clone();caches.open(C).then(c=>c.put(r,copy));}return res;}).catch(()=>caches.match(r).then(m=>m||caches.match('index.html'))));});
