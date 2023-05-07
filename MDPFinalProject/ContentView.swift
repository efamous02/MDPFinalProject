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
    
}
struct mainData: Decodable{
    let temp: Double
}
struct weatherData: Decodable {
    let main: String
    let description: String
    let icon: String
}

//Next 5 Days
/*struct forcastDayData: Decodable{
    let main: [mainForcast]
    let weather: [weatherForcast]
}
*/
struct mainForcast{
    let temp_min: Double
    let temp_max: Double
}
struct weatherForcast{
    let icon: String
}
struct windForcast{
    let speed: Double
    let gust: Double
}
struct rainForcast{
    let oneHour: Double
}


struct ContentView: View {
    @State private var Location = ""
    @State private var CurrentLocation = "Adress: "
    
    @State private var tempInFahrenheit = "Na"
    @State private var currentWeatherString = ""
    @State private var weatherIcon = "magnifyingglass.circle"
    
    //TODO:REMOVE
    //@State private var debugOutput = ":D"
    
    @State private var day1Data1 = ""
    @State private var day2Data1 = ""
    @State private var day3Data1 = ""
    @State private var day4Data1 = ""


    @State private var day1Data2 = ""
    @State private var day2Data2 = ""
    @State private var day3Data2 = ""
    @State private var day4Data2 = ""
    
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
            
            Spacer()
            Text(CurrentLocation)
            HStack{
                //Text(debugOutput)

                Text(tempInFahrenheit.prefix(2)+"°")
                    .font(.largeTitle)
                    .padding()
                Image(systemName: weatherIcon)

            }//End Hstack
            Text(currentWeatherString)
            
            
            Spacer()

            Text("Next 4 Days")
            HStack{
                Button(action: {
                    Task{
                        setDataToWeather()
                    }
                }, label: {
                    Text("Weather")
                })
                Spacer()
                Button(action: {
                    Task{
                        setDataToRain()
                    }
                }, label: {
                    Text("Rain")
                })
                Spacer()
                Button(action: {
                    Task{
                        setDataToWind()
                    }
                }, label: {
                    Text("Wind")
                })
            }// End Hstack
            .padding()
            HStack{
                VStack{
                    Image(systemName: "sun.max.fill")
                    Image(systemName: "cloud.fill")
                    Image(systemName: "cloud.drizzle.fill")
                    Image(systemName: "cloud.rain.fill")
                    Image(systemName: "cloud.snow.fill")
                }
                Spacer()
                VStack{
                    Text("20 - 100")
                    Text("82 - 86")
                    Text("90 - 99")
                    Text("83 - 90 ")
                    Text("80 - 20")
                }
                Spacer()
            }//End Hstack
            .padding()
            .font(.title3)
            Spacer()


        }//End Vstack
        .padding()
        .task {
            await fetchWeatherData(lat: 44.34, long: 10.99)
        }
        

        
    }
    func setDataToWeather(){
        
    }
    func setDataToRain(){
        
    }
    func setDataToWind(){
        
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
            tempInFahrenheit = String(1.8*(tempInKelvin-273)+32)
            weatherIcon = findWeatherIcon(weatherIconNum: output.weather[0].icon)
            
        }catch{
            print("error retreiving data")
            
        }
        
        //Next 5 data
        //https://pro.openweathermap.org/data/2.5/forecast/hourly?lat={lat}&lon={lon}&appid={API key}
        let forcastAPICall = "https://pro.openweathermap.org/data/2.5/forecast/hourly?lat=" + String(lat) + "&lon=" + String(long) + "&appid=" + apiKey
        guard let urlF = URL(string: forcastAPICall) else{
            print("Invalid URL")
            return
        }
    }//end fetchWeatherData
    
    func findWeatherIcon(weatherIconNum: String) -> String{
        //Sunny
        if(weatherIconNum == "01d" ){
            return "sun.max"
        }else if(weatherIconNum == "01n"){
            return "moon"
        }else if(weatherIconNum == "02d"){
            return "cloud.sun"
        }else if(weatherIconNum == "02n"){
            return "cloud.moon"
        }else if(weatherIconNum == "03d" || weatherIconNum == "03n"){
            return "cloud"
        }else if(weatherIconNum == "04d" || weatherIconNum == "04n"){
            return "smoke"
        }else if(weatherIconNum == "09d" || weatherIconNum == "09n"){
            return "cloud.drizzle"
        }else if(weatherIconNum == "10d" || weatherIconNum == "10n"){
            return "cloud.heavyrain"
        }else if(weatherIconNum ==  "11d" || weatherIconNum == "11n"){
            return "cloud.bolt"
        }else if(weatherIconNum == "13d" || weatherIconNum == "13n"){
            return "cloud.snow"
        }else if(weatherIconNum == "50d"){
            return "sun.haze"
        }else if (weatherIconNum == "50n"){
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
            CurrentLocation = "Error retrieving Location Info"
            print(error)
        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

