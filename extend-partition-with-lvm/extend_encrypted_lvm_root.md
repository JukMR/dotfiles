# Extending an Encrypted LVM Root (No Reinstall)

This guide shows how to add a new partition to an **existing encrypted LVM root (`/`)**
and grow it **online**, without reinstalling Ubuntu.

---

## When This Works

- Root filesystem is: `LUKS → LVM → filesystem`
- You have a new empty partition anywhere on disk
- Disk order / contiguity does **not** matter

> Key idea: **You extend Volume Groups, not partitions.**

---

## One-Page Procedure

### 0. Inspect current layout
```bash
lsblk
```

Identify:
- Root LV: `/dev/<vg>/<lv>`
- Existing encrypted device
- New free partition (e.g. `/dev/nvme0n1p7`)

---

### 1. Encrypt the new partition (recommended)
```bash
sudo cryptsetup luksFormat /dev/<new-partition>
sudo cryptsetup open /dev/<new-partition> crypt-new
```

---

### 2. Create an LVM Physical Volume
```bash
sudo pvcreate /dev/mapper/crypt-new
```

---

### 3. Extend the existing Volume Group
```bash
sudo vgextend <vg-name> /dev/mapper/crypt-new
```

Verify:
```bash
vgdisplay <vg-name>
```

---

### 4. Extend the root Logical Volume
Use all available free space:
```bash
sudo lvextend -l +100%FREE /dev/<vg-name>/<lv-name>
```

---

### 5. Grow the filesystem (online)

**ext4**
```bash
sudo resize2fs /dev/<vg-name>/<lv-name>
```

**xfs**
```bash
sudo xfs_growfs /
```

---

### 6. Persist encryption across reboots (CRITICAL)

Get UUID:
```bash
sudo blkid /dev/<new-partition>
```

Edit crypttab:
```bash
sudo nano /etc/crypttab
```

Add:
```
crypt-new UUID=<uuid> none luks
```

Rebuild initramfs:
```bash
sudo update-initramfs -u
```

---

### 7. Verify
```bash
df -h /
lsblk
```

Root (`/`) should now span multiple encrypted devices.

---

## Common Mistakes

- Trying to resize partitions instead of LVM
- Forgetting `/etc/crypttab`
- Mixing encrypted and plaintext PVs
- Reinstalling unnecessarily

---

## Optional Power Moves

### Avoid double passphrase prompt
```bash
sudo cryptsetup luksAddKey /dev/<new-partition>
```

### Snapshot before risky changes
```bash
sudo lvcreate -L 10G -s -n root_snap /dev/<vg>/<lv>
```

### Future disks
Repeat steps 1–5. No redesign needed.

---

## TL;DR
```
Encrypt → PV → VG → LV → resize FS → crypttab → initramfs
```

This is the canonical, zero-downtime way to scale an encrypted Linux system.
