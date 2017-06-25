//
//  ViewController.swift
//  JTCalTest
//
//  Created by Daniel Marques on 24/06/17.
//  Copyright © 2017 dbmrq. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {

    @IBOutlet weak var calendarContainerConstraint: NSLayoutConstraint!

    @IBOutlet weak var calendarView: JTAppleCalendarView!

    var tableViewController: TableViewController!

    var slowness = 1
    var dateOffset = 1
    var startDate: Date?
    var endDate: Date?

    var lastDateSelected: Date?

    var scrolled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        self.navigationItem.title = Date().shortDateString
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendarView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.select(date: self.lastDateSelected ?? Date())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !scrolled {
            setStartAndEndDates()
            let today = Date()
            self.calendarView.scrollToDate(
                today,
                triggerScrollToDateDelegate: false,
                animateScroll: false,
                preferredScrollPosition: nil
            )
            self.resizeConstraint(today)
            scrolled = true
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
            self.resizeConstraint(self.lastDateSelected ?? Date())
            self.calendarView.reloadData()
            self.select(date: self.lastDateSelected ?? Date(), animated: false)
        }
    }

    func setStartAndEndDates(for date: Date = Date.today) {
        startDate = date.offset(.month, -dateOffset).startOfMonth
        endDate = date.offset(.month, dateOffset).endOfMonth
    }

    func select(date: Date, animated: Bool = false) {
        if calendarView.visibleDates().monthDates.first?.date.startOfMonth == date.startOfMonth {
            self.calendarView.selectDates([date], triggerSelectionDelegate: true)
        } else {
            let oldStartDate = startDate
            let oldEndDate = endDate
            setStartAndEndDates(for: date)
            if startDate != oldStartDate || endDate != oldEndDate {
                calendarView.reloadData()
            }
            calendarView.scrollToDate(date, triggerScrollToDateDelegate: false,
                                      animateScroll: animated, preferredScrollPosition: nil) {
                if self.calendarView.selectedDates.first !~ date {
                    self.calendarView.selectDates([date], triggerSelectionDelegate: true)
                }
                self.resizeConstraint(date)
            }
        }
        self.navigationItem.title = date.shortDateString
    }

    @IBAction func todayBarButtonDidPress(_ sender: AnyObject) {
        select(date: Date.today, animated: true)
    }

    func slowFunction(_ slowness: Int = 10, returns: Bool) -> Bool {
        var array: [Int] = []
        var arrayArray: [[Int]] = []
        for i in 0...Int(pow(Double(slowness), 6)) {
            array.append(i)
        }
        for _ in 0...Int(pow(Double(slowness), 6)) {
            let anotherArray = array
            arrayArray.append(anotherArray)
        }
        return returns
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableViewController = segue.destination as? TableViewController {
            self.tableViewController = tableViewController
            tableViewController.calendarViewController = self
        }
    }

}

extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {

        return ConfigurationParameters(
            startDate: startDate ?? Date.today.offset(.month, -dateOffset).startOfMonth,
            endDate: endDate ?? Date.today.offset(.month, dateOffset).endOfMonth,
            numberOfRows: 6, generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid, firstDayOfWeek: .sunday
        )
    }

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date,
                  cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "cell", for: indexPath) as? CellView else { return CellView() }

        configureCell(cell, date: date, cellState: cellState)

        return cell

    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState) {

        lastDateSelected = date

        guard let cell = cell as? CellView else { return }
        configureCell(cell, date: date, cellState: cellState)

        if cellState.isSelected {
            cell.select()
        }
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let cell = cell as? CellView {
            configureCell(cell, date: date, cellState: cellState)
        }
    }

    func configureCell(_ cell: CellView, date: Date, cellState: CellState) {
        if cellState.dateBelongsTo != .thisMonth {
            cell.isHidden = true
            return
        } else {
            cell.isHidden = false
        }

        cell.dayLabel.text = cellState.text

        cell.selectedView.alpha = 1
        cell.selectedView.isHidden = !cellState.isSelected
        cell.layoutIfNeeded()
        cell.selectedView.layer.cornerRadius = cell.selectedView.frame.width / 2

        cell.dotMarkerView.isHidden = slowFunction(slowness, returns: date.day % 2 == 0)

        if !cell.selectedView.isHidden {
            cell.dayLabel.textColor = UIColor.white
            cell.dotMarkerView.circleColor = UIColor.white
            cell.dotMarkerView.backgroundColor = cell.selectedView.backgroundColor
            if date =~ Date() {
                cell.dayLabel.font =
                    UIFont.monospacedDigitSystemFont(ofSize: 19, weight: UIFontWeightMedium)
                cell.selectedView.backgroundColor = cell.selectedView.tintColor
            } else {
                cell.dayLabel.font =
                    UIFont.monospacedDigitSystemFont(ofSize: 19, weight: UIFontWeightRegular)
                cell.selectedView.backgroundColor = UIColor.black
            }
        } else if cellState.dateBelongsTo == .thisMonth {
            cell.dotMarkerView.circleColor = UIColor.black
            cell.dotMarkerView.backgroundColor = UIColor.white
            if date =~ Date() {
                cell.dayLabel.textColor = cell.dayLabel.tintColor
                cell.dotMarkerView.circleColor = cell.dayLabel.tintColor
                cell.dayLabel.font =
                    UIFont.monospacedDigitSystemFont(ofSize: 19, weight: UIFontWeightRegular)
            } else {
                cell.dayLabel.textColor = UIColor.black
                cell.dayLabel.font =
                    UIFont.monospacedDigitSystemFont(ofSize: 19, weight: UIFontWeightLight)
            }
        }
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let firstVisibleDate = visibleDates.monthDates.first?.date else { return }
        if firstVisibleDate.month == startDate?.month || firstVisibleDate.month == endDate?.month {
            setStartAndEndDates(for: firstVisibleDate)
            calendarView.reloadData()
            calendarView.scrollToDate(firstVisibleDate, triggerScrollToDateDelegate: false,
                                      animateScroll: false)
        }
        if firstVisibleDate =~ Date.today.startOfMonth {
            self.calendarView.selectDates([Date.today])
        } else {
            self.calendarView.selectDates([firstVisibleDate])
        }
        self.resizeConstraint(firstVisibleDate, animated: true)
        self.navigationItem.title = firstVisibleDate.shortDateString
    }

    func numberOfRows(forDate date: Date) -> Int {
        let weekday = date.startOfMonth.weekday
        let monthDays = date.nextMonth.yesterday.day

        if weekday == 1 && monthDays == 28 {
            return 4
        } else if weekday < 6 ||
            (weekday == 6 && monthDays < 31) ||
            (weekday == 7 && monthDays < 30) {
            return 5
        } else {
            return 6
        }
    }

    func resizeConstraint(_ date: Date, animated: Bool = false) {
        self.view.layoutIfNeeded()
        let constraint = calendarContainerConstraint.constant
        setConstraint(date)
        if calendarContainerConstraint.constant != constraint {
            let duration = animated ? 0.2 : 0.0
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    func setConstraint(_ date: Date) {
        if numberOfRows(forDate: date) == 6 {
            self.calendarContainerConstraint.constant = 10
        } else if numberOfRows(forDate: date) == 4 {
            self.calendarContainerConstraint.constant = 10
            self.calendarContainerConstraint.constant -= 2 * (self.calendarView.frame.height / 6)
        } else {
            self.calendarContainerConstraint.constant = 10
            self.calendarContainerConstraint.constant -= self.calendarView.frame.height / 6
        }
    }
    
}

extension UICollectionViewFlowLayout {
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}



//, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
//
//    @IBOutlet weak var calendarView: JTAppleCalendarView!
//
//    @IBOutlet weak var offsetStepper: UIStepper!
//    @IBOutlet weak var slownessStepper: UIStepper!
//    @IBOutlet weak var offsetLabel: UILabel!
//    @IBOutlet weak var slownessLabel: UILabel!
//
//    var slowness = 1
//    var dateOffset = 2
//    var startDate: Date?
//    var endDate: Date?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        calendarView.minimumLineSpacing = 0
//        calendarView.minimumInteritemSpacing = 0
//        offsetStepper.minimumValue = 1
//        offsetStepper.maximumValue = 10
//        slownessStepper.minimumValue = 1
//        slownessStepper.maximumValue = 10
//        setStartAndEndDates(for: Date())
//        updateLabels()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        select(date: Date())
//    }
//
//    func updateLabels() {
//        offsetLabel.text = "Offset: \(dateOffset)"
//        slownessLabel.text = "Slowness: \(slowness)"
//    }
//
//    func setStartAndEndDates(for date: Date = Date.today) {
//        startDate = date.offset(.month, -dateOffset).startOfMonth
//        endDate = date.offset(.month, dateOffset).endOfMonth
//    }
//
//    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
//
//        return ConfigurationParameters(
//            startDate: startDate ?? Date().offset(.month, -dateOffset).startOfMonth,
//            endDate: endDate ?? Date().offset(.month, dateOffset).endOfMonth,
//            numberOfRows: 6, generateInDates: .forAllMonths,
//            generateOutDates: .tillEndOfGrid, firstDayOfWeek: .sunday
//        )
//    }
//
//    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date,
//                  cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
//
//        guard let cell = calendar.dequeueReusableJTAppleCell(
//            withReuseIdentifier: "cell", for: indexPath) as? CellView else { return CellView() }
//
//        if cellState.dateBelongsTo != .thisMonth {
//            cell.isHidden = true
//            return cell
//        } else {
//            cell.isHidden = false
//            configureCell(cell, date: date, cellState: cellState)
//        }
//
//        return cell
//        
//    }
//
//    func configureCell(_ cell: CellView, date: Date, cellState: CellState) {
//
//        cell.dayLabel.text = cellState.text
//
//        cell.selectedView.isHidden = !cellState.isSelected
//        cell.selectedView.round()
//
//        cell.dotMarkerView.isHidden = slowFunction(slowness, returns: date.day % 2 == 0)
//
//        if cellState.isSelected {
//            cell.dayLabel.textColor = UIColor.white
//            cell.dotMarkerView.circleColor = UIColor.white
//            if date =~ Date() {
//                cell.selectedView.backgroundColor = cell.selectedView.tintColor
//                cell.dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19,
//                                                                      weight: UIFontWeightMedium)
//            } else {
//                cell.selectedView.backgroundColor = UIColor.black
//                cell.dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19,
//                                                                      weight: UIFontWeightRegular)
//            }
//            cell.dotMarkerView.backgroundColor = cell.selectedView.backgroundColor
//        } else {
//            if date =~ Date() {
//                cell.dayLabel.textColor = cell.dayLabel.tintColor
//                cell.dotMarkerView.circleColor = cell.dayLabel.tintColor
//                cell.dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19,
//                                                                      weight: UIFontWeightRegular)
//            } else {
//                cell.dayLabel.textColor = UIColor.black
//                cell.dotMarkerView.circleColor = UIColor.black
//                cell.dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19,
//                                                                      weight: UIFontWeightLight)
//            }
//            cell.dotMarkerView.backgroundColor = UIColor.white
//        }
//    }
//
//    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date,
//                  cell: JTAppleCell?, cellState: CellState) {
//
//        guard let cell = cell as? CellView else { return }
//        configureCell(cell, date: date, cellState: cellState)
//
//        if cellState.isSelected { cell.select() }
//    }
//
//    func calendar(_ calendar: JTAppleCalendarView,
//                  didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//
//        guard let cell = cell as? CellView else { return }
//        configureCell(cell, date: date, cellState: cellState)
//    }
//
//    func calendar(_ calendar: JTAppleCalendarView,
//                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
//
//        guard let firstVisibleDate = visibleDates.monthDates.first?.date else { return }
//        // With previous versions the date had to be selected here, before calling
//        // celandarView.reloadData(). With the latest version this seems to be fixed and I can
//        // call selectDates down there:
//        if firstVisibleDate.month == startDate?.month || firstVisibleDate.month == endDate?.month {
//            setStartAndEndDates(for: firstVisibleDate)
//            calendarView.reloadData()
//            calendarView.scrollToDate(firstVisibleDate, triggerScrollToDateDelegate: false,
//                                      animateScroll: false) {
//                self.calendarView.selectDates([firstVisibleDate]) // <--- Here
//            }
//        } else {
//            self.calendarView.selectDates([firstVisibleDate]) // <--- And here
//        }
//        self.navigationItem.title = firstVisibleDate.shortDateString
//    }
//
//    func select(date: Date, animated: Bool = false) {
//        self.navigationItem.title = date.shortDateString
//        if calendarView.visibleDates().monthDates.first?.date.startOfMonth == date.startOfMonth {
//            self.calendarView.selectDates([date], triggerSelectionDelegate: true)
//            return
//        }
//        let oldStartDate = startDate
//        let oldEndDate = endDate
//        setStartAndEndDates(for: date)
//        if startDate != oldStartDate || endDate != oldEndDate {
//            calendarView.reloadData()
//        }
//        calendarView.scrollToDate(date, triggerScrollToDateDelegate: false,
//                                  animateScroll: animated, preferredScrollPosition: nil) {
//            if self.calendarView.selectedDates.first !~ date {
//                self.calendarView.selectDates([date], triggerSelectionDelegate: true)
//            }
//        }
//    }
//
//    func slowFunction(_ slowness: Int = 10, returns: Bool) -> Bool {
//        var array: [Int] = []
//        var arrayArray: [[Int]] = []
//        for i in 0...Int(pow(Double(slowness), 6)) {
//            array.append(i)
//        }
//        for _ in 0...Int(pow(Double(slowness), 6)) {
//            let anotherArray = array
//            arrayArray.append(anotherArray)
//        }
//        return returns
//    }
//
//    @IBAction func offsetChanged(_ sender: Any) {
//        dateOffset = Int(offsetStepper.value)
//        updateLabels()
//    }
//
//    @IBAction func slownessChanged(_ sender: Any) {
//        slowness = Int(slownessStepper.value)
//        updateLabels()
//    }
//
//}
//
