//
//  ViewController.swift
//  Coffee
//
//  Created by Saumya Lahera on 7/15/21.


import UIKit
import GooglePlaces

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
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

