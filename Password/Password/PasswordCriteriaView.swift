//
//  PasswordCriteriaView.swift
//  Password
//
//  Created by 野中淳 on 2022/05/09.
//
import Foundation
import UIKit

class PasswordCriteriaView:UIView{
    
    let stackView = UIStackView()
    let imageView = UIImageView()
    let label = UILabel()
    
    let checkmarkImage = UIImage(systemName: "checkmark.circle")!.withTintColor(.systemGreen,renderingMode: .alwaysOriginal)
    let xmarkImage = UIImage(systemName: "xmark.circle")!.withTintColor(.systemRed,renderingMode: .alwaysOriginal)
    let circleemarkImage = UIImage(systemName: "circle")!.withTintColor(.secondaryLabel,renderingMode: .alwaysOriginal)

    var isCriteriaMet:Bool = false{
        didSet{
            if isCriteriaMet{
                imageView.image = checkmarkImage
            }else{
                imageView.image = xmarkImage
            }
        }
    }
    
    func reset(){
        isCriteriaMet = false
        imageView.image = circleemarkImage
    }
    
//    override init(frame:CGRect){
//        super.init(frame: frame)
//        style()
//        layout()
//    }
    
    init(text:String){
        super.init(frame: .zero)
        
        label.text = text
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize:CGSize{
        return CGSize(width: 200, height: 40)
    }
}

extension PasswordCriteriaView{
    
    func style(){
        translatesAutoresizingMaskIntoConstraints = false
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = circleemarkImage

        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .subheadline)
    }
    
    func layout(){
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)
        addSubview(stackView)

        //stackView
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
        ])
       
        //Image
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        
        //CHCR
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
    }
    
}
