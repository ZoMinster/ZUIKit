import UIKit

public class ZCalendarDetailView: UICollectionReusableView {
    public static let identifier = "ZCalendarDetailView"
    
    private let label = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        
        label.textAlignment = .center
        label.numberOfLines = 0
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    public func configure(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        label.text = "Expanded View for\n" + formatter.string(from: date)
    }
}
