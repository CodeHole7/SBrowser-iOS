//
//  SBStorageFirstVC.swift
//  SBrowser
//
//  Created by Jin Xu on 27/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit
import Eureka

class SBStorageFirstVC: SBFixedFormVC {

    /**
    We need a day beginning at 00:00 of the current day with the user's timezone.

    Otherwise, we will see timezone-corrected time intervals or current time.
    */
    private lazy var reference: Date? = {
        return Calendar.current.date(from:
            Calendar.current.dateComponents(Set([.timeZone, .year, .month, .day]), from: Date()))
    }()

    private lazy var intervalRow = LabelRow() {
        $0.title = NSLocalizedString("Auto-Sweep Interval", comment: "Option title")
        $0.cell.textLabel?.numberOfLines = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Cookies and Local Storage", comment: "Scene title")

        form
        +++ LabelRow() {
            $0.title = NSLocalizedString("Cookies and Local Storage", comment: "Option title")
            $0.cell.textLabel?.numberOfLines = 0
            $0.cell.accessoryType = .disclosureIndicator
            $0.cell.selectionStyle = .default
        }
        .onCellSelection { _, _ in
            self.navigationController?.pushViewController(
                StorageSecondVC(), animated: true)
        }

        +++ Section(footer: NSLocalizedString(
            "Cookies and local storage data from non-whitelisted hosts will be cleared even from open tabs after not being accessed for this many minutes.",
            comment: "Option description"))

        <<< intervalRow

        <<< CountDownPickerRow() {
            if let reference = reference {
                let date = Date(timeInterval: SettingsSBrowser.cookieAutoSweepInterval, since: reference)
                $0.value = date

                updateIntervalRow(date)
            }
        }
        .onChange { row in
            if let value = row.value, let reference = self.reference {
                SettingsSBrowser.cookieAutoSweepInterval = value.timeIntervalSinceReferenceDate - reference.timeIntervalSinceReferenceDate

                self.updateIntervalRow(value)
            }
        }
    }

    private func updateIntervalRow(_ date: Date) {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)

        self.intervalRow.value = DateComponentsFormatter.localizedString(
            from: dateComponents, unitsStyle: .abbreviated)?.replacingOccurrences(of: ",", with: "")

        self.intervalRow.updateCell()
    }
}
