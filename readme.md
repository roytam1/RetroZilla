# RetroZilla

RetroZilla is a fork of Gecko 1.8.1 for improved compatibility on the modern web, with Windows 95 and Windows NT 4.0 in mind. Right now, RetroZilla's rendering capabilities are pretty similar to Firefox 2.0's, but as RetroZilla progresses, so will its capabilities.

RetroZilla Suite is the primary target of RetroZilla, but code exists in the tree to build RetroZilla Browser (Firefox 2) and xulrunner.

### Supported Operating Systems
* Windows 95
* Windows 98
* Windows Me
* Windows NT 3.51
* Windows NT 4.0

This webpage is geared more towards building RetroZilla from source. To install RetroZilla, or to learn more about using it, [go to the RetroZilla website](https://rn10950.github.io/RetroZillaWeb/)

## Building

I currently do my release builds on Windows 2000 SP4 with Visual Studio 6.0 and MozillaBuild 1.2. This method works on Windows XP/2003 x86 as well.

1. You're going to need to install VC6, [MozillaBuild 1.2](https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-1.2.exe), [VC6 SP5](https://github.com/rn10950/RetroZillaWeb/releases/download/0/vs6sp5.exe) (not SP6) and [VC6 Processor Pack](https://github.com/rn10950/RetroZillaWeb/releases/download/0/vcpp5.exe).

2. Place your source somewhere in a directory without spaces if it's not already. I recommend something like C:\projects\RetroZilla\RetroZilla. 

3. Start `start-msvc6.bat` in C:\mozilla-build\. This will open a UNIX-type shell window. navigate to your source directory. It uses UNIX-style file paths with the Windows drive letters as the first child directory (e.g. C:\WINDOWS\System32 will be /c/WINDOWS/System32 in MSYS shell) 

4. Copy mozconfig-suite.txt to mozconfig (no extension). Open up your newly created mozconfig in a text editor. You're going to want to change the object directory, I recommend changing it to the parent directory of the source. Using my example for a source directory above, change
`mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/obj-sm95-release`
to 
`mk_add_options MOZ_OBJDIR=/c/projects/RetroZilla/obj-rzSuite-release`

4. Now just run `make -f client.mk configure build` from the MSYS shell and wait. On a VM running on a modern host, building should take 20-40 minutes. On XP-era desktops expect building to take about 1 hour and 20 minutes to 2 hours.

If start-msvc6.bat can't find your VC6 installation, add the following line to start-msvc6.bat, after "SET MOZILLABUILD=..."

`SET VC6DIR=C:\Program Files\Microsoft Visual Studio\VC98`

### 64-bit Build OSes
It is possible to build on Windows XP/2003 x64. The instructions from above are mostly the same, however you need to install [MozillaBuild 1.5](https://ftp.mozilla.org/pub/mozilla/libraries/win32/MozillaBuildSetup-1.5.exe) instead. 

**Important:** start-msvc6.bat must be run from a 32-bit command prompt. The MSYS shell will run inside a win32 console window instead of rxvt. To start a 32-bit command prompt, you can paste the following into the run dialog: `C:\WINDOWS\SysWOW64\cmd.exe`

I do not know if building works on Windows Vista/7/8.x/10/11. I suspect your biggest roadblock would be VC6.

## Incremental Builds
If you have already built RetroZilla and you would like to save time by building only a small subset of the program to test a change you made, run make from the corresponding folder in your object directory. Depending on what you changed, building should only take a few minutes.

EX: If you made a change to `retrozilla/xpfe/browser/resources/content/navigator.xul`, cd into `{OBJDIR}/xpfe/browser/resources/content` using MSYS shell and run `make`.

## Other Platforms (Mac/Linux/etc)
I do not have the time or resources to port to other platforms myself at this time, however I am more than willing to add patches to support other platforms as long as they don't break the main win32 version. All platform code from the Mozilla tree at 1.8.1 has been left in. Any ported binaries will be linked here as long as they are built without any uncommitted changes.

## Building an Installer
From the xpinstall folder in your object directory, run `make installer`.

## Contributing to RetroZilla
To learn more about contributing to RetroZilla, please read the [contributing page](contributing.md).

## Donating to RetroZilla
While RetroZilla will always remain free, countless hours went into working on it. If you would like to give a tip to show your appreciation, you may do so at my [PayPal doation page](https://www.paypal.com/donate/?hosted_button_id=RAMWYD65G5X5J).
