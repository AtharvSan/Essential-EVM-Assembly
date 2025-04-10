// --- part 2 of a 5 part series on essentials for solidity devs ---
// - Essential-Solidity
// - Essential-EVM-Assembly
// - Essential-Solidity-Cryptography
// - Essential-Solidity-Design-Patterns
// - Essential-Solidity-Security


/* table of contents -------------------*/
// --- notes ---
// - data measurement 
// - data interpretation
// - data systems
// - datatypes
// - literals
// - endian orders
// - data alignment
// - data location
// - data addresses
// - gas notes
// - opcodes
// - inline assembly(yul)

// --- roadmap ---
// - pragmatic applications of inline assembly
// - gas optimization from first principles
// - footguns in assembly


// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract Slot0_And_Slot1{
    /* slot: 0 */ uint256 internal _counter; 
    /* slot: 1 */ bytes4 internal _selector;
    
}

/// @author AtharvSan
/// @notice short notes and compilable cheatsheet of inline-assembly for solidity devs
contract EssentialAssembly is Slot0_And_Slot1 {
    /* slot: 2 */ address internal alice;
    /* slot: 3 */ string internal _contract_name = "EssentialAssembly"; 
    /* slot: 4 */ bool internal _pause; 
    /* slot: 5 */ uint256[] internal _a = [11,12,13];
    /* slot: 6 */ mapping(address => uint256) register;


    /* data measurement -----------------------*/
    // - bit
    //      - we are talking transistors here, a single transistor thats on(1) or off(0)
    //      - bit is the smallest piece of information in computer architecture 
    // - byte
    //      - a group of 8 transistors
    //      - together this group of 8 transistors represent a certain character.
    //      - byte is the fundamental unit of data in computers
    // - word
    //      - a group of 32 bytes
    //      - EVM operates on words
    //
    //     -------------------------------------------------------------------------------------------
    //     | representation of bit, byte and a word in solidity                                      |
    //     |    1 bit  : 0b0                                                                         |
    //     |    1 byte : 0x00                                                                        |
    //     |    1 word : 0x000000000000000000000000000000000000000000000000000000000000000000000000  |
    //     -------------------------------------------------------------------------------------------
    //

    
    /* data interpretation --------------------*/
    // --- raw data ---
    // - bytes class: it stores the raw data, has no associated interpretation to it

    // --- interpreted data ---
    // - uint class: number interpretation from the number systems
    // - string class: character interpretation from the character systems
    // - address class: address interpretation from the eip 55 
    // - bool class: bool interpretation, just two values true and false
    // - enum class: enum interpretation, as per the definition in the code


    /* data systems ---------------------------*/
    // --- number systems ---
    // - ways in which a number is represented
    // - binary: 
    //      - base 2
    //      - symbols: 0 1
    //      - each individual symbol has 1 bit underlying, can represent raw data
    //      - natural number 46 in binary : 101110 (1 0 1 1 1 0)  
    // - hex
    //      - base 16
    //      - symbols: 0 1 2 3 4 5 6 7 8 9 a b c d e f
    //      - each individual symbol has 4 bit underlying, can represent raw data
    //      - natural number 46 in hex : 2e (0010 1110)
    // - decimal
    //      - base 10
    //      - symbols: 0 1 2 3 4 5 6 7 8 9
    //      - individual symbol doesn't have underlying, instead entire number has an underlying
    //      - natural number 46 in decimal : 46 (101110)

    // --- character systems ---
    // - characters are building blocks of strings
    // - ASCII
    //      - interpretation of raw data to represent characters
    // - UTF-8
    //      - extends ASCII to represent more characters


    /* datatypes ------------------------------*/
    // - strict containers for data that maintain sanity in the code
    // - properties:
    //      - have a certain size
    //      - carry a certain interpretation (except bytes datatypes)
    //      - builtin methods
    // - trivia: 
    //      - floating points not supported by solidity
    //             --------------------------------------------------------------------------------------
    //             | base 2  :       8         4        2       1        1/2         1/4          1/8   |
    //             | base 10 :    1000       100       10       1       1/10       1/100       1/1000   |
    //             --------------------------------------------------------------------------------------
    //          - computers are naturally base 2 (transistors can only be On/Off)
    //          - representing base 10 decimals with underlying as base 2 is tricky. Computers need to construct base 10 decimals using base 
    //            2 components and there are unexpected decimal arithmetic outputs in computers so solidity has got rid of floats.
    //          - key point: To mimic decimal behaviour use scaled values by the required decimal places you need
    //      - overflow underflow for datatype values
    //          - max valuation : (base ** trailing symbol places) - 1
    //          - overflow underflow is a common problem that occurs when the output is out of its size for the datatype container

    
    /* literals -------------------------------*/
    // - fixed values of a certain datatype embedded in the code
    // - types of literals
    //     - decimal literals : underscores allowed, NeX allowed
    //     - hexadecimal literals : start with 0x
    //     - binary literals : start with 0b
    //     - address literals : hexadecimals that follow eip55 address checksum
    //     - string literals : "....."
    //     - boolean literal : true/false
    //     - unicode literal : unicode"....."


    /* endian orders --------------------------*/
    // - endian order is 'in which side the data starts?' in computer memory
    // - every data has two sides, consider this data (a 4 byte selector) : a3e9b8f2
    //                                                                      |      ^--- least significant side
    //                                                                      ^^^ most significant side
    // - order
    //      - big-endian : data starts with most significant side in computer memory(the way english is written)
    //      - little-endian : data starts with least significant side in computer memory(the way arabic is written)
    // - key point : EVM stores data in big-endian format when dealing with 32 byte slots
    //
    //    -----------------------------------------------------------------------------------------------------------------------
    //    | example: EVM filling 4 byte selector in 32 byte storage slot in big-endian order (storage is right aligned)         |
    //    |     32 byte slot      : 0000000000000000000000000000000000000000000000000000000000000000                            |
    //    |                                                                                 ^^^^^^^^<-- data is right aligned   |
    //    |     4 byte selector   : a3e9b8f2                                                                                    |
    //    |                         |      ^--- least significant side                                                          |
    //    |                         ^^^ most significant side                                                                   |
    //    |     output            : 00000000000000000000000000000000000000000000000000000000a3e9b8f2                            |
    //    |                                                                                 ^--- data starts with most          |
    //    |                                                                                      significant side               |
    //    -----------------------------------------------------------------------------------------------------------------------
    //


    /* data alignment --------------------------*/
    // - alignment comes into picture when we are placing smaller size data (less than 32-byte) into a full 32-byte word.
    // - storage is right alined as it fits smaller datatyes into storage slots without blowing up their size to full 32 byte words
    // - there is nothing as alignment in memory as everything is blown up to full 32 bytes before being stored in memory(mstore8 is an exception)
    //      - bytes are padded to the right to convert it to 32 bytes, similarly its truncated to the right to recover the original bytes
    //      - numbers(uints) are padded to the left to convert it to 32 bytes, similarly its truncated to the left to recover the original number


    /* data location ---------------------------*/
    // - for convenience everything is denoted in hex notation
    // --- memory ---
    // - structure : 
    //      - byte addressable array, but read write operations apply on 32 byte words starting from the byte address
    //      - expanded in 32-byte chunks
    //    -----------------------------------------------------------------------------------------------------------------|------------------
    //    | 0x00  0x01  0x02  0x03                                                                     .  .  . 0x1e  0x1f  | 0x20  0x21  .  .  .
    //    | 00    00    00    00                                                                       .  .  . 00    00    | 00    00    .  .  .
    //    -----------------------------------------------------------------------------------------------------------------|------------------ 
    // - layout :
    //      - scratch space (0x00 - 0x3f) : temporary storage during execution (kind of like doing rough work on the last page of notebooks)
    //          - It’s not a formal or reserved area, but rather a convention in how compilers (like Solidity's) or developers organize memory.
    //      - Free memory pointer (0x40) : this stores the location to available memory
    //      - zero slot (0x60) : used as default value for uninitialized variables
    //         ---------------------------------------------------------------------------------------- 
    //         |  0x00            0x40    0x60    0x80                                                |
    //         |  ------------------------------------------------------------------                  |   
    //         |  |               |       |       |                                .   .   .   .   .  |
    //         |  ------------------------------------------------------------------                  |
    //         |    ^^^^^^^^^^^^^  ^^^^^^  ^^^^^   ^^^^^                                              |
    //         |          |          |       |       `---> available memory starts here               |
    //         |          |          |       `---> zero slot                                          |
    //         |          |          `---> free memory pointer                                        |
    //         |          `---> scratch space                                                         |
    //         ---------------------------------------------------------------------------------------- 
    //      - no memory packing, each variable occupies a full 32-byte word, even if smaller.
    //      - static arrays: occupy continuous words (element 1, element 2)
    //      - dynamic arrays: occupy continuous words with length in first word (length, element 1, element 2)
    //      - struct flattened and inserted member by member
    //      - mapping not supported in memory, gives compiler error
    // - operations :
    //      - locally available, function scoped
    //      - temporary existence, only for duration of tx
    //      - cheap
    //      - may become expensive for higher memory usage, cost increases quadratically
    //          - memory_expansion_cost = (newWords**2 / 512) - (oldWords**2 / 512)
    //      - notice that even though memory is byte addresable, EVM operates on 32 byte words, so when interacting with address in memory 
    //        the entire 32 byte block from that address is interacted with.
    //      - opcodes : mload, mstore, mstore8
    //      - inline assembly : mload(address), mstore(address, value), mstore8(address, value) 
    
    // --- storage ---
    // - structure : mapping of 32-byte slot number to a 32-byte slot values
    //   -----------------------------------------------------------------------------------------------------------------------------------------
    //   |                                                                                                                                       |
    //   |                                                       slot number : value                                                             |
    //   |  ----------------------------------------------------------------   ----------------------------------------------------------------  |
    //   |  0000000000000000000000000000000000000000000000000000000000000000 : 0000000000000000000000000000000000000000000000000000000000000000  |
    //   |  0000000000000000000000000000000000000000000000000000000000000001 : 0000000000000000000000000000000000000000000000000000000000000000  |
    //   |  0000000000000000000000000000000000000000000000000000000000000002 : 0000000000000000000000000000000000000000000000000000000000000000  |
    //   |                                 .                                                                     .                               | 
    //   |                                 .                                                                     .                               | 
    //   |                                 .                                                                     .                               | 
    //   |                                 .                                                                     .                               | 
    //   |                                 .                                                                     .                               | 
    //   |                                 .                                                                     .                               |
    //   |                                 .                                                                     .                               |
    //   |                                                                                                                                       |
    //   -----------------------------------------------------------------------------------------------------------------------------------------
    // - layout :
    //      - storage starts filling from slot 0 for the state variables
    //      - Storage slots of a parent contract precedes the child in the order of inheritance.
    //      - If the next value can fit into the same slot (determined by type), it is right-aligned in the same slot, else it is stored
    //        in the next slot.
    //      - constant and immutable variables are not stored here instead they are stored in separate location called code
    //      - mappings : 
    //         - the declaration slot remains empty 
    //         - slot number for value of the corresponding key: keccak256(abi.encode(key, mapping_declaration_slot))
    //      - arrays : dynamic arrays store the current length in its slot, its elements are stored sequentially from keccak256(declaration_slot).
    //      - byte arrays and strings : 
    //         - if length is 31 or less, value and lenght is packed into one slot and the right-most byte is occupied by (2 * length)
    //         - for 32 or more bytes long, the main slot p stores (length * 2 + 1) and the data is stored as usual in keccak256(p). 
    //           So you can distinguish short array from long array by checking if the lowest bit is set: short (not set) and long (set)
    //      - structs and arrays always start a new slot. 
    //      - variables after structs and arrays always start a new slot.
    //      - bitwise manupulation needed to retrieve the packed data
    // - operations : 
    //      - globally avilable
    //      - permanent existance
    //      - expensive
    //      - opcodes : sload, sstore
    //      - inline assembly : sload(slot), sstore(slot, value), 
    //          - variable.slot gets you the slot number of that state var

    // --- calldata --- 
    // - structure : same as memory but read-only
    // - layout :
    //      - first 4 bytes is function selector (except for fallback or receieve)
    //      - args are appended in multiples of 32 bytes, ususally handled by encode methods.
    // - operations
    //      - opcodes : calldatasize, calldatacopy, calldataload
    //      - inline assembly : calldatasize(), calldatacopy(memPtr, offset, size), calldataload(offset)    

    // --- stack ---
    // - structure : max 1024 slots of 32 bytes (visvalized as a tower that expand upward)
    // - operations
    //      - last in first out (LIFO)
    //      - opcodes : pushN
    //      - inputs to opcodes are popped from the stack
    //      - results of opcodes are pushed to the stack
    //      - stack is accompanies by a dedicated program counter that locates where in the bytecode the next execution command is

    // --- code ---
    // - a special place where bytecode is stored
    // - constants and immutables get stored here inside the bytecode as literals
    // - You can access any contract's bytecode at runtime
    // - operations
    //      - opcodes : codesize, codecopy, extcodehash, extcodecopy, extcodesize
    //      - inline assembly : codesize(), extcodesize(address), extcodehash(address),
    //                          codecopy(memPtr, offset, size), extcodecopy(memPtr, offset, size)

    // --- return data ---
    // - a special buffer where return values of the last external call are stored — whether it is a call, delegatecall, staticcall
    // - operations
    //      - opcodes : returndatasize, returndatacopy
    //      - inline assembly : returndatasize(), returndatacopy(memPtr, offset, size)
    

    /* data addresses -------------------------*/
    // - data addresses are just numbers, they are mapped to a certain size of bytes
    //      - memeory address : points to a single byte
    //      - storage address : points to a 32 bytes slot 
    //      - stack address : points to a 32 bytes slot
    // - all addresses start with zero (0x00)


    /* gas notes ------------------------------*/
    // - gas is not a seperate entity that can be purchased
    // - what is gas? --> could be understood in two ways, but they are the same thing
    //      - gas is a unit of measuring the resource consumption of your tx
    //      - gas is a unit of measuring blockspace that your tx occupies in the block
    // - the problem : publicly available system resources can be abused if allowed to use freely
    // - the solution : implement a metering system to charge for the resource consumption
    // - implementation :
    //      - metering
    //          - each opcode consumes a certain amount of resources, and it is measured in gas
    //          - tx's resource consumption is the sum total of all its opcode gas values 
    //      - charging 
    //          - gas fees is the ether valuation of 'total gas the tx needs'
    //             -------------------------------------------------------------------------------------------------
    //             |   gas fee = (total gas the tx needs) * (dynamic rate for 1 gas in ether)                      |
    //             |              ^^^^^^^^^^^^^^^^^^^^^^     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                       |
    //             |                        |                             |                                        |
    //             |                        `---> tx gas cost             `---> gas price (market rate of gas)     |
    //             -------------------------------------------------------------------------------------------------
    //          - market rate of gas is determined by the demand and supply for the blockspace
    //      - collection
    //          - it is payable only in ETH 
    //          - gas fees is collected by validators
    //          - tx's gas fee need to be sent along with its tx
    //          - if tx fails, gas used is used (it can't be refunded)
    // - terms and definitions
    //     - gas : a unit of resource usage
    //     - gas price : the market rate of 1 gas in ethers
    //     - gas cost : resource usage of the tx as metered in gas
    //     - gas fee : the fee for tx execution in ethers
    //     - base fee : base fee for the 'txn'
    //     - priority fee : the fee for bypassing the queue
    //     - max fee : max gas you are willing to spend on the txn
    //     - gasLimit : max amt of gas a txn can consume
    //     - block.gaslimit : It caps how much total gas can be consumed across all transactions in the block


    // Gas Optimizations ---------------------*/
    // - gas optimization is the art of reducing heavy gas opcodes while keeping the logic intact.
    // --- Scratch Space Usage ---
    // - Use memory below 0x40 for temporary storage
    // - Avoids updating free memory pointer
    // - Ideal for small, temporary data

    // --- Storage Packing ---
    // - Combine multiple small variables into one slot
    // - Use bitwise operations to pack/unpack values
    // - Reduces SSTORE operations 

    // --- Direct Calldata Access ---
    // - Read directly from calldata without memory copy
    // - Uses calldataload instead of memory operations
    // - Saves 3 gas per word + memory expansion costs

    // --- Efficient Loops ---
    // - Cache array length and calculate end pointer
    // - Avoids repeated mload calls
    // - Saves 3 gas per iteration

    // --- Bitwise Operations ---
    // - Use shifts instead of multiplication/division
    // - shl(4, x) vs x * 16 (saves 5 gas per operation)
    // - Combine with masking for complex operations

    // --- Custom Error Reverts ---
    // - 4-byte error selectors instead of string messages
    // - More efficient than require statements

    // --- Direct Mapping Access ---
    // - Compute storage slots manually with keccak256
    // - Avoids Solidity's abstraction overhead


    /* opcodes --------------------------------*/
    // - detailed reference https://www.evm.codes/ 
    // - they are 1 byte in lenght 
    // - opcodes may take input from stack or have it hardcoded in contract bytecode
    // - warm and cold access
    //      - Warm = previously accessed in tx = cheap
    //      - Cold = first-time access in tx = costly
    // - gas cost
    //      - CREATE 32000
    //      - CREATE2 32000
    //      - CALL 2600 cold, 100 warm
    //      - DELEGATECALL 2600 cold, 100 warm
    //      - STATICCALL 2600 cold, 100 warm
    //      - SSTORE 2100 cold, 100 warm
    //      - SLOAD 2100 cold, 100 warm
    //      - BALANCE 2600 cold, 100 warm
    //      - MSTORE 3
    //      - MSTORE8 3
    //      - MLOAD  3
    //      - CALLDATALOAD 3
    //      - CALLDATACOPY 3
    //      - REVERT 0
    //      - RETURN 0
    //      - LOG0 375
    //      - LOG1 750
    //      - LOG2 1125
    //      - LOG3 1500
    //      - LOG4 1875
    
    
    /* inline assembly(yul) --------------------*/
    // --- syntax ---
    // - assembly{...}
    // - :=  assignment
    // - no use of semicolons
    // - yul manages stack for us, devs manage memory and storage

    // --- variables --- 
    // - all variables are locally declared using let
    // - variables declared inside assembly scope are not available outside
    // - variables declared inside function but outside assemlby scope are avilable inside
    
    // --- types And Literals --- 
    // - no strict types everything is let
    // - all of the literals form solidity can be used here
    // - evm understands only raw bytes, yul infers the types from the operations you do on the data
    function Literals() pure public {
        assembly {
            let x := 82                                             // Decimal
            let y := 0x2A                                           // Hexadecimal
            let addr := 0xdAC17F958D2ee523a2206206994597C13D831ec7  // address
            let z := "abc"                                          // String (stored as bytes)
            let success := true                                     // bool
        }
    }

    // --- mload(p) ---
    // - reads the memory at given location
    function mload() pure public returns(uint256 ptr) {
        assembly{
            ptr := mload(0x40)
        }
    }
    
    // --- mstore(p,v) ---
    // - stores the value at given location
    function mstore() pure public {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 1000)
            mstore(0x40, add(ptr,0x20))
        }
    }
    
    // --- mstore8(p,v) ---
    // - stores the 1 byte value at given location
    function mstore8() pure public {
        assembly {
            let ptr := mload(0x40)
            mstore8(ptr, 100)
            mstore(0x40, add(ptr,0x01))
        }
    }
    
    // --- calldataload(p) ---
    // - reads calldata(32 bytes) from given location 
    function calldataload(bytes calldata data_passed_to_the_function) pure public returns(bytes memory recieved_data) {
        assembly {
            recieved_data := calldataload(0x00)
        }
    }
    
    // --- calldatacopy(t,f,s) ---
    // - copy s bytes from calldata at position f to mem at position t
    // - think of it as hybrid of calldataload and mstore
    function calldatacopy(bytes calldata data_passed_to_the_function) pure public {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x00, 0x20)
            mstore(0x40, add(ptr, 0x20))
        }
    }
    
    // --- sload(p) ---
    // - reads the storage at given location 
    function sload() view public returns(uint256 counter) {
        assembly {
            counter := sload(0)
        }
    }
    
    // --- sstore(p,v) ---
    // - store the value at given location
    function sstore() public {
        assembly {
            sstore(0,100)
        }
    }
    
    // --- return(mem offset, next n bytes) ---
    // - return can only read from memory
    function Return() view public {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, sload(5))
            let returnPosition := ptr
            mstore(0x40, add(ptr, 0x20))
            return(returnPosition, 0x20)
        }
    }

    // --- logs ---
    // - In Yul, events do not have explicit names; instead, they are identified by the Keccak-256 hash of their signature.
    // - Non-indexed parameters are stored in memory and passed to the log instruction using a memory offset and size.
    // - topic1 is always the Keccak-256 hash of the event signature.
    // - log1(mem offset, size, topic1) 
    // - log2(mem offset, size, topic1, topic2)
    // - log3(mem offset, size, topic1, topic2, topic3)
    // - log4(mem offset, size, topic1, topic2, topic3, topic4)
    event simpleEvent(bytes32 data);
    function events() public {
        emit simpleEvent("hello");
    }
    function events_asm() public {
        bytes32 signature = keccak256("simpleEvent(bytes32)");
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "hello")
            mstore(0x40,add(ptr,0x20))
            log1(ptr, 0x20, signature)
        }
    }

    // --- revert(offset, size) ---
    // - consist of a four byte error selector and the error data.
    // - throws data only from the memory
    // - 1 revert with no message
    // - 2 revert with message
    // - 3 revert with custom error has a encoding of 100 bytes
    //     - 4bytes : error selector
    //     - 32bytes : data offset
    //     - 32bytes : error data length
    //     - 32bytes : error data
    // - refer https://ethereum.stackexchange.com/questions/142752/yul-inline-assembly-revert-with-a-custom-error-message
    function revert_empty() pure public {
        assembly {
            revert(0,0)
        }
    } 
    function revert_message() pure public {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "error message")
            revert(ptr, 13)
        }
    }
    error MyError(string);
    function revert_customError() pure public {
        assembly {
            let ptr := mload(0x40) // Load free memory pointer
            
            // Store custom error signature: keccak256("MyError(string)") = 0x633aa551
            mstore(ptr, 0x633aa55100000000000000000000000000000000000000000000000000000000) 
            
            // Store error message
            mstore(add(ptr, 4), 32) // Data offset
            mstore(add(ptr, 36), 13) // String length
            mstore(add(ptr, 68), 0x48656c6c6f2c2059756c21) // "Hello, Yul!" in hex
            
            revert(ptr, 100) // Revert with 100 bytes of data
        }
    }

    // --- keccak256(offset, size) ---
    // - only reads from memory
    function Keccak256_asm() pure public returns(bytes32 hashval) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "msg")
            hashval := keccak256(ptr, 3)
        }
    }
    // --- shl(shift, data) ---
    // - Left shifts the bits, padding with zeros
    // - its a gas ops trick, behaves like multiplication with 2's without actually doing the multiplication
    function shiftLeft(uint256 value, uint256 shift) public pure returns (uint256 result) {
        assembly {
            result := shl(shift, value)
        }
    }

    // --- shr(shift, data) ---
    // - right shifts the bits, padding with zeros
    // - its a gas ops trick, behaves like multiplication with 2's without actually doing the multiplication
    function shiftRight(uint256 value, uint256 shift) public pure returns (uint256 result) {
        assembly {
            result := shr(shift, value)
        }
    }

    // --- or(a,b) ---
    // - only bitwise operators in yul
    function bitwise_or(uint256 a, uint256 b) public pure returns(uint256 result) {
        assembly {
            result := or(a, b)
        }
    }

    // --- and(a,b) ---
    // - only bitwise operators in yul
    function bitwise_and(uint256 a, uint256 b) public pure returns(uint256 result) {
        assembly {
            result := and(a, b)
        }
    }

    // --- call --- 
    // - in solidity it returns both bool success and bytes data, but here it only the success part (returns 1 if success, else 0)
    // - call(forward all gas, target address, eth value, input pointer, input size, out pointer, output size)
    function call_asm() public {
        Wingman wingman = new Wingman();
        address _wingman = address(wingman);
        assembly {
            let iPtr := mload(0x40)
            mstore(iPtr, "sending a msg")
            let oPtr := add(iPtr, 13)

            let success := call(
                gas(),         // gas : Forward all available gas
                _wingman,      // target : target address to call
                0x00,          // value : ETH to send
                iPtr,          // inputdataPtr : Input data pointer
                13,            // dataSize : Input data size
                oPtr,          // outputdataPtr : Output memory location
                0              // Output size
            )

            if iszero(success) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    // --- delegatecall ---
    // - returns 1 if success, else 0
    // - delegatecall(forward all gas, target address, input pointer, input size, out pointer, output size)
    function delegatecall_asm() public {
        Wingman wingman = new Wingman();
        address _wingman = address(wingman);
        assembly {
            let iPtr := mload(0x40)
            mstore(iPtr, "double the value")
            let oPtr := add(iPtr, 13)

            let success := delegatecall(
                gas(),       // gas : Forward all available gas
                _wingman,    // target : target contract to import logic
                iPtr,        // inputdataPtr : Input data pointer
                16,          // dataSize : Input data size
                oPtr,        // outputdataPtr : Output memory location
                0            // Output size 
            )

            if iszero(success) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
    
    // --- create(value, codeOffset, codeSize) --- 
    // - address computed by keccak256(sender,nonce)
    // - since its not possible to predict nonce, create is non-deterministic
    // - trivia:
    //      - returns address of the new contract or 0 if failed
    function create() public {
        assembly {
            let value := 0 // Ether to send
            let offset := mload(0x40) // Memory offset for the contract code
            let size := 0x20 // Size of the contract code
            let newContractAddr := create(value, offset, size)
        }
    }
    
    // --- create2(value, codeOffset, codeSize, salt) --- 
    // - address computed by keccak256(0xFF,sender,salt,bytecode)
    // - since address is generated out of all the deterministic components, create2 is deterministic
    // - use case: counterfactual deployment, you can predict the contract address before it's deployed.
    // - trivia:
    //      - returns address of the new contract or 0 if failed
    //      - create2 fails if the same salt is reused with the same init code — address collision.
    function create2() public {
        assembly {
            let value := 0 // Ether to send
            let offset := mload(0x40) // Memory offset for the contract code
            let size := 0x20 // Size of the contract code
            let salt := 0 // Define a salt value
            let newContractAddr := create2(value, offset, size, salt)
        }
    }

    // --- for loop ---
    function forLoop() pure public {
        assembly {
            for { let i := 0 } lt(i, 10) { i := add(i, 1) } {
                // loop body 
            }
        }
    }

    // --- if else ---
    function ifElse() pure public {
        assembly {
            let a := 10
            if eq(a, 10) {
                // if body
            } {
                // notice that there is no mention of else in else block
            }
        }
    }
    
    // --- switch ---
    function switchCase() pure public {
        assembly {
            let k := 0
            switch k
            case 0 {
                // Handle case 0
            }
            default {
                // Default case
            }
        }
    }

}

contract Wingman {
    /* slot: 0 */ uint256 internal _counter; 

    function double(uint256 val) public {
        _counter = val*2 ;
    }
    fallback(bytes calldata) external payable returns(bytes memory){
        return "hello";
    }
    receive() external payable {}
}
