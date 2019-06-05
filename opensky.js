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
        var first = body[12]
        
        console.log("Selecionando o primeiro:\n")
        
        console.log("-> icao24: " + first.icao24)
        console.log("-> firstSeen: " + timestamp_to_date(first.firstSeen))
        console.log("-> lastSeen: " + timestamp_to_date(first.lastSeen))
        console.log("-> estDepartureAirport: " + first.estDepartureAirport)
        console.log("-> estArrivalAirport: " + first.estArrivalAirport)
        console.log("-> callsign: " + first.callsign)
        console.log("-> estDepartureAirportHorizDistance: " + first.estDepartureAirportHorizDistance)
        console.log("-> estDepartureAirportVertDistance: " + first.estDepartureAirportVertDistance)
        console.log("-> estArrivalAirportHorizDistance: " + first.estArrivalAirportHorizDistance)
        console.log("-> estArrivalAirportVertDistance: " + first.estArrivalAirportVertDistance)
        console.log("-> departureAirportCandidatesCount: " + first.departureAirportCandidatesCount)
        console.log("-> arrivalAirportCandidatesCount: " + first.arrivalAirportCandidatesCount)
        
        var url2 = "https://"+credentials.API_user+":"+credentials.API_password+"@opensky-network.org/api/tracks/all?icao24="+first.icao24+"&time=0"
        console.log("--------------------------------------------------------------------------------------------------")
        console.log("\nConsultando voo com o icao24=" + first.icao24 + " a partir da url: ")
        console.log("\t" + url2)
        console.log("--------------------------------------------------------------------------------------------------")

        // 2 Request
        request({
            url: url2,
            json: true
        }, get_response2)
    }
}

// 2 Function Response Request
var get_response2 = function (error, response, body){
    if (!error && response.statusCode === 200) {
        var by_flight = body
        console.log("icao24: " + by_flight.icao24)
        console.log("callsign: " + by_flight.callsign)
        console.log("startTime: " + by_flight.startTime)
        console.log("endTime: " + by_flight.endTime)
        console.log("path[]: ")

        var geo = []
        cont_ICAO = 0
        for (t in by_flight.path) {
            actual_path = by_flight.path[t]
            var structure = {time: actual_path[0], lat: actual_path[1], long: actual_path[2], color: actual_path[3]}
            geo.push(structure)

            // console.log("\t time: " + actual_path[0])
            // console.log("\t latitude: " + actual_path[1])
            // console.log("\t longitude: " + actual_path[2])
            console.log("\t baro_altitude: " + actual_path[3])
            // console.log("\t true_track: " + actual_path[4])
            // console.log("\t on_ground: " + actual_path[5])

            
        }
        // console.log(geo)

        cont_ICAO += 1
        filename = cont_ICAO.toString() + "_" + actual_path.icao24

        const csvWriter = createCsvWriter({
            path: "./voo.csv",
            header: [
                {id: 'time', title: 'TIMESTAMP'},
                {id: 'lat', title: 'LATITUDE'},
                {id: 'long', title: 'LONGITUDE'},
                {id: 'color', title: 'COLOR'}
            ]
        });
        csvWriter.writeRecords(geo)       // returns a promise
        .then(() => {
            console.log('...Done');
        });
        

        
    }
}


console.log("--------------------------------------------------------------------------------------------------")
console.log("Consultando arrivals de Viracopos (SBKP) !\n")
var airportICAO = "SBKP"

var now = new Date()
var past = new Date()
past.setDate(now.getDate()-6);
now_date_timestamp = now.getTime()
past_date_timestamp = past.getTime()

var url = "https://opensky-network.org/api/flights/arrival?airport="+airportICAO+"&begin=1559001600&end=1559433600"
// var url = "https://opensky-network.org/api/flights/arrival?airport="+airportICAO+"&begin="+past_date_timestamp.toString()+"&end="+now_date_timestamp.toString()

// // 1 Request
// request({
//     url: url,
//     json: true
// }, get_response)


var icao24 = "e4936a"
// var icao24 = "e4904c"
// var icao24 = "e48ac5"


var url2 = "https://"+credentials.API_user+":"+credentials.API_password+"@opensky-network.org/api/tracks/all?icao24="+icao24+"&time=0"
// console.log("--------------------------------------------------------------------------------------------------")
// console.log("\nConsultando voo com o icao24=" + first.icao24 + " a partir da url: ")
// console.log("\t" + url2)
// console.log("--------------------------------------------------------------------------------------------------")

// 2 Request
request({
    url: url2,
    json: true
}, get_response2)


 