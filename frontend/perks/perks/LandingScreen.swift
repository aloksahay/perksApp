//
//  LandingScreen.swift
//  perks
//
//  Created by Alok Sahay on 17.10.2023.
//

import SwiftUI
import AVKit



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
                    Button(action: {
                        // Handle login button tap
                    }) {
                        Text("GET STARTED")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                    }
                    .padding(.bottom, 50) // Adjust bottom padding as needed
                }
            }
        }
}


