//
//  GlanceController.swift
//  Time for Coffee! WatchKit Extension
//
//  Created by Christian Stocker on 02.03.15.
//  Copyright (c) 2015 Christian Stocker. All rights reserved.
//

import WatchKit
import Foundation
import timeforcoffeeWatchKit


class GlanceController: WKInterfaceController {

    @IBOutlet weak var minutesLabel: WKInterfaceLabel!
    @IBOutlet weak var destinationLabel: WKInterfaceLabel!
    @IBOutlet weak var numberGroup: WKInterfaceGroup!
    @IBOutlet weak var departureLabel: WKInterfaceLabel!
    @IBOutlet weak var numberLabel: WKInterfaceLabel!
    @IBOutlet weak var stationLabel: WKInterfaceLabel!

    @IBOutlet weak var stationsTable: WKInterfaceTable!

    @IBOutlet weak var infoGroup: WKInterfaceGroup!
    @IBOutlet weak var infoLabel: WKInterfaceLabel!


    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        // Configure interface objects here.
        print("are we here??")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user

        super.willActivate()
        func handleReply(stations: TFCStations?) {
            infoGroup.setHidden(true)
            for (station) in stations! {
                station.updateDepartures(nil)
                let departures = station.getFilteredDepartures()
                if(departures?.count > 0) {
                    var i = 0
                    stationLabel.setText(station.getName(true))
                    stationsTable.setNumberOfRows(min(3,(departures?.count)!), withRowType: "station")
                    for (departure) in departures! {
                        if let sr = stationsTable.rowControllerAtIndex(i) as! StationRow? {
                            sr.drawCell(departure, station: station)
                            i++
                            if (i >= 3) {
                                break;
                            }

                        }
                    }
                    break;
                }
            }
        }

        func errorReply(text: String) {
            stationLabel.setText("Time for Coffee!");
            infoGroup.setHidden(false)
            infoLabel.setText(text)
        }
        TFCWatchData.sharedInstance.getStations(handleReply, errorReply: errorReply, stopWithFavorites: true)

        stationLabel.setText("Loading ...");
        //stationsTable.setNumberOfRows(0, withRowType: "station")

        /*   minutesLabel.setText("")
        destinationLabel.setText("")
        departureLabel.setText("");
        numberLabel.setText("")
        numberLabel.setTextColor(UIColor.whiteColor())
        numberGroup.setBackgroundColor(UIColor.clearColor())*/

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}