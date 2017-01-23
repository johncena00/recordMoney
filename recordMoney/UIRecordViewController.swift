//
//  UIRecordViewController.swift
//  recordMoney
//
//  Created by devilcry on 2017/1/23.
//  Copyright © 2017年 devilcry. All rights reserved.
//

import UIKit
import CoreData

class UIRecordViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var currentDateTextField :UITextField!
    @IBOutlet weak var amountLabel :UILabel!
    @IBOutlet weak var nextBtn :UIButton!
    @IBOutlet weak var prevBtn :UIButton!
    @IBOutlet weak var addBarBtn :UIBarButtonItem!
    @IBOutlet weak var myTableView :UITableView!
    
    let myFormatter = DateFormatter()
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let myUserDefaults = UserDefaults.standard
    
    
    var coreConnect :CoreDataConnect?
    var myDatePicker :UIDatePicker!
    var currentDate :Date = Date()
    var myRecords : [String:[[String:String]]] = [:]
    var days: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreConnect = CoreDataConnect.init(moc: self.moc)
        
        myFormatter.dateFormat = "yyyy年MM月dd日"
        myDatePicker = UIDatePicker()
        myDatePicker.datePickerMode = .date
        myDatePicker.locale = Locale(identifier: "zh_TW")
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupDatePicker()
        updateRecordList()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateRecordList(){
        guard let connect = coreConnect else {
            return
        }
        myFormatter.dateFormat = "yyyy-MM-dd"
        let createTime = myFormatter.string(from: currentDate)
        let myEntityName = "Account"
        let predicate = String(format:"createTime = '%@'", createTime)
        
        var total = 0.0
        myRecords = [:]
        days = []
        
        let statement = connect.fetch(myEntityName: myEntityName, predicate: predicate, sort: [["createTime": true]], limit: nil)
        
        if let results = statement {
            for result in results {
                let id = result.id
                let type = result.type!
                let amount = result.amount
                let createTime = result.createTime!
                
                
                if createTime != "" {
                    if !days.contains(createTime) {
                        days.append(createTime)
                        myRecords[createTime] = []
                    }
                    
                    myRecords[createTime]?.append(
                        ["id":"\(id)",
                         "type":"\(type)",
                         "amount":"\(amount)",
                         "createTime":"\(createTime)"]
                    )
                    total += amount
                }
                
                
            }
        }
        myTableView.reloadData()
        amountLabel.text = String(format: "%g", total)
    }
    
    func setupDatePicker() {
        currentDateTextField.text = myFormatter.string(from: currentDate)
        myDatePicker.date = myFormatter.date(from:currentDateTextField.text!)!
        currentDateTextField.inputView = myDatePicker
        
        let toolBar = UIToolbar()
        toolBar.barTintColor = UIColor.clear
        toolBar.sizeToFit()
        toolBar.barStyle = .default
        toolBar.tintColor = UIColor.white
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(UIRecordViewController.cancelTouched(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(UIRecordViewController.doneTouched(_:)))
        toolBar.items = [cancelBtn, space, doneBtn]
        currentDateTextField.inputAccessoryView = toolBar
    }
    
    
    @IBAction func addAction() {
        let optionMenu = UIAlertController(title: nil, message: "新增方式", preferredStyle: .actionSheet)
        
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "showRecord") as! UIRecordDetailViewController
        
        menuVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(UIRecordViewController.goBack))
        let naviController = UINavigationController(rootViewController: menuVC)
        
        
        let qrActionHandler = {
            (action :UIAlertAction!) -> Void in
        }
        
        let qrActoin = UIAlertAction(title: "QRCode", style: .default, handler: qrActionHandler)
        optionMenu.addAction(qrActoin)
        
        let addActionHandler = {
            (action :UIAlertAction!) -> Void in
            self.myUserDefaults.set(0, forKey: "postID")
            self.myUserDefaults.synchronize()
            self.present(naviController, animated: true, completion: nil)
        }
        
        let addAction = UIAlertAction(title: "AddRecord", style: .default, handler: addActionHandler)
        optionMenu.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true, completion: nil)
    }
    
    func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    // 選取日期時 按下完成
    func doneTouched(_ sender:UIBarButtonItem) {
        
        let date = myFormatter.string(from: myDatePicker.date)
        currentDateTextField.text = date
        //record.createTime = date
        
        hideKeyboard(nil)
    }
    
    // 選取日期時 按下取消
    func cancelTouched(_ sender:UIBarButtonItem) {
        hideKeyboard(nil)
    }
    
    // MARK: Functional Methods
    
    // 按空白處會隱藏編輯狀態
    func hideKeyboard(_ tapG:UITapGestureRecognizer?){
        self.view.endEditing(true)
    }
    
    // TableView Section
    //每一組有幾個cell *必須實作
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int
    {
        let date = days[section]
        guard let records = myRecords[date] else {
            return 0
        }
        return records.count
    }
    //顯示cell資料 *必須實作
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return cell!
        }
        
        cell!.detailTextLabel?.text = String(format: "%g", Float(records[indexPath.row]["amount"]!)!)
        cell!.textLabel?.text = records[indexPath.row]["type"]
        
        return cell!
    }
    
    //點選cell後的動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let date = days[indexPath.section]
        guard let records = myRecords[date] else {
            return
        }
        
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "showRecord") as! UIRecordDetailViewController
        
        menuVC.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(UIRecordViewController.goBack))
        let naviController = UINavigationController(rootViewController: menuVC)
        
        
        myUserDefaults.set(Int(records[indexPath.row]["id"]!), forKey: "postID")
        myUserDefaults.synchronize()
        
        self.present(naviController, animated: true, completion: nil)
        
    }
    
    // 有幾個 section
    func numberOfSections(in tableView: UITableView) -> Int {
        //return days.count
        return 1
    }
    
    // section 標題
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return days[section]
//    }
//    
//    // section 標題 高度
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
    
    // section footer 高度
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (days.count - 1) == section ? 60 : 3
    }
    
    // section header 樣式
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor.init(red: 0.88, green: 0.83, blue: 0.73, alpha: 1)
    }

}
