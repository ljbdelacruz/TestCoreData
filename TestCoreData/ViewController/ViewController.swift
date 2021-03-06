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


class ViewController: UIViewController {
    var taskCategory:Category?{
        didSet{
            //this will execute once this variable has been set
            self.LoadData();
        }
    };
    var tasks:[Task] = [];
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    @IBOutlet weak var UITableview: UITableView!
    @IBOutlet weak var UISBarTask: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.UITableview.delegate=self;
        self.UITableview.dataSource=self;
        self.UISBarTask.delegate=self;
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //BtnEvents
    @IBAction func DeleteCompleteOnClick(_ sender: Any) {
        self.EndSearchEdit();
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
        self.EndSearchEdit()
        let alert=UIAlertController(title: "Add Task", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            (tf) in
            tf.placeholder="Taskname";
            taskNameTF=tf;
        })
        let action=UIAlertAction(title: "Add", style: .default, handler: {
            (action) in
            //action invoked when user added new item button
            self.SaveContent(taskName: taskNameTF!.text!);
        })
        let cancelAction=UIAlertAction(title: "Cancel", style: .default, handler: {
            (action) in
        })
        alert.addAction(action);
        alert.addAction(cancelAction);
        present(alert, animated: true, completion: nil)
    }
    
}


//MARK: -UITableView Functionalities
extension ViewController: UITableViewDelegate, UITableViewDataSource{
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
        self.EndSearchEdit();
        self.tasks[indexPath.row].isDone = !self.tasks[indexPath.row].isDone;
        self.UpdateContent();
    }
}


//MARK:- Searchbar methods
extension ViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count <= 0 {
            self.LoadData();
            DispatchQueue.main.async {
                searchBar.resignFirstResponder();
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Task>=Task.fetchRequest();
        //cd makes the case insensitive to match wether its lowercase or uppercase
        if searchBar.text!.count > 0 {
            request.sortDescriptors=[NSSortDescriptor(key: "taskname", ascending: true)];
            self.LoadData(request: request, addOnPredicate: NSPredicate(format: "taskname CONTAINS[cd] %@", searchBar.text!));
        }else{
            self.LoadData();
        }
    }
    func EndSearchEdit(){
        self.UISBarTask.endEditing(true);
    }
}

//MARK: -CoreDataMethods
extension ViewController{
    func SaveContent(taskName:String){
        let newTask=Task(context: self.context);
        newTask.set(id: "", name: taskName, isDone:false);
        newTask.parentCategory=self.taskCategory!;
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
        self.LoadData()
    }
    func UpdateContent(){
        do{
            try context.save();
        }catch{
            print("ERROR saving data");
        }
        self.UITableview.reloadData();
    }
    
    //
    func LoadData(request:NSFetchRequest<Task> = Task.fetchRequest(), addOnPredicate:NSPredicate? = nil){
        let pred=NSPredicate(format: "parentCategory.name MATCHES %@", self.taskCategory!.name!);
        request.predicate = addOnPredicate != nil ? NSCompoundPredicate(andPredicateWithSubpredicates: [pred, addOnPredicate!]) : pred;
        SVProgressHUD.show();
        do{
            self.tasks=try context.fetch(request);
        }catch{
            print("has error \(error.localizedDescription)");
        }
        SVProgressHUD.dismiss();
        self.UITableview != nil ? self.UITableview.reloadData() : nil;
        
    }
}
