require import Int.

from Jasmin require import JByte_array.

require import BArray64 BArray112.

clone SubByteArray as SBArray112_64  with theory Asmall <= BArray64,
                                          theory Abig <= BArray112.
