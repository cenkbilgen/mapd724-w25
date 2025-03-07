//
//  ViewController.swift
//  MapUIKItSample
//
//  Created by cenk on 2025-03-07.
//

import UIKit
import MapKit

// MARK: Annotation Type

class BurgerKing: NSObject, MKAnnotation {
    // MKAnnotation Protocol properties
    let coordinate: CLLocationCoordinate2D // required
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

// MARK: ViewController

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 40)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let randomLatitude = 37.7749  // Approximate latitude for San Francisco
        let randomLongitude = -122.4194 // Approximate longitude for San Francisco
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let randomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: randomLatitude, longitude: randomLongitude), span: span)
        mapView.region = randomRegion
    
        mapView.delegate = self
        
        mapView.addAnnotations(
            [BurgerKing(coordinate: CLLocationCoordinate2D(latitude: 43.6487, longitude: -79.3848), title: "Burger King - Downtown", subtitle: "Located near Yonge-Dundas Square"),
            BurgerKing(coordinate: CLLocationCoordinate2D(latitude: 43.7170, longitude: -79.3765), title: "Burger King - Scarborough", subtitle: "Near Scarborough Town Centre")]
        )
        
        // Add Label to View
        label.text = "TORONTO"
        label.backgroundColor = UIColor.yellow
        mapView.addSubview(label)
        
        // Keep invisible, until map regions includes Toronto center coordinate
        label.alpha = 0
    }
    
    let torontoCoordinate = CLLocationCoordinate2D(latitude: 43.65107, longitude: -79.347015)
    
    // MapView Delegate functions
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // Convert the Toronto coordinate to MKMapPoint
            let torontoPoint = MKMapPoint(torontoCoordinate)

            // Get the visible map rect
            let visibleMapRect = mapView.visibleMapRect
            
            // Check if the Toronto coordinate is within the visible map rect
            if visibleMapRect.contains(torontoPoint) {
                print("Toronto center coordinate is visible")
                // Perform any action you need when the Toronto coordinate is visible
                label.alpha = 1
            } else {
                print("Toronto center coordinate is not visible")
                label.alpha = 0
            }
        }

    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        // we could add many types of Annotation, but we only added BurgerKing types
        if let burgerKing = annotation as? BurgerKing {
            // Use default Marker type View, could make a custom subclass of MKAnnotationView also
            let view = MKMarkerAnnotationView(annotation: burgerKing, reuseIdentifier: nil)
            // no need for reuseIdentifier, since only 2 annotations added
            // works exactly same as reuse identifier for UITableView and Cells
            return view
        } else {
            return nil
        }
    }
}


