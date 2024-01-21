#!/bin/bash

# Pide al usuario que seleccione un dispositivo
# y muestra la lista de disco disponibles
select_disk() {
    # Display a list of connected external disks with their name, path, size, and model
    echo "Discos externos conectados:"
    echo "Nombre | Ruta   | Tamaño | Modelo"
    lsblk -o NAME,PATH,SIZE,MODEL | grep "sd"
    echo ""

    # Prompt the user to input the name of the disk they want to select (e.g., sdb1)
    echo "Por favor, introduce el nombre del dispositivo que deseas seleccionar (por ejemplo, sdb1):"
    read dispositivo
}

# Verifica si el dispositivo seleccionado existe
verify_if_disk_exists() {
    # Check if the device name is not empty
    if [ -z "$dispositivo" ]; then
        echo "No has ingresado ningún nombre de dispositivo. Por favor, intenta nuevamente."
        select_disk
    fi

    # Check if the device path exists
    if [ -e "/dev/$dispositivo" ]; then
        echo "Has seleccionado el dispositivo /dev/$dispositivo"
    else
        echo "El dispositivo seleccionado no existe. Por favor, verifica tu selección e intenta de nuevo."
        select_disk
    fi
}

# Muestra la lista de carpetas dentro del disco seleccionado
show_items_disk() {
    echo "Carpetas del disco seleccionado: /dev/$dispositivo"
    ls /mnt
    #i=1
    #for folder in $(ls /mnt); do
    #    echo "$i. $folder"
    #    i=$((i + 1))
    #done
}

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

# Función para seleccionar carpetas
select_folders() {
    echo "Seleccione una o varias carpetas para hacer una copia de respaldo:"
    read -p "Ingrese la ruta de la carpeta (separadas por espacios): " folders

    # Verificar si las carpetas existen
    for folder in $folders; do
        if [ ! -d "/mnt/$folder" ]; then
            echo "La carpeta $folder no existe. Por favor, verifique la ruta e intente de nuevo."
            echo ""
            exit 1
        fi
    done

    echo "Copia de respaldo de las siguientes carpetas:"
    echo $folders
}

# Función para guardar la copia de seguridad en una carpeta local
save_backup_local() {
    # Prompt user to input the name of the local folder for backup
    echo "Ha seleccionado guardar la copia de seguridad en una carpeta local."
    read -p "Por favor, ingrese el nombre de la carpeta: " local_folder

    if [ -d "$HOME/backup/$local_folder" ]; then
        # If a folder with the same name already exists, add a numeric suffix
        i=1
        while [ -d "$HOME/backup/$local_folder ($i)" ]; do
            i=$((i + 1))
        done
        mkdir "$HOME/backup/$local_folder ($i)"
        echo "Se está haciendo la copia de seguridad. Por favor espere un momento..."

        # Copy folders to the backup location
        for folder in $folders; do
            cp -r /mnt/$folder "$HOME/backup/$local_folder ($i)"
            # Check if the folder exists in the source location
            if [ ! -d "/mnt/$folder" ]; then
                echo "La carpeta $folder no existe. Por favor, verifique la ruta e intente de nuevo."
                exit 1
            fi
        done
    else
        # Create a new folder for backup
        mkdir "$HOME/backup/$local_folder"
        echo "Se está haciendo la copia de seguridad. Por favor espere un momento..."

        # Copy folders to the backup location
        for folder in $folders; do
            cp -r /mnt/$folder "$HOME/backup/$local_folder"
            # Check if the folder exists in the source location
            if [ ! -d "/mnt/$folder" ]; then
                echo "La carpeta $folder no existe. Por favor, verifique la ruta e intente de nuevo."
                exit 1
            fi
        done
    fi
}

# Función para seleccionar el destino de la copia de seguridad
select_backup_destination() {
    echo "Seleccione dónde desea guardar la copia de seguridad:"
    echo "1. Disco externo (No disponible)"
    echo "2. Carpeta local"
    read -p "Ingrese el número correspondiente a su elección: " choice
    echo ""

    case $choice in
    1)
        echo "Ha seleccionado guardar la copia de seguridad en un disco externo."
        #read -p "Por favor, ingrese la ruta del disco externo: " external_disk
        # Agregue aquí el código para guardar la copia de seguridad en el disco externo
        ;;
    2)
        save_backup_local
        ;;
    *)
        echo "Selección inválida. Por favor, intente de nuevo."
        select_backup_destination
        ;;
    esac

    echo "Se ha completado la copia de seguridad"
}

# MAIN
main() {
    select_disk
    verify_if_disk_exists
    echo ""
    mount_device
    show_items_disk
    echo ""

    select_folders
    echo ""
    select_backup_destination

    unmount_device
    echo ""
    echo "Gracias por usar el programa <3"
    echo "No olvides seguirme en mis redes sociales como @darkusphantom"
    echo "Puedes ver algunos de mis proyectos en https://github.com/darkusphantom"
    echo "y visitar mi website: https://darkusphantom.com"
    sleep 2
}

main
