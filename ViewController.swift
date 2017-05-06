//
//  ViewController.swift
//  Parker
//
//  Created by Matt O'Connell on 4/29/17.
//  Copyright © 2017 Matt O'Connell. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK - Constants
    let NEXTDAY = "nextDay"
    let COORDINATE = "coordinate"
    let LATITUDE = "latitude"
    let LONGITUDE = "longitude"
    
    
    // MARK - Local Variables
    let locationManager = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    var placemark:MKPlacemark!
    
    
    // MARK - Outlets
    @IBOutlet weak var nextDay: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK - Helper Functions
    func updateNextDay(day: String) {
        nextDay.text = "Next move day: " + day
    }
    
    func checkForLocationAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .denied, .restricted:
            print("location denied")
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func addPin() {
        
        // Clear old pins
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        // Get saved coords
        let coords = UserDefaults.standard.value(forKey: self.COORDINATE) as! [String:Double]
        if let lat = coords[self.LATITUDE], let lon = coords[self.LONGITUDE] {
            
            // Add Pin Annotation
            let place = Place(title: "test", subtitle: "subtitle", latitude: lat, longitude: lon)
            mapView.addAnnotation(place)
        }
    }
    
    
    // MARK - Actions
    @IBAction func parkButtonClick(_ sender: Any) {
        let alertController = UIAlertController(title: "", message: "When do you need to move your car?", preferredStyle: .actionSheet)
        
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        var alertActions = [UIAlertAction]()
        
        for day in days {
            let action = UIAlertAction(title: day, style: .default, handler: { (action) -> Void in
                UserDefaults.standard.set(day, forKey: self.NEXTDAY)
                self.updateNextDay(day: day)
                self.locationManager.startUpdatingLocation()
            })
            alertActions.append(action)
        }
        
        for action in alertActions {
            alertController.addAction(action)
        }

        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        mapView.delegate = self
        locationManager.delegate = self
        
        addPin()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if let day = UserDefaults.standard.string(forKey: self.NEXTDAY) {
            self.updateNextDay(day: day)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkForLocationAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK - Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations.first
        
        self.geocoder.reverseGeocodeLocation(currentLocation!) { (placemarks, error) in

            if (placemarks != nil && placemarks!.count > 0) {

                let coordinate = placemarks!.first?.location?.coordinate

                let userLocation:[String:Double] = [
                    self.LATITUDE: coordinate!.latitude,
                    self.LONGITUDE: coordinate!.longitude
                ]

                // Save Location
                UserDefaults.standard.set(userLocation, forKey: self.COORDINATE)
                
                self.addPin()

                self.locationManager.stopUpdatingLocation()
            }
        }
    }
}

