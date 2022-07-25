//
//  WeatherService.swift
//  Weathery
//
//  Created by 野中淳 on 2022/07/21.
//

import Foundation
import CoreLocation

enum ServiceError: Error {
    //タプルで追加情報を付与可能
    case network(statusCode: Int)
    case parsing
    case general(reason: String)
}

protocol WeatherServiceDelegate:AnyObject{
    func didFetchWeather(_ weaterService:WeatherService,_ weather:WeatherModel)
    func didFailWithError(_ weatherService: WeatherService, _ error: ServiceError)
}

struct WeatherService{
    
    weak var delegate: WeatherServiceDelegate?
    
    let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?appid=ce5edb27133f4b3a9eab5abfe8072942&units=metric")!
    
    func fetchWeather(cityName:String){
        //addingPercentEncodingは対象外の文字をエスケープする、urlの形式で許されていない文字をエスケープする
        guard let urlEncodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            //デバッグ時のみassertionFailureは発火する
            assertionFailure("Could not encode city named: \(cityName)")
            return
        }
        let urlString = "\(weatherURL)&q=\(urlEncodedCityName)"

        perfomRequest(with: urlString)
    }
    
    func fetchWeather(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        perfomRequest(with: urlString)
    }
    
    func perfomRequest(with urlString:String){
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let unwrapedData = data,
                  let httpResponse = response as? HTTPURLResponse
            else { return }
            
            //errorが何か入っていた場合：httpリクエストがサーバーに到達できなかった場合
            guard error == nil else {
                DispatchQueue.main.async {
                    let generalError = ServiceError.general(reason: "Check network availability.")
                    self.delegate?.didFailWithError(self, generalError)
                }
                return
            }
            
            //statuscodeがおかしい場合
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.delegate?.didFailWithError(self, ServiceError.network(statusCode: httpResponse.statusCode))
                }
                return
            }
            
            guard let weather = self.parseJSON(unwrapedData) else { return }
            
            DispatchQueue.main.async {
                self.delegate?.didFetchWeather(self, weather)
            }
            
        }
        task.resume()
    }
    
    private func parseJSON(_ weatherData:Data) -> WeatherModel?{
        //let docodedData = try! JSONDecoder().decode(WeatherData.self, from: weatherData)
        
        guard let decodedData = try? JSONDecoder().decode(WeatherData.self, from: weatherData) else {
            DispatchQueue.main.async {
                self.delegate?.didFailWithError(self, ServiceError.parsing)
            }
            return nil
        }
        
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
        
        let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
        
        return weather
    }
}
