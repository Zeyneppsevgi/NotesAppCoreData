//
//  ViewController.swift
//  NotesAppCD
//
//  Created by Zeynep Sevgi on 27.03.2023.
//

import UIKit
import CoreData
import MapKit
import CoreLocation


class NoteDetailVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,UISearchBarDelegate,MKMapViewDelegate,CLLocationManagerDelegate{
    
  
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var aciklamaTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var savedButonTitle: UIButton!
    
    @IBOutlet weak var isSaved: UIImageView!
  
    var selectedNote: Note? = nil
    var savedLat: Double?
    var savedLon: Double?
   // var isSaved: Bool?
    var locationManager = CLLocationManager()
    var stopLocation = false
    
    // let search = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        if(selectedNote != nil)
        {
            print(selectedNote?.title)
            if selectedNote!.isFaved {
                isSaved.image = UIImage(systemName: "heart.fill")
            }else {
                isSaved.image = UIImage(systemName: "heart")
            }
            titleTextField.text = selectedNote?.title
            aciklamaTextView.text = selectedNote?.desc
        }
       
        
       
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        searchBar.delegate = self
        // search.searchBar.delegate = self
        //  navigationItem.searchController = search
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if selectedNote?.latitude != nil {
            
            let latitude = selectedNote?.latitude
            let longitude = selectedNote?.longitude
            
            
            
            let location = CLLocationCoordinate2D(latitude: latitude as! CLLocationDegrees, longitude: longitude as! CLLocationDegrees )
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            
            
            mapView.setRegion(region, animated: true)
            manager.stopUpdatingLocation()
            
        } else {

            let latitude = locations[0].coordinate.latitude
            let longitude = locations[0].coordinate.longitude
            savedLat = Double(latitude)
            savedLon = Double(longitude)
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)

            mapView.setRegion(region, animated: true)
            manager.stopUpdatingLocation()
        }
        
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        let text = searchBar.text ?? "istanbul"
        //  let text = search.searchBar.text ?? "istanbul"
        
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
        
        activeSearch.start{ (response, error) in
            
            indicator.stopAnimating()
            
            if (response == nil) {
                print("error")
            }else {
                
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                let lat = response?.boundingRegion.center.latitude
                let long = response?.boundingRegion.center.longitude
                
                let annotation = MKPointAnnotation()
                annotation.title = text
                annotation.coordinate = CLLocationCoordinate2DMake(lat!, long!)
                self.mapView.addAnnotation(annotation)
                
                //coredatasan çektiğim lat lonu göstermeğer daha önce kaydettiğine girerse??
                let cordinate = CLLocationCoordinate2DMake(lat!, long!)
                self.savedLat = lat
                self.savedLon = long
                
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: cordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
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
            newNote.latitude = savedLat as NSNumber?
            newNote.longitude = savedLon as NSNumber?
            if isSaved.image == UIImage(systemName: "heart.fill") {
                newNote.isFaved = false
            } else {
                newNote.isFaved = true
                
            }
            
            if let image = imageView.image {
                
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    newNote.image = imageData
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
                        if isSaved.image == UIImage(systemName: "heart.fill") {
                            note.isFaved = false
                        } else {
                            note.isFaved = true
                            
                        }
                        
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
    
    
  

}





