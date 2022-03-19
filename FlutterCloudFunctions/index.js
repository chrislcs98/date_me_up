const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp(functions.config().functions);

let newMatch;
let user;

exports.triggerOnCreate = functions.firestore.document("matches/{id}")
    .onCreate(async (snapshot, context) => {
      sendNotification(snapshot);
      console.log("On Create!");
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
  let uid1;
  let uid2;
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

  if (newMatch["twoWays"]) {
    uid1 = newMatch["senderUId"];
    uid2 = newMatch["receiverUId"];
  } else {
    uid1 = newMatch["receiverUId"];
    uid2 = newMatch["senderUId"];
  }

  console.log("Two-way Match: " + newMatch["twoWays"]);

  admin.firestore().collection("users").doc(uid2)
      .get()
      .then((snapshot) => {
        user = snapshot["_fieldsProto"];

        console.log("User Name: " + user["name"]["stringValue"]);

        if (newMatch["twoWays"]) {
          payload["notification"]["body"] = user["name"]["stringValue"] +
              payload["notification"]["body"] + " back!";
        } else {
          payload["notification"]["title"] = "Match";
          payload["notification"]["body"] = user["name"]["stringValue"] +
              payload["notification"]["body"] + "!";
        }

        admin.firestore().collection("users").doc(uid1)
            .get()
            .then((snapshot) => {
              user = snapshot["_fieldsProto"];

              console.log("User device-token: " +
                  user["deviceToken"]["stringValue"]);
              try {
                if (user["deviceToken"]["stringValue"]) {
                  admin.messaging().sendToDevice(
                      user["deviceToken"]["stringValue"], payload);
                  console.log("Notification sent successfully!");
                } else {
                  console.log("Device token is empty!");
                }
              } catch (err) {
                console.log("Error: " + err);
              }
            });
      });
}

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
