require import Int.

from Jasmin require import JByte_array.

require import BArray16 BArray784.

clone SubByteArray as SBArray784_16  with theory Asmall <= BArray16,
                                          theory Abig <= BArray784.
