
main:
li $t0, 5
sw $t0, int.temp_0
lw $t0, int.temp_0
sw $t0, int.n.0
li $t0, 6
sw $t0, int.temp_1
lw $t0, int.temp_1
sw $t0, int.d.0
li $t0, 0
sw $t0, int.temp_2
lw $t0, int.temp_2
sw $t0, int.i.1
label_0:
li $t0, 3
sw $t0, int.temp_4
lw $t1, int.i.1
lw $t2, int.temp_4
li $t0, 0
slt $t0, $t1, $t2
sw $t0, int.temp_3
lw $t0 int.temp_3
bne $t0, 0 label_1
b label_2
label_1:
li $t0, 0
sw $t0, int.temp_5
lw $t0, int.temp_5
sw $t0, int.j.1
label_4:
li $t0, 3
sw $t0, int.temp_7
lw $t1, int.j.1
lw $t2, int.temp_7
li $t0, 0
slt $t0, $t1, $t2
sw $t0, int.temp_6
lw $t0 int.temp_6
bne $t0, 0 label_5
b label_6
label_5:
lw $t0, int.i.1
sw $t0, int.temp_8
lw $t1, int.temp_8
li $t2, 3
mul $t0, $t1, $t2
sw $t0, int.temp_8
lw $t1, int.temp_8
lw $t2, int.j.1
add $t0, $t1, $t2
sw $t0, int.temp_8
lw $t3, int.temp_8
la $t4, int.arr.1
li $t5, 4
mul $t3, $t3, $t5
add $t4, $t4, $t3
li $v0, 5
syscall
sw $v0, 0($t4)
lw $t0, int.i.1
sw $t0, int.temp_9
lw $t1, int.temp_9
li $t2, 3
mul $t0, $t1, $t2
sw $t0, int.temp_9
lw $t1, int.temp_9
lw $t2, int.j.1
add $t0, $t1, $t2
sw $t0, int.temp_9
lw $t0, int.i.1
sw $t0, int.temp_10
lw $t1, int.temp_10
li $t2, 3
mul $t0, $t1, $t2
sw $t0, int.temp_10
lw $t1, int.temp_10
lw $t2, int.j.1
add $t0, $t1, $t2
sw $t0, int.temp_10
lw $t3, int.temp_9
la $t4, int.arr.1
li $t5, 4
mul $t3, $t3, $t5
add $t4, $t4, $t3
lw $t0, 0($t4)
lw $t3, int.temp_10
la $t4, int.brr.1
li $t5, 4
mul $t3, $t3, $t5
add $t4, $t4, $t3
sw $t0, 0($t4)
lw $t0, int.i.1
sw $t0, int.temp_12
lw $t1, int.temp_12
li $t2, 3
mul $t0, $t1, $t2
sw $t0, int.temp_12
lw $t1, int.temp_12
lw $t2, int.j.1
add $t0, $t1, $t2
sw $t0, int.temp_12
lw $t0, int.i.1
sw $t0, int.temp_13
lw $t1, int.temp_13
li $t2, 3
mul $t0, $t1, $t2
sw $t0, int.temp_13
lw $t1, int.temp_13
lw $t2, int.j.1
add $t0, $t1, $t2
sw $t0, int.temp_13
lw $t3, int.temp_12
la $t4, int.arr.1
li $t5, 4
mul $t3, $t3, $t5
add $t4, $t4, $t3
lw $t1, 0($t4)
lw $t3, int.temp_13
la $t4, int.brr.1
li $t5, 4
mul $t3, $t3, $t5
add $t4, $t4, $t3
lw $t2, 0($t4)
add $t0, $t1, $t2
sw $t0, int.temp_11
lw $t0, int.i.1
sw $t0, int.temp_14
lw $t1, int.temp_14
li $t2, 3
mul $t0, $t1, $t2
sw $t0, int.temp_14
lw $t1, int.temp_14
lw $t2, int.j.1
add $t0, $t1, $t2
sw $t0, int.temp_14
lw $t3, int.temp_14
la $t4, int.crr.1
li $t5, 4
mul $t3, $t3, $t5
add $t4, $t4, $t3
lw $t0, int.temp_11
sw $t0, 0($t4)
lw $t0, int.i.1
sw $t0, int.temp_15
lw $t1, int.temp_15
li $t2, 3
mul $t0, $t1, $t2
sw $t0, int.temp_15
lw $t1, int.temp_15
lw $t2, int.j.1
add $t0, $t1, $t2
sw $t0, int.temp_15
lw $t3, int.temp_15
la $t4, int.crr.1
li $t5, 4
mul $t3, $t3, $t5
add $t4, $t4, $t3
lw $a0, 0($t4)
li $v0, 1
syscall
la $a0, string0
li $v0, 4
syscall
label_7:
lw $t1, int.j.1
li $t2, 1
add $t0, $t1, $t2
sw $t0, int.j.1
b label_4
label_6:
label_3:
lw $t1, int.i.1
li $t2, 1
add $t0, $t1, $t2
sw $t0, int.i.1
b label_0
label_2:
li $t0, 0
sw $t0, int.temp_16
lw $s7, int.temp_16
jr $ra
jr $ra
