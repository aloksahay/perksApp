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
    
    @State private var smartAccount: SmartAccount?
    
    @State private var simulateResult: SimulateResult?
    
    @State private var tx: Shared.Transaction?
    
    @State private var txHash: String?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                if smartAccount == nil {
                    Button(action: { Task {
                        Shared.setupTracing(filter: "info")
                        let keyStorage = EthereumKeyLocalStorage()
                        let account = try! EthereumAccount.importAccount(replacing: keyStorage, privateKey: "0xd5071223dcbf1cb824090bd98e0ddc807be00f1874fdd74bbd9225773a824397", keystorePassword: "MY_PASSWORD")
                        let options = SmartAccountOptions(masterKeySigner: account, appId: "438d464001b8511abc304b109a640606",  chainOptions: [ChainOptions(chainId: ChainID.ARBITRUM_GOERLI, rpcUrl: "https://node.wallet.unipass.id/arbitrum-goerli", relayerUrl: "https://testnet.wallet.unipass.id/relayer-v2-arbitrum")])
                        self.smartAccount = CustomAuthSdk.SmartAccount(options: options)
                        let initOptions = SmartAccountInitOptions(chainId: ChainID.ARBITRUM_GOERLI)
                        try! await self.smartAccount!.initialize(options: initOptions)
                        self.tx = Shared.Transaction(to: "0x93f2e90Ab182E445E66a8523B57B3443cb0f1fC2", data: "0x", value: "0x1")
                    }}) {
                        Text("Init Smart Account")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        self.smartAccount = nil
                    }) {
                        Text("Destroy Smart Account")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
            
            if smartAccount != nil {
                Text(text)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
                
                HStack {
                    Button(action: {
                        Task {
                            self.text = try await self.smartAccount!.address()
                            print(try await self.smartAccount!.address())
                        }
                    }) {
                        Text("Get Address")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        self.text = String(try! self.smartAccount!.chainID().rawValue)
                    }) {
                        Text("Get ChainID")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                let clientUrl = URL(string: "https://node.wallet.unipass.id/polygon-mumbai")!
                                let client = EthereumHttpClient(url: clientUrl)
                                
                                let address = try await self.smartAccount!.address()
                                let chain = try self.smartAccount!.chainID()
                                let ethereumAddress = EthereumAddress(address)
                                
                                let balanceResult = try await client.eth_getBalance(address: ethereumAddress, block: EthereumBlock.Latest)
                                
                                if chain == ChainID.POLYGON_MUMBAI {
                                    let maticBalance = Double(balanceResult) / 1e18
                                    self.text = String(format: "%.18f MATIC", maticBalance)
                                } else {
                                    self.text = String(balanceResult)
                                }
                            } catch {
                                self.text = "Error fetching balance: \(error.localizedDescription)"
                            }
                        }
                        
                    }) {
                        Text("Get Balance")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        Task {
                            
                            
                        do {
                              // test "0xCc985ba6934d134Feec4824ba40258608F3A4333"
                            let address = try await self.smartAccount!.address()
                            let user: PushUser?
                              if let _user = try await PushUser.get(
                                account: address, env: .STAGING) {
                                  user = _user
                                  self.text = _user.profile.name ?? "User found: No Name"
                                  print("got user")
                              } else {
                                  let newUser = try await PushUser.createUserEmpty(userAddress: address, env: .STAGING)
                                      self.text = newUser.profile.name ?? "User found: No Name"
                                  user = newUser
                                  print("created user")
                                  
                              }
                            
                            // inaccessible using core sdk, but available on fork: https://github.com/stevysmith/push-swift-sdk - but this has package conflicts
                            
//                            let keystore = try EthereumKeystore
//                            let privateKey = SignerPrivateKey(
//                                privateKey: ""
//                              )
//                            PushUser.DecryptPGPKey(encryptedPrivateKey: <#T##String#>, signer: <#T##Signer#>)
//                            let pgpKey:String = await PushUser.DecryptPGPKey(
//                              encryptedPrivateKey: user.encryptedPrivateKey,
//                              signer: signer
//                            )
//                            print(user)
                                
                            } catch {
                              print(error)
                            }
                            
                        }
                        
                    }) {
                        Text("Connect Push")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                }
                
                HStack {
                    Button(action: {
                        try! self.smartAccount!.switchChain(chainID: ChainID.ETHEREUM_GOERLI)
                        self.text = "success"
                    }) {
                        Text("Switch Chain")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { Task {
                        let sig = try! await self.smartAccount!.signMessage(message: "Hello World")
                        self.text = sig
                    }}) {
                        Text("Sign Message")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { Task {
                        // 第三个按钮的动作代码
                        let result = try! await self.smartAccount!.simulateTransaction(transaction: self.tx!, options: nil)
                        self.simulateResult = result
                        self.text = "tx: \(self.tx!)\n simualte result: \(result)"
                    }}) {
                        Text("Simulate Tx")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    Button(action: { Task {
                        // 第三个按钮的动作代码
                        if self.simulateResult != nil {
                            let txHash = try! await self.smartAccount!.sendTransaction(transaction: self.tx!, options: SendingTransactionOptions(fee: self.simulateResult!.feeOptions.first(where: { feeOption in
                                feeOption.token == "0x87F0E95E11a49f56b329A1c143Fb22430C07332a".lowercased()
                                
                            })))
                            self.text = "tx hash: \(txHash)"
                            self.txHash = txHash
                        } else {
                            self.text = "Please simulate first"
                        }
                        
                    }}) {
                        Text("Send Tx")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    Button(action: { Task {
                        // 第三个按钮的动作代码
                        if self.txHash != nil {
                            let receipt = try! await self.smartAccount!.waitTransactionReceiptByHash(transactionHash: self.txHash!)
                            self.text = "receipt: \(receipt!)"
                        } else {
                            self.text = "Please Send Tx first"
                        }
                        
                    }}) {
                        Text("Wait Tx")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
