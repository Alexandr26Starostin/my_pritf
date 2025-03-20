
my_printf:     формат файла elf64-x86-64


Дизассемблирование раздела .text:

0000000000401000 <.text>:
  401000:	55                   	push   %rbp
  401001:	48 89 e5             	mov    %rsp,%rbp
  401004:	48 8d 05 64 10 00 00 	lea    0x1064(%rip),%rax        # 0x40206f
  40100b:	50                   	push   %rax
  40100c:	68 3d 02 00 00       	push   $0x23d
  401011:	41 b9 3d 02 00 00    	mov    $0x23d,%r9d
  401017:	41 b8 ff 00 00 00    	mov    $0xff,%r8d
  40101d:	48 b8 39 18 62 b2 dd 	movabs $0xf6b7fddb2621839,%rax
  401024:	7f 6b 0f 
  401027:	48 89 c1             	mov    %rax,%rcx
  40102a:	ba 40 00 00 00       	mov    $0x40,%edx
  40102f:	be d2 02 96 49       	mov    $0x499602d2,%esi
  401034:	48 8d 05 c5 0f 00 00 	lea    0xfc5(%rip),%rax        # 0x402000
  40103b:	48 89 c7             	mov    %rax,%rdi
  40103e:	b8 00 00 00 00       	mov    $0x0,%eax
  401043:	e8 27 00 00 00       	call   0x40106f
  401048:	48 83 c4 10          	add    $0x10,%rsp
  40104c:	b8 00 00 00 00       	mov    $0x0,%eax
  401051:	c9                   	leave
  401052:	c3                   	ret
  401053:	66 2e 0f 1f 84 00 00 	cs nopw 0x0(%rax,%rax,1)
  40105a:	00 00 00 
  40105d:	0f 1f 00             	nopl   (%rax)
  401060:	e8 9b ff ff ff       	call   0x401000
  401065:	48 89 c7             	mov    %rax,%rdi
  401068:	b8 3c 00 00 00       	mov    $0x3c,%eax
  40106d:	0f 05                	syscall
  40106f:	49 89 ea             	mov    %rbp,%r10
  401072:	41 5b                	pop    %r11
  401074:	41 51                	push   %r9
  401076:	41 50                	push   %r8
  401078:	51                   	push   %rcx
  401079:	52                   	push   %rdx
  40107a:	56                   	push   %rsi
  40107b:	48 89 e5             	mov    %rsp,%rbp
  40107e:	53                   	push   %rbx
  40107f:	48 31 c0             	xor    %rax,%rax
  401082:	48 31 db             	xor    %rbx,%rbx
  401085:	48 8b 0c 25 00 30 40 	mov    0x403000,%rcx
  40108c:	00 
  40108d:	48 ba 08 30 40 00 00 	movabs $0x403008,%rdx
  401094:	00 00 00 
  401097:	8a 1f                	mov    (%rdi),%bl
  401099:	80 fb 00             	cmp    $0x0,%bl
  40109c:	74 1c                	je     0x4010ba
  40109e:	80 fb 25             	cmp    $0x25,%bl
  4010a1:	74 0d                	je     0x4010b0
  4010a3:	88 1a                	mov    %bl,(%rdx)
  4010a5:	48 ff c7             	inc    %rdi
  4010a8:	48 ff c2             	inc    %rdx
  4010ab:	48 ff c0             	inc    %rax
  4010ae:	eb 08                	jmp    0x4010b8
  4010b0:	e8 86 00 00 00       	call   0x40113b
  4010b5:	48 ff c1             	inc    %rcx
  4010b8:	e2 dd                	loop   0x401097
  4010ba:	e8 12 00 00 00       	call   0x4010d1
  4010bf:	80 fb 00             	cmp    $0x0,%bl
  4010c2:	74 02                	je     0x4010c6
  4010c4:	eb d1                	jmp    0x401097
  4010c6:	5b                   	pop    %rbx
  4010c7:	48 83 c4 28          	add    $0x28,%rsp
  4010cb:	41 53                	push   %r11
  4010cd:	4c 89 d5             	mov    %r10,%rbp
  4010d0:	c3                   	ret
  4010d1:	57                   	push   %rdi
  4010d2:	50                   	push   %rax
  4010d3:	41 52                	push   %r10
  4010d5:	41 53                	push   %r11
  4010d7:	b8 01 00 00 00       	mov    $0x1,%eax
  4010dc:	48 8b 14 25 00 30 40 	mov    0x403000,%rdx
  4010e3:	00 
  4010e4:	48 29 ca             	sub    %rcx,%rdx
  4010e7:	48 be 08 30 40 00 00 	movabs $0x403008,%rsi
  4010ee:	00 00 00 
  4010f1:	bf 01 00 00 00       	mov    $0x1,%edi
  4010f6:	0f 05                	syscall
  4010f8:	41 5b                	pop    %r11
  4010fa:	41 5a                	pop    %r10
  4010fc:	58                   	pop    %rax
  4010fd:	5f                   	pop    %rdi
  4010fe:	48 8b 0c 25 00 30 40 	mov    0x403000,%rcx
  401105:	00 
  401106:	48 ba 08 30 40 00 00 	movabs $0x403008,%rdx
  40110d:	00 00 00 
  401110:	c3                   	ret
  401111:	41 5d                	pop    %r13
  401113:	48 83 f9 00          	cmp    $0x0,%rcx
  401117:	75 05                	jne    0x40111e
  401119:	e8 b3 ff ff ff       	call   0x4010d1
  40111e:	5b                   	pop    %rbx
  40111f:	88 1a                	mov    %bl,(%rdx)
  401121:	48 ff c2             	inc    %rdx
  401124:	48 ff c9             	dec    %rcx
  401127:	49 ff c8             	dec    %r8
  40112a:	49 83 f8 00          	cmp    $0x0,%r8
  40112e:	75 e3                	jne    0x401113
  401130:	41 59                	pop    %r9
  401132:	4c 01 c8             	add    %r9,%rax
  401135:	48 ff c7             	inc    %rdi
  401138:	41 55                	push   %r13
  40113a:	c3                   	ret
  40113b:	48 ff c7             	inc    %rdi
  40113e:	8a 1f                	mov    (%rdi),%bl
  401140:	80 eb 25             	sub    $0x25,%bl
  401143:	ff 24 dd 80 20 40 00 	jmp    *0x402080(,%rbx,8)
  40114a:	48 8b 5d 00          	mov    0x0(%rbp),%rbx
  40114e:	88 1a                	mov    %bl,(%rdx)
  401150:	48 83 c5 08          	add    $0x8,%rbp
  401154:	48 ff c7             	inc    %rdi
  401157:	48 ff c2             	inc    %rdx
  40115a:	48 ff c9             	dec    %rcx
  40115d:	48 ff c0             	inc    %rax
  401160:	e9 f5 00 00 00       	jmp    0x40125a
  401165:	41 55                	push   %r13
  401167:	41 54                	push   %r12
  401169:	50                   	push   %rax
  40116a:	49 89 d4             	mov    %rdx,%r12
  40116d:	48 8b 45 00          	mov    0x0(%rbp),%rax
  401171:	48 83 c5 08          	add    $0x8,%rbp
  401175:	4d 31 c0             	xor    %r8,%r8
  401178:	48 99                	cqto
  40117a:	41 b9 0a 00 00 00    	mov    $0xa,%r9d
  401180:	49 f7 f1             	div    %r9
  401183:	49 ff c0             	inc    %r8
  401186:	48 83 c2 30          	add    $0x30,%rdx
  40118a:	52                   	push   %rdx
  40118b:	48 83 f8 00          	cmp    $0x0,%rax
  40118f:	75 e7                	jne    0x401178
  401191:	4c 89 c0             	mov    %r8,%rax
  401194:	4c 89 e2             	mov    %r12,%rdx
  401197:	e8 75 ff ff ff       	call   0x401111
  40119c:	41 5c                	pop    %r12
  40119e:	41 5d                	pop    %r13
  4011a0:	e9 b5 00 00 00       	jmp    0x40125a
  4011a5:	41 56                	push   %r14
  4011a7:	41 be 01 00 00 00    	mov    $0x1,%r14d
  4011ad:	eb 14                	jmp    0x4011c3
  4011af:	41 56                	push   %r14
  4011b1:	41 be 03 00 00 00    	mov    $0x3,%r14d
  4011b7:	eb 0a                	jmp    0x4011c3
  4011b9:	41 56                	push   %r14
  4011bb:	41 be 04 00 00 00    	mov    $0x4,%r14d
  4011c1:	eb 00                	jmp    0x4011c3
  4011c3:	41 55                	push   %r13
  4011c5:	41 54                	push   %r12
  4011c7:	41 57                	push   %r15
  4011c9:	50                   	push   %rax
  4011ca:	48 8b 45 00          	mov    0x0(%rbp),%rax
  4011ce:	48 83 c5 08          	add    $0x8,%rbp
  4011d2:	4d 31 c0             	xor    %r8,%r8
  4011d5:	49 89 cf             	mov    %rcx,%r15
  4011d8:	4c 89 f1             	mov    %r14,%rcx
  4011db:	49 89 c4             	mov    %rax,%r12
  4011de:	48 d3 e8             	shr    %cl,%rax
  4011e1:	48 d3 e0             	shl    %cl,%rax
  4011e4:	49 29 c4             	sub    %rax,%r12
  4011e7:	48 d3 e8             	shr    %cl,%rax
  4011ea:	49 83 fc 0a          	cmp    $0xa,%r12
  4011ee:	78 0a                	js     0x4011fa
  4011f0:	49 83 ec 0a          	sub    $0xa,%r12
  4011f4:	49 83 c4 41          	add    $0x41,%r12
  4011f8:	eb 04                	jmp    0x4011fe
  4011fa:	49 83 c4 30          	add    $0x30,%r12
  4011fe:	49 ff c0             	inc    %r8
  401201:	41 54                	push   %r12
  401203:	48 83 f8 00          	cmp    $0x0,%rax
  401207:	75 d2                	jne    0x4011db
  401209:	4c 89 f9             	mov    %r15,%rcx
  40120c:	4c 89 c0             	mov    %r8,%rax
  40120f:	e8 fd fe ff ff       	call   0x401111
  401214:	41 5f                	pop    %r15
  401216:	41 5c                	pop    %r12
  401218:	41 5d                	pop    %r13
  40121a:	41 5e                	pop    %r14
  40121c:	eb 3c                	jmp    0x40125a
  40121e:	57                   	push   %rdi
  40121f:	48 8b 7d 00          	mov    0x0(%rbp),%rdi
  401223:	48 83 c5 08          	add    $0x8,%rbp
  401227:	8a 1f                	mov    (%rdi),%bl
  401229:	80 fb 00             	cmp    $0x0,%bl
  40122c:	74 14                	je     0x401242
  40122e:	88 1a                	mov    %bl,(%rdx)
  401230:	48 ff c7             	inc    %rdi
  401233:	48 ff c2             	inc    %rdx
  401236:	48 ff c0             	inc    %rax
  401239:	e2 ec                	loop   0x401227
  40123b:	e8 91 fe ff ff       	call   0x4010d1
  401240:	eb e5                	jmp    0x401227
  401242:	5f                   	pop    %rdi
  401243:	48 ff c7             	inc    %rdi
  401246:	eb 12                	jmp    0x40125a
  401248:	b3 25                	mov    $0x25,%bl
  40124a:	88 1a                	mov    %bl,(%rdx)
  40124c:	48 ff c7             	inc    %rdi
  40124f:	48 ff c2             	inc    %rdx
  401252:	48 ff c0             	inc    %rax
  401255:	48 ff c9             	dec    %rcx
  401258:	eb 00                	jmp    0x40125a
  40125a:	c3                   	ret
