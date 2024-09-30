import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var distanceReading: UILabel!
    
    @IBOutlet var circleView: UIView!
    
    var locationManager: CLLocationManager?
    var didFindBeacon = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        
        circleView.layer.cornerRadius = 128
        circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: beaconConstraint)
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 0.8) { [weak self] in
            switch distance {
            case .far:
                self?.view.backgroundColor = UIColor.blue
                self?.distanceReading.text = "FAR"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)

            case .near:
                self?.view.backgroundColor = UIColor.orange
                self?.distanceReading.text = "NEAR"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            case .immediate:
                self?.view.backgroundColor = UIColor.red
                self?.distanceReading.text = "RIGHT HERE"
                self?.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

            default:
                self?.view.backgroundColor = UIColor.gray
                self?.distanceReading.text = "UNKNOWN"
                self?.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            didFindBeacon = true
            let alert = UIAlertController(title: "Beacon was found", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default))
            
            present(alert, animated: true)
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
}

