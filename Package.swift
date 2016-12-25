import PackageDescription

let package = Package(
    name: "AtlasGenerator",
    targets: [ 
    	Target(name: "msdfgen"),
//       	Target(name: "MSDFGenBridge", dependencies:["msdfgen"]),
//    	Target(name: "AtlasGenerator", dependencies:["MSDFGenBridge"])
    ],
    dependencies: [
        .Package(url: "https://github.com/jkandzi/Progress.swift", majorVersion: 0)
    ]
)
