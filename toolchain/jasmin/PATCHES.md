# Jasmin patch series

The pinned compiler is upstream Jasmin at the commit in `PIN` with the
patches listed in `SERIES` applied in that order. `toolchain/build.sh jasmin`
applies them with `git am` to a clean checkout of the pin and builds the
result as upstream does: Rocq proofs, extraction of the compiler, OCaml
build.

A patch is either a commit of an upstream pull request, carried unchanged
until the pin includes it, or a patch of this project, written to be proposed
upstream. A carried commit keeps its author, date and message.

Upstream Jasmin is distributed under the MIT licence, reproduced in
`jasmin-license.txt` next to this file from the pinned commit. The patches
modify Jasmin and are distributed under the same terms.

## Series

Pin: `288a569b6ed2bb50078b1882739fda6aa7873ec6` (jasmin-lang/jasmin, main,
2026-09-10). `SERIES` lists no patch yet. The ARMv8-A instructions, the
safety-checker changes and the Advanced SIMD support the kernels need are
being prepared as upstream pull requests; each is added here, with the
reason it is carried and its proof status, once it is proposed.
