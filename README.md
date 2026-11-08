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

## Mise alternative

The same release is available through mise's GitHub backend; no third-party plugin or registry alias is required:

```sh
mise use --global github:katesongsy/dort@0.1.0
mise exec github:katesongsy/dort@0.1.0 -- dort --version
```

The same supported-host requirements apply. Configure mise's PATH/shims as described in its [documentation](https://mise.jdx.dev/getting-started.html).

## Validation and updates

The four-platform CI installs/tests the real Homebrew formula in disposable GitHub runners and tests direct GitHub-backed mise installation with a private canonical HOME/config/cache/data/state. The installed binary must match the verified release binary and report its version without creating application state. It does not perform real-home dotfile tasks.

```sh
ruby scripts/test-formula.rb
python3 scripts/test-mise.py --mise /absolute/path/to/mise
```

The Ruby check loads only a small formula DSL stub; it does not change Homebrew. The mise check needs reviewed mise 2026.11.4 and downloads only the public Dort release into disposable storage. No workstation package-manager install is part of these checks.

To update the tap, first publish and verify the upstream release, then update the formula's version/URLs/checksums and `tests/release.json` binary receipts together. Preserve all legal notices. CI never publishes new upstream releases, moves tags or updates formulae automatically. The public tap and mise backend do not imply acceptance into Homebrew Core or mise's short-name registry.
