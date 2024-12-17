# Introduction

**Install any Python 3 package by renaming an exe!** WTF? Yes, really.

The repo contains an EXE file called "**install_1NSERT-PYPI-PKG-HERE.exe**". Replace '**1NSERT-PYPI-PKG-HERE**' with your Pypi package name. The installer will automatically download Python 3 (if it needs to), install your app, and make a start menu link to run it.

**The entry point is python.exe -m your-package /polyinstall.**

Add this to your package's __main__.py file. E.g:

```python3
if sys.argv[-1] == "/polyinstall":
    # Custom run code here.
    print("Hello, world!")
```
    
# Custom app icons

You can use a resource editor to change the installer icon for the EXE file. This is what will show up as the icon for your program when it's installed.

# Custom package mirror

The base URL for the installer is part of the EXE's file description field. Modifying this allows for the EXE to be patched with different package mirrors.
    
# How it works

Nullsoft, Inc, the company that created the goated and much loved Winamp also wrote another program that is incredibly under-rated. It's an installer system for Windows that offers support for Windows 95 to Windows 11 (including server versions.) I wrote a simple downloader for Python and make the installer itself the input system. This means that you can create a portable, single EXE for any Python package by renaming a file.
