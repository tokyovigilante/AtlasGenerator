//
//  main.swift
//  AtlasGenerator
//
//  Created by Ryan Walklin on 8/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

import Foundation


ConsoleIO.printWelcome()

if CommandLine.argc < 2 {
    print("no font provided")
    ConsoleIO.printUsage()
    exit(-1)
}

let atlasGenerator = AtlasGenerator()
atlasGenerator.staticMode()
