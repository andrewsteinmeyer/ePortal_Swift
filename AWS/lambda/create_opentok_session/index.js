require('dotenv').load()
console.log('api_key: ' + process.env.OPENTOK_API_KEY);
console.log('api_secret: ' + process.env.OPENTOK_SECRET);
var OpenTok = require('opentok'),
    opentok = new OpenTok(process.env.OPENTOK_API_KEY, process.env.OPENTOK_SECRET);
var async = require('async');

// Extract data from the dynamodb event
exports.handler = function(event, context) {

  console.log('Event booyah:' + event);

  // This function handles the dynamodb table update
  function handleUpdate(record, callback) {

    console.log('In handleUpdate son:');
    if (record.eventName == "INSERT") {
      opentok.createSession(function(err, session) {
        // Handle any errors
        console.log('Made that session bro:' + session.sessionId);
        if (err) { console.log("could not create opentok session for broadcast: ") }

        callback();
      });
    }
  };

  // The dynamodb event may contain multiple records in a specific order.
  // Since our handlers are asynchronous, we handle each update in series,
  // calling the parent handler's callback (context.done) upon completion.
  async.eachSeries(event.Records, handleUpdate, context.done)
};

