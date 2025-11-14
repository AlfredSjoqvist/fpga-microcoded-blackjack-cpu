# Define your instruction set here. This is a simple example.
instr_set = {
    "NOP": "00",
    "LD": "01",
    "LOAD": "01",
    "ST": "02",
    "STORE": "02",
    "CMP": "03",
    "ADD": "04",
    "SUB": "05",
    "AND": "06",
    "OR": "07",
    "MUL": "08",
    "MULS": "09",
    "LSR": "0A",
    "LSL": "0B",
    "INV": "0C",
    "HALT": "0F",
    "JMP": "10",
    "RJMP": "11",
    "BEQ": "12",
    "BNE": "13",
    "RIV": "20"
    # Add more instructions as needed.
}

mode_set = {
    "imm": "0",
    "immediate": "0",
    
    "dr": "1",
    "dir": "1",
    "direct": "1",
    
    "idr": "2",
    "indir": "2",
    "indirect": "2",
    
    "inx": "3",
    "index": "3",
    "indexed": "3",

    "rel": "4",
    "relative": "4"
}

gr_set = {
    "R0": "0",
    "R1": "1",
    "R2": "2",
    "R3": "3",
    "R4": "4",
    "R5": "5",
    "R6": "6",
    "R7": "7",
    "R8": "8",
    "R9": "9",
    "RA": "A",
    "RB": "B",
    "RC": "C",
    "RD": "D",
    "RE": "E",
    "RF": "F",
}

rev_instr_set = {
 '00': 'NOP    ',
 '01': 'LOAD   ',
 '02': 'STORE  ',
 '03': 'CMP    ',
 '04': 'ADD    ',
 '05': 'SUB    ',
 '06': 'AND    ',
 '07': 'OR     ',
 '08': 'MUL    ',
 '09': 'MULS   ',
 '0A': 'LSR    ',
 '0B': 'LSL    ',
 '0C': 'INV    ',
 '0F': 'HALT   ',
 '10': 'JMP    ',
 '11': 'RJMP   ',
 '12': 'BEQ    ',
 '13': 'BNE    ',
 '20': 'RIV    '}

rev_mode_set = {
    "0": "immediate  ",
    "1": "direct     ",
    "2": "indirect   ",
    "3": "indexed    ",
    "4": "relative   "
}