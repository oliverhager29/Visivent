Visivent iOS App
================

This App is an iOS App that visualizes events from various datasources in different maps and animates them.

See README.pdf for a detailed functional description

The App source code must be fetched in the following way:

```sh
The App source code must be fetched in the following way:
# install git large file system tools:
# With Mac Port: sudo port install git-lfs
# with Homebrew: brew install git-lfs
# Or via download: https://github.com/github/git-lfs/releases/download/v1.1.1/git-lfs-darwin-amd64-1.1.1.tar.gz
# see https://git-lfs.github.com/
# After installation of git-lfs
# make a local directory
mkdir LocalProject
cd LocalProject
# clone git hub project
git clone https://github.com/oliverhager29/Visivent
cd Visivent
# download the large files Visivent.sqlite and worldcitiespop.txt (Github has a 100MBytes file limit so we have to use Github large file system)
git lfs fetch
git lfs checkout
# Please only open Xcode 7.2.1 the following way (only the workspace not the project!!!):
open Visivent.xcworkspace
```