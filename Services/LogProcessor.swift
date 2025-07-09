import Foundation

class LogProcessor {
    private let keyMapper = KeyMapper()
    
    func processLog(inputPath: URL, outputPath: URL) -> Bool {
        guard let input = try? String(contentsOf: inputPath) else {
            print("Error reading input file")
            return false
        }
        
        let lines = input.components(separatedBy: "\n")
        var output = ""
        var lastKeyDown: (time: TimeInterval, key: String)? = nil
        var currentModifiers: [String] = []
        
        for line in lines {
            guard !line.isEmpty else { continue }
            
            let components = line.components(separatedBy: ",")
            guard components.count >= 3,
                  let timestamp = TimeInterval(components[0]),
                  let eventType = components[1] as String?,
                  let keyCode = Int(components[2]) else { continue }
            
            if let keyChar = keyMapper.mapKey(code: keyCode, eventType: eventType) {
                switch eventType {
                case "keyDown":
                    // Handle key repeats
                    if let last = lastKeyDown, timestamp - last.time < 0.1, last.key == keyChar {
                        output += keyChar
                    } else {
                        output += keyChar
                    }
                    lastKeyDown = (timestamp, keyChar)
                    
                case "keyUp":
                    lastKeyDown = nil
                    
                case "flagsChanged":
                    if keyMapper.isModifier(code: keyCode) {
                        if currentModifiers.contains(keyChar) {
                            currentModifiers.removeAll { $0 == keyChar }
                        } else {
                            currentModifiers.append(keyChar)
                        }
                        output += "[\(currentModifiers.joined())]"
                    }
                    
                default:
                    break
                }
            }
        }
        
        do {
            try output.write(to: outputPath, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Error writing output: \(error)")
            return false
        }
    }
}