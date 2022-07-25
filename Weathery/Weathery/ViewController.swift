//
//  ViewController.swift
//  Weathery
//
//  Created by 野中淳 on 2022/07/11.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var weatherService = WeatherService()
    
    let backgroundView = UIImageView()
    let rootStackView = UIStackView()
    
    //serch
    let serchStackView = UIStackView()
    let locationButton = UIButton()
    let serchButon = UIButton()
    let serchTextField = UITextField()
    
    //Weather
    let conditionImageView = UIImageView()
    let tempratureLabel = UILabel()
    let cityLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        style()
        layout()
        
    }
}
extension ViewController{
    func setup(){
        serchTextField.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherService.delegate = self
    }
    
    func style(){
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.image = UIImage(named: "day-background")
        backgroundView.contentMode = .scaleAspectFill
        
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .vertical
        rootStackView.alignment = .trailing
        rootStackView.spacing = 10
        
        serchStackView.translatesAutoresizingMaskIntoConstraints = false
        serchStackView.spacing = 8
        serchStackView.axis = .horizontal
        
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.setBackgroundImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        locationButton.tintColor = .label
        locationButton.addTarget(self, action: #selector(locationPressed(_:)), for: .primaryActionTriggered)
        
        serchButon.translatesAutoresizingMaskIntoConstraints = false
        serchButon.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        serchButon.tintColor = .label
        serchButon.addTarget(self, action: #selector(serchPressed(_sender:)), for: .primaryActionTriggered)
        
        serchTextField.translatesAutoresizingMaskIntoConstraints = false
        serchTextField.font = UIFont.preferredFont(forTextStyle: .title1)
        serchTextField.placeholder = "Serch"
        serchTextField.textAlignment = .right
        serchTextField.borderStyle = .roundedRect
        serchTextField.backgroundColor = .systemFill

        
        conditionImageView.translatesAutoresizingMaskIntoConstraints = false
        conditionImageView.image = UIImage(systemName: "sun.max")
        conditionImageView.tintColor = .label
        
        tempratureLabel.translatesAutoresizingMaskIntoConstraints = false
        //tempratureLabel.text = "15.4℃"
        tempratureLabel.tintColor = .label
        //tempratureLabel.font = UIFont.systemFont(ofSize: 80,weight: .bold)
        tempratureLabel.attributedText = makeTemperatureText(with:"21")

        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.text = "San Francisco"
        cityLabel.tintColor = .label
        cityLabel.font = UIFont.systemFont(ofSize: 40,weight: .regular)

        
    }
    
    private func makeTemperatureText(with temperature:String)->NSAttributedString{
        var boldAttributes = [NSAttributedString.Key:AnyObject]()
        boldAttributes[.foregroundColor] = UIColor.label
        boldAttributes[.font] = UIFont.boldSystemFont(ofSize: 100)
        
        var planeTextAttributes = [NSAttributedString.Key:AnyObject]()
        planeTextAttributes[.font] = UIFont.systemFont(ofSize: 80)
        
        let text = NSMutableAttributedString(string: temperature, attributes: boldAttributes)
        text.append(NSAttributedString(string: "℃", attributes: planeTextAttributes))
        
        return text
    }
    
    
    func layout(){
        view.addSubview(backgroundView)
        view.addSubview(rootStackView)
        
        rootStackView.addArrangedSubview(serchStackView)
        rootStackView.addArrangedSubview(conditionImageView)
        rootStackView.addArrangedSubview(tempratureLabel)
        rootStackView.addArrangedSubview(cityLabel)
        
        serchStackView.addArrangedSubview(locationButton)
        serchStackView.addArrangedSubview(serchTextField)
        serchStackView.addArrangedSubview(serchButon)
 
        
        
//        view.addSubview(locationButton)
//        view.addSubview(serchButon)
//        view.addSubview(serchTextField)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            rootStackView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor),
            rootStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1 ),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: rootStackView.trailingAnchor, multiplier: 1),
            
            rootStackView.widthAnchor.constraint(equalTo: serchStackView.widthAnchor),
            
            locationButton.widthAnchor.constraint(equalToConstant: 40),
            locationButton.heightAnchor.constraint(equalToConstant: 40),
            

            serchButon.heightAnchor.constraint(equalToConstant: 40),
            serchButon.widthAnchor.constraint(equalToConstant: 40),
            
            conditionImageView.heightAnchor.constraint(equalToConstant: 120),
            conditionImageView.widthAnchor.constraint(equalToConstant: 120),


            
        ])
        
        
    }
}
//MARK: - UITextFieldDelegate
extension ViewController:UITextFieldDelegate{
    
    @objc func serchPressed(_sender: UIButton){
        serchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        serchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }else{
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = serchTextField.text{
            weatherService.fetchWeather(cityName: city)
        }
        
        serchTextField.text = ""
    }
}

extension ViewController:CLLocationManagerDelegate{
    
    @objc func locationPressed(_ sender:UIButton){
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherService.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
//MARK: - WeatherServiceDelegate
extension ViewController:WeatherServiceDelegate{
    func didFailWithError(_ weatherService: WeatherService, _ error: ServiceError) {
        let message: String
        
        switch error {
        case .network(statusCode: let statusCode):
            message = "Networking error. Status code: \(statusCode)."
        case .parsing:
            message = "JSON weather data could not be parsed."
        case .general(reason: let reason):
            message = reason
        }
        showErrorAlert(with: message)
    }
    func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error fetching weather",
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    func didFetchWeather(_ weaterService: WeatherService, _ weather: WeatherModel) {
        tempratureLabel.attributedText = makeTemperatureText(with: weather.temperatureString)
        cityLabel.text = weather.cityName
        conditionImageView.image = UIImage(systemName: weather.conditionName)
    }
    
//    func didFetchWeather() {
//        //update UI
//        tempratureLabel.attributedText = makeTemperatureText(with: wether.)
//        cityLabel.text = wether.cityName
//    }
    
    
}

#if canImport(SwiftUI) && DEBUG
//SwiftUIのViewでViewControllerをラップしている
import SwiftUI
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    // MARK: - UIViewControllerRepresentable
    //初期化メソッド
    func makeUIViewController(context: Context) -> ViewController {
        //ViewControllerを返す
        viewController
    }
    // SwiftUI側から更新がかかったときに呼ばれるメソッド
    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<UIViewControllerPreview<ViewController>>) {
        return
    }
}
#endif

#if canImport(SwiftUI) && DEBUG
import SwiftUI
//Previewで使うデバイスを複数出す時に便利
//これを使わなくても.previewDeviceを外せばSimulaterで選んだデバイスで実行される
let deviceNames: [String] = [
    "iPhone SE",
    "iPhone 11 Pro Max",
    "iPad Pro (11-inch)"
]

@available(iOS 13.0, *)
//Previewを表示するためのプロトコル
//Previewで指定したViewをCanvasでプレビュー表示する
//XCodeが勝手に検知してくれる
struct ViewController_Preview: PreviewProvider {
    static var previews: some View {
        //ForEach(deviceNames, id: \.self) { deviceName in
          UIViewControllerPreview {
              ViewController()
          }.edgesIgnoringSafeArea(.vertical)
          
          //.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
            //.previewDisplayName(deviceName)
        }
      //}
}
#endif
