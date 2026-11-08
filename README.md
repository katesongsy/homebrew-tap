# Homebrew tap

Third-party Homebrew formulae maintained by [katesongsy](https://github.com/katesongsy).
This tap is independent of Homebrew Core.

## Install Dort

```sh
brew install katesongsy/tap/dort
```

Or tap once, then use the short name:

```sh
brew tap katesongsy/tap
brew install dort
```

Dort 0.1.0 remains experimental. Supported binary hosts are macOS 15+ and Ubuntu 24.04+ (glibc 2.39+), on Intel/x86_64 or ARM64. Other Linux distributions and older operating systems are not supported by this formula. Rust is not needed for these prebuilt binaries; local init/attach and Git inspection additionally require installed Git.

The formula downloads the existing [Dort release](https://github.com/katesongsy/dort/releases/tag/v0.1.0), verifies its platform-specific SHA-256, and retains the MIT license, dependency/Rust library notices and build provenance. Checksums are integrity checks, not an independent publisher signature or notarization.

Before using real configuration, read the [getting-started guide](https://github.com/katesongsy/dort/blob/main/docs/user/getting-started.md) and [safety boundaries](https://github.com/katesongsy/dort/blob/main/docs/user/safety.md). Dort does not install package managers, clone/sync repositories or run providers. Writes need reviewed approval; recovery never automatically replays or overwrites later edits.

## Validation and updates

The four-platform CI checks the real Homebrew formula's platform-specific release URL/checksum, installs/tests it in disposable GitHub runners, and requires the installed application to report its version without creating state in a separate child HOME. It does not perform real-home dotfile tasks. This repository owns only Homebrew distribution.

```sh
ruby scripts/test-formula.rb
```

The Ruby check loads only a small formula DSL stub; it does not change Homebrew. Real package-manager installation is tested only in disposable CI, never against workstation installations.

To update the tap, first publish and verify the upstream release, then update the formula's version/URLs/checksums and `tests/release.json` binary receipts together. Preserve all legal notices. CI never publishes new upstream releases, moves tags or updates formulae automatically. The public tap does not imply acceptance into Homebrew Core.
