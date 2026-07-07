import ProjectDescription

let project = Project(
    name: "PopPangListKit",
    targets: [
        .target(
            name: "PopPangListKit",
            destinations: [.iPhone],
            product: .framework,
            bundleId: "com.poppang.poppanglistkit",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"]
        ),
        .target(
            name: "PopPangListKitDemo",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.poppang.demo.poppanglistkit",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Demo/Sources/**"],
            dependencies: [
                .target(name: "PopPangListKit"),
                .sdk(name: "Testing", type: .framework),
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Automatic",
                    "DEVELOPMENT_TEAM": "LGX4B4WC66",
                ]
            )
        ),
        .target(
            name: "PopPangListKitTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.poppang.poppanglistkit.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "PopPangListKit"),
            ]
        ),
    ],
)
