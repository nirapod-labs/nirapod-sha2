require import Int.

from Jasmin require import JByte_array.

require import BArray64 BArray512.

clone SubByteArray as SBArray512_64  with theory Asmall <= BArray64,
                                          theory Abig <= BArray512.
