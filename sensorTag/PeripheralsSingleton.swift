//
//  PeripheralSingleton.swift
//  sensorTag
//
//  Created by Cristiano Salla Lunardi on 9/4/18.
//  Copyright © 2018 Cristiano Salla Lunardi. All rights reserved.
//

import CoreBluetooth
import Foundation

class Peripherals: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
	
	static let shared = Peripherals()
	
	public var humString = "0"
	public var luzString = "0"
	public var temperatureImageString = "low-temperature"
	public var tempString = "0"
	public var lightImageString = "sun"
	public var giroStringY = "Y: 0"
	public var giroStringX = "X: 0"
	public var giroStringZ = "Z: 0"
	public var aceleStringY = "Y: 0"
	public var aceleStringX = "X: 0"
	public var aceleStringZ = "Z: 0"
	public var magnetStringY = "Y: 0"
	public var magnetStringX = "X: 0"
	public var magnetStringZ = "Z: 0"
	
	private var myPeripheral: CBPeripheral?
	private var centralManager: CBCentralManager
	
	private let svcHumidity = CBUUID(string: "F000AA20-0451-4000-B000-000000000000")
	private let svcTemperature = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")
	private let svcLight = CBUUID(string: "F000AA70-0451-4000-B000-000000000000")
	private let svcAccelerometer = CBUUID(string: "F000AA10-0451-4000-B000-000000000000")
	private let svcBarometer = CBUUID(string: "F000AA40-0451-4000-B000-000000000000")
	private let svcMovement = CBUUID(string: "F000AA80-0451-4000-B000-000000000000")
	private let svcMagnetometer = CBUUID(string: "F000AA30-0451-4000-B000-000000000000")
	private let temperData = CBUUID(string: "F000AA01-0451-4000-B000-000000000000")
	private let temperConfig = CBUUID(string: "F000AA02-0451-4000-B000-000000000000")
	private let accelerometerData = CBUUID(string: "F000AA11-0451-4000-B000-000000000000")
	private let accelerometerConfig = CBUUID(string: "F000AA12-0451-4000-B000-000000000000")
	private let magnetometerData = CBUUID(string: "F000AA31-0451-4000-B000-000000000000")
	private let magnetometerConfig = CBUUID(string: "F000AA32-0451-4000-B000-000000000000")
	private let barometerData = CBUUID(string: "F000AA41-0451-4000-B000-000000000000")
	private let barometerConfig = CBUUID(string: "F000AA42-0451-4000-B000-000000000000")
	private let movementData = CBUUID(string: "F000AA81-0451-4000-B000-000000000000")
	private let movementConfig = CBUUID(string: "F000AA82-0451-4000-B000-000000000000")
	private let movementPeriod = CBUUID(string: "F000AA83-0451-4000-B000-000000000000")
	private let charHumidityData = CBUUID(string: "F000AA21-0451-4000-B000-000000000000" )
	private let charHumidityConfig = CBUUID(string: "F000AA22-0451-4000-B000-000000000000")
	private let charLightConfig = CBUUID(string: "F000AA72-0451-4000-B000-000000000000")
	private let charLightData = CBUUID(string: "F000AA71-0451-4000-B000-000000000000")
    private let systemID = CBUUID(string: "F000AA64-0451-4000-B000-000000000000")
   // private let deviceInformation = CBUUID(string: "Device Information")

    
	var luz: Double = 0
	var umidVal: Double = 0
	var humTemp: [Double] = []
	var luminosidade: Double = 0.0
	var tempVal1: Double = 0
	var humVal1: Double = 0
	var xMagVal: Double = 0
	var yMagVal: Double = 0
	var zMagVal: Double = 0
	var dadosGiro: [Double] = []
	var dadosGiroY: Double = 0
	var dadosGiroX: Double = 0
	var dadosGiroZ: Double = 0
	var timerSelected: Double = 0.5
	var umidValC: Int = 0
	var tempVal: Double = 0
	var tempValC: Int = 0
	var accXDouble: Double = 0
	var accYDouble: Double = 0
	var accZDouble: Double = 0
	
	private override init() {
		centralManager = CBCentralManager()
		super.init()
		centralManager.delegate = self
	}
	
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		if central.state == CBManagerState.poweredOn {
			central.scanForPeripherals(withServices: nil, options: nil)
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		
		if peripheral.name?.contains("SensorTag") == true {
			centralManager.stopScan()
			central.connect(peripheral, options: nil)
			myPeripheral = peripheral
		}
		
	}
	
	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		central.scanForPeripherals(withServices: nil, options: nil)
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		peripheral.discoverServices(nil)
		peripheral.delegate = self
	}
	
    let count = 0
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		if let services = peripheral.services {
			for svc in services {
                if count == 0{
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
				if svc.uuid == svcLight {
					peripheral.discoverCharacteristics(nil, for: svc)
				}
				if svc.uuid == svcHumidity{
					peripheral.discoverCharacteristics(nil, for: svc)
				}
				if svc.uuid == svcBarometer{
					peripheral.discoverCharacteristics(nil, for: svc)
				}
				if svc.uuid == svcMovement{
					peripheral.discoverCharacteristics(nil, for: svc)
				}
				if svc.uuid == svcTemperature{
					peripheral.discoverCharacteristics(nil, for: svc)
                    
				}
                
                if svc.uuid == systemID {
                    peripheral.discoverCharacteristics(nil, for: svc)
                    print("HIEFEJJEIFJEIFJIEJFIJEIJFIEJFIEJFIJE")
                    //Service AA64
                    print(systemID)
                    //systemID.
                    print("HIEFEJJEIFJEIFJIEJFIJEIJFIEJFIEJFIJE")
                }
//                if svc.uuid == CBUUID(string: "0x180A"){
//                    peripheral.discoverCharacteristics(nil, for: svc)
//
//                }
                count == count + 1
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if service.uuid.uuidString == "0x180A" && service.characteristics![0].uuid.uuidString != "05b23a00002d0798"
//        {
//            centralManager.cancelPeripheralConnection(myPeripheral!)
//            centralManager.scanForPeripherals(withServices: nil, options: nil)
//        } else {
        
		if let chars = service.characteristics {
			for char in chars {
                //if char.uuid == 
				if char.uuid == charHumidityConfig {
					if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse){
						peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
					} else {
						peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
					}
				}
				else if char.uuid == charHumidityData{
					checkHumidity(curChar: char)
				}
					
					//TEMPERATURA
				else if char.uuid == temperConfig {
					if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
						peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
					} else {
						peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
					}
				}
					//GIROSCOPIO
				else if char.uuid == movementConfig{
					
					// FF - with WOM
					// 7F - all sensors on, 03 - 16 G
					let bytes : [UInt8] = [ 0x7F, 0x03 ]
					let data = Data(bytes:bytes)
					
					peripheral.writeValue(data, for: char, type: CBCharacteristicWriteType.withResponse)
				}
				else if char.uuid == movementPeriod {
					let currentPeriod: UInt8 = 0
					let bytes : [UInt8] = [ currentPeriod ]
					let data = Data(bytes:bytes)
					peripheral.writeValue(data, for: char, type: CBCharacteristicWriteType.withResponse)
				}
				else if char.uuid == movementData{
					checkMovement(curChar: char)
				}
					//BAROMETRO
				else if char.uuid == barometerData{
					if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
						peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
					} else {
						peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
					}
				}
					//LUZ
				else if char.uuid == charLightConfig {
					if char.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
						peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withoutResponse)
					} else {
						peripheral.writeValue(Data.init(bytes: [01]), for: char, type: CBCharacteristicWriteType.withResponse)
					}
				}
				else if char.uuid == charLightData {
					checkLight(curChar: char)
                    //print("jidjsajdijsadjaisdiajsidjaisdajds")
				}
//                else if char.uuid == systemID{
//                    print("HHHHHHHIIIIII")
//                }
			}
		}
    }
	//}
	
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		
		if characteristic.uuid == charHumidityData {
			_ = getRelativeHumidity(value: characteristic.value! as NSData)
			for _ in humTemp{
				//Para ficar com duas casa decimais
				if umidVal < 110.00 && umidVal > 0{
					
					let umidVal111: String = String(format: "%.2f", umidVal)
					//send to viewController
					humString = String("\(umidVal111)%rH")
				}
				if tempVal1 != -50 {
					let tempVal11: String = String(format: "%.2f",tempVal1)
					tempString = String(" \(tempVal11) °C")
				}
				if tempVal1 > 24{
					temperatureImageString = "high-temperature"
				}else if tempVal1 <= 24 {
					temperatureImageString =  "low-temperature"
				}
			}
		}
		
		//luzString = String(luxConvert(value: (characteristic.value! as NSData)as Data))
		
		if characteristic.uuid == charLightData {
			
			let luxVal = luxConvert(value: (characteristic.value! as NSData) as Data)
			
			//var baseLuz = pickerLuz
			luminosidade = Double(luxVal)
			
			luzString = String(format: "%.0f", luxVal)
			
			if luxVal > 40 {
				//TODO
				// parar trem
				//trainHorn.stop()
				lightImageString = "sun"
				luz = luxVal
			} else{
				//TODO
				// play trem
				//trainHorn.play()
				lightImageString = "cloudy (1)"
				luz = luxVal
			}
		}
			
			
			
		else if characteristic.uuid == movementData {
			
			let dataLength = characteristic.value!.count / MemoryLayout<Int16>.size
			var dataArray = [Int16](repeating: 0, count: dataLength)
			(characteristic.value! as NSData).getBytes(&dataArray, length: dataLength * MemoryLayout<Int16>.size)
			
			let date = Date()
			let calendar = Calendar.current
			let dataFromSensor = Utils.shared.dataToSignedBytes16(value: (characteristic.value as NSData?)!)
			
			let rawGyroX:Int16 = dataFromSensor[0]
			let GyroX = Float(rawGyroX) / (65536 / 500)
			let gyroXConv = Int(GyroX)
			giroStringX = String("X: \(gyroXConv)")
			dadosGiroX = Double(GyroX)
			
			let rawGyroY:Int16 = dataFromSensor[1]
			let GyroY = Float(rawGyroY) / (65536 / 500)
			let gyroYConv = Int(GyroY)
			giroStringY = String("Y: \(gyroYConv)")
			dadosGiroY = Double(GyroY)
			
			let rawGyroZ:Int16 = dataFromSensor[2]
			let GyroZ = Float(rawGyroZ) / (65536 / 500);
			let gyroZConv = Int(GyroZ)
			giroStringZ = String("Z: \(gyroZConv)")
			dadosGiroZ = Double(GyroZ)
			
			
			let rawAccX:Int16 = dataFromSensor[3]
			let AccX = Float(rawAccX) / (32768/16)
			accXDouble = Double(AccX)
			let accXConv = Int(AccX)
			aceleStringX = String("X: \(accXConv)")
			//DOUBLE:
			//aceleLblX.text = String("\(AccX)")
			
			let rawAccY:Int16 = dataFromSensor[4]
			let AccY = Float(rawAccY) / (32768/16)
			accYDouble = Double(AccY)
			let accYConv = Int(AccY)
			aceleStringY = String("Y: \(accYConv)")
			//aceleLblY.text = String("\(AccY)")
			
			let rawAccZ:Int16 = dataFromSensor[5]
			let AccZ = Float(rawAccZ) / (32768/16)
			accZDouble = Double(AccZ)
			let accZConv = Int(AccZ)
			aceleStringZ = String("Z: \(accZConv)")
			//aceleLblZ.text = String("\(AccZ)")
			
			let rawMagX:Int16 = dataFromSensor[6]
			let MagX = Float(rawMagX)
			let magXConv = Int(MagX)
			magnetStringX = String("X: \(magXConv)")
			xMagVal = Double(MagX)
			
			let rawMagY:Int16 = dataFromSensor[7]
			let MagY = Float(rawMagY)
			let magYConv = Int(MagY)
			magnetStringY = String("Y: \(magYConv)")
			yMagVal = Double(MagY)
			
			
			let rawMagZ:Int16 = dataFromSensor[8]
			let MagZ = Float(rawMagZ)
			let magZConv = Int(MagZ)
			magnetStringZ = String("Z: \(magZConv)")
			zMagVal = Double(MagZ)
		}
		
	}
	
	func checkLight(curChar : CBCharacteristic) {
		Timer.scheduledTimer(withTimeInterval: timerSelected, repeats: true) { (timer) in
			self.myPeripheral!.readValue(for: curChar)
		}
	}
	
	func checkMovement(curChar : CBCharacteristic){
		Timer.scheduledTimer(withTimeInterval: timerSelected, repeats: true) { (timer) in
			self.myPeripheral!.readValue(for: curChar)
		}
	}
	
	func checkHumidity(curChar : CBCharacteristic){
		Timer.scheduledTimer(withTimeInterval: timerSelected, repeats: true) { (timer) in
			//self.postando(mensagem: self.jsonIoT(typeM: 0))
			self.myPeripheral!.readValue(for: curChar)
		}
		
		Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
//			self.postOData(odataModel:  self.json(typeM: 1))
//			self.postando(mensagem: self.jsonIoT(typeM: 1))
		}
	}
	
	func getRelativeHumidity(value: NSData) -> [Double] {
		let dataFromSensor = Utils.shared.dataToUnsignedBytes16(value: value)
		let humidity = Double(-6 + 125/65536 * Double(dataFromSensor[1]))
		let temperature = Double(-40 + ((165  * Double(dataFromSensor[0])) / 65536.0))
		
		humTemp = [humidity, temperature]
		umidVal = humTemp[0]
		if umidVal < 100.00{
			umidValC = Int(humTemp[0])
		}
		//Para evitar o -40
		tempVal = humTemp[1]
		if tempVal > 0{
			tempVal1 = tempVal
		}
		tempValC = Int(humTemp[1])
		
		return humTemp
		
	}
	
	func getGyroscopeData(value: NSData) -> [Double] {
		let dataFromSensor = Utils.shared.dataToSignedBytes16(value: value)
		let yVal = Double(dataFromSensor[0]) * 500 / 65536 * -1
		let xVal = Double(dataFromSensor[1]) * 500 / 65536
		let zVal = Double(dataFromSensor[2]) * 500 / 65536
		dadosGiro = [yVal, xVal, zVal]
		
		return [xVal, yVal, zVal]
	}
	
	func luxConvert(value : Data) -> Double {
		let rawData = Utils.shared.dataToUnsignedBytes16(value: value)
		var e :UInt16 = 0
		var m :UInt16 = 0
		
		m = rawData[0] & 0x0FFF;
		e = (rawData[0] & 0xF000) >> 12;
		
		/** e on 4 bits stored in a 16 bit unsigned => it can store 2 << (e - 1) with e < 16 */
		e = (e == 0) ? 1 : 2 << (e - 1);
		
		return Double(m) * (0.01 * Double(e));
	}

	func getMagnetometerData(value: NSData) -> [Double] {
		let dataFromSensor = Utils.shared.dataToSignedBytes16(value: value)
		let xVal = Double(dataFromSensor[0]) * 2000 / 65536 * -1
		let yVal = Double(dataFromSensor[1]) * 2000 / 65536 * -1
		let zVal = Double(dataFromSensor[2]) * 2000 / 65536
		
		return [xVal, yVal, zVal]
	}

	
}
