//
//  File.swift
//  
//
//  Created by nasrin niazi on 2023-01-31.
//

import Foundation
import LogManager


final public class LocalProvider:FeatureToggleProvider {
    var featuresWithState :[FeaturesWithState] = []
    private let fileURL: URL
    
    public init(jsonURL: URL) {
        fileURL = jsonURL
        try? fetchFeatureToggles()
    }
    deinit{
        clearData()
    }
    let fm = FileManager.default
    
    fileprivate var cacheFilepath: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("cachedFeatures.json")
        return documentsDirectory
    }()
    
    private func loadCacheFile()throws{
        
        Log.featureTogglingLog.info("start LocalProvider-loadCacheFile Method")
        try self.decodeData(pathName: self.cacheFilepath){features in
            self.featuresWithState = features
            Log.featureTogglingLog.info("end of LocalProvider-loadCacheFile Method-features=\(features)")
        }
    }
    public func features() -> [FeaturesWithState] {
        return featuresWithState
    }
    
    //    public func fetchFeatureToggles(_ completion: @escaping FeatureToggleCallback) throws
    public func fetchFeatureToggles() throws{
        
        Log.featureTogglingLog.info("start LocalProvider-fetchFeatureToggles Method")
        if fm.fileExists(atPath: cacheFilepath.path){
            try loadCacheFile()
            if  featuresWithState.isEmpty {
                try loadDefaultConfig()
            }
        }
        else{
            try loadDefaultConfig()
        }
        Log.featureTogglingLog.info("LocalProvider-fetchFeatureToggles Method-completion==\(self.featuresWithState)")
        //        completion(self.featuresWithState)
    }
    public func updateFeatureToggleSource( editedFeatures:[FeaturesWithState])throws
    {
        Log.featureTogglingLog.info("start LocalProvider-updateFeatureToggleSource Method")
        do{
            try self.writeToFile(editedFeatures:editedFeatures)
            Log.featureTogglingLog.info("end of LocalProvider-updateFeatureToggleSource Method updated Features=\(self.featuresWithState)")
            
        } catch {}
    }
    private func loadDefaultConfig()throws{
        Log.featureTogglingLog.info("start LocalProvider-loadDefaultConfig Method")
        
        try self.decodeData(pathName: self.fileURL){features in
            self.featuresWithState = features
            Log.featureTogglingLog.info("end of LocalProvider-loadDefaultConfig Method-features=\(features)")
        }
    }
}
//MARK: Json Read and write
extension LocalProvider{
    private func decodeData(pathName: URL,completion: @escaping FeatureToggleCallback)throws{
        
        do{
            let jsonData = try Data(contentsOf: pathName)
            let decoder = JSONDecoder()
            let features = try decoder.decode([FeaturesWithState].self, from: jsonData)
            completion(features)
        }
        catch {
            Log.featureTogglingLog.error("\(FeatureTogglingErrors.loadError.description)")
            throw FeatureTogglingErrors.loadError}
    }
    
    private func writeToFile(editedFeatures:[FeaturesWithState])throws{
        do{
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let JsonData = try encoder.encode(editedFeatures)
            try JsonData.write(to: self.cacheFilepath)
            self.featuresWithState = editedFeatures
            
        }catch{
            Log.featureTogglingLog.error("\(FeatureTogglingErrors.updateError.description)")
            throw FeatureTogglingErrors.updateError}
    }
    
    @discardableResult
    public func clearData() -> Bool {
        Log.featureTogglingLog.info("start LocalProvider-clearData Method")
        if fm.fileExists(atPath: cacheFilepath.path) == false {
            return true
        }
        do {
            Log.featureTogglingLog.log("LocalProvider-removed json file at path \(self.cacheFilepath)")
            
            try fm.removeItem(at: cacheFilepath)
            return true
        } catch {
            return false
        }
    }
}
public enum FeatureTogglingErrors:String,LocalizedError{
    case loadError = "error when loading features "
    case updateError = "error occured when updating features state"
    case unknownError = "error occured"
    public var description: String { return NSLocalizedString(self.rawValue, comment: "FeatureToggling")
    }
}
//just for unit test
extension LocalProvider:Equatable{
    public static func == (lhs: LocalProvider, rhs: LocalProvider) -> Bool {
        return lhs.fileURL == rhs.fileURL && lhs.cacheFilepath == rhs.cacheFilepath
    }
    
}
