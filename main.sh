#!/bin/bash

# Muestra los discos externos
# Pide al usuario que seleccione un dispositivo
select_disk() {
    echo "Discos externos conectados:"
    echo "Nombre | Ruta   | Tamaño | Modelo"
    lsblk -o NAME,PATH,SIZE,MODEL | grep "sd"
    echo ""
    echo "Por favor, introduce el nombre del dispositivo que deseas seleccionar (por ejemplo, sdb1):"
    read dispositivo
}

# Verifica si el dispositivo seleccionado existe
verify_if_disk_exists() {
    if lsblk | grep -q "$dispositivo"; then
        echo "Has seleccionado el dispositivo /dev/$dispositivo"
    else
        echo "El dispositivo seleccionado no existe. Por favor, verifica tu selección e intenta de nuevo."
    fi
}

show_items_disk() {
    echo "Elementos del disco seleccionado: /dev/$dispositivo"
    ls /mnt
}

mount_device() {
    mountpoint=$(sudo lsblk -no MOUNTPOINT /dev/"$dispositivo")

    if [ -n "$mountpoint" ]; then
        echo "El dispositivo /dev/$dispositivo ya está montado en $mountpoint."
    else
        sudo mount /dev/"$dispositivo" /mnt
        echo "El dispositivo /dev/$dispositivo ha sido montado en /mnt."
    fi
}

unmount_device() {
    path_mount_disk=/mnt
    mountpoint=$(lsblk -no MOUNTPOINT "$path_mount_disk")

    if [ -n "$mountpoint" ]; then
        sudo umount "$path_mount_disk"
        echo "El dispositivo /dev/$dispositivo ha sido desmontado de $mountpoint."
    else
        echo "El dispositivo /dev/$dispositivo no está montado."
    fi
}

#!/bin/bash

# Función para seleccionar carpetas
select_folders() {
    echo "Seleccione una o varias carpetas para hacer una copia de respaldo:"
    read -p "Ingrese la ruta de la carpeta (separadas por espacios): " folders

    # Verificar si las carpetas existen
    for folder in $folders; do
        if [ ! -d "/mnt/$folder" ]; then
            echo "La carpeta $folder no existe. Por favor, verifique la ruta e intente de nuevo."
            exit 1
        fi
    done

    echo "Copia de respaldo de las siguientes carpetas:"
    echo $folders
    # Agregue aquí el código para realizar la copia de respaldo de las carpetas seleccionadas
}

#!/bin/bash

# Función para seleccionar el destino de la copia de seguridad
select_backup_destination() {
    echo "Seleccione dónde desea guardar la copia de seguridad:"
    echo "1. Disco externo"
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
        echo "Ha seleccionado guardar la copia de seguridad en una carpeta local."
        read -p "Por favor, ingrese el nombre de la carpeta: " local_folder
        if [ -d "$HOME/backup/$local_folder" ]; then
            i=1
            while [ -d "$HOME/backup/$local_folder ($i)" ]; do
                i=$((i + 1))
            done
            mkdir "$HOME/backup/$local_folder ($i)"
            echo "Se está haciendo la copia de seguridad. Por favor espere un momento..."
            cp -r /mnt/* "$HOME/backup/$local_folder ($i)"
        else
            mkdir "$HOME/backup/$local_folder"
            echo "Se está haciendo la copia de seguridad. Por favor espere un momento..."
            cp -r /mnt/* "$HOME/backup/$local_folder"
        fi
        # Agregue aquí el código para guardar la copia de seguridad en la carpeta local
        ;;
    *)
        echo "Selección inválida. Por favor, intente de nuevo."
        select_backup_destination
        ;;
    esac

    echo "Se ha completado la copia de seguridad"
}

# MAIN
select_disk
verify_if_disk_exists
echo ""
mount_device
show_items_disk

select_folders
echo ""
select_backup_destination

#unmount_device
