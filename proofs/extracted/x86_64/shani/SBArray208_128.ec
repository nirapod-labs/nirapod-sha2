require import Int.

from Jasmin require import JByte_array.

require import BArray128 BArray208.

clone SubByteArray as SBArray208_128  with theory Asmall <= BArray128,
                                           theory Abig <= BArray208.
