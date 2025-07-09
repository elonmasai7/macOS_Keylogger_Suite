import Foundation

class AppFileManager {
    static let shared = AppFileManager()
    private let fileManager = FileManager.default
    
    private init() {}
    
    func applicationSupportDirectory() -> URL {
        let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let bundleDir = appSupportDir.appendingPathComponent(Constants.bundleID)
        
        // Create directory if needed
        if !fileManager.fileExists(atPath: bundleDir.path) {
            try? fileManager.createDirectory(at: bundleDir, withIntermediateDirectories: true)
        }
        
        return bundleDir
    }
    
    func logFilePath() -> URL {
        return applicationSupportDirectory().appendingPathComponent(Constants.logFileName)
    }
    
    func decodedLogFilePath() -> URL {
        return applicationSupportDirectory().appendingPathComponent(Constants.decodedLogFileName)
    }
    
    func pdfReportPath() -> URL {
        let computerName = Host.current().localizedName ?? "UnknownMac"
        return applicationSupportDirectory().appendingPathComponent("\(computerName)_SystemReport.pdf")
    }
    
    func rotateLogs() {
        let logPath = logFilePath().path
        let decodedPath = decodedLogFilePath().path
        
        // Archive existing logs
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        
        if fileManager.fileExists(atPath: logPath) {
            let archivePath = applicationSupportDirectory().appendingPathComponent("archive_\(timestamp)_\(Constants.logFileName)").path
            try? fileManager.moveItem(atPath: logPath, toPath: archivePath)
        }
        
        if fileManager.fileExists(atPath: decodedPath) {
            let archivePath = applicationSupportDirectory().appendingPathComponent("archive_\(timestamp)_\(Constants.decodedLogFileName)").path
            try? fileManager.moveItem(atPath: decodedPath, toPath: archivePath)
        }
    }
}