//
//  Task.swift
//  taskapp
//
//  Created by 熊谷一騎 on 2017/02/11.
//  Copyright © 2017年 熊谷一騎. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    /// 日時
    dynamic var date = NSDate()

    //カテゴリ
    dynamic var category:String = ""
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
