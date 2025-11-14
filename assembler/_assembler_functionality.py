from _instruction_dicts   import instr_set, mode_set, gr_set, rev_instr_set, rev_mode_set
from _error_handling      import AssemblerSyntaxError, InstructionIDError, AdressModeError, GeneralRegisterError, ProgramAdressError, InstructionTooLongError
from _pmem_text           import pmem_start, pmem_mid, pmem_end



def assemble_instruction(line: str, line_number: int) -> (str, str):
    """
    Translate a single instruction from mnemonic to machine code with a corresponding line comment.
    
    The function takes an assembly language instruction as input and converts it into a machine code format.
    It also generates a line comment that explains the machine code instruction in terms of the original
    assembly components for easier readability and debugging.

    Parameters:
        line (str): A single line of assembly code.
        line_number (int): The current line number in the assembly program for error reporting.

    Returns:
        tuple: Returns a tuple containing the machine code string and its corresponding line comment.

    Raises:
        InstructionTooLongError: If the instruction has more parts than expected.
        InstructionIDError: If the instruction ID is not recognized.
        AdressModeError: If the addressing mode is not recognized.
        GeneralRegisterError: If the specified general register is not recognized or wrongly formatted.
        ProgramAdressError: If the address is invalid or wrongly formatted.
    """

    # Split the instruction into parts if necessary (for instructions with operands)
    parts = line.split()
    
    op_id = parts[0]  # The first part is the instruction ID
    mode_id, grx_id, adress_id = "imm", "r0", "#0000"
    
    # Attempt to extract additional parts, handling absence with default values
    try:
        mode_id = parts[1]
    except IndexError:
        pass

    try:
        grx_id = parts[2]
    except IndexError:
        pass

    try:
        adress_id = parts[3]
    except IndexError:
        pass

    # Raise error if instruction is too long
    if len(parts) > 4:
        raise InstructionTooLongError(line, line_number)


    # Raise error if instruction parameters are invalid
    instr_id = instr_set.get(op_id.upper())   
    if not instr_id:
        raise InstructionIDError(op_id, line, line_number)
    
    adress_mode = mode_set.get(mode_id.lower())
    if not adress_mode:
        raise AdressModeError(mode_id, line, line_number)
    
    greg_id = gr_set.get(grx_id.upper())
    if not greg_id:
        raise GeneralRegisterError(grx_id, line, line_number)
    
    adress_approved = False
    if (len(adress_id) == 5):
        if (adress_id[0] == "#") and (adress_id[1:].isdigit()):
            adress_approved = True
    if not adress_approved:
        raise ProgramAdressError(adress_id, line, line_number)
    else:
        adress_slice = adress_id[1:]

    # Assemble the machine instruction with it's corresponding line comment for the VHDL-program
    machine_instruction = 'x"' + instr_id + adress_mode + greg_id + adress_slice + '",'
    line_comment = '   --   ' + rev_instr_set[instr_id] + rev_mode_set[adress_mode] + " r" + greg_id + "   " + adress_id

    return machine_instruction, line_comment



def assemble_program(program: str) -> str:
    """
    Translate an entire program from assembly to machine code, including program memory wrappers.
    
    The function processes each line of the input assembly code, converting it to machine code using
    `assemble_instruction` function and keeping track of line numbers and instruction count.
    It also adds a header and footer to the output based on predefined program memory addresses.

    Parameters:
        program (str): The entire assembly program as a single string.

    Returns:
        str: The complete machine code program wrapped in predefined memory addresses, ready for execution.
    """
    machine_code_program = []
    instruction_amount = 0
    line_counter = 1
    space_counter = 16
    
    for instruction in program.split('\n'):
        if instruction.strip() == "":  # Skip empty lines
            line_counter += 1
            continue
        machine_code, line_comment = assemble_instruction(instruction, line_counter)
        machine_code_program.append(machine_code + line_comment)
        instruction_amount += 1
        
        space_counter -= 1
        line_counter += 1

        if space_counter == 0:
            machine_code_program.append("")
            space_counter = 16
    
    return pmem_start + str(instruction_amount-1) + pmem_mid + '\n'.join(machine_code_program[:-1]) + "\n" + machine_code[:-1] + " " + line_comment + pmem_end