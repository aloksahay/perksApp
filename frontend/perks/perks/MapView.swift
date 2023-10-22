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
    @State private var showCheckinAlert = false
    @Binding var smartAccount: SmartAccount?
    @Binding var user: PushUser?
    @State private var checkInStatus: CheckInStatus = .notCheckedIn
    @State private var navigateToMarketplace: Bool = false
    @State private var balance: Float = 0
    @State private var xp: Int = 0
    
    var body: some View {
        NavigationView {
            
            VStack {
                HStack {
                    Button(action: {
                        //Add funds
                        navigateToMarketplace = true
                        
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
                        
                        Text("Downtown, Prague 1⌝")
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
                    showCheckinAlert = true
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
                .cornerRadius(7)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: 5)
                )
                .clipped()
                .padding(10)
                .alert(isPresented: $showCheckinAlert) {
                            Alert(
                                title: Text("You need to checkin"),
                                message: Text("Before selecting this store you need to checkin first"),
                                dismissButton: .default(Text("Okay"))
                            )
                        }
                
                Spacer()
            }
            .background(Color.white)
            
        }
        .background(NavigationLink("", destination: MarketplaceView(smartAccount: $smartAccount), isActive: $navigateToMarketplace))
    }
    
    func checkIfUserHasRewardsCard() -> Bool {
        return Bool.random()
    }
    
    func mintRewardsCard(for userAddress: String) async throws -> String {
        
        let typedSigner = TypedSmartAccountSigner(account: self.smartAccount!)
        let userAddress = try await typedSigner.getAddress()

        let subChannelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"
        
        let subscribe = try await PushChannel.subscribe(
          option: PushChannel.SubscribeOption(
            signer: typedSigner, channelAddress: subChannelAddress, env: .STAGING))

        let isOptIn = try await PushChannel.getIsSubscribed(
          userAddress: userAddress, channelAddress: subChannelAddress, env: .STAGING)
        
        print("Is subscribed?")
        print(isOptIn)
        
        let feeds = try await PushUser.getFeeds(
          options:
            PushUser.FeedsOptionsType(
              user: userAddress,
              env: ENV.STAGING
            )
        )
        
        print("FEED")
        print(feeds)
        
        let unsubTypedSigner = UnsubscribeTypedSmartAccountSigner(account: self.smartAccount!)
        let unsubUserAddress = try await unsubTypedSigner.getAddress()
        
        let unsub = try await PushChannel.unsubscribe(
          option: PushChannel.SubscribeOption(
            signer: unsubTypedSigner, channelAddress: subChannelAddress, env: .STAGING))

        let isOptOut = try await PushChannel.getIsSubscribed(
          userAddress: unsubUserAddress, channelAddress: subChannelAddress, env: .STAGING)

        print("Is subscribed?")
        print(isOptOut)

        
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
        let pin = CustomAnnotation(coordinate: destination, title: "MFA store")
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

class TypedSmartAccountSigner: Push.TypedSigner {
    private let account: SmartAccount
    
    init(account: SmartAccount) {
        self.account = account
    }
    
    func getEip712Signature(message: String) async throws -> String {
    
        
//        {"types":{"Subscribe":[{"name":"channel","type":"address"},{"name":"subscriber","type":"address"},{"name":"action","type":"string"}],"EIP712Domain":[{"name":"name","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}]},"primaryType":"Subscribe","domain":{"name":"EPNS COMM V1","chainId":5,"verifyingContract":"0x"},"message":{"channel":"0xd26a7bf7fa0f8f1f3f73b056c9a67565a6afe63c","subscriber":"0x1b405a981be0f5aa5c2662c1b11a87d50c5c3eaa","action":"Subscribe"}}

        let address = try await account.address()
        
        let domain = Eip712Domain(name: "EPNS COMM V1", version: nil, chainId: 5, verifyingContract: "0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa", salt: nil)
        
        let types = ["EIP712Domain":[Eip712DomainType(name: "name", type: "string"),Eip712DomainType(name: "chainId", type:"uint256"),Eip712DomainType(name: "verifyingContract", type: "address")],"Subscribe":[Eip712DomainType(name: "channel", type:"address"),Eip712DomainType(name: "subscriber", type: "address"),Eip712DomainType(name: "action", type: "string")]]
        
        let typedData = Shared.TypedData(domain: domain, types:types, primaryType: "Subscribe", message: ["channel":Shared.Value.stringValue(inner: "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"),"subscriber":Shared.Value.stringValue(inner: "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"),"action":Shared.Value.stringValue(inner: "Subscribe")])
        
        let sig = try! await account.signTypedData(typedData: typedData)
//        return sig
        return
          "0xbd2724da36cbb3a99d59d4133b9cceb6a602bb1c0aab69d249a199c071a196880e8b7fba882cb10e943223be2ce34ccc5ceb4e1326410e968cd4497748c0de111c"
    }
    
    func getAddress() async throws -> String {
        return "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
//        return try await account.address()
    }
}

class UnsubscribeTypedSmartAccountSigner: Push.TypedSigner {
    private let account: SmartAccount
    
    init(account: SmartAccount) {
        self.account = account
    }
    
    func getEip712Signature(message: String) async throws -> String {
        let address = try await account.address()
        
        let domain = Eip712Domain(name: "EPNS COMM V1", version: nil, chainId: 5, verifyingContract: "0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa", salt: nil)
        
        let types = ["EIP712Domain":[Eip712DomainType(name: "name", type: "string"),Eip712DomainType(name: "chainId", type:"uint256"),Eip712DomainType(name: "verifyingContract", type: "address")],"Unsubscribe":[Eip712DomainType(name: "channel", type:"address"),Eip712DomainType(name: "unsubscriber", type: "address"),Eip712DomainType(name: "action", type: "string")]]
        
        let typedData = Shared.TypedData(domain: domain, types:types, primaryType: "Unsubscribe", message: ["channel":Shared.Value.stringValue(inner: "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"),"unsubscriber":Shared.Value.stringValue(inner: "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"),"action":Shared.Value.stringValue(inner: "Unsubscribe")])
        
        let sig = try! await account.signTypedData(typedData: typedData)
//        return sig
        return
          "0xac77e24153f6b5a46b42020ba987d402c4b5b0308aa62cf06cd2a9173c3c613d4d182bba1607d004a504848cebe30b73c9efb88897e0f9563f38e21ec2e84b281b"
    }
    
    func getAddress() async throws -> String {
        return "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
//        return try await account.address()
    }
}



class SmartAccountSigner: Push.Signer {

    private let account: SmartAccount
    
    init(account: SmartAccount) {
        self.account = account
    }
    
    func getEip191Signature(message: String) async throws -> String {
        return try await account.signMessage(message: message)
    }
    
    func getAddress() async throws -> String {
        return try await account.address()
    }
}
