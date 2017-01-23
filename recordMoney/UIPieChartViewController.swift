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
    
    @IBOutlet weak var pieChartView:PieChartView!
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var coreConnect:CoreDataConnect?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 建立連線
        coreConnect = CoreDataConnect.init(moc: self.moc)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
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

}
