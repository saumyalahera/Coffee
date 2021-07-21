//
//  SLLocation.swift
//  Coffee
//
//  Created by Saumya Lahera on 7/16/21.
//

import UIKit
import CoreLocation


class SLHelper: NSObject {
    static var color = UIColor(red: 89, green: 67, blue: 42, alpha: 1)
    static let googleAPIKey = "AIzaSyCmDuyvI3rh4rxSGVLSCZPymJHsXKi20sk"
    static let sfbay511Tokey = "ff74c72c-25bb-4f77-b9d0-ff5ce230385f"
}


/*This will hold all the important information */
//needs some cleaning
struct SLSearchInformation {
    
//Needed for directions API
    var destinationPlaceID: String?
    //var distance:String?
    //var duration:String?
    //var polyline:String?
    //var startlocation:String?
    //var destinationPlaceName:String?
    
    //var startlocationcoordinate:CGPoint?
    //var endlocationplaceid:String?
//Used for google API and directions API
    var startLocationCoordinates: CLLocationCoordinate2D?
    var destinationLocationCoordinates: CLLocationCoordinate2D?
}
/**This will hold all place information**/
struct SLPlace {
    var coordinates:CGPoint?
    var placeID:String?
    var placeName:String?
}

struct MapPath : Decodable{
    var routes : [Route]?
}

struct Route : Decodable{
    var overview_polyline : OverView?
    var legs:[Leg]!
}

struct Leg : Decodable {
    var distance:Distance?
    var duration:Duration?
    var start_address:String?
    var end_address:String?
    var steps:[Step]?
    var start_location:Location?
    var end_location:Location?
}

struct Location: Decodable {
    var lat:Double!
    var lng:Double!
}

struct Step : Decodable {
    var travel_mode:String!
    var distance:Distance!
    var duration:Duration!
    var html_instructions:String!
    var polyline:OverView?
    var transit_details:TransitDetails?
}

struct Distance: Decodable {
    var text:String!
}

struct Duration: Decodable {
    var text:String!
}

struct OverView : Decodable {
    var points : String?
}

struct TransitDetails : Decodable {
    var num_stops : Int?
    var line:Line?
    var departure_stop:DepartureStop?
}

struct DepartureStop : Decodable {
    var name:String?
}

struct Line : Decodable {
    var short_name:String?
}

