#!/bin/bash
# name   : check-boot.sh
# usage  : script to check boot-partition for changes
# author : one7two99@gmail.com
# version: 0.1
# date   : 19/06/18
#
bootpartition=/boot
checksumfile=~/boot.md5
checksumfilenew=~/boot.md5.new

case $1 in
  init)
    # create a file with checksums of all files in the boot partition
    echo && echo write checksums for $bootpartition to $checksumfile
    sudo find $bootpartition -type f -exec md5sum {} \; | sort -k 2 > $checksumfile
    # gpg-sign the checksumfile with a detached signature
    echo && echo create detached gpg-signature of $checksumfile
    gpg --output $checksumfile.sig --detach-sig $checksumfile
    ;;
  check)
    # verify signature of checksumfile
    echo && echo verify signure of $checksumfile
    gpg --verify $checksumfile.sig
    # create a new file with checksums of all files in the boot partition
    echo && echo create new checksums of $bootpartition
    sudo find $bootpartition -type f -exec md5sum {} \; | sort -k 2 > $checksumfilenew
    # compare recent checksums with the saved version
    echo && echo compare generated checksums with checksums in checksum file $checksumfile
    diff $checksumfile $checksumfilenew
    # remove temporary checksumfile
    sudo rm -Rf $checksumfilenew
    # Press Enter to continue
    echo && read -p "Press Enter to continue"
    exit 1
    ;;
  *)
    echo
    echo "Usage: $0 {init | check }"
    echo "creates and checks MD5 checksums for all files within the boot partition"
    echo
    echo "At least one of the two options need to be passed as argument,"
    echo "If no argument has been provided, this message will be shown."
    echo
    echo "  $0 init  : creates checksums of all files and store them in a file. File will be signed using GPG"
    echo "  $0 check : checks checksums of all files in boot against the checksum-file, created with init before"
    echo
    echo "Make sure to run $0 init at least once and after running any changes on /boot (ex. GRUB rebuild / kernel updates)"
    echo
    ;;
esac


