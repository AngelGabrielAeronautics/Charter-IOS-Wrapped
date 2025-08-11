const OFFLINE_URL = '/offline.html';

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('charter-cache-v1').then((cache) => cache.addAll([OFFLINE_URL]))
  );
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;
  event.respondWith(
    fetch(request).catch(async () => {
      const cache = await caches.open('charter-cache-v1');
      const cached = await cache.match(OFFLINE_URL);
      return cached || Response.error();
    })
  );
});


