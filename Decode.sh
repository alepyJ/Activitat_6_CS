#!/bin/bash

# Pedir al usuario que introduzca el número del diccionario
echo "Introduce el número del diccionario (1-70):"
read dic_number

# Formatear el nombre del archivo de diccionario basado en el número introducido
diccionario="diccionari_part_${dic_number}.txt"

# Verificar si el archivo de diccionario existe
if [ ! -f "$diccionario" ]; then
    echo "El archivo de diccionario no existe."
    exit 1
fi

start_time=$(date +%s)

# Archivo donde se guardarán los resultados
output_file="resultados_part_${dic_number}.txt"

# Limpiar el archivo de resultados si ya existe
echo "" > "$output_file"

# Contador de contraseñas probadas
count=0

# Total de contraseñas en el diccionario
total_passwords=$(wc -l < "$diccionario")
echo "Iniciando desencriptación, probando un total de $total_passwords contraseñas."

# Iterar sobre cada palabra en el diccionario seleccionado
cat "$diccionario" | while read PASSWORD
do
    count=$((count + 1))
    # Iterar sobre cada archivo cifrado
    for file in text-2.txt.enc text-3.txt.enc
    do
        # Intentar desencriptar con la contraseña actual
        openssl enc -pbkdf2 -d -aes-256-cbc -a -in "$file" -pass pass:$PASSWORD -out out.txt 2>/dev/null
        RET=$?

        # Comprobar si la desencriptación fue exitosa
        if [ $RET -eq 0 ]; then
            echo "Contraseña encontrada: $PASSWORD para el archivo $file" >> "$output_file"
            # Adjuntar el contenido de out.txt al archivo de resultados
            echo "Contenido de $file:" >> "$output_file"
            cat out.txt >> "$output_file"
            echo "----------------------------------------" >> "$output_file"
        fi
    done
    # Mostrar el progreso
    echo "Progreso: $count de $total_passwords contraseñas probadas."
done

end_time=$(date +%s)

# Calcular y mostrar el tiempo total de ejecución
echo "Tiempo de ejecución: $((end_time - start_time)) segundos"
echo "Resultados guardados en $output_file"
echo "Total de contraseñas probadas: $count"

