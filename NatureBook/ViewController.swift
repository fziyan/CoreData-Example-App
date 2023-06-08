//
//  ViewController.swift
//  NatureBook
//
//  Created by Fatihan Ziyan on 6.06.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var sourceName = ""
    var sourceId: UUID?
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sourceName = nameArray[indexPath.row]
        sourceId = idArray[indexPath.row]
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondVC") as! SecondViewController
        vc.targetName = sourceName
        vc.targetId = sourceId
        vc.modalPresentationStyle = .formSheet
        self.present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Core data veri silme işini burada yaptım.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gallery")
        
        //id'ye göre filtreleme
        let idString = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                if let id = result.value(forKey: "id") as? UUID {
                    context.delete(result)
                    nameArray.remove(at: indexPath.row)
                    idArray.remove(at: indexPath.row)
                    self.tableView.reloadData()
                    
                    do{
                        try context.save()
                    }catch{
                        print("Data not saved")
                    }
                }
            }
            
        }catch{
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addItem))
        
        tableView.delegate = self
        tableView.dataSource = self
        getData()
        
    }
    
    @objc func addItem(){
        
         let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondVC")
        vc.modalPresentationStyle = .formSheet
         self.present(vc, animated: true)
    }
    
    // Bu fonksiyonu eklememin amacı data kayıt edilmeden hemen önce bu viewController'a haber vermek
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    // Core data ile veri çekme işlemlerini yapan fonksiyon
    @objc func getData() {
        self.nameArray.removeAll(keepingCapacity: true)
        self.idArray.removeAll(keepingCapacity: true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gallery")
        fetchRequest.returnsObjectsAsFaults = false // Bu satır Core data içindeki verirler okurken  uygulamaının hızını arttırmaya yarıyor. Apple dokümaında böyle yazıyor.
        
        do {
            
           let results =  try context.fetch(fetchRequest)
            for result in results as! [NSManagedObject] {
                
                if let name = result.value(forKey: "name") as? String{
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID{
                    self.idArray.append(id)
                }
                self.tableView.reloadData()
            }
            
        }catch{
            
        }
    }
  
    
}

