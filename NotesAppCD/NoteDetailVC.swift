//
//  ViewController.swift
//  NotesAppCD
//
//  Created by Zeynep Sevgi on 27.03.2023.
//

import UIKit
import CoreData

class NoteDetailVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aciklamaTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var selectedNote: Note? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(selectedNote != nil)
                {
                    titleTextField.text = selectedNote?.title
                    aciklamaTextView.text = selectedNote?.desc
                }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func gorselSec() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true,completion: nil)
    }
    
    
    @objc func klavyeyiKapat() {
        view.endEditing(true)
    }
    
    

            
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        if(selectedNote == nil)
        {
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            let newNote = Note(entity: entity!, insertInto: context)
            newNote.id = noteList.count as NSNumber
            newNote.title = titleTextField.text
            newNote.desc = aciklamaTextView.text

            
            print(imageView.image)
            

            #warning("kaydetme şeklimiz  data oldugu icin önce imageyi dataya çeviriyoruz")
            
            if let image = imageView.image {

                if let imageData = image.jpegData(compressionQuality: 1.0) {
#warning("burada çeviriyoruz dataya")
                    newNote.image = imageData
#warning("burada coredataya ekliyoruz ")
                }
            }
            
            
         
       
            do
            {
                try context.save()
                noteList.append(newNote)
                navigationController?.popViewController(animated: true)
            }
            catch
            {
                print("hata var")
            }
        }
        else //edit
        {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for result in results
                {
                    let note = result as! Note
                    if(note == selectedNote)
                    {
                        note.title = titleTextField.text
                        note.desc = aciklamaTextView.text
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            }
            catch
            {
                print("Fetch Failed")
            }
        }
        
    }
    
    
    
    @IBAction func deleteNote(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
                do {
                    let results:NSArray = try context.fetch(request) as NSArray
                    for result in results
                    {
                        let note = result as! Note
                        if(note == selectedNote)
                        {
                            note.deletedDate = Date()
                            try context.save()
                            navigationController?.popViewController(animated: true)
                        }
                    }
                }
                catch
                {
                    print("Fetch Failed")
                }
    }
}

