//
//  ViewController.swift
//  JTCalTest
//
//  Created by Daniel Marques on 24/06/17.
//  Copyright © 2017 dbmrq. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController, JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    @IBOutlet weak var offsetStepper: UIStepper!
    @IBOutlet weak var slownessStepper: UIStepper!
    @IBOutlet weak var offsetLabel: UILabel!
    @IBOutlet weak var slownessLabel: UILabel!

    var slowness = 1
    var dateOffset = 2
    var startDate: Date?
    var endDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        offsetStepper.minimumValue = 1
        offsetStepper.maximumValue = 10
        slownessStepper.minimumValue = 1
        slownessStepper.maximumValue = 10
        setStartAndEndDates(for: Date())
        updateLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        select(date: Date())
    }

    func updateLabels() {
        offsetLabel.text = "Offset: \(dateOffset)"
        slownessLabel.text = "Slowness: \(slowness)"
    }

    func setStartAndEndDates(for date: Date = Date.today) {
        startDate = date.offset(.month, -dateOffset).startOfMonth
        endDate = date.offset(.month, dateOffset).endOfMonth
    }

    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {

        return ConfigurationParameters(
            startDate: startDate ?? Date().offset(.month, -dateOffset).startOfMonth,
            endDate: endDate ?? Date().offset(.month, dateOffset).endOfMonth,
            numberOfRows: 6, generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid, firstDayOfWeek: .sunday
        )
    }

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date,
                  cellState: CellState, indexPath: IndexPath) -> JTAppleCell {

        guard let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "cell", for: indexPath) as? CellView else { return CellView() }

        if cellState.dateBelongsTo != .thisMonth {
            cell.isHidden = true
            return cell
        } else {
            cell.isHidden = false
            configureCell(cell, date: date, cellState: cellState)
        }

        return cell
        
    }

    func configureCell(_ cell: CellView, date: Date, cellState: CellState) {

        cell.dayLabel.text = cellState.text

        cell.selectedView.isHidden = !cellState.isSelected
        cell.selectedView.round()

        cell.dotMarkerView.isHidden = slowFunction(slowness, returns: date.day % 2 == 0)

        if cellState.isSelected {
            cell.dayLabel.textColor = UIColor.white
            cell.dotMarkerView.circleColor = UIColor.white
            if date =~ Date() {
                cell.selectedView.backgroundColor = cell.selectedView.tintColor
                cell.dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19,
                                                                      weight: UIFontWeightMedium)
            } else {
                cell.selectedView.backgroundColor = UIColor.black
                cell.dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19,
                                                                      weight: UIFontWeightRegular)
            }
            cell.dotMarkerView.backgroundColor = cell.selectedView.backgroundColor
        } else {
            if date =~ Date() {
                cell.dayLabel.textColor = cell.dayLabel.tintColor
                cell.dotMarkerView.circleColor = cell.dayLabel.tintColor
                cell.dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19,
                                                                      weight: UIFontWeightRegular)
            } else {
                cell.dayLabel.textColor = UIColor.black
                cell.dotMarkerView.circleColor = UIColor.black
                cell.dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19,
                                                                      weight: UIFontWeightLight)
            }
            cell.dotMarkerView.backgroundColor = UIColor.white
        }
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState) {

        guard let cell = cell as? CellView else { return }
        configureCell(cell, date: date, cellState: cellState)

        if cellState.isSelected { cell.select() }
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {

        guard let cell = cell as? CellView else { return }
        configureCell(cell, date: date, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {

        guard let firstVisibleDate = visibleDates.monthDates.first?.date else { return }
        // With previous versions the date had to be selected here, before calling
        // celandarView.reloadData(). With the latest version this seems to be fixed and I can
        // call selectDates down there:
        if firstVisibleDate.month == startDate?.month || firstVisibleDate.month == endDate?.month {
            setStartAndEndDates(for: firstVisibleDate)
            calendarView.reloadData()
            calendarView.scrollToDate(firstVisibleDate, triggerScrollToDateDelegate: false,
                                      animateScroll: false) {
                self.calendarView.selectDates([firstVisibleDate]) // <--- Here
            }
        } else {
            self.calendarView.selectDates([firstVisibleDate]) // <--- And here
        }
        self.navigationItem.title = firstVisibleDate.shortDateString
    }

    func select(date: Date, animated: Bool = false) {
        self.navigationItem.title = date.shortDateString
        if calendarView.visibleDates().monthDates.first?.date.startOfMonth == date.startOfMonth {
            self.calendarView.selectDates([date], triggerSelectionDelegate: true)
            return
        }
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
        }
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

    @IBAction func offsetChanged(_ sender: Any) {
        dateOffset = Int(offsetStepper.value)
        updateLabels()
    }

    @IBAction func slownessChanged(_ sender: Any) {
        slowness = Int(slownessStepper.value)
        updateLabels()
    }

}

