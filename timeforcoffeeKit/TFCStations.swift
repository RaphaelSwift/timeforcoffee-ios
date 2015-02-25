//
//  TFCStations.swift
//  timeforcoffee
//
//  Created by Christian Stocker on 25.02.15.
//  Copyright (c) 2015 Christian Stocker. All rights reserved.
//

import Foundation
import CoreLocation

public class TFCStations {
    var stations:[TFCStation] = []
    var favoriteStations: [String: TFCStation] = [:]


    public init() {
        populateFavoriteStations()

    }

    public func count() -> Int {
        return stations.count
    }
    
    public func addWithJSON(allResults: JSONValue) {
        stations = []
        // Create an empty array of Albums to append to from this list
        // Store the results in our table data array
        if allResults["stations"].array?.count>0 {
            if let results = allResults["stations"].array {
                for result in results {
                    var name = result["name"].string
                    var id = result["id"].string
                    var longitude = result["coordinate"]["y"].double
                    var latitude = result["coordinate"]["x"].double
                    var Clocation = CLLocation(latitude: latitude!, longitude: longitude!)
                    var newStation = TFCStation(name: name!, id: id!, coord: Clocation)
                    stations.append(newStation)
                }
            }
        }
    }
    
    public func getStation(index: Int) -> TFCStation {
        return stations[index]
    }
    
    public func isFavoriteStation(index: String) -> Bool {
        if (favoriteStations[index] != nil) {
            return true
        }
        return false
    }
    
    public func unsetFavoriteStation(st_id: String) {
        var favoriteStationsDict = getFavoriteStationsDict()
        favoriteStationsDict[st_id] = nil
        favoriteStations[st_id] = nil
        saveFavoriteStations(favoriteStationsDict)
    }
    
    public func setFavoriteStation(station: TFCStation) {
        var favoriteStationsDict = getFavoriteStationsDict()
        favoriteStationsDict[station.st_id] =  [
        "name": station.name,
        "st_id": station.st_id,
        "latitude": station.coord.coordinate.latitude.description,
        "longitude": station.coord.coordinate.longitude.description
        ]
        favoriteStations[station.st_id] = station
        saveFavoriteStations(favoriteStationsDict)
    }
    
    func saveFavoriteStations(favoriteStationsDict: [String: [String: String]]) {
        var sharedDefaults = NSUserDefaults(suiteName: "group.ch.liip.timeforcoffee")
        sharedDefaults?.setObject(favoriteStationsDict, forKey: "favoriteStations")
    }
    
    func populateFavoriteStations() {
        var favoriteStationsDict = getFavoriteStationsDict()
        for (st_id, station) in favoriteStationsDict {
            let lat = NSString(string:station["latitude"]!).doubleValue
            let long = NSString(string:station["longitude"]!).doubleValue
            var Clocation = CLLocation(latitude: lat, longitude: long)
            let station: TFCStation = TFCStation(name: station["name"]!, id: station["st_id"]!, coord: Clocation)
            self.favoriteStations[st_id] = station
        }
    }
    
    
    func getFavoriteStationsDict() -> [String: [String: String]] {
        var sharedDefaults = NSUserDefaults(suiteName: "group.ch.liip.timeforcoffee")
        var favoriteStationsShared: [String: [String: String]]? = sharedDefaults?.objectForKey("favoriteStations") as [String: [String: String]]?
        
        if (favoriteStationsShared == nil) {
            favoriteStationsShared = [:]
        }
        return favoriteStationsShared!
    }
    
}