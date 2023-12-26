import Foundation


final class MyFormatter: DateFormatter {
    
    override init() {
        super.init()
        dateFormat = "yyyy-MM-dd"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

