import Foundation

class KeyMapper {
    private let keyMap: [Int: String] = [
        // Standard keys
        0: "a", 1: "s", 2: "d", 3: "f", 4: "h", 5: "g", 6: "z", 7: "x",
        8: "c", 9: "v", 11: "b", 12: "q", 13: "w", 14: "e", 15: "r",
        16: "y", 17: "t", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
        23: "5", 25: "9", 26: "7", 28: "8", 29: "0", 30: "]", 31: "o",
        32: "u", 33: "[", 34: "i", 35: "p", 37: "l", 38: "j", 39: "'",
        40: "k", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "n", 46: "m",
        47: ".", 50: "`", 51: "⌫",  // Backspace
        
        // Modifier keys
        55: "⌘", 56: "⇧", 57: "⇪", 58: "⌥", 59: "⌃", 60: "⇧", 61: "⌃", 63: "fn",
        
        // Special keys
        53: "⎋",  // Escape
        76: "⌅",  // Enter
        96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8", 101: "F9",
        103: "F11", 105: "F13", 107: "F14", 109: "F10", 111: "F12",
        113: "F15", 114: "⎙", 115: "↖", 116: "⇞", 117: "⌦", 118: "F4",
        119: "↘", 120: "F2", 121: "⇟", 122: "↩", 123: "←", 124: "→",
        125: "↓", 126: "↑", 144: "F16"
    ]
    
    func mapKey(code: Int, eventType: String) -> String? {
        // Handle special cases
        if eventType == "flagsChanged" && isModifier(code: code) {
            return keyMap[code]
        }
        
        // Skip modifier key events that aren't flagsChanged
        if isModifier(code: code) && eventType != "flagsChanged" {
            return nil
        }
        
        return keyMap[code]
    }
    
    func isModifier(code: Int) -> Bool {
        let modifierCodes = [55, 56, 57, 58, 59, 60, 61, 63]
        return modifierCodes.contains(code)
    }
}