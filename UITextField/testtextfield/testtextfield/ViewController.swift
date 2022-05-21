//
//  ViewController.swift
//  testtextfield
//
//  Created by 野中淳 on 2022/05/21.
//

import Foundation
import UIKit

class ViewController:UIViewController{
    
    let stackView = UIStackView()
    let textField = UITextField()
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
}

extension ViewController{
    
    func style(){
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .tertiarySystemFill
        textField.delegate = self
        textField.placeholder = "input"
        //キーボード入力がされる毎にtextFieldEditingChangedを呼び出す
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
    }
    
    func layout(){
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 2),
            stackView.centerXAnchor.constraint(equalTo:view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo:view.centerYAnchor),
        ])
        
    }
    
}

extension ViewController:UITextFieldDelegate{
    
    // true:編集可能
    //false:編集不可
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // first responderになるタイミングで呼ばれる
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(#function)
    }
    
    //Returnキーを押してテキストフィールドの入力が完了する直前:resign first responderの直後に呼ばれる1
    //true:入力完了
    //false:無視する(resign first responderが無視されキーボード表示のままになる)
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print(#function)
        return true
    }
    
    //resign first responderのタイミングで呼ばれる2
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(#function)
    }
    
    // キーボードの入力を取得する
    // stringがキーボードの入力
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let word = textField.text ?? ""
        let char = string
        print("\(#function) \(word) \(char)")
        return true
    }
    
    //クリアボタンを押した時に呼ばれる
    // true:クリア完了
    //false:無視
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print(#function)
        return true
    }
    
    // returnキーを押した直後
    // true:return完了
    // false:無視
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true) // resign first responder
        print(#function)
        return true
    }
    
}
extension ViewController{
    
    @objc func textFieldEditingChanged(sender:UITextField){
        print("\(#function) text:\(sender.text)")
        DispatchQueue.main.async {
            self.label.text = sender.text
        }
    }
}
