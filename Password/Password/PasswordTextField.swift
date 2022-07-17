//
//  PasswordTextField.swift
//  Password
//
//  Created by 野中淳 on 2022/05/08.
//

import Foundation
import UIKit

protocol PasswordTextFieldDelegate : AnyObject{
    func editingChanged(_ sender:PasswordTextField)
    func editingDidEnd(_ sender:PasswordTextField)
}

class PasswordTextField:UIView{
    
    typealias CustomValidation = (_ textValue:String?) ->(Bool,String)?
    
    let lockImageView = UIImageView(image: UIImage(systemName: "lock.fill"))
    let textField = UITextField()
    let eyeButton = UIButton(type: .custom)
    let dividerView = UIView()
    let errorLabel = UILabel()

    let placeHolderText:String
    var custumValidation:CustomValidation?
    
    var text:String?{
        get{return textField.text}
        set{textField.text = newValue}
    }
    
    weak var delegate:PasswordTextFieldDelegate?
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        style()
//        layout()
//    }
    
    init(placeholderText: String) {
        self.placeHolderText = placeholderText
        super.init(frame: .zero)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //部品の初期サイズを決める
    override var intrinsicContentSize: CGSize{
        return CGSize(width: 200, height: 50)
    }
}

extension PasswordTextField{
    //オブジェクトの設定
    func style(){
        translatesAutoresizingMaskIntoConstraints = false
        //backgroundColor = .systemOrange
        
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = false //デバッグ用に意図的にfalseにしている
        textField.placeholder = placeHolderText
        textField.delegate = self
        textField.keyboardType = .asciiCapable
        textField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [NSAttributedString.Key.foregroundColor:UIColor.secondaryLabel])
        //extra interaction
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.setImage(UIImage(systemName: "eye.circle"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye.slash.circle"), for: .selected)
        eyeButton.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = .separator
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textColor = .systemRed
        errorLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        //errorLabel.text = "Enter your password"
        errorLabel.text = "Enter your password must meet the requirements below"
//        errorLabel.adjustsFontSizeToFitWidth = true
//        errorLabel.minimumScaleFactor = 0.8
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.isHidden = true
    }
    
    
    //オブジェクトのレイアウト
    func layout(){
        addSubview(lockImageView)
        addSubview(textField)
        addSubview(eyeButton)
        addSubview(dividerView)
        addSubview(errorLabel)
        
        //lock
        NSLayoutConstraint.activate([
            lockImageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            lockImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            
        ])
        
        //textField
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalToSystemSpacingAfter: lockImageView.trailingAnchor, multiplier: 1)
        ])
        
        //eyeButton
        NSLayoutConstraint.activate([
            eyeButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            eyeButton.leadingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1),
            eyeButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        //dividerView
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalToSystemSpacingBelow: textField.bottomAnchor, multiplier: 1),
            dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1)
            
        ])
        
        //errorLabel
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
        ])
        
        //CHCR
        lockImageView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        eyeButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        
        
    }
    
}

extension PasswordTextField{
    @objc func togglePasswordView(){
        textField.isSecureTextEntry.toggle()
        eyeButton.isSelected.toggle()
    }
    
    @objc func textFieldEditingChanged(_ sender:UITextField){
        print("foo - \(sender.text)")
        delegate?.editingChanged(self)
    }
}

extension PasswordTextField:UITextFieldDelegate{
    //フォーカスを失った時に検出
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.editingDidEnd(self)
    }
    //retuenを押した時にフォーカスを失う
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)//resign first responder
        return true
    }
}

// typealias CustomValidation = (_ textValue:String?) ->(Bool,String)?
//typealiasでtypeを指定して判定式は後で入れる。外部で式を定義してtypealiasに入れて、結果を取得する
extension PasswordTextField{
    func validate() -> Bool{
        if let customValidation = custumValidation,
           //textfieldの値を入れている
           let customValidationResult = customValidation(text),
           //戻り値はtuppleなので.0が結果、1がtext
           customValidationResult.0 == false{
            showError(customValidationResult.1)
            return false
        }
        
        clearError()
        return true
    }
    
    private func showError(_ errorMessage:String){
        errorLabel.isHidden = false
        errorLabel.text = errorMessage
    }
    
    private func clearError(){
        errorLabel.isHidden = false
        errorLabel.text = ""
    }
}
