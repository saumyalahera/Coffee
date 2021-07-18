//
//  ViewController.swift
//  Coffee
//
//  Created by Saumya Lahera on 7/15/21.
/*
 Programming Exercise - Mobile
 Create a mobile app for riders of public transportation
 1. Select origin (or use location services)
 2. Select destination
 3. Query google transit API to find the optional bus route
 4. Select one option and show its polyline on a map
 5. Use 511.org to find your bus location and show the bus on the map
 6. Show the distance to my stops
 */

import UIKit
import GooglePlaces
import GoogleMaps


/**This will hold all place information**/
struct SLPlace {
    var coordinates:CGPoint?
    var placeID:String?
    var placeName:String?
}

class ViewController: UIViewController {

    @IBOutlet weak var transitSearchBar: UIView!
    
//MARK: - Google Maps
    @IBOutlet weak var destinationLabel: UILabel!
    //Google maps
    @IBOutlet var mapView:GMSMapView!
    
    //Location manager for getting current location
    var locationManager = CLLocationManager()
    
/*Properties for transit API*/
    var currentPlace = SLPlace()
    var destinationPlace = SLPlace()
   
    
//MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()

    //Make sure the view is in light mode because by default it is dark
        overrideUserInterfaceStyle = .light
    //Add map
        self.setupGoogleMapView()
    //border
        
        if let color = self.transitSearchBar.backgroundColor {
            SLHelper.color = color
        }
        
        self.transitSearchBar.layer.borderColor = SLHelper.color.cgColor
        self.transitSearchBar.clipsToBounds = true
    }
//MARK: - Search Destination
    @IBAction func searchDestination(_ sender: Any) {
        
        guard let autocompleteController = self.setupGMSAutocomplete(delegate: self) else {
            return
        }

    // Display the autocomplete view controller
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func searchTransitOptions(_ sender: Any) {
        print("Search Transit Options")
        guard let currentplace = self.currentPlace.coordinates, let destinationplace = self.destinationPlace.placeID else {
            return
        }
        
        let endPoint = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentplace.x),\(currentplace.y)&destination=place_id:\(destinationplace)&mode=bus&key=\(SLHelper.googleAPIKey)"
        self.getData(endPoint)
    }
}

//MARK: - Fetch Data

private struct MapPath : Decodable{
    var routes : [Route]?
}

private struct Route : Decodable{
    var overview_polyline : OverView?
    var legs:[Leg]!
}

private struct Leg : Decodable {
    var distance:Distance?
    var duration:Duration?
    var steps:[Step]?
}

private struct Step : Decodable {
    var travel_mode:String!
}
private struct Distance: Decodable {
    var text:String!
}

private struct Duration: Decodable {
    var text:String!
}

private struct OverView : Decodable {
    var points : String?
}


extension ViewController {
    
    func getData(_ endPoint: String) {
        print("Endpoint: \(endPoint)")
        
        var ep = "https://api.myjson.com/bins/yfua8"
        ep = "https://dog.ceo/api/breeds/image/random"
        ep = endPoint
        
        DispatchQueue.main.async {
            if let url = URL(string: ep) {
               URLSession.shared.dataTask(with: url) { data, response, error in
                  if let data = data {
                      do {
                          let route = try JSONDecoder().decode(MapPath.self, from: data)
                          
                          if let legs = route.routes?.first?.legs {
                              print("\(legs)")
                              
                              if legs.count > 0 {
                                  
                              }
                              
                          }

                          if let points = route.routes?.first?.overview_polyline?.points {
                            //print("number")
                            self.drawPath(with: points)
                        }
                          
                      } catch let error {
                         print(error)
                      }
                   }
               }.resume()
            }
        }
    }
    
    private func drawPath(with points : String) {

        DispatchQueue.main.async {
            let path = GMSPath(fromEncodedPath: points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .red
            polyline.map = self.mapView
        }
    }
}

//MARK: - SET CURRENT LOCATION
/**Setup google map and also set the current location*/
extension ViewController: CLLocationManagerDelegate {
    
    func setupGoogleMapView() {
        
    //Setup Map Camera
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        
    //Set camera
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        
    //Set up location manager
        self.locationManager.requestAlwaysAuthorization()

    //For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location Updated")
    //Update the location
        let location = locations.last
    //Get new camera location
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
        self.mapView.animate(to: camera)

    //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
        guard let latitude = location?.coordinate.latitude, let longitude = location?.coordinate.longitude else {
            return
        }
        
    //Update current location
        self.currentPlace.coordinates = CGPoint(x: latitude, y: longitude)
    }
}

//MARK: - PLACE AUTOCOMPLETE
/**This extension is for place auto complete. GMSAutocompleteViewController has a search bar and a table view that will displaty results.*/
extension ViewController:GMSAutocompleteViewControllerDelegate {
    
//MARK: - Setup Autocomplete View controller
    func setupGMSAutocomplete(delegate: GMSAutocompleteViewControllerDelegate) -> GMSAutocompleteViewController? {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = delegate

    // Specify the place data types to return
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue))
        autocompleteController.placeFields = fields

    // Specify a filter
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        return autocompleteController
    }
    
    
//MARK: - Delegate Methods
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        guard let placeName = place.name, let placeId = place.placeID else {
            return
        }
        
        self.destinationLabel.text = placeName
        self.destinationPlace.placeID = placeId
        print("Place name: \(placeName)")
        print("Place ID: \(placeId)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("")
        dismiss(animated: true, completion: nil)
    }
}

