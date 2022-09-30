// swift-tools-version:5.1

/*
 SUITCase

 Copyright (c) 2020 Devexperts LLC

 See https://code.devexperts.com for more open source projects
*/

import PackageDescription

let package = Package(
    name: "SUITCase",
    products: [
        .library(
            name: "SUITCase",
            targets: ["SUITCase"])
    ],
    dependencies: [
        .package(url: "https://github.com/devicekit/DeviceKit.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "SUITCase",
            dependencies: ["DeviceKit"]),
        .testTarget(
            name: "SUITCaseTests",
            dependencies: ["SUITCase"])
    ]
)
