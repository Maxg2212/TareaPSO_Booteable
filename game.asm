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
secondsLeft    dw 60    ; Inicializar con el número de segundos deseados (1 minuto)
secondsunit    dw 48    ; Inicializar con las unidades  deseados (1 minuto)
secondsdecs    dw 54    ; Inicializar con las decenas  deseados (1 minuto)
currentColor   dw 0Ah   ; Color actual (por defecto, verde)
clockSeconds   dw 0     ; Variable que maneja los segundos del sistema

; Constantes    -----------------------------
width          dw 140h  ; El tamano del ancho de la pantalla 320 pixeles
height         dw 0c8H  ; El tamano del alto de la pantalla 200 pixeles


gameHeight     dw 46h   ; Define el tamano del alto area de juego 100 pixeles
gameWidth      dw 12ah  ; Define el tamano del ancho area de juego 150 pixeles
timerPosX      dw 19h   ; Posición X para decenas del temporizador
timerPosX2     dw 1ah   ; Posición X para unidades del temporizador
timerPosY      dw 15h   ; Posición Y para el temporizador


textColor      dw 150h  ; Color del texto para los menus
player_x       dw 03h   ; Posicion en x del jugador
player_y       dw 0ah   ; Posicion en y del jugador 
temp_player_x  dw 03h   ; Posicion temporal en x del jugador
temp_player_y  dw 0ah   ; Posicion temporal en y del jugador
color_player_x dw 03h   ; Posicion casilla en x del jugador (para pintar)
color_player_y dw 0ah   ; Posicion casilla en y del jugador (para pintar)
player_speed   dw 06h   ; Velocidad de movimiento del jugador
player_color   dw 0ah   ; Color por defecto del jugador (tortuga)
player_size    dw 05h   ; DImensiones del sprite de la tortuga (5x5)
player_dir     dw 00h   ; Ultima direccion que tuvo el jugador

; Texto del menu principal del juego -----------------

menu1    dw '      -----------------------        ', 0h
menu2    dw '      -  MY-NAME-BOOTEABLE  -        ', 0h
menu3    dw '      -      BIENVENIDO     -        ', 0h
menu4    dw '      -----------------------        ', 0h
menu5    dw '   Presione ENTER para continuar     ', 0h


m1  dw '#  #', 0h
m2  dw '####', 0h
m3  dw '####', 0h
m4  dw '#  #', 0h


a1  dw '####', 0h
a2  dw '#  #', 0h
a3  dw '####', 0h
a4  dw '#  #', 0h


x1  dw '#  #', 0h
x2  dw ' ## ', 0h
x3  dw ' ## ', 0h
x4  dw '#  #', 0h


; Menu de controles In-Game -------------------------

inGame1  dw '-------------------------------------', 0h
inGame2  dw '-            Controles              -', 0h
inGame3  dw '- Mover-> Flechas                   -', 0h
inGame4  dw '- Reset-> R | Terminar -> ESC       -', 0h
inGame5  dw '-------------------------------------', 0h
inGame6  dw 'Flecha derecha     -', 0h
inGame7  dw 'Flecha izquierda   -', 0h
inGame8  dw 'Flecha arriba      -', 0h
inGame9  dw 'Flecha abajo       -', 0h
inGame10 dw 'Modo normal       -', 0h

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


;cambio random
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

    mov     bx, m1             ; Selecciona el texto que quiere escribir
    mov     dh, 0eh                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 02h                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, m2             ; Texto que indica el nivel y el titulo de controles   
    inc     dh            
    mov     dl, 02h               
    call    drawText   

    mov     bx, m3             ; Indica los controles de movimiento del juego      
    inc     dh            
    mov     dl, 02h               
    call    drawText

    mov     bx, m4             ; Indica los controles para reiniciar y volver a menu principal
    inc     dh            
    mov     dl, 02h               
    call    drawText


    mov     bx, a1             ; Selecciona el texto que quiere escribir
    mov     dh, 0eh                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 07h                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, a2             ; Texto que indica el nivel y el titulo de controles   
    inc     dh            
    mov     dl, 07h               
    call    drawText   

    mov     bx, a3             ; Indica los controles de movimiento del juego      
    inc     dh            
    mov     dl, 07h               
    call    drawText

    mov     bx, a4             ; Indica los controles para reiniciar y volver a menu principal
    inc     dh            
    mov     dl, 07h               
    call    drawText



    mov     bx, x1             ; Selecciona el texto que quiere escribir
    mov     dh, 0eh                 ; Selecciona la coordenada y en pixeles donde se escribira
    mov     dl, 0ch                 ; Selecciona la coordenada X en pixeles donde se escribira               
    call    drawText                ; Llama a la funcion que lo coloca en pantalla

    mov     bx, x2             ; Texto que indica el nivel y el titulo de controles   
    inc     dh            
    mov     dl, 0ch               
    call    drawText   

    mov     bx, x3             ; Indica los controles de movimiento del juego      
    inc     dh            
    mov     dl, 0ch               
    call    drawText

    mov     bx, x4             ; Indica los controles para reiniciar y volver a menu principal
    inc     dh            
    mov     dl, 0ch               
    call    drawText



    ;Verifica la habilidad que esta en ejecucion para indicarla en pantalla

    mov     bx, [rightFlag]          ; Revisa si esta en modo derecha
    cmp     bx, 1
    je      drawInGameTextAux

    mov     bx, [leftFlag]          ; Revisa si esta en modo izquierda
    cmp     bx, 1
    je      drawInGameTextAux2

    mov     bx, [upFlag]          ; Revisa si esta en modo arriba
    cmp     bx, 1
    je      drawInGameTextAux4

    mov     bx, [downFlag]          ; Revisa si esta en modo abajo
    cmp     bx, 1
    je      drawInGameTextAux5
    
    jmp     drawInGameTextAux3       ; Ejecuta el modo sin habilidad en caso de no estar en ninguna de las mencionadas


    ret

drawInGameTextAux:

    mov     bx, inGame6              ; Dibuja el texto en pantalla indicando que esta modo derecha     
    mov     dl, 17h
    mov     dh, 11h               
    call    drawText
    ret

drawInGameTextAux2:

    mov     bx, inGame7              ; Dibuja el texto en pantalla indicando que esta modo izquierda     
    mov     dl, 17h
    mov     dh, 11h               
    call    drawText
    ret

drawInGameTextAux4:

    mov     bx, inGame8              ; Dibuja el texto en pantalla indicando que esta modo arriba     
    mov     dl, 17h
    mov     dh, 11h               
    call    drawText
    ret

drawInGameTextAux5:

    mov     bx, inGame9              ; Dibuja el texto en pantalla indicando que esta modo izquierda     
    mov     dl, 17h
    mov     dh, 11h               
    call    drawText
    ret

drawInGameTextAux3:

    mov     bx, inGame10              ; Dibuja el texto en pantalla indicando que esta modo normal     
    mov     dl, 17h
    mov     dh, 11h               
    call    drawText
    ret

drawText:                           ; FUNCION QUE SE ENCARGA DE DIBUJAR CADENAS DE CARACTERES EN PANTALLA

    cmp     byte [bx],0             ; Verifica si el texto ya se termino de dibujar en pantalla
    jz      exitRoutine             ; Vuelve al bucle principal si ya termino
    jmp     drawChar                ; Sino sigue al siguiente caracter

drawChar:                           ; FUNCION QUE SE ENCARGA DE DIBUJAR CARACTERES EN PANTALLA

    push    bx                      ; Agrega el valor del caracter a la pila de dibujo
    mov     ah, 02h                 ; Indica que se va a pintar un caracter en pantalla
    mov     bh, 00h                 ; Indica que el caracter se va a pintar en la pantalla actual
    int     10h                     ; Llama a la interrupcion de pintar en pantalla
    pop     bx                      ; Saca al caracter de la pila

    push    bx                      
    mov     al, [bx]                ; Guarda el caracter actual que se va a pintar
    mov     ah, 0ah                 ; Se mueve 10 unidades 
    mov     bh, 00h                 
    mov     bl, [textColor]         ; Establece el color que va a tener el caracter que se dibujara
    mov     cx, 01h                 ; Indica que solo un caracter va a ser dibujado
    int     10h                     ; Llama a la interrupcion de dibujo en pantalla
    pop     bx                      

    inc     bx                      ; Incrementa en 1 para leer el siguiente caracter
    inc     dl                      
    jmp     drawText                ; Devuelve al ciclo de dibujado principal

setRandomSpawn:                     ; FUNCION QUE PERMITE SPAWNEAR AL JUGADOR EN UNA POSICION ALEATORIA  

    mov ah, 02h                     ; Se setea el valor de ah necesario para que la interrupcion devuelva la hora del sistema
    int 0x1A                        ; Se ejecuta la interrupcion que devuelve la hora del sistema

    movsx ax, ch                    ; Se almacenan los minutos en un registro
    movsx bx, dh                    ; Se almacenan los segundos en un registro

    mul bx                          ; Se multiplican segundos x minutos para obtener un posicion aleatoria
    
    mov [player_y], bx              ; Asigna el valor calculado  a y
    mov [temp_player_y], bx         ; Guarda la misma coordenada en el temp y
    mov [player_x], bx              ; Asigna el valor calculado a x
    mov [temp_player_x], bx         ; Guarda la misma coordenada en el temp x

    ret                             ; Se devuelve al bucle principal

renderPlayer:                        ; FUNCION QUE PERMITE DIBUJAR AL JUGADOR EN PANTALLA.

    mov     cx, [player_x]           ; Posicion x donde sera dibujado
    mov     dx, [player_y]           ; Posicion y donde sera dibujado
    jmp     renderPlayerAux   

renderPlayerAux:                     ; FUNCION COMPLEMENTARIA QUE PERMITE DIBUJAR AL JUGADOR EN PANTALLA.

    mov    ah, 0ch                   ; Indica que se va a dibujar un pixel en pantalla
    mov    al, [player_color]        ; Indica el color del pixel (color del jugador)
    mov    bh, 00h                   ; Indica en que pagina lo va a dibujar (predeterminada)
    int    10h                       ; Llama a la interrupcion para dibujar en pantalla
    inc    cx                        ; Incremente en 1 el cx
    mov    ax, cx                   
    sub    ax, [player_x]            ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando anchura)
    cmp    ax, [player_size]         ; Verifica si el ax es mas grande que el tamano del jugador
    jng    renderPlayerAux           ; Si aun no es mas grande sigue dibujando la siguiente columna
    jmp    renderPlayerAux2          ; Sino salta a la siguiente funcion de dibujo (dibujar altura del sprite)

renderPlayerAux2:                    ; FUNCION COMPLEMENTARIA QUE PERMITE DIBUJAR AL JUGADOR EN PANTALLA.

    mov     cx, [player_x]           ; Restablece el valor de las columnas
    inc     dx                       ; Aumenta en la fila
    mov     ax, dx                  
    sub     ax, [player_y]           ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando altura)
    cmp     ax, [player_size]        ; Verifica si el ax es mas grande que el tamano del jugador
    jng     renderPlayerAux          ; Si aun no es mas grande sigue dibujando la siguiente fila
    ret                              ; Sino vuelve al bucle principal

makeMovements:                      ; FUNCION QUE SE ENCARGA DE DETECTAR LOS INPUTS DE TECLADO Y EJECUTAR LAS ACCIONES QUE CORRESPONDAN

    mov     ah, 01h                 ; Indica que se va a leer una entrada de teclado
    int     16h                     ; Ejecuta la interrupcion de teclado

    jz      exitRoutine             ; Si no se detecta ninguna tecla vuelve al bucle principal

    mov     ah, 00h                 ; Detecta que se presiono una tecla
    int     16h                     ; Ejecuta la interrupcion para saber el valor de la tecla presionada

    cmp     ah, 48h                 ; Si la tecla es : Flecha arriba
    je      playerUp                ; Mueve al jugador hacia arriba

    
    cmp     ah, 50h                 ; Si la tecla es : Flecha abajo
    je      playerDown              ; Mueve al jugador hacia abajo

    cmp     ah, 4dh                 ; Si la tecla es : Flecha derecha
    je      playerRight             ; Mueve al jugador hacia derecha

    cmp     ah, 4bh                 ; Si la tecla es : Flecha izquierda
    je      playerLeft              ; Mueve al jugador hacia izquierda

    cmp     ah, 13h                 ; Si la tecla es : r
    je      resetGame               ; Reinicia el juego

    cmp     al, 1Bh                 ; Si la tecla es : esc
    je      startProgram            ; EL juego termina y vuelve al menu principa


    ret

playerUp:

playerDown:

playerRight:

playerLeft:




paintLoop:                          ; BUCLE QUE SE ENCARGA DE PINTAR LA CASILLA DEL COLOR CORRESPONDIENTE (FILAS)

    mov     ah, 0ch                 ; Indica que se va a dibujar un pixel en pantalla
    mov     al, [currentColor]      ; Indica el color del pixel (color segun movimiento) 
    mov     bh, 00h                 ; Indica en que pagina lo va a dibujar (predeterminada)
    int     10h                     ; Llama a la interrupcion para dibujar en pantalla
    inc     cx                      ; Incrementa en 1 el cx 
    mov     ax, cx                  
    sub     ax, [color_player_x]    ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando anchura)
    cmp     ax, [player_size]       ; Verifica si el ax es mas grande que el tamano del jugador
    jng     paintLoop               ; Si aun no es mas grande sigue dibujando la siguiente columna
    jmp     paintLoop2              ; Sino salta a la siguiente funcion de dibujo (dibujar altura del sprite)

paintLoop2:                         ; BUCLE QUE SE ENCARGA DE PINTAR LA CASILLA DEL COLOR CORRESPONDIENTE (COLUMNAS)

    mov     cx, [color_player_x]    ; Restablece el valor de las columnas
    inc     dx                      ; Aumenta en la fila
    mov     ax, dx                  
    sub     ax, [color_player_y]    ; Resta 1 a la posicion del jugador para dibujar el siguiente pixel del sprite (dibujando altura)
    cmp     ax, [player_size]       ; Verifica si el ax es mas grande que el tamano del jugador
    jng     paintLoop               ; Si aun no es mas grande sigue dibujando la siguiente fila

    ret                             ; Sino vuelve al bucle principal 

resetGame:                          ; FUNCION QUE REINICIA EL JUEGO 

    call    clearCounter            ; Llama al reiniciador del temporizador y flags

    call    clearScreen             ; Llama al limpiador de pantalla 

    jmp     startGame               ; Vuelve a llamar al inicio de juego

clearCounter:                       ; FUNCION QUE SE ENCARGA DE REINICIAR EL TEMPORIZADOR Y LAS FLAGS

    mov     word [secondsLeft], 60  ; Reinicia los segundos restantes a 60 (1 mins)
    mov     word [secondsdecs], 54  ; Reinicia las decenas  restantes a 6 
    mov     word [secondsunit], 48  ; Reinicia las unidades restantes a 0 

exitRoutine:                        ; FUNCION QUE SE VOLVER A LOS CICLOS PRINCIPALES

    ret                             ; Permite salir de una rutina y vuelve al ciclo principal