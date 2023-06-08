//
//  SecondViewController.swift
//  NatureBook
//
//  Created by Fatihan Ziyan on 6.06.2023.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var place: UITextField!
    @IBOutlet weak var year: UITextField!
    var targetName = ""
    var targetId: UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetName != "" {
            // Core data verilerini burda çekeceğiz
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gallery")
            
            //id'ye göre filtreleme
            let idString = targetId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false // Bu satır Core data içindeki verirler okurken  uygulamaının hızını arttırmaya yarıyor. Apple dokümaında böyle yazıyor.
            
            do {
                
               let results =  try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    
                    if let nameT = result.value(forKey: "name") as? String{
                        name.text = nameT
                    }
                    if let placeT = result.value(forKey: "name") as? String{
                        place.text = placeT
                    }
                    if let yearT = result.value(forKey: "year") as? Int{
                        year.text = String(yearT)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                  
                }
                
            }catch{
                print("Error")
            }
            
        }
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(gestureRecognizer)

    }
    
    @objc func imageTap(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    //Fotoğraf seçme olayı burda tetikleniyor
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info [.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

        @IBAction func saveClickedButton(_ sender: Any) {
            
            // Veri Kaydetme işlemi
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let saveData = NSEntityDescription.insertNewObject(forEntityName: "Gallery", into: context)
            
            saveData.setValue(name.text, forKey: "name")
            saveData.setValue(place.text, forKey: "place")
            
            if let year = Int(year.text!){
                saveData.setValue(year, forKey: "year")
            }
            
            let imagePress = imageView.image?.jpegData(compressionQuality: 0.5) // resim kalitesi yer kaplamaması için yapılıyor.
            saveData.setValue(imagePress, forKey: "image")
            saveData.setValue(UUID(), forKey: "id")
            
            do{
                try context.save()
                print("Success")
            } catch{
                print("Error")
            }
            
            // İkinci ekran kapanacak ve Kayıt edilen data tableView'da görünür olacak.
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true)
        }
        
    
}
