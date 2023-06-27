importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

const firebaseConfig = {
    apiKey: "AIzaSyAPHBri3-HZb_wjhFCIlVHQ8b7N59pJAjo",
    authDomain: "unilink23.firebaseapp.com",
    databaseURL: "https://unilink23-default-rtdb.europe-west1.firebasedatabase.app",
    projectId: "unilink23",
    storageBucket: "unilink23.appspot.com",
    messagingSenderId: "190649102208",
    appId: "1:190649102208:web:bdcac3f91b382d1f519b65"
};

// Initialize Firebase
const app = firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onMessage((payload) => {
    console.log('Message received. ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
        notificationOptions);
});

messaging.setBackgroundMessageHandler((payload) => {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});