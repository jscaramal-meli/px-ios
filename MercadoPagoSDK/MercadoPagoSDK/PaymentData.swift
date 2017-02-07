//
//  PaymentData.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 2/1/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

public class PaymentData: NSObject {

    public var paymentMethod : PaymentMethod!
    public var issuer : Issuer?
    public var payerCost : PayerCost?
    public var token : Token?
    
    func clear() {
        self.paymentMethod = nil
        self.issuer = nil
        self.payerCost = nil
        self.token = nil
    }
    
    
    func complete() -> Bool {
        
        
        if paymentMethod == nil {
            return false
        }
        
        if paymentMethod!.isCard() && (token == nil || payerCost == nil) {
            return false
        }

        return true
    }
    
    func toJSONString() -> String {
        return JSONHandler.jsonCoding(toJSON())
    }
    
    func toJSON() -> [String:Any] {
       var obj:[String:Any] = [
            "payment_method_id" : String(describing: self.paymentMethod._id)
       ]
       
        obj["installments"] = (self.payerCost != nil ) ? self.payerCost!.installments : ""
        obj["card_token_id"] = (self.token != nil ) ? self.token!._id : ""
        obj["issuer_id"] = (self.issuer != nil ) ? self.issuer!._id : ""
        return obj
    }

}

