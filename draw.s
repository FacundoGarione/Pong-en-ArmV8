	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ BITS_PER_PIXEL, 32

    draw_pixel: //(x, y, color) x=X1, y=X2, color=X5
    mov x6, SCREEN_WIDTH
    mul x6, x2, x6
    add x6, x1, x6
    lsl x6, x6, #2 
    add x6, x0, x6 //X6 = dirección de inicio + 4 * (x + (y * 640))
    str w5,[x6]
    ret

  //--------------------Dibujar rectangulo----------------------------------------

    rectangulo: //(x1, y1, x2, y2, color) x1 = X1, y1 = X2, x2 = X3, y2 = X4, color = X5
    sub sp, sp, #48
    str x1, [sp]
    str x2, [sp, #8]
    str x3, [sp, #16]
    str x4, [sp, #24]
    str x9, [sp, #32]
    str x30, [sp, #40]

    //Verifico que x1 e y1 sean menores a x2 e y2

    cmp x1, x3            // x1 > x2? 
    B.LE no_swap           
        mov x6, x1                
        mov x1, x3      
        mov x3, x6                

    cmp x2, x4            // y1 > y2?
    B.LE no_swap          
        mov x6, x2         
        mov x2, x4       
        mov x4, x6           
    no_swap:

    //dibujo
    mov x9, x1          

    draw_rectangulo:

    cmp x2, x4
    B.GT parar_rectangulo // si y1>y2, termine de dibujar
    cmp x1, x3         // si x1>x2, termine la linea
    B.GT subir_fila
    bl draw_pixel
    add x1, x1, 1    //x1++
    b draw_rectangulo

    subir_fila:
        mov x1, x9       
        add x2, x2, 1    //y1++
        b draw_rectangulo
    
    parar_rectangulo:

    ldr x30, [sp, #40]
    ldr x9, [sp, #32]
    ldr x4, [sp, #24]
    ldr x3, [sp, #16]
    ldr x2, [sp, #8]
    ldr x1, [sp]
    add sp, sp, #48
    ret 

    mov x0, x20

  //----------------------Dibujar circulo-----------------------------------------

    circulo: //X12 = pos X, X13 = pos Y, X14 = radio, X17 = radio^2, X5 = color
    sub sp, sp, #48
    str lr, [sp]
    str x12, [sp, #8]
    str x13, [sp, #16]
    str x14, [sp, #24]
    str x1, [sp, #32]
    str x2, [sp, #40]

    movz x9, 0                     
    movz x10, 0                    
    mov x0, x20                    
    mov x2, #SCREEN_HEIGH          

    c_loop1:
    mov x1, #SCREEN_WIDTH          

    c_loop0:
    sub x9, x12, x1                // dist en X al centro
    sub x10, x13, x2               // dist en Y al centro
    mul x9, x9, x9                 // x9 = X9^2
    mul x10, x10, x10              // x10 = X10^2
    add x9, x9, x10                // x9 = X9^2 + X10^2
    cmp x9, x17                    
    b.hi c_cont                    // si X9 > r^2 no pintar
    str w16, [x0]                   // Pintar

    c_cont:
    add x0, x0, #4                 // Siguiente pixel
    sub x1, x1, #1                 // Decrementar contador X
    cbnz x1, c_loop0               // Si no terminó la fila, salto
    sub x2, x2, #1                 // Decrementar contador Y
    cbnz x2, c_loop1               // Si no es la última fila, salto  

    ldr lr, [sp]
    ldr x12, [sp, #8]
    ldr x13, [sp, #16]
    ldr x14, [sp, #24]
    ldr x1, [sp, #32]
    ldr x2, [sp, #40]
    add sp, sp, #48

    mov x0, x20

    ret
