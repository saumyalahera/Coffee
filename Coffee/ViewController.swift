//
//  ViewController.swift
//  Coffee
//
//  Created by Saumya Lahera on 7/15/21.
/*
 Programming Exercise - Mobile
 Create a mobile app for riders of public transportation
 1. Select origin (or use location services) - done
 2. Select destination - done
 3. Query google transit API to find the optional bus route - done
 4. Select one option and show its polyline on a map
 5. Use 511.org to find your bus location and show the bus on the map
 6. Show the distance to my stops - done
 */

import UIKit
import GooglePlaces
import GoogleMaps

/*Select a new place, tableview - 0, searchbar - 1
 after searching tableview - 1, searchbar - 0*/

class ViewController: UIViewController {

//MARK: - Autolayout constraints
    
    ///This is to animate tableview
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    ///This is to animate searchbar
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
//MARK: - Model Properties
    ///It holds current destination search information
    var currentSearchInformation = SLSearchInformation()
    
    ///It holds directions information and gets displaye on the tableview
    var directions = [Route]() //This is going to be use
    
//MARK: - UIView properties
    ///Holds destination name and desitination label
    @IBOutlet weak var transitSearchBar: UIView!
    
    ///Destination label used to hold destination label
    @IBOutlet weak var destinationLabel: UILabel!
    
    ///Shows directions
    @IBOutlet weak var directionsTable: UITableView!
    
    ///Table Header Labels
    var tableHeaderDurationLabel:UILabel!
    var tableHeaderDistanceLabel:UILabel!
    
//MARK: - Map properties
    ///Google map used to show transit information
    @IBOutlet var mapView:GMSMapView!
    
    ///Location manager for getting current location
    var locationManager = CLLocationManager()
    

//MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
    //Set View Methods
        self.setupViews()
    //Add Map view
        self.setupGoogleMapView()
    }
}

//MARK: - Aesthetic Methods
extension ViewController {
    
    func setupViews() {
    //Add a shadow on top of the view
        //self.directionsTable.layer.masksToBounds = false
        self.directionsTable.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.directionsTable.layer.shadowRadius = 1;
        self.directionsTable.layer.shadowOpacity = 0.1;
    //Set the constraint to 0
        self.mapViewBottomConstraint.constant = -34
    //Clear a separator view
        self.directionsTable.separatorColor = .clear
    //Make sure the view is in light mode because by default it is dark
        overrideUserInterfaceStyle = .light
    //Destination view border properties
        if let color = self.transitSearchBar.backgroundColor {
            SLHelper.color = color
        }
        self.transitSearchBar.layer.borderColor = SLHelper.color.cgColor
        self.transitSearchBar.clipsToBounds = true
    }
}

//MARK: - Fetch Data
extension ViewController {
    
/*This function will fetch the data and parse it so we cn display the data
    1. Get the data
    2. Decodable helps in mapping the data
    3. Create a model to store current query information*/
    func getData(_ endPoint: String) {
        //print("Endpoint: \(endPoint)")
    //Clear all the search information
        self.currentSearchInformation = SLSearchInformation()
        
        DispatchQueue.main.async {
            if let url = URL(string: endPoint) {
               URLSession.shared.dataTask(with: url) { data, response, error in
                  if let data = data {
                      do {
                    //Decodable
                        let route = try JSONDecoder().decode(MapPath.self, from: data)
                    //Check for routes
                        if let routes = route.routes {
                            
                            if let currentRoute = routes.first {
                                if let points = currentRoute.overview_polyline?.points {
                                //Draw points
                                    self.drawPath(with: points)
                                //Add markers on the map
                                    if let startLocation = currentRoute.legs.first?.start_location, let endLocation = currentRoute.legs.first?.end_location {
                                    //Get Coordinates
                                        let startCoordinate = CLLocationCoordinate2D(latitude: startLocation.lat, longitude: startLocation.lng)
                                        let endCoordinate = CLLocationCoordinate2D(latitude: endLocation.lat, longitude: endLocation.lng)
                                    //Update markers
                                        self.showMarker(position: startCoordinate)
                                        self.showMarker(position: endCoordinate)
                                        
                                    //Update camera position
                                        self.updateMapViewCamera(startCoordinate: startCoordinate, endCoordinate: endCoordinate)
                                    }
                                }
                          //Get current legs
                              /*if let currentLeg = currentRoute.legs.first {
                              //Check for directions
                                  if let routes = route.routes {
                                      DispatchQueue.main.sync {
                                          self.transitSearchBar.isHidden = true
                                          UIView.animate(withDuration: 1.2, animations: {
                                              self.mapViewBottomConstraint.constant = 300
                                          })
                                          self.directions = routes
                                          self.directionsTable.reloadData()
                                      }
                                  }
                              }*/
                            }
                            
                            DispatchQueue.main.sync {
                                self.transitSearchBar.isHidden = true
                                UIView.animate(withDuration: 1.2, animations: {
                                    self.mapViewBottomConstraint.constant = 300
                                })
                                self.directions = routes
                                self.directionsTable.reloadData()
                            }
                        }
                          
                    //Get current route
                        
                      } catch let error {
                         print(error)
                      }
                   }
               }.resume()
            }
        }
    }
}

//MARK: - TableView Delegates
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
/*This function processes tap function
    1. Gets the correct Route values
    2. Gets the polyline points
    3. Render polylines*/
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else {
            return
        }
        
        if let points = self.directions[tag].overview_polyline?.points, let leg = self.directions[tag].legs.first {
            self.drawPath(with: points)
                
            if let startLocation = leg.start_location, let destinationLocation = leg.end_location {
                self.showMarker(position: CLLocationCoordinate2D(latitude: startLocation.lat, longitude: startLocation.lng))
                self.showMarker(position: CLLocationCoordinate2D(latitude: destinationLocation.lat, longitude: destinationLocation.lng))
            }
        }
    }
    
/*This function is to setup table view header that holds total distance and total time
    1. Create a header view
    2. Create holder views for duration and distance
    3. Create duration and distance labels
    4. Autolayout stuff*/
    func getHeaderView(distance: String, duration: String, tag: Int) -> UIView{
    //Create a header view
        let header  = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        header.backgroundColor = .white
        header.tag = tag
        
    //Add Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        header.addGestureRecognizer(tap)
        
    //It is a complete view holder because it is easy for autolayout
        let informationViewHolder = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        header.addSubview(informationViewHolder)
            
    //Add the main view
        informationViewHolder.translatesAutoresizingMaskIntoConstraints = false
            
    //Add subviews
        let durationView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        durationView.translatesAutoresizingMaskIntoConstraints = false
        durationView.layer.cornerRadius = 10
        durationView.layer.borderWidth = 1
        informationViewHolder.addSubview(durationView)
            
        let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        informationViewHolder.addSubview(separatorView)
            
        let distanceView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        distanceView.translatesAutoresizingMaskIntoConstraints = false
        distanceView.layer.cornerRadius = 10
        distanceView.layer.borderWidth = 1
        informationViewHolder.addSubview(distanceView)
            
    //Add labels
        let label1 = self.getLabel()
        durationView.addSubview(label1)
        label1.translatesAutoresizingMaskIntoConstraints = false
            
        let label2 = self.getLabel()
        distanceView.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false
            
    //Set constraints
        NSLayoutConstraint.activate([
            informationViewHolder.heightAnchor.constraint(equalToConstant: 50),
            informationViewHolder.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            informationViewHolder.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            informationViewHolder.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            informationViewHolder.centerYAnchor.constraint(equalTo: header.centerYAnchor),
                
            separatorView.centerXAnchor.constraint(equalTo: informationViewHolder.centerXAnchor),
            separatorView.centerYAnchor.constraint(equalTo: informationViewHolder.centerYAnchor),
            separatorView.topAnchor.constraint(equalTo: informationViewHolder.topAnchor),
            separatorView.bottomAnchor.constraint(equalTo: informationViewHolder.bottomAnchor),
            separatorView.widthAnchor.constraint(equalToConstant: 10),
                
            durationView.leadingAnchor.constraint(equalTo: informationViewHolder.leadingAnchor),
            durationView.topAnchor.constraint(equalTo: informationViewHolder.topAnchor),
            durationView.bottomAnchor.constraint(equalTo: informationViewHolder.bottomAnchor),
            durationView.trailingAnchor.constraint(equalTo: separatorView.leadingAnchor),
                
            distanceView.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            distanceView.topAnchor.constraint(equalTo: informationViewHolder.topAnchor),
            distanceView.bottomAnchor.constraint(equalTo: informationViewHolder.bottomAnchor),
            distanceView.trailingAnchor.constraint(equalTo: informationViewHolder.trailingAnchor),
                
            label1.leadingAnchor.constraint(equalTo: durationView.leadingAnchor, constant: 15),
            label1.trailingAnchor.constraint(equalTo: durationView.trailingAnchor, constant: -15),
            label1.topAnchor.constraint(equalTo: durationView.topAnchor, constant: 5),
            label1.bottomAnchor.constraint(equalTo: durationView.bottomAnchor, constant: -5),
                
            label2.leadingAnchor.constraint(equalTo: distanceView.leadingAnchor, constant: 15),
            label2.trailingAnchor.constraint(equalTo: distanceView.trailingAnchor, constant: -15),
            label2.topAnchor.constraint(equalTo: distanceView.topAnchor, constant: 5),
            label2.bottomAnchor.constraint(equalTo: distanceView.bottomAnchor, constant: -5)
        ])
            
    //Update labels
        //self.tableHeaderDistanceLabel = label2
        //self.tableHeaderDurationLabel = label1
            
    //Set literals
        label1.text = duration
        label2.text = distance
        
        return header
    }
    
/*This function creates labels
    1. Create a label
    2. Add font to it and other things
    3. return the label*/
    func getLabel() -> UILabel{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.font = UIFont(name: "Avenir Next Bold", size: 12)
        label.textAlignment = .center
        label.textColor = SLHelper.color
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentRoute = self.directions[section]
        return currentRoute.legs[section].steps?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //Get the distance and direction
        let currentRoute = self.directions[section]
        let leg = currentRoute.legs[section]
        
        var distance = "DISTANCE: "
        var duration = "DURATION: "
        
        if let distance_x = leg.distance?.text {
            distance = "DISTANCE: \(distance_x)"
        }
        
        if let duration_x = leg.duration?.text {
            duration = "DURATION: \(duration_x)"
        }
        
        let header  = self.getHeaderView(distance: distance, duration: duration, tag: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.directions.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("selected")
        tableView.deselectRow(at: indexPath, animated: true)
        /*
    //Draw points
        let direction = self.directions[indexPath.row]
    //Points
        if let points = direction.polyline?.points {
            print("points")
            self.drawPath(with: points)
        }*/
    //OPTIONAL
        if let points = self.directions[indexPath.section].overview_polyline?.points {
            self.drawPath(with: points)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SLDirectionCell
        
        let currentRoute = self.directions[indexPath.section]
        
        let leg = currentRoute.legs[indexPath.section]
        
        //currentRoute.legs[section].steps?.count
        let step = leg.steps![indexPath.row]
            
        if "\(step.travel_mode ?? "WALKING")" == "WALKING" {
            cell.type.text = "WALKING"
            cell.icon.image = UIImage(named: "blackwalk@2x.png")
            cell.band.backgroundColor = .brown
            cell.stopsView.isHidden = true
        }else {
            
            if let number = step.transit_details?.num_stops {
                cell.stops.text = "STOPS: \(number)"
            }
            
            cell.type.text = "TRANSIT"
            if let transitnumber = step.transit_details?.line?.short_name {
                cell.type.text = "TRANSIT: \(transitnumber)"
            }
            
            
            //get the first stop and print it sir
            if let stopName = step.transit_details?.departure_stop?.name {
                cell.stopName.text = "Departure Stop: \(stopName)"
            }
            
            cell.icon.image = UIImage(named: "blacktransit@2x.png")
            cell.band.backgroundColor = .black
            
        }

        cell.time.text = "\(step.duration.text ?? "NA")".uppercased()
        cell.distance.text = "\(step.distance.text ?? "NA")".uppercased()
        cell.detail.text = "\(step.html_instructions ?? "NA")".uppercased()
        
        return cell
    }
}


//MARK: - Get Current Location
/**Setup google map and also set the current location*/
extension ViewController: CLLocationManagerDelegate {
    
/*This function helps in getting current location and updates GMSMapView
    1. Get last location
    2. Update camera in Google View
    3. Update current location*/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //Update the location
        let location = locations.last
    //Get new camera location
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:12)
        self.mapView.animate(to: camera)

    //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
        guard let latitude = location?.coordinate.latitude, let longitude = location?.coordinate.longitude else {
            return
        }
        /*
    //Update current location
        var lat:Double = latitude
        var lon:Double = longitude
    //Stanford University Lat and Lon
        lat = 37.426816
        lon = -122.170490*/
    //Update location
        self.currentSearchInformation.startLocationCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

//MARK: - Google Maps Methods
extension ViewController {
    
/*This function sets up Goggle Map
    1. Set a camera because it will define zoom level
    2. Ask for permissions
    3. Init Location Manager because it will help update current location*/
    func setupGoogleMapView() {
    //Map and camera setup
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        self.mapView.camera = camera
        //self.mapView.isMyLocationEnabled = true
        
    //Get permissions
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
    //Setup Location Manager
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
/*This function helps in drawing polylines on google maps
    1. Get points
    2. Create path
    3. Assign the path*/
    func drawPath(with points : String) {
        self.mapView.clear()
        DispatchQueue.main.async {
            let path = GMSPath(fromEncodedPath: points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = SLHelper.color
            polyline.map = self.mapView
        }
    }
    
/*This function is used to zoom google maps
    1. Get the points
    2. Set the camera
    3. Update map camera*/
    func updateMapViewCamera(startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
        let bounds = GMSCoordinateBounds(coordinate: startCoordinate , coordinate: endCoordinate)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        self.mapView.moveCamera(update)
    }
    
/*This function draws a marker on the map
    1. Get the position
    2. Add a title
    3. Assign it to the Map*/
    func showMarker(position: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        marker.position = position
        //marker.title = "Your Current Location"
        //marker.snippet = "----"
        marker.map = self.mapView
        //return marker
    }
}

//MARK: - Google Places Autocomplete View Controller Methods
/**This extension is for place auto complete. GMSAutocompleteViewController has a search bar and a table view that will displaty results.*/
extension ViewController:GMSAutocompleteViewControllerDelegate {
    
/*This method is just for creating an autocomplete view controller
    1. Takes in GMSAutocompleteViewControllerDelegate as a parameter
    2. Creates a ViewController, delegates the instance and returns the view controller*/
    func setupGMSAutocomplete(delegate: GMSAutocompleteViewControllerDelegate) -> GMSAutocompleteViewController? {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = delegate

    //Specify the place data types to return
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.placeID.rawValue))
        autocompleteController.placeFields = fields

    //Specify a filter
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        return autocompleteController
    }
//MARK: - Delegate Methods
/*This function gets selected place's information
    1. Place name, Place Id and ETC
    2. Google directions API needs this to look for directions*/
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let placeName = place.name, let placeId = place.placeID else {
            return
        }
        self.destinationLabel.text = placeName
        //self.currentSearchInformation.destinationPlaceName = placeName.uppercased()
        self.currentSearchInformation.destinationPlaceID = placeId
        
        DispatchQueue.main.async {
            self.mapView.clear()
        //Not a right practice but it is an easy work around
            self.transitSearchBar.isHidden = false
            
            UIView.animate(withDuration: 1.2, animations: {
                self.mapViewBottomConstraint.constant = -34
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
/*This function throws an error if there is some error*/
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
/*This function is used to dismiss Autocomplete Viewcontroller
    1. GMSAutocompleteViewController handles this*/
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
//MARK: - Search Destination Methods
/*This is the navigation bar item function.
    1. User clicks on the search icon on the navigation bar
    2. Autocomplete view controller popups*/
    @IBAction func searchDestination(_ sender: Any) {
        guard let autocompleteController = self.setupGMSAutocomplete(delegate: self) else {
            return
        }
        present(autocompleteController, animated: true, completion: nil)
    }

/*This is the button press function
    1. User selects a destination
    2. User looks for a bus option and it happens in this function*/
    @IBAction func searchTransitOptions(_ sender: Any) {
        guard let startPlaceCoordinates = self.currentSearchInformation.startLocationCoordinates, let destinationPlaceID = self.currentSearchInformation.destinationPlaceID else {
            return
        }
    //Zuckerberg hospital
        //37.755673, -122.404942
    //Stanford University
        
        var lat:Double = 37.755673
        var lon:Double = -122.404942
        
        var api = "https://maps.googleapis.com/maps/api/directions/json?origin=\(startPlaceCoordinates.latitude),\(startPlaceCoordinates.longitude)&destination=place_id:\(destinationPlaceID)&mode=transit&key=\(SLHelper.googleAPIKey)"
        api = "https://maps.googleapis.com/maps/api/directions/json?origin=\(lat),\(lon)&destination=place_id:\(destinationPlaceID)&mode=transit&key=\(SLHelper.googleAPIKey)"
        
        print(api)
        self.getData(api)
    }
}


