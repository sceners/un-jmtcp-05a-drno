; JMT-CP v0.5a Unpacker
; Coded by dR.No // Delirium Tremens Group

model tiny
.386
.code
org 100h


Start:
                mov     dx,offset Msg
                call    write

                pusha

                mov     ah,4Ah
                mov     bh,10h
                int     21h

                mov     si,81h
                mov     di,offset File2Run

                lodsb
                dec     si
                cmp     al,0Dh
                jne     @CopyStr
                mov     dx,offset Usage
                jmp     short write
@CopyStr:
                lodsb
                cmp     al,20h
                je      @CopyStr
                cmp     al,0Dh
                je      _EndStr
                stosb
                jmp     short @CopyStr
_EndStr:
                xor     al,al
                stosb

                mov     dx,offset Process
                mov     ah,9
                int     21h

                mov     dx,offset File2Run
                mov     ax,3d02h
                int     21h

                jnc     FileOk
                mov     dx,offset File_Not
                jmp     short write
FileOk:
                xchg    bx,ax
                mov     ah,3Fh
                mov     dx,offset Buf
                mov     cx,-1
                int     21h

                mov     ax,4202h
                xor     cx,cx
                xor     dx,dx
                int     21h
                mov     bp,ax
                mov     ah,3Eh
                int     21h

                cmp     dword ptr [Buf+2Ch],6D75616Ah
                je      ID_Ok
                mov     dx,offset Not_Crypted
                jmp     short write
ID_Ok:

                mov     _oldseg,ds
                mov     ax,cs
                add     ax,1010h
                mov     es,ax
                lea     si,_start
                xor     di,di
                mov     cx,_end-_start
                rep     movsb

                push    0
                pop     ds

                mov     word ptr ds:[1*4],New1-_start
                mov     word ptr ds:[1*4+2],es

                push    es
                push    0
                retf
Write:
                mov     ah,9h
                int     21h
                ret

_start:
                push    es
                pop     ds
                mov     dx,file2run-_start
                mov     ax,3d02h
                int     21h

                push    ss
                pop     ds
                xchg    bx,ax
                mov     ah,3fh
                mov     dx,256
                mov     cx,-1
                int     21h
                mov     ah,3eh
                int     21h
                popa
                push    100h
                push    ds
                push    100h
                xor     bx,bx
                xor     ax,ax
                mov     cs:(_seg-_start),cs
                push    ss ss
                pop     es ds
                iret
New1:
                push    bp
                mov     bp,sp

                cmp     word ptr [bp+2],1C6h
                jne     @@_1
                mov     word ptr [bp+2],1DCh
@@_1:

                cmp     word ptr [bp+2],225h
                je      Go

Back:
                pop     bp
                iret

_seg            dw      ?
_oldseg         dw      ?

Go:
                mov     di,100h
                mov     si,59Fh
                mov     cx,ds:[138h]

                push    ds
                push    cs
                pop     ds
                mov     FSize,cx
                pop     ds

                xor     dx,dx

@Decode:
                lodsb
                xor     ax,8C60h
                xor     ah,ah
                add     dx,ax
                xor     ax,di
                stosb
                loop    @Decode

                mov     ds,cs:(_seg-_start)
                mov     ah,3Ch
                mov     dx,FileName-_start
                xor     cx,cx
                int     21h

                xchg    ax,bx

                mov     ah,40h
                mov     cx,FSize


                mov     dx,100h
                mov     ds,cs:(_oldseg-_start)
                int     21h

                pop     bp

                mov     ds,cs:(_seg-_start)
                mov     dx,offset Success-_start
                mov     ah,9
                int     21h

                mov     ax,4C00h
                int     21h

Msg             db      0dh,0ah,'jmt-cp v0.5a Unpacker Coded by dR.No // ViP // DTg // PMP$'
Process         db      0dh,0ah,'Please Wait! Unpacking... $'
Success         db      'completed!',0dh,0ah,24h
Usage           db      0dh,0ah,'Usage: UN-JMTCP <FiLENAME-2-UNP>',0dh,0ah,24h
File_Not        db      0dh,0ah,'File not found',0dh,0ah,24h
Not_Crypted     db      0dh,0ah,'Specified file is not crypted with jmt-cp v0.5a',0dh,0ah,24h
FSize           dw      ?
FileName        db      'unpacked.com',0
File2Run        db      80 dup(0)
Buf:
_end:
End Start
;                                -=THE!END=-