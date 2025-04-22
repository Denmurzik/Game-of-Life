asect 0xdf
noChangesFlag: ds 1 

asect 0xe0
birthCondition: ds 8
dethCondition: ds 8

asect 0xf0
IO_Y: ds 1
IO_X: ds 1
gameState: ds 1 #старт 1, финиш 0
IObithCondition: ds 1 #кол во соседей для рождения
IOsurvivalCondition: ds 1 #кол во соседей для выживания
gameMode: ds 1 
changeCellState: ds 1 #изменить состояние текущей клетки на противоположное
updateFixedBuffer: ds 1 #обновить экран
cellState: ds 1 
countOfNeighbors: ds 1  #кол во живых соседей  
isRowNull: ds 1 #пропуск строки
showResult: ds 1 # нужно для status bar для показа результата win lose

asect 0x00
br preparation


loadingCondition: #принимает r0 - условие, r1 - адрес для записи
  ldi r3, 8
  while
    tst r3
  stays nz
    ldi r2, 1
    and r0, r2
    st r1, r2
    inc r1
    shra r0
    dec r3
  wend
rts

computationCell: #принимает r0 - сумму соседий > 0, r1 - состояние ячейки
  if
    tst r1
  is z
    ldi r2, birthCondition
  else
    ldi r2, dethCondition
  fi

  dec r0
  add r0, r2
  ld r2, r2

  if
    tst r2
  is nz
    ldi r0, invertCellState
    st r0, r0

    ldi r0, noChangesFlag
    st r0, r0
  fi
rts

preparation:
  setsp 0xc0

  ldi r1, gameState
  do
    ld r1, r0
    tst r0
  until nz

  ldi r1, IObirthCondition
  ld r1, r0
  ldi r1, birthCondition
  jsr loadingCondition

  ldi r1, IOsurvivalCondition
  ld r1, r0
  ldi r1, dethCondition
  jsr loadingCondition


main:
  ldi r0, noChangesFlag
  ldi r1, 0
  st r0, r1 

  ldi r0, updateFixedBuffer
  st r0, r0

  


end
