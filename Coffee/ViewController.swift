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



class ViewController: UIViewController {

//MARK: - Autolayout constraints
    
    ///This is to animate tableview
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
//MARK: - Model Properties
    ///It holds current destination search information
    var currentSearchInformation = SLSearchInformation()
    
    ///It holds directions information and gets displaye on the tableview
    var directions = [Step]()
    
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
    //Add header view
        self.setupHeaderView()
    }
}

//MARK: - Aesthetic Methods
extension ViewController {
    
    func setupViews() {
    //Set the constraint to 0
        //self.mapViewBottomConstraint.constant = -34
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
    
    func getData(_ endPoint: String) {
        
        print("Endpoint: \(endPoint)")
        
    //Clear all the search information
        self.currentSearchInformation = SLSearchInformation()
        
        DispatchQueue.main.async {
            if let url = URL(string: endPoint) {
               URLSession.shared.dataTask(with: url) { data, response, error in
                  if let data = data {
                      do {
                        
                    //Decodable
                        let route = try JSONDecoder().decode(MapPath.self, from: data)
                          
                    //Get current route
                        if let currentRoute = route.routes?.first {
                            if let points = currentRoute.overview_polyline?.points {
                          //Draw points
                              self.drawPath(with: points)
                              self.currentSearchInformation.polyline = points
                            }
                            
                      //Get current legs
                          if let currentLeg = currentRoute.legs.first {
                          //Update distance
                              if let distance = currentLeg.distance  {
                                  self.currentSearchInformation.distance = distance.text.uppercased()
                              }
                          //Update duration
                              if let duration = currentLeg.duration {
                                  self.currentSearchInformation.duration = duration.text.uppercased()
                              }
                          //Update start location
                              if let startLocation = currentLeg.start_address {
                                  self.currentSearchInformation.startlocation = startLocation.uppercased()
                              }
                          //Update end address
                              if let endLocation = currentLeg.end_address {
                                  self.currentSearchInformation.endLocation = endLocation.uppercased()
                              }
                          //Check for directions
                              if let steps = currentLeg.steps {
                                  print("Number of steps: \(steps.count)")
                                  DispatchQueue.main.sync {
                                      self.directions = steps
                                      self.directionsTable.reloadData()
                                      self.tableHeaderDurationLabel.text = "DURATION: \(self.currentSearchInformation.duration ?? "NA")"
                                      self.tableHeaderDistanceLabel.text = "DISTANCE: \(self.currentSearchInformation.distance ?? "NA")"
                                  }
                              }
                          }
                    //Check route
                        }
                      } catch let error {
                         print(error)
                      }
                //Data check
                   }
            //URL Session
               }.resume()
        //Check URL
            }
    //Dispatch
        }
    }
    
    private func drawPath(with points : String) {

        self.mapView.clear()
        DispatchQueue.main.async {
            let path = GMSPath(fromEncodedPath: points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = SLHelper.color
            polyline.map = self.mapView
            
            
            //let camera = GMSCameraPosition.camera(withLatitude: self.sourceLat, longitude: self.sourceLong, zoom: 15.0)self.mapView.animate(to: camera)
        }
    }
}

//MARK: - TableView Delegates
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupHeaderView() {
        
        
        let header  = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        self.directionsTable.tableHeaderView = header
        
        let informationViewHolder = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        //informationViewHolder.backgroundColor = UIColor.yellow
        header.addSubview(informationViewHolder)
        
    //Add the main view
        //informationViewHolder.layer.borderColor = SLHelper.color.cgColor
        //informationViewHolder.layer.cornerRadius = 10
        //informationViewHolder.layer.borderWidth = 1.7
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
            
            label1.leadingAnchor.constraint(equalTo: durationView.leadingAnchor, constant: 15), //(equalTo: durationView.leadingAnchor),
            label1.trailingAnchor.constraint(equalTo: durationView.trailingAnchor, constant: -15),
            label1.topAnchor.constraint(equalTo: durationView.topAnchor, constant: 5),
            label1.bottomAnchor.constraint(equalTo: durationView.bottomAnchor, constant: -5),
            
            label2.leadingAnchor.constraint(equalTo: distanceView.leadingAnchor, constant: 15),
            label2.trailingAnchor.constraint(equalTo: distanceView.trailingAnchor, constant: -15),
            label2.topAnchor.constraint(equalTo: distanceView.topAnchor, constant: 5),
            label2.bottomAnchor.constraint(equalTo: distanceView.bottomAnchor, constant: -5)
        ])
        
        self.tableHeaderDistanceLabel = label2
        self.tableHeaderDurationLabel = label1
        
        label1.text = "DURATION: NA"
        label2.text = "DISTANCE: NA"
    }
    
    func getLabel() -> UILabel{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.font = UIFont(name: "Avenir Next Bold", size: 12)
        label.textAlignment = .center
        label.textColor = SLHelper.color
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.directions.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("selected")
        tableView.deselectRow(at: indexPath, animated: true)
    //Draw points
        let direction = self.directions[indexPath.row]
    //Points
        if let points = direction.polyline?.points {
            print("points")
            self.drawPath(with: points)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SLDirectionCell
        
        let step = self.directions[indexPath.row]
        
        cell.holder1.clipsToBounds = true
        cell.holder2.clipsToBounds = true
        cell.holder3.clipsToBounds = true
        
        cell.holder1.layer.borderColor = SLHelper.color.cgColor
        cell.holder2.layer.borderColor = SLHelper.color.cgColor
        cell.holder3.layer.borderColor = SLHelper.color.cgColor
        
        cell.mode.text = "\(step.travel_mode ?? "NA")".uppercased()
        cell.duration.text = "Duration: \(step.duration.text ?? "NA")".uppercased()
        cell.distance.text = "Distance: \(step.distance.text ?? "NA")".uppercased()
        
        cell.instructionsTextView.text = "\(step.html_instructions ?? "NA")".uppercased()
        //cell.backgroundColor = UIColor.brown
        let data = Data("\(step.html_instructions ?? "NA")".utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            cell.instructionsTextView.attributedText = attributedString
        }
        return cell
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
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:12)
        self.mapView.animate(to: camera)

    //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        
        guard let latitude = location?.coordinate.latitude, let longitude = location?.coordinate.longitude else {
            return
        }
        
    //Update current location
        self.currentSearchInformation.startlocationcoordinate = CGPoint(x: latitude, y: longitude)

    }
}

//MARK: - PLACE AUTOCOMPLETE
/**This extension is for place auto complete. GMSAutocompleteViewController has a search bar and a table view that will displaty results.*/
extension ViewController:GMSAutocompleteViewControllerDelegate {
    
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
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        guard let placeName = place.name, let placeId = place.placeID else {
            return
        }
        
        self.destinationLabel.text = placeName
    //Update current place
        self.currentSearchInformation.endLocation = placeName.uppercased()
        
        self.currentSearchInformation.endlocationplaceid = placeId
        //self.destinationPlace.placeID = placeId
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
    
    //MARK: - Search Destination
        @IBAction func searchDestination(_ sender: Any) {
            
            guard let autocompleteController = self.setupGMSAutocomplete(delegate: self) else {
                return
            }
        //Display the autocomplete view controller
            present(autocompleteController, animated: true, completion: nil)
        }
        
        @IBAction func searchTransitOptions(_ sender: Any) {
        
            guard let currentplace = self.currentSearchInformation.startlocationcoordinate, let destinationplace = self.currentSearchInformation.endlocationplaceid else {
                return
            }
            
            let endPoint = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentplace.x),\(currentplace.y)&destination=place_id:\(destinationplace)&mode=transit&key=\(SLHelper.googleAPIKey)"
            print("API: \(endPoint)")
            self.getData(endPoint)
        }
}


