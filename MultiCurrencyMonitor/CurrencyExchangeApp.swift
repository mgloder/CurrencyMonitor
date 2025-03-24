import SwiftUI
import os.log

@main
struct CurrencyExchangeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let logger = Logger(subsystem: "com.yourcompany.CurrencyExchangeApp", category: "main")
    
    init() {
        // Set up global error handling
        logger.info("Application initializing")
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
                .onAppear {
                    logger.info("Settings scene appeared")
                }
                .onDisappear {
                    logger.info("Settings scene disappeared")
                }
        }
    }
}

// Add this extension to capture uncaught exceptions
extension NSApplication {
    static func logError(_ error: Error) {
        let logger = Logger(subsystem: "com.yourcompany.CurrencyExchangeApp", category: "error")
        logger.error("Uncaught error: \(error.localizedDescription)")
        
        // You can also log to a file or send to a service
        print("ERROR: \(error.localizedDescription)")
    }
} 