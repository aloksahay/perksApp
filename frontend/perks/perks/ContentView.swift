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
                            let account = try! EthereumAccount.importAccount(replacing: keyStorage, privateKey: "0xd5071223dcbf1cb824090bd98e0ddc807be00f1874fdd74bbd9225773a824397", keystorePassword: "")
                            let options = SmartAccountOptions(masterKeySigner: account, appId: "438d464001b8511abc304b109a640606",  chainOptions: [ChainOptions(chainId: ChainID.ETHEREUM_GOERLI, rpcUrl: "https://node.wallet.unipass.id/eth-goerli", relayerUrl: "https://testnet.wallet.unipass.id/relayer-v2-eth")])
                            self.smartAccount = CustomAuthSdk.SmartAccount(options: options)
                            let initOptions = SmartAccountInitOptions(chainId: ChainID.ETHEREUM_GOERLI)
                            try! await self.smartAccount!.initialize(options: initOptions)
                            self.tx = Shared.Transaction(to: "0x93f2e90Ab182E445E66a8523B57B3443cb0f1fC2", data: "0x", value: "0x1")
                            
                            let address = try await self.smartAccount!.address()
                            print("Current address")
                            print(address)
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
                            
                            print(res)
                            
                            let signer = SmartAccountSigner(account: self.smartAccount!)
                            
                            let user: PushUser?
                            if let _user: PushUser = try await PushUser.get(account: address, env: ENV.STAGING) {
                                user = _user
                            } else {
                                let _user:PushUser = try await PushUser.create(
                                    options: PushUser.CreateUserOptions(
                                        env: ENV.STAGING,
                                        signer: signer,
                                        progressHook: nil
                                    ))
                                user = _user
                            }
                            
                            print(user)
                            
                            let pgpPrivateKey = try await PushUser.DecryptPGPKey(
                              encryptedPrivateKey: user!.encryptedPrivateKey,
                              signer: signer
                            )
                            
                            let response:Message = try await PushChat.send(PushChat.SendOptions(
                              messageContent: "Gm gm! It's me... Mario",
                              messageType: "Text",
                              receiverAddress: "0xCc985ba6934d134Feec4824ba40258608F3A4333", 
                              account: address,
                              pgpPrivateKey: pgpPrivateKey,
                              env: ENV.STAGING
                            ))
                            
                            print("CHAT")
                            print(response)
                            
                            let typedSigner = TypedSmartAccountSigner(account: self.smartAccount!)
                            
                            let subscribers:PushChannel.ChannelSubscribers = try await PushChannel.getSubscribers(
                                option: PushChannel.GetChannelSubscribersOptions(
                                    channel: channelAddress,
                                    page: 1, limit: 10, env: .STAGING))
                            
                            print(subscribers)

                            let isOptIn:Bool = try await PushChannel.getIsSubscribed(
                                  userAddress: address, channelAddress: channelAddress, env: .STAGING)
                            
                            print("Is subscribed?")
                            print(isOptIn)
                            
                            let createGroupOptions = try PushChat.CreateGroupOptions(
                              name: "Testing Perk",
                              description: "Perk Description",
                              image:
                                "data:image/png;base64,OTMNCia0/QpFcVIfFli8a+k6MsQ3cpgVE1O7sewD9UInj1Cxs6VSBVJgRZwOlt99dJe8Snw+UV9vzqLUYe9+uGXwYmSlxQgW7cBcNM5mZK5X8Bklicpy7LCeMM+d8sRhSXICZrPIX1N3LmKgX0npT70wH7uEPWoik9d7ZsHdmL+YccdAB4vZNILVoawSd7ZpuG7RbyX1lneV7YQvnIqklfuum72WaGUL9UFPVQC1v6KN5v1HD3wef46AUIWPUZtvmuzrnsH0A65sWhfpfILQsdyOFchUUd0rIc1+nx5WjSfn11OsPIFioNYTAykrUNdW+MOvQF6O5cw0C9C4CeolEFR/ah/QVFOF3oGstDtkTnmeOQYLyFMFCteXRfjKHdTyOdoPsbWmN2xyWxnmdepnlQKxj7NQTW1knLT4xr2TewU68Jn/wm8pWKPLK/eNvPuoFF27wLmw2AlHKbRl6AzDJ2oa3zpDb2yaytzAJ9bS0Z7dKNPAeqjD8I96ASEN8blrF4xTNw3X3ZhfPxhOcZpZpuSY+XM8g71+ZgUpvzd59Lp3419he8sT+txDzxGBM5orR62mJCIi4kIoFjA2vWZqOL4Ire7dxdEoXR6x2ce0hD5d86MTSPn+BkpDgsqxcHixvbaGh4Hh/Y26eD8Y7NfMosQ9JSxfhgQnMxuNjwAkpUo=",
                              members: ["0xcc985ba6934d134feec4824ba40258608f3a4333"], // Max 10
                              isPublic: false, // Only in private group messages are encrypted
                              creatorAddress: address,
                              creatorPgpPrivateKey: pgpPrivateKey,
                              env: ENV.STAGING
                            )

                            let group:PushChat.PushGroup = try await PushChat.createGroup(options: createGroupOptions)
                            
                            print("Group chat")
                            print(group)
                            
                            let result:Bool = try await PushChannel.unsubscribe(
                                option: PushChannel.SubscribeOption(
                                    signer: typedSigner,
                                    channelAddress: channelAddress,
                                    env: .STAGING))
                            
                            print("unsubscribe")
                            print(result)

                            let subscribeResult:Bool = try await PushChannel.subscribe(
                                option: PushChannel.SubscribeOption(
                                    signer: typedSigner,
                                    channelAddress: channelAddress,
                                    env: .STAGING))
                            
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

class TypedSmartAccountSigner: Push.TypedSigner {
    private let account: SmartAccount
    
    init(account: SmartAccount) {
        self.account = account
    }
    
    func getEip712Signature(message: String) async throws -> String {
        return try await account.signMessage(message: message)
    }
    
    func getAddress() async throws -> String {
        return try await account.address()
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
