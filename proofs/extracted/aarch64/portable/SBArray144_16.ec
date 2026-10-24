require import Int.

from Jasmin require import JByte_array.

require import BArray16 BArray144.

clone SubByteArray as SBArray144_16  with theory Asmall <= BArray16,
                                          theory Abig <= BArray144.
