import Foundation
import Combine
import os.log

class ExchangeRateViewModel: ObservableObject {
    @Published var rate: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var lastUpdated: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let dateFormatter: DateFormatter
    private let logger = Logger(subsystem: "com.yourcompany.CurrencyExchangeApp", category: "ExchangeRateViewModel")
    
    init() {
        logger.info("ExchangeRateViewModel initialized")
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
    }
    
    func fetchExchangeRate() {
        isLoading = true
        error = nil
        logger.info("Starting to fetch exchange rate")
        
        // Using a free API for exchange rates
        guard let url = URL(string: "https://open.er-api.com/v6/latest/CNY") else {
            self.error = "Invalid URL"
            self.isLoading = false
            logger.error("Invalid URL configured")
            return
        }
        
        logger.debug("Fetching from URL: \(url.absoluteString)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse {
                    self.logger.debug("Received response with status code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        self.logger.error("HTTP error: \(httpResponse.statusCode)")
                    }
                }
                return data
            }
            .decode(type: ExchangeRateResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.logger.error("Fetch failed: \(error.localizedDescription)")
                    
                    // Log more details about the error
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .dataCorrupted(let context):
                            self?.logger.error("Data corrupted: \(context.debugDescription)")
                        case .keyNotFound(let key, let context):
                            self?.logger.error("Key not found: \(key.stringValue) in \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            self?.logger.error("Type mismatch: expected \(type) in \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            self?.logger.error("Value not found: expected \(type) in \(context.debugDescription)")
                        @unknown default:
                            self?.logger.error("Unknown decoding error")
                        }
                    }
                } else {
                    self?.logger.info("Successfully fetched exchange rate")
                }
            }, receiveValue: { [weak self] response in
                guard let self = self, let usdRate = response.rates["USD"] else {
                    self?.error = "Could not find USD rate"
                    self?.logger.error("USD rate not found in response")
                    return
                }
                
                // Since we're using CNY as base, we need to calculate USD to CNY
                self.rate = 1.0 / usdRate
                self.lastUpdated = self.dateFormatter.string(from: Date())
                self.logger.info("Updated rate: \(self.rate), last updated: \(self.lastUpdated)")
                self.logger.info("Base currency: \(response.base_code)")
            })
            .store(in: &cancellables)
    }
    
    // Add a method to debug the raw response
    func debugFetchRawResponse() {
        guard let url = URL(string: "https://open.er-api.com/v6/latest/CNY") else {
            logger.error("Invalid URL for debug fetch")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.logger.error("Debug fetch failed: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    self?.logger.debug("Debug HTTP status: \(httpResponse.statusCode)")
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    self?.logger.debug("Raw response: \(jsonString)")
                } else {
                    self?.logger.error("Could not convert response data to string")
                }
            })
            .store(in: &cancellables)
    }
}

struct ExchangeRateResponse: Codable {
    let result: String
    let provider: String
    let documentation: String
    let terms_of_use: String
    let time_last_update_unix: TimeInterval
    let time_last_update_utc: String
    let time_next_update_unix: TimeInterval
    let time_next_update_utc: String
    let time_eol_unix: Int
    let base_code: String
    let rates: [String: Double]
} 