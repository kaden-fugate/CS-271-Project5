TITLE Generating, Sorting, and Counting Random Integers!	(Proj5_fugateka.asm)

; Author: Kaden Fugate
; Last Modified: August 13th, 2023
; OSU email address: fugateka@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5        Due Date: August 13th, 2023
; Description: This program will generate a given amount of random integers and store them in a list.
; After generating and storing these numbers, the program will sort the array. After the array is sorted,
; the program will find the arrays median and it will count the amount of occurences of each unique value.
; The amount of each occurence will be stored in the "count" array

INCLUDE Irvine32.inc

LO          = 15
HI          = 50
ARRAYSIZE   = 200

.data

    intro    BYTE    "Generating, Sorting, and Counting Random Integers! Programmed by Kaden Fugate", 0
    intro_1  BYTE    "This program generates ", 0
    intro_2  BYTE    " random integers between ", 0
    intro_3  BYTE    " and ", 0
    intro_4  BYTE    ", inclusive.", 0
    intro_5  BYTE    "It will then display the original list, sort the list, display the median value of the list, display the list sorted in ascending order, and finally display the number of instances of each generated value, starting with the lowest number.", 0
    farewell BYTE    "Goodbye, and thanks for grading my program; I hope you like it!", 0

    unsorted_title  BYTE    "Your unsorted numbers: ", 0
    sorted_title    BYTE    "Your sorted numbers: ", 0
    median_title    BYTE    "Median of array: ", 0
    count_title     BYTE    "Your list of instances of each generated number, starting with the smallest value:", 0

    space    BYTE    " ", 0
    array    DWORD   ARRAYSIZE   DUP(?)
    count    DWORD   (HI-LO)+1   DUP(?)       

.code

main PROC

    call    Randomize

    push    OFFSET  intro_5
    push    OFFSET  intro_4
    push    OFFSET  intro_3
    push    OFFSET  intro_2
    push    OFFSET  intro_1
    push    OFFSET  intro
    call    introduction

    push    OFFSET  array
    call    fillArray

    push    OFFSET  space
    push    ARRAYSIZE
    push    OFFSET  unsorted_title
    push    OFFSET  array
    call    displayList

    ; pushing ARRAYSIZE as param because sort is recursive, this call will start the recursion
    push    ARRAYSIZE
    push    OFFSET  array
    call    sort

    push    OFFSET  space
    push    ARRAYSIZE
    push    OFFSET  sorted_title
    push    OFFSET  array
    call    displayList

    push    OFFSET  median_title
    push    OFFSET  array
    call    displayMedian

    push    OFFSET  array
    push    OFFSET  count
    call    countList

    mov     ecx,    HI
    sub     ecx,    LO
    inc     ecx

    push    OFFSET  space
    push    ecx
    push    OFFSET  count_title
    push    OFFSET  count
    call    displayList

    mov     edx,    OFFSET  farewell
    call    CrLf
    call    CrLf
    call    WriteString

	exit

main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Description: This procedure will introduce and explain the program.
;
; Preconditions: none
;
; Postconditions: none
;
; Receives:
; [ebp+28] = introduction message # 6
; [ebp+24] = introduction message # 5
; [ebp+20] = introduction message # 4
; [ebp+16] = introduction message # 3
; [ebp+12] = introduction message # 2
; [ebp+8]  = introduction message # 1
;
; Returns: none
; ---------------------------------------------------------------------------------
introduction PROC

    push    ebp
    mov     ebp,    esp
    pushad  

    ; move address of program title into edx
    mov     edx,    [ebp + 8]
    call    WriteString
    call    CrLf
    call    CrLf

    ; move address of intro_1 into edx
    mov     edx,    [ebp + 12]
    mov     eax,    ARRAYSIZE
    call    WriteString
    call    WriteDec

    ; move address of intro_2 into edx
    mov     edx,    [ebp + 16]
    mov     eax,    LO
    call    WriteString
    call    WriteDec

    ; move address of intro_3 into edx
    mov     edx,    [ebp + 20]
    mov     eax,    HI
    call    WriteString
    call    WriteDec

    ; move address of intro_4 into edx
    mov     edx,    [ebp + 24]
    call    WriteString
    call    CrLf

    ; move address of intro_5 into edx
    mov     edx,    [ebp + 28]
    call    WriteString
    call    CrLf

    popad   
    pop     ebp

    ret     8

introduction ENDP

; ---------------------------------------------------------------------------------
; Name: fillArray
;
; Description: This procedure will fill an array with random numbers
;
; Preconditions: Randomize must have been called in main in order to randomize seed
;
; Postconditions: none.
;
; Receives:
; [ebp+8] = address of the array to fill
;  ARRAYSIZE as a global constant
;
; Returns: array filled with random values
; ---------------------------------------------------------------------------------
fillArray PROC

    push    ebp
    mov     ebp,    esp
    pushad

    ; Store 1st index of arr in esi, size of array in ecx
    mov     esi,    [ebp + 8]
    mov     ecx,    ARRAYSIZE

    __fill_arr_loop:

    ; Get (HI - LO) + 1 for RandomRange
    mov     eax,    HI
    sub     eax,    LO
    inc     eax

    call    RandomRange

    add     eax,    LO

    ; Store random val in array, increment to next index
    mov     [esi],  eax
    add     esi,    TYPE    DWORD

    loop    __fill_arr_loop

    popad
    pop     ebp

    ret     4

fillArray ENDP

; ---------------------------------------------------------------------------------
; Name: displayList
;
; Description: This procedure will display an entire list. This function will only display
; the list holding the (un)sorted values. Will print many following 0's if used to print
; the count array.
;
; Preconditions: array must have been filled using fillArray procedure
;
; Postconditions: none.
;
; Receives:
; [ebp+20] = address of space " " char
; [ebp+16] = length of array to be printed
; [ebp+12] = address of title to be printed
; [ebp+8] = address of first idx of array
;
; Returns: none.
; ---------------------------------------------------------------------------------
displayList PROC

    push    ebp
    mov     ebp,    esp
    pushad

    call    CrLf

    ; ebx = cur nums in row, ecx = arraysize, edx = someTitle address, esi = array address
    mov     ebx,    0
    mov     ecx,    [ebp + 16]
    mov     edx,    [ebp + 12]
    mov     esi,    [ebp + 8]

    call    WriteString
    call    CrLf

    __display_loop:

    ; store cur array value in eax, move to next index in array
    mov     eax,    [esi]
    add     esi,    TYPE    DWORD

    ; ebp + 20 holds address of "space" variable
    mov     edx,    [ebp + 20]
    
    call    WriteDec
    call    WriteString
    inc     ebx

    cmp     ebx,    20
    jne      __not_new_row

    call    CrLf
    mov     ebx,    0

    __not_new_row:

    loop    __display_loop

    popad
    pop     ebp

    ret     8

displayList ENDP

; ---------------------------------------------------------------------------------
; Name: sort
;
; Description: this procedure will sort an array. this procedure is recursive, one
; call of this procedure will sort a single element in the array. the procedure will
; call itself until it has sorted all values.
;
; Preconditions: array must have already been filled to properly sort.
;
; Postconditions: none
;
; Receives:
; [ebp+12] = size of the passed array
; [ebp+8] = address of idx of array
;
; Returns:
; ---------------------------------------------------------------------------------
sort PROC

    push    ebp
    mov     ebp,    esp

    ; eax = address of array, ecx = size of array
    mov     eax,    [ebp + 8] 
    mov     ecx,    [[ebp + 12]]
    dec     ecx

    ; if len of list 0, do nothing
    cmp     ecx,    0
    je      __end

    mov     edx,    eax

    ; store eax & ecx for use after the sorting look
    push    eax
    push    ecx

    ; __sort_loop will put one element of the array in the correct position
    __sort_loop:

    add     edx,    4

    push    edx
    push    eax
    call    exchangeElements

    loop    __sort_loop
    
    pop     ecx
    pop     eax

    ; move to next index of array, decrement array size by 1
    add     eax,    4   

    ; call sort recursively to sort next element of array
    push    ecx
    push    eax
    call    sort

    __end:

    pop     ebp
    ret     8

sort ENDP

; ---------------------------------------------------------------------------------
; Name: exchangeElements
;
; Description: this procedure will take the addresses of two elements and swap the
; values stored inside of them with eachother.
;
; Preconditions: both addresses must point to a value
;
; Postconditions: none.
;
; Receives:
; [ebp+28] = secondn element to be swapped
; [ebp+24] = first element to be swapped
;
; Returns: none.
; ---------------------------------------------------------------------------------
exchangeElements PROC   USES    eax     ebx     ecx     edx

    push    ebp
    mov     ebp,    esp

    ; eax = 1st element, ebx = second element
    mov     eax,    [ebp + 24]
    mov     ebx,    [ebp + 28]

    ; no swap needed if left element <= right element
    mov     ecx,    [eax]
    mov     edx,    [ebx]

    cmp     ecx,  edx
    jle     __no_swap

    ; swap elements
    mov     [eax],    edx
    mov     [ebx],    ecx

    __no_swap:

    pop     ebp

    ret     8

exchangeElements ENDP

; ---------------------------------------------------------------------------------
; Name: displayMedian
;
; Description: This procedure will find the median of an array of numbers.
;
; Preconditions: array must be filled with values and must be sorted
;
; Postconditions: none.
;
; Receives:
; [ebp+12] = title to be displayed for median
; [ebp+8] = address of first idx of array for median to be found in
; ARRAYSIZE as a global constant
;
; Returns: none.
; ---------------------------------------------------------------------------------
displayMedian PROC

    LOCAL   dword_size: DWORD
    mov     dword_size,     SIZE    DWORD

    ; eax = array size, ebx = divisor, esi = 1st index of array
    mov     eax,    ARRAYSIZE
    mov     ebx,    2
    mov     edx,    0
    mov     esi,    [ebp + 8]

    div     ebx

    ; eax will hold the middle index of array (if array size odd)
    dec     eax
    add     eax,    edx
    push    edx
    mul     dword_size
    pop     edx

    mov     ecx,    [esi + eax]

    ; if size of arr even, no true middle
    cmp     edx,    1
    je      __odd_array

    ; add next index to middle
    add     eax,    dword_size
    add     ecx,    [esi + eax]

    mov     eax,    ecx
    div     ebx

    ; adding remainder will take care of round half up rounding method
    add     eax,    edx
    mov     ecx,    eax

    __odd_array:

    mov     edx,    [ebp + 12]
    mov     eax,    ecx

    call    CrLf
    call    WriteString
    call    WriteDec
    call    CrLf

    ret     8

displayMedian ENDP

; ---------------------------------------------------------------------------------
; Name: countList
;
; Description: This function will count the amount of times each unique number appears
; in the array and will add that value to the count array.
;
; Preconditions: none.
;
; Postconditions: none.
;
; Receives:
; [ebp+12] = address of (un)sorted array
; [ebp+8] = address of count array
; ARRAYSIZE, LO, and HI as global constants
;
; Returns: an array holding the count of each unique elements appearances
; ---------------------------------------------------------------------------------
countList PROC

    push    ebp
    mov     ebp,    esp

    ; eax = first val to check, edi = count, esi = array
    mov     eax,    LO
    mov     ecx,    ARRAYSIZE
    mov     edi,    [ebp + 8]
    mov     esi,    [ebp + 12]

    __count_loop:

    ; count # of current val to check
    push    ecx
    push    eax
    push    esi
    push    edi
    call    countNum

    inc     eax
    add     edi,    4

    ; if eax > HI, break loop
    cmp     eax,    HI
    jle     __count_loop

    pop     ebp
    ret     8

countList ENDP

; ---------------------------------------------------------------------------------
; Name: countNum
;
; Description: this recursive function will check if a given index of an array matches
; the number it is given. If true, it will increment the corresponding index in the count 
; array. After checking one index of the array, it will then call itself again on the
; next index of the array until it reaches the end of the array.
;
; Preconditions: none
;
; Postconditions: idx of count array may be incremented
;
; Receives:
; [ebp+40] = remaining elements to check in the (un)sorted array
; [ebp+36] = value to check if idx is equal to
; [ebp+32] = address of the cur index of the (un)sorted array
; [ebp+28] = address of the cur index of the count array
;
; Returns: none.
; ---------------------------------------------------------------------------------
countNum PROC   USES    eax     ebx    ecx     edi     esi

    push    ebp
    mov     ebp,    esp

    ; eax = value to search for, ecx = len of edi, edi = * cur idx of list, esi = * cur index of count
    mov     eax,    [ebp + 36]
    mov     ecx,    [ebp + 40]
    mov     edi,    [ebp + 32]
    mov     esi,    [ebp + 28]

    cmp     [edi],  eax
    jne     __not_equal

    ; increment value in count array
    mov     ebx,    [esi]
    inc     ebx
    mov     [esi],  ebx

    __not_equal:

    ; recursion base case - if list is len 1, stop recursion
    dec     ecx
    cmp     ecx,    0
    je      __done_checking

    ; if len > 1, increment to next index of array, count numbers starting from there
    add     edi,    4

    push    ecx
    push    eax
    push    edi
    push    esi
    call    countNum

    __done_checking:
    
    pop     ebp
    ret     16

countNum ENDP

END main
