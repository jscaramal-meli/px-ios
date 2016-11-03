//
//  CongratsRevampViewController.swift
//  MercadoPagoSDK
//
//  Created by Eden Torres on 10/25/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class CongratsRevampViewController: MercadoPagoUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var bundle = MercadoPago.getBundle()
    var viewModel: CongratsViewModel!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60
        self.tableView.separatorStyle = .none
        
        self.viewModel.color = self.viewModel.getColor()
        
        var frame = self.tableView.bounds
        frame.origin.y = -frame.size.height;
        let view = UIView(frame: frame)
        view.backgroundColor = self.viewModel.color
        tableView.addSubview(view)
        
        let headerNib = UINib(nibName: "HeaderCongratsTableViewCell", bundle: self.bundle)
        self.tableView.register(headerNib, forCellReuseIdentifier: "headerNib")
        let emailNib = UINib(nibName: "ConfirmEmailTableViewCell", bundle: self.bundle)
        self.tableView.register(emailNib, forCellReuseIdentifier: "emailNib")
        let approvedNib = UINib(nibName: "ApprovedTableViewCell", bundle: self.bundle)
        self.tableView.register(approvedNib, forCellReuseIdentifier: "approvedNib")
        let rejectedNib = UINib(nibName: "RejectedTableViewCell", bundle: self.bundle)
        self.tableView.register(rejectedNib, forCellReuseIdentifier: "rejectedNib")
        let callFAuthNib = UINib(nibName: "CallForAuthTableViewCell", bundle: self.bundle)
        self.tableView.register(callFAuthNib, forCellReuseIdentifier: "callFAuthNib")
        let footerNib = UINib(nibName: "FooterTableViewCell", bundle: self.bundle)
        self.tableView.register(footerNib, forCellReuseIdentifier: "footerNib")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil && self.navigationController?.navigationBar != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            ViewUtils.addStatusBar(self.view, color: self.viewModel.color)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    init(payment: Payment?, paymentMethod : PaymentMethod?, callback : @escaping (_ payment : Payment, _ status : MPStepBuilder.CongratsState) -> Void){
        super.init(nibName: "CongratsRevampViewController", bundle : bundle)
        self.viewModel = CongratsViewModel(payment: payment, paymentMethod: paymentMethod, callback: callback)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideNavBar(){
        self.title = ""
        navigationController?.navigationBar.titleTextAttributes = nil
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            if self.viewModel.approved() || self.viewModel.callForAuth() {
                return 2
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let headerCell = self.tableView.dequeueReusableCell(withIdentifier: "headerNib") as! HeaderCongratsTableViewCell
            headerCell.fillCell(payment: self.viewModel.payment!, paymentMethod: self.viewModel.paymentMethod!, color: self.viewModel.color)
            headerCell.selectionStyle = .none
            return headerCell
        } else if indexPath.section == 1 {
            if  self.viewModel.approved(){
                if indexPath.row == 0{
                    let approvedCell = self.tableView.dequeueReusableCell(withIdentifier: "approvedNib") as! ApprovedTableViewCell
                    approvedCell.selectionStyle = .none
                    approvedCell.fillCell(payment: self.viewModel.payment! )
                    approvedCell.addSeparatorLineToTop(width: Double(UIScreen.main.bounds.width), y: Int(390))
                    return approvedCell
                }
                else {
                    let confirmEmailCell = self.tableView.dequeueReusableCell(withIdentifier: "emailNib") as! ConfirmEmailTableViewCell
                    confirmEmailCell.fillCell(payment: self.viewModel.payment!)
                    confirmEmailCell.selectionStyle = .none
                    confirmEmailCell.addSeparatorLineToTop(width: Double(UIScreen.main.bounds.width), y: Int(60))
                    return confirmEmailCell
                }
            } else if self.viewModel.callForAuth() {
                if indexPath.row == 0{
                    let callFAuthCell = self.tableView.dequeueReusableCell(withIdentifier: "callFAuthNib") as! CallForAuthTableViewCell
                    callFAuthCell.setCallbackStatus(callback: self.viewModel.callback, payment: self.viewModel.payment, status: MPStepBuilder.CongratsState.call_FOR_AUTH)
                    callFAuthCell.fillCell(paymentMehtod: self.viewModel.paymentMethod!)
                    callFAuthCell.selectionStyle = .none
                    callFAuthCell.addSeparatorLineToTop(width: Double(UIScreen.main.bounds.width), y: Int(callFAuthCell.contentView.bounds.maxY))
                    return callFAuthCell
                }
                else {
                    let rejectedCell = self.tableView.dequeueReusableCell(withIdentifier: "rejectedNib") as! RejectedTableViewCell
                    rejectedCell.setCallbackStatus(callback: self.viewModel.callback, payment: self.viewModel.payment, status: MPStepBuilder.CongratsState.cancel_RETRY)
                    rejectedCell.selectionStyle = .none
                    rejectedCell.fillCell(payment: self.viewModel.payment)
                    return rejectedCell
                }
                
            } else if self.viewModel.payment.status == PaymentStatus.IN_PROCESS.rawValue {
                let pendingCell = self.tableView.dequeueReusableCell(withIdentifier: "rejectedNib") as! RejectedTableViewCell
                pendingCell.callbackStatus = self.viewModel.callback
                pendingCell.setCallbackStatus(callback: self.viewModel.callback, payment: self.viewModel.payment, status: MPStepBuilder.CongratsState.cancel_RETRY)
                pendingCell.selectionStyle = .none
                pendingCell.fillCell(payment: self.viewModel.payment)
                return pendingCell
                
            } else {
                let rejectedCell = self.tableView.dequeueReusableCell(withIdentifier: "rejectedNib") as! RejectedTableViewCell
                rejectedCell.setCallbackStatus(callback: self.viewModel.callback, payment: self.viewModel.payment, status: MPStepBuilder.CongratsState.cancel_RETRY)
                rejectedCell.selectionStyle = .none
                rejectedCell.fillCell(payment: self.viewModel.payment!)
                return rejectedCell
                
            }
        } else {
            let footerNib = self.tableView.dequeueReusableCell(withIdentifier: "footerNib") as! FooterTableViewCell
            footerNib.selectionStyle = .none
            footerNib.setCallbackStatus(callback: self.viewModel.callback, payment: self.viewModel.payment, status: MPStepBuilder.CongratsState.ok)
            footerNib.fillCell(payment: self.viewModel.payment)
            return footerNib
        }
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    enum PaymentStatus : String {
        case APPROVED = "approved"
        case REJECTED = "rejected"
        case RECOVERY = "recovery"
        case IN_PROCESS = "in_process"
    }
}
class CongratsViewModel : NSObject {
    var color: UIColor!
    var payment: Payment!
    var paymentMethod: PaymentMethod?
    var callback: (_ payment : Payment, _ status : MPStepBuilder.CongratsState) -> Void
    
    init(payment: Payment?, paymentMethod : PaymentMethod?, callback : @escaping (_ payment : Payment, _ status : MPStepBuilder.CongratsState) -> Void){
        self.payment = payment
        self.paymentMethod = paymentMethod
        self.callback = callback
    }
    
    func getColor()->UIColor{
        if payment.status == "approved" {
            return UIColor(red: 59, green: 194, blue: 128)
        } else if payment.status == "in_process" {
            return UIColor(red: 255, green: 161, blue: 90)
        } else if callForAuth() {
            return UIColor(red: 58, green: 184, blue: 239)
        } else if payment.status == "rejected"{
            return UIColor(red: 255, green: 89, blue: 89)
        }
        return UIColor()
    }
    func callForAuth() ->Bool{
        if self.payment.statusDetail == "cc_rejected_call_for_authorize"{
            return true
        } else {
            return false
        }
    }
    func approved() -> Bool{
        if self.payment.status == PaymentStatus.APPROVED.rawValue {
            return true
        } else {
            return false
        }
    }
}

