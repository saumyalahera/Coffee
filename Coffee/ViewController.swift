//
//  ViewController.swift
//  Coffee
//
//  Created by Saumya Lahera on 7/15/21.


import UIKit
import GooglePlaces
import GoogleMaps

class ViewController: UIViewController {

//MARK: - Google Maps
    
    //Google maps
    var mapView:GMSMapView!
    
    //Location manager for getting current location
    var locationManager = CLLocationManager()
    
//MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
    //Add map
        self.setupGoogleMapView()
    }
//MARK: - Search Destination
    @IBAction func searchDestination(_ sender: Any) {
        
        guard let autocompleteController = self.setupGMSAutocomplete(delegate: self) else {
            return
        }

    // Display the autocomplete view controller
        present(autocompleteController, animated: true, completion: nil)
    }
}

//MARK: - SET CURRENT LOCATION
/**Setup google map and also set the current location*/
extension ViewController: CLLocationManagerDelegate {
    
    func setupGoogleMapView() {
        
    //Setup Map Camera
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        
    //Create Map View
        self.mapView = GMSMapView(frame: self.view.frame, camera: camera)
        self.mapView.isMyLocationEnabled = true
        self.view.addSubview(self.mapView)
        
    //Add autolayout constraints to the view
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    //Set camera
        self.mapView.camera = camera
    //Set up location manager
        
        
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func getCurrentLocation() {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("upda")
    //Update the location
        let location = locations.last
    //Get new camera location
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
        self.mapView.animate(to: camera)

    //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
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

