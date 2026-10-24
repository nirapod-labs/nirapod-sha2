require import Int.

from Jasmin require import JByte_array.

require import BArray64 BArray208.

clone SubByteArray as SBArray208_64  with theory Asmall <= BArray64,
                                          theory Abig <= BArray208.
