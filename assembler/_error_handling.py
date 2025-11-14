class AssemblerSyntaxError(Exception):

     def __init__(self, line, line_number, appendix="AssemblerSyntaxError: The provided instruction has incorrect syntax."):
        
        self.message = "Exception found at line " + str(line_number) + ":\n" + str(line) + "\n" + appendix
        super().__init__(self.message)

class InstructionIDError(AssemblerSyntaxError):
    
    def __init__(self, instruction, line, line_number):
        
        appendix = self.__class__.__name__ + "The provided instruction '" + str(instruction.upper()) + "' is not included in the instruction set."
        super().__init__(line, line_number, appendix)

class AdressModeError(AssemblerSyntaxError):
    
    def __init__(self, mode, line, line_number):

        appendix = self.__class__.__name__ + "The provided adress mode '" + str(mode.lower()) + "' is not included in the set of modes."
        super().__init__(line, line_number, appendix)

class GeneralRegisterError(AssemblerSyntaxError):
    
    def __init__(self, gr, line, line_number):
        
        appendix = self.__class__.__name__ + "The provided general register '" + str(gr) + "' does not exist, it has to be provided in the format 'rX' where X is the placeholder of the hex ID from 0-F for the register."
        super().__init__(line, line_number, appendix)

class ProgramAdressError(AssemblerSyntaxError):
    
    def __init__(self, adress, line, line_number):
        
        appendix = self.__class__.__name__ + "The provided memory adress '" + str(adress) + "' does not exist, it has to be provided in the format '#XXXX' where XXXX is the placeholder of specific hex numbers for the adress."
        super().__init__(line, line_number, appendix)

class InstructionTooLongError(AssemblerSyntaxError):

    def __init__(self, line, line_number):
        
        appendix = self.__class__.__name__ + ": The provided instruction is too long."
        super().__init__(line, line_number, appendix)