//
//  ContentView.swift
//  perks
//
//  Created by Steve Smith on 16/10/2023.
//

import CustomAuthSdk
import SwiftUI
import web3
import Push

struct ContentView: View {
    @State private var text: String = "Initial Text"
    @State private var isLogged: Bool = false
    @State private var hasPerkCard: Bool = false
    @State private var isMapViewActive: Bool = false
    @State private var isDebugViewActive: Bool = false
    @State private var smartAccount: SmartAccount?
    @State private var tx: Shared.Transaction?
    @State private var user: PushUser?
    
    var body: some View {
        NavigationView {
            VStack {
                if !isLogged {
                    Button("Login") {
                        Task {
                            Shared.setupTracing(filter: "info")
                            let keyStorage = EthereumKeyLocalStorage()
                            let account = try! EthereumAccount.importAccount(replacing: keyStorage, privateKey: "0xd5071223dcbf1cb824090bd98e0ddc807be00f1874fdd74bbd9225773a824397", keystorePassword: "MY_PASSWORD")
                            let options = SmartAccountOptions(masterKeySigner: account, appId: "438d464001b8511abc304b109a640606",  chainOptions: [ChainOptions(chainId: ChainID.ARBITRUM_GOERLI, rpcUrl: "https://node.wallet.unipass.id/arbitrum-goerli", relayerUrl: "https://testnet.wallet.unipass.id/relayer-v2-arbitrum")])
                            self.smartAccount = CustomAuthSdk.SmartAccount(options: options)
                            let initOptions = SmartAccountInitOptions(chainId: ChainID.ARBITRUM_GOERLI)
                            try! await self.smartAccount!.initialize(options: initOptions)
                            self.tx = Shared.Transaction(to: "0x93f2e90Ab182E445E66a8523B57B3443cb0f1fC2", data: "0x", value: "0x1")
                            
                            let address = try await self.smartAccount!.address()
                            if let _user = try await PushUser.get(
                                account: address, env: .STAGING) {
                                self.user = _user
                                self.text = _user.profile.name ?? "User found: No Name"
                                print("got user")
                            } else {
                                let newUser = try await PushUser.createUserEmpty(userAddress: address, env: .STAGING)
                                self.text = newUser.profile.name ?? "User found: No Name"
                                self.user = newUser
                                print("created user")
                            }
                            
                            let channelAddress = "0xCc985ba6934d134Feec4824ba40258608F3A4333"
                            let res:PushChannel? = try await PushChannel.getChannel(
                            options: PushChannel.GetChannelOption(
                                channel: channelAddress, env: .STAGING
                            ))
                            
                            let privateKey = ""
                            
//                            let signer = SignerPrivateKey.init("")
                            
//                            PushChannel.subscribe(option: PushChannel.SubscribeOption(signer: signer, channelAddress: channelAddress, env: .STAGING))
                            
                            print(res)
                            
                            isLogged = true
                        }
                    }
                } else if !hasPerkCard {
                    // Check or mint perk card button and logic here
                    Button("Check/Mint Perk Card") {
                        Task {
                            // Your check/mint perk card logic here
                            // For demonstration, we'll assume it's minted successfully
                            hasPerkCard = true
                        }
                    }
                } else {
                    // Perk card exists, show option to open MapView
                    NavigationLink(destination: MapView(smartAccount: $smartAccount, user: $user), isActive: $isMapViewActive) {
                        Button("Open Map") {
                            isMapViewActive = true
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
