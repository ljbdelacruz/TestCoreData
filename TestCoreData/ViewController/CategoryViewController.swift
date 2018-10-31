//
//  CategoryViewController.swift
//  TestCoreData
//
//  Created by Lainel John Dela Cruz on 23/10/2018.
//  Copyright © 2018 Lainel John Dela Cruz. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController, UIApplicationDelegate {
    let context=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    @IBOutlet weak var UICategoryTV: UITableView!
    @IBOutlet weak var UISearchBarCategory: UISearchBar!
    var taskCategories:[Category]=[];
    var selectedTaskCategory:Category?;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.UICategoryTV.delegate=self;
        self.UICategoryTV.dataSource=self;
        self.UISearchBarCategory.delegate=self;        
        self.LoadData();
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryToTask" {
            let destVC=segue.destination as! ViewController;
            destVC.taskCategory=self.selectedTaskCategory;
        }
    }
    @IBAction func AddOnClick(_ sender: Any) {
        var categoryTF:UITextField?;
        let uialert=UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        uialert.addTextField(configurationHandler: {
            (tf) in
            tf.placeholder="Taskname";
            categoryTF=tf;
        })
        let addAction=UIAlertAction(title: "Add", style: .default, handler: {
            (action) in
            //action invoked when user added new item button
            self.SaveData(name: categoryTF!.text!);
        })
        let cancelAction=UIAlertAction(title: "Cancel", style: .default, handler: {
            (action) in
        })
        uialert.addAction(addAction);
        uialert.addAction(cancelAction);
        present(uialert, animated: true, completion: nil)
    }
    
}





//MARK: -CoreData Functionality
extension CategoryViewController{
    
    func LoadData(request:NSFetchRequest<Category> = Category.fetchRequest(), addOnPredicate:NSPredicate? = nil){
        request.predicate=addOnPredicate != nil ? addOnPredicate : nil;
        do{
            try self.taskCategories=context.fetch(request);
        }catch{
            print("\(error.localizedDescription)");
        }
        self.UICategoryTV.reloadData();
    }
    func SaveData(name:String){
        let newTask=Category(context: self.context);
        newTask.set(name: name);
        self.taskCategories.append(newTask);
        self.UpdateData();
    }
    func UpdateData(){
        do{
            try context.save();
        }catch{
            print("\(error.localizedDescription)");
        }
        self.UICategoryTV.reloadData()
    }
    
}

//MARK: -UISearchBar Functionality
extension CategoryViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count <= 0{
            self.LoadData();
            DispatchQueue.main.async {
                searchBar.resignFirstResponder();
            }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Category>=Category.fetchRequest();
        //cd makes the case insensitive to match wether its lowercase or uppercase
        if searchBar.text!.count > 0 {
            request.sortDescriptors=[NSSortDescriptor(key: "name", ascending: true)];
            self.LoadData(request:request, addOnPredicate: NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!));
        }else{
            self.LoadData();
        }
    }
}
//MARK: -UITableViewFunctionality
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskCategories.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell1", for: indexPath)
        cell.textLabel?.text = self.taskCategories[indexPath.row].name!;
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedTaskCategory=self.taskCategories[indexPath.row];
        print(self.selectedTaskCategory!.name!);
        performSegue(withIdentifier: "categoryToTask", sender: nil);
    }
    
}
