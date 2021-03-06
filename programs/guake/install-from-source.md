This info is extracted from:
https://guake.readthedocs.io/en/stable/user/installing.html


## Install from source
If you want to install Guake from its sources, please follow this procedure:

First, DO NOT USE TARBALLS GENERATED BY GITHUB on the Release Page. They are automatically generated and cannot be used alone. We use a package, namely PBR, that requires the full git history to work.

Checkout the HEAD of the source tree with:

$ git clone https://github.com/Guake/guake.git
make sure that you have the needed system dependencies (Python GTK, VTE, …) installed for your system. If you are unsure about the dependencies, you can run this script to install them:

$ ./scripts/bootstrap-dev-[debian, arch, fedora].sh run make
Note: Insert your distribution in the square brackets.

## To install Guake itself, use:

$ make
$ sudo make install
To uninstall, still in the source directory:

$ make
$ sudo make uninstall

## Tips for a complete Guake reinstallation (without system dependencies):

$ sudo make uninstall && make && sudo make install
$ # Or use this shortcut:
$ make reinstall  # (do not sudo it!)
