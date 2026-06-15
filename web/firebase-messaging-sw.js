importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyA76dIrldA7VZ6Mj9mkKiS4yN9pzY8GA7g",
  authDomain: "loris-636db.firebaseapp.com",
  projectId: "loris-636db",
  storageBucket: "loris-636db.firebasestorage.app",
  messagingSenderId: "530130998004",
  appId: "1:530130998004:web:b77725e68997f8fff984a1",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[FCM SW] Background message:', payload);
  const title = payload.notification?.title || 'Attendance System';
  const options = {
    body: payload.notification?.body || '',
    icon: '/favicon.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
  };
  return self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      for (const client of clientList) {
        if (client.url.startsWith(self.location.origin) && 'focus' in client) {
          client.focus();
          return;
        }
      }
      clients.openWindow(self.location.origin + '/');
    })
  );
});
