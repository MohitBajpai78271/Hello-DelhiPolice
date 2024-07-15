//
//  ApiMapsViewController.swift
//  ConstableOnPatrol
//
//  Created by Mac on 11/07/24.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

class ApiMapsViewController: UIViewController{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var policeStationLabel: UILabel!
    @IBOutlet weak var policeStationButton: dropDownButton!
    @IBOutlet weak var crimTypeLabel: UILabel!
    @IBOutlet weak var criimeTypeButton: dropDownButton!
    
    @IBOutlet weak var dateText: UILabel!
    var crimes: [Crime] = []
    
    var datePicker: UIDatePicker!
    
    private var transparentView : UIView?
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        criimeTypeButton.delegate = self
        policeStationButton.delegate = self
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        underLinetexts()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        criimeTypeButton.options = CrimesAndPoliceStations.crimeType
        policeStationButton.options = CrimesAndPoliceStations.policeStationPlace
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        fetchCrimeData()
        
    }
    
    //MARK: - UnderLine Texts
    
    func underLinetexts(){
        
        let labelTextCrime = crimTypeLabel.text ?? "All"
        let labelTextPoliceStation = policeStationLabel.text ?? "All"
        
        let labelCrime = crimTypeLabel
        let labelPoliceStation = policeStationLabel
        
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributedStringCrime = NSAttributedString(string: labelTextCrime, attributes: underlineAttribute)
        let attributedStringpoliceStation = NSAttributedString(string: labelTextPoliceStation, attributes: underlineAttribute)
        
        labelCrime?.attributedText = attributedStringCrime
        labelPoliceStation?.attributedText = attributedStringpoliceStation
        
    }
    
    //MARK: - Calender Popped
    
    @IBAction func calenderButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Select Date", message: nil, preferredStyle:.alert)
        alertController.view.addSubview(datePicker)
        
        alertController.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let selectedDate = self?.datePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            let formattedDate = dateFormatter.string(from: selectedDate!)
            self?.dateText.text = formattedDate
        })
        present(alertController,animated: true)
    }
    
    //MARK: - FetchCrimeData and Add Annotation
    
    func fetchCrimeData(){
        let apiUrl = "https://www.openstreetmap.org/copyright"
        
        AF.request(apiUrl).responseDecodable(of: [Crime].self) { response in
            switch response.result{
            case .success(let crimes):
                self.crimes = crimes
                
                DispatchQueue.main.async{
                    self.addCrimeAnnotations()
                }
            case .failure(_):
                print("Found error!")
            }
        }
    }
    
    func addCrimeAnnotations(){
        let annotations = crimes.map{ crime in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: crime.latitude, longitude: crime.longitude)
            annotation.title = crime.crimeType
            annotation.subtitle = "Beat: \(crime.beat),Date: \(crime.date)"
            return annotation
        }
        //        print("Adding Annotation : \(annotations)")
        mapView.addAnnotation(annotations as! MKAnnotation)
    }
    
}

//MARK: - DropDown Button

extension ApiMapsViewController: dropDownButtonDelegate{
    
    func dropDownButtonShowOptions(_ button: dropDownButton, alertController: UIAlertController) {
        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene})
            .flatMap({$0.windows})
            .first(where: { $0.isKeyWindow })?.rootViewController{
            rootViewController.present(alertController, animated: true,completion: nil)
        }
        present(alertController,animated: true,completion: nil)
    }
    
    func dropDownButtonShowOptions(_ button: dropDownButton) {
        print("show option")
    }
    
    func dropDownButtonHideOptions(_ button: dropDownButton) {
        print("hide option")
    }
    
    func dropDownButton(_ button: dropDownButton, didSelectOption option: String) {
        if button == criimeTypeButton{
            crimTypeLabel.text = option
        }else if button == policeStationButton{
            policeStationLabel.text = option
        }
    }

}

//MARK: - CLLocation Manager

extension ApiMapsViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            let alert = UIAlertController(title: "Location Access Denied", message: "Location access is required to show crime markers on the map. Please enable location services in settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true,completion: nil)
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location manager did fail with error : \(error.localizedDescription)")
    }
}

//MARK: - MKMapView

extension ApiMapsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else{return nil}
        
        let identifier = "CrimeAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        }else{
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            //            print("\(location.coordinate.latitude) and \(location.coordinate.longitude)")
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}
