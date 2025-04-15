asect 0xf0

IO>
IO_Y: ds 1
IO_X: ds 1
gameState: ds 1 #старт 1, финиш 0
bithCondition: ds 1 #кол во соседей для рождения
survivalCondition: ds 1 #кол во соседей для выживания
gameMode: ds 1 
changeCellState: ds 1 #изменить состояние текущей клетки на противоположное
updateFixedBuffer: ds 1 #обновить экран
cellState: ds 1 
countOfNeighbors: ds 1  #кол во живых соседей  
isRowNull: ds 1 #пропуск строки
showResult: ds 1 # нужно для status bar для показа результата win lose
vars>  
x: dc 0 #счетчик x
y: dc 0 #счетчик y



asect 0x00

ldi r1, gameState
ld r1, r1
do
  ldi r1, y
  ld r1, r1
  ldi r2, 31
  
  while
     cmp r1, r2
  stays ne
    
    ldi r1, y
    ld r1, r1
    ldi r0, IO_Y
    st r0, r1
    
    ldi r1, x
    ld r1, r1
    ldi r0, IO_X
    st r0, r1
    
    
    ldi r2, isRowNull
    ld r2, r2
    ldi r1, 0
    if
      cmp r1, r2
    is eq
      ldi r0, cellState
      ld r0, r0
      ldi r1, 1
      
      if 
        cmp r0, r1
      is eq
        #если клетка уже живая, проверяем условие выживаня
        ldi r0, countOfNeighbors
        ld r0 ,r0
        ldi r1, survivalCondition
        ld r1, r1
        
        if 
          cmp r0, r1
        is hs
          ldi r0, 1
          ldi r1, changeCellState
          st r1, r0
        fi
      else
        #если не живая
        ldi r0, countOfNeighbors
        ld r0 ,r0
        ldi r1, bithCondition
        ld r1, r1
        
        if 
          cmp r0, r1
        is hs
          ldi r0, 1
          ldi r1, changeCellState
          st r1, r0
        fi
      
      fi
    else
      ldi r0, x
      ldi r3, -1
      st r0, r3
      inc r1
    fi
    
    #изменение индексов
    ldi r0, x
    ld r0, r0
    ldi r2, 31
    inc r0
    ldi r1, y
    ld r1, r1
    #переход на следующую строку
    if 
      cmp r0, r2
    is eq
      ldi r0, x
      ldi r3, 0
      st r0, r3
      inc r1
    fi
    
    ldi r1, y
    ld r1, r1
    ldi r2, 31
  wend
  
  #обновить экран
  ldi r0, 1
  ldi r1, updateFixedBuffer
  st r1, r0

  ldi r1, gameState
    ld r1, r0
    tst r0
until nz
end
