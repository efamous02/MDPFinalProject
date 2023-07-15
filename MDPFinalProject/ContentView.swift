//
//  ContentView.swift
//  MDPFinalProject
//
//  Created by Emma Famous on 3/28/23.
//

import SwiftUI

//JSON STRUCTURES
//GeoCode Info
struct geoInfo: Decodable{
    let lat: String
    let lon: String
    let display_name: String
}

//Current Weather
struct currentWeatherData: Decodable {
    let weather: [weatherData]
    let main: mainData
    let sys: sysData
    let timezone: Int
    let name: String
    
}
struct mainData: Decodable{
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Double
}
struct weatherData: Decodable {
    let main: String
    let description: String
    let icon: String
}
struct sysData: Decodable{
    let sunrise: Int
    let sunset: Int
}

struct ContentView: View {
    //State Variables
    @State private var Location = ""
    @State private var CurrentLocation = "Adress: "
    
    @State private var tempInFahrenheit = "Na"
    @State private var currentWeatherString = ""
    @State private var weatherIcon = "sun.max"
    @State private var feelsLike = "0"

    @State private var tempMin = 56.0
    @State private var tempMax = 72.0
    
    @State private var Sunrise = "9:00"
    @State private var Sunset = "9:00"


    @State private var weatherColor = Color(red: 242/255, green: 206/255, blue: 48/255)
    
    var body: some View {
            VStack {
                HStack(alignment: .top){
                    TextField(CurrentLocation,text: $Location)
                    Button(action: {
                        Task{
                             await fetchGeoData()
                        }
                    }, label: {
                        Image(systemName: "magnifyingglass.circle")
                    })
                }//end Hstack
                .border(.secondary)
                .padding(.horizontal)
                .background(weatherColor)
                
                ZStack{
                    VStack{
                        Text(Location)
                            .font(.title2)
                            .bold()
                            .italic()
                        Text(CurrentLocation)
                            .font(.subheadline)
                            .italic()
                        HStack{
                            ZStack{
                                Circle()
                                    .frame(width: 80, height:80)
                                    .foregroundColor(weatherColor)
                                    .shadow(color: .gray, radius: 1.0, x: 0, y: 1.0)
                                Text(tempInFahrenheit.prefix(2)+"°")
                                    .font(.largeTitle)
                                    .padding()
                            }
                            
                            Image(systemName: weatherIcon)
                                .imageScale(.large)
                            
                        }//End Hstack
                        Text("Feels like: " + feelsLike.prefix(2) + "°")
                    }//End VStack
                    .padding(50)
                }//End ZStack
                HStack{
                    Text(String(tempMin).prefix(2) + "°")
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .frame(width: (tempMax - tempMin)*8, height: 10)
                        .foregroundColor(weatherColor)
                        .shadow(color: .gray, radius: 1.0, x: 0, y: 1.0)
                    Text(String(tempMax).prefix(2) + "°")
                }
                .font(.title3)
                .padding()
                
                HStack{
                    Image(systemName: "sunrise")
                        .imageScale(.large)
                        .padding()
                        .foregroundColor(weatherColor)
                    Text(Sunrise)
                    Image(systemName: "sunset")
                        .imageScale(.large)
                        .padding()
                        .foregroundColor(weatherColor)
                    Text(Sunset)
                }
                .padding(.trailing)

               

                Spacer()
                Image(weatherIcon)
                    .resizable()
            }//End Vstack
            .padding()
       
    }//End Body
   
    func kelvinToFahrenheit(input: Double)-> Double{
        return 1.8*(input-273)+32
    }
    
    func fetchWeatherData(lat:Double, long:Double) async {
        let apiKey = "3b22829df4345b0039be06a55eccf9ee"

        let weatherAPICall = "https://api.openweathermap.org/data/2.5/weather?lat=" + String(lat) + "&lon=" + String(long) + "&appid=" + apiKey
        
        guard let url = URL(string: weatherAPICall) else{
                    print("Invalid URL")
                    return
        }
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
               
            let output: currentWeatherData = try JSONDecoder().decode(currentWeatherData.self,from: data)
               
               currentWeatherString = output.weather[0].main
               //temp is by default in kelvin
               let tempInKelvin = output.main.temp
               tempInFahrenheit = String(kelvinToFahrenheit(input: tempInKelvin))
               weatherIcon = findWeatherIcon(weatherIconNum: output.weather[0].icon)
               
               feelsLike = String(kelvinToFahrenheit(input: output.main.feels_like))
               
               tempMin = kelvinToFahrenheit(input: output.main.temp_min)
               tempMax = kelvinToFahrenheit(input: output.main.temp_max)
               
               let sunriseTime = Date(timeIntervalSince1970: TimeInterval(output.sys.sunrise ))
               let sunsetTime = Date(timeIntervalSince1970: TimeInterval(output.sys.sunset ))
               
               Sunrise = sunriseTime.formatted()
               Sunset = sunsetTime.formatted()

            
        }catch{
            CurrentLocation = "Error"
            print("error retreiving data")
            
        }
    }//end fetchWeatherData

    func findWeatherIcon(weatherIconNum: String) -> String{
        //Sunny
        if(weatherIconNum == "01d" ){
            weatherColor = Color(red: 242/255, green: 206/255, blue: 48/255)
            return "sun.max"
        }else if(weatherIconNum == "01n"){
            weatherColor = Color(red: 144/255, green: 157/255, blue: 168/255)
            return "moon"
        }else if(weatherIconNum == "02d"){
            weatherColor = Color(red: 242/255, green: 206/255, blue: 48/255)
            return "cloud.sun"
        }else if(weatherIconNum == "02n"){
            weatherColor = Color(red: 148/255, green: 154/255, blue: 181/255)
            return "cloud.moon"
        }else if(weatherIconNum == "03d" || weatherIconNum == "03n"){
            weatherColor = Color(red: 151/255, green: 154/255, blue: 163/255)
            return "cloud"
        }else if(weatherIconNum == "04d" || weatherIconNum == "04n"){
            //weatherColor = Color(red: 97/255, green: 98/255, blue: 102/255)
            weatherColor = Color(red: 242/255, green: 206/255, blue: 48/255)
            return "cloud.sun"
        }else if(weatherIconNum == "09d" || weatherIconNum == "09n"){
            weatherColor = Color(red: 129/225, green: 145/225, blue: 209/225)
            return "cloud.drizzle"
        }else if(weatherIconNum == "10d" || weatherIconNum == "10n"){
            weatherColor = Color(red: 82/255, green: 94/255, blue: 102/255)
            return "cloud.heavyrain"
        }else if(weatherIconNum ==  "11d" || weatherIconNum == "11n"){
            weatherColor = Color(red: 98/255, green: 98/255, blue: 124/255)
            return "cloud.bolt"
        }else if(weatherIconNum == "13d" || weatherIconNum == "13n"){
            weatherColor = Color(red: 186/255, green: 195/255, blue: 211/255)
            return "cloud.snow"
        }else if(weatherIconNum == "50d"){
            weatherColor = Color(red: 204/255, green: 211/255, blue: 169/255)
            return "sun.haze"
        }else if (weatherIconNum == "50n"){
            weatherColor = Color(red: 186/255, green: 195/255, blue: 211/255)
            return "moon.haze"
        }
        return "exclamationmark.triangle"
    }
    
    func fetchGeoData() async {
        var geoAPICall = "https://geocode.maps.co/search?q=" + Location + ""

        geoAPICall = geoAPICall.replacingOccurrences(of:" ", with:"+")
        guard let url = URL(string: geoAPICall) else{
            CurrentLocation = "Error [URL]"
            return
        }
        do{
            let (data, _) = try await URLSession.shared.data(from:url)
            
            let decoder = JSONDecoder()
            let output = try decoder.decode([geoInfo].self, from:data)
            
            if(!output.isEmpty){
                CurrentLocation = output[0].display_name
                let lat = Double(output[0].lat)
                let long = Double(output[0].lon)
                
                await fetchWeatherData(lat: lat!, long: long!)
                
            }
            else{
                CurrentLocation = "Invalid Location"
            }


        }catch{
            print(error)
        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


