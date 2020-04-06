const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// sendWifiConnectedMessage detects when a new user's Reef has successfully connected to Wi-Fi for the
// first time and sends a notification to their device
exports.sendWifiConnectedMessage = functions.database.ref('/Users/{uid}/WiFiLastConnected/').onCreate( (snap, context) => {
	const uuid = context.params.uid;

	// Print out user's ID who is receiving the notification
	console.log('Send notification to user with UID:', uuid);

	// Get the reference node to retrieve the users messaging token
	var ref = admin.database().ref('/Users/' + uuid + '/UserData/FCMtoken');

	// Once the token value has been read, compose the notification and send it to the user's device
	return ref.once('value', function(snapshot) {
         const payload = {
              notification: {
                  title: 'Wi-Fi successfully connected!',
                  body: 'Reef is now connected to your local Wi-Fi.'
              }
         };

         admin.messaging().sendToDevice(snapshot.val(), payload)

    }, function (errorObject) {
        console.log("The read failed: " + errorObject.code);
    });

});


exports.sendBasinLowMessage = functions.database.ref('{uid}/BasinLevels/Nutrient').onWrite( (change, context) => {
	const uuid = context.params.uid;

	return admin.database().ref(uuid + '/BasinLevels/Nutrient').once('value').then( function(snapshot) {
		const level = snapshot.val();
		console.log("Nutrient Value updated " + level);

		if (level < 10) {

			console.log("Value is less than 10");
			// Get the reference node to retrieve the users messaging token
			var ref = admin.database().ref(uuid + '/UserData/FCMtoken');

			// Once the token value has been read, compose the notification and send it to the user's device
			return ref.once('value', function(snap) {
         		const payload = {
              	notification: {
                  title: 'Nutrient Level Low',
                  body: 'Reef nutrients are getting low. Refill soon.'
              	}
         	};

         	admin.messaging().sendToDevice(snap.val(), payload)

    		}, function (errorObject) {
        		console.log("The read failed: " + errorObject.code);
    		});
         }
		return snapshot.val();
	});

});

	


// initializeDatabase stores the initial values for a user's Reef Ecosystem once the user
// is Authorized by Firebase
exports.initializeDatabase = functions.auth.user().onCreate((user) => {
	// Retrieve User's UID from user object
	const uuid = user.uid;

	// Initialize aquariumFull branch in user's database
	admin.database().ref('/Users/' + uuid + '/ReefSettings/aquariumFull').set(0);
	// Initialize dayHours branch in user's database
	admin.database().ref('/Users/' + uuid + '/ReefSettings/dayHours').set(0);
	// Initialize sunrise branch in user's database
	admin.database().ref('/Users/' + uuid + '/ReefSettings/sunrise').set('7:00');
	// Initialize aquariumRGB branch in user's database
	admin.database().ref('/Users/' + uuid + '/ReefSettings/aquariumRGB').set('255,255,255');

	// Initialize Basin Levels branch in user's database
	admin.database().ref('/Users/' + uuid + '/ReefSettings/BasinLevels/nutrients').set(0);
	admin.database().ref('/Users/' + uuid + '/ReefSettings/BasinLevels/phUp').set(0);
	admin.database().ref('/Users/' + uuid + '/ReefSettings/BasinLevels/phDown').set(0);

});

/// Deletes all data in firebase realtime database when a user is deleted
exports.removeAllData = functions.auth.user().onDelete((user) => {
	// Retrieve User's UID from user object
	const uuid = user.uid;
	// Deletee user's entire data tree
	admin.database().ref('/Users/' + uuid).remove();
});


