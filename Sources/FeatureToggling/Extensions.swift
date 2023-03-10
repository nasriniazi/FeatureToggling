//
//  File.swift
//  
//
//  Created by nasrin niazi on 2023-02-13.
//

import Foundation

public extension Foundation.Bundle {
    static func currentModule(name: String) -> Bundle {
        var thisModuleName = name + "_" + name
        var url = Bundle.main.bundleURL
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            url = bundle.bundleURL.deletingLastPathComponent()
            thisModuleName = thisModuleName.appending("Tests")
        }
        url = url.appendingPathComponent("\(thisModuleName).bundle")
        guard let bundle = Bundle(url: url) else {
            fatalError("Foundation.Bundle.module could not load resource bundle: \(url.path)")
        }
        return bundle
    }
}
