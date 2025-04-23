asect 0xdf
noChangesFlag: ds 1 

asect 0xe0
birthCondition: ds 8
dethCondition: ds 8

asect 0xf0
IO_Y: ds 1
IO_X: ds 1
gameState: ds 1 #старт 1, финиш 0
IObirthCondition: ds 1 #кол во соседей для рождения
IOsurvivalCondition: ds 1 #кол во соседей для выживания
gameMode: ds 1 
changeCellState: ds 1 #изменить состояние текущей клетки на противоположное
updateFixedBuffer: ds 1 #обновить экран
cellState: ds 1 
countOfNeighbors: ds 1  #кол во живых соседей  
isRowNull: ds 1 #пропуск строки
showResult: ds 1 # нужно для status bar для показа результата win / lose

asect 0x00
br main

computeingCell: #r0 - состоние ячейки, r1 - сумма соседей
    if 
        tst r0
    is nz
        ldi r2, dethCondition
    else
        ldi r2, birthCondition
    fi

    dec r1
    add r1, r2 # адрес ячейки условия
    ld r2, r2

    if
        tst r2
    is nz
        ldi r0, changeCellState
        st r0, r0
        ldi r0, noChangesFlag
        ldi r1, 1
        st r0, r1 # флаг изменений = 1
    fi
rts

loadingCondition: #r1 - адрес, r0 - условие
    ldi r2, 8
    while 
        tst r2
    stays nz
        ldi r3, 1 # маска
        and r0, r3
        st r1, r3
        shra r0
        inc r1
        dec r2
    wend
rts



main:
    setsp 0xdf
    

    ldi r0, gameState
    do
        ld r0, r1
        tst r1
    until nz  # ждем старта игры

    ldi r0, updateFixedBuffer
    st r0, r0
    
    # загрузка условий
    ldi r1, IObirthCondition
    ld r1, r0
    ldi r1, birthCondition
    jsr loadingCondition

    ldi r1, IOsurvivalCondition
    ld r1, r0
    not r0
    ldi r1, dethCondition
    jsr loadingCondition

    rowIteration:
    ldi r0, noChangesFlag
    ldi r1, 0
    st r0, r1 # флаг изменений = 0

    ldi r0, updateFixedBuffer
    st r0, r0 # обновляем экран
    
    ldi r3, 31 # Y
    do
        push r3
        ldi r0, IO_Y
        st r0, r3

        if
            ldi r0, isRowNull
            ld r0, r0
            tst r0
        is nz
            br nextRow
        fi

        ldi r3, 31 # X

        do
            ldi r0, IO_X
            st r0, r3

            ldi r0, cellState
            ld r0, r0
            ldi r1, countOfNeighbors
            ld r1, r1

            if 
                tst r1
            is nz
                jsr computeingCell
            else
                if
                    tst r0
                is nz
                    ldi r0, changeCellState
                    st r0, r0
                    ldi r0, noChangesFlag
                    ldi r1, 1
                    st r0, r1 # флаг изменений = 1
                fi
            fi

            dec r3
        until mi
        
        nextRow:
        pop r3
        dec r3
    until mi

    ldi r0, noChangesFlag 
    ld r0, r0
    if 
        tst r0
    is z
        ldi r0, gameState
        st r0, r0
        br main
    else
        br rowIteration
    fi


halt
end
