This info was taken from:

https://askubuntu.com/questions/810731/cant-create-folder-after-mounting-partition


How to fix partition owner

If you mounted a partition but you can't make a directory then you must change
ownership of the partition.

To do this you have to write the next command:

sudo su 
chown "Your user name":"Your group name" -R "partition name"

So, e.g.:

chown julian:julian -R /mnt/sda6
