# Función para montar el dispositivo seleccionado
mount_device() {
    # Get the mount point of the device
    mountpoint=$(sudo lsblk -no MOUNTPOINT /dev/"$dispositivo")

    # Check if the device is already mounted
    if [ -n "$mountpoint" ]; then
        echo "El dispositivo /dev/$dispositivo ya está montado en $mountpoint."
    else
        # Mount the device to /mnt
        sudo mount /dev/"$dispositivo" /mnt
        echo "El dispositivo /dev/$dispositivo ha sido montado en /mnt."
    fi
}

# Función para desmontar el dispositivo seleccionado
unmount_device() {
    path_mount_disk=/mnt
    # Get the mount point of the device
    mountpoint=$(lsblk -no MOUNTPOINT /dev/"$dispositivo")

    if [ -n "$mountpoint" ]; then
        # Unmount the device
        sudo umount "$path_mount_disk"
        echo "El dispositivo /dev/$dispositivo ha sido desmontado de $mountpoint."
    else
        echo "El dispositivo /dev/$dispositivo no está montado."
    fi
}
