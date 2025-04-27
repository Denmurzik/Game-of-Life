asect 0x0020
anyChangesFlag: ds 1 
minBound: ds 1 # левая верхняя граница
maxBound: ds 1 # правая нижняя граница

asect 0x0010
birthCondition: ds 8
deathCondition: ds 8

asect 0x0000
IO_Y: ds 1
IO_X: ds 1
gameState: ds 1 #старт 1, финиш 0
IObirthCondition: ds 1 #кол во соседей для рождения
IOsurvivalCondition: ds 1 #кол во соседей для выживания
gameMode: ds 1 # режим игры 0 - обычный, 1 - с границами
changeCellState: ds 1 #изменить состояние текущей клетки на противоположное
updateFixedBuffer: ds 1 #обновить экран
cellState: ds 1 
countOfNeighbors: ds 1  #кол во живых соседей  
isRowNull: ds 1 #пропуск строки
showResult: ds 1 # нужно для status bar для показа результата win / lose
noAnyAlive: ds 1 #все клетки мертвы


asect 0x0100
br main

computingCell: #r0 - состояние ячейки, r1 - сумма соседей
    if 
        tst r0
    is nz
        ldi r2, deathCondition
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
        ldi r0, anyChangesFlag
        ldi r1, 1
        st r0, r1 # флаг изменений = 1
    fi
rts

loadingCondition: #r1 - адрес, r0 - IO условие
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
    setsp 0x0040

    ldi r0, gameState
    do
        ld r0, r1
        tst r1
    until nz  # ждем старта игры
    
    # загрузка условий
    ldi r1, IObirthCondition
    ld r1, r0
    ldi r1, birthCondition
    jsr loadingCondition

    ldi r1, IOsurvivalCondition
    ld r1, r0
    not r0 #из условия выживания получаем условия смерти
    ldi r1, deathCondition
    jsr loadingCondition

    if
        ldi r0, gameMode
        ld r0, r0
        tst r0
    is nz
        ldi r0, minBound
        ldi r1, 1
        st r0, r1
        ldi r0, maxBound
        ldi r1, 30
        st r0, r1

        ldi r2, 1 # границы
    else
        ldi r0, minBound
        ldi r1, 0
        st r0, r1
        ldi r0, maxBound
        ldi r1, 31
        st r0, r1
    fi


    generation:

    if
        ldi r0, gameMode
        ld r0, r0
        tst r0
    is nz
        if
            ldi r0, 15
            cmp r2, r0
        is eq
            br showResultOfGame
        fi

        if
            ldi r0, noAnyAlive
            ld r0, r0
            tst r0
        is nz
            showResultOfGame:
            ldi r0, showResult
            st r0, r0 # показываем результат
            ldi r0, gameState
            st r0, r0
            br main
        fi

        push r2
    fi


#======================# Промежуточные метки для возврата в main/generation
    main1: 
    if
        pop r0
        ldi r1, 0x0f
        cmp r0, r1
    is hs
        pop r0
        br main
    else
        push r0
    fi
    
    generation1:
    if
        pop r0
        ldi r1, 0x03
        cmp r0, r1
    is hs
        pop r0
        br generation
    else 
        push r0
    fi
#======================#



    ldi r0, anyChangesFlag
    ldi r1, 0
    st r0, r1 # флаг изменений = 0

    ldi r0, updateFixedBuffer
    st r0, r0 # обновляем экран
    
    ldi r3, IO_Y
    ldi r0, minBound
    ld r0, r3
    push r3



    do
        
        ldi r0, IO_Y #отправляем Y в схему
        st r0, r3

        #пропуск пустой строки
        ldi r0, isRowNull
        ld r0, r0
        tst r0
        bnz nextRow
        

        ldi r3, IO_X
        ldi r0, minBound
        ld r0, r3
        

        do
            #проверка на game OFF
            if
                ldi r0, gameState
                ld r0, r0
                tst r0
            is z
                jsr main1
            fi

            ldi r0, IO_X #отправляем X в схему
            st r0, r3

            ldi r0, cellState
            ld r0, r0
            ldi r1, countOfNeighbors
            ld r1, r1

            if 
                tst r1
            is nz
                jsr computingCell
            else
                if
                    tst r0
                is nz
                    ldi r0, changeCellState
                    st r0, r0
                    ldi r0, anyChangesFlag
                    ldi r1, 1
                    st r0, r1 # флаг изменений = 1
                fi
            fi
            
            
            inc r3

            ldi r0, maxBound
            ld r0, r0
            cmp r3, r0
        until hs
        
        nextRow:
        pop r3
        inc r3
        ldi r0, maxBound
        ld r0, r0
        cmp r3, r0
        push r3
    until hs



    if
        ldi r0, gameMode
        ld r0, r0
        tst r0
    is nz
        pop r2
        inc r2
    fi

    if
        ldi r0, gameMode
        ld r0, r0
        tst r0
    is z # если creative
        ldi r0, anyChangesFlag 
        ld r0, r0
        if 
            tst r0
        is z
            ldi r0, gameState
            st r0, r0
            jsr main1
        else
            jsr generation1
        fi
    else # если survival
        ldi r0, minBound
        ld r0, r1
        inc r1
        st r0, r1 

        ldi r0, maxBound
        ld r0, r1
        ldi r0, 31
        push r2
        sub r0, r2
        ldi r0, maxBound
        st r0, r2
        pop r2
        jsr generation1
    fi

halt
end
