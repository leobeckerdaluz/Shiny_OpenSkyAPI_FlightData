var request = require("request")
var credentials = require('./credentials');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;



function timestamp_to_date(timestamp){
    var date = new Date(timestamp*1000);
    // Hours part from the timestamp
    var hours = date.getHours();
    // Minutes part from the timestamp
    var minutes = "0" + date.getMinutes();
    // Seconds part from the timestamp
    var seconds = "0" + date.getSeconds();
    
    // Will display time in 10:30:23 format
    var formattedTime = hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
    // console.log(formattedTime)
    return (formattedTime)
}

// 1 Function Response Request
var get_response = function (error, response, body){
    if (!error && response.statusCode === 200) {
        var AllStates = []
        for (s in body.states){
            var actual = body.states[s]

            var icao = actual[0]
            var long = actual[5]
            var lat = actual[6]

            if (long && lat){
                // console.log("Deu!!")
                // console.log("Lat: " + lat)
                // console.log("Long: " + long)
                // console.log("-----------------")
                
                var position = {icao24: icao, latitude: lat, longitude: long}
                AllStates.push(position)
            }

            // icao24
            // callsign
            // origin_country
            // time_position
            // last_contact
            // longitude
            // latitude
            // baro_altitude
            // on_ground
            // velocity
            // true_track
            // vertical_rate
            // sensors
            // geo_altitude
            // squawk
            // spi
            // position_source
        }

        console.log(AllStates)

        const csvWriter = createCsvWriter({
            path: "./states.csv",
            header: [
                {id: 'icao24', title: 'ICAO24'},
                {id: 'latitude', title: 'LATITUDE'},
                {id: 'longitude', title: 'LONGITUDE'}
            ]
        });

        csvWriter.writeRecords(AllStates)       // returns a promise
        .then(() => {
            console.log('...Done');
        });
        

        
    }
}   


console.log("--------------------------------------------------------------------------------------------------")
console.log("Consultando todos os estados atuais!\n")

var url = "https://opensky-network.org/api/states/all"

// 1 Request
request({
    url: url,
    json: true
}, get_response)



 