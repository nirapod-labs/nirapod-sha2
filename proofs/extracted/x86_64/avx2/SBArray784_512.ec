require import Int.

from Jasmin require import JByte_array.

require import BArray512 BArray784.

clone SubByteArray as SBArray784_512  with theory Asmall <= BArray512,
                                           theory Abig <= BArray784.
