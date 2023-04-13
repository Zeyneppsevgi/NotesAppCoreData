//
//  ViewController.swift
//  NotesAppCD
//
//  Created by Zeynep Sevgi on 27.03.2023.
//

import UIKit
import CoreData
import MapKit

class NoteDetailVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,UISearchBarDelegate{
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aciklamaTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var selectedNote: Note? = nil
    
    let search = UISearchController(searchResultsController: nil)
    
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
        
        search.searchBar.delegate = self
        navigationItem.searchController = search
        
        
        
    
       
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let text = search
            .searchBar.text ?? "istanbul"
        search(text: text)
    }
    
    func search(text: String) {
        let indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        self.view.addSubview(indicator)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            indicator.stopAnimating()
            if (response == nil) {
                print("error")
            } else {
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                let lat = response?.boundingRegion.center.latitude
                let long = response?.boundingRegion.center.longitude
                
                let annotation = MKPointAnnotation()
                annotation.title = text
                annotation.coordinate = CLLocationCoordinate2D(latitude: lat!,longitude: long!)
                self.mapView.addAnnotation(annotation)
            }
            
        }
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
    
    
    
    // @IBAction func deleteNote(_ sender: Any) {
    // let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //   let context: NSManagedObjectContext = //appDelegate.persistentContainer.viewContext
    
    //let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
    //  do {
    //  let results:NSArray = try context.fetch(request) as NSArray
    //     for result in results
    //{
    //   let note = result as! Note
    //  if(note == selectedNote)
    // {
    //    note.deletedDate = Date()
    //    try context.save()
    //   navigationController?.popViewController(animated: true)
    // }
    // }
    //  }
    // catch
    //  {
    //      print("Fetch Failed")
    //  }
    // }

    
  
            
        }
        
        
    
    

