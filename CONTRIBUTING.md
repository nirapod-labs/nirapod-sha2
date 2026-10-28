# Contributing

Bug reports, reviews and patches are welcome. Nothing has been released, so
the interface may still change. For anything beyond a small fix, open an
issue first so the approach can be agreed. Security problems go privately,
as [SECURITY.md](SECURITY.md) describes.

## Checking a change

`ci/run.sh` is the CI of record and a change has to pass it. Its header
lists the jobs; `ci/jobs/` has one script per job.

```sh
ci/run.sh                  # the default jobs
ci/run.sh --proofs         # add every EasyCrypt proof (Linux, over an hour)
ci/run.sh --safety         # add jasmin-checksafety on every export (Linux, hours)
ci/run.sh --only build,ct  # just these
```

A job that times out is reported as inconclusive and fails the run, as does
a job that is selected but cannot run. The `tests` job needs
`SHA2_BASELINES`, the install directory `toolchain/baselines/build.sh`
makes, because the differential suites are never skipped. Say in the pull
request which jobs ran, on which architecture and system.

Beyond a passing run:

* A change to `src/` or `proofs/` reruns the proofs of every unit it
  touches, from a clean checkout
  ([docs/PROOFS.md](docs/PROOFS.md#checking)). Nothing may be admitted. A
  new axiom or a changed claimed theorem shows up in the unit's inventory
  (`make -C proofs inventory`), and the pull request says why.
* Code that reads message bytes, keys or context contents belongs in Jasmin,
  where the proofs and the checkers see it. The C layer only checks
  arguments, selects a unit, handles DIT and clears registers.
* Editing a `#[safety]` contract or another annotation can move register
  allocation even when no instruction changes in the source. Compare the
  output of `make asm-all` before and after, and rerun the `extraction` job.
* New files start with the SPDX header used in the tree; a file that cannot
  carry a comment is listed in `REUSE.toml`.

## Sign-off

Contributions are accepted under Apache-2.0, with the [Developer Certificate
of Origin](https://developercertificate.org/) and no CLA. Sign every commit
off with `git commit -s`.
