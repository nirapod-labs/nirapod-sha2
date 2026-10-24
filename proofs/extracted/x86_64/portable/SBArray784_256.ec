require import Int.

from Jasmin require import JByte_array.

require import BArray256 BArray784.

clone SubByteArray as SBArray784_256  with theory Asmall <= BArray256,
                                           theory Abig <= BArray784.
