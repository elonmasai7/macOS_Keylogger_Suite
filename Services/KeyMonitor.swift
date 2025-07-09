import Cocoa
import CoreGraphics

class KeyMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let eventLogger = EventLogger()
    
    func startMonitoring() -> Bool {
        // Check accessibility permissions
        guard SystemInfo.isAccessibilityEnabled else {
            SystemInfo.requestAccessibilityPermission()
            return false
        }
        
        // Create event tap
        let eventMask = CGEventMask(
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue)
        )
        
        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: eventCallback,
            userInfo: bridge(obj: self)
        )
        
        guard let tap = eventTap else {
            print("Failed to create event tap")
            return false
        }
        
        // Add to run loop
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        
        return true
    }
    
    func stopMonitoring() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
    }
    
    private func handleEvent(_ event: CGEvent) {
        let timestamp = Date().timeIntervalSince1970
        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        let eventType = event.type
        
        var typeStr = ""
        switch eventType {
        case .keyDown: typeStr = "keyDown"
        case .keyUp: typeStr = "keyUp"
        case .flagsChanged: typeStr = "flagsChanged"
        default: return
        }
        
        eventLogger.logEvent(eventType: typeStr, keyCode: keyCode, timestamp: timestamp)
    }
    
    private let eventCallback: CGEventTapCallBack = { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
        guard let refcon = refcon else { return Unmanaged.passRetained(event) }
        let monitor = Unmanaged<KeyMonitor>.fromOpaque(refcon).takeUnretainedValue()
        
        // Process the event
        monitor.handleEvent(event)
        
        // Pass event along
        return Unmanaged.passRetained(event)
    }
    
    // Helper to bridge self to void pointer
    private func bridge<T: AnyObject>(obj: T) -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(obj).toOpaque()
    }
}