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
                    addFundsToVault(Double(fundsToAdd) ?? 0.0)
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
    
    func addFundsToVault(_ amount: Double) {
        vaultBalance += amount
        fundsToAdd = ""  // Clear the text field after adding funds
    }
}

struct Product: Identifiable {
    var id = UUID()
    var name: String
    var price: Double
}
