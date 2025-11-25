import UIKit

public class ZCalendarViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private let layout = ZCalendarLayout()
    
    private var currentDate = Date()
    private var calendar = Calendar.current
    private var days = [Date]()
    private var events = [ZCalendarEvent]()
    
    // Cache for cell display: Map Day Index -> List of DrawInfos
    private var dayDrawInfos = [Int: [ZCalendarEventDrawInfo]]()
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Calendar"
        
        setupCollectionView()
        setupNavigation()
        
        // Initial Data
        generateDays()
        generateDemoEvents()
        calculateEventLayout()
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        layout.delegate = self
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.register(ZCalendarCell.self, forCellWithReuseIdentifier: ZCalendarCell.identifier)
        collectionView.register(ZCalendarDetailView.self, forSupplementaryViewOfKind: "DetailView", withReuseIdentifier: ZCalendarDetailView.identifier)
        
        view.addSubview(collectionView)
        
        // Add weekday header view above if needed, but for simplicity we rely on cells or simple stack
        // Let's add a simple stack view for Mon-Sun labels at the top
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 30) // Just placeholder frame
        
        let symbols = calendar.shortWeekdaySymbols
        for symbol in symbols {
            let label = UILabel()
            label.text = symbol
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 14)
            stack.addArrangedSubview(label)
        }
        
        // Adjust collectionView frame to accommodate header
        // For this demo, we'll just put it in the view controller view
        // But better to use AutoLayout. I'll skip AutoLayout for speed and use frames in viewDidLayoutSubviews if strictly needed,
        // but let's use constraints for the header and CV.
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.heightAnchor.constraint(equalToConstant: 30),
            
            collectionView.topAnchor.constraint(equalTo: stack.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(handleToday))
    }
    
    @objc private func handleToday() {
        currentDate = Date()
        generateDays()
        calculateEventLayout()
        layout.expandedIndexPath = nil
        collectionView.reloadData()
    }
    
    // MARK: - Data Generation
    private func generateDays() {
        days.removeAll()
        
        // Find start of month
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let startOfMonth = calendar.date(from: components) else { return }
        
        // Find start of week (Sunday)
        // Adjust grid to start on Sunday
        var startOfWeek = startOfMonth
        let weekday = calendar.component(.weekday, from: startOfMonth)
        // weekday: 1=Sun, 2=Mon...
        // Subtract (weekday - 1) days
        startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: startOfMonth)!
        
        // Generate 42 days (6 rows * 7 cols)
        for i in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(date)
            }
        }
    }
    
    private func generateDemoEvents() {
        events.removeAll()
        // Create some events around today
        let today = Date()
        
        // Event 1: Today, spanning 3 days
        events.append(ZCalendarEvent(title: "Project Kickoff", startDate: today, endDate: calendar.date(byAdding: .day, value: 2, to: today)!, color: .systemBlue))
        
        // Event 2: Yesterday, single day
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
            events.append(ZCalendarEvent(title: "Meeting", startDate: yesterday, endDate: yesterday, color: .systemRed))
        }
        
        // Event 3: Overlapping with Event 1
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
            events.append(ZCalendarEvent(title: "Code Review", startDate: tomorrow, endDate: calendar.date(byAdding: .day, value: 2, to: today)!, color: .systemGreen))
        }
        
        // Event 4: Spanning 2 weeks
        if let nextWeek = calendar.date(byAdding: .day, value: 5, to: today) {
             events.append(ZCalendarEvent(title: "Vacation", startDate: nextWeek, endDate: calendar.date(byAdding: .day, value: 10, to: today)!, color: .systemOrange))
        }
        
        // Event 5: Many small events on one day to test overflow
        if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) {
            for i in 1...6 {
                events.append(ZCalendarEvent(title: "Task \(i)", startDate: twoDaysAgo, endDate: twoDaysAgo, color: .systemPurple))
            }
        }
    }
    
    // MARK: - Layout Calculation
    private func calculateEventLayout() {
        dayDrawInfos.removeAll()
        
        // Process week by week
        for weekIndex in 0..<6 {
            let weekStartIndex = weekIndex * 7
            let weekEndIndex = weekStartIndex + 7
            guard weekEndIndex <= days.count else { break }
            
            let weekDays = Array(days[weekStartIndex..<weekEndIndex])
            let weekStart = weekDays.first!
            // End of week is end of last day
            let weekEnd = calendar.date(byAdding: .day, value: 1, to: weekDays.last!)!.addingTimeInterval(-1)
            
            // Find intersecting events
            let weekEvents = events.filter { event in
                return event.startDate <= weekEnd && event.endDate >= weekStart
            }
            
            // Sort events: Start Asc, Length Desc
            let sortedEvents = weekEvents.sorted { (e1, e2) -> Bool in
                if calendar.isDate(e1.startDate, inSameDayAs: e2.startDate) {
                    return e1.endDate.timeIntervalSince(e1.startDate) > e2.endDate.timeIntervalSince(e2.startDate)
                }
                return e1.startDate < e2.startDate
            }
            
            // Assign slots
            // Slot availability for the 7 days of the week
            // slots[dayIndex] = [Occupied(Bool)]
            // We want to find the first Row Index K where the event fits for all its days in this week.
            
            // Map: SlotIndex -> [DayIndex where occupied]
            // We'll use a simple 2D grid for the week: grid[slot][day] = Bool
            var grid = [[Bool]]() // Start empty, grow as needed
            
            for event in sortedEvents {
                // Determine intersection range in terms of day indices (0..6)
                let startDayIndex = max(0, calendar.dateComponents([.day], from: weekStart, to: event.startDate).day ?? 0)
                // Note: dateComponents returns difference. If event starts before week, diff is negative.
                // Re-calc:
                let distStart = calendar.dateComponents([.day], from: weekStart, to: calendar.startOfDay(for: event.startDate)).day!
                let distEnd = calendar.dateComponents([.day], from: weekStart, to: calendar.startOfDay(for: event.endDate)).day!
                
                let s = max(0, distStart)
                let e = min(6, distEnd)
                
                guard s <= e else { continue }
                
                // Find a slot
                var assignedSlot = 0
                var found = false
                
                while !found {
                    // Check if assignedSlot exists in grid, if not add it
                    while grid.count <= assignedSlot {
                        grid.append(Array(repeating: false, count: 7))
                    }
                    
                    // Check if space is free
                    var isFree = true
                    for d in s...e {
                        if grid[assignedSlot][d] {
                            isFree = false
                            break
                        }
                    }
                    
                    if isFree {
                        // Occupy
                        for d in s...e {
                            grid[assignedSlot][d] = true
                        }
                        found = true
                    } else {
                        assignedSlot += 1
                    }
                }
                
                // Save DrawInfo for each day
                for d in s...e {
                    let dayDate = weekDays[d]
                    let globalIndex = weekStartIndex + d
                    
                    // Determine position
                    var pos: ZCalendarEventPosition = .middle
                    let isStart = calendar.isDate(dayDate, inSameDayAs: event.startDate)
                    let isEnd = calendar.isDate(dayDate, inSameDayAs: event.endDate)
                    
                    if isStart && isEnd {
                        pos = .single
                    } else if isStart {
                        pos = .start
                    } else if isEnd {
                        pos = .end
                    } else {
                        pos = .middle
                    }
                    
                    let info = ZCalendarEventDrawInfo(event: event, slotIndex: assignedSlot, position: pos, isPast: dayDate < Date())
                    
                    if dayDrawInfos[globalIndex] == nil {
                        dayDrawInfos[globalIndex] = []
                    }
                    dayDrawInfos[globalIndex]?.append(info)
                }
            }
        }
    }
}

// MARK: - DataSource & Delegate
extension ZCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate, ZCalendarLayoutDelegate {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZCalendarCell.identifier, for: indexPath) as! ZCalendarCell
        
        let date = days[indexPath.item]
        let events = dayDrawInfos[indexPath.item] ?? []
        
        // Determine if current month
        let isCurrentMonth = calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
        
        cell.configure(date: date, events: events, isCurrentMonth: isCurrentMonth)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "DetailView" {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ZCalendarDetailView.identifier, for: indexPath) as! ZCalendarDetailView
            if let expanded = layout.expandedIndexPath {
                view.configure(date: days[expanded.item])
            }
            return view
        }
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Toggle expansion
        if layout.expandedIndexPath == indexPath {
            layout.expandedIndexPath = nil
        } else {
            layout.expandedIndexPath = indexPath
        }
        
        // Animate
        collectionView.performBatchUpdates({
            // Just invalidating layout inside batch updates triggers animation
             // layout.invalidateLayout() // Not strictly needed if we just set property and ask for invalidation context, but simpler here
        }, completion: nil)
        
        // Scroll to make it visible
        if layout.expandedIndexPath != nil {
             collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }
    }
    
    // Layout Delegate
    func calendarLayout(_ layout: ZCalendarLayout, heightForDetailViewAt indexPath: IndexPath) -> CGFloat {
        return 200 // Fixed height for detail view
    }
}
