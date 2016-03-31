//
//  ViewController.swift
//  taskapp
//
//  Created by Yoshifumi Hidaka on 2016/03/21.
//  Copyright © 2016年 Yoshifumi Hidaka. All rights reserved.
//

import UIKit
import RealmSwift  //追加


    class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    //@IBOutlet weak var tableView: UITableView!の接続しなおし。なぜなら自分で削除してしまったため。
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
//質問：ここに、@IBOutlet searchbarが必要ですか？　->答えは、yesだった
//さらに、searchbarからdrag&dropで上のviewcontrollerに持って行き、delegate接続もした。
  
    
    //Realmインスタンスを取得する
    let realm = try! Realm() //追加
    
    //DB内のタスクが格納されるリスト
    //日付近い順\順でソート：降順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
    //上文を追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        
        
        
        //以下、searchbarの実装
        //searchbar.delegate = self <-不要。storyboardから接続作業をしたので
        // 各種ボタンを表示
        searchbar.showsCancelButton = true
        searchbar.showsSearchResultsButton = true
        // 見出し、プレースホルダの表示
        searchbar.placeholder = "検索ワード入力"
        searchbar.keyboardType = UIKeyboardType.Default
        // 枠と文字を灰色に
        searchbar.tintColor = UIColor.grayColor()
        //self.view.addSubview(searchbar) <-これも不要だとメンターに教えてもらった。理由は？
        }
        
        
        
        func searchBarCancelButtonClicked(searchBar:UISearchBar){
        //キャンセルボタンが押されたら検索フォームを空にする
        searchbar.text = ""
        //searchBarCancelButtonClickedは、最初上文のみしか実装してなかった。
        //すると、キャンセルボタン押した後、元のタスク一覧画面が出てこなくなった。
        //そこで、taskArray = try! Realm().objects(Task).sorted("date", ascending: false)を追加したら、上手くいった！
        //それと、その後taskArrayの情報をすべて取得して再度reloadData()を呼び出しする必要があるだろう。
        //よって、以下の２文を追加した。
        taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
        tableView.reloadData()  //<-必要ではないか？
        }
        
        func searchBar(searchBar: UISearchBar, textDidChange searchText:String) {
        //再検索の処理など
            print(searchText)
        }
        
        func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //検索ボタン押下時の処理
        //realmから呼び出し
        //let kensaku = realm.objects(object名前).filter("条件") //条件は、""OR""OR""OR"" か、nameIN'','','',''かだろうか？
        //let kensaku = try! Realm().objects(Task).filter("categoryCONTAINS[c]‘\(searchBar.text)'")をコメントアウト
        taskArray = try! Realm().objects(Task).filter("category = '\(searchBar.text!)'").sorted("date", ascending: false)
        //taskArray = kensakuをコメントアウト
        tableView.reloadData()
        }
        
        //以上、searchbarの実装
        
    
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:UITableViewDataSourceプロトコルのメソッド
    //データの数（=セルの数）を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count //追加する
    }
    
    //各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:indexPath )
        
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    //MARK: UITableViewDelegateプロトコルのメソッド
    //各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝える
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete{
            
            //ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications!{
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            
            
            //データベースから削除する　//以降追加する
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimation.Fade)
            }
            
        }
        
    }

    //segueで画面遷移するときに呼ばれる
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max("id")! + 1
            }
            inputViewController.task = task
        }
     }
    
    //入力画面から戻ってきた時に、TableViewを更新させる
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
        }
     }



