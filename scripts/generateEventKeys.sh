#!/bin/bash

# Define el archivo de entrada y el archivo de salida
NAME_SPACE="jokers_ls_mod-"
INPUT_FILE="src/models/data/events.cairo"
OUTPUT_FILE="dojoEventKeys.ts"

# Limpia o crea el archivo de salida
echo "// Archivo generado automáticamente" > $OUTPUT_FILE

# Encuentra todos los nombres de los structs y genera los hashes
grep 'struct' $INPUT_FILE | awk '{print $2}' | while read -r EVENT_NAME; do
    # Ejecuta el comando sozo hash y captura solo el hash hexadecimal
    HASH=$(sozo hash "$NAME_SPACE$EVENT_NAME" | awk -F': ' '{print $2}')
    
    # Convierte el nombre del evento a mayúsculas y formatea con guiones bajos
    CONST_NAME=$(echo "$EVENT_NAME" | sed -E 's/([a-z])([A-Z])/\1_\2/g' | sed 's/_Event$/_EVENT/' | tr '[:lower:]' '[:upper:]')
    
    # Escribe el resultado en el archivo de salida con el formato especificado
    echo "export const $CONST_NAME = \"$HASH\";" >> $OUTPUT_FILE
done

# Mensaje de confirmación
echo "Archivo $OUTPUT_FILE generado exitosamente."
