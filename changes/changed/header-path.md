- The public header moved from `include/nirapod_sha2.h` to
  `include/nirapod/sha2.h`, so a program includes `<nirapod/sha2.h>` with
  `include/` on its search path. Only the path changed: the functions,
  types and macros keep their `nirapod_sha2_` and `NIRAPOD_SHA2_` names.
