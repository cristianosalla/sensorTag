//
//  Utils.swift
//  sensorTag
//
//  Created by Cristiano Salla Lunardi on 9/4/18.
//  Copyright © 2018 Cristiano Salla Lunardi. All rights reserved.
//

import Foundation

class Utils {
	
	static let shared = Utils()
	
	private init(){
		
	}
	
	/* String from date */
	func ISOStringFromDate(date: Date) -> String {
		let timezone = "UTC"
		let locale = "pt_BR_POSIX"
		let dateFormatter = DateFormatter()
		dateFormatter.locale = NSLocale(localeIdentifier: locale) as Locale!
		dateFormatter.timeZone = NSTimeZone(abbreviation: timezone) as! TimeZone
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
		
		return dateFormatter.string(from: date as Date)
	}
	
	/* String from date post oData */
	func ISOStringFromDateOdata(date: Date) -> String {
		let timezone = "UTC"
		let locale = "pt_BR_POSIX"
		let dateFormatter = DateFormatter()
		dateFormatter.locale = NSLocale(localeIdentifier: locale) as Locale?
		dateFormatter.timeZone = NSTimeZone(abbreviation: timezone)! as TimeZone
		dateFormatter.dateFormat = "yyyyMMddTHHmmssSSS"
		
		return dateFormatter.string(from: date as Date)
	}
	
	func dataToUnsignedBytes16(value : Data) -> [UInt16] {
		let count = value.count
		var array = [UInt16](repeating: 0, count: count)
		(value as NSData).getBytes(&array, length:count * MemoryLayout<UInt16>.size)
		return array
	}
	
	func dataToSignedBytes16(value : NSData) -> [Int16] {
		let count = value.length
		var array = [Int16](repeating: 0, count: count)
		value.getBytes(&array, length:count * MemoryLayout<Int16>.size)
		return array
	}
	
	func dataToUnsignedBytes16(value : NSData) -> [UInt16] {
		let count = value.length
		var array = [UInt16](repeating: 0, count: count)
		value.getBytes(&array, length:count * MemoryLayout<UInt16>.size)
		return array
	}
	
	func dataToSignedBytes8(value : NSData) -> [Int8] {
		let count = value.length
		var array = [Int8](repeating: 0, count: count)
		value.getBytes(&array, length:count * MemoryLayout<Int8>.size)
		return array
	}
	
}
