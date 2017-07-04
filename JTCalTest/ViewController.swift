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

    let dateOffset = 3

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        select(date: Date())
    }

    var startDate: Date {
        let currentDate = calendarView.visibleDates().monthDates.first?.date ?? Date()
        return currentDate.offset(.month, -dateOffset).startOfMonth
    }

    var endDate: Date {
        let currentDate = calendarView.visibleDates().monthDates.first?.date ?? Date()
        return currentDate.offset(.month, +dateOffset).endOfMonth
    }

    @IBAction func reloadButtonTouchUpInside(_ sender: Any) {
        calendarView.reloadData()
    }

    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {

        return ConfigurationParameters(startDate: startDate, endDate: endDate,
                                       numberOfRows: 6, generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfGrid, firstDayOfWeek: .sunday)
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

        cell.dotMarkerView.isHidden = date.day % 2 == 0

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

    func calendar(_ calendar: JTAppleCalendarView,
                  didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {

        guard let firstVisibleDate = visibleDates.monthDates.first?.date else { return }
        if firstVisibleDate =~ Date.today.startOfMonth {
            self.calendarView.selectDates([Date.today])
        } else {
            self.calendarView.selectDates([firstVisibleDate])
        }
        calendarView.reloadData()
        calendarView.scrollToDate(firstVisibleDate, triggerScrollToDateDelegate: false,
                                  animateScroll: false)
        self.navigationItem.title = firstVisibleDate.shortDateString
    }

    func select(date: Date, animated: Bool = false) {
        self.navigationItem.title = date.shortDateString
        if calendarView.visibleDates().monthDates.first?.date.startOfMonth == date.startOfMonth {
            self.calendarView.selectDates([date], triggerSelectionDelegate: true)
            return
        }
        let firstVisibleDate = calendarView.visibleDates().monthDates.first?.date
        if startDate != firstVisibleDate?.offset(.month, -dateOffset).startOfMonth || endDate != firstVisibleDate?.offset(.month, +dateOffset).endOfMonth {
            calendarView.reloadData()
        }
        calendarView.scrollToDate(date, triggerScrollToDateDelegate: false,
                                  animateScroll: animated, preferredScrollPosition: nil) {
                                    if self.calendarView.selectedDates.first !~ date {
                                        self.calendarView.selectDates([date], triggerSelectionDelegate: true)
                                    }
        }
    }

}

