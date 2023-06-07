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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true)
        }
        
    
}
