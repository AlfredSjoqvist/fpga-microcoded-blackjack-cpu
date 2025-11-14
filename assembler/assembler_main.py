import os
from _assembler_functionality import assemble_program

ASSEMBLE_ALL = True
FILENAME = "kebabian"

def main():
    """
    === MAIN FUNCTION OF ShawarmianAssembler 1.0 ===

    Execute the assembly process for one or multiple assembly (.asm) files.

    This function serves as the main entry point for the ShawarmianAssembler. It reads .asm files from a specified
    directory, assembles them into machine code using the `assemble_program` function, and writes the resulting
    machine code into corresponding .vhd files. It handles both individual file assembly and bulk assembly of all
    .asm files within the directory, controlled by the `ASSEMBLE_ALL` global variable.

    The function iterates over each .asm file, performs the assembly, and reports success for each file processed.
    In case of errors during the reading, assembly, or writing processes, it captures and prints the exceptions.

    Global Variables:
        ASSEMBLE_ALL (bool): Determines whether to assemble all .asm files in the directory or just a specific file.
        FILENAME (str): Specifies the filename to assemble when `ASSEMBLE_ALL` is False.

    Side Effects:
        Reads from and writes to the filesystem.
        Prints the status of assembly operations to standard output.
        Writes machine code to .vhd files corresponding to each .asm file processed.
    """

    directory = "assembler"
    
    # List all .asm files in the directory if ASSEMBLE_ALL is True, or just a specific file otherwise.
    if ASSEMBLE_ALL:
        asm_files = [f for f in os.listdir(directory) if f.endswith('.asm')]
    else:
        asm_files = [FILENAME + ".asm"]

    # Process each file, assemble its contents and write the output to a .vhd file
    for asm_file in asm_files:
        asm_path = os.path.join(directory, asm_file)      # Full path to the .asm file
        vhd_filename = asm_file.replace('.asm', '.vhd')   # Replace .asm extension with .vhd
        vhd_path = os.path.join(directory, vhd_filename)  # Full path to the .vhd file

        try:
            with open(asm_path, "r") as file:
                assembly_program = file.read()
            machine_code = assemble_program(assembly_program)
            

            # Check if any changes has been made to the VHDL file with the same name, if so - overwrite it
            with open(vhd_path, "r") as vhd_file_r:
                if (vhd_file_r.read() != machine_code):
                    with open(vhd_path, "w") as vhd_file_w:
                        vhd_file_w.write(machine_code)
                        print(f"The contents of {asm_file} has been successfully assembled.")

        except Exception as e:
            print(f"\nWhen assembling {asm_file} the following was encountered:")
            print(f"{e}\n")


if __name__ == "__main__":
    main()