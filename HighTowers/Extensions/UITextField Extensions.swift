//
//  UITextField Extensions.swift
//  GPSValidation
//
//  Created by Greg Durfee on 7/5/19.
//  Copyright © 2019 Durfee's Sandbox. All rights reserved.
//

import UIKit.UITextField

extension UITextField {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text!)
    }
}
