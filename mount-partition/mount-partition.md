Info taken from :
https://www.linuxbabe.com/desktop-linux/how-to-automount-file-systems-on-linux


To mount a new partition automatically at startup do

Make a mount point in /mnt directory. Use:

'''sh
sudo mkdir /mnt/<name-of-the-drive>

Check all disks with

'''sh
sudo blkid
'''

then find the name, UUID, and the type of disk. 

E.g:

/dev/sda6: LABEL="data" UUID="bef61dca-b734-469b-93c4-821a9a745a66" TYPE="ext4" PARTUUID="0a62b3d9-06

where '/dev/sda6' is the name of the disk, UUID='bef..' is the UUID and 'ext4' is the
disk type.

Then you will have to write those setting at the end of /etc/fstab like this:

UUID=bef61dca-b734-469b-93c4-821a9a745a66 /mnt/sda6 ext4  defaults  0 2 

(keep in mind that the data should be seppareted with a tab character)

defaults are the default permissions. This option allows read and write
operation. 

0 is the dump value, it usually is 0. 

2 have to do with the fsck program and how it do filesystem check. Swap is 0,
root file system is 1 and everything else is 2.
