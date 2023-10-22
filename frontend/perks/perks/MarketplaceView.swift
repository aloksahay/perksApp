//
//  MarketplaceView.swift
//  perks
//
//  Created by Steve Smith on 17/10/2023.
//

import CustomAuthSdk
import SwiftUI
import web3
import Push
import web3swift
import BigInt
import Web3Core

struct MarketplaceView: View {
    @Binding var smartAccount: SmartAccount?
    @State private var fundsToAdd: String = ""
    @State private var vaultBalance: Double = 0.0
    @State private var userXP: Int = 0
    @State private var selectedProduct: Product?
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    // Sample products with prices
    let products = [
        Product(name: "Product A", price: 10.0),
        Product(name: "Product B", price: 20.0),
        Product(name: "Product C", price: 30.0),
        Product(name: "Product D", price: 40.0)
    ]

    var body: some View {
        VStack {
            Text("AppCoin Products")
                .font(.largeTitle)
            
            Text("Your ApeCoin XP: \(userXP)")
                .font(.headline)
            Text("Vault Balance: $\(vaultBalance, specifier: "%.2f")")
                .font(.headline)

            
            List(products, id: \.id) { product in
                Button(action: {
                    self.selectedProduct = product
                }) {
                    Text("\(product.name) - $\(product.price, specifier: "%.2f")")
                }
            }
            
            Button("Contact Support") {
                
                    Task {
                        let user: PushUser?
                        let address = try await self.smartAccount!.address()
                        let signer = SmartAccountSigner(account: self.smartAccount!)
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
                        
                        let pgpPrivateKey = try await PushUser.DecryptPGPKey(
                          encryptedPrivateKey: user!.encryptedPrivateKey,
                          signer: signer
                        )
                        
                        let response:Message = try await PushChat.send(PushChat.SendOptions(
                          messageContent: "Gm gm! It's me... Mario, I need help!",
                          messageType: "Text",
                          receiverAddress: "0xCc985ba6934d134Feec4824ba40258608F3A4333",
                          account: address,
                          pgpPrivateKey: pgpPrivateKey,
                          env: ENV.STAGING
                        ))
                        
                        print(response)
                    }
                
               
              }
              .padding()
              .background(Color.blue)
              .foregroundColor(.white)
              .cornerRadius(5)
            
            if let product = selectedProduct {
                VStack(spacing: 20) {
                    Text("Buy \(product.name) for $\(product.price, specifier: "%.2f")?")
                    Button("Buy") {
                        if vaultBalance >= product.price {
                            vaultBalance -= product.price
                            userXP += 5
                            alertTitle = "Success"
                            alertMessage = "You've purchased \(product.name)."
                            showAlert = true
                        } else {
                            alertTitle = "Insufficient Funds"
                            alertMessage = "Please add more funds to your vault."
                            showAlert = true
                        }
                        selectedProduct = nil
                    }
                    Button("Cancel") {
                        selectedProduct = nil
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
            }
            
            VStack {
                Text("Vault Balance: $\(vaultBalance, specifier: "%.2f")")
                    .font(.headline)
                
                TextField("Enter funds to add to vault", text: $fundsToAdd)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.decimalPad)
                
                Button("Add Funds to Vault") {
                    Task {
                        await addFundsToVault(Double(fundsToAdd) ?? 0.0)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func addFundsToVault(_ amount: Double) async {
        
        let vaultAddress = EthereumAddress("0x8078cB27dD51266950FE0317CB314F16f11Fac8b")!
        
        let provider = await Web3HttpProvider(URL(string: "https://node.wallet.unipass.id/polygon-mumbai")!, network: Networks.Custom(networkID: BigUInt(80001)))!
        let web3 = Web3(provider: provider)
        
        let ABI_STRING: String = """
        [{"inputs":[{"internalType":"address","name":"_uniswapPoolManager","type":"address"},{"internalType":"address","name":"_perksToken","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"owner","type":"address"}],"name":"OwnableInvalidOwner","type":"error"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"OwnableUnauthorizedAccount","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"store","type":"address"},{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"PaidToStore","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"PerksBurnt","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"PerksEarned","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"PerksRedeemed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"store","type":"address"},{"indexed":false,"internalType":"uint256","name":"rewardFraction","type":"uint256"}],"name":"StoreAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"store","type":"address"}],"name":"StoreRemoved","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"USDCDeposited","type":"event"},{"inputs":[],"name":"USDC","outputs":[{"internalType":"contract IERC20","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"burnPerksTokens","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"store","type":"address"}],"name":"deleteStore","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"depositUSDC","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"lastBurnTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"lastTxTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"store","type":"address"},{"internalType":"uint256","name":"usdcAmount","type":"uint256"}],"name":"payToStore","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"perksToken","outputs":[{"internalType":"contract PerksToken","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"perksAmount","type":"uint256"},{"internalType":"address","name":"store","type":"address"}],"name":"redeemPerksTokens","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"rewardFraction","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"components":[{"internalType":"Currency","name":"currency0","type":"address"},{"internalType":"Currency","name":"currency1","type":"address"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"int24","name":"tickSpacing","type":"int24"},{"internalType":"contract IHooks","name":"hooks","type":"address"}],"internalType":"struct PoolKey","name":"poolKey","type":"tuple"}],"name":"setUniswapPoolId","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"storeUsdcAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"uniswapPoolKey","outputs":[{"internalType":"Currency","name":"currency0","type":"address"},{"internalType":"Currency","name":"currency1","type":"address"},{"internalType":"uint24","name":"fee","type":"uint24"},{"internalType":"int24","name":"tickSpacing","type":"int24"},{"internalType":"contract IHooks","name":"hooks","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"uniswapPoolManager","outputs":[{"internalType":"contract IPoolManager","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"userUSDCAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"store","type":"address"},{"internalType":"uint256","name":"_rewardFraction","type":"uint256"}],"name":"whitelisteStore","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"whitelistedStores","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"}]
        """

        let contract = web3.contract(ABI_STRING, at: vaultAddress)
        
        // Encode the function call
        let usdcAmount: BigUInt = 1000 * 1_000_000  // 1000 USDC, accounting for 6 decimal places
        let parameters: [AnyObject] = [usdcAmount as AnyObject]
        let encodedData = contract?.contract.method("depositUSDC", parameters: parameters, extraData: nil)

        // Create the transaction
        let tx = Shared.Transaction(to: "0x8078cB27dD51266950FE0317CB314F16f11Fac8b", data: encodedData!.toHexString(), value: "0x0")
//        let result = try! await smartAccount!.simulateTransaction(transaction: tx, options: nil)
//        print("tx: \(tx)\n simulate result: \(result)")
        
        vaultBalance += amount
        fundsToAdd = ""  // Clear the text field after adding funds
    }
}

struct Product: Identifiable {
    var id = UUID()
    var name: String
    var price: Double
}
