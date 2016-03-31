//
//  InputViewController.swift
//  taskapp
//
//  Created by Yoshifumi Hidaka on 2016/03/22.
//  Copyright © 2016年 Yoshifumi Hidaka. All rights reserved.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryarray: UIPickerView!
    
    var categorylist = ["work","fun","excersise","other"]
    
    let realm = try!Realm()
    var task:Task!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryarray.dataSource = self
        categoryarray.delegate = self

        // 背景をタップしたら、dismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:"dismissKeyboard")
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        //task.category = categoryarray.selectedRowInComponent(0)
        //上文は、下文のように訂正
        //下文では、pickerviewの何番目にあるかを調べる
        if let no = categorylist.indexOf(task.category){
        // UIPickerVIewに反映
        categoryarray.selectRow(no, inComponent: 0, animated: false)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
    return 1
    }
   func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
    return categorylist.count
    }
    
   /*func pickerView(pickerView: UIPickerView, titleForRow: Int, forComponent component:Int) -> String! {
    return categorylist[row]
   上のメソッドの宣言の書き方は、下のように訂正
    */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component:Int) -> String? {
    return categorylist[row]
    }
    
    
    
    override func viewWillDisappear(animated:Bool){
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            //self.task[row] = self.categoryarray.selectedRowInComponent(0)
            //上の文は、下の文のように訂正
            let no = self.categoryarray.selectedRowInComponent(0)   //ピッカービューの現在選択されている番号をselectedRowInComponent(Int)で取得
            let str = categorylist[no]   //選択された行番号をカテゴリーの名前（文字データ(str)）に変換している
            //カテゴリーの名前をtaskに設定
            //taskは修正済み
            self.task.category = str
            
            self.realm.add(self.task, update: true)
        }
        setNotification(task)
     super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //タスクのローカル通知を設定する
    func setNotification(task: Task){
    
    //すでに同じタスクが登録されていたらキャンセルする
    for notification in UIApplication.sharedApplication().scheduledLocalNotifications!{
    if notification.userInfo!["id"] as! Int == task.id{
    UIApplication.sharedApplication().cancelLocalNotification(notification)
    break  //breakに来ると、forループから抜け出せる
    }
    }
    let notification = UILocalNotification()
    
    notification.fireDate = task.date
    notification.timeZone = NSTimeZone.defaultTimeZone()
    notification.alertBody = "\(task.title)"
    notification.soundName = UILocalNotificationDefaultSoundName
    notification.userInfo = ["id":task.id]
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
    
}
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


