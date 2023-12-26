import UIKit


final class UIBlocking {
    
    private static var window: UIWindow? {
            return UIApplication.shared.windows.first
        }
    
    static func show() {
        window?.isUserInteractionEnabled = false
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
    }
}
