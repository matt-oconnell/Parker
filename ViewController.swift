//
//  ViewController.swift
//  Parker
//
//  Created by Matt O'Connell on 4/29/17.
//  Copyright © 2017 Matt O'Connell. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK - Constants
    let NEXTDAY = "nextDay"
    let COORDINATE = "coordinate"
    let LATITUDE = "latitude"
    let LONGITUDE = "longitude"
    
    
    // MARK - Local Variables
    let locationManager = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    
    
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
        
        if let coords = getSavedCoords() {
            // Add Pin Annotation
            let place = Place(title: "test", subtitle: "subtitle", latitude: coords.lat, longitude: coords.lon)
            mapView.addAnnotation(place)
        }
    }
    
    func getSavedCoords() -> (lat: Double, lon: Double)? {
        if let coords = UserDefaults.standard.value(forKey: self.COORDINATE) as! [String:Double]? {
            if let lat = coords[self.LATITUDE], let lon = coords[self.LONGITUDE] {
                return (lat, lon)
            }
        }
        return nil
    }
    
    func getMidPoint(userLocation: MKUserLocation) -> CLLocationCoordinate2D {
        let userLat = userLocation.coordinate.latitude
        let userLon = userLocation.coordinate.longitude
        let userCoords2d = CLLocationCoordinate2D(latitude: userLat, longitude: userLon)
        let midpoint: CLLocationCoordinate2D
        
        if let savedCoords = getSavedCoords() {
            let midLat = (userLat + savedCoords.lat) / 2
            let midLon = (userLon + savedCoords.lon) / 2
            midpoint = CLLocationCoordinate2D(latitude: midLat, longitude: midLon)
        } else {
            midpoint = userCoords2d
        }
        
        return midpoint
    }
    
    func getRadius(userLocation: MKUserLocation, defaultDistance: Double) -> Double {
        let regionRadius: Double
        
        let userCoords = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        if let savedCoords = getSavedCoords() {
            let parkedCoords = CLLocation(latitude: savedCoords.lat, longitude: savedCoords.lon)
            regionRadius = userCoords.distance(from: parkedCoords) * 1.3
        } else {
            regionRadius = defaultDistance
        }
        
        return regionRadius
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
        
        // TEST
        Alamofire.request("https://nyc-asp-twitter.herokuapp.com/").responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
        
        
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
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let midpoint = getMidPoint(userLocation: userLocation)
        let regionRadius = getRadius(userLocation: userLocation, defaultDistance: 400.0)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance( midpoint, CLLocationDistance(regionRadius), CLLocationDistance(regionRadius) )
        self.mapView.setRegion( coordinateRegion, animated: true)
    }
}

