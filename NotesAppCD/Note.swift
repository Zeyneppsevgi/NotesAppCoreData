//
//  Note.swift
//  NotesAppCD
//
//  Created by Zeynep Sevgi on 27.03.2023.
//

import CoreData

@objc(Note)
class Note: NSManagedObject
{
    @NSManaged var id: NSNumber!
    @NSManaged var title: String!
    @NSManaged var desc: String!
    @NSManaged var deletedDate: Date?
    @NSManaged var  image: Data?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var isFaved: Bool
}
