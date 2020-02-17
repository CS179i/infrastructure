const helpers = require("./helpers");
const firebase = require("@firebase/testing");
const fs = require("fs");

// Setup unit tests
const rules = fs.readFileSync("database.rules.json", "utf8");

// Load rules and cleanup when complete.
before(async () => {
    await firebase.loadDatabaseRules({
        databaseName: "opa-test",
        rules: rules
    });
});

beforeEach(async () => {
    await firebase.initializeAdminApp({
        databaseName: "opa-test"
    }).database().ref().set(null);
});

after(async () => {
    await Promise.all(firebase.apps().map(app => app.delete()));
});

// Unit tests
describe("user creation", () => {
    var alice = null;
    var bob = null;
    
    it("should allow a user to create themselves", async () => {
        alice = await helpers.createUser("alice", "Alice Smith", "normal");
        bob = await helpers.createUser("bob", "Bob Smith", "normal");

        await firebase.assertSucceeds(alice.ref("users/alice").once("value"));
        await firebase.assertSucceeds(bob.ref("users/bob").once("value"));
    });

    it("should only allow a user to edit themselves", async () => {
        await firebase.assertFails(
            alice.ref("users/bob").update({"name": "Jane Doe"})
        );

        await firebase.assertFails(
            bob.ref("users/alice").update({"name": "John Smith"})
        );
    });
});

describe("event rules", () => {
    var alice = null;
    var bob = null;

    it("should allow users to create events", async () => {
        alice = await helpers.createUser("alice", "Alice Smith", "manager");
        bob = await helpers.createUser("bob", "Bob Smith", "manager");

        await helpers.createEvent(alice, "alice", "test");
        await firebase.assertSucceeds(alice.ref("events/test").once("value"));
    });
});
