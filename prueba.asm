org 0x8000
bits 16
section .data
    mensaje db 'Max', 0  ; El mensaje a mostrar en pantalla
    x db 40              ; Posición X inicial (columna)
    y db 12              ; Posición Y inicial (fila)

section .bss
    ; Aquí puedes declarar variables temporales si es necesario

section .text
    ; Punto de entrada del programa
    start:
        ; Mostrar el texto "Max" por primera vez
        call dibujar_mensaje

        ; Bucle principal
    bucle:
        ; Capturar la entrada del teclado
        mov ah, 0x00
        int 0x16           ; Espera a una tecla

        ; Verificar si es una tecla de flecha (código extendido 0xE0)
        cmp al, 0xE0
        jne bucle          ; Si no es una tecla de flecha, sigue esperando

        ; Ahora lee la tecla real
        mov ah, 0x00
        int 0x16
        cmp al, 0x48       ; Flecha arriba
        je mover_arriba
        cmp al, 0x50       ; Flecha abajo
        je mover_abajo
        cmp al, 0x4B       ; Flecha izquierda
        je mover_izquierda
        cmp al, 0x4D       ; Flecha derecha
        je mover_derecha

        ; Si no es una flecha, vuelve a esperar
        jmp bucle

    mover_arriba:
        dec byte [y]        ; Mover hacia arriba (disminuir Y)
        call dibujar_mensaje
        jmp bucle

    mover_abajo:
        inc byte [y]        ; Mover hacia abajo (aumentar Y)
        call dibujar_mensaje
        jmp bucle

    mover_izquierda:
        dec byte [x]        ; Mover hacia la izquierda (disminuir X)
        call dibujar_mensaje
        jmp bucle

    mover_derecha:
        inc byte [x]        ; Mover hacia la derecha (aumentar X)
        call dibujar_mensaje
        jmp bucle

    dibujar_mensaje:
        ; Borra la pantalla
        mov ah, 0x02         ; Colocar cursor
        xor bh, bh           ; Página 0
        mov dh, [y]          ; Fila
        mov dl, [x]          ; Columna
        int 0x10

        ; Imprimir el mensaje "Max"
        mov ah, 0x0E         ; Modo TTY de impresión de caracteres
        mov si, mensaje
    escribir_letra:
        lodsb                ; Cargar el siguiente byte de mensaje
        cmp al, 0
        je fin_dibujo        ; Fin si encuentra el terminador
        int 0x10             ; Mostrar el carácter
        jmp escribir_letra

    fin_dibujo:
        ret
