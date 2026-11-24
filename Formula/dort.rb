require "json"
require "open3"

class Dort < Formula
  desc "Experimental, TUI-first local dotfile manager with guarded recovery"
  homepage "https://github.com/katesongsy/dort"
  version "0.2.0"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/katesongsy/dort/releases/download/v0.2.0/dort-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "c5b71004d321cca6045195ca1b8aa41953c904523bd5fe2e1c8804834f3f445f"
    end
    on_intel do
      url "https://github.com/katesongsy/dort/releases/download/v0.2.0/dort-v0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "3e3504cd018d6fd4311735d6023d8c595b410e8ae39c1449b36e8bf2e650e331"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/katesongsy/dort/releases/download/v0.2.0/dort-v0.2.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "caa13f7725563ccedb4db2f4bb0808aa3d67680009582bb9395633ddbe3b0201"
    end
    on_intel do
      url "https://github.com/katesongsy/dort/releases/download/v0.2.0/dort-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "8268e01ca560f2904ccd908ca0651646885cfd9a34056f6de31e56253ec9b7ac"
    end
  end

  # These upstream binaries support Ubuntu, not arbitrary Linux distributions.
  def self.supported_ubuntu?(release)
    fields = release.each_line.filter_map do |line|
      match = /\A(ID|VERSION_ID)=(?:"([^"]*)"|'([^']*)'|([^\s]+))\s*\z/.match(line)
      [match[1], match[2] || match[3] || match[4]] if match
    end.to_h
    version = /\A(\d+)\.(\d+)\z/.match(fields.fetch("VERSION_ID", ""))
    return false if fields["ID"] != "ubuntu"
    return false unless version

    major, minor = version.captures.map(&:to_i)
    major > 24 || (major == 24 && minor >= 4)
  end

  def install
    if OS.linux?
      release = Pathname.new("/etc/os-release")
      supported = release.file? && self.class.supported_ubuntu?(release.read)
      odie "Dort's prebuilt Linux binaries require Ubuntu 24.04 or newer (glibc 2.39+)." unless supported
    end

    bin.install "dort"
    doc.install "LICENSE", "THIRD-PARTY-NOTICES.txt", "RUST-COPYRIGHT.html"
    pkgshare.install "BUILD-INFO.json"
  end

  test do
    home = testpath/"isolated-home"
    home.mkpath
    environment = {
      "HOME"            => home.to_s,
      "XDG_CONFIG_HOME" => (home/"config").to_s,
      "XDG_STATE_HOME"  => (home/"state").to_s,
    }
    output, error, status = Open3.capture3(environment, (bin/"dort").to_s, "--version", chdir: home.to_s)
    assert_predicate status, :success?
    assert_equal "dort #{version}\n", output
    assert_empty error
    assert_empty home.children
    assert_equal version.to_s, JSON.parse((pkgshare/"BUILD-INFO.json").read).fetch("version")
    assert_path_exists doc/"LICENSE"
    assert_path_exists doc/"THIRD-PARTY-NOTICES.txt"
    assert_path_exists doc/"RUST-COPYRIGHT.html"
  end
end
