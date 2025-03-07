//
//  ContentView.swift
//  CoreLocationSample
//
//  Created by cenk on 2025-03-07.
//

import SwiftUI
import CoreLocation
import CoreMotion

// NOTE:
// In the app target's Info, need to set a String of why the even needs the device's Location when Authorization requested.
// Otherwise prompt for authorization will not appear and authorization can never be granted.
// Older iOS versions would crash.


// MARK: Method 1: CoreLocation using CLLocationManager and Delegate
// The Delegate is a separate type for clarity.
// See the course notes for a variation where there is no seperate Delegate. The LocationState itself plays that role.
// That avoids this awkward pattern to pass the location information back to here from the Delegate
// that is the recommended approach, NOT this one

class LocationState: ObservableObject {
    
    @Published var location: CLLocation?

    let manager: CLLocationManager
    let managerDelegate: LocationManagerDelegate
    
    init() {
        self.manager = CLLocationManager()
        self.managerDelegate = LocationManagerDelegate()
        manager.delegate = managerDelegate
        
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        managerDelegate.state = self
    }
    
}

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    
    weak var state: LocationState? // weak because, if this is the only thing left referring to a LocationState?, it's OK to free it
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            print("lat: \(currentLocation.coordinate.latitude). lon: \(currentLocation.coordinate.longitude)")
            state?.location = currentLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Manager: \(manager.debugDescription) failed with error \(error)")
    }
}

// MARK: Method 2: CLLocationUpdate

class LocationStateWithCLLocationUpdate: ObservableObject {
    @Published var location: CLLocation?
    
    init() {
        Task {
            let updates = CLLocationUpdate.liveUpdates()
            
            do {
                for try await update in updates {
                    if let newLocation = update.location {
                        await MainActor.run {
                            self.location = newLocation
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct ContentView: View {
    
    // @StateObject var locationState= LocationState()
    @StateObject var locationState = LocationStateWithCLLocationUpdate()
    @State var updateCount = 0
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text(locationState.location?.timestamp.formatted() ?? "No timestamp")
            Text("Update Count: \(updateCount)")
        }
        .padding()
        .onChange(of: locationState.location) { _, _ in
            updateCount += 1
        }
    }
}

#Preview {
    ContentView()
}
