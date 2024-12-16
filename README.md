# Introduction

Easily install any Python package by renaming an exe! Yes, really!

Simply rename the provided install exe and add your Pypi package name after 'install_.' The installer will then download the highest version of Python 3 for the OS, install your app via pip, and create a launcher in the start menu. The entry point will be python.exe -m your-package /polyinstall.

Add this to your package's __main__.py file. E.g:

if sys.argv[-1] == "/polyinstall":
    # Custom run code here.
    print("Hello, world!")
    
# Custom app icons

You can use a resource editor to change the app icon for the EXE file. This is what will show up as the icon for your program when it's installed.

# Custom package mirror.

The base URL for the binary files that the installer downloads is part of the EXE's file description field. Modifying this allows for the EXE to be patched with different package mirrors.
    
# How it works

Nullsoft, Inc, the company that brought you the goated and much loved Winamp also wrote another program that is incredibly under-rated. It's an installer system for Windows that offers support all the way from Windows 95 to Windows 11. I wrote a simple downloader for Python so I can offer Desktop builds for my software in future.
