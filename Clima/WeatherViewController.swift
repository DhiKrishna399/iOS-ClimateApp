import UIKit
//Framework that enables Location features
import CoreLocation
import Alamofire //Alamofire will make it easier for us to handle HTTP request from OpenWeatherMap servers
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e193a8dbaab62cf98f3633a1cb258d"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    
    //Intialize a locationaManager object using the CLLocationManager class
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        //Delegate:
        locationManager.delegate = self
        //Accuracy determines how often and to what degree location data is updated
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //Ask permission to use location
        locationManager.requestWhenInUseAuthorization()
        //Starts looking for GPS coordinates of the iPhone (Async method)
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String, parameters: [String:String]){
        //Request takes in the URL and our list of parameters
        //.get: this method requests data and should only retrieve data
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Data received")
                //the response sends back the value that contains the weather data
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(WeatherJSON: weatherJSON)
                print(weatherJSON )
                
            } else {
                print(response.result.error)
                self.cityLabel.text = "Connection Issue"
            }
        }
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(WeatherJSON: JSON){
        
        //Place this check here so we don't run into errors
        //Becuase if we use ! with an optional and it doesn't return something like we said
        //it should, then the entire app crashes
        if let temperatureRes = WeatherJSON["main"]["temp"].double {
            
        //let temperatureRes = WeatherJSON["main"]["temp"].double
        weatherDataModel.temperature = Int(temperatureRes - 273.15)
        weatherDataModel.city = WeatherJSON["name"].stringValue //Using .string! will also work
        weatherDataModel.condition = WeatherJSON["weather"][0]["id"].intValue
        //Invoking the method in the weatherDataModel class that uses condition ID to
        //decide which Icon to display
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather unavailable"
        }
        
    }
  
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = (String(weatherDataModel.temperature) + "°")
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        //if the horizontal range is negative, it wouldn't make sense and is invalid data
        if (location.horizontalAccuracy > 0){
            locationManager.stopUpdatingLocation()
            //Use location to obtain the longitude and latitude of the location we just got
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            //Store the lat and long values into a dictionary and then send this data to the OpenWeather API
            //You must type in parameters exactly as the API states or else no data will display
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredCityName(city: String) {
        //print(city)
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
    }
        
    }
    
    
    
    
    
}


