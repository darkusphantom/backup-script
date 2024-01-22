#!/bin/bash
# main.sh

source ./lib/device.sh
source ./lib/backup.sh
source ./lib/other.sh

# Pide al usuario que seleccione un dispositivo
# y muestra la lista de disco disponibles
select_disk() {
    # Display a list of connected external disks with their name, path, size, and model
    echo "Discos externos conectados:"
    echo "Nombre | Ruta   | Tamaño | Modelo"
    lsblk -o NAME,PATH,SIZE,MODEL | grep "sd"

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

# MAIN
main() {
    select_disk
    verify_if_disk_exists
    clear
    mount_device
    # echo "¿Desea realizar una copia de seguridad completa o solo las carpetas seleccionadas?"
    # echo "1. Copia completa"
    # echo "2. Copia por carpetas"
    # is_backup_all=0
    # read -p "Ingresa una opción: " is_backup_all
    # if is_backup_all == 1; then
    #     select_backup_destination
    #     cp -r mnt/* $HOME/backup/all_backup
    # else
    show_items_disk
    echo ""
    select_backup_option
    # fi
    echo ""
    unmount_device
    echo ""
    leave_message
    sleep 2
}

main
