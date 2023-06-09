//
//  CourseCelebrationModel.swift
//  edX
//
//  Created by Salman on 10/02/2021.
//  Copyright © 2021 edX. All rights reserved.
//


class CourseCelebrationModel: NSObject {

    enum Keys: String, RawStringExtractable {
        case firstSection = "first_section"
        case celebrations = "celebrations"
    }

    let isFirstSection: Bool
    
    init(dictionary: [String : Any]) {
        isFirstSection = dictionary[Keys.firstSection] as? Bool ?? false
        super.init()
    }
    
    convenience init(json: JSON) {
        let celebrationJson = json[Keys.celebrations]
        
        self.init(dictionary: celebrationJson.dictionaryObject ?? [:])
    }
}
