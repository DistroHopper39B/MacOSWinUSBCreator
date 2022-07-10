#!/bin/bash
echo "Welcome to Windows USB Creator, version 0.1!"
echo "Bug reports and feedback are always appreciated; after all, this is early alpha software."
confirmMacOS() { #Confirms that you're running macOS and not Linux, since this script depends on diskutil and hdiutil as well as /Volumes
    printf "Checking if you're using macOS... "
    if [[ $(uname) = 'Darwin' ]]; then
        printf "You're using macOS!\n"
    else
        printf "You're NOT using macOS! This script will only work on macOS, so don't try it on $(uname).\n"
        exit 1
    fi
}
#todo: implement admin account checker to prevent sudo from failing
getDiskPath() {
    echo "Please drag the USB drive icon from Finder to this Terminal window." # not ideal
    printf 'Drag your USB here: '
    read VOLUME_PATH
    echo "Your USB drive is $VOLUME_PATH"
    DISK_ID=$(mount | grep $VOLUME_PATH | cut -d " " -f 1 | cut -d "s" -f 1,2)
    echo "Your Disk ID is $DISK_ID"
}

partitionDisk() {
    echo "About to erase disk $VOLUME_PATH ($DISK_ID)."
    echo "PLEASE BE WARNED: ALL FILES ON ALL PARTITIONS OF $DISK_ID WILL BE WIPED WITH NO EASY WAY OF GETTING THEM BACK!!"
    printf "Please confirm (y/N): "
    read USER_CHOICE
    if [[ $USER_CHOICE == "y" ]] || [[ $USER_CHOICE == "Y" ]]; then
        echo "Note you may get a prompt asking if you want to allow Terminal to access a removable volume, select OK."
        echo "Erasing Disk..."
        diskutil partitionDisk $DISK_ID GPT exfat WinMedia 0b
        export VOLUME_PATH=/Volumes/WinMedia

    else
        echo "Abort."
        exit
    fi
}
transferWindowsISO() {

    printf "Please drag your Windows 8 (or later) 64-bit ISO here: "
    read WINDOWS_ISO
    echo "Mounting Windows ISO..."
    mkdir -p /tmp/WinISO
    hdiutil attach "$WINDOWS_ISO" -mountpoint /tmp/WinISO -nobrowse -noverify
    echo "Copying files: (this might take a while)"
    rsync --progress -ahz "/tmp/WinISO/" "/Volumes/WinMedia/" 
}
mountEFI() {
    echo "Copy complete. Now mounting the EFI (Reserved) partition."
    sudo -p "Please enter your password here: " mkdir -p /Volumes/EFI && sudo -p "Please enter your password here: " mount_msdos "$DISK_ID"s1 /Volumes/EFI
}
transferEFIDrivers() {
    echo "Downloading EFI drivers..."
    curl -o /tmp/uefi_ntfs.img https://raw.githubusercontent.com/pbatard/rufus/master/res/uefi/uefi-ntfs.img
    printf "Mounting EFI drivers..."
    hdiutil attach /tmp/uefi_ntfs.img -mountpoint /tmp/uefi_ntfs -nobrowse -noverify > /dev/null
    echo "done."
    echo "Copying EFI drivers to USB..."
    rsync --progress -ahz "/tmp/uefi_ntfs/" "/Volumes/EFI/"
}
cleanUp() {
    echo "Process complete, cleaning temporary files and unmounting partitions..."
    sync
    hdiutil detach /tmp/uefi_ntfs
    hdiutil detach /tmp/WinISO
    rm /tmp/uefi_ntfs.img
    diskutil unmountDisk $DISK_ID
    printf "Would you like to delete the original Windows ISO file? (Y/n): "
    read DEL_USER_CHOICE
    if [[ $DEL_USER_CHOICE == "n" ]] || [[ $DEL_USER_CHOICE == "N" ]]; then
        exit 0
    else
        rm $WINDOWS_ISO
        exit 0
    fi
}

confirmMacOS
getDiskPath $VOLUME_PATH $DISK_ID
partitionDisk $VOLUME_PATH $DISK_ID $USER_CHOICE
transferWindowsISO $DISK_ID 
mountEFI $DISK_ID
transferEFIDrivers
cleanUp $DISK_ID $WINDOWS_ISO