org 0x0100

jmp start

str1: times 240 dw 0
str3: times 240 dw 0
speed : dw 6
speedinterval: dw 0
lives : dw 3
seconds: dw 60
stage : dw 1
mins: dw 3

livesindex: dw 14
scoreindex: dw 54
minindex: dw 88
secindex: dw 94
stageindex: dw 124

fruit: db 'o'
score: dw 0
rand: dw 2000
hurdleflag: dw 0
hurdleflag1: dw 0

msg_start: db 'SNAKE GAME'
msg_startcls: db '          '
msg_rule1: db 'Use arrow keys to move the snake'
msg_rule2: db 'You have three lives and four minutes to play'
msg_rule3: db 'If snake touches border the you loose one life'
msg_rule4: db 'Hurdles are created after your score reaches ten'
msg_rule5: db 'Touching hurdles results in loss of one life'
msg_start1: db 'Press any key to start game..'

msg_lives: db 'Lives:'
msg_gameover: db 'Game Over!!'
msg_score: db 'Score :'
msg_time: db 'Time :'
msg_stage: db 'Stage :'
msg_timerreset: db 'Timer reset'
msg_appro : db 'Maximum height reached'

length: dw 19

oldisr: dd 0

clrscr:											;clrscr routine
push es
push ax
push cx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
xor di, di ; point di to top left column
mov ax, 0x0720 ; space char in normal attribute
mov cx, 2000 ; number of screen locations
cld ; auto increment mode
rep stosw ; clear the whole screen
pop di
pop cx
pop ax
pop es
ret

mykbisr:										;mykbisr

;continue:
in al,0x60
cmp al,0x4b	;left key 'a'
je left
jne l5

left:
mov byte[buffer],al
jmp end

l5:
cmp al,0x4d	;right key 'd'
je right
jne l6

right:
mov byte[buffer],al
jmp end

l6:
cmp al,0x48	;up key 'w'
je up

cmp al,0x50	;down key 's'
je down
jmp end

down:
mov byte[buffer],al
jmp end

up:
mov byte[buffer],al

end:
;mov al,0x20
;out 0x20,al

jmp far [cs:oldisr]

;iret

timer:											;timer ISR
push ax

;call sound

cmp word[score],10								;check for hurdles (second stage)
jge cont3
jmp cont1
cont3:
cmp word[hurdleflag],1
je cont1
call hurdles
mov word[hurdleflag],1

cont1:
cmp word[score],20								;third stage
jge cont6
jmp cont5

cont6:
;mov word[hurdleflag],0
cmp word[hurdleflag1],0
jne cont5
mov word[hurdleflag1],1
call hurdles
mov word[hurdleflag1],1

cont5:
add word[cs:time],55

mov ax,[cs:time]
add word[cs:rand],ax
mov ax,[buffer]
add word[cs:rand],ax

call checktime
inc word[cs:tick_count]
cmp word[cs:tick_count], 24
jl end11111

mov ax,[cs:speed]
mov word[cs:tick_count], ax						;setting speed of snake

cmp word[cs:speedinterval],20
jl cont
mov word[cs:speedinterval],0
add word[cs:speed],6							;increasing speed after 20 seconds

cont:
cmp byte[cs:buffer], 0
je end11111

cmp word[buffer],0x48
je w

cmp word[buffer],0x50
je sbxx

cmp word[buffer],0x4d
je dbbbb										;intermediary jump

cmp word[buffer],0x4b
je abbbb										;intermediary jump
jmp end10

w:												;Routine for up key
mov bx,str1
mov si,238
mov ax,[bx+si]
sub ax,160
mov cx,0xb800
mov es,cx
mov di,ax
cmp word[es:di],0x023d							;Check for border/hurdle
jne checknextw
jmp declifew
jmp fazool2										;intermediary jump

sbxx:
jmp sb
end11111:
jmp end111
dbbbb:
jmp dbbb
abbbb:
jmp abbb

fazool2:
checknextw:
mov di,ax
cmp word[es:di],0x076f							;comparing for fruit eaten or not
mov word[buffer2],0x076f
je incscorew
cmp word[es:di],0x0724
mov word[buffer2],0x0724
je incscorew
cmp word[es:di],0x012a							;comparing for self collision
jne move2
jmp declifew

incscorew:
call checklength								;increasing length of shorter than 240 chars
add word[score],2								;adding score
call random										;printing random fruit
mov word[buffer2],0
push word[scoreindex]
push word[score]
call print_lives
cmp word[es:di],0x012a							;comparing for self collision
jne move2

declifew:
dec word[lives]									;decreasing one life
push word[livesindex]
push word[lives]
call print_lives
mov word[buffer],0								;waiting for next pressed key
jmp end11

move2:

mov cx,0xb800
mov es,cx

call shiftarray									;shifting current arr to dummy arr
jmp nextw										;intermediary jump

end111:
jmp end11
dbbb:
jmp dbb
abbb:
jmp abb
sb:
jmp s

nextw:
mov si,238
sub word[str1+si],160							;making changes to head of snake depending on key pressed
call printsnake									;printing snake according to length
jmp end11

end11:
jmp end13
dbb:
jmp d
abb:
jmp a

s:												;routine for down key
mov bx,str1
mov si,238
mov ax,[bx+si]
add ax,160
mov cx,0xb800
mov es,cx
mov di,ax
cmp word[es:di],0x023d							;comparing for border/hurdle
jne checknexts
jmp declives

checknexts:
mov di,ax
cmp word[es:di],0x076f							;comparing for fruit
mov word[buffer2],0x076f
je incscores
cmp word[es:di],0x0724
mov word[buffer2],0x0724
je incscores
cmp word[es:di],0x012a							;comparing for self collision
jne move3
jmp declives

incscores:
call checklength								;increasing length
add word[score],2
call random
mov word[buffer2],0
push word[scoreindex]
push word[score]
call print_lives
cmp word[es:di],0x012a
jne move3

declives:
dec word[lives]									;decreasing one life
push word[livesindex]
push word[lives]
call print_lives
mov word[buffer],0
jmp end13

move3:

mov cx,0xb800
mov es,cx

call shiftarray

mov si,238

add word[str1+si],160							;changes to head

call printsnake

jmp end12

end13:
jmp end10

a:												;check for left key
mov dx,0
mov bx,str1
mov si,238
mov ax,[bx+si]
sub ax,2
mov di,ax
;push ax
;mov bx,160
;div bx

;pop ax

;cmp dx,0
mov dx,0xb800
mov es,dx
cmp word[es:di],0x023d
jne checknexta
jmp declivea

checknexta:
mov di,ax
cmp word[es:di],0x076f							;comparing for fruit
mov word[buffer2],0x076f
je incscorea
cmp word[es:di],0x0724
mov word[buffer2],0x0724
je incscorea

cmp word[es:di],0x012a
jne move
jmp declivea

incscorea:
call checklength
add word[score],2
call random
mov word[buffer2],0
push word[scoreindex]
push word[score]
call print_lives

cmp word[es:di],0x012a
jne move

declivea:
dec word[lives]
push word[livesindex]
push word[lives]
call print_lives
mov word[buffer],0
jmp end12

move:
mov cx,0xb800
mov es,cx

call shiftarray

mov si,238

sub word[str1+si],2

call printsnake

jmp end12

end12:
jmp end10

d:												;check for right key

mov dx,0
mov bx,str1
mov si,238
mov ax,[bx+si]
add ax,2
;mov bx,160
;div bx
mov cx,0xb800
mov es,cx
mov di,ax
cmp word[es:di],0x023d
jne checknextd
jmp declived

checknextd:
mov di,ax
cmp word[es:di],0x076f							;comparing for fruit
mov word[buffer2],0x076f
je incscored
cmp word[es:di],0x0724
mov word[buffer2],0x0724
je incscored
cmp word[es:di],0x012a
jne move1
jmp declived

incscored:
call checklength
add word[score],2
call random
mov word[buffer2],0
push word[scoreindex]
push word[score]
call print_lives
cmp word[es:di],0x012a
jne move1

declived:
dec word[lives]
push word[livesindex]
push word[lives]
call print_lives
mov word[buffer],0
jmp end10

move1:

mov cx,0xb800
mov es,cx

call shiftarray

mov si,238

add word[str1+si],2

call printsnake

end10:
mov al,0x20
out 0x20,al
pop ax

cmp word[lives],0								;checking if game is over
jne continue

mov ah,0x13
mov al,0
mov bh,0
mov bl,0x87
mov dx,0x0A40
mov cx,11
push cs
pop es
mov bp,msg_gameover
int 0x10

;mov ah,0
;int 0x16
jmp far [cs:endstart]
continue:
iret

checklength:									;checklength subroutine
cmp word[length],240
je here
jmp here1
here:
mov ah,0x13
mov al,0
mov bh,0
mov bl,7
mov dx,0x0936
mov cx,22
push cs
pop es
mov bp,msg_appro
int 0x10


jmp far[cs:endstart]

here1:
cmp word[length],240
jge end_checklength
add word[length],4
end_checklength:
ret

shiftarray:										;shift array subroutine
mov si,238
mov di,238
mov cx,238

looptoshift:
mov ax,[str1+si]
mov word[str3+di],ax
sub si,2
sub di,2
sub cx,2
jnz looptoshift

ret

checktime:										;checktime subroutine
push ax
push es
push di
cmp word[cs:time],1000
jle endtemp

mov word[cs:time],0
dec word[cs:seconds]
inc word[cs:speedinterval]

push word[cs:secindex]
push word[cs:seconds]
call print_lives

cmp word[cs:seconds],9
jg cont2

mov ax,0xb800
mov es,ax
mov di,[cs:secindex]
add di,2
mov word[es:di],0x0720

cont2:
cmp word[cs:seconds],0
jg endtemp

dec word[cs:mins]
mov word[cs:seconds],60

push word[cs:secindex]
push word[cs:seconds]
call print_lives
jmp fazool3										;intermediary jump

endtemp:
jmp endchecktime

fazool3:

cmp word[cs:mins],0
jge fazool4

cmp word[length],240							;compare for game end checks after 4 mins
jge stop										;if max size reached, then add 20 score and exit

jmp reset										;else restart 4 mins timer and decrease one life

stop:

mov word[seconds],0
mov di,[secindex]
mov word[es:di],0x0730
add di,2
mov word[es:di],0x0720

add word[score],20
push word[scoreindex]
push word[score]
call print_lives
jmp endgamee
			
fazool4:										;intermediary jump
jmp endchecktime

endgamee:										;rouitne for displaying game over msg
mov ah,0x13
mov al,0
mov bh,0
mov bl,0x87
mov dx,0x0A40
mov cx,11
push cs
pop es
mov bp,msg_gameover
int 0x10

jmp far [cs:endstart]

reset:											;routine for resetting timer
dec word[lives]
push word[livesindex]
push word[lives]
call print_lives

cmp word[lives],0
je endgamee

mov ah,0x13										;printing timer reset on top right corner of screen
mov al,0
mov bh,0
mov bl,0x87
mov dx,0x0044
mov cx,11
push cs
pop es
mov bp,msg_timerreset
int 0x10

;mov ah,0
;int 0x16
mov cx,0xfff
looponeee:
mov bx,0xfff
looponee:
sub bx,1
cmp bx,0
jne looponee
loop looponeee

mov di,134
push 0xb800
pop es
mov cx,12
one:
mov word[es:di],0x0720
add di,2
loop one

mov word[seconds],60
mov word[mins],3
push word[secindex]
push word[seconds]
call print_lives

endchecktime:
push word[cs:minindex]
push word[cs:mins]
call print_lives
pop di
pop es
pop ax
ret

random:											;random fruit generator 
push ax
push bx
push dx
push di
push es
push cx

call sound

push 0xb800
pop es
mov ax,[rand]
mov bx,4000
doagain:
mov dx,0
add ax,1500
add ax,[rand]
div bx
mov di,dx
cmp word[es:di],0x012a
je doagain
cmp word[es:di],0x023d
je doagain
cmp di,320
jle doagain

mov si,di
mov ax,di

mov dx,0
mov cx,2
div cx
cmp dx,0
jne doagain

mov di,si


;mov di,dx
mov bx,[buffer2]
or bx,0x0000

mov word[es:di],bx

pop cx
pop es
pop di
pop dx
pop bx
pop ax
ret

hurdles:										;hurdles routine
push ax
push bx
push di
push es
push cx

inc word[stage]
push word[stageindex]
push word[stage]
call print_lives

mov ax,0xb800
mov es,ax
mov di,870
mov bx,0x023d

mov cx,4
again:
mov word[es:di],bx
add di,160
loop again

mov cx,5
again1:
mov word[es:di],bx
add di,2
loop again1

mov cx,5
mov di,3100
again2:
mov word[es:di],bx
add di,2
loop again2

mov cx,4
again3:
mov word[es:di],bx
add di,160
loop again3

cmp word[hurdleflag1],1
jne endhurdles
mov word[hurdleflag1],0

mov cx,4
mov di,2480
again4:
mov word[es:di],bx
add di,160
loop again4

mov cx,5
again5:
mov word[es:di],bx
sub di,2
loop again5


mov cx,4
mov di,1580
again6:
mov word[es:di],bx
add di,160
loop again6

mov cx,5
again7:
mov word[es:di],bx
sub di,2
loop again7

mov bx,0x023d

mov cx,4
mov di,1448
again8:
mov word[es:di],bx
add di,160
loop again8

mov cx,5
again9:
mov word[es:di],bx
add di,2
loop again9

endhurdles:
pop cx
pop es
pop di
pop bx
pop ax
ret


printsnake:										;print snake routine
mov di,238
mov cx,236
sub si,2

movenext:
mov ax,[str3+di]
mov word[str1+si],ax
sub di,2
sub si,2
sub cx,2
jnz movenext

mov si,[length]
mov di,238
sub di,si
sub di,si
mov di,[str3+di]
mov word[es:di],0x0720

mov si,238
mov cx,[length]
sub cx,1

mov di,[str1+si]
mov word[es:di],0x0130
sub si,2

print:
mov di,[str1+si]
mov word[es:di],0x012a
sub si,2
loop print

ret

print_lives:									;subroutine for printing numbers using value and index
push bp
mov bp,sp
push ax
push bx
push cx
push dx
push si
push di

mov ax,0xb800
mov es,ax
mov ax,[bp+4]
mov bx,10
mov cx,0
nextdigit:
mov dx,0
div bx
add dl,0x30
push dx
inc cx
cmp ax,0
jnz nextdigit

mov di,[bp+6]

nextpos:
pop dx
mov dh,0x07
mov word[es:di],dx
add di,2
loop nextpos

pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 4

sound:
mov dx,22ch
mov al,10h
out dx,al

mov si,[soundindex]
mov al,[sounddata+si]
out dx,al

mov cx,10
.delay:

loop .delay
inc word[soundindex]
cmp word[soundindex],51528
jne .exit
mov word[soundindex],0

.exit:
ret

start:											;main() function


call clrscr

mov ah,0x13
mov al,0
mov bh,0
mov bl,7
mov dx,0x0921
mov cx,10
push cs
pop es
mov bp,msg_start
int 0x10

mov ah,0x13
mov dx,0x1011
mov cx,32
mov bp,msg_rule1
int 0x10

mov ah,0x13
mov dx,0x1111
mov cx,45
mov bp,msg_rule2
int 0x10

mov ah,0x13
mov dx,0x1211
mov cx,46
mov bp,msg_rule3
int 0x10

mov ah,0x13
mov dx,0x1311
mov cx,48
mov bp,msg_rule4
int 0x10

mov ah,0x13
mov dx,0x1411
mov cx,44
mov bp,msg_rule5
int 0x10

mov ah,0x13
mov dx,0x1511
mov cx,29
mov bp,msg_start1
int 0x10

mov ah,0
int 0x16

call clrscr

xor ax,ax
mov es,ax

mov ax,[es:9*4]
mov [oldisr],ax
mov ax,[es:9*4+2]
mov [oldisr+2],ax

xor ax,ax
mov es,ax

cli
mov word[es:8*4],timer
mov [es:8*4+2],cs 
sti
cli
mov word[es:9*4],mykbisr
mov word[es:9*4+2],cs
sti

mov si,238
mov di,2000
mov bx,str1

init:
mov [bx+si],di
sub di,2
sub si,2
jnz init

mov si,238
mov ax,0xb800
mov es,ax
mov cx,[length]

mov word[es:1500],0x076f
;mov word[es:500],0x076f
;mov word[es:600],0x076f
mov word[es:2500],0x0724
;mov word[es:2500],0x076f
;mov word[es:3500],0x076f

mov di,[str1+si]
mov word[es:di],0x0130
sub si,2
sub cx,1

printmain:
mov di,[str1+si]
mov word[es:di],0x012a
sub si,2
loop printmain

mov bx,0x023d
mov di,160

leftborder:
mov word[es:di],bx
add di,160
cmp di,4000
jl leftborder

mov di,3840
lowerborder:
mov word[es:di],bx
add di,2
cmp di,4000
jl lowerborder

mov di,316
mov si,2
rightborder:
add di,si
mov word[es:di],bx
sub di,si
add si,2
add di,158
cmp di,4000
jl rightborder

mov di,160
mov cx,80
upperborder:
mov word[es:di],bx
add di,2
loop upperborder


mov ah,0x13
mov al,0
mov bh,0
mov bl,7
mov dx,0x0000
mov cx,6
push cs
pop es
mov bp,msg_lives
int 0x10

mov ah,0x13
mov dx,0x0012
mov cx,7
mov bp,msg_score
int 0x10

mov ah,0x13
mov dx,0x0025
mov cx,6
mov bp,msg_time
int 0x10

mov ah,0x13
mov dx,0x0036
mov cx,7
mov bp,msg_stage
int 0x10

push word[minindex]
push word[mins]
call print_lives

push word[secindex]
push word[seconds]
call print_lives

push word[scoreindex]
push word[score]
call print_lives

push word[livesindex]
push word[lives]
call print_lives

push word[stageindex]
push word[stage]
call print_lives

l1:
mov ah,0
int 0x16

cmp al,27
jne l1

endstart:
mov dx,start
add dx,15
mov cl,4
shr dx,cl
mov ax,0x3100
int 0x21

rand1 : dw 0
tick_count: dw 0
time: dw 0
buffer: dw 0
buffer2: dw 0
soundindex: dw 0
sounddata: incbin "kingsv.wav"
