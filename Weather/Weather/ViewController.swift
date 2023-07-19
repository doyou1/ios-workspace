//
//  ViewController.swift
//  Weather
//
//  Created by simjh on 2023/07/17.
//

// Location: CoreLocation
// table view
// custom cell: collection view
// API / request to get the data

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    
    var currentModel: CurrentWeather?
    var forecastModels = [ForecastWeather]()
    var hourlyModels = [HourlyWeather]()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register 2 cells
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        table.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1)
        view.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    // Location
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else { return }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let headers = [
            "X-RapidAPI-Key": Bundle.main.WEATHER_API_KEY,
            "X-RapidAPI-Host": "weatherapi-com.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://weatherapi-com.p.rapidapi.com/forecast.json?q=\(lat)%2C\(long)&days=3")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // validation
            guard let data = data, error == nil else {
                print(error as Any)
                return
            }
            
            // Convert data to models
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("convert to json error: \(error)")
            }
            
            guard let result = json else { return }
            self.currentModel = CurrentWeather(updatedDate: result.current.last_updated, temp: result.current.temp_c, condition: result.current.condition, region: result.location.region, country: result.location.country)
            
            for item in result.forecast.forecastday {
                self.forecastModels.append(ForecastWeather(date: item.date, minTemp: item.day.mintemp_c, maxTemp: item.day.maxtemp_c, condition: item.day.condition))
            }
            //            print("current: \(self.currentModel)")
            //            print("forecast: \(self.forecastModels)")
            
            // Update user interface
            DispatchQueue.main.async {
                self.table.reloadData()
                self.table.tableHeaderView = self.createTableHeader()
                
            }
            
        })
        dataTask.resume()
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        headerView.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1.0)
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        tempLabel.textAlignment = .center
        
        tempLabel.text = "\(currentModel?.temp ?? 0)°C"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        locationLabel.text = "\(currentModel?.country ?? "") \(currentModel?.region ?? "")"
        summaryLabel.text = "\(currentModel?.condition.text ?? "")"
        return headerView
    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: forecastModels[indexPath.row])
        cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 1)
        return cell
    }
    
}

struct CurrentWeather {
    let updatedDate: String
    let temp: Float
    let condition: Condition
    let region: String
    let country: String
}

struct ForecastWeather {
    let date: String
    let minTemp: Float
    let maxTemp: Float
    let condition: Condition
}

struct HourlyWeather {
    
}

struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Float
    let lon: Float
    let tz_id: String
    let localtime_epoch: CLong
    let localtime: String
}

struct Current: Codable {
    let last_updated_epoch: CLong
    let last_updated: String
    let temp_c: Float
    let temp_f: Float
    let is_day: Int
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable {
    let date: String
    let date_epoch: CLong
    let day: Day
}

struct Day: Codable {
    let maxtemp_c: Float
    let mintemp_c: Float
    let avgtemp_c: Float
    let condition: Condition
}


extension Bundle {
    
    // 생성한 .plist 파일 경로 불러오기
    var WEATHER_API_KEY: String {
        guard let file = self.path(forResource: "WeatherAPIInfo", ofType: "plist") else { return "" }
        
        // .plist를 딕셔너리로 받아오기
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        // 딕셔너리에서 값 찾기
        guard let key = resource["WEATHER_API_KEY"] as? String else {
            fatalError("WEATHER_API_KEY error")
        }
        return key
    }
}
