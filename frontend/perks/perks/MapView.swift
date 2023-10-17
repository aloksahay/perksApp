//
//  MapView.swift
//  perks
//
//  Created by Steve Smith on 17/10/2023.
//

import SwiftUI
import MapKit
import CustomAuthSdk
import web3
import Push

enum CheckInStatus {
    case notCheckedIn
    case memberOfRewardsClub
    case notAMember
}

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showAlert: Bool = false
    @Binding var smartAccount: SmartAccount?
    @Binding var user: PushUser?
    @State private var checkInStatus: CheckInStatus = .notCheckedIn
    @State private var navigateToMarketplace: Bool = false
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    VStack {
                        Text(annotation.title ?? "")
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(radius: 4)
                        Button(action: {
                            let hasRewardsCard = checkIfUserHasRewardsCard()
                            
                            checkInStatus = hasRewardsCard ? .memberOfRewardsClub : .notAMember
                            showAlert = true
                        }) {
                            Image("apecoin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)  // Adjust this size as needed
                                .foregroundColor(.blue)
                                .shadow(radius: 4)
                        }
                        .alert(isPresented: $showAlert) {
                            switch checkInStatus {
                            case .memberOfRewardsClub:
                                return Alert(title: Text("Welcome Back!"),
                                             message: Text("You're a member of the rewards club."),
                                             dismissButton: .default(Text("OK")) {
                                                 navigateToMarketplace = true
                                             })
                            case .notAMember:
                                return Alert(title: Text("Welcome!"),
                                             message: Text("You're new here. Would you like to join our rewards club?"),
                                             primaryButton: .default(Text("Yes"), action: {
                                    Task {
                                        do {
                                            let userAddress = try await self.smartAccount!.address()
                                            let txHash = try await mintRewardsCard(for: userAddress)
                                            // Optionally, you can wait for the transaction to be confirmed here
                                            print("Minting successful with tx hash: \(txHash)")
                                            
                                            navigateToMarketplace = true
                                        } catch {
                                            print("Error minting rewards card: \(error)")
                                        }
                                    }
                                }),
                                             secondaryButton: .cancel())
                            default:
                                return Alert(title: Text("Error"), dismissButton: .default(Text("OK")))
                            }
                        }
                    }
                }
            }
        }
        .background(NavigationLink("", destination: MarketplaceView(smartAccount: $smartAccount), isActive: $navigateToMarketplace))
    }
    
    func checkIfUserHasRewardsCard() -> Bool {
        return Bool.random()
    }
    
    func mintRewardsCard(for userAddress: String) async throws -> String {
        return "minted"
    }
    
    
}

class MapViewModel: NSObject, ObservableObject {
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

extension MapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        region.center = location.coordinate
        
        // Create a pin 100 meters away from the user's location
        let destination = location.coordinate.locationWithBearing(bearing: 0, distanceMeters: 100)
        let pin = CustomAnnotation(coordinate: destination, title: "ApeCoin Store")
        annotations.append(pin)
    }
}

class CustomAnnotation: NSObject, Identifiable, MKAnnotation {
    var id = UUID() // This makes it conform to Identifiable
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
    }
}

extension CLLocationCoordinate2D {
    func locationWithBearing(bearing: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6)
        
        let rbearing = bearing * .pi / 180.0
        
        let lat1 = self.latitude * .pi / 180
        let lon1 = self.longitude * .pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(rbearing))
        let lon2 = lon1 + atan2(sin(rbearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
    }
}
