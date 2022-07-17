//
//  ViewController.swift
//  TermsAndConditions_CombineEx
//
//  Created by 野中淳 on 2022/07/10.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var acceptedSwitch: UISwitch!
    
    @IBOutlet weak var privacySwitch: UISwitch!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    //Define Publishers
    
    @Published private var acceptedTerms = false
    @Published private var acceptedPrivacy = false
    @Published private var name = ""
    
    //Combine publishers into single stream
    private var validToSubmit:AnyPublisher<Bool,Never>{
        return Publishers.CombineLatest3($acceptedTerms,$acceptedPrivacy,$name).map{ terms,privacy,name in
            return terms && privacy && !name.isEmpty
        }.eraseToAnyPublisher()
    }
    
    //Define subscriber
    private var buttonSubscriber:AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        //Hook subscriber up to publisher
        buttonSubscriber = validToSubmit
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: submitButton)
        
    }
    
    @IBAction func acceptTerms(_ sender: UISwitch) {
        acceptedTerms = sender.isOn
    }
    
    @IBAction func acceptPrivacy(_ sender: UISwitch) {
        acceptedPrivacy = sender.isOn
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        
        name = sender.text ?? ""
    }
}

extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
