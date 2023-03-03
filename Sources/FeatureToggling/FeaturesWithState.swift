//
//  File.swift
//  
//
//  Created by nasrin niazi on 2023-01-31.
//

import Foundation
public struct FeaturesWithState:Codable {
    var feature: String
    var enabled: Bool
    enum CodingKeys: String, CodingKey {
        case feature = "feature"
        case enabled = "enabled"
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        feature = try values.decodeIfPresent(String.self, forKey: .feature)!
        enabled = try values.decodeIfPresent(Bool.self, forKey: .enabled)!
    }
}
extension FeaturesWithState {
    public init(feature:String,enabled:Bool){
        self.feature = feature
        self.enabled = enabled
    }
}
extension FeaturesWithState :Equatable{
    public static func == (lhs: FeaturesWithState, rhs: FeaturesWithState) -> Bool {
        return lhs.feature == rhs.feature && lhs.enabled == rhs.enabled
    }
}
