import CoreLocation
import UIKit

class SpeedometerViewController: UIViewController {
    private let locationManager: CLLocationManager

    private var speedValue: Double? {
        didSet {
            guard let speedValue = speedValue else {
                return
            }

            let speed = Speed(speed: speedValue, unit: unit, speedLimit: UserDefaults.standard.float(forKey: Configuration.currentSpeedLimitDefaultsKey))
            switch speed.limitIsExceeded {
            case true:
                speedLabel.textColor = UIColor(red: 0.6196, green: 0, blue: 0, alpha: 1.0)
            case false:
                speedLabel.textColor = nil
            }

            speedLabel.text = speed.asString
        }
    }

    private var unit: Unit {
        didSet {
            unitLabel.text = unit.abbreviation
        }
    }

    // MARK: - Controller Lifecycle

    init(locationManager: CLLocationManager, unit: Unit) {
        self.locationManager = locationManager
        self.unit = unit

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureLocationManager()
    }

    // MARK: - Outlets & Actions

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl! {
        didSet {
            unitSegmentedControl.removeAllSegments()
            units.enumerated().forEach { (index, unit) in
                unitSegmentedControl.insertSegment(withTitle: unit.abbreviation, at: index, animated: false)
            }

            unitSegmentedControl.selectedSegmentIndex = units.index(where: { $0.abbreviation == unit.abbreviation }) ?? 0
        }
    }

    @IBAction func presentSettings(_ sender: UIButton) {
        present(SettingsViewController(unit: unit), animated: true, completion: nil)
    }

    @IBAction func selectUnit(_ sender: UISegmentedControl) {
        selectUnit(unit: units[sender.selectedSegmentIndex])
    }
}

// MARK: - CLLocationManagerDelegate

extension SpeedometerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if speedLabel.text == Configuration.speedPlaceholderLabel {
            UIView.transition(with: speedLabel, duration: Configuration.speedPlaceholderAnimationDuration, options: .transitionCrossDissolve, animations: { [weak self] in
                self?.speedValue = locations.last?.speed ?? 0
            }, completion: nil)
        }

        speedValue = locations.last?.speed ?? 0
    }
}

// MARK: - Private Methods

private extension SpeedometerViewController {
    func configureView() {
        speedLabel.text = Configuration.speedPlaceholderLabel
        unitLabel.text = unit.abbreviation

        StoreReviewHelper.askForReview()
    }

    func selectUnit(unit: Unit) {
        self.unit = unit
        UserDefaults.standard.set(unit.rawValue, forKey: Configuration.currentUnitDefaultsKey)
        UserDefaults.standard.removeObject(forKey: Configuration.currentSpeedLimitDefaultsKey)
    }

    func configureLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}
