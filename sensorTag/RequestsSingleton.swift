//
//  RequestsSingleton.swift
//  sensorTag
//
//  Created by Cristiano Salla Lunardi on 9/4/18.
//  Copyright © 2018 Cristiano Salla Lunardi. All rights reserved.
//

import Foundation

class Requests: NSObject, URLSessionDelegate {
	
	static let shared = Requests()
	public var luzString = ""
	private override init() {
		
	}
	
	/* Request post SMS */
	func requestForSms(id: String, luxometer: Double, limit: Double, date: String, phoneNumber: String) {
		let smsModel = ["message" : "Atenção: O sensor \(id) atingiu uma luminosidade de \(luxometer), abaixo do limite de \(limit) em \(date)", "binary" : false, "destinations" : [phoneNumber]] as [String : Any]
		
		var request = URLRequest(url: URL(string: "https://sandbox.api.sap.com/proximusenco/sms/outboundmessages")!)
		
		let jsonData = try? JSONSerialization.data(withJSONObject: smsModel, options: [])
		request.httpBody = jsonData
		request.httpMethod = "POST"
		request.addValue("AFIuGXcXABO3I48KtPbeS2WGeGLz1bAk", forHTTPHeaderField: "APIKey")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let session = URLSession.shared
		
		let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
			if (error != nil) {
			} else {
				//let httpResponse = response as? HTTPURLResponse
				//TODO
				//phonenumber to 0
				//self.phoneNumber = ""
			}
		})
		dataTask.resume()
	}
	
	/* Request post oData */
	func postOData(typeM: Int) {
        
		let odataModel = jsonOData(typeM: typeM)
		guard let jsonData = try? JSONSerialization.data(withJSONObject: odataModel, options: .prettyPrinted) else { return }
		let url = URL(string: "http://fioris4.itsgroup.com.br:44310/sap/opu/odata/sap/EAM_NTF_CREATE/NotificationHeaderSet")!
		//let url = URL(string: "http://s4srv01.itspoa.com:44310/sap/opu/odata/sap/EAM_NTF_CREATE/NotificationHeaderSet")!
		let username = "SAPFORUM"
		let password = "its@2018"
		let loginString = String(format: "%@:%@", username, password)
		let loginData = loginString.data(using: String.Encoding.utf8)!
		let base64LoginString = loginData.base64EncodedString()
		
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
		request.addValue("130", forHTTPHeaderField: "sap-client")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Fetch", forHTTPHeaderField: "x-csrf-token")
		
		
		_ = URLSessionConfiguration.default
		let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
		
		let task = session.dataTask(with: request) { (data, response, error) in
			
			if error == nil {
				
				guard let umaResposta = response as? HTTPURLResponse else {return}
				
				if umaResposta.statusCode == 200 {
					
					let aa = umaResposta.allHeaderFields
					_ = aa.index(forKey: "Set-Cookie")
					let cc = aa.index(forKey: "x-csrf-token")
					let token  = "\(aa.values[cc!])"
					let jar = HTTPCookieStorage.shared
					let cookieHeaderField = ["Set-Cookie" : "key=value, key2=value2"]
					let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
					jar.setCookies(cookies, for: url, mainDocumentURL: url)
					let cookie = jar.cookies
					
					request.url = url
					request.httpMethod = "POST"
					request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
					request.setValue("130", forHTTPHeaderField: "sap-client")
					request.setValue("application/json", forHTTPHeaderField: "Content-Type")
					request.setValue(token, forHTTPHeaderField: "x-csrf-token")
					request.setValue("\(cookie)", forHTTPHeaderField: "Cookie")
					request.httpBody = jsonData
					
					let task2 = session.dataTask(with: request) { data, response, error in
						if error == nil {
							
							guard let result = response as? HTTPURLResponse else {return}
							
							if result.statusCode == 201 {
								
								let location = result.allHeaderFields
								let searchLocation = location.index(forKey: "Location")
								let getLocation = "\(location.values[searchLocation!])"
								let notificationHeaderSet = getLocation.components(separatedBy: ["(",")"])
								
								let notification = notificationHeaderSet[1]
								var notificationNumber = ""
								notificationNumber = notification.components(separatedBy: ["'", "'"])[1]
								print(notification)
								
								let url2 = URL(string: "http://fioris4.itsgroup.com.br:44310/sap/opu/odata/sap/EAM_NTF_CREATE/LongTextSet(NotificationNumber=\(notificationHeaderSet[1]),ObjectKey='00000001')")!
								
								let odataModel2 : [String : Any ] = [
									"NotificationNumber": "\(notificationNumber)",
									"ObjectKey": "00000000",
									"UpdateText": "Acesse o endereço abaixo para obter apoio na identificação do problema: \nhttps://intranet.itsgroup.com.br/download/ITS_Chatbot.html",
									"IsHistorical": true
								]
								
								guard let jsonData2 = try? JSONSerialization.data(withJSONObject: odataModel2, options: .prettyPrinted) else { return }
								
								var request2 = URLRequest(url: url2)
								request2.httpMethod = "PUT"
								request2.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
								request2.setValue("130", forHTTPHeaderField: "sap-client")
								request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
								request2.setValue(token, forHTTPHeaderField: "x-csrf-token")
								request2.setValue("\(cookie)", forHTTPHeaderField: "Cookie")
								request2.httpBody = jsonData2
								
								let task3 = session.dataTask(with: request2) { dados, resposta, erro in
									print(dados)
									print(resposta)
									print(erro)
								}
								task3.resume()
							}
						}
					}
					task2.resume()
				}
			}
		}
		task.resume()
	}
	
	/* json format for post oData */
	private func jsonOData(typeM: Int) -> [String : Any] {
        
		let date = Utils.shared.ISOStringFromDateOdata(date: Date())
		var shortText = ""
		var location = ""
		var notificationType = ""
		var effect = ""
        
		switch typeM {
		case 1:
			shortText = "Executar manutenção preventiva"
			effect = "\(typeM)"
			notificationType = "M\(typeM)"
		case 2:
			location = "Sistema de iluminação"
			shortText = "Falha sensor iluminação: \(self.luzString)"
			effect = "\(typeM)"
			notificationType = "M\(typeM)"
		case 3:
			shortText = "Falha no sistema-Ação imediata"
			effect = "\(typeM)"
			notificationType = "M\(typeM)"
		case 4:
			shortText = "Mais de 10 segundos"
			effect = "\(typeM)"
			notificationType = "M\(typeM)"
        case 99:
            shortText = "Testando P3"
        case 100:
            shortText = "Testando P4"
		default:
			break
		}
		
		let post : [String : Any ] = [ "UserCanBeNotified": false,
									   "ShortText": "\(shortText)",
									   "TecObjNoLeadingZeros": "000000000010000100",
									   "ReporterDisplay": "ITS_ALESSAND",
									   "TechnicalObjectType": "EAMS_EQUI",
									   "Effect": "\(effect)",
									   "NotificationTimestamp": "/Date(\(date))/",
                                       "TechnicalObjectNumber": "10000100",
                                       "TechnicalObjectDescription": "http://bit.do",
                                       "NotificationType": "\(notificationType)",
                                       "NotificationTypeText": "Maintenance Request",
                                       "Location": "\(location)",
                                       "Reporter": "ITS_ALESSAND",
                                       "Subscribed": false,
                                       "__metadata": [
                                       "type": "EAM_NTF_CREATE.NotificationHeader",
                                       "uri" : "/sap/opu/odata/sap/EAM_NTF_CREATE/NotificationHeaderSet" ]
                                     ]
		
		return post
		
	}
	
	
	/* Request post IoT */
	func postIot(typeM: Int?, point: Int?) {
		let mensagem = jsonIoT(typeM: typeM, point: point)
		let dadosIOT : [String : Any] = ["mode" : "sync", "messageType" : "eda3550e5d06b2210acd", "messages" : mensagem]
		
		guard let url = URL(string: "https://iotmmss0009452156trial.hanatrial.ondemand.com/com.sap.iotservices.mms/v1/api/http/data/ceb113b9-a0f0-43b7-849e-af98797fc344") else { return }
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer 3da6d1d4a6247b39f5a151353083117a", forHTTPHeaderField: "Authorization")
		request.addValue("charset=utf-8", forHTTPHeaderField: "Accept-Charset")
		
		guard let httpBody = try? JSONSerialization.data(withJSONObject: dadosIOT, options: []) else { return }
		request.httpBody = httpBody
		
		let session = URLSession.init(configuration: .default, delegate: self, delegateQueue: nil)
		session.dataTask(with: request) { (data, response, error) in
			if error == nil {
				guard let umaResposta = response as? HTTPURLResponse else {return}
				
				if umaResposta.statusCode == 200 {
					
				}
			}
			}.resume()
	}
	
	/* JSON format for IOT Post */
	private func jsonIoT(typeM: Int?, point: Int?) -> [[String : Any]]{
		let sensorData = Peripherals.shared
		
		let timestamp: String = Utils.shared.ISOStringFromDate(date: Date())
		let temperature = sensorData.tempVal1
		let humidity = sensorData.umidVal
		let gyro_x = sensorData.dadosGiroX
		let gyro_y = sensorData.dadosGiroY
		let gyro_z = sensorData.dadosGiroZ
		let magnetometer_x: Double = sensorData.xMagVal
		let magnetometer_y: Double = sensorData.yMagVal
		let magnetometer_z: Double = sensorData.zMagVal
		let accelerometer_x1: Double = sensorData.accXDouble
		let accelerometer_y1: Double = sensorData.accYDouble
		let accelerometer_z1: Double = sensorData.accZDouble
		let lightness: Double = sensorData.luminosidade
		
		var serialNumber = ""
        
		var deviceName = ""
		
		if let type = typeM {
			deviceName = "M\(type)"
		}
		
		if let p = point {
			switch p {
			case 1:
                serialNumber = "P1"
			case 2:
				serialNumber = "P2"
			case 3:
				serialNumber = "P3"
			case 4:
				serialNumber = "P4"
			default:
				break
			}
		}
		
	
		let message : [[String : Any ]] = [[
			"timestamp" : timestamp,
			"temperature" : temperature,
			"humidity" : humidity,
			"pressure" : 0,
			"giro_x" : gyro_x,
			"giro_y" : gyro_y,
			"giro_z" : gyro_z,
			"battery_level" : 0,
			"system_id" : "54:6c:0e:00:00:53:02:cc",
			"magnetometer_x" : magnetometer_x,
			"magnetometer_y" : magnetometer_y,
			"magnetometer_z" : magnetometer_z,
			"accelerometer_x" : accelerometer_x1,
			"accelerometer_y" : accelerometer_y1,
			"accelerometer_z" : accelerometer_z1,
			"serial_number" : "\(serialNumber)",
			"distance" : 0,
			"lightness" : lightness,
			"device_name" : "\(deviceName)"
			]]
		
		return message
		
	}
	
	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		if challenge.previousFailureCount > 0 {
			completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
		} else if let serverTrust = challenge.protectionSpace.serverTrust {
			completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
		} else {
			_ = challenge.protectionSpace.authenticationMethod
			let username = "its_alessand"
			let password = "Apr@2018"
			let credentialOrNil = URLCredential(user: username, password: password, persistence: .forSession)
			let credential = credentialOrNil
			
			completionHandler(.useCredential, credential)
		}
	}
}
