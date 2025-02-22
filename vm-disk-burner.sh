#!/bin/bash

function is_a_valid_vm_disk_image () {
    case "$1" in
    *.vmdk | *.vdi | *.vhd | *.vhdx )
            # it's valid
            echo true;
            ;;
    *)
            # it's not
            echo false;
            ;;
    esac
}

function is_a_valid_disk () {
    existDisk=$(fdisk -l $1)
    case "$existDisk" in
    "" )
            # it's not valid
            echo false;
            ;;
    *)
            # it's
            echo true;
            ;;
    esac
}

echo -e "vm-disk-burner 0.1 beta"
echo -e "NO WARRANTY. USE WITH CARE.\n"

sepLine=$(echo -$___{1..40} | tr -d ' ')
path=""
validDiskImage=false

while [ "$validDiskImage" == false ];
do
    read -e -p "path to disk image (vmdk/vdi/vhd[x])): " path

    if [ -f $path ];
    then
        valid_disk_image=$(is_a_valid_vm_disk_image $path)
        if [ "$valid_disk_image" == true ];
        then
            echo -e "\nDisk image exists"
            ls -lh $path
            echo -e "\n"
            validDiskImage=true
        else
            echo "File is not a disk image"
        fi
    else
        echo "File does not exist"
    fi
done

sleep 2
echo -e "List of disks"
echo "$sepLine"
sudo fdisk -l
echo -e "$sepLine\n"

target=""
validTargetDisk=false

while [ "$validTargetDisk" == false ];
do
    read -e -p "target disk: " target

    valid_target_disk=$(is_a_valid_disk $target)
    if [ "$valid_target_disk" == true ];
    then
        echo -e "\nValid target disk"
        fdisk -l $target
        echo -e "\n"
        validTargetDisk=true
    else
        echo "Target is not a disk"
    fi

done


echo -e "mounting disk image ..."
# we enable ndb to read disk image, max 8 partitions, 2 ndb devices
modprobe nbd max_part=8 nbds_max=2

# mount disk image with nbd
filename=$(basename -- "$path")
extension="${filename##*.}"
filename="${filename%.*}"
qemu-nbd -c /dev/nbd0 -f $extension $path
echo -e "mounting disk image done"


# burning the data
echo -e "burning disk image to disk ..."
echo -e "\nburning $path to $target in progress"
dd if=/dev/nbd0 of=$target bs=64M status=progress
echo -e "burning disk image to disk done"


# disable ndb
echo -e "dismounting disk image ..."
qemu-nbd --disconnect /dev/nbd0
sleep 2
rmmod nbd
echo -e "dismounting disk image done"


# fix partition table, expand partition
echo -e "fixing partition table ..."
echo -e "Fix\n" | parted ---pretend-input-tty -l $target
totalPartitions=$(partx -g $target | wc -l)
parted $target resizepart $totalPartitions 100%
echo -e "fixing partition table done"
