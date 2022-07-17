//
//  ViewController.swift
//  Password
//
//  Created by 野中淳 on 2022/05/08.
//

import Foundation
import UIKit

class ViewController:UIViewController{
    typealias CustomValidation = PasswordTextField.CustomValidation
    
    let stackView = UIStackView()
    let newPasswordTextField = PasswordTextField(placeholderText: "New password")
    let statusView = PasswordStatusView()
    let confirmPasswortTextField = PasswordTextField(placeholderText: "Re-enter new passwort")
    
    let resetButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setup()
    }
    
}

extension ViewController{
    func setup(){
        setupNewPassword()
        setupConfirmPassword()
        setupDismissKeyboardGesture()
        setupKeyboardHiding()
    }
    
    //typealias CustomValidation = (_ textValue:String?) -> (Bool,String)?
    
    //emptyチェック
    private func setupNewPassword(){
        //これがtypealiasで定義したValidationに入れる関数
        let newPasswordValiidation:CustomValidation = { text in
            //empty text
            guard let text = text,!text.isEmpty else{
                self.statusView.reset()
                return (false,"Enter your password")
            }
            
            // Valid characters
            let validChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,@:?!()$\\/#"
            let invalidSet = CharacterSet(charactersIn: validChars).inverted
            guard text.rangeOfCharacter(from: invalidSet) == nil else {
                self.statusView.reset()
                return (false, "Enter valid special chars (.,@:?!()$\\/#) with no spaces")
            }
            
            //Criteria met
            self.statusView.updateDisplay(text)
            if !self.statusView.validate(text){
                return (false,"Your password must meet the requirments below")
            }
            
            return (true,"")
            
        }
        newPasswordTextField.custumValidation = newPasswordValiidation
        newPasswordTextField.delegate = self
        
    }
    
    private func setupConfirmPassword(){
        let confirmPasswordValidation:CustomValidation = { text in
            guard let text = text, !text.isEmpty else{
                return(false,"Enter your passwore")
            }
            
            guard text == self.newPasswordTextField.text else{
                return (false,"Passwords do not match")
            }
            
            return (true,"")
        }
        
        confirmPasswortTextField.custumValidation = confirmPasswordValidation
        confirmPasswortTextField.delegate = self
    }
    
    private func setupDismissKeyboardGesture(){
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    @objc func viewTapped(_ recognizer:UITapGestureRecognizer){
        view.endEditing(true)//resign first responder
    }
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func style(){
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        newPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswortTextField.translatesAutoresizingMaskIntoConstraints = false
        
        statusView.translatesAutoresizingMaskIntoConstraints = false
        statusView.layer.cornerRadius = 5
        statusView.clipsToBounds = true
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.configuration = .filled()
        resetButton.setTitle("Reset passwort", for: [])
        resetButton.addTarget(self, action: #selector(resetPasswordButtonTapped), for: .primaryActionTriggered)
    }
    
    func layout(){
        stackView.addArrangedSubview(newPasswordTextField)
        stackView.addArrangedSubview(statusView)
        stackView.addArrangedSubview(confirmPasswortTextField)
        stackView.addArrangedSubview(resetButton)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 2),
        ])
        
    }
    
}

extension ViewController:PasswordTextFieldDelegate{
    func editingDidEnd(_ sender: PasswordTextField) {
        if sender === newPasswordTextField{
            statusView.shouldResetCriteria = false
            _ = newPasswordTextField.validate()
        }else if sender == confirmPasswortTextField{
            _ = confirmPasswortTextField.validate()
        }
    }
    
    func editingChanged(_ sender: PasswordTextField) {
        if sender === newPasswordTextField{
            statusView.updateDisplay(sender.textField.text ?? "")
        }
    }
}

// MARK: Keyboard
extension ViewController {
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              //keyBordのフレームを取得する
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              //FirstResponderのTextFieldを取得する
              let currentTextField = UIResponder.currentFirst() as? UITextField else { return }
        
        print("foo - userInfo: \(userInfo)")
        print("foo - keyboardFrame: \(keyboardFrame)")
        print("foo - currentTextField: \(currentTextField)")
        
        // check if the top of the keyboard is above the bottom of the currently focused textbox
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        
        
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        
        
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height

        // if textField bottom is below keyboard bottom - bump the frame up
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            view.frame.origin.y = newFrameY
        }

        print("foo - currentTextFieldFrame: \(currentTextField.frame)")
        print("foo - convertedTextFieldFrame: \(convertedTextFieldFrame)")
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
}
// MARK: Actions
extension ViewController {

    @objc func resetPasswordButtonTapped(sender: UIButton) {
        view.endEditing(true)

        let isValidNewPassword = newPasswordTextField.validate()
        let isValidConfirmPassword = confirmPasswortTextField.validate()

        if isValidNewPassword && isValidConfirmPassword {
            showAlert(title: "Success", message: "You have successfully changed your password.")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert =  UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        alert.title = title
        alert.message = message
        present(alert, animated: true, completion: nil)
    }
}
