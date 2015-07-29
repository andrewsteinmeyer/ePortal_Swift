require('dotenv').load()
var async = require('async');

var Firebase = require('firebase'),
    ref = new Firebase(process.env.FIREBASE_AUTH_URL);

var FirebaseTokenGenerator = require('firebase-token-generator'),
    tokenGenerator = new FirebaseTokenGenerator(process.env.FIREBASE_SECRET);


exports.handler = function(event, context) {
  //Try to generate Firebase token and login to database
  async.waterfall([
    function generateFirebaseToken(next) {
      //generate token
      var token = tokenGenerator.createToken({uid: "cognito:1", some: "arbitrary", data: "here"});

      if (token) {
        next(null, token);
      }
      else {
        next('Could not retrieve Firebase token');
      }
    },
    function loginToFirebase(token, next) {
      //attempt to login to firebase
      ref.authWithCustomToken(token, function(err, authData) {
        if (err) {
          next(err);
        } else {
          next(null, authData);
        }
      });
    }
  ], function (err, authData) {
      var response = '';

      if (err) {
        response = 'Could not login to Firebase with token provided due to error: ' + err;
        console.log(response);
      }
      else {
        response = authData;
      }

      context.done();
  });
};

