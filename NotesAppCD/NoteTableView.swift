//
//  NoteTableView.swift
//  NotesAppCD
//
//  Created by Zeynep Sevgi on 27.03.2023.
//

import UIKit
import CoreData

private var filteredData = [Note]()







var noteList = [Note] ()
class NoteTableView: UITableViewController
{
    
 
    
    
    var firstLoad = true
   
        
    func nonDeletedNotes() -> [Note]
    {
        var noDeleteNoteList = [Note]()
        for note in noteList
        {
            if(note.deletedDate == nil)
            {
                noDeleteNoteList.append(note)
            }
        }
        return noDeleteNoteList
    }
    
        
        override func viewDidLoad()
        {
            
            if(firstLoad)
            {
                firstLoad = false
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
                do {
                    let results:NSArray = try context.fetch(request) as NSArray
                    for result in results
                    {
                        let note = result as! Note
                        noteList.append(note)
                    }
                }
                catch
                {
                    print("Fetch Failed")
                }
            }
  
         
        }


 
   
  
   
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let noteToDelete = nonDeletedNotes()[indexPath.row]
            
            
            noteToDelete.deletedDate = Date()
            
            do {
                
              
                tableView.deleteRows(at: [indexPath], with: .fade)
                try context.save()
            } catch {
                print("ERROR DELETE")
            }
           
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteCellID" ,for: indexPath) as! NoteCell
        
        let thisNote: Note!
        thisNote = nonDeletedNotes()[indexPath.row]
        let array: [UIColor] = [#colorLiteral(red: 0.8045124412, green: 0.763776958, blue: 0.9254626632, alpha: 1), #colorLiteral(red: 0.8732218146, green: 0.7138105035, blue: 0.9272833467, alpha: 1) , #colorLiteral(red: 0.9445775151, green: 0.8938065171, blue: 0.9744563699, alpha: 1), #colorLiteral(red: 0.988660872, green: 0.8662791848, blue: 0.9515206218, alpha: 1) ]
        noteCell.titleLabel.text = thisNote.title
        noteCell.descLabel.text = thisNote.desc
        noteCell.backgroundColor = array.randomElement()
    
        

        if let currentImage = thisNote.image {

            let image = UIImage(data: thisNote.image ?? Data())
            noteCell.savedImage.image = image
        }
        
        return noteCell
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        {
            return nonDeletedNotes().count
        }
        
        override func viewDidAppear(_ animated: Bool)
        {
            tableView.reloadData()
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        {
            self.performSegue(withIdentifier: "editNote", sender: self)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            if(segue.identifier == "editNote")
            {
                let indexPath = tableView.indexPathForSelectedRow!
                
                let noteDetail = segue.destination as? NoteDetailVC
                
                let selectedNote : Note!
                selectedNote = nonDeletedNotes()[indexPath.row]
                noteDetail!.selectedNote = selectedNote
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    
    
    
  
    
    
        
        
}
