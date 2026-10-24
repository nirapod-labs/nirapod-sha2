require import Int.

from Jasmin require import JByte_array.

require import BArray128 BArray512.

clone SubByteArray as SBArray512_128  with theory Asmall <= BArray128,
                                           theory Abig <= BArray512.
