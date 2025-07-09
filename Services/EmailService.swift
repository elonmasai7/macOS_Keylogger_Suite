import Foundation

class EmailService {
    func sendReport(email: String, subject: String, body: String, attachmentPath: URL) -> Bool {
        let script = """
        tell application "Mail"
            set newMessage to make new outgoing message with properties {
                subject: "\(subject)",
                content: "\(body)"
            }
            
            tell newMessage
                make new to recipient at end of to recipients with properties {
                    address: "\(email)"
                }
                
                tell content
                    make new attachment with properties {
                        file name: (POSIX file "\(attachmentPath.path)")
                    } at after last paragraph
                end tell
                
                set visible to false
                send
            end tell
        end tell
        """
        
        let process = Process()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = ["-e", script]
        
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            print("Error sending email: \(error)")
            return false
        }
    }
}