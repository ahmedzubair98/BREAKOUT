[org 0x0100]
jmp start

old_kbisr: dd 0
old_timer: dd 0
bar_col: dw 30
ball_row: dw 22
ball_col: dw 37
bricks_arr: dw 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1

;		up_0,down_2,r_up_4,r_d_6,l_u_8,l_d_10
ball_dir: dw 1, 0, 0 , 0, 0, 0
life: dw 6
starter: dw 0
score: dw 0
lives_str: db 'lives: '  ;strlen = 7
score_str: db 'score: '  ;strlen = 7
time_str: db 'time: '    ;strlen = 6
time: dw 120
ticks: dw 18
time_over: dw 0
time_over_str: db 'TIME OVER!!'  ;strlen = 11
level: dw 1
level_str: db 'Level: '		;strlen = 7
lvl_2_brick_col: dw 20, 40, 60
avoid_me_str: db '!AVOID_ME!'    ;strlen = 10
dir_brick: dw 0, 1, 0
game_over_str: db 'GAME OVER'	;strlen = 9


sound:
	push ax
	push bx
	push cx
	mov al, 182
	out 43h, al
	mov ax, 4560
	out 42h, al
	in al, 61h
	or al, 00000011b
	out 61h, al
	mov bx, 1
s1:
	mov cx, 65535
s2:
	dec cx
	jne s2
	dec bx
	jne s1
	in al, 61h
	and al, 11111100b
	out 61h, al
	pop cx
	pop bx
	pop ax
	ret
	
	
info_bar:
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	
	
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,7
	mov dh,24
	mov dl,10
	push cs
	pop es
	mov bp,lives_str
	int 0x10
	
	mov ax,18
	push ax
	mov ax,[cs:life]
	shr ax,1
	push ax
	call printnum
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,7
	mov dh,24
	mov dl,25
	push cs
	pop es
	mov bp,score_str
	int 0x10
	
	mov ax,32
	push ax
	mov ax,[cs:score]
	push ax
	call printnum
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,7
	mov dh,24
	mov dl,42
	push cs
	pop es
	mov bp,level_str
	int 0x10
	
	mov ax,50
	push ax
	mov ax,[cs:level]
	push ax
	call printnum
	
	cmp word[cs:time_over],1
	je info_bar_l1
	
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,6
	mov dh,24
	mov dl,60
	push cs
	pop es
	mov bp,time_str
	int 0x10
	
	mov ax,68
	push ax
	mov ax,[cs:time]
	push ax
	call printnum
	
	dec word[cs:ticks]
	cmp word[cs:ticks],0
	jne info_bar_quit
	dec word[cs:time]
	mov word[cs:ticks],18
	cmp word[cs:time],0
	jne info_bar_quit
	mov word[cs:time_over],1
	
info_bar_quit:
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax

	ret

info_bar_l1:
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0xc7
	mov cx,11
	mov dh,24
	mov dl,60
	push cs
	pop es
	mov bp,time_over_str
	int 0x10
	jmp info_bar_quit

	

bar:
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx

	mov ax,0xb800
	mov es,ax
	xor ax,ax
	mov al,23
	mov bl,80
	mul bl
	
	cmp word[cs:bar_col],90
	ja bar_l3
	cmp word[cs:bar_col],66
	ja bar_l2
;print bar
bar_l1: 
	add ax,[cs:bar_col]
	shl ax,1
	mov di,ax
	mov ax,0x1120
	mov cx,14

	rep stosw

	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax



	ret

bar_l2: 
	mov word[cs:bar_col],66
	jmp bar_l1
	
bar_l3:
	mov word[cs:bar_col],0
	jmp bar_l1

cls:
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	
	mov ax,0xb800
	mov es,ax
	xor di,di
	mov ax,0x0720
	mov cx,2000

	rep stosw
	
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax
	ret


restore:
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	mov word[starter], 0; to stop the ball
	mov ax,30
	mov [cs:bar_col],ax
	mov ax,22
	mov [cs:ball_row],ax
	mov ax,[cs:bar_col]
	add ax,7
	mov [cs:ball_col],ax
	xor si,si
restore_l1: 
	mov word[ball_dir+si],0
	add si,2
	cmp si,12
	jne restore_l1
	mov word[ball_dir+4],1
	dec word[life]
	
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax
	ret


ball_dir_check: 
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	jmp ball_dir_check_start_l0

;;start of this functiion is at the middle due to jmp short out of range

right_edge:
	cmp word[ball_row],0
	je right_edge_l3
	cmp word[ball_dir+4],1
	je right_edge_l1
	cmp word[ball_dir+6],1
	je right_edge_l2

right_edge_l1: 
	mov word[ball_dir+4],0
	mov word[ball_dir+8],1
	jmp right_edge_quit

right_edge_l2: 
	mov word[ball_dir+6],0
	mov word[ball_dir+10],1
	jmp right_edge_quit

right_edge_l3: 
	mov word[ball_dir+4],0
	mov word[ball_dir+10],1
	jmp right_edge_quit


right_edge_quit: 
	jmp ball_dir_check_quit



up_edge: 
	cmp word[ball_dir+8],1
	je up_edge_l1
	cmp word[ball_dir+4],1
	je up_edge_l2
	cmp word[ball_dir],1
	je up_edge_l0

up_edge_l1: 
	mov word[ball_dir+8],0
	mov word[ball_dir+10],1
	jmp up_edge_quit

up_edge_l2: 
	mov word[ball_dir+4],0
	mov word[ball_dir+6],1
	jmp up_edge_quit

up_edge_l0: 
	mov word[ball_dir],0
	mov word[ball_dir+2],1
	jmp up_edge_quit

up_edge_quit: 
	jmp ball_dir_check_quit
	
dead:
	dec word[cs:life]
	call restore
	jmp ball_dir_check_quit

;;;;;;;;;;;;;;;;;;;;
;;start of functiion
ball_dir_check_start_l0:
	cmp word[cs:ball_row],8
	jnb ball_dir_check_start
	cmp word[cs:level],1
	jne ball_dir_check_l1
	call brick_hit_check
	jmp ball_dir_check_start

ball_dir_check_l1:
	call brick_hit_check_lvl_2
	
ball_dir_check_start:
	cmp word[cs:ball_row],24
	je dead
	cmp word[cs:ball_col],79
	je right_edge
	cmp word[cs:ball_col],0
	je left_edge
	cmp word[cs:ball_row],0
	je up_edge
	cmp word[cs:ball_row],22
	je down_edge

	jmp ball_dir_check_quit


left_edge: 
	cmp word[ball_row],0
	je left_edge_l3
	cmp word[ball_dir+8],1
	je left_edge_l1
	cmp word[ball_dir+10],1
	je left_edge_l2



left_edge_l1: 
	mov word[ball_dir+8],0
	mov word[ball_dir+4],1
	jmp left_edge_quit

left_edge_l2: 
	mov word[ball_dir+10],0
	mov word[ball_dir+6],1
	jmp left_edge_quit

left_edge_l3: 
	mov word[ball_dir+8],0
	mov word[ball_dir+6],1
	jmp left_edge_quit

left_edge_quit: 
	jmp ball_dir_check_quit


down_edge:
	;;ax = start of bar
	;;bx = middle of bar
	;;cx = end of bar
	mov ax,[cs:bar_col]
	mov bx,ax
	add bx,7
	mov cx,bx
	add cx,7
	xor si,si
	add dx,0
	cmp [cs:ball_col],bx
	je down_edge_l1   ;on middle of bar
	ja down_edge_l2   ;above middle of bar
	jmp down_edge_l0  ;below middle of bar
	
down_edge_l1: 
	mov word[ball_dir+si],0
	add si,2
	cmp si,12
	jne down_edge_l1
	mov word[ball_dir],1
	jmp ball_dir_check_quit

down_edge_l2: 
	cmp [cs:ball_col],cx
	ja down_edge_quit
	mov word[ball_dir+si],0
	add si,2
	cmp si,12
	jne down_edge_l2
	mov word[ball_dir+4],1
	jmp ball_dir_check_quit
	

down_edge_l0: 
	cmp [cs:ball_col],ax
	jb down_edge_quit
	mov word[ball_dir+si],0
	add si,2
	cmp si,12
	jne down_edge_l0
	mov word[ball_dir+8],1
	jmp ball_dir_check_quit

down_edge_quit: 
	jmp ball_dir_check_quit





ball_dir_check_quit: 
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax

	ret


ball: 
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx

	mov ax,0xb800
	mov es,ax
	xor ax,ax
	mov al,[cs:ball_row]
	mov bl,80
	mul bl
	add ax,[cs:ball_col]
	shl ax,1
	mov di,ax
	mov ax,0x044f

	mov [es:di],ax


	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax

	ret


brick_lvl_2:
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	push ds
	
	push cs
	pop ds
	
	xor ax,ax
	mov bx,lvl_2_brick_col
	mov si,dir_brick

yar:	
	push word[bx]
	push ax
	call lvl_2_print_brick
	mov dx,7
	cmp word[si],0
	je inc_brick_col
	jne dec_brick_col
yar_l1:
	add ax,3
	add bx,2
	add si,2
	cmp ax,9
	jne yar
	
brick_lvl_2_quit:
	pop ds
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax
	ret
	
inc_brick_col:
	inc word[bx]
	cmp word[bx],66
	je invert_dir
	jmp yar_l1
	
dec_brick_col:
	dec word[bx]
	cmp word[bx],0
	je invert_dir
	jmp yar_l1
	
invert_dir:
	xor word[si],1
	jmp yar_l1
	
lvl_2_print_brick: 
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push es
	push si
	push di

	mov cx,14 ;length
	mov ax,0xb800
	mov es,ax
	xor ax,ax
	mov al,[bp+4]  ;row
	mov bl,80
	mul bl
	mov bx,[bp+6]  ;col
	add ax,bx
	shl ax,1
	mov di,ax
	cmp word[bp+4],3
	je lvl_2_print_brick_l1
	mov ax,0x2220
	jmp lvl_2_print_brick_l0
	
lvl_2_print_brick_l1:
	mov ax,0x4420
	
lvl_2_print_brick_l0	
	rep stosw
	cmp word[bp+4],3
	je lvl_2_print_brick_l2

lvl_2_print_brick_l3:
	pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp

	ret 4
	
lvl_2_print_brick_l2:
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0xc7
	mov cx,10
	mov dx,[bp+6]
	add dx,2
	mov dh,3
	push cs
	pop es
	mov bp,avoid_me_str
	int 0x10
	jmp lvl_2_print_brick_l3
	
	
	
	
brick_hit_check_lvl_2:
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	push ds
	
	push cs
	pop ds
	
	mov dx,14
	mov bx,lvl_2_brick_col
	xor ax,ax
	mov si,-1

	;; bari bari sari bricks dekhta
brick_hit_check_lvl_2_l1:
	
	push dx ; len
	push si ; dummy
	push word[bx] ; col
	push ax ; row
	call brick_hit
	

	add bx,2
	add ax,3
	cmp ax,9
	jne brick_hit_check_lvl_2_l1
		
	pop ds
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax
	ret
	
	
	
brick: 
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	push ds
	
	push cs
	pop ds

	xor bx,bx
	mov dx,10
	xor ax,ax
	mov si,bricks_arr

brick_l1: 
	cmp word[si],1
	jne no_print_brick
	push bx ; col
	push ax ; row
	call brick_l0

no_print_brick: 
	add si,2
	inc bx
	cmp bx,8
	jne brick_l1
	xor bx,bx
	add ax,3
	cmp ax,9
	jne brick_l1
	
	call check_lvl
	pop ds
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax
	ret

;print brick
brick_l0: 
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push es
	push si
	push di

	mov cx,9 ;length
	mov ax,0xb800
	mov es,ax
	xor ax,ax
	mov al,[bp+4]
	mov bl,80
	mul bl
	push ax
	mov ax,[bp+6]
	mov bx,10
	mul bx
	mov bx,ax
	pop ax
	add ax,bx
	shl ax,1
	mov di,ax
	
	
	
	cmp word[bp+4],0
	je rang_0
	cmp word[bp+4],3
	je rang_3
	cmp word[bp+4],6
	je rang_6
	
rang_0:
	mov ax,0x4420
	jmp rang_quit
rang_3:
	mov ax,0x2220
	jmp rang_quit
rang_6:
	mov ax,0x5520
	jmp rang_quit

rang_quit:
	
	rep stosw
	mov word[es:di],0x0720

	pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp

	ret 4
	
	
brick_hit_check:
	push ax
	push bx
	push cx
	push es
	push di
	push si
	push dx
	push ds
	
	push cs
	pop ds
	
	mov dx,9
	xor bx,bx
	xor ax,ax
	mov si,bricks_arr

	;; bari bari sari bricks dekhta
brick_hit_check_l1:
	cmp word[si],1
	jnz no_hit
	;;agr brick on to is function me chl jata
	
	push dx ;len = 9
	push si ;brick address
	push bx ; col
	push ax ; row
	call brick_hit
	
no_hit: 
	add si,2
	add bx,10
	cmp bx,80
	jne brick_hit_check_l1
	xor bx,bx
	add ax,3
	cmp ax,9
	jne brick_hit_check_l1
		
	pop ds
	pop dx
	pop si
	pop di
	pop es
	pop cx
	pop bx
	pop ax
	ret

;print brick
brick_hit: 
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push es
	push si
	push di

	mov cx,[bp+10] ;length
	mov ax,[bp+4] ;brick row
	mov bx,[bp+6] ;brick col
	mov si,[bp+8] ;brick_address
	
	;;dekhta agr brick row aur ball row equal
	cmp ax,[cs:ball_row]
	jne brick_hit_l1
	je brick_hit_l4
	
	;;dekhta agr brick row -1 == ball row
brick_hit_l1:
	mov dx,ax
	dec dx
	cmp dx,[cs:ball_row]
	jne brick_hit_l2
	je brick_hit_l3
	
	;;dekhta agr brick row+1 == ball row
brick_hit_l2:
	add dx,2
	cmp dx,[cs:ball_row]
	jne brick_hit_quit_inter
	je brick_hit_l3_lvl2
	
	;;agr brick row se upr ya neechay ball row ho phr
brick_hit_l3:
	cmp word[cs:level],2
	jne normal
	cmp word[cs:ball_dir],1
	je brick_hit_quit_inter
	cmp word[cs:ball_dir+4],1
	je brick_hit_quit_inter
	cmp word[cs:ball_dir+8],1
	je brick_hit_quit_inter
normal:
	cmp bx,[cs:ball_col]
	ja brick_hit_quit_inter   ;;agr ball col < brick ka starting col
	mov dx,[bp+6]
	add dx,cx
	cmp dx,[cs:ball_col]
	jae brick_hit_change_dir  ;;agr ball >= brick end col
	jmp brick_hit_quit   ;;ni to hit ni kr ra
	
brick_hit_l3_lvl2:
	cmp word[cs:level],2
	jne normal
	cmp word[cs:ball_dir+2],1
	je brick_hit_quit_inter
	cmp word[cs:ball_dir+6],1
	je brick_hit_quit_inter
	cmp word[cs:ball_dir+10],1
	je brick_hit_quit_inter
	jmp normal

;;jmp out of range se bachne k lye
brick_hit_quit_inter:
	jmp brick_hit_quit	
	
	;;ye is liye k agr ball brick ki kisi side p hit kre
	;; 0|----|  aesa scene
brick_hit_l4:
	cmp word[cs:level],2
	je brick_hit_quit
	dec bx
	cmp bx,[cs:ball_col]
	je brick_hit_change_dir  ;; 0|----| agr ye scene
	add bx,2
	add bx,cx
	cmp bx,[cs:ball_col]
	je brick_hit_change_dir  ;; |----|0 agr ye scene
	jmp brick_hit_quit

	
	
	;;ye directions on of ki hui
brick_hit_change_dir:
	call sound
	cmp word[cs:time_over],1
	je brick_hit_change_dir_idk
	push ax
	push si
	call inc_score
	
brick_hit_change_dir_idk
	cmp word[ball_dir],1
	je brick_hit_change_dir_l1
	cmp word[ball_dir+2],1
	je brick_hit_change_dir_l2
brick_hit_change_dir_l0:
	cmp word[ball_dir+4],1
	je brick_hit_change_dir_l3
	cmp word[ball_dir+6],1
	je brick_hit_change_dir_l4
	cmp word[ball_dir+8],1
	je brick_hit_change_dir_l5
	cmp word[ball_dir+10],1
	je brick_hit_change_dir_l6_inter



	;; ye idr islye kiun k tehami wala jmp out of range ka error ara tha
brick_hit_quit:
	pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp

	ret 8
	
	;;purana kam continue
	
brick_hit_change_dir_l6_inter:
	jmp brick_hit_change_dir_l6
	
brick_hit_change_dir_l1:
	mov word[ball_dir],0
	mov word[ball_dir+2],1
	cmp word[level],2
	je brick_hit_quit
	mov word[si],0
	jmp brick_hit_quit
	
brick_hit_change_dir_l2:
	mov word[ball_dir+2],0
	mov word[ball_dir],1
	cmp word[level],2
	je brick_hit_quit
	mov word[si],0
	jmp brick_hit_quit

brick_hit_change_dir_l3:
	mov word[ball_dir+4],0
	mov word[ball_dir+6],1
	cmp word[level],2
	je brick_hit_quit
	mov word[si],0
	jmp brick_hit_quit
	
brick_hit_change_dir_l4:
	mov word[ball_dir+6],0
	mov word[ball_dir+4],1
	cmp word[level],2
	je brick_hit_quit
	mov word[si],0
	jmp brick_hit_quit
	
brick_hit_change_dir_l5:
	mov word[ball_dir+8],0
	mov word[ball_dir+10],1
	cmp word[level],2
	je brick_hit_quit
	mov word[si],0
	jmp brick_hit_quit
	
brick_hit_change_dir_l6:
	mov word[ball_dir+10],0
	mov word[ball_dir+8],1
	cmp word[level],2
	je brick_hit_quit
	mov word[si],0
	jmp brick_hit_quit
	;;end

	
inc_score:
	push bp
	mov bp,sp
	push ax
	push bx
	
	mov ax,[bp+4] ;brick_address
	cmp ax,-1
	je inc_score_l1
	sub ax,bricks_arr
	cmp ax,16
	jb add_30
	cmp ax,32
	jb add_20
	cmp ax,48
	jb add_10
	
add_10:
	add word[cs:score],10
	jmp inc_score_quit

add_20:
	add word[cs:score],20
	jmp inc_score_quit
	
add_30:
	add word[cs:score],30
	jmp inc_score_quit
	
inc_score_l1:
	mov ax,[bp+6]  ;row
	cmp ax,3
	jne add_20
	sub word[cs:score],30
	
inc_score_quit:
	cmp word[cs:score],0xf000
	ja inc_score_l2
	pop bx
	pop ax
	pop bp
	ret 4	
	
	
inc_score_l2:
	mov word[cs:score],0
	jmp inc_score_quit

end_game:
	call cls
	mov ah,0x13
	xor al,al
	xor bh,bh
	mov bl,0x07
	mov cx,9
	mov dh,12
	mov dl,35
	push cs
	pop es
	mov bp,game_over_str
	int 0x10
	call info_bar
	xor ax,ax
	mov es,ax
	cli
	mov ax, [cs:old_kbisr]
	mov [es:9*4], ax 
	mov ax, [cs:old_kbisr+2]
	mov [es:9*4+2], ax
	mov ax,[cs:old_timer] 
	mov [es:8*4], ax 
	mov ax, [cs:old_timer+2]
	mov [es:8*4+2], ax
	sti
	mov al, 0x20
	out 0x20, al
	mov ax,0x4c00
	int 0x21
	
	
check_lvl:
	push ax
	push bx
	push cx
	
	mov cx,24
	mov bx,bricks_arr
	
check_lvl_l1:
	cmp word[bx],1
	je check_lvl_l2
	add bx,2
	loop check_lvl_l1
	mov word[cs:level],2
	mov word[cs:starter],0
	mov word[cs:ball_row],22
	mov ax,[cs:bar_col]
	add ax,7
	mov [cs:ball_col],ax
	mov ax,[cs:time]
	add [cs:score],ax
	
check_lvl_quit:
	pop cx
	pop bx
	pop ax
	ret
	
check_lvl_l2:
	jmp check_lvl_quit
	
	
timer_l1:
	call brick_lvl_2
	jmp timer_l2
	
	
timer: 
	push ax
	push bx
	push cx
	push si
	push di
	push es
	call cls
	call ball
	call bar 
	cmp word[cs:level],1
	jne timer_l1
	call brick
timer_l2:
	call info_bar
	cmp word[cs:life],0
	je end_game
	
	cmp word[cs:starter], 1
	jne ball_quit
startMoving:
	cmp word[cs:ball_dir],1
	je dir_0
	cmp word[cs:ball_dir+2],1
	je dir_1
	cmp word[cs:ball_dir+4],1
	je dir_2
	cmp word[cs:ball_dir+6],1
	je dir_3
	cmp word[cs:ball_dir+8],1
	je dir_4
	cmp word[cs:ball_dir+10],1
	je dir_5

dir_0: 
	dec word[cs:ball_row]
	jmp ball_quit
dir_1: 
	inc word[cs:ball_row]
	jmp ball_quit
dir_2: 
	dec word[cs:ball_row]
	inc word[cs:ball_col]
	jmp ball_quit
dir_3: 
	inc word[cs:ball_row]
	inc word[cs:ball_col]
	jmp ball_quit
dir_4: 
	dec word[cs:ball_row]
	dec word[cs:ball_col]
	jmp ball_quit
dir_5: 
	inc word[cs:ball_row]
	dec word[cs:ball_col]
	jmp ball_quit




ball_quit: 

	call ball_dir_check

	mov al, 0x20
	out 0x20, al

	pop es
	pop di
	pop si
	pop cx
	pop bx
	pop ax



	iret
	
kbisr: 
	push ax
	push es
	push dx
	mov ax, 0xb800
	mov es, ax ; point es to video memory
	in al, 0x60 ; read a char from keyboard port
	cmp al, 0x4b ; is the key left arrow
	jne nextcmp1 ; no, try next comparison
	sub word[cs:bar_col], 4; yes, move bar left
	call bar
	cmp word[cs:starter], 0
	je macho

nextcmp1: 
	cmp al, 0x4d ; is the key right arrow
	jne nextcmp2 ; no, leave interrupt routine
	add word[cs:bar_col], 4 ; yes, move bar right
	call bar
	cmp word[cs:starter], 0
	je macho
nextcmp2: 
	cmp al,0x1C ; is the key enter
	jne nomatch ; no, leave interrupt routine
	mov word[cs:starter], 1 ; yes, turn on start of ball
	jmp exit
nomatch:
	pop dx
	pop es
	pop ax
	jmp far [cs:old_kbisr] ; call the original ISR
exit: 
	mov al, 0x20
	out 0x20, al ; send EOI to PIC
	pop dx
	pop es
	pop ax
	iret ; return from interrupt

macho:
	mov dx,[cs:bar_col]
	add dx,7
	mov [cs:ball_col],dx
	jmp nomatch
	
	
;for help in debugging
printnum:
 push bp
 mov bp, sp
 push es
 push ax
 push bx
 push cx
 push dx
 push di
 mov ax, 0xb800
 mov es, ax ; point es to video base
 xor ax,ax
 mov al,80
 mov bl,24
 mul bl
 mov di,ax
 shl di,1
 mov ax,[bp+6] ;col
 shl ax,1
 add di,ax
 mov ax, [bp+4] ; load number in ax
 mov bx, 10 ; use base 10 for division
 mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
 div bx ; divide by 10
 add dl, 0x30 ; convert digit into ascii value
 push dx ; save ascii value on stack
 inc cx ; increment count of values
 cmp ax, 0 ; is the quotient zero
 jnz nextdigit ; if no divide it again
nextpos: pop dx ; remove a digit from the stack
 mov dh, 0x07 ; use normal attribute
 mov [es:di], dx ; print char on screen
 add di, 2 ; move to next screen location
 loop nextpos ; repeat for all digits on stack
 pop di
 pop dx
 pop cx
 pop bx
 pop ax
 pop es
 pop bp
 ret 4 

start: 
	
	
	xor ax,ax
	mov es,ax
	mov ax, [es:9*4]
	mov [cs:old_kbisr], ax 
	mov ax, [es:9*4+2]
	mov [cs:old_kbisr+2], ax 
	mov ax, [es:8*4]
	mov [cs:old_timer], ax 
	mov ax, [es:8*4+2]
	mov [cs:old_timer+2], ax
	cli
	mov word[es:8*4],timer
	mov [es:8*4+2],cs
	mov word [es:9*4], kbisr 
	mov [es:9*4+2], cs 
	sti

infinite:
	jmp infinite
	
