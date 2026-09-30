require import Int.

from Jasmin require import JByte_array.

require import BArray16 BArray272.

clone SubByteArray as SBArray272_16  with theory Asmall <= BArray16,
                                          theory Abig <= BArray272.
