import PackageDescription

let package = Package(
    name: "AtlasGenerator",
    dependencies: [
        .Package(url: "https://github.com/jkandzi/Progress.swift", majorVersion: 0)
    ]
)
