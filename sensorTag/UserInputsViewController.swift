//
//  UserInputsViewController.swift
//  sensorTag
//
//  Created by Cristiano Salla Lunardi on 8/21/18.
//  Copyright © 2018 Cristiano Salla Lunardi. All rights reserved.
//

import UIKit
import Foundation

class UserInputsViewController: UIViewController, UITextFieldDelegate {
	
    // MARK: - Outlets
	@IBOutlet private(set) weak var sensorID: UITextField!
	@IBOutlet private weak var phoneNumber: UITextField!
	@IBOutlet private weak var lumosLabel: UILabel!
	@IBOutlet private weak var timeScan: UILabel!
	@IBOutlet private(set) weak var luxometerSensor: UISlider!
    @IBOutlet private(set) weak var timeScanSensor: UISlider!
	
	@IBOutlet weak var luxometerSensorMax: UISlider!
	
	@IBOutlet weak var luxometerSensorMaxLabel: UILabel!
	
	
	private(set) var numberToSend: String = ""
	private(set) var sensorId: String = ""
	
    var pickerID = UIPickerView()
    
    let ID : [String] = ["7DEA0E803AE56248DD446ED034ED6A54", "0CCFA24145CB6E9CDB8BDF733C1D4D8D",
                         "DA7AF105D92DF861C1477E84698F892C", "3351AD491DF7B763F523652538F3196D",
                         "E3EF47E1CAF04B95A4814BDD080B1BBA"]
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        pickerID.delegate = self
        pickerID.dataSource = self
        sensorID.inputView = pickerID
		self.phoneNumber.delegate = self
		self.sensorID.delegate = self
		self.lumosLabel.text = String (Int(self.luxometerSensor.value * 500)) + " lm"
		let phoneNumber = verifyValidPhoneNumber(number: "")
		print(phoneNumber)
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
    
    //Limpa o campo número de celular
    override func viewWillAppear(_ animated: Bool) {
        phoneNumber.text = ""
        numberToSend = ""
    }
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		if textField == self.phoneNumber {
			self.numberToSend = "+55" + (textField.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
		} else if textField == self.sensorID {
			self.sensorId = (textField.text?.components(separatedBy: CharacterSet.alphanumerics.inverted).joined())!
		}
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == self.phoneNumber {
			textField.text = verifyValidPhoneNumber(number: textField.text!)
		} else if textField == self.sensorID {
			textField.text = verifyValidSensorId(id: textField.text!)
		}
		return true
	}
	
	func verifyValidSensorId (id: String) -> String {
		let cleanSensorId = id.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
		var mask = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
		var result = ""
		var index = cleanSensorId.startIndex
		for ch in mask.characters {
			if index == cleanSensorId.endIndex {
				break
			}
			if ch == "X" {
				result.append(cleanSensorId[index])
				index = cleanSensorId.index(after: index)
			} else {
				result.append(ch)
			}
		}
		return result
	}
	
	func verifyValidPhoneNumber (number: String) -> String {
		let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
		var mask = "(XX) X XXXX-XXXX"
		var result = ""
		var index = cleanPhoneNumber.startIndex
		for ch in mask.characters {
			if index == cleanPhoneNumber.endIndex {
				break
			}
			if ch == "X" {
				result.append(cleanPhoneNumber[index])
				index = cleanPhoneNumber.index(after: index)
			} else {
				result.append(ch)
			}
		}
		return result
	}
	
    // MARK: - Actions
	@IBAction func lumosSlider(_ sender: Any) {
		self.lumosLabel.text = String (Int(self.luxometerSensor.value * 500)) + " lm"
	}
	
    @IBAction func timeScanSlider(_ sender: Any) {
        self.timeScan.text = String (Int(self.timeScanSensor.value * 10)) + " s"
    }
	
	@IBAction func lumosMaxSlider(_ sender: Any) {
		self.luxometerSensorMaxLabel.text = String (Int(self.luxometerSensorMax.value * 10000)) + " lm"
	}
	
	
	@objc
	func dismissKeyboard() {
		view.endEditing(true)
	}
}


// MARK: - Picker ID do Sensor
extension UserInputsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ID[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ID.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let formatID = verifyValidSensorId(id: ID[row])
        sensorID.text = formatID
    }
}
