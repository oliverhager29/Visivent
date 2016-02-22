# Visivent App
This App is an iOS App that visualizes events from various datasources in different maps and animates them.

See README.pdf for a detailed functional description

The App source code must be fetched in the following way:
\# make a local directory
mkdir LocalProject
cd LocalProject
# clone git hub project
git clone https://github.com/oliverhager29/Visivent
cd Visivent/Visivent
# Download large files from external Website (there is a 100MBytes file size limit and git lfs does not work)
wget https://www.webporting.com/Visivent/Visivent.sqlite
wget https://www.webporting.com/Visivent/worldcitiespop.txt
cd ..
# run Cocoa pod to retrieve and install third party libraries (DTHeatmap), see https://cocoapods.org
# You should get an output:
# Analyzing dependencies
# Downloading dependencies
# Using DTMHeatmap (1.0)
# Generating Pods project
# Integrating client project
# Sending stats
# Pod installation complete! There is 1 dependency from the Podfile and 1 total pod installed.
pod install
cd ..
wget https://www.webporting.com/Visivent/swifter.zip
unzip swifter.zip
cd Visivent
# Please only open Xcode 7.2.1 the following way (only the workspace not the project!!!):
open Visivent.xcworkspace
# In XCode right click on "Visivent" project, go to "Linked Frameworks and Libraries" on the right panel and
# add file "Swifter.xcodeproj" (Add other ...) in the extracted Swifter directory
# Wait for completion of processing the file
# Under Embedded Binaries add Frameworks -> SwifteriOS.frameworkiOS
# Wait for completion of processing the file
# Select menu item Product -> Clean
# Select menu item Product -> Build
# The project should be successfully built

