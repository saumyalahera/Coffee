//
//  SLLocation.swift
//  Coffee
//
//  Created by Saumya Lahera on 7/16/21.
//

import UIKit


class SLHelper: NSObject {
    static var color = UIColor(red: 89, green: 67, blue: 42, alpha: 1)
    static let googleAPIKey = "AIzaSyCmDuyvI3rh4rxSGVLSCZPymJHsXKi20sk"
    static let sfbay511Tokey = "ff74c72c-25bb-4f77-b9d0-ff5ce230385f"
}


/*This will hold all the important information */
struct SLSearchInformation {
    var distance:String?
    var duration:String?
    var polyline:String?
    var startlocation:String?
    var endLocation:String?
    var startlocationcoordinate:CGPoint?
    var endlocationplaceid:String?
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
}

struct Step : Decodable {
    var travel_mode:String!
    var distance:Distance!
    var duration:Duration!
    var html_instructions:String!
    var polyline:OverView?
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

