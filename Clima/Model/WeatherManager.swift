//
//  WeatherManager.swift
//  Clima
//
//  Created by özge kurnaz on 25.02.2024.
//  Copyright © 2024 App Brewery. All rights reserved.


import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager:WeatherManager ,  weather:WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager{
    
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=84b81de7499e015f04074161822a6574&units=metric"
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName:String){
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performReq(urlString: urlString)
        
    }
    
    func fetchWeather(latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performReq(urlString: urlString)
    }
    
    func performReq(urlString:String){
        //create a url
        
        if let url = URL(string: urlString){
            //create a urlSession
            
            let session = URLSession(configuration: .default)
            
            //give the session a task
            
            let task = session.dataTask(with: url){ (data, response,error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            
            
            //start the task
            task.resume()
            
        }
    }
    
    func parseJSON(_ weatherData:Data)->WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let temp = decodedData.main.temp
            let id = decodedData.weather[0].id
            let cityName = decodedData.name
            

            let weather = WeatherModel(conditionId: id, cityName: cityName, temperature: temp)
            return weather
        }
        catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
        
    }
        
    


}
