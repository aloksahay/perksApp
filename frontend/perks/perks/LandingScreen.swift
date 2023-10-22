//
//  LandingScreen.swift
//  perks
//
//  Created by Alok Sahay on 17.10.2023.
//

import SwiftUI
import AVKit

// TODO
// remove video controls
// Splash background color from white to #FCD73E

struct LandingScreen: View {
    private let player = AVPlayer(url: Bundle.main.url(forResource: "backgroundVid", withExtension: "mp4")!)
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                    player.actionAtItemEnd = .none
                    NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                           object: player.currentItem,
                                                           queue: nil) { notification in
                        player.seek(to: .zero)
                        player.play()
                    }
                }
            
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(contentMode: .fill)
            
            VStack {
                Spacer()
                
                Image("Perks_text")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200) // Set the image size
                
                Spacer()
                
                Button(action: {
                    // do all smart account logic here
                }) {
                    Text("Connect Wallet")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

//move this somewhere later
//Light #FCD73E
//Dark #D7BD52

extension Color {
 
    init(hex: UInt) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double((hex & 0x0000FF) >> 0) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
    
    static let lightThemeColor = Color.init(hex: 0xFCD73E)
    static let darkThemeColor = Color.init(hex: 0xD7BD52)
}
