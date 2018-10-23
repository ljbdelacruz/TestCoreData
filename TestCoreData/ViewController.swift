//
//  ViewController.swift
//  TestCoreData
//
//  Created by Lainel John Dela Cruz on 22/10/2018.
//  Copyright © 2018 Lainel John Dela Cruz. All rights reserved.
//

import UIKit
import CoreData;
import SVProgressHUD;


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tasks:[Task] = [];
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    @IBOutlet weak var UITableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.UITableview.delegate=self;
        self.UITableview.dataSource=self;
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask));
        self.LoadData();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //customFunc
    func SaveContent(taskName:String){
        let newTask=Task(context: self.context);
        newTask.set(id: "", name: taskName, isDone:false);
        self.tasks.append(newTask);
        self.UpdateContent();
    }
    func RemoveComplete(){
        for index in 0..<self.tasks.count{
            if self.tasks[index].isDone {
                context.delete(self.tasks[index]);
            }
        }
        self.UpdateContent();
        self.LoadData();
    }
    func UpdateContent(){
        do{
            try context.save();
        }catch{
            print("ERROR saving data");
        }
        self.UITableview.reloadData();
    }
    func LoadData(){
        let request:NSFetchRequest<Task>=Task.fetchRequest();
        do{
            self.tasks=try context.fetch(request);
            SVProgressHUD.show();
        }catch{
            print("has error \(error.localizedDescription)");
        }
        SVProgressHUD.dismiss();
        self.UITableview.reloadData();
    }
    //tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
        cell.textLabel?.text = self.tasks[indexPath.row].taskname!;
        cell.accessoryType = self.tasks[indexPath.row].isDone ? .checkmark : .none;
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        self.tasks[indexPath.row].isDone = !self.tasks[indexPath.row].isDone;
        self.UpdateContent();
    }
    
    //BtnEvents
    @IBAction func DeleteCompleteOnClick(_ sender: Any) {
        let alert=UIAlertController(title: "Remove Complete Task", message: "Are you sure you want to remove it?", preferredStyle: .alert)
        let yesAction=UIAlertAction(title: "Yes", style: .default, handler: {
            (action) in
            self.RemoveComplete();
        })
        let noAction=UIAlertAction(title: "No", style: .default, handler: {
            (action) in
        })
        alert.addAction(yesAction);
        alert.addAction(noAction);
        present(alert, animated: true, completion: nil)
    }
    @IBAction func AddOnClick(_ sender: Any){
        var taskNameTF:UITextField?;
        let alert=UIAlertController(title: "Add Task", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (tf) in
            tf.placeholder="Taskname";
            taskNameTF=tf;
        })
        let action=UIAlertAction(title: "Add Task", style: .default, handler: {
            (action) in
            //action invoked when user added new item button
            self.SaveContent(taskName: taskNameTF!.text!);
        })
        let cancelAction=UIAlertAction(title: "Add Task", style: .default, handler: {
            (action) in
        })
        alert.addAction(action);
        alert.addAction(cancelAction);
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
}

