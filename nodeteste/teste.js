var unirest = require('unirest'); 
unirest.post(API_URL) 
    .header("X-RapidAPI-Key", API_KEY) 
    .end(function (result) { 
        console.log(result.status, result.headers, result.body); 
    });