# MacOSWinUSBCreator
Shell script to create a UEFI-only (as of 0.1) Windows USB drive on macOS

## Prerequisites
- A Windows 8 or later 64-bit ISO file, downloaded from Microsoft
- A Mac with Internet access that you have administrator priviliges on
- An 8+ GB USB flash drive. **NOTE THAT IT ABSOLUTELY WILL BE WIPED DURING THIS PROCESS!**

## Usage
- Download and run the script. The easiest way to do this (which also circumvents Apple's notarization BS) is through the Terminal by typing:
```
curl -O https://raw.githubusercontent.com/DistroHopper39B/MacOSWinUSBCreator/main/MacOSWinUSBCreator.sh # Downloads the script
chmod +x MacOSWinUSBCreator.sh # Allows the Terminal to execute the script
./MacOSWinUSBCreator.sh # Runs the script
```
- Follow the instructions.
- On the target computer, **disable Secure Boot** if enabled. This is due to the UEFI:NTFS ExFAT UEFI drivers (used in this script) not being Secure Boot-signed by Microsoft, and macOS not being able to write to NTFS partitions. Secure Boot can be re-enabled once the first stage of installation is complete.
## Windows 11 Secure Boot Workaround
- Upon booting Windows 11 setup, press Shift-F10 (or Shift-Fn-F10) to open Command Prompt.
- Type "regedit" to open the Registry Editor.
- Navigate to HKEY_LOCAL_MACHINE\SYSTEM\Setup
- Right click on Setup, and select New -> Key. Name this key LabConfig.
- Right click on LabConfig, and selct New -> DWORD (32-bit). Name this DWORD value BypassTPMCheck.
- Double-click on BypassTPMCheck and change the value from 0 to 1.
- Right click on LabConfig, and selct New -> DWORD (32-bit). Name this DWORD value BypassRAMCheck.
- Double-click on BypassRAMCheck and change the value from 0 to 1.
- Right click on LabConfig, and selct New -> DWORD (32-bit). Name this DWORD value BypassSecureBootCheck.
- Double-click on BypassSecureBootCheck and change the value from 0 to 1.
- Close the Registry Editor.
- Close the Command Prompt.
- Set up Windows as usual.
## Special thanks to
- https://github.com/pbatard/uefi-ntfs for making this whole script possible 
- https://github.com/pbatard/rufus for the prebuild of UEFI:NTFS
## To Do
- Allow picking USB devices instead of having to drag them into the terminal
- Add Legacy and possible Hybrid boot support
- Allow resuming from a failure point (for example, if the EFI partition won't mount due to lack of priviliges, you won't have to copy over the entire Windows ISO again)
- Better error handling
- Automatic Windows 11 Workaround
- Secure Boot workarounds?
