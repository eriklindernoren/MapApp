//
//  ViewController.swift
//  MapApp
//
//  Created by Erik Linder-Norén on 2014-12-22.
//  Copyright (c) 2014 Mina Appar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GMSMapViewDelegate{

    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var checkPhotosButton: UIButton!
    @IBOutlet var bottomBrand: UIView!
    @IBOutlet var bottomInfo: BottomInfo!
    
    @IBOutlet var zIn: UIButton!
    @IBOutlet var zOut: UIButton!
    
    let locationManager = CLLocationManager()
    var markerCoordinate:CLLocationCoordinate2D?
    
    @IBOutlet var bottomPanel: UIView!
    
    let openWeatherKey = "c029cd61774d1696f5c314b89b4c6eb0"
    let timezoneDBKey = "5WWWP2LBIOLM"
    
    
    @IBAction func zoomIn(sender: AnyObject) {
        mapView.animateToZoom(mapView.camera.zoom + 1)
    }
    
    @IBAction func zoomOut(sender: AnyObject) {
        mapView.animateToZoom(mapView.camera.zoom - 1)
    }
    
    @IBAction func typeChange(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            mapView.mapType = kGMSTypeHybrid
        case 1:
            mapView.mapType = kGMSTypeTerrain
        default:
            println("Something went wrong")
        }
    }
    
    func setUpTime(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        //Sets up time
        let timePath: String = "http://api.timezonedb.com/?lat=\(latitude)&lng=\(longitude)&format=json&key=\(timezoneDBKey)"
        var timetask = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: timePath)!), completionHandler: {data, response, error -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let timejson = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                if let diff = timejson["gmtOffset"].stringValue{
                    let diff_from_utc = (diff as NSString).doubleValue
                    let date = NSDate(timeInterval: diff_from_utc, sinceDate: NSDate())
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd - HH:mm"
                    self.bottomInfo.date.text = dateFormatter.stringFromDate(NSDate())
                }
                
            })
        })
        timetask.resume()
        
    }
    
  
    
    func setUpWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        //Sets up temperature for that location using openweathermap api
        let weatherPath: String = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&APPID=\(self.openWeatherKey)&units=metric"
        
        var task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: weatherPath)!), completionHandler: {data, response, error -> Void in
            
            let weatherjson = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let temperature = weatherjson["main"]["temp"].stringValue{
                    var t = (temperature as NSString).doubleValue
                    var temp = NSString(format: "%.1f", t)
                    self.bottomInfo.temp.text = "\(temp)℃"
                }
                if let icon = weatherjson["weather"][0]["icon"].stringValue{
                    let url = NSURL(string: "http://openweathermap.org/img/w/\(icon).png")
                    self.bottomInfo.weatherImg.image = UIImage()
                    var icontask = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url!), completionHandler: {data, response, error -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.bottomInfo.weatherImg.image = UIImage(data: data)
                        })
                    })
                    icontask.resume()
                }
                
                if let windms = weatherjson["wind"]["speed"].stringValue{
                    var w = (windms as NSString).doubleValue
                    var wind = NSString(format: "%.2f", w)
                    self.bottomInfo.wind.text = "\(wind)m/s"
                }
                
            })
        })
        task.resume()

    }
    
    func setUpLocationInfo(position:CLLocationCoordinate2D){
        
        let pospath = "http://nominatim.openstreetmap.org/reverse?format=json&accept-language=en&lat=\(position.latitude)&lon=\(position.longitude)&zoom=18&addressdetails=1"
        
        if let url = NSURL(string: pospath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!){
            println(url)
            let request = NSMutableURLRequest(URL: url)
            var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let posjson = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let city = posjson["address"]["town"].stringValue{
                        self.bottomInfo.address.text = city
                    }else if let city = posjson["address"]["city"].stringValue{
                        self.bottomInfo.address.text = city
                    }else if let city = posjson["address"]["village"].stringValue{
                        self.bottomInfo.address.text = city
                    }
                    if let state = posjson["address"]["state"].stringValue{
                        self.bottomInfo.city.text = state
                    }
                    if let country = posjson["address"]["country"].stringValue{
                        self.bottomInfo.country.text = country
                    }
                })
            })
            task.resume()
        }
        
        var lat = NSString(format: "%.2f", position.latitude)
        var lon = NSString(format: "%.2f", position.longitude)
        bottomInfo.coordinates.text = "\(lat), \(lon)"
    }
    
    func setLocation(map: GMSMapView, coordinate: CLLocationCoordinate2D){
        map.clear()
        bottomInfo.clearInfo()
        var marker = GMSMarker(position: coordinate)
        marker.icon = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("marker", ofType: "png")!)
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.draggable = true
        markerCoordinate = marker.position
        setUpLocationInfo(marker.position)
        setUpTime(marker.position.latitude, longitude: marker.position.longitude)
        setUpWeather(marker.position.latitude, longitude: marker.position.longitude)
       
        marker.map = mapView
    }

    func mapView(mapView: GMSMapView!, didEndDraggingMarker marker: GMSMarker!) {
        setLocation(mapView, coordinate: marker.position)
    }
    
    func mapView(map: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        setLocation(map, coordinate: coordinate)
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        mapView.clear()
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomInfo.setUpLook()
        checkPhotosButton.titleLabel?.text = ""
        mapView.myLocationEnabled = true
        mapView.delegate = self
        mapView.settings.rotateGestures = false
        mapView.accessibilityElementsHidden = false
        mapView.addSubview(checkPhotosButton)
        mapView.addSubview(bottomInfo)
        mapView.addSubview(bottomBrand)
        mapView.addSubview(bottomPanel)
        mapView.addSubview(segmentedControl)
        mapView.addSubview(zIn)
        mapView.addSubview(zOut)
        mapView.mapType = kGMSTypeHybrid
        locationManager.requestWhenInUseAuthorization()
        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
        
        let startLocation = CLLocationCoordinate2D(latitude:8.032548, longitude:98.820962)
        setLocation(mapView, coordinate: startLocation)
        mapView.camera = GMSCameraPosition(target: startLocation, zoom: mapView.camera.zoom, bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle)
        mapView.animateToZoom(3)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as LocationVC
        if let city = bottomInfo.city.text{
            vc.tempCity = city
        }
        if let street = bottomInfo.address.text{
            vc.tempStreet = street
        }
        if let country = bottomInfo.country.text{
            vc.tempCountry = country
        }
        vc.coordinate = markerCoordinate
    }
    
    
}

