//
//  ContentView.swift
//  MapSample
//
//  Created by cenk on 2025-03-07.
//

import SwiftUI
import MapKit


// MARK: Annotation

struct Restaurant: Identifiable, Hashable {
    let id = UUID()
    
    // NOTE:
    // Rather than this:
    // let coordinates: CLLocationCoordinate2D
    
    // Instead split into latitude and longitude as Double or CLLocationDegree
    // (same thing, typealias CLLocationDegrees == Double)
    
    // CLLocationCoordinate2D is not Equatable, Hashable or Codable
    // Double is all those things
    
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let name: String
    let typeOfFood: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude,
                               longitude: longitude)
    }
}

// MARK: Model

class RestaurantModel: ObservableObject {
    let vegetarianRestaurants = [
        Restaurant(latitude: 43.6542, longitude: -79.3848, name: "Fresh on Front", typeOfFood: "Vegetarian & Vegan"),
        Restaurant(latitude: 43.6635, longitude: -79.4015, name: "Planta", typeOfFood: "Vegetarian & Vegan"),
        Restaurant(latitude: 43.6498, longitude: -79.3702, name: "DaiLo", typeOfFood: "Pan-Asian Vegetarian"),
        Restaurant(latitude: 43.6471, longitude: -79.4000, name: "Karma’s Kitchen", typeOfFood: "Vegetarian Café"),
        Restaurant(latitude: 43.6682, longitude: -79.3905, name: "The Beet", typeOfFood: "Vegetarian & Vegan"),
        Restaurant(latitude: 43.6458, longitude: -79.3759, name: "Cafe Green", typeOfFood: "Vegetarian & Vegan")
    ]
}

// MARK: View

struct ContentView: View {
    
    @StateObject var model = RestaurantModel()

    @State var cameraPosition = MapCameraPosition.automatic
    
    @State var selection: Restaurant?
    // anything type that is Hashable can be a selection type, Optional version of it
    // nil means no selection
    
    var body: some View {
        Map(position: $cameraPosition,
            selection: $selection) {
            ForEach(model.vegetarianRestaurants) { restaurant in
                Marker(restaurant.name,
                       systemImage: "diamond",
                       coordinate: restaurant.coordinate)
                    .tag(restaurant) // this will be the value $selection get's set to
            }
        }
        .onChange(of: selection) { _, newValue in
            // ignore the oldValue
            // newValue could be nil, if so set position to auto
            if let newValue {
                cameraPosition = .camera(MapCamera(centerCoordinate: newValue.coordinate, distance: 200))
            } else {
                cameraPosition = .automatic
            }
        }
    }
    
}

#Preview {
    ContentView()
}
