//
//  AccountLocationViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/02/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import MapKit

class AccountLocationViewController: UIViewController {
    // MARK: Variables
    var account:Client?
    
    // MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // let us reload the last saved location
        if let lastLocation = UserDefaults.standard.object(forKey: "lastLocation") as? [String: Any] {
            let center = CLLocationCoordinate2D(latitude: lastLocation["lat"] as! CLLocationDegrees, longitude: lastLocation["lng"] as! CLLocationDegrees)
            let span = MKCoordinateSpan(latitudeDelta: center.latitude / 10, longitudeDelta: center.longitude / 10)
            let region = MKCoordinateRegion(center: center, span: span)
            
            self.mapView.setRegion(region, animated: true)
        }
        
        if let account = account {
            nameLabel.text = account.name
            
            if let address = addressOf(account) {
                setMapLocationForAddress(address: address)
            } else {
                let message = "No address found"
                let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // let us save the location
        let center = mapView.region.center
        let dictionary = ["lat": center.latitude,
                          "lng": center.longitude]
        UserDefaults.standard.set(dictionary, forKey: "lastLocation")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Custom methods
    
    /*
     * Get the address of client
     */
    func addressOf(_ account: Client) -> String? {
        if let addresses = account.addresses {
            if let addressArray = NSKeyedUnarchiver.unarchiveObject(with: addresses as Data) as? [[String: Any]] {
                for a in addressArray {
                    if let type = a["type"] as? String {
                        if type == "Visit" || type == "Mail" {
                            var addressString = ""
                            
                            if let address = a["address"] as? String {
                                addressString += "\(address)"
                            }
                            if let city = a["city"] as? String {
                                if addressString.characters.count > 0 {
                                    addressString += ", "
                                }
                                addressString += "\(city)"
                            }
                            if let state = a["state"] as? String {
                                if addressString.characters.count > 0 {
                                    addressString += ", "
                                }
                                addressString += "\(state)"
                            }
                            if let country = a["country"] as? String {
                                if let countryName = Locale.current.localizedString(forRegionCode: country) {
                                    if addressString.characters.count > 0 {
                                        addressString += ", "
                                    }
                                    addressString += "\(countryName)"
                                }
                            }
                            if let zipcode = a["zipcode"] as? String {
                                if addressString.characters.count > 0 {
                                    addressString += " "
                                }
                                addressString += "\(zipcode)"
                            }
                            
                            return addressString
                        }
                    }
                }
            }
            
        }
        
        return nil
    }
    
    /*
     * Geocode the address string and put it into the map
     */
    func setMapLocationForAddress(address: String) {
        let geocoder:CLGeocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        if let topResult = placemarks.first {
                            let placemark = MKPlacemark(placemark: topResult)
                            
                            let coordinate = placemark.location?.coordinate
                            var region = self.mapView.region
                            region.center = coordinate!
                            region.span.longitudeDelta /= 10.0
                            region.span.latitudeDelta /= 10.0
                            
                            self.mapView.setRegion(region, animated: true)
                            self.mapView.addAnnotation(placemark)
                            self.mapView.selectAnnotation(placemark, animated: true)
                        }
                    }
                }
            }
        })
    }

}


