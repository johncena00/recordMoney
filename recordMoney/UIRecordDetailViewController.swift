//
//  UIRecordDetailViewController.swift
//  recordMoney
//
//  Created by devilcry on 2017/1/23.
//  Copyright © 2017年 devilcry. All rights reserved.
//

import UIKit

class UIRecordDetailViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {
    
    struct Record {
        var id : Int = 0
        var desc :String?
        var amount :Double?
        var type :String?
        var createTime :String?
    }
    
    @IBOutlet weak var amountTextField :UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var createTimeTextField : UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let myFormatter = DateFormatter()
    let myUserDefaults = UserDefaults.standard
    let myType : [String] = ["食","衣","住","行","育","樂"]
    
    var coreDateConnect: CoreDataConnect?
    var record : Record!
    var myDatePicker :UIDatePicker!
    var currentDate :Date = Date()
    var myPickerView :UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountTextField.becomeFirstResponder()
        
        myPickerView = UIPickerView()
        
        myPickerView.dataSource = self
        myPickerView.delegate = self

        coreDateConnect = CoreDataConnect.init(moc: self.moc)
        
        myFormatter.dateFormat = "yyyy-MM-dd"
        record = Record(id: 0, desc: nil, amount: nil, type: nil, createTime: myFormatter.string(from: Date()))
        
        
        myDatePicker = UIDatePicker()
        myDatePicker.datePickerMode = .date
        myDatePicker.locale = Locale(identifier: "zh_TW")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupPickerView()
        setupDatePicker()
        fetchRequest()
    }
    
    func setupPickerView(){
        //設初值
        typeTextField.text = myType[0]
        typeTextField.inputView = myPickerView
        
        let toolBar = UIToolbar()
        toolBar.barTintColor = UIColor.clear
        toolBar.sizeToFit()
        toolBar.barStyle = .default
        toolBar.tintColor = UIColor.white
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(UIRecordDetailViewController.cancelTouched(_:)))
        toolBar.items = [space, doneBtn]
        typeTextField.inputAccessoryView = toolBar
    }
    
    func setupDatePicker() {
        createTimeTextField.text = myFormatter.string(from: currentDate)
        myDatePicker.date = myFormatter.date(from:createTimeTextField.text!)!
        createTimeTextField.inputView = myDatePicker
        
        let toolBar = UIToolbar()
        toolBar.barTintColor = UIColor.clear
        toolBar.sizeToFit()
        toolBar.barStyle = .default
        toolBar.tintColor = UIColor.white
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(UIRecordDetailViewController.cancelTouched(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(UIRecordDetailViewController.doneTouched(_:)))
        toolBar.items = [cancelBtn, space, doneBtn]
        createTimeTextField.inputAccessoryView = toolBar
    }
    
    func fetchRequest() {
        
    }
    
    @IBAction func saveBtnAction(sender:AnyObject) {
        let myEntityName = "Account"
        guard let connect = coreDateConnect else {
            return
        }
        
        // record_id 遞增
        if let idSeq = myUserDefaults.object(forKey: "idSeq")
            as? Int {
            record.id = idSeq + 1
        }
        
        // 表單驗證
        var errorField = ""
        
        if amountTextField.text == "" {
            errorField = "金錢"
        } else if descTextField.text == "" {
            errorField = "事由"
        } else if createTimeTextField.text == "" {
            errorField = "時間"
        }
        
        if errorField != "" {
            
            let alertController = UIAlertController(title: "Oops", message: "We can't proceed as you forget to fill" + errorField + ". All fields are mandatory.", preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(doneAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        record.amount = Double(amountTextField.text!) ?? 0
        record.type = typeTextField.text ?? ""
        record.desc = descTextField.text ?? ""
        record.createTime = createTimeTextField.text!
        
        
        let insetResult = connect.insert(myEntityName: myEntityName, attributeInfo: [
            "id":"\(record.id)",
            "amount":"\(record.amount!)",
            "type":"\(record.type!)",
            "desc":"\(record.desc!)",
            "createTime":"\(record.createTime!)"])
        
        if insetResult {
            print("新增成功")
            myUserDefaults.set(record.id, forKey: "idSeq")
            myUserDefaults.synchronize()
            
            dismiss(animated: true, completion: nil)
        }

    }
    
    // 選取日期時 按下完成
    func doneTouched(_ sender:UIBarButtonItem) {
        
        let date = myFormatter.string(from: myDatePicker.date)
        createTimeTextField.text = date
        
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
    
    // UIPickerViewDataSource
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myType.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myType[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = myType[row]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
