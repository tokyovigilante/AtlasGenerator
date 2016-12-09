//
//  ConsoleIO.swift
//  AtlasGenerator
//
//  Created by Ryan Walklin on 8/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

import Foundation

class ConsoleIO {
    
    class func printWelcome() {
        print("Multichannel SDF texture generator")
        print("----------------------------------")
        print("")
    }
    
    class func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        print("usage:")
        print("\(executableName) <fontname.ttf|otf>")
    }
}
