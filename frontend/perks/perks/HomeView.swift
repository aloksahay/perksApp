//
//  HomeView.swift
//  perks
//
//  Created by Alok Sahay on 22.10.2023.
//

import SwiftUI
import MapKit

struct HomeView: View {
    
    @State private var balance: Int = 0
    @State private var xp: Int = 0
    
    @StateObject private var viewModel = StoreMapViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    //Add funds
                    
                    
                }) {
                    Text("Top Up")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                }
                .padding(.leading, 10)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Wallet Balance: \(balance) USD")
                    Text("Perks: \(xp) XP")
                }
                .padding()
            }
            
            Map(coordinateRegion: $viewModel.region)
                .frame(height: 300)
                .edgesIgnoringSafeArea(.horizontal)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("1421 Valencia St, San Francisco")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                    
                    Text("Made By Apes Store #2")
                        .font(.title2)
                        .padding(.bottom, 10)
                }
                Spacer()
            }
            .padding(.leading)
            
            
            Spacer()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


class StoreMapViewModel: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var annotations: [CustomAnnotation] = []
    
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension StoreMapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        region.center = location.coordinate
        
        let destination = location.coordinate.locationWithBearing(bearing: 0, distanceMeters: 100)
        let pin = CustomAnnotation(coordinate: destination, title: "MFA store")
        annotations.append(pin)
    }
}


