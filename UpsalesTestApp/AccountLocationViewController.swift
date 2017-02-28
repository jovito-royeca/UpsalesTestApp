//
//  AccountLocationViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/02/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import MapKit

let kUserDefaultLastLocation = "lastLocation"

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
        if let lastLocation = UserDefaults.standard.object(forKey: kUserDefaultLastLocation) as? [String: Any] {
            let center = CLLocationCoordinate2D(latitude: lastLocation["lat"] as! CLLocationDegrees, longitude: lastLocation["lng"] as! CLLocationDegrees)
            let span = MKCoordinateSpan(latitudeDelta: center.latitude / 10, longitudeDelta: center.longitude / 10)
            let region = MKCoordinateRegion(center: center, span: span)
            
            self.mapView.setRegion(region, animated: true)
        }
        
        if let account = account {
            nameLabel.text = account.name
            
            if let address = account.completeAddress() {
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
        UserDefaults.standard.set(dictionary, forKey: kUserDefaultLastLocation)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Custom methods
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


