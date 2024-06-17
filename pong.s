	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ BITS_PER_PIXEL, 32
    .equ BALL_SPEED, 1

	.equ GPIO_BASE,    0x3f200000
	.equ GPIO_GPFSEL0, 0x00
	.equ GPIO_GPLEV0,  0x34
	.equ GPIO_TECLA_W, 0x02
	.include "draw.s"

	.globl main

main:
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	movz x5, 0x00, lsl 16
	movk x5, 0x0000, lsl 00	
	bl pintar_pantalla

	mov x0, x20
	movz x5, 0xFF, lsl 16
	movk x5, 0xFFFF, lsl 00

	mov x1, #589
	mov x2, #199
	mov x3, #599
	mov x4, #279
	bl rectangulo
    mov x22, x2
    mov x23, x4
	mov x0, x20

	mov x1, #50
	mov x2, #199
	mov x3, #60
	mov x4, #279
    mov x24, x2
    mov x25, x4
	bl rectangulo

	mov x0, x20
	movz x16, 0xFF, lsl 16
	movk x16, 0xFFFF, lsl 00

    mov x14, #3
    mul x17, x14, x14
    mov x12, #320
    mov x13, #240
    bl circulo

	mov x0, x20
	mov x7, BALL_SPEED
	mov x8, BALL_SPEED

    mov x19, #0 //contador bola
	ldr x27, =15000 

//---------------- GPIO ------------------------------------

  // Setea gpios 0 - 9 como lectura
    mov x9, GPIO_BASE
    str wzr, [x9, GPIO_GPFSEL0]

    movz x15, 0x001F, lsl 00
start:
leer_GPIO_start:
    // Lee el estado de los GPIO 0 - 31
    ldr w10, [x9, GPIO_GPLEV0]
	and w11, w10, 0b00100000 //Mascara que lee la spacebar
    movz x15, 0x0008, lsl 00
delay_loop_start:
    sub x15, x15, 1
    cbnz x15, delay_loop_start

    cmp x11, xzr                
    beq leer_GPIO_start

InfLoop:	// Setea gpios 0 - 9 como lectura
	mov x9, GPIO_BASE
	str wzr, [x9, GPIO_GPFSEL0]


	movz x15, 0x001F, lsl 00

leer_GPIO:
	// Lee el estado de los GPIO 0 - 31
	ldr w10, [x9, GPIO_GPLEV0]
	
	//Mascara captura las 5 teclas que se pueden usar
	and w11, w10, 0b00111110 	//w, a, s, d o espacio
	
	//loop para perder tiempo 
	movz x15, 0x0008, lsl 00
delay_loop:
	sub x15, x15, 1
	cbnz x15, delay_loop

	cmp x11, xzr				
	beq move_ball
	//loopeo esperando un GPIO
	// Si la mascara capto alguno de los bits de las teclas que filtre, va a ser
	//distinto de 0, con lo que se corta el loop


    // Comprobar cada tecla
    cmp w11, 0b00000010        // w
    beq w_pressed
    cmp w11, 0b00001000        // s
    beq s_pressed
    cmp w11, 0b00000100        // a
    beq a_pressed
    cmp w11, 0b00010000        // d
    beq d_pressed	


    // Si ninguna tecla relevante es presionada, vuelve a leer
    b leer_GPIO

// Acciones pala derecha (W)
w_pressed:
    add x19, x19, #1
    cmp x19, x27  
    blt skip_ball_move

    mov x19, #0

    movz x16, 0x00, lsl 16
    movk x16, 0x0000, lsl 00
    bl circulo
    movz x16, 0xFF, lsl 16
    movk x16, 0xFFFF, lsl 00
    add x12, x12, x7
    add x13, x13, x8
	cmp x13, #3
	ble reverse_y
	cmp x13, #476
	bge reverse_y
	cmp x12, #576
	beq check_izq
	cmp x12, #55
	beq check_der
	cmp x12, #0
	beq main
	cmp x12, #639
	beq main
    bl circulo

    mov x1, #589
 	mov x2, #0
	mov x3, #639
	mov x4, #479 
	movz x5, 0x00, lsl 16
	movk x5, 0x0000, lsl 00
    bl rectangulo
	movz x5, 0xFF, lsl 16
	movk x5, 0xFFFF, lsl 00
    mov x0, x20
	mov x1, #589
	mov x2, x22
	mov x3, #599
	mov x4, x23
    sub x2, x2, #3
    sub x4, x4, #3
    cmp x2, #0
    ble sumar_pintar
    mov x22, x2
    mov x23, x4
    bl rectangulo                    
    b move_ball

// Acciones pala derecha (S)
s_pressed:

    add x19, x19, #1
    cmp x19, x27  
    blt skip_ball_move

    mov x19, #0

    movz x16, 0x00, lsl 16
    movk x16, 0x0000, lsl 00
    bl circulo
    movz x16, 0xFF, lsl 16
    movk x16, 0xFFFF, lsl 00
    add x12, x12, x7
    add x13, x13, x8
	cmp x13, #3
	ble reverse_y
	cmp x13, #476
	bge reverse_y
	cmp x12, #576
	beq check_izq
	cmp x12, #55
	beq check_der
	cmp x12, #0
	beq main
	cmp x12, #639
	beq main
    bl circulo

    mov x1, #589
 	mov x2, #0
	mov x3, #639
	mov x4, #479 
	movz x5, 0x00, lsl 16
	movk x5, 0x0000, lsl 00
    bl rectangulo
	movz x5, 0xFF, lsl 16
	movk x5, 0xFFFF, lsl 00
    mov x0, x20
	mov x1, #589
	mov x2, x22
	mov x3, #599
	mov x4, x23
    add x2, x2, #3
    add x4, x4, #3
    cmp x4, #479
    bge restar_pintar
    mov x22, x2
    mov x23, x4
    bl rectangulo
    b move_ball

// Acciones pala izquierda (A)
a_pressed:
    add x19, x19, #1
    cmp x19, x27  
    blt skip_ball_move

    mov x19, #0

    movz x16, 0x00, lsl 16
    movk x16, 0x0000, lsl 00
    bl circulo
    movz x16, 0xFF, lsl 16
    movk x16, 0xFFFF, lsl 00
    add x12, x12, x7
    add x13, x13, x8
	cmp x13, #3
	ble reverse_y
	cmp x13, #476
	bge reverse_y
	cmp x12, #576
	beq check_izq
	cmp x12, #55
	beq check_der
	cmp x12, #0
	beq main
	cmp x12, #639
	beq main
    bl circulo

    mov x1, #0
 	mov x2, #0
	mov x3, #60
	mov x4, #479 
	movz x5, 0x00, lsl 16
	movk x5, 0x0000, lsl 00
    bl rectangulo
	movz x5, 0xFF, lsl 16
	movk x5, 0xFFFF, lsl 00 
    mov x0, x20
	mov x1, #50
	mov x2, x24
	mov x3, #60
	mov x4, x25
    sub x2, x2, #3
    sub x4, x4, #3
    cmp x2, #0
    ble sumar_pintar
    mov x24, x2
    mov x25, x4
    bl rectangulo
    b move_ball

// Acciones pala izquierda (D)
d_pressed:
    add x19, x19, #1
    cmp x19, x27  
    blt skip_ball_move

    mov x19, #0

    movz x16, 0x00, lsl 16
    movk x16, 0x0000, lsl 00
    bl circulo
    movz x16, 0xFF, lsl 16
    movk x16, 0xFFFF, lsl 00
    add x12, x12, x7
    add x13, x13, x8
	cmp x13, #3
	ble reverse_y
	cmp x13, #476
	bge reverse_y
	cmp x12, #576
	beq check_izq
	cmp x12, #55
	beq check_der
	cmp x12, #0
	beq main
	cmp x12, #639
	beq main
    bl circulo

    mov x1, #0
 	mov x2, #0
	mov x3, #60
	mov x4, #479 
	movz x5, 0x00, lsl 16
	movk x5, 0x0000, lsl 00
    bl rectangulo
	movz x5, 0xFF, lsl 16
	movk x5, 0xFFFF, lsl 00
    mov x0, x20
	mov x1, #50
	mov x2, x24
	mov x3, #60
	mov x4, x25
    add x2, x2, #3
    add x4, x4, #3
    cmp x4, #479
    bge restar_pintar
    mov x24, x2
    mov x25, x4
    bl rectangulo
    b move_ball
//Pelota
move_ball:
    add x19, x19, #1
    cmp x19, x27  // Ajusta este valor para controlar la velocidad de la bola
    blt skip_ball_move

    // Restablece el contador y mueve la bola
    mov x19, #0

    movz x16, 0x00, lsl 16
    movk x16, 0x0000, lsl 00
    bl circulo
    movz x16, 0xFF, lsl 16
    movk x16, 0xFFFF, lsl 00
    add x12, x12, x7
    add x13, x13, x8
	cmp x13, #3
	ble reverse_y
	cmp x13, #476
	bge reverse_y
	cmp x12, #576
	beq check_izq
	cmp x12, #55
	beq check_der
	cmp x12, #0
	beq main
	cmp x12, #639
	beq main
    bl circulo

skip_ball_move:
    b InfLoop
//Reverse direccion
check_izq:
    mov x21, #479
    sub x21, x21, x24
	cmp x21, x24
    ble move_ball
    mov x21, #479
    sub x21, x21, x25
	cmp x21, x25
    bge reverse_x
    b move_ball

check_der:
    mov x21, #479
    sub x21, x21, x22
	cmp x21, x22
    bge move_ball
    mov x21, #479
    sub x21, x21, x23
	cmp x21, x23
    ble reverse_x
    b move_ball
reverse_y:
	sub x8, xzr, x8
	bl move_ball
reverse_x:
	sub x7, xzr, x7
	bl move_ball

//Limites de la pantalla (palas)
sumar_pintar:
    add x2, x2, #1
    add x4, x4, #1
    bl rectangulo
    b InfLoop
restar_pintar:
    sub x2, x2, #1
    sub x4, x4, #1
    bl rectangulo
    b InfLoop

//Funcion para pintar pantalla del color guardado en X5
pintar_pantalla:
	mov x0, x20
	mov x18, SCREEN_HEIGH         // Y Size
loop1:
	mov x17, SCREEN_WIDTH         // X Size
loop0:
	stur w5,[x0]  // Colorear el pixel N
	add x0,x0,4    // Siguiente pixel
	sub x17,x17,1    // Decrementar contador X
	cbnz x17,loop0  // Si no terminó la fila, salto
	sub x18,x18,1    // Decrementar contador Y
	cbnz x18,loop1  // Si no es la última fila, salto
	ret

//a

