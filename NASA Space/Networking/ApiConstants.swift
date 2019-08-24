//
//  ApiConstants.swift
//  NASA Space
//
//  Created by vikas on 21/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
extension NasaApi {
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.nasa.gov"
        static let ApiPath = "/planetary/apod"
    }
    
    struct URLKeys {
        static let StartDate = "start_date"
        static let EndDate = "end_date"
        static let APIKey = "api_key"
        static let ConceptTag = "concept_tags"
    }
    
    struct URLValues {
        static let NASAApiKey = "xuTLcvUXbSNKuvG0HokQaICJjBiNG98HfmfNL9i0"
        static let ConceptTag = "True"
    }
    
    struct ResponseKeys {
        static let ServiceVersion = "service_version"
        static let Title = "title"
        static let Date = "date"
        static let Explanation = "explanation"
        static let URL = "url"
        static let HDURL = "hdurl"
        static let MediaType = "media_type"
        static let ImageSet = "image_set"
        static let Copyright = "copyright"
    }
}
