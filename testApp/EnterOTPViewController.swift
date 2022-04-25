//
//  EnterOTPViewController.swift
//  testApp
//
//  Created by Rutwik Shinde on 17/04/22.
//

import UIKit

class EnterOTPViewController: UIViewController {

    @IBOutlet weak var otpTextField: UITextField!
    
    @IBOutlet weak var resendLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var resendButton: UIButton!
    
    
    var otp : String?
    
    var timer = Timer()
    var timeLeft = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otpTextField.delegate = self
        otpTextField.layer.cornerRadius = 16
        otpTextField.setupGradientBorder(colors: [UIColor(red: 1, green: 0.075, blue: 0.63, alpha: 0.44).cgColor,UIColor(red: 0.075, green: 0.501, blue: 1, alpha: 0.44).cgColor], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 0.0), borderWidth: 3, locations: [0,1])
        
        otpTextField.defaultTextAttributes.updateValue(10, forKey: NSAttributedString.Key.kern)
        nextButton.layer.cornerRadius = 20
        
        addGradientToBtn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
        otpTextField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerChanged), userInfo: nil, repeats: true)
        resendButton.isHidden = true
        resendLabel.text = "Resend code in 00:\(timeLeft)"
    }
    
    func addGradientToBtn() {
        nextButton.setupGradientBorder(colors: [UIColor(red: 1, green: 0.075, blue: 0.63, alpha: 0.36).cgColor,UIColor(red: 0.075, green: 0.501, blue: 1, alpha: 0.36).cgColor], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 0.0), borderWidth: 3, locations: [0,1])
        nextButton.setupGradientBackground(colors: [UIColor(red: 1, green: 0.075, blue: 0.63, alpha: 0.44).cgColor,UIColor(red: 0.075, green: 0.501, blue: 1, alpha: 0.44).cgColor], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 0.0))
        nextButton.setTitle("Next", for: .selected)
        nextButton.setTitle("Next", for: .disabled)
        nextButton.setTitleColor(.white, for: .selected)
        nextButton.setTitleColor(.gray, for: .disabled)    }
    
    
    @objc func timerChanged() {
        timeLeft -= 1
        if timeLeft < 0 {
            timer.invalidate()
            resendButton.isHidden = false
            resendLabel.isHidden = true
        } else {
            resendLabel.text = "Resend code in 00:\(timeLeft)"
        }
        
        
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        otpTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               // if keyboard size is not available for some reason, dont do anything
               return
            }
          
          // move the root view up by the distance of keyboard height
          self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 6 {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        if otpTextField.text == otp {
            self.modalPresentationStyle = .fullScreen
            self.present(FinalViewController(), animated: true)
        } else {
            let alert = UIAlertController(title: "Incorrect OTP", message: "Please try again with correct OTP", preferredStyle: .alert)
            self.present(alert, animated: false, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension EnterOTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 6
    }
    
    
}
