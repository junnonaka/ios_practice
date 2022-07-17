//
//  PasswordStatusView.swift
//  Password
//
//  Created by 野中淳 on 2022/05/10.
//

import Foundation
import UIKit

class PasswordStatusView:UIView{
    
    let stackView = UIStackView()
    let lengthCriteriaView = PasswordCriteriaView(text: "8-32 characters (no spaces)")
    let uppercaseCriteriaView = PasswordCriteriaView(text: "uppercase letter (A-Z)")
    let lowercaseCriteriaView = PasswordCriteriaView(text: "lowercase (a-z)")
    let digitCriteriaView = PasswordCriteriaView(text: "digit (0-9)")
    let specialCharacterCriteriaView = PasswordCriteriaView(text: "special character (e.g !@#$%^)")

    //Used to determine if we reset criteria back to empty state
    var shouldResetCriteria:Bool = true
    
    let criterialabel = UILabel()

    override init(frame:CGRect){
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize:CGSize{
        return CGSize(width: 200, height: 200)
    }
}

extension PasswordStatusView{
    
    func style(){
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .tertiarySystemFill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        
        lengthCriteriaView.translatesAutoresizingMaskIntoConstraints = false
        uppercaseCriteriaView.translatesAutoresizingMaskIntoConstraints = false
        lowercaseCriteriaView.translatesAutoresizingMaskIntoConstraints = false
        digitCriteriaView.translatesAutoresizingMaskIntoConstraints = false
        specialCharacterCriteriaView.translatesAutoresizingMaskIntoConstraints = false

        criterialabel.numberOfLines = 0
        criterialabel.lineBreakMode = .byWordWrapping
        criterialabel.attributedText = makeCriteriaMessage()
        
    }
    
    func layout(){
        stackView.addArrangedSubview(lengthCriteriaView)
        stackView.addArrangedSubview(criterialabel)
        stackView.addArrangedSubview(uppercaseCriteriaView)
        stackView.addArrangedSubview(lowercaseCriteriaView)
        stackView.addArrangedSubview(digitCriteriaView)
        stackView.addArrangedSubview(specialCharacterCriteriaView)

        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 2),
            //bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 2),
        ])
        
       
    }
    
}
extension PasswordStatusView{
    private func makeCriteriaMessage()->NSAttributedString{
        var planeTextAttributes = [NSAttributedString.Key : AnyObject]()
        planeTextAttributes[.font] = UIFont.preferredFont(forTextStyle: .subheadline)
        planeTextAttributes[.foregroundColor] = UIColor.secondaryLabel
        
        var boldTextAttributes = [NSAttributedString.Key : AnyObject]()
        boldTextAttributes[.font] = UIFont.preferredFont(forTextStyle: .subheadline)
        boldTextAttributes[.foregroundColor] = UIColor.label
        
        let attrText = NSMutableAttributedString(string: "Use at least", attributes: planeTextAttributes)
        attrText.append(NSAttributedString(string: "3 of these ", attributes: boldTextAttributes))
        attrText.append(NSAttributedString(string: "criteria when setting your password:",attributes: planeTextAttributes))
        return attrText
    }
    
}

extension PasswordStatusView{
    func updateDisplay(_ text:String){
        let lengthAndNoSpaceMet = PasswordCriteria.lengthAndNoSpaceMet(text)
        let uppercaseMet = PasswordCriteria.uppercaseMet(text)
        let lowercaseMet = PasswordCriteria.lowercaseMet(text)
        let digiMet = PasswordCriteria.digitMet(text)
        let specialCharacterMet = PasswordCriteria.specialCharacterMet(text)
        
        if shouldResetCriteria{
            //Inline validateion
            lengthAndNoSpaceMet ? lengthCriteriaView.isCriteriaMet = true : lengthCriteriaView.reset()
            
            uppercaseMet ? uppercaseCriteriaView.isCriteriaMet = true : uppercaseCriteriaView.reset()
            
            lowercaseMet ? lowercaseCriteriaView.isCriteriaMet = true : lowercaseCriteriaView.reset()
            
            digiMet ? digitCriteriaView.isCriteriaMet = true : digitCriteriaView.reset()
            
            specialCharacterMet ? specialCharacterCriteriaView.isCriteriaMet = true : specialCharacterCriteriaView.reset()
        }else{
            //Focus lost
            lengthCriteriaView.isCriteriaMet = lengthAndNoSpaceMet
            uppercaseCriteriaView.isCriteriaMet = uppercaseMet
            lowercaseCriteriaView.isCriteriaMet = lowercaseMet
            digitCriteriaView.isCriteriaMet = digiMet
            specialCharacterCriteriaView.isCriteriaMet = specialCharacterMet
            
            
        }
    }
    
    func validate(_ text:String) -> Bool{
        let uppercaseMet = PasswordCriteria.uppercaseMet(text)
        let lowercaseMet = PasswordCriteria.lowercaseMet(text)
        let digitMet = PasswordCriteria.digitMet(text)
        let specialCharacterMet = PasswordCriteria.specialCharacterMet(text)
        
        //4つの中で3つ以上trueだったらtrueを返したい
        let checkable = [uppercaseMet,lowercaseMet,digitMet,specialCharacterMet]
        let metCriteria = checkable.filter { $0 }
        let lengthAndNoSpaceMet = PasswordCriteria.lengthAndNoSpaceMet(text)
        
        if lengthAndNoSpaceMet && metCriteria.count >= 3 {
            return true
        }
        
        return false
    }
    
    func reset(){
        lengthCriteriaView.reset()
        uppercaseCriteriaView.reset()
        lowercaseCriteriaView.reset()
        digitCriteriaView.reset()
        specialCharacterCriteriaView.reset()
    }
}
