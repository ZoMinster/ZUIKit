import Foundation
import UIKit

public struct ZCalendarEvent {
    public let id: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let color: UIColor
    
    public init(id: String = UUID().uuidString, title: String, startDate: Date, endDate: Date, color: UIColor = .blue) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
    }
}
