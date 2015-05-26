//
//  LocationVC.swift
//  MapApp
//
//  Created by Erik Linder-Norén on 2014-12-29.
//  Copyright (c) 2014 Mina Appar. All rights reserved.
//

import UIKit



class LocationVC: UIViewController {
    
    @IBOutlet var photoButton: UIButton!
    
    @IBOutlet var prog1: DayPrognosisView!
    @IBOutlet var prog2: DayPrognosisView!
    @IBOutlet var prog3: DayPrognosisView!
    @IBOutlet var prog4: DayPrognosisView!
    @IBOutlet var prog5: DayPrognosisView!

    @IBOutlet var infoWebView: UIWebView!
    
    @IBOutlet var country: UILabel!
    @IBOutlet var weatherView: UIView!
    @IBOutlet var city: UILabel!
    @IBOutlet var street: UILabel!
    
    var tempCountry = ""
    var tempCity = ""
    var tempStreet = ""
    var coordinate:CLLocationCoordinate2D?
    
    var photoURLs = NSMutableArray()
    
    let flickrKey = "63a975fa42bc2403ad863e45b2ab8689"
    let flickrSecret = "338fb4126e42fe6f"
    let geolocationWSPhotos = "w4OXhgVAWUmshGc0YjSC7YyGwfjjp1XHTrBjsnVW1m73G4QA3T"

    override func viewDidLoad() {
        super.viewDidLoad()
        city.text = tempCity
        street.text = tempStreet
        country.text = tempCountry
        photoButton.enabled = false
        setUpPhotos()
        setUpWeather()
        setUpInfo()
        
        let gestureRec = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe"))
        gestureRec.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(gestureRec)
    }
    
    
    func setUpInfo(){
        infoWebView.opaque = true
        infoWebView.alpha = 0.8
        infoWebView.layer.cornerRadius = 10.0
        infoWebView.layer.borderColor = UIColor.grayColor().CGColor
        infoWebView.layer.borderWidth = 0.5
        infoWebView.clipsToBounds = true
        
        let subject = tempStreet.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        println(subject)
        let wikipath = "http://en.m.wikipedia.org/w/api.php?action=parse&page=\(subject)&format=json&prop=text&section=0"
        println(wikipath)
        
        if let url = NSURL(string: wikipath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!){
            println(url)
            let request = NSMutableURLRequest(URL: url)
            var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let wikijson = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                println(wikijson)
                if let string = wikijson["parse"]["text"]["*"].stringValue{
                    let myRegex = "<p>(.*)</p>"
                    if let match = string.rangeOfString(myRegex, options: .RegularExpressionSearch){
                        let result = string.substringWithRange(match)
                        let htmlWithAttributes = NSString(format: "<head> \n<style type=\"text/css\"> \nbody { \ncolor:rgb(48,48,48);font-family:helvetica;font-size:12pt; font-style:light; \n}\n</style> \n</head> \n<body>%@</body> \n</html>", result)
                        self.infoWebView.loadHTMLString(result, baseURL: nil)
                    }
                }
            })
            task.resume()
        }
    }
    
    func setUpWeather(){
        
        let wViews = NSMutableArray()
        wViews.addObject(prog1)
        wViews.addObject(prog2)
        wViews.addObject(prog3)
        wViews.addObject(prog4)
        wViews.addObject(prog5)
        
        let wPath = ("http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(coordinate!.latitude)&lon=\(coordinate!.longitude)&cnt=5&mode=json&units=metric" as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        if let url = NSURL(string: wPath!){
            var task = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: url), completionHandler: {data, response, error -> Void in
                let weatherjson = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                
                for index in 0...4 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let dailyWeather = weatherjson["list"][index]
                        
                        var weather:DayPrognosisView = wViews.objectAtIndex(index) as DayPrognosisView
                        if let temperature = dailyWeather["temp"]["day"].stringValue{
                            var t = (temperature as NSString).doubleValue
                            let temp = NSString(format: "%.1f", t)
                            weather.temp.text = "\(temp)℃"
                        }
                        if let icon = dailyWeather["weather"][0]["icon"].stringValue{
                            let url = "http://openweathermap.org/img/w/\(icon).png"
                            weather.image.image = UIImage() // Temp value
                            weather.date.text = "" // Temp value
                            var icontask = NSURLSession.sharedSession().dataTaskWithRequest(NSURLRequest(URL: NSURL(string: url)!), completionHandler: {data, response, error -> Void in
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    weather.image.image = UIImage(data: data)
                                    let dateDif = Double(index*60*60*24)
                                    let date = NSDate(timeInterval: dateDif, sinceDate: NSDate())
                                    let dateFormatter = NSDateFormatter()
                                    dateFormatter.dateFormat = "dd/MM"
                                    weather.date.text = dateFormatter.stringFromDate(date)
                                    self.weatherView.addSubview(weather)
                                })
                            })
                            icontask.resume()
                        }
                    })
                }
            })
            task.resume()
        }
    }
    
    func setUpPhotos(){
        
        let photoPath: String = "https://maxim75-geolocation-ws-v1.p.mashape.com/api/find_box?e=\(coordinate!.longitude+0.1)&lang=en&n=\(coordinate!.latitude+0.1)&s=\(coordinate!.latitude-0.1)&w=\(coordinate!.longitude-0.1)"
        if let url = NSURL(string: photoPath){
            let request = NSMutableURLRequest(URL: url)
            request.setValue(geolocationWSPhotos, forHTTPHeaderField: "X-Mashape-Key")
            println(photoPath)
            var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let photojson = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                    let photos:JSON = photojson["items"]
                    let length = photos.arrayValue!.count
                    for i in 0..<length{
                        println("\(i) -  \(length)")
                        if let imgURL = photos[i]["image_url"].stringValue{
                            self.photoURLs.addObject(imgURL)
                            self.photoButton.enabled = true
                        }
                    }
                })
            })
            task.resume()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleSwipe(){
        let newVC = ViewController()
        let vcs = NSMutableArray(array: self.navigationController!.viewControllers)
        vcs.insertObject(newVC, atIndex: vcs.count-1)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PhotoGallery{
            vc.photos = photoURLs
        }
        
    }
    

}
