//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by George McMullen on 3/7/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
    var filePathUrl: NSURL!                         // Location of the audio clip
    var title: String!                              // Title for the clip
    
    init(filepathurl: NSURL, title: String) {
        super.init()
        // Assign the passed variables to the class variables
        self.filePathUrl = filepathurl
        self.title = title
    }
}