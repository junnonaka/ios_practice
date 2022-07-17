//
//  ViewController.swift
//  Weathery
//
//  Created by 野中淳 on 2022/07/11.
//

import UIKit

class ViewController: UIViewController {
    
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
        
        style()
        layout()
        
    }
}
extension ViewController{
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
        
        serchButon.translatesAutoresizingMaskIntoConstraints = false
        serchButon.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        serchButon.tintColor = .label
        
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
        tempratureLabel.text = "15.4℃"
        tempratureLabel.tintColor = .label
        tempratureLabel.font = UIFont.systemFont(ofSize: 80,weight: .bold)

        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.text = "San Francisco"
        cityLabel.tintColor = .label
        cityLabel.font = UIFont.systemFont(ofSize: 40,weight: .regular)

        
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
