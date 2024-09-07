org 0x8000
bits 16

jmp startProgram    ; Salta al inicio del programa

; Variables --------------------------

time           db 00h   ; Tiempo que representa los fps del programa
lastColor      dw 00h   ; Color de la casilla en donde se encuentra
rightFlag      dw 00h   ; Flag para indicar si el jugador esta hacia la derecha
leftFlag      dw 00h   ; Flag para indicar si el jugador esta hacia la izquierda
upFlag      dw 00h   ; Flag para indicar si el jugador esta hacia arriba
downFlag      dw 00h   ; Flag para indicar si el jugador esta hacia abajo
currentColor   dw 0Ah   ; Color actual (por defecto, verde)

; Constantes    -----------------------------
width          dw 140h  ; El tamano del ancho de la pantalla 320 pixeles
height         dw 0c8H  ; El tamano del alto de la pantalla 200 pixeles


gameHeight     dw 46h   ; Define el tamano del alto area de juego 100 pixeles
gameWidth      dw 12ah  ; Define el tamano del ancho area de juego 150 pixeles


textColor      dw 150h  ; Color del texto para los menus
name_x       dw 03h   ; Posicion en x del jugador
name_y       dw 0ah   ; Posicion en y del jugador 
temp_name_x  dw 03h   ; Posicion temporal en x del jugador
temp_name_y  dw 0ah   ; Posicion temporal en y del jugador
color_name_x dw 03h   ; Posicion casilla en x del jugador (para pintar)
color_name_y dw 0ah   ; Posicion casilla en y del jugador (para pintar)
name_speed   dw 06h   ; Velocidad de movimiento del jugador
name_color   dw 0ah   ; Color por defecto del jugador (tortuga)
name_size    dw 05h   ; DImensiones del sprite de la tortuga (5x5)
name_dir     dw 00h   ; Ultima direccion que tuvo el jugador

; Texto del menu principal del juego -----------------

menu1    dw '           -----------------------        ', 0h
menu2    dw '           -  MY-NAME-BOOTEABLE  -        ', 0h
menu3    dw '           -      BIENVENIDO     -        ', 0h
menu4    dw '           -----------------------        ', 0h
menu5    dw '      Presione ENTER para continuar       ', 0h


nombre1  dw '     MAX        ', 0h


; Menu de controles In-Game -------------------------

inGame1  dw '-------------------------------------', 0h
inGame2  dw '-            Controles              -', 0h
inGame3  dw '- Mover-> Flechas                   -', 0h
inGame4  dw '- Reset-> R | Terminar -> ESC       -', 0h
inGame5  dw '-------------------------------------', 0h

startProgram:                       ; FUNCION DE INICIO DEL PROGRAMA

    call    initDisplay             ; Llama al inicializador de la pantalla

    call    clearScreen             ; Llama al limpiador de pantalla

    call    clearCounter            ; Llama al limpiador del contador y las flags de las habilidades

    jmp     menuLoop                ; Salta al bucle del menu principal


startGame:                          ;FUNCION DE INICIO DE JUEGO

    call    setRandomSpawn          ; Llama a la funcion que permite spawnear aleatoriamente al jugador

    call    clearScreen             ; Llama al limpiador de pantalla

    call    drawInGameText          ; Dibuja el menu de controles dentro del juego

    jmp     gameLoop                ; Salta al bucle de juego principal


initDisplay:                        ; FUNCION INICIALIZADORA DEL MODO DE VIDEO

    mov     ah, 00h                 ; Establece el modo de video 
    mov     al, 13h                 ; llamando a la interrupcion 
    int     10h                     ; 10h con el codigo 13h de video VGA

    ret


menuLoop:                           ; BUCLE DEL MENU PRINCIPAL      

    call    checkPlayerMenuAction   ; Revisa si el usuario presiono ENTER para empezar el juego

    call    drawTextMenu            ; Dibuja el menu principal en pantalla

    jmp     menuLoop                ; Se llama asi misma hasta que se detecte el ENTER


gameLoop:                           ; BUCLE PRINCIPAL DEL JUEGO

    call    drawInGameText          ; Dibuja el menu de controles dentro del juego principal

    call    makeMovements           ; Revisa contanstemente las teclas para detectar cualquier movimiento del jugador en juego 

    call    renderPlayer            ; Permite dibujar al jugador en la posicion donde se encuentre

    jmp     gameLoop                ; Se llama asi misma hasta que ocurra alguna accion por parte del usuario


; Funciones de renderizado del jugador y pintado ----------------

clearScreen:                        ; FUNCION QUE PERMITE ELIMINAR TODOS LOS ELEMENTOS EN PANTALLA

    mov     cx, 00h                 ; Establece la posicion inicial x de la pantalla
    mov     dx, 00h                 ; Establece la posicion inicial y de la pantalla
    jmp     clearScreenAux    

clearScreenAux:                     ; FUNCION COMPLEMENTARIA QUE ELIMINA LOS ELEMENTOS DE LA PANTALLA
    mov     ah, 0ch                 ; Seteo de valores para ejecutar la interrupcion 10h
    mov     al, 00h                 ; Seteo de valores para ejecutar la interrupcion 10h
    mov     bh, 00h                 ; Seteo de valores para ejecutar la interrupcion 10h
    int     10h                     ; Llama a la interrupcion para que se pinte de negro el fondo
    inc     cx                      ; Va incrementando el valor en la horizontal de la pantalla
    cmp     cx, [width]             ; Compara si ya se llego al ancho maximo sino sigue hasta pintar todo
    jng     clearScreenAux          

    jmp     clearScreenAux2   


clearScreenAux2:                    ; FUNCION COMPLEMENTARIA 2 QUE ELIMINA LOS ELEMENTOS DE LA PANTALLA

    mov     cx, 00h                 ; Reinicia la posicion en x
    inc     dx                      ; Incrementa en 1 la y para escribir en la siguiente linea
    cmp     dx, [height]            ; Compara si ya se llego a la altura maxima sino sigue hasta pintar todo
    jng     clearScreenAux          
    ret 

checkPlayerMenuAction:              ; FUNCION QUE SE ENCARGA DE DETECTAR SI EL JUGADOR ACCIONO ALGUNA TECLA EN EL MENU INICIO
    mov     ah, 01h                
    int     16h                     ; Llama a la interrupcion que detecta movimiento en el teclado
    jz      exitRoutine             ; Si no se presiona nada se retorna al bucle del juego principal
    mov     ah, 00h                 
    int     16h                     ; Llama a la interrupcion de movimiento en el teclado nuevamente
    cmp     al, 0Dh                 ; Verifica si la tecla presionada es ENTER
    je      startGame               ; Si es asi entonces inicia el juego

    ret                             ; Si ningun escenario pasa, devuelve al bucle prinicipal


drawTextMenu:                       ; FUNCION QUE SE ENCARGA DE PRINTEAR EL MENU PRINCIPAL EN PANTALLA

    mov     bx, [textColor]         ; Establece el color del texto para pintar el Menu Principal

    mov     bx, menu1               ; Selecciona el texto que quiere escribir
    mov     dh, 07h                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada x en pixeles donde se escribira
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, menu2           
    inc     dh                      ; Se aumenta el valor de y para seguir pintando los demas textos en la linea siguiente.
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu3            
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu4           
    inc     dh                      
    mov     dl, 02h                 
    call    drawText                

    mov     bx, menu5           
    mov     dh, 10h                     
    mov     dl, 02h                 
    call    drawText                

    ret


drawInGameText:                     ; FUNCION QUE SE ENCARGA DE PRINTEAR EL MENU DE CONTROLES EN PANTALLA


    mov     bx, [textColor]         ; Establece el color del texto para pintar el texto In Game

    mov     bx, inGame1             ; Selecciona el texto que quiere escribir
    mov     dh, 0ch                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, inGame2             ; Texto que indica el nivel y el titulo de controles   
    inc     dh            
    mov     dl, 02h               
    call    drawText   

    mov     bx, inGame3             ; Indica los controles de movimiento del juego      
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame4             ; Indica los controles para reiniciar y volver a menu principal
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame5             ; Indica los controles para activar las diferentes habilidades (pintar, borrar)
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame6             ; Indica en tiempo real cual habilidad esta activada
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, inGame10             ; Decoracion para cerrar la caja de controles
    mov     dh, 12h          
    mov     dl, 02h               
    call    drawText
