const firebase = require("@firebase/testing");
const fs = require("fs");

// Setup unit tests
const dbname = "opa-test";
const rules = fs.readFileSync("database.rules.json", "utf8");

function getApp(uid) {
    return firebase.initializeTestApp({
        databaseName: dbname, 
        auth: {uid: uid}
    }).database();
}

// Load rules and cleanup when complete.
before(async () => {
    await firebase.loadDatabaseRules({
        databaseName: dbname,
        rules: rules
    });
});

beforeEach(async () => {
    await firebase.initializeAdminApp({
        databaseName: dbname
    }).database().ref().set(null);
});

after(async () => {
    await Promise.all(firebase.apps().map(app => app.delete()));
});

// Unit tests
describe("user creation", () => {
    const alice = getApp("alice");
    const bob = getApp("bob");
    
    it("should allow a user to create themselves", async () => {
        await alice.ref("users/alice").set({
            "name": "Alice Smith",
            "events": {},
            "connections": {},
            "managed_events": {}
        });

        await bob.ref("users/bob").set({
            "name": "Bob Smith",
            "events": {},
            "connections": {},
            "managed_events": {}
        });

        await firebase.assertSucceeds(alice.ref("users/alice").once("value"));
        await firebase.assertSucceeds(bob.ref("users/bob").once("value"));
    });

    it("should only allow a user to edit themselves", async () => {
        await firebase.assertFails(
            alice.ref("users/bob").update({"name": "Jane Doe"})
        );
    });
});
