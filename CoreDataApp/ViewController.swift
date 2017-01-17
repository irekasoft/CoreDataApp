//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Hijazi on 6/11/16.
//  Copyright © 2016 iReka Soft. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

//  var items: [String] = []
  var itemsFromCoreData: [NSManagedObject] = []
  var items: [String] = []
  
  @IBOutlet weak var tableView: UITableView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let managedContext =
      CoreDataConnection.sharedInstance.persistentContainer.viewContext
    //2
    let fetchRequest =
      NSFetchRequest<NSManagedObject>(entityName: CoreDataConnection.kItem)
    //3
    do {
      itemsFromCoreData = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func addItem(_ sender: UIBarButtonItem) {
    let alert = UIAlertController(title: "New Item",
                                  message: "Name of the new item",
                                  preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel)
    alert.addAction(cancelAction)
    
    let saveAction = UIAlertAction(title: "Save",style: .default) {
      [unowned self] action in
    
      guard let textField = alert.textFields?.first,
        let nameToSave = textField.text else {
          return
      }
      self.saveToCoreData(nameToSave)
      self.tableView.reloadData()
    }
    
    alert.addTextField()
    alert.addAction(saveAction)
    
    present(alert, animated: true)
  }
  
  func saveToCoreData(_ title: String){

    let item = CoreDataConnection.sharedInstance.createManagedObject(entityName: CoreDataConnection.kItem)
    
    item.setValue(title, forKeyPath: "title")

    CoreDataConnection.sharedInstance.saveDatabase { (success) in
      print("success \(success)")
      
      if (success){
        itemsFromCoreData.append(item)
      }
      
    }
    
  }

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return itemsFromCoreData.count
  }
  
  
  
  // MARK: - UITableViewDataSource
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      
      let cell =
        tableView.dequeueReusableCell(withIdentifier:"Cell",
                                      for: indexPath)
      

      let item = itemsFromCoreData[indexPath.row] as! Item
      
      cell.textLabel?.text = item.title
      cell.detailTextLabel?.text = "\(item.progress)"
      
      return cell
      
  }
  
  
  // MARK: - UITableViewDelegate
  // Update the 
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    
    print("here \(indexPath.row)")
    
    let item = itemsFromCoreData[indexPath.row] as! Item
    
    if (item.progress == 0){
      item.progress = 1
    }else{
      item.progress = 0
    }
    
    CoreDataConnection.sharedInstance.saveDatabase { (success) in

      if (success) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
      }
    
    }
    
  }
  
  // ViewController.swift
  // [1]
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  // [2]
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    if (editingStyle == .delete){
      
      let item = itemsFromCoreData[indexPath.row] as! Item
      
      CoreDataConnection.sharedInstance.deleteManagedObject(managedObject: item, completion: { (success) in
        if (success){
          
          itemsFromCoreData.remove(at: indexPath.row)
          tableView.deleteRows(at:[indexPath], with: .automatic)
          
        }
      })
      
      
    }
    
  }
  
}


