//
//  TableViewTextFieldWithEditButton.swift
//  App411
//
//  Created by IosDeveloper on 26/08/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

protocol TableViewTextFieldWithEditButtonDelegate {
    
    func editDelegateMethod(_ sender: UIButton)
    func saveDelegateMethod()
    
}

class TableViewTextFieldWithEditButton: UITableViewCell {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textFieldEnterText: DesignableTextField!
    
    var delegate:TableViewTextFieldWithEditButtonDelegate?
    
    lazy var saveButton: DesignableButton = {
        
        let saveButton = DesignableButton(type: .custom)
        
        return saveButton
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal func allocSaveButton() {
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel!.font = UIFont(name: FontNameConstants.SourceSansProRegular, size: 15)!
        saveButton.backgroundColor = UIColor.red
        saveButton.cornerRadius = 5
        saveButton.clipsToBounds = true
        saveButton.setTitleColor(UIColor.white, for: .normal)
        
        saveButton.addTarget(self, action: #selector(SaveAction(_:)), for: .touchUpInside)
        
        contentView.addSubview(saveButton)
        
        let saveButtonConstraints : [NSLayoutConstraint] = [
            
            saveButton.leadingAnchor.constraint(equalTo: self.textFieldEnterText.trailingAnchor, constant: 5),
            saveButton.trailingAnchor.constraint(equalTo: self.cancelButton.leadingAnchor, constant: -5),
            saveButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            saveButton.heightAnchor.constraint(equalTo: self.cancelButton.heightAnchor),
            saveButton.widthAnchor.constraint(equalTo: self.cancelButton.widthAnchor)
            
        ]
        
        NSLayoutConstraint.activate(saveButtonConstraints)
    
    }
    
    
    @IBAction func SaveAction(_ sender: DesignableButton) {
        
        self.delegate?.saveDelegateMethod()
    }
    
    @IBAction func EditAction(_ sender: UIButton) {
        
        self.delegate?.editDelegateMethod(sender)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
