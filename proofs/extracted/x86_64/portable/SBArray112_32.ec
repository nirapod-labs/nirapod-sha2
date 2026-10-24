require import Int.

from Jasmin require import JByte_array.

require import BArray32 BArray112.

clone SubByteArray as SBArray112_32  with theory Asmall <= BArray32,
                                          theory Abig <= BArray112.
