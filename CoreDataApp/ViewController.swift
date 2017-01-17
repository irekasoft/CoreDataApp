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

//  var items: [String] = [] ! Initial Testing 
  var coreData = CoreDataConnection.sharedInstance
  
  
  var itemsFromCoreData: [NSManagedObject] {
    
    get {
      
      var resultArray:Array<NSManagedObject>!
      let managedContext = coreData.persistentContainer.viewContext
      let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: CoreDataConnection.kItem)
      
      let sortDescriptor = NSSortDescriptor(key:"title", ascending: true)
      
      fetchRequest.sortDescriptors = [sortDescriptor]
      
      do {
        resultArray = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
      
      return resultArray
    }
    
  }
  
  var items: [String] = []
  
  
  @IBOutlet weak var tableView: UITableView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
 
    
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
      
    }
    
    alert.addTextField()
    alert.addAction(saveAction)
    
    present(alert, animated: true)
  }
  
  func saveToCoreData(_ title: String){

    let item = coreData.createManagedObject(entityName: CoreDataConnection.kItem)
    
    item.setValue(title, forKeyPath: "title")

    coreData.saveDatabase { (success) in
      
      if (success){
        self.tableView.reloadData()
      }
      
    }
    
  }
  
  // MARK: - UITableViewDataSource

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return itemsFromCoreData.count
  }
  
  
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
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    
    print("here \(indexPath.row)")
    
    let item = itemsFromCoreData[indexPath.row] as! Item
    
    if (item.progress == 0){
      item.progress = 1
    }else{
      item.progress = 0
    }
    
    coreData.saveDatabase { (success) in
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
      
      coreData.deleteManagedObject(managedObject: item, completion: { (success) in
        if (success){

          tableView.deleteRows(at:[indexPath], with: .automatic)
          
        }
      })
      
      
    }
    
  }
  
}


