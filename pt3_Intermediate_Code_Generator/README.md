**Requirements**

FOR COMPILATION 
- well.cs.ucr.edu
    - OR -
- gcc version 4.1.2 20080704 (Red Hat 4.1.2-55)
- flex version 2.5.4
- bison (GNU) version 2.3

FOR EXECUTION   
- bolt.cs.ucr.edu
    - OR -
- gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC)  

**Examples**
There are couple of example code files included in this repo. They can be used to make compiler parser work.  
**Running the Code**
The code can be run by following the sequence of commands:

    make clean
    make
    ./mini_l *filename*.min > filename.mil   
    /*This performs lexical analysis, Parsing, Semantic Analysis and MIL Code generation on the file containing mini l code in filename.min, and redirects the MIL code output to filename.mil*/
    ./mil_run filename.mil < input.txt
    /*executing the generated MIL code with input provided from input.txt*/

**Known Bugs**

 1. [FIXED]~~Cannot read multiple input items from the same line~~
 2. [FIXED]~~Function lookups not implemented~~

**Features Added in Last Commit**
 - Fixed faulty MIL generation of array declaration statement.
 - Added function to check for proper declaration of variables before use.
 - Added Do-While loops
 - Fixed While loop-label naming conventions 
 - Can read multiple items in a single read statement
 - Added function lookups
