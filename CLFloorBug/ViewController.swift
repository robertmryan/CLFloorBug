//
//  ViewController.swift
//  CLFloorBug
//
//  Created by Robert Ryan on 3/23/20.
//  Copyright © 2020 Robert Ryan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!

    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureLocationManager()
    }

    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 6
        return formatter
    }()

    @IBAction func didTapGetLocation(_ sender: Any) {
        updateLabels(for: locationManager.location)
    }

    @IBAction func didTapStartUpdatingLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
}

private extension ViewController {
    func configureLocationManager() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined: locationManager.requestWhenInUseAuthorization()
        case .denied:        redirectToSettings()
        default:             break
        }
    }

    func updateLabels(for location: CLLocation?) {
        guard let location = location else {
            latitudeLabel.text = nil
            longitudeLabel.text = nil
            altitudeLabel.text = nil
            floorLabel.text = nil
            return
        }

        latitudeLabel.text = numberFormatter.string(for: location.coordinate.latitude)
        longitudeLabel.text = numberFormatter.string(for: location.coordinate.longitude)
        altitudeLabel.text = numberFormatter.string(for: location.altitude)

        if let level = locationManager.location?.floor?.level {
            let hexString = "0x" + String(format: "%08x", level)
            floorLabel.text = "\(level) (\(hexString))"
        } else {
            floorLabel.text = "No floor info."
        }
    }

    func redirectToSettings() {
        guard
            let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        else {
            return
        }

        let alert = UIAlertController(title: nil, message: "We need permission to settings to illustrate the problem? Please grant permission in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last(where: { $0.horizontalAccuracy >= 0 })
        updateLabels(for: location)
    }
}
