//
//  ViewController.swift
//  UIKit_SwiftUIPreview
//
//  Created by 野中淳 on 2022/06/22.
//

import UIKit

class ViewController: UIViewController {

    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blue
        button.setTitle("pressedButton", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        view.addSubview(button)
        
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
    ForEach(deviceNames, id: \.self) { deviceName in
      UIViewControllerPreview {
          ViewController()
      }.previewDevice(PreviewDevice(rawValue: deviceName))
        .previewDisplayName(deviceName)
    }
  }
}
#endif
