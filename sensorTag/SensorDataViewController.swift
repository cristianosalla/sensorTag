//
//  SensorDataViewController.swift
//  sensorTag
//
//  Created by Cristiano Salla Lunardi on 8/22/18.
//  Copyright © 2018 Cristiano Salla Lunardi. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class SensorDataViewController: UIViewController {
	
	// MARK: - Outlets
	
	@IBOutlet weak var luzLbl: UILabel!
	@IBOutlet weak var lblHum: UILabel!
	@IBOutlet weak var tmpLbl: UILabel!
	@IBOutlet weak var giroLblY: UILabel!
	@IBOutlet weak var giroLblX: UILabel!
	@IBOutlet weak var giroLblZ: UILabel!
	@IBOutlet weak var aceleLblY: UILabel!
	@IBOutlet weak var aceleLblX: UILabel!
	@IBOutlet weak var aceleLblZ: UILabel!
	@IBOutlet weak var magnetLblY: UILabel!
	@IBOutlet weak var magnetLblX: UILabel!
	@IBOutlet weak var magnetLblZ: UILabel!
	@IBOutlet weak var luzImg: UIImageView!
	@IBOutlet weak var umidImg: UIImageView!
	@IBOutlet weak var tempImg: UIImageView!
	
	// MARK: - Variables
	
	let systemSoundIDVibrate: SystemSoundID = 4095
	var trainHorn: AVAudioPlayer = AVAudioPlayer()
	var currentPeriod: UInt8 = 0
	var luz: Double = 0
    var luzString = ""
	var hum: Double = 0
	var lastMessage: CFAbsoluteTime = 0
	var humTemp: [Double] = []
	var second: [Double] = []
	var umidVal: Double = 0
	var umidValC: Int = 0
	var tempVal: Double = 0
	var tempValC: Int = 0
	var timePicker = UIPickerView()
	var time : [String] = ["1.0","2.0","3.0","4.0","5.0"]
	var pickerSelecionado: Double = 0.5
	var sensorPicker = UIPickerView()
	var sensores : [String] = ["sensor1", "sensor2", "sensor3"]
	
	private var phoneNumber: String = ""
	private var sensorId: String = ""
	private var lumosMinimumValue: Int = 10000
	private var lumosMaxValue: Int = 10000
	private var timeScan: Int = 1
	
	private var timerToUpdateUI = Timer()
	
	private var seconds = 0
	private var isValidTimer = false
	private var timer = Timer()
	private var lastLuminosidade : Int?
	private var isValidToSendPostM1Iot = false
	private var isValidToSendPostM3Iot = false
	private var isValidToSendPostM2Iot = false
	private var isValidToSendPostM4Iot = false
	
	private var iotSecondsM3 = 0
	private var isValidTimerIotM3 = false
	private var secondsM1 = 0
	private var isValidTimerM1 = false
    private var isValidM2IOT = true
	
	private var oDataSeconds = 0
	private var isValidM1s4 = false
	private var isValidM2s4 = false
    
	private var isValidTimerM3s4 = false
	private var isValidM4s4 = false
	private var isValidSendM3s4 = false
	
	private var lastP = ""
	
    var p1 = false
    var p2 = false
    var p3 = false
	
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let trainHornURL = Bundle.main.path(forResource: "TRAIN Sound Effects - Steam Train Start and Whistle", ofType: ".mp3")
		
		do {
			try trainHorn = AVAudioPlayer(contentsOf: URL (fileURLWithPath: trainHornURL!))
		} catch {
		
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		
		timerToUpdateUI = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: true)
		
		_ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerPost), userInfo: nil, repeats: true)
		
		if let userInputsVC = tabBarController?.viewControllers![1] as? UserInputsViewController {
			self.phoneNumber = userInputsVC.numberToSend
			if userInputsVC.sensorID != nil {
				self.sensorId = userInputsVC.sensorID.text!
			}
			if userInputsVC.luxometerSensor != nil && userInputsVC.timeScanSensor != nil {
				self.lumosMinimumValue = Int(userInputsVC.luxometerSensor.value * 500)
				self.lumosMaxValue = Int(userInputsVC.luxometerSensorMax.value * 5000)
				self.timeScan = Int(userInputsVC.timeScanSensor.value * 10)
			}
		}
	}
	
	@objc func updateUI() {
        
		let peripheralData = Peripherals.shared
		luzLbl.text = peripheralData.luzString
		lblHum.text = peripheralData.humString
		tmpLbl.text = peripheralData.tempString
		tempImg.image = UIImage.init(named: peripheralData.temperatureImageString)
		giroLblX.text = peripheralData.giroStringX
		giroLblY.text = peripheralData.giroStringY
		giroLblZ.text = peripheralData.giroStringZ
		aceleLblX.text = peripheralData.aceleStringX
		aceleLblY.text = peripheralData.aceleStringY
		aceleLblZ.text = peripheralData.aceleStringZ
		magnetLblX.text = peripheralData.magnetStringX
		magnetLblY.text = peripheralData.magnetStringY
		magnetLblZ.text = peripheralData.magnetStringZ
		
		if let luminosidade = Int(luzLbl.text!) {
            Requests.shared.luzString = String(luminosidade)
			sendPostIot(luminosidade: luminosidade)
			sendPostOData(luminosidade: luminosidade)
		}
		
	}
	
	/* enviar post iot*/
	func sendPostIot(luminosidade: Int) {
        
		let post = Requests.shared
		
		if isValidTimerM1 {
			isValidTimerM1 = false
			isValidTimerIotM3 = false
			iotSecondsM3 = 0
			//post.postIot(typeM: 1)
			post.postIot(typeM: nil, point: nil)
		}
		
		if luminosidade < lumosMinimumValue {
			if lastP == "P3" {
				post.postIot(typeM: nil, point: 4)
				lastP = "P4"
			} else {
                //if isValidM2IOT {
                    post.postIot(typeM: 2, point: 2)
                    lastP = "P2"
                    isValidM2IOT = false
                //}
//				p2 = true
                if iotSecondsM3 == 0 {
                    isValidTimerIotM3 = true
                } else if iotSecondsM3 >= 10 {
                    //post.postIot(typeM: 3)
                    post.postIot(typeM: 3, point: nil)
                    isValidTimerIotM3 = false
                    iotSecondsM3 = 0
                    isValidM2IOT = true
                }
			}
		} else if luminosidade > 5000 {
			isValidTimerIotM3 = false
			iotSecondsM3 = 0
			//post.postIot(typeM: 4)
			post.postIot(typeM: nil, point: 3)
			lastP = "P3"
            p1 = true
            
		} else if luminosidade > lumosMaxValue {
			//post.postIot(typeM: 100)
			post.postIot(typeM: 4, point: 1)
			lastP = "P1"
            isValidM2IOT = true
		} else {
			isValidTimerIotM3 = false
			iotSecondsM3 = 0
			post.postIot(typeM: nil, point: nil)
		}
	}
	
	func sendPostOData(luminosidade: Int) {
		
		let post = Requests.shared
		
		let date = Date()
		let calendar = Calendar.current
		let minutes = calendar.component(.minute, from: date)
		let second = calendar.component(.second, from: date)
        
		if minutes == 0 && second == 0 || minutes == 15 && second == 0 || minutes == 30 && second == 0 || minutes == 45 && second == 0 {
			post.postOData(typeM: 1)
			post.postIot(typeM: 1, point: nil)
		}
//		if isValidTimerM1 {
//			post.postOData(typeM: 1)
//			post.postIot(typeM: 1, point: nil)
//		}
		if luminosidade < lumosMinimumValue {
			var temporaryPhone = self.phoneNumber
			self.phoneNumber = ""
			if temporaryPhone != "" {
				post.requestForSms(id: self.sensorId, luxometer: Double(luminosidade), limit: Double(self.lumosMinimumValue), date: String(describing: Date().description(with: Locale.autoupdatingCurrent)), phoneNumber: temporaryPhone)
			}
			
			isValidTimerM3s4 = true
			isValidM4s4 = false
			if isValidM2s4 {
				isValidM2s4 = false
				post.postOData(typeM: 2)
				post.postIot(typeM: 2, point: nil)
				oDataSeconds = 0
			}
			
			if oDataSeconds >= 10 && isValidSendM3s4 {
				isValidSendM3s4 = false
				oDataSeconds = 0
				post.postOData(typeM: 3)
				post.postIot(typeM: 3, point: nil)
			}
		} else if luminosidade > lumosMaxValue {
			isValidTimerM3s4 = false
			isValidSendM3s4 = false
			isValidM2s4 = false
			if isValidM4s4 {
				isValidM4s4 = false
				post.postOData(typeM: 4)
			}
		} else {
			isValidTimerM3s4 = false
			isValidSendM3s4 = true
			isValidM2s4 = true
			isValidM4s4 = true
		}
	}
	
	@objc func updateTimerPost(){
		if isValidTimerIotM3 {
			iotSecondsM3 += 1
		}
		
		if isValidTimerM3s4 {
			oDataSeconds += 1
		}
		
		secondsM1 += 1
		if secondsM1 >= 900*2 {
			secondsM1 = 0
			isValidTimerM1 = true
		}
	}
}
