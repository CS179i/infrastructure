const firebase = require("@firebase/testing");

function getApp(uid, user_type) {
    return firebase.initializeTestApp({
        databaseName: "opa-test",
        auth: {
            uid,
            user_type: true
        }
    }).database();
}

module.exports = {
    createUser: async function(uid, name, user_type) {
        const app = getApp(uid, user_type);
        await app.ref("users/" + uid).set({
            name,
            events: {},
            connections: {},
            managed_events: {}
        });

        return app;
    },
    createEvent: async function(user, uid, event_id) {
        await user.ref("events/" + event_id).set({
            manager: uid,
            expires: new Date().getTime() + 100000,
            questionnaire: {},
            users: {}
        });
        
        await user.ref("users/" + uid + "/managed_events").push(event_id);
    }
}
