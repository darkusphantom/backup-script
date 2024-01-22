#!/bin/bash
# lib/backup.sh

source ./lib/other.sh

# Función para seleccionar el destino de la copia de seguridad
select_backup_destination() {
    echo "Seleccione dónde desea guardar la copia de seguridad:"
    echo "1. Disco externo (No disponible)"
    echo "2. Carpeta local"
    echo "3. Salir"
    read -p "Ingrese el número correspondiente a su elección: " choice
    echo ""

    case $choice in
    1)
        echo "Ha seleccionado guardar la copia de seguridad en un disco externo."
        #read -p "Por favor, ingrese la ruta del disco externo: " external_disk
        # Agregue aquí el código para guardar la copia de seguridad en el disco externo
        ;;
    2)
        create_backup_local
        save_backup_local
        ;;

    3)
        echo "Saliendo..."
        sleep 1
        leave_message
        sleep 2
        exit 0
        ;;
    *)
        echo "Selección inválida. Por favor, intente de nuevo."
        select_backup_destination
        ;;
    esac

    echo "Se ha completado la copia de seguridad"
}

# Función para seleccionar el destino de la copia de seguridad
select_backup_option() {
    echo "¿Desea realizar una copia de seguridad completa o solo las carpetas seleccionadas?"
    echo "1. Copia completa"
    echo "2. Copia por carpetas"
    read -p "Ingrese una opción: " option
    echo ""

    case $option in
    1)
        # Perform full backup
        echo "Ha seleccionado realizar una copia de seguridad completa."
        backup_all
        ;;
    2)
        # Perform selective backup
        echo "Ha seleccionado realizar una copia de seguridad por carpetas."
        select_folders
        echo ""
        select_backup_destination
        ;;
    *)
        echo "Opción inválida. Por favor, inténtelo de nuevo."
        select_backup_option
        ;;
    esac
}

create_backup_local() {
    # Prompt user to input the name of the local folder for backup
    echo "Ha seleccionado guardar la copia de seguridad en una carpeta local."
    read -p "Por favor, ingrese el nombre de la carpeta: " local_folder

    # Common logic for creating a new folder or adding a numeric suffix
    i=0
    while [ -d "$HOME/backup/$local_folder${i:+\ ($i)}" ]; do
        ((i++))
    done
    mkdir "$HOME/backup/$local_folder${i:+\ ($i)}"
    echo "Se está haciendo la copia de seguridad. Por favor espere un momento..."

    # Copy folders to the backup location
    for folder in "${folders[@]}"; do
        if [ ! -d "/mnt/$folder" ]; then
            echo "La carpeta $folder no existe. Por favor, verifique la ruta e intente de nuevo."
            exit 1
        fi
    done
}

# Función para guardar la copia de seguridad en una carpeta local
save_backup_local() {
    cp -r /mnt/"${folders[@]}" "$HOME/backup/$local_folder${i:+\ ($i)}"
}

# Función para realizar una copia de seguridad completa
backup_all() {
    echo "Se está realizando una copia de seguridad completa. Por favor, espere un momento..."

    create_backup_local

    # Copy all folders to the backup location
    cp -r /mnt/* "$HOME/backup/$local_folder${i:+\ ($i)}"

    echo "La copia de seguridad completa ha sido realizada con éxito."
}
