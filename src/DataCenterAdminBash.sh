	#!/bin/bash

: '
SYNOPSIS
    Herramienta de administración para Data Centers en Bash.

DESCRIPTION
    Este script proporciona un menú interactivo con varias opciones para ayudar
    en las tareas de administración de un Data Center. Las opciones incluyen
    mostrar los procesos que más CPU consumen, los filesystems conectados,
    el archivo más grande en un directorio especificado, información de memoria,
    y conexiones de red activas.
'

: '
SYNOPSIS
    Muestra el menú principal con las opciones disponibles.
EXAMPLE
    show_menu
'
show_menu() {
    echo "1. Desplegar los cinco procesos que más CPU estén consumiendo en ese momento."
    echo "2. Desplegar los filesystems o discos conectados a la máquina."
    echo "3. Desplegar el nombre y el tamaño del archivo más grande almacenado en un disco o filesystem."
    echo "4. Mostrar información de memoria."
    echo "5. Número de conexiones de red activas actualmente."
    echo "0. Salir."
}

: '
SYNOPSIS
    Muestra los cinco procesos que más CPU están consumiendo en ese momento.
EXAMPLE
    show_top_processes
'
show_top_processes() {
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
}

: '
SYNOPSIS
    Muestra los filesystems conectados, incluyendo espacio usado y libre en bytes.
EXAMPLE
    show_filesystems
'
show_filesystems() {
    df -B1 | awk 'BEGIN { printf "%-20s %-15s %-15s\n", "Filesystem", "Size (bytes)", "Available (bytes)" }
                  NR>1 { printf "%-20s %-15s %-15s\n", $1, $2, $4 }'
}


: '
SYNOPSIS
    Muestra el archivo más grande en un directorio especificado por el usuario.
PARAMETER path
    Ruta del disco o filesystem donde buscar el archivo más grande.
EXAMPLE
    show_largest_file "/home/user"
'
show_largest_file() {
    read -p "Ingrese el path del disco o filesystem: " path
    find "$path" -type f -exec ls -s {} + | sort -n -r | head -n 1
}

: '
SYNOPSIS
    Muestra información de memoria, permitiendo al usuario elegir entre memoria disponible o libre.
DESCRIPTION
    Incluye validaciones para asegurar que los datos obtenidos no sean nulos antes de mostrar la información.
EXAMPLE
    show_memory_info
'
show_memory_info() {
    read -p "¿Desea ver la memoria disponible o la memoria libre? (disponible/libre): " mem_choice
    mem_info=$(free -b)
    if [[ -z "$mem_info" ]]; then
        echo "Error: No se pudo obtener la información de memoria."
        return
    fi

    if [[ "$mem_choice" == "disponible" ]]; then
        free_physical_memory=$(echo "$mem_info" | awk '/Mem:/ {print $7}')
        echo "Memoria Disponible: $free_physical_memory bytes"
    elif [[ "$mem_choice" == "libre" ]]; then
        free_physical_memory=$(echo "$mem_info" | awk '/Mem:/ {print $4}')
        echo "Memoria Libre: $free_physical_memory bytes"
    else
        echo "Opción no válida."
    fi
}

: '
SYNOPSIS
    Muestra el número de conexiones de red activas actualmente en estado ESTABLISHED.
EXAMPLE
    show_network_connections
'
show_network_connections() {
    netstat -an | grep ESTABLISHED | wc -l
}

while true; do
    show_menu
    read -p "Seleccione una opción: " choice
    case $choice in
        1) show_top_processes ;;
        2) show_filesystems ;;
        3) show_largest_file ;;
        4) show_memory_info ;;
        5) show_network_connections ;;
        0) break ;;
        *) echo "Opción no válida, intente de nuevo." ;;
    esac
done
