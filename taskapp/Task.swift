//
//  Task.swift
//  
//
//  Created by Yoshifumi Hidaka on 2016/03/24.
//
//

import RealmSwift

class Task: Object {
    
    //管理用ID。プライマリーキー
    dynamic var id = 0
    //タイトル
    dynamic var title = ""
    //内容
    dynamic var contents = ""
    //日時
    dynamic var date = NSDate()
    
    //dynamic var category = categoryarray[""]
    //上の文は、下の文のように訂正。（普通の文字列としてカテゴリーを作成）
    dynamic var category = ""
    
    //idをプライマリーキーとして設定
    override static func primaryKey() -> String?{
        return "id"
    }
}


