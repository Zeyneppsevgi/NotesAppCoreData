//
//  NoteCell.swift
//  NotesAppCD
//
//  Created by Zeynep Sevgi on 27.03.2023.
//

import UIKit

class NoteCell: UITableViewCell
{
    var isSaved: Bool?
    @IBOutlet weak var starImage: UIButton!
    @IBOutlet weak var savedImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var descLabel: UILabel!
    
    

    override func layoutSubviews() {
        super.layoutSubviews()
        print("ssaa")
        print(isSaved)
        if isSaved == true {
            starImage.setImage( UIImage(systemName: "star.fill"), for: .normal)
        } else {
            starImage.setImage( UIImage(systemName: "star"), for: .normal)
            
        }
    }
    @IBAction func starButtonClicked(_ sender: Any) {
        print("s")
        print(isSaved)
        if isSaved == true {
            starImage.setImage( UIImage(systemName: "star"), for: .normal)
        } else {
            starImage.setImage( UIImage(systemName: "star.fill"), for: .normal)
            
        }
      
       
    }
    
}
