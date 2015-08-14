require('dotenv').load()

var OpenTok = require('opentok'),
    opentok = new OpenTok(process.env.OPENTOK_API_KEY, process.env.OPENTOK_SECRET);

exports.handler = function(event, context) {
  //Try to generate Opentok session
  console.log(event);

  opentok.createSession(function(err, session) {
    if (err) {
      context.fail();
    } else {
      console.log('sessionId:' + session.sessionId);
      context.succeed(session.sessionId);
    }
  });
};

