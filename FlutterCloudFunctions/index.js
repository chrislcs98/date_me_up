const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp(functions.config().functions);

let newMatch;
let user;
const payload = {
  notification: {
    title: "It's a Match",
    body: " liked you",
    sound: "default",
  },
  data: {
    click_action: "FLUTTER_NOTIFICATION_CLICK",
  },
};


exports.triggerOnCreate = functions.firestore.document("matches/{id}")
    .onCreate(async (snapshot, context) => {
      sendNotification(snapshot);
    });

exports.triggerOnUpdate = functions.firestore.document("matches/{id}")
    .onUpdate( (snapshot, context) => {
      sendNotification(snapshot);
    });

/**
 * Send Notification
 * @param {snapshot} snapshot
 */
function sendNotification(snapshot) {
  if (snapshot.empty) {
    console.log("No Matches!");
    return;
  }

  newMatch = snapshot.data();

  if (newMatch.twoWays) {
    user = admin.firestore().collection("users")
        .doc(newMatch.senderUId).get();

    payload["notification"]["body"] = user.name +
        payload["notification"]["body"] + "back!";
  } else {
    user = admin.firestore().collection("users")
        .doc(newMatch.receiverUId).get();

    payload["notification"]["title"] = "Match";
    payload["notification"]["body"] = user.name +
        payload["notification"]["body"] + "!";
  }


  try {
    admin.messaging().sendToDevice(user.deviceToken, payload);
    console.log("Notification sent successfully!");
  } catch (err) {
    console.log(err);
  }
}

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
