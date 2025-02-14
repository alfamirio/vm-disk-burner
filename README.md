# vm-disk-burner
Small bash script to burn a vmdk, vdi o vhd(x) to a usb drive/nvme-usb drive.
It prompts for the disk location and target unit to burnt the image.

# purpose
It is designed for fast v2p (virtual to physical).

# how it works
It used qemu-utils ndb to mount the vm disk image and later uses dd to burn the mounted image to a usb unit.
This way avoids the step of converting the compressed vm disk image to an uncompressed .img/.raw that can be burn
with Gnome-Disk or Rufus. So mostly about saving the unsparce/inflating step of using a raw image. 

# warning
Take extreme care when selecting the target disk, as it will dd the device.
NO WARRANTY. USE WITH CARE.