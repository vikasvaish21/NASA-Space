//
//  NasaApi.swift
//  NASA Space
//
//  Created by vikas on 21/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
import CoreData
class NasaApi{
    var session = URLSession.shared
    
    class func sharedInstance() -> NasaApi{
        struct Singleton{
            static var sharesInstance = NasaApi()
        }
        return Singleton.sharesInstance
    }

    
    func taskForGetMethod(parameters:[String:AnyObject],parseJSON:Bool,completionHandlerForGet: @escaping (_ result:Any?,_ error:Error?) -> Void) ->URLSessionDataTask{
        var params = parameters
        params.merge(dict: [URLKeys.APIKey: URLValues.NASAApiKey as AnyObject])
        var  url : URL = self.NasaUrlFromParameters(parameters:params)
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request,completionHandler: {
            (data,response,error) in
            func sendError(_ error: String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(nil,NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else{
                sendError("there was an error withh an request: \(String(describing:error))")
            return
            }
            
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else{
                sendError("no data eas returned by the request!")
                return
            }
            
            if parseJSON{
                self.converDataWithCompletionHandle(data,completionHandlerForConvertData : completionHandlerForGet)
            } else{
                completionHandlerForGet(data as AnyObject?, nil)
            }
        })
        task.resume()
        return task
    }
    
    
    func NasaUrlFromParameters(parameters:[String:AnyObject]) -> URL{
        let Components = NSURLComponents()
        Components.scheme = NasaApi.Constants.ApiScheme
        Components.host = NasaApi.Constants.ApiHost
        Components.path = NasaApi.Constants.ApiPath
        Components.queryItems = [NSURLQueryItem]() as [URLQueryItem]
        for (key,value) in parameters{
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            Components.queryItems!.append(queryItem as URLQueryItem)
        }
        return Components.url!
    }
    
    fileprivate func converDataWithCompletionHandle(_ data:Data, completionHandlerForConvertData: (_ result:Any?,_ error: NSError?) -> Void){
        var parsedResult : Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        }
        catch{
            let userInfo = [NSLocalizedDescriptionKey : "could not parse the data as JSON:'\(data)'"]
            completionHandlerForConvertData(nil,NSError(domain: "converDataWithCompletionHandle", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult,nil)
    }
}
extension Dictionary{
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict{
            updateValue(v, forKey: k)
        }
    }
}
