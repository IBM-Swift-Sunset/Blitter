/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import PackageDescription

let package = Package(
    name: "TwitterClone",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kassandra",                   majorVersion: 0,  minor: 1),
        .Package(url: "https://github.com/IBM-Swift/Kitura.git",                  majorVersion: 0,  minor: 28),
        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git",              majorVersion: 14, minor: 0),
        .Package(url: "https://github.com/IBM-Swift/Kitura-CredentialsFacebook",  majorVersion: 0,  minor: 28)
        ]
)