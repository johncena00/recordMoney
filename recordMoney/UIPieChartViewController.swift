//
//  UIPieChartViewController.swift
//  recordMoney
//
//  Created by devilcry on 2017/1/23.
//  Copyright © 2017年 devilcry. All rights reserved.
//

import UIKit
import Charts
import CoreData

class UIPieChartViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pieChartView:PieChartView!
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    
    let myFormatter = DateFormatter()
    
    var currentDate: Date = Date()
    
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var coreConnect:CoreDataConnect?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 建立連線
        coreConnect = CoreDataConnect.init(moc: self.moc)
        
        pieChartView.noDataText = "You need to provide data for the chart."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }
    
    func updateView() {
        segmentedControl.selectedSegmentIndex = 1
        var dateComponents = DateComponents()
        dateComponents.day = -7
        self.updateCurrentDate(dateComponents)
    }
    
    func updateCurrentDate(_ dateComponents :DateComponents) {
        let cal = Calendar.current
        let newDate = cal.date(byAdding: dateComponents, to: currentDate)
        
        // 更新年月
        myFormatter.dateFormat = "yyyy-MM-dd"
        let newDateStr = myFormatter.string(from: newDate!)
        let currentDateStr = myFormatter.string(from: currentDate)
        
        let combineStr = String(format: "%@ ~ %@", newDateStr,currentDateStr)
        
        dateLabel.text = combineStr
        
        updateRecord(newDate: newDateStr,currentDate: currentDateStr)
        
    }
    
    func updateRecord(newDate:String,currentDate:String) {
        let myEntityName = "Account"
        let predicate = String(format:"createTime >= '%@' AND createTime <= '%@'", newDate,currentDate)
        var total = 0.0
        var dictAccount: [String:Double] = [:]
        print(predicate)
        if let connect = coreConnect {
            let statement = connect.fetch(myEntityName: myEntityName, predicate: predicate, sort: [["createTime":true]], limit: nil)
            
            if let results = statement {
                for result in results {
                
                    let type = result.type!
                    var amount = result.amount
                    
                    if let value = dictAccount[type] {
                        amount += value
                    }
                    
                    dictAccount.updateValue(amount, forKey: type)
                    
                    print(dictAccount)
                    
                    
                    total += amount
                }
            }
            print(String(format: "%g", total))
            
            setChart(dictionary: dictAccount)
            
            
        }
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
    }
    
    func setChart(dictionary:Dictionary<String, Double>) {
        //var dataEntries: [PieChartDataEntry] = []
        var dataEntries: [ChartDataEntry] = []
        //var i:Int = 0
        
        for (key, value) in dictionary {
            print("Dictionary key \(key) -  Dictionary value \(value)")
            let dataEntry = PieChartDataEntry(value: value, label: key)
            //let dataEntry = ChartDataEntry(x: Double(i), y: value)
            dataEntries.append(dataEntry)
            //i += 1
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: nil )
        
        /*
        var colors: [UIColor] = []
        
        for i in 0..<dictionary.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        */
        pieChartDataSet.colors = ChartColorTemplates.colorful()
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        
        pieChartView.descriptionText = ""
        
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }

    
    @IBAction func myToggleAction(_ sender: UISegmentedControl){
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            dateLabel.text = "自訂喔"
        case 1: //週
            var dateComponents = DateComponents()
            dateComponents.day = -7
            self.updateCurrentDate(dateComponents)
        case 2: //月
            var dateComponents = DateComponents()
            dateComponents.month = -6
            self.updateCurrentDate(dateComponents)
        default: //年
            var dateComponents = DateComponents()
            dateComponents.year = -1
            self.updateCurrentDate(dateComponents)
        break
        }
        
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
