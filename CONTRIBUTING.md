# Contributing

Bug reports, review comments and patches are welcome. Nothing has been
released yet, so the interface in `include/nirapod/sha2.h` may still
change.

## Before you start

- Open an issue first for anything bigger than a small fix, so the
  approach can be agreed before you spend time on it.
- Report security problems privately, as `SECURITY.md` describes.

## Checking a change

`ci/run.sh` runs every check the project has, and a change has to pass it.
`ci/README.md` lists the jobs and what each one establishes. Which jobs run
by default depends on the host:

```sh
ci/run.sh             # toolchain, build, tests, exports, ct, extraction
ci/run.sh --proofs    # add the EasyCrypt proofs (Linux, takes hours)
ci/run.sh --safety    # add the memory-safety checker (Linux, takes hours)
```

The `tests` job compares against independent implementations, so it needs
`SHA2_BASELINES` pointing at the install directory that
`toolchain/baselines/build.sh` makes. `toolchain/build.sh` builds the
pinned Jasmin and EasyCrypt. In the pull request, say which jobs you ran
and on which architecture and operating system.

Some changes need more than a passing run:

- A change to `src/` or to anything under `proofs/` reruns the proofs of
  every unit it touches (`proofs/README.md`, "Running"). A proof may not
  admit a lemma. If a change adds an axiom or changes a claimed theorem,
  the unit's inventory changes with it (`make -C proofs inventory`), and
  the pull request says why.
- The C layer only checks arguments, picks a kernel, sets the timing mode
  and clears registers. Code that reads message bytes, keys or the contents
  of a context goes in Jasmin, where the proofs and the checkers see it.
- New files start with the SPDX header used throughout the repository.
  A file that can't carry a comment gets an entry in `REUSE.toml`.

## Changelog

A change users can notice (to the library, its interface, the proofs or
the toolchain) adds an entry under `changes/` in the same pull request,
as `changes/README.md` describes. It doesn't edit `CHANGELOG.md`.

## Sign-off

Contributions are accepted under the Apache License 2.0. The project uses
the [Developer Certificate of Origin](https://developercertificate.org/)
and no CLA. Add a `Signed-off-by` line to every commit with `git commit -s`
to certify that you wrote the change or otherwise have the right to submit
it.
