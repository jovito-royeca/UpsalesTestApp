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
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let account = account {
            let address = addressOf(account)
            
            nameLabel.text = account.name
            addressLabel.text = address
            setMapLocationForAddress(address: address)
        }
    }

    // MARK: Custom methods
    func addressOf(_ account: Client) -> String {
        var addressString = ""
        
        if let addresses = account.addresses {
            if let addressArray = NSKeyedUnarchiver.unarchiveObject(with: addresses as Data) as? [[String: Any]] {
                for a in addressArray {
                    if let type = a["type"] as? String {
                        if type == "Visit" {
                            addressString += "Visit Address: "
                        } else if type == "Mail" {
                            addressString += "Postal Address: "
                        }
                        
                        if let address = a["address"] as? String {
                            addressString += "\(address)"
                        }
                        if let city = a["city"] as? String {
                            addressString += ", \(city)"
                        }
                        if let state = a["state"] as? String {
                            addressString += ", \(state)"
                        }
                        if let country = a["country"] as? String {
                            if let countryName = Locale.current.localizedString(forRegionCode: country) {
                                addressString += ", \(countryName)"
                            }
                        }
                        if let zipcode = a["zipcode"] as? String {
                            addressString += " \(zipcode)"
                        }
                        break
                    }
                }
            }
            
        }
        
        return addressString
    }
    
    func setMapLocationForAddress(address: String) {
        let geocoder:CLGeocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        if let topResult = placemarks.first {
                            let placemark = MKPlacemark(placemark: topResult)
                            
                            var region: MKCoordinateRegion = self.mapView.region
                            region.center = (placemark.location?.coordinate)!
                            region.span.longitudeDelta /= 5.0
                            region.span.latitudeDelta /= 5.0
                            self.mapView.setRegion(region, animated: true)
                            self.mapView.addAnnotation(placemark)
                        }
                    }
                }
            }
        })
    }

}


