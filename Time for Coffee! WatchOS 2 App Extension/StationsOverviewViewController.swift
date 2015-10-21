//
//  StationsOverviewViewController.swift
//  timeforcoffee
//
//  Created by Christian Stocker on 13.04.15.
//  Copyright (c) 2015 Christian Stocker. All rights reserved.
//

import WatchKit
import Foundation

class StationsOverviewViewController: WKInterfaceController {

    var numberOfRows: Int = 0

    @IBOutlet weak var stationsTable: WKInterfaceTable!

    @IBOutlet weak var infoGroup: WKInterfaceGroup!
    @IBOutlet weak var infoLabel: WKInterfaceLabel!
    var activatedOnce = false
    var appeared = false

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        NSLog("awake StationsOverviewViewController")
        stationsTable.setNumberOfRows(6, withRowType: "stations")
        self.numberOfRows = 6
    }

    override func willActivate() {
        super.willActivate()
        if (!activatedOnce) {
            self.setTitle("Nearby Stations")
            self.addMenuItemWithItemIcon(WKMenuItemIcon.Resume, title: "Reload", action: "contextButtonReload")
            activatedOnce = true
        }
        if (self.appeared) {
            getStations()
        }
    }

    override func didAppear() {
        self.appeared = true
        getStations()
   }

    override func willDisappear() {
        self.appeared = false
    }
    private func contextButtonReload() {
        if let ud =  NSUserDefaults(suiteName: "group.ch.opendata.timeforcoffee") {
            ud.setValue(nil, forKey: "lastFirstStationId")
        }
        getStations()
        TFCDataStore.sharedInstance.requestAllDataFromPhone()
        TFCWatchData.sharedInstance.updateComplicationData()
    }
    private func getStations() {
        func handleReply(stations: TFCStations?) {
            if (stations == nil || stations?.count() == nil) {
                return
            }
            if (self.appeared) {
                WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Click)
            }
            infoGroup.setHidden(true)
            let maxStations = min(5, (stations?.count())! - 1)
            let ctxStations = stations?[0...maxStations]
            if (self.numberOfRows != ctxStations!.count) {
                stationsTable.setNumberOfRows(ctxStations!.count, withRowType: "stations")
                self.numberOfRows = ctxStations!.count
            }
            var i = 0;
            if let ctxStations = ctxStations {
                for (station) in ctxStations {
                    if let sr = stationsTable.rowControllerAtIndex(i) as! StationsRow? {
                        sr.drawCell(station)
                    }
                    i++
                }
                if let stations = stations {
                    TFCWatchData.sharedInstance.updateComplication(stations)
                }
            }

        }
        func errorReply(text: String) {
            infoGroup.setHidden(false)
            infoLabel.setText(text)
        }

        TFCWatchData.sharedInstance.getStations(handleReply, errorReply: errorReply, stopWithFavorites: false)
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let row = table.rowControllerAtIndex(rowIndex) as! StationsRow
        if let station = row.station {
            NSNotificationCenter.defaultCenter().postNotificationName("TFCWatchkitSelectStation", object: nil, userInfo: ["st_id": station.st_id, "name": station.name])
        }
        
    }
}

