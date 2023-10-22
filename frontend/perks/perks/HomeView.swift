//
//  HomeView.swift
//  perks
//
//  Created by Alok Sahay on 22.10.2023.
//

import SwiftUI
import MapKit

struct HomeView: View {
    
    @State private var balance: Float = 0
    @State private var xp: Int = 0
    @State private var navigateToDetail = false
    
    @StateObject private var viewModel = StoreMapViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    //Add funds
                    
                    
                }) {
                    Text("Top up ++")
                        .padding()
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                }
                .padding(.leading, 10)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Wallet Balance: $\(String(format: "%.1f", balance))")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("Perks: \(xp)")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                .padding()
            }
            
            Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.annotations) { annotation in
                
                MapAnnotation(coordinate: annotation.coordinate) {
                    
                    VStack {
                        Text("ApeVine")
                            .font(.caption)
                            .padding(4)
                            .fontWeight(.semibold)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        Button(action: {
                            // Open navigation to store
                            
                        }) {
                            Image("apecoin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        
                    }
                }
            }
            .frame(height: 250)
            .edgesIgnoringSafeArea(.horizontal)
            
            HStack {
                VStack(alignment: .leading) {
                    
                    Text("My Perks")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .padding(.top,5)
                    
                    Rectangle()
                        .fill(Color(UIColor.lightGray))
                        .frame(height: 1)
                        .padding(.bottom, 10)
                        .padding(.leading, -5)
                        .padding(.trailing, 5)
                    
                    Text("Downtown⌝")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .padding(.top, -5)
                    
                    Text("ApeVine #MadeByApes")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.leading)
            
            Button(action: {
                //Go to store detail
                self.navigateToDetail = true
            }) {
                VStack {
                    Text("")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(
                    Image("ApeVine")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
            }
            .background(
                NavigationLink("", destination: StoreView(), isActive: $navigateToDetail)
                    .hidden()
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.accentColor, lineWidth: 5)
            )
            .padding(.horizontal, 10)
            Spacer()
        }
        .background(Color.white)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


class StoreMapViewModel: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.0443, longitude: 14.2550),
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
        let pin = CustomAnnotation(coordinate: destination, title: "ApeVine")
        annotations.append(pin)
    }
}


