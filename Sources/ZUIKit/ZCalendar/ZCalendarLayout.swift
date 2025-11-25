import UIKit

protocol ZCalendarLayoutDelegate: AnyObject {
    func calendarLayout(_ layout: ZCalendarLayout, heightForDetailViewAt indexPath: IndexPath) -> CGFloat
}

public class ZCalendarLayout: UICollectionViewLayout {
    
    public weak var delegate: ZCalendarLayoutDelegate?
    public var expandedIndexPath: IndexPath?
    
    private let numberOfColumns = 7
    public var rowHeight: CGFloat = 100
    public var headerHeight: CGFloat = 30 // Weekday header
    
    private var layoutAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var detailLayoutAttributes: UICollectionViewLayoutAttributes?
    private var contentSize: CGSize = .zero
    
    public override func prepare() {
        super.prepare()
        
        layoutAttributes.removeAll()
        detailLayoutAttributes = nil
        
        guard let collectionView = collectionView else { return }
        
        let width = collectionView.bounds.width
        let columnWidth = width / CGFloat(numberOfColumns)
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let numberOfRows = Int(ceil(Double(numberOfItems) / Double(numberOfColumns)))
        
        var yOffset: CGFloat = 0
        
        // Check expansion state
        var expandedRow: Int? = nil
        if let expanded = expandedIndexPath {
            expandedRow = expanded.item / numberOfColumns
        }
        
        // Loop through rows
        for row in 0..<numberOfRows {
            // Visibility Logic
            var isVisible = true
            if let targetRow = expandedRow {
                // Show target row and next row
                if row == targetRow || row == targetRow + 1 {
                    isVisible = true
                } else {
                    isVisible = false
                }
            }
            
            if !isVisible {
                continue
            }
            
            // Calculate Frame for Items in this Row
            for col in 0..<numberOfColumns {
                let itemIndex = row * numberOfColumns + col
                if itemIndex >= numberOfItems { break }
                
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                let xOffset = CGFloat(col) * columnWidth
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: columnWidth, height: rowHeight)
                
                layoutAttributes[indexPath] = attributes
            }
            
            yOffset += rowHeight
            
            // Insert Detail View if this is the expanded row
            if let targetRow = expandedRow, row == targetRow {
                let detailHeight = delegate?.calendarLayout(self, heightForDetailViewAt: expandedIndexPath!) ?? 0
                if detailHeight > 0 {
                    let detailIndexPath = IndexPath(item: 0, section: 0) // Dummy index for supplementary
                    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "DetailView", with: detailIndexPath)
                    attributes.frame = CGRect(x: 0, y: yOffset, width: width, height: detailHeight)
                    attributes.zIndex = 10
                    detailLayoutAttributes = attributes
                    
                    yOffset += detailHeight
                }
            }
        }
        
        contentSize = CGSize(width: width, height: yOffset)
    }
    
    public override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleAttributes = layoutAttributes.values.filter { $0.frame.intersects(rect) }
        
        if let detail = detailLayoutAttributes, detail.frame.intersects(rect) {
            visibleAttributes.append(detail)
        }
        
        return visibleAttributes
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath]
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == "DetailView" {
            return detailLayoutAttributes
        }
        return nil
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width
    }
}
