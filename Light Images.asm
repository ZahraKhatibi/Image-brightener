%include "sys-equal.asm"
%include "in_out.asm"
section .data
	edited_photo_str        db    		"/edited_photo/" , 0
	slash_sign              db     		'/' , 0
	O_directory             equ   		 0q0200000
	sys_make_new_folder     equ   		 0q777
	file_descriptor	        dq    		 0
	descriptor		dq    		 0
	descriptor_copy  	dq     		 0
	end_pointer	        dq  	         0
	width 		        dq    		 0
	height 		        dq    		 0
	
section .bss
	path 			resb 		1000000 
	new_path 		resb 		1000000
	pixel_list 		resb 		1000000
	myfiles 		resb 		1000000
	file_name 		resb 		1000
	edit_name 		resb 		1000
	file_name_copy 		resb 		1000
	edit_name2 		resb 		1000
	header 			resb 		14
	type 			resb 		4
	header_os_win   	resb 		36
	size 			resq 		1
	n 			resb 		1
	index 			resq 		1
	
section .text
	global _start
	
%macro new_name 3
	push rdi
	push r8
	push r9
	push rax
	
	mov rdi , %1
	call GetStrlen
	mov rdi , %1
	mov rsi , %3	
	mov r8 , rdx
	%%while1: 	
		cmp rdx , 0
		je %%continue1
		mov al , [rdi]	
		mov [rsi], rax
		inc rsi
		inc rdi
		dec rdx
		jmp %%while1
		
	%%continue1:	
		mov rdi , %2
		call GetStrlen
		mov rdi,%2
		
	%%while2:
		cmp rdx, 0
		je %%end_func
		mov al , [rdi]
		mov [rsi] , al
		inc rsi
		inc rdi
		dec rdx
		jmp %%while2
	
	%%end_func:
		mov byte [rsi], 0
		mov rsi , %3	
	pop rax
	pop r8
	pop r9
	pop rdi
%endmacro

_start:
	call read_string
	new_name path, edited_photo_str, new_path
	call readNum
	mov [n] , al
	call find_index
	call create_folder
	call read_folder	
	jmp exit
	
read_string:
	push rax
	push rdi
	push rdx
	
	mov rax, 0         
    	mov rdi, 0       
    	mov rsi, path
    	mov rdx, 1000       
    	syscall
    	
    	mov rdi , path
    	call GetStrlen
    	mov rdi , path
    	dec rdx
    	mov byte [rdi+rdx],0
    	mov al , byte [rdi+rdx]
    	call putc
    	
    	pop rdx
    	pop rdi
    	pop rax
    	ret    	
	
create_folder:
	push rax
	push rdi
	push rsi

	mov rsi , new_path
	mov rax, 83
	mov rdi, rsi
	mov rsi, sys_make_new_folder        
	syscall

	pop rsi
	pop rdi
	pop rsi
	ret

read_folder:
    	push rax
    	push rdi
    	push rsi
    	push r11
    	push r12
    	push r13
    	
	mov rax, 2
	mov rdi, path
	mov rsi, O_directory           
	syscall
	mov [file_descriptor], rax

	mov rax, 217
	mov rdi, [file_descriptor]                 
	mov rsi, myfiles
	mov rdx, 1000000
	syscall
        mov [end_pointer], rax 
        
	mov rdx, 0
	mov r11, myfiles
	add [end_pointer], r11
	
	read_file:
	    add rdx,r11
	    cmp rdx,[end_pointer]
	    jge end_read_file
	    mov r11,0
	    mov r11w,[rdx+16]
	    mov r12,rdx 
	    add r12,18
	    xor r13,r13
	    mov r13b,[r12]
	    cmp r13,8
	    jne read_file
	    inc r12

	    push rdx
	    push r11
	    push r12
	    push r13
	    
	    mov rsi , r12
	    new_name path,slash_sign,edit_name
	    new_name edit_name,r12,file_name	    
	    new_name new_path,r12,file_name_copy   
	    call open_file

	    pop r13
	    pop r12 
	    pop r11 
	    pop rdx 
	    jmp read_file
	    
	end_read_file:
	   pop r13
	   pop r12
	   pop r11
	   pop rsi
	   pop rdi
	   pop rax
	 
    	   ret
    	   
open_file:
	mov rax,2
    	mov rdi,file_name
    	mov rsi,O_RDWR
    	syscall
    	mov [descriptor],rax
		
    	mov rax, 0
    	mov rdi, [descriptor]           
    	mov rsi, header
    	mov rdx, 14
    	syscall
    	
    	mov rax, 0
    	mov rdi, [descriptor]           
    	mov rsi, type
    	mov rdx, 4
    	syscall
    	                    
    	mov ax, [header] 
    	cmp ax,'BM'     
    	jne close_file
    	
    	mov rax, 85
    	mov rdi, file_name_copy
    	mov rsi, sys_IRUSR | sys_IWUSR
    	syscall
    	mov [descriptor_copy], rax
    
    	mov rax, 1
    	mov rdi, [descriptor_copy]
    	mov rsi, header
    	mov rdx, 14
    	syscall
    	
    	mov rax, 1
    	mov rdi, [descriptor_copy]
    	mov rsi, type
    	mov rdx, 4
    	syscall
    	
    	mov rax, 0
    	mov eax, [type]
    	cmp eax, 12 
    	je os
    	jne windows   ; eax = 40
	
	os:
    	    mov rax, 0
	    mov rdi, [descriptor]
	    mov rsi, header_os_win
	    mov rdx, 8
	    syscall

	    mov rax, 0
    	    mov rbx, 0
	    mov ax, [header_os_win]
	    mov [width], rax
	    mov bx, [header_os_win+2]
	    mov [height], rbx
	    
	    mov rax, 1
	    mov rdi, [descriptor_copy]
	    mov rsi, header_os_win
	    mov rdx, 8
	    syscall
	    jmp handle_pixel
	        
    	windows:
    	    xor rax, rax
	    mov rdi, [descriptor]
	    mov rsi, header_os_win
	    mov rdx, 36
	    syscall
	
	    xor rbx, rbx
    	    xor rcx, rcx
	    mov ebx, [header_os_win]
	    mov [width], rbx
	    mov ecx, [header_os_win+4]
	    mov [height], rcx

	    mov rax, 1
	    mov rdi, [descriptor_copy]
	    mov rsi, header_os_win
	    mov rdx, 36
	    syscall
	    jmp handle_pixel
    	   
	handle_pixel:
	    call read_photo_pixel
    	    mov rax, 3
    	    mov rdi, [descriptor_copy]
    	    syscall
   
	close_file:
	    	mov rax, 3
	    	mov rdi, [descriptor]
	    	syscall

    	ret

read_photo_pixel:
	mov r8, [width]
	mov rax, r8
	mov r10, 3
	mul r10
	mov r8, rax
    	mov rcx, 4
    	xor rdx, rdx
    	div rcx
    	sub rcx, rdx
    	mov r9, 0
    	cmp rcx, 4
    	jl have_padding
    	je no_padding
    	
    	have_padding:
    		mov r9, rcx
    		
    	no_padding:
    	  
	    	mov rax, r8
	    	add rax, r9
	    	mov r11, qword[height]
	    	mul r11
	    	mov [size], rax
	    	
	    	xor rax, rax
	    	mov rdi, [descriptor]
	    	mov rsi, [index]  
	    	mov rdx,[size]
	    	syscall
	  	  	
	  	call lighter 
	 
	    	mov rax,1
		mov rdi,[descriptor_copy]
	    	mov rsi,[index]
	    	mov rdx,[size]
	    	syscall
    	ret

find_index:
	push rax
	push rbx
	push rdx
	
	mov rax , pixel_list 
	mov rbx , 64  
	xor rdx , rdx
	div rbx
	sub rbx , rdx
	mov [index] , rbx
	mov rax , pixel_list
	add [index] , rax
	
	pop rax
	pop rbx
	pop rdx
	ret
	
lighter:
	mov rsi , [index]
	mov rbx,0
  	looop:
	    vpbroadcastb xmm1,[n]
	    paddusb xmm1,[rsi+rbx]
	    movdqa [rsi+rbx],xmm1
	    add rbx,16
	    cmp rbx,[size]
	    jl looop 
	ret

exit:
	mov rax, 1
	mov rbx, 0
	int 0x80