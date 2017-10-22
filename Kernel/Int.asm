[BITS 32]
  
%macro intmacro 1
global interrupt%1
interrupt%1:
  cli
  push byte 0
  push byte %1
  jmp  int_common
%endmacro

intmacro 47
intmacro 48
intmacro 49
intmacro 50
intmacro 51
intmacro 52
intmacro 53
intmacro 54
intmacro 55
intmacro 56
intmacro 57
intmacro 58
intmacro 59
intmacro 60
intmacro 61
intmacro 62
intmacro 63
intmacro 64
intmacro 65
intmacro 66
intmacro 67
intmacro 68
intmacro 69
intmacro 70
intmacro 71
intmacro 72
intmacro 73
intmacro 74
intmacro 75
intmacro 76
intmacro 77
intmacro 78
intmacro 79
intmacro 80
intmacro 81
intmacro 82
intmacro 83
intmacro 84
intmacro 85
intmacro 86
intmacro 87
intmacro 88
intmacro 89
intmacro 90
intmacro 91
intmacro 92
intmacro 93
intmacro 94
intmacro 95
intmacro 96
intmacro 97
intmacro 98
intmacro 99
intmacro 100
intmacro 101
intmacro 102
intmacro 103
intmacro 104
intmacro 105
intmacro 106
intmacro 107
intmacro 108
intmacro 109
intmacro 110
intmacro 111
intmacro 112
intmacro 113
intmacro 114
intmacro 115
intmacro 116
intmacro 117
intmacro 118
intmacro 119
intmacro 120
intmacro 121
intmacro 122
intmacro 123
intmacro 124
intmacro 125
intmacro 126
intmacro 127
intmacro 128
intmacro 129
intmacro 130
intmacro 131
intmacro 132
intmacro 133
intmacro 134
intmacro 135
intmacro 136
intmacro 137
intmacro 138
intmacro 139
intmacro 140
intmacro 141
intmacro 142
intmacro 143
intmacro 144
intmacro 145
intmacro 146
intmacro 147
intmacro 148
intmacro 149
intmacro 150
intmacro 151
intmacro 152
intmacro 153
intmacro 154
intmacro 155
intmacro 156
intmacro 157
intmacro 158
intmacro 159
intmacro 160
intmacro 161
intmacro 162
intmacro 163
intmacro 164
intmacro 165
intmacro 166
intmacro 167
intmacro 168
intmacro 169
intmacro 170
intmacro 171
intmacro 172
intmacro 173
intmacro 174
intmacro 175
intmacro 176
intmacro 177
intmacro 178
intmacro 179
intmacro 180
intmacro 181
intmacro 182
intmacro 183
intmacro 184
intmacro 185
intmacro 186
intmacro 187
intmacro 188
intmacro 189
intmacro 190
intmacro 191
intmacro 192
intmacro 193
intmacro 194
intmacro 195
intmacro 196
intmacro 197
intmacro 198
intmacro 199
intmacro 200
intmacro 201
intmacro 202
intmacro 203
intmacro 204
intmacro 205
intmacro 206
intmacro 207
intmacro 208
intmacro 209
intmacro 210
intmacro 211
intmacro 212
intmacro 213
intmacro 214
intmacro 215
intmacro 216
intmacro 217
intmacro 218
intmacro 219
intmacro 220
intmacro 221
intmacro 222
intmacro 223
intmacro 224
intmacro 225
intmacro 226
intmacro 227
intmacro 228
intmacro 229
intmacro 230
intmacro 231
intmacro 232
intmacro 233
intmacro 234
intmacro 235
intmacro 236
intmacro 237
intmacro 238
intmacro 239
intmacro 240
intmacro 241
intmacro 242
intmacro 243
intmacro 244
intmacro 245
intmacro 246
intmacro 247
intmacro 248
intmacro 249
intmacro 250
intmacro 251
intmacro 252
intmacro 253
intmacro 254
intmacro 255

extern int_handler

int_common
    pusha
    push ds
    push es
    push fs
    push gs

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov eax, esp
    push eax

    mov eax, int_handler
    call eax

    pop eax
    pop gs
    pop fs
    pop es
    pop ds
    popa
    add esp, 8
    iret