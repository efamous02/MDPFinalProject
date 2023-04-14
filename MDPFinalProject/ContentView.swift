//
//  ContentView.swift
//  MDPFinalProject
//
//  Created by Emma Famous on 3/28/23.
//

import SwiftUI

struct Place: Decodable {
    var lat: String
    var lon: String
    var display_name: String
}

struct ContentView: View {
    @State private var Location = ""
    @State private var PlaceInfo = [Place]()
    @State private var CurrentLocation = "Adress: "
    
    
    
    var body: some View {
        VStack {
            HStack(alignment: .top){
                TextField(CurrentLocation,text: $Location)
                Image(systemName: "magnifyingglass.circle")
            }
            .border(.secondary)
            .padding(.horizontal)
            
            Spacer()
            
            HStack{
                Text("86°")
                    .font(.largeTitle)
                    .padding()
                Image(systemName: "cloud.sun")

            }
            
            Spacer()

            
            Text("Next 5 Days")
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
            }
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
                    Text("95  Degrees")
                    Text("82  Degrees")
                    Text("90  Degrees")
                    Text("83  Degrees")
                    Text("80  Degrees")
                }
                Spacer()
            }
            .font(.title3)
            Spacer()


        }
        .padding()
        .task {
            await fetchGeoData()
        }
        

        
    }
    func setDataToWeather(){
        
    }
    func setDataToRain(){
        
    }
    func setDataToWind(){
        
    }
    func fetchGeoData() async {
        let urlInput = "https://geocode.maps.co/search?q={" + Location + "}"
        guard let url = URL(string: urlInput) else {
            print("URL IS INVALID")
            return
        }
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // decode that data
            if let decodedResponse = try? JSONDecoder().decode([Place].self, from: data) {
                PlaceInfo = decodedResponse
            }
        } catch {
            print("Data Invalid")
        }
        CurrentLocation = String(PlaceInfo.count)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

