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
    
    var dbObject: NSManagedObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if dbObject != nil {
            if let nameT = dbObject!.value(forKey: "name") as? String{
                name.text = nameT
            }
            if let placeT = dbObject!.value(forKey: "place") as? String{
                place.text = placeT
            }
            if let yearT = dbObject!.value(forKey: "year") as? Int{
                year.text = String(yearT)
            }
            if let imageData = dbObject!.value(forKey: "image") as? Data {
                let image = UIImage(data: imageData)
                imageView.image = image
                self.selectedImage = image
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
    
    var selectedImage: UIImage?
    
    //Fotoğraf seçme olayı burda tetikleniyor
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        selectedImage = info[.originalImage] as? UIImage
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

        @IBAction func saveClickedButton(_ sender: Any) {
            
            if dbObject != nil {
                if name.text != "" && place.text != "" && year.text != "" && selectedImage != nil {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    
                    dbObject!.setValue(name.text, forKey: "name")
                    dbObject!.setValue(place.text, forKey: "place")
                    
                    if let year = Int(year.text!){
                        dbObject!.setValue(year, forKey: "year")
                    }
                    
                    let imagePress = selectedImage?.jpegData(compressionQuality: 0.5) // resim kalitesi yer kaplamaması için yapılıyor.
                    dbObject!.setValue(imagePress, forKey: "image")
                    
                    do{
                        try context.save()
                        print("Success")
                    } catch{
                        print("Error")
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true)
                }
            } else {
                if name.text != "" && place.text != "" && year.text != "" && selectedImage != nil {
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
                } else {
                    let alert = UIAlertController(title: "HATA", message: "Lütfen gerekli alanları doldur piç", preferredStyle: .alert )
                    alert.addAction(.init(title: "Ok", style: .default))
                    present(alert, animated: true)
                }
            }
        }
}
