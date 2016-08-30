# Blitter - A Social Networking tool

An demonstration that uses the [Kitura web framework](https://github.com/IBM-Swift/Kitura) to produce a feed of posts that people can follow.

## Requires:

- XCode 8 beta 6
- 

## Quick start

1. Install Cassandra:

`brew install cassandra`
  
2. Set up the schemas:

`cqlsh -f blitter.sql`
  
## Generate an XCode project:

`swift package generate-xcodeproj -Xswiftc -I/usr/local/opt/openssl/include -Xlinker -L/usr/local/opt/openssl/lib`

## Building and testing on Mac Terminal

1. Build the project

`swift build -Xswiftc -I/usr/local/opt/openssl/include -Xlinker -L/usr/local/opt/openssl/lib`
  
2. Test the project

`swift test -Xswiftc -I/usr/local/opt/openssl/include -Xlinker -L/usr/local/opt/openssl/lib`

## Building and testing in Linux

1. Build the project

`swift build`
  
2. Test the project

`swift test`

## Using Docker

1. Build your image with:

`docker build -t blitter/latest .`

2. Run your image:

`docker run -t blitter/latest`

## License

Copyright 2016 IBM

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.