import UIKit

public enum ZCalendarEventPosition {
    case start
    case middle
    case end
    case single
}

public struct ZCalendarEventDrawInfo {
    let event: ZCalendarEvent
    let slotIndex: Int
    let position: ZCalendarEventPosition
    let isPast: Bool
}

public class ZCalendarCell: UICollectionViewCell {
    public static let identifier = "ZCalendarCell"
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let eventsContainerView = UIView()
    private let overflowLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    // Config
    private let eventHeight: CGFloat = 18.0
    private let eventSpacing: CGFloat = 2.0
    private let headerHeight: CGFloat = 24.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(eventsContainerView)
        contentView.addSubview(overflowLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        dayLabel.frame = CGRect(x: 4, y: 0, width: contentView.bounds.width - 8, height: headerHeight)
        
        let containerTop = headerHeight
        let containerHeight = contentView.bounds.height - containerTop
        eventsContainerView.frame = CGRect(x: 0, y: containerTop, width: contentView.bounds.width, height: containerHeight)
        
        // Overflow label at bottom right
        overflowLabel.frame = CGRect(x: contentView.bounds.width - 24, y: contentView.bounds.height - 16, width: 20, height: 12)
    }
    
    public func configure(date: Date, events: [ZCalendarEventDrawInfo], isCurrentMonth: Bool) {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        dayLabel.text = "\(day)"
        dayLabel.textColor = isCurrentMonth ? .label : .secondaryLabel
        contentView.backgroundColor = isCurrentMonth ? .systemBackground : .secondarySystemBackground
        
        // Clear previous events
        eventsContainerView.subviews.forEach { $0.removeFromSuperview() }
        overflowLabel.text = ""
        overflowLabel.isHidden = true
        
        // Calculate max visible slots
        let availableHeight = eventsContainerView.bounds.height
        let maxSlots = Int(availableHeight / (eventHeight + eventSpacing))
        
        guard maxSlots > 0 else { return }
        
        // Determine if we have overflow
        let maxRequestedSlot = events.map { $0.slotIndex }.max() ?? -1
        let hasOverflow = maxRequestedSlot >= maxSlots
        
        // If overflow, reserve the last slot for the label
        let visibleSlotsLimit = hasOverflow ? maxSlots - 1 : maxSlots
        
        var overflowCount = 0
        
        for info in events {
            if info.slotIndex < visibleSlotsLimit {
                drawEvent(info)
            } else {
                overflowCount += 1
            }
        }
        
        if overflowCount > 0 {
            overflowLabel.text = "+\(overflowCount)"
            overflowLabel.isHidden = false
        }
    }
    
    private func drawEvent(_ info: ZCalendarEventDrawInfo) {
        let y = CGFloat(info.slotIndex) * (eventHeight + eventSpacing)
        var x: CGFloat = 0
        var width: CGFloat = eventsContainerView.bounds.width
        
        // Adjust based on position
        let padding: CGFloat = 2.0
        
        switch info.position {
        case .start:
            x = padding
            width -= padding
        case .end:
            width -= padding
        case .middle:
            x = 0
        case .single:
            x = padding
            width -= (padding * 2)
        }
        
        let eventView = UIView(frame: CGRect(x: x, y: y, width: width, height: eventHeight))
        eventView.backgroundColor = info.event.color.withAlphaComponent(0.3)
        eventView.layer.cornerRadius = 4
        
        // Specific corner masking could be done for continuous look, but simple rounded rect is okay for now.
        // If continuous, we want sharp corners on the connecting side.
        if info.position == .start {
            eventView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else if info.position == .end {
            eventView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        } else if info.position == .middle {
            eventView.layer.cornerRadius = 0
        }
        
        let titleLabel = UILabel(frame: eventView.bounds.insetBy(dx: 4, dy: 0))
        titleLabel.text = info.event.title
        titleLabel.font = .systemFont(ofSize: 10)
        titleLabel.textColor = info.event.color
        eventView.addSubview(titleLabel)
        
        eventsContainerView.addSubview(eventView)
    }
}
