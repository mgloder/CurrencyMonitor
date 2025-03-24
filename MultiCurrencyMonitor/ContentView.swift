//
//  ContentView.swift
//  MultiCurrencyMonitor
//
//  Created by Yan Xu on 24/3/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var exchangeRateViewModel = ExchangeRateViewModel()
    
    var body: some View {
        VStack {
            if exchangeRateViewModel.isLoading {
                ProgressView()
                    .padding()
            } else if let error = exchangeRateViewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error: \(error)")
                        .padding()
                    Button("Retry") {
                        exchangeRateViewModel.fetchExchangeRate()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("USD to CNY Exchange Rate")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            exchangeRateViewModel.fetchExchangeRate()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("1 USD = ")
                        Text("\(exchangeRateViewModel.rate, specifier: "%.4f") CNY")
                            .bold()
                    }
                    
                    HStack {
                        Text("1 CNY = ")
                        Text("\(1 / exchangeRateViewModel.rate, specifier: "%.4f") USD")
                            .bold()
                    }
                    
                    Text("Last updated: \(exchangeRateViewModel.lastUpdated)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(width: 250)
            }
        }
        .onAppear {
            exchangeRateViewModel.fetchExchangeRate()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
