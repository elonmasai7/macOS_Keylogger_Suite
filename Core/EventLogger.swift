import Foundation

class EventLogger {
    private var logFileHandle: FileHandle?
    
    init() {
        let logPath = AppFileManager.shared.logFilePath().path
        
        // Create log file if needed
        if !FileManager.default.fileExists(atPath: logPath) {
            FileManager.default.createFile(atPath: logPath, contents: nil)
        }
        
        // Open log file for writing
        logFileHandle = try? FileHandle(forWritingTo: AppFileManager.shared.logFilePath())
        logFileHandle?.seekToEndOfFile()
    }
    
    deinit {
        logFileHandle?.closeFile()
    }
    
    func logEvent(eventType: String, keyCode: Int, timestamp: TimeInterval) {
        let logLine = "\(timestamp),\(eventType),\(keyCode)\n"
        
        if let data = logLine.data(using: .utf8) {
            logFileHandle?.write(data)
        }
    }
}