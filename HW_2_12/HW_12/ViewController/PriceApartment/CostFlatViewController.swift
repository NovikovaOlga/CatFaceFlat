import Foundation
import UIKit
import MapKit

class CostFlatViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    let model = PriceApartmentNew()
    
    var floorDataValue = Double()
    var roomsDataValue = Double()
    var areaDataValue = Double()
    
    var latitudeValue = CLLocationDegrees()
    var longitudeValue = CLLocationDegrees()
    
    var regionRadius: CLLocationDistance = 30000
    let initialLocation = CLLocation(latitude: 55.75407, longitude: 37.62050)
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var floorSlider: UISlider! { didSet {
        floorSlider.maximumValue = 7
        floorSlider.minimumValue = 1
        floorSlider.value = 1
    }}
    @IBOutlet weak var roomsSlider: UISlider! { didSet {
        roomsSlider.maximumValue = 5
        roomsSlider.minimumValue = 1
        roomsSlider.value = 1
    }}
    
    @IBOutlet weak var areaSlider: UISlider! { didSet {
        areaSlider.maximumValue = 140
        areaSlider.minimumValue = 18
        areaSlider.value = 18
        
    }}
    
    
    @IBOutlet weak var floorData: UILabel! { didSet {
        floorData.text = "1"
    }}
    @IBOutlet weak var roomsData: UILabel! { didSet {
        roomsData.text = "1"
    }}
    
    @IBOutlet weak var areaData: UILabel! { didSet {
        areaData.text = "18"
    }}
    
    
    @IBOutlet weak var latitudeData: UILabel! { didSet {
        latitudeData.text = "\(latitudeValue)"
    }}
    
    @IBOutlet weak var longitudeData: UILabel! { didSet {
        longitudeData.text = "\(longitudeValue)"
    }}
    
    
    @IBAction func floorSliderAction(_ sender: UISlider) {
        floorDataValue = Double(sender.value) //Int(round(sender.value))
        floorData.text = "\(Int(floorDataValue))"
    }
    
    @IBAction func roomsSliderAction(_ sender: UISlider) {
        roomsDataValue = Double(sender.value) //Int(round(sender.value))
        roomsData.text = "\(Int(roomsDataValue))"
    }
    
    @IBAction func areaSliderAction(_ sender: UISlider) {
        areaDataValue = Double(sender.value)
        areaData.text = "\(Int(areaDataValue))"
        
    }
    
    
    @IBAction func you(_ sender: Any) { // возврат в центр
        centerToLocation(initialLocation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // центрирование карты по координатам
        centerToLocation(initialLocation)
        
        //   self.setMapView()
        self.addTap()
    }
    
    // MARK: settings region
    func centerToLocation(_ location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius, // ограничения региона по ширине
            longitudinalMeters: regionRadius) // огрнаичение региона по долготе
        mapView.setRegion(coordinateRegion, animated: true) // автоматический перевод карты в регион масштабирования
    }
    
    // MARK: UITapGesture
    func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchedScreen(touch:)))
        mapView.addGestureRecognizer(tap)
    }
    
    @objc func touchedScreen(touch: UITapGestureRecognizer) {
        let touchPoint = touch.location(in: mapView)
        let touchPointCoordinate = mapView.convert(touchPoint,toCoordinateFrom: mapView)
        latitudeValue = touchPointCoordinate.latitude
        longitudeValue = touchPointCoordinate.longitude
        latitudeData.text = "\(latitudeValue)"
        longitudeData.text = "\(longitudeValue)"
        print("Tapped at lat: \(latitudeValue) long: \(longitudeValue)")
        
    }
    
    // MARK: Vision (Tabular Regression)
    
    @IBAction func priceValueAction(_ sender: Any) {
        priceValueAction()
    }
    
    func priceValueAction() {
        let prediction = try? model.prediction(Area: areaDataValue, Floor: floorDataValue, Rooms: roomsDataValue, Latitude: latitudeValue, Longitude: longitudeValue)
        
        let price = Int(prediction?.Price ?? 0)
        priceLabel.text = "\(price)"
    }
}

