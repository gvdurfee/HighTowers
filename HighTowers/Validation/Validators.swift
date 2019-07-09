//
//  Validators.swift
//  GPSValidation
//
//  Created by Greg Durfee on 7/5/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

import Foundation

class ValidationError: Error {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidatorType {
    case latitudeDegrees
    case latitudeMinutes
    case longitudeDegrees
    case longitudeMinutes
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .latitudeDegrees: return LatitudeDegreesValidator()
        case .latitudeMinutes: return LatitudeMinutesValidator()
        case .longitudeDegrees: return LongitudeDegreesValidator()
        case .longitudeMinutes: return LongitudeMinutesValidator()
        
        }
    }
}

struct LatitudeDegreesValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^(1[7-9]|[2-6][0-9]|7[01])$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid Latitude Degrees Format. The number of degrees must be a whole number between 17 and 71.")
            }
        } catch {
            throw ValidationError("Invalid Latitude Degrees Format. The number of degrees must be a whole number between 17 and 71.")
        }
        return value
    }
    
}


struct LatitudeMinutesValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^[0-5]{1}[0-9]{1}[.][0-9]{1}[0-9]{1}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid Latitude Minutes Format. acceptable values are between 00.00 and 59.99")
            }
        } catch {
            throw ValidationError("Invalid Latitude Minutes Format. Acceptable values are between 00.00 and 59.99.")
        }
        return value
    }
    
}

struct LongitudeDegreesValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^(1[1-9]|[2-9][0-9]|1[0-6][0-9]|17[0-9])$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid Longitude Degrees Format. The number of degrees must be a whole number between 11 and 179.")
            }
        } catch {
            throw ValidationError("Invalid Longitude Degrees Format. The number of degrees must be a whole number between 11 and 179.")
        }
        return value
    }
    
}


struct LongitudeMinutesValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^[0-5]{1}[0-9]{1}[.][0-9]{1}[0-9]{1}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid Longitude Minutes Format. Acceptable values are between 00.00 and 59.99.")
            }
        } catch {
            throw ValidationError("Invalid Longitude Minutes Format. Acceptable values are between 00.00 and 59.99.")
        }
        return value
    }
    
}

