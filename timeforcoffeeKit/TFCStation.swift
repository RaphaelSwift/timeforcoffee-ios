//
//  TFCStation.swift
//  timeforcoffee
//
//  Created by Christian Stocker on 21.06.15.
//  Copyright © 2015 Christian Stocker. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


public final class TFCStation: TFCStationBase {

    private func getWalkingDistance(location: CLLocation?, completion: (String?) -> Void ) {
        let walkingDistanceValidString = getLastValidWalkingDistanceValid(location)
        if (walkingDistanceValidString != nil) {
            completion(walkingDistanceValidString)
            return
        }

        let currentCoordinate = location?.coordinate
        let sourcePlacemark:MKPlacemark = MKPlacemark(coordinate: currentCoordinate!, addressDictionary: nil)

        if (self.coord == nil) {
            completion(nil)
            return
        }
        let coord = self.coord!
        let destinationPlacemark:MKPlacemark = MKPlacemark(coordinate: coord.coordinate, addressDictionary: nil)
        let source:MKMapItem = MKMapItem(placemark: sourcePlacemark)
        let destination:MKMapItem = MKMapItem(placemark: destinationPlacemark)
        let directionRequest:MKDirectionsRequest = MKDirectionsRequest()

        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = MKDirectionsTransportType.Walking
        directionRequest.requestsAlternateRoutes = true

        let directions:MKDirections = MKDirections(request: directionRequest)


        directions.calculateDirectionsWithCompletionHandler({
            (response: MKDirectionsResponse?, error: NSError?) in
            if error != nil{
                NSLog("Error")
            }
            if response != nil {
                let route: MKRoute = response!.routes[0] as MKRoute;
                let time =  Int(round(route.expectedTravelTime / 60))
                let meters = Int(route.distance);
                self.walkingDistanceString = "\(meters) m, \(time) min "
                self.walkingDistanceLastCoord = location
                completion(self.walkingDistanceString)
            }  else {
                self.walkingDistanceLastCoord = nil
                self.walkingDistanceString = nil
                NSLog("No response")
                completion(nil)
                print(error?.description)
            }

        })
    }

    public func getDistanceForDisplay(location: CLLocation?, completion: (String?) -> Void) -> String {
        if (location == nil || coord == nil) {
            completion("")
            return ""
        }
        let directDistance = getDistanceInMeter(location)
        var distanceString: String? = ""
        if (directDistance > 5000) {
            let km = Int(round(Double(directDistance!) / 1000))
            distanceString = "\(km) Kilometer"
            completion(distanceString)
        } else {
            // calculate exact distance
            //check if one is in the cache
            distanceString = getLastValidWalkingDistanceValid(location)
            if (distanceString == nil) {
                distanceString = "\(directDistance!) Meter"
                self.getWalkingDistance(location, completion: completion)
            } else {
                completion(distanceString)
            }
        }
        return distanceString!

    }

    public func getDistanceInMeter(location: CLLocation?) -> Int? {
        return Int(location?.distanceFromLocation(coord!) as Double!)
    }

    private func getLastValidWalkingDistanceValid(location: CLLocation?) -> String? {
        if (walkingDistanceLastCoord != nil && walkingDistanceString != nil) {
            let distanceToLast = location?.distanceFromLocation(walkingDistanceLastCoord!)
            if (distanceToLast < 50) {
                return walkingDistanceString
            }
        }
        return nil
    }

    public func getMapImage(completion: (UIImage) -> Void?) {
        let map: MKMapView = MKMapView()
        map.bounds.size = CGSize(width: 320,height: 150)
        let location = self.coord?.coordinate
        let region = MKCoordinateRegionMakeWithDistance(location!,200,200);
        map.setRegion(region, animated: false)

        let options = MKMapSnapshotOptions()
        options.region = map.region
        options.scale = UIScreen.mainScreen().scale
        options.size = map.frame.size

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.startWithCompletionHandler({
            snapshot, error in
            let image = snapshot!.image
            completion(image)
        })
    }

    public func toggleIcon(button: UIButton, icon: UIView, completion: () -> Void) {
        let newImage: UIImage?

        self.toggleFavorite()

        newImage = self.getIcon()

        button.imageView?.alpha = 1.0
        icon.transform = CGAffineTransformMakeScale(1, 1);

        UIView.animateWithDuration(0.2,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                icon.transform = CGAffineTransformMakeScale(0.1, 0.1);
                icon.alpha = 0.0
                return
            }, completion: { (finished:Bool) in
                button.imageView?.image = newImage
                UIView.animateWithDuration(0.2,
                    animations: {
                        icon.transform = CGAffineTransformMakeScale(1, 1);
                        icon.alpha = 1.0
                        return
                    }, completion: { (finished:Bool) in
                        completion()
                        return
                })
        })
        
    }
}