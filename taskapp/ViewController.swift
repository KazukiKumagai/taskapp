//
//  ViewController.swift
//  taskapp
//
//  Created by 熊谷一騎 on 2017/02/05.
//  Copyright © 2017年 熊谷一騎. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import SCLAlertView

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    let taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    var categoryFilter = ""
    var categoryTaskArray:Results<Task>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
    }
    //入力画面から戻ってきたとき
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //UITableViewDataSourceプロトコルのメソッド
    //データの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if categoryFilter != ""{
            return self.categoryTaskArray!.count
        }
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        var task = Task()
        if categoryFilter != ""{
            task = categoryTaskArray![indexPath.row]
        }else{
            task = taskArray[indexPath.row]
        }
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH: mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString

        return cell
    }
    
    //UITableViewDelegateのプロトコルのメソッド
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
         performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    //セルが削除可能を伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle{
        return UITableViewCellEditingStyle.delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == UITableViewCellEditingStyle.delete{
            
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
            
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
                for request in requests{
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    //segueで画面遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0{
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
    
        }
    }
    //カテゴリ検索用アラーム
    @IBAction func categoryBarButton(_ sender: Any) {
        let alert = SCLAlertView()
        let inputCategory = alert.addTextField("Enter the category")
        alert.addButton("Search") {
            self.categoryFilter = inputCategory.text!
            self.categoryTaskArray = self.realm.objects(Task.self).filter("category == %@", self.categoryFilter)
            self.tableView.reloadData()
        }
        alert.showEdit("Edit View", subTitle: "This alert view shows a text box")
    }
    @IBAction func clearCategoryBarButton(_ sender: Any) {
        self.categoryFilter = ""
        self.tableView.reloadData()
    }
    
    
}
