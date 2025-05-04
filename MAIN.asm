asect 0x0030
anyChangesFlag: ds 1 
minBound: ds 1 # левая верхняя граница
maxBound: ds 1 # правая нижняя граница

asect 0x0020 #таблицы условий 
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
cellState: ds 1 #текущее состояние ячейки
countOfNeighbors: ds 1  #кол во живых соседей  
isRowNull: ds 1 #пропуск строки
showResult: ds 1 # нужно для status bar для показа результата win / lose
noAnyAlive: ds 1 #все клетки мертвы
zoneWidth: ds 1 #ширина зоны
deathCondifNull: ds 1 # условие смерти, если нет соседей
drowPattern: ds 1 # отрисовка паттерна
IDofPattern: ds 1 # ID паттерна


asect 0x0100
br main


computingCell: #r0 - состояние ячейки, r1 - сумма соседей
    if
        tst r0
    is z 
        if
            tst r1
        is z
            rts
        fi
    fi

    if
        tst r1
    is z # если нет соседей
        ldi r2, deathCondifNull
        ld r2, r2

        
    else # если есть соседи
        if 
            tst r0
        is z
            ldi r2, birthCondition
        else
            ldi r2, deathCondition
        fi

        dec r1
        add r1, r2 # адрес ячейки условия
        ld r2, r2
    fi


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
    setsp 0x0080


    ldi r2, drowPattern
    do
        ld r2, r3
        if 
            tst r3
        is nz
            jsr drow
            ldi r2, drowPattern
            st r2, r2 # сбрасываем флаг отрисовки
        fi

        ldi r2, drowPattern
        ldi r0, gameState
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

        ldi r2, 0 # границы зоны
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
            ldi r0, zoneWidth
            ld r0, r0
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
    fi


    ldi r0, anyChangesFlag
    ldi r1, 0
    st r0, r1 # флаг изменений = 0

    ldi r0, updateFixedBuffer
    st r0, r0 # обновляем буфер
    
    ldi r3, IO_Y
    ldi r0, minBound
    ld r0, r3



    do
        push r3
        #проверка на game OFF
        if
            ldi r0, gameState
            ld r0, r0
            tst r0
        is z
            jsr main
        fi
        
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
            

            ldi r0, IO_X #отправляем X в схему
            st r0, r3

            ldi r0, cellState
            ld r0, r0
            ldi r1, countOfNeighbors
            ld r1, r1

            
            push r2
            jsr computingCell
            pop r2
            
            inc r3

            ldi r0, maxBound
            ld r0, r0
            cmp r3, r0
        until hi
        
        nextRow:
        pop r3
        inc r3
        ldi r0, maxBound
        ld r0, r0
        cmp r3, r0
        
    until hi



    if
        ldi r0, gameMode
        ld r0, r0
        tst r0
    is nz
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
            jsr main
        else
            jsr generation
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
        jsr generation
    fi


drow:
    ldi r0, IO_Y
    ld r0, r0 
    ldi r1, IO_X
    ld r1, r1

    ldi r2, IDofPattern
    ld r2, r2
    if 
        tst r2
    is z
        jsr glider
        rts
    fi
    if
        ldi r3, 1
        cmp r2, r3
    is eq
        jsr blinker
        rts
    fi
    if
        ldi r3, 2
        cmp r2, r3
    is eq
        jsr butterfly
        rts
    fi
    if 
        ldi r3, 3
        cmp r2, r3
    is eq
        jsr byflops
        rts
    fi
    if
        ldi r3, 4
        cmp r2, r3
    is eq
        jsr monogram
        rts
    fi
    if 
        ldi r3, 5
        cmp r2, r3
    is eq
        jsr mickeyMouse
        rts
    fi
    if 
        ldi r3, 6
        cmp r2, r3
    is eq
        jsr unix
        rts
    fi
    if
        ldi r3, 7
        cmp r2, r3
    is eq
        jsr queenBee
        rts
    fi
rts



#================|Patterns|================#

glider: #r1 - X , r0 - Y
    ldi r2, changeCellState
    dec r0
    st r2, r2
    inc r0
    dec r1
    st r2, r2
    inc r0
    st r2, r2
    inc r1
    st r2, r2
    inc r1
    st r2, r2
rts

blinker:
    ldi r2, changeCellState
    dec r0
    st r2, r2
    inc r0
    st r2, r2
    inc r0
    st r2, r2
rts

butterfly:
    ldi r2, changeCellState
    dec r0
    st r2, r2
    inc r1
    st r2, r2
    dec r0
    st r2, r2
    inc r0
    inc r0
    st r2, r2
    inc r0
    dec r1
    st r2, r2
    dec r1
    st r2, r2
    dec r0
    st r2, r2
    inc r0
    dec r1
    st r2, r2
rts

byflops:
    ldi r2, changeCellState
    dec r1
    st r2, r2
    dec r1
    dec r0
    st r2, r2
    inc r1
    inc r1
    dec r0
    st r2, r2
    dec r0
    st r2, r2
    inc r1
    inc r0
    inc r1
    st r2, r2
    inc r0
    inc r0
    inc r1
    st r2, r2
    dec r1
    st r2, r2
    dec r1
    st r2, r2
    dec r1
    st r2, r2
    dec r1
    dec r1
    inc r0
    st r2, r2
    inc r1
    inc r1
    inc r0
    st r2, r2
    inc r0
    st r2, r2
    inc r1
    dec r0
    inc r1
    st r2, r2
rts

monogram:
    ldi r2, changeCellState
    dec r0
    st r2, r2
    dec r1
    inc r0
    st r2, r2
    dec r1
    st r2, r2
    dec r0
    st r2, r2
    dec r0
    st r2, r2
    dec r1
    st r2, r2
    inc r0
    inc r0
    inc r0
    inc r0
    st r2, r2
    inc r1
    st r2, r2
    dec r0
    st r2, r2
    inc r1
    inc r1
    st r2, r2
    inc r1
    dec r0
    st r2, r2
    inc r1
    st r2, r2
    dec r0
    st r2, r2
    dec r0
    st r2, r2
    inc r1
    st r2, r2
    inc r0
    inc r0
    inc r0
    inc r0
    st r2, r2
    dec r1
    st r2, r2
    dec r0
    st r2, r2
rts

mickeyMouse:
    ldi r2, changeCellState
    st r2, r2
    dec r1
    dec r0
    st r2, r2
    dec r0
    st r2, r2
    dec r1
    dec r0
    st r2, r2
    dec r1
    st r2, r2
    dec r1
    dec r0
    st r2, r2
    dec r0
    st r2, r2
    dec r0
    inc r1
    st r2, r2
    inc r1
    st r2, r2
    inc r1
    inc r0
    st r2, r2
    inc r0
    st r2, r2
    inc r1
    st r2, r2
    inc r1
    st r2, r2
    inc r1
    st r2, r2
    dec r0
    st r2, r2
    dec r0
    inc r1
    st r2, r2
    inc r1
    st r2, r2
    inc r1
    inc r0
    st r2, r2
    inc r0
    st r2, r2
    inc r0
    dec r1
    st r2, r2
    dec r1
    st r2, r2
    dec r1
    inc r0
    st r2, r2
    dec r1
    st r2, r2
    dec r1
    st r2, r2
    inc r1
    inc r1
    inc r0
    st r2, r2
    inc r0
    dec r1
    st r2, r2
rts

unix:
    ldi r2, changeCellState
    st r2, r2
    dec r1
    st r2, r2
    dec r1
    dec r0
    st r2, r2
    dec r1
    dec r1
    st r2, r2
    dec r1
    st r2, r2
    dec r0
    st r2, r2
    inc r1
    st r2, r2
    inc r1
    inc r1
    inc r1
    st r2, r2
    dec r0
    inc r1
    st r2, r2
    dec r0
    inc r1
    st r2, r2
    dec r0
    dec r0
    dec r0
    st r2, r2
    dec r0
    st r2, r2
    inc r1
    st r2, r2
    inc r0
    st r2, r2
    inc r0
    inc r0
    st r2, r2
    inc r1
    inc r0
    st r2, r2
    inc r0
    st r2, r2
rts

queenBee:
    ldi r2, changeCellState
    st r2, r2
    dec r1
    st r2, r2
    inc r0
    dec r1
    st r2, r2
    dec r1
    st r2, r2
    dec r0
    dec r0
    inc r1
    st r2, r2
    inc r1
    dec r0
    st r2, r2
    dec r0
    inc r1
    st r2, r2
    inc r1
    inc r0
    st r2, r2
    inc r0
    inc r1
    st r2, r2
    inc r0
    dec r1
    st r2, r2
    inc r0
    inc r1
    st r2, r2
    inc r1
    st r2, r2
rts 

#=============|End of Patterns|=============#

halt
end
