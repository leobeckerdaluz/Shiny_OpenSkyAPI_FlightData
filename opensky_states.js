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

            var icao24 = actual[0]
            var callsign = actual[1]
            var origin_country = actual[2]
            var time_position = actual[3]
            var last_contact = actual[4]
            var longitude = actual[5]
            var latitude = actual[6]
            var baro_altitude = actual[7]
            var on_ground = actual[8]
            var velocity = actual[9]
            var true_track = actual[10]
            var vertical_rate = actual[11]
            var sensors = actual[12]
            var geo_altitude = actual[12]
            var squawk = actual[13]
            var spi = actual[14]
            var position_source = actual[15]

            // console.log("Deu!!")
            // console.log("Lat: " + lat)
            // console.log("Long: " + long)
            // console.log("-----------------")
            
            var position = {icao24: icao24, 
                            callsign: callsign,
                            origin_country: origin_country,
                            time_position: time_position,
                            last_contact: last_contact,
                            longitude: longitude,
                            latitude: latitude,
                            baro_altitude: baro_altitude,
                            on_ground: on_ground,
                            velocity: velocity,
                            true_track: true_track,
                            vertical_rate: vertical_rate,
                            sensors: sensors,
                            geo_altitude: geo_altitude,
                            squawk: squawk,
                            spi: spi,
                            position_source: position_source}

            AllStates.push(position)

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
                {id: 'icao24', title: 'icao24'},
                {id: 'callsign', title: 'callsign'},
                {id: 'origin_country', title: 'origin_country'},
                {id: 'time_position', title: 'time_position'},
                {id: 'last_contact', title: 'last_contact'},
                {id: 'longitude', title: 'longitude'},
                {id: 'latitude', title: 'latitude'},
                {id: 'baro_altitude', title: 'baro_altitude'},
                {id: 'on_ground', title: 'on_ground'},
                {id: 'velocity', title: 'velocity'},
                {id: 'true_track', title: 'true_track'},
                {id: 'vertical_rate', title: 'vertical_rate'},
                {id: 'sensors', title: 'sensors'},
                {id: 'geo_altitude', title: 'geo_altitude'},
                {id: 'squawk', title: 'squawk'},
                {id: 'spi', title: 'spi'},
                {id: 'position_source', title: 'position_source'},
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



 