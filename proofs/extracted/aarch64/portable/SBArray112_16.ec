require import Int.

from Jasmin require import JByte_array.

require import BArray16 BArray112.

clone SubByteArray as SBArray112_16  with theory Asmall <= BArray16,
                                          theory Abig <= BArray112.
