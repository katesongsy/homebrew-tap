require "json"
require "open3"

class Dort < Formula
  desc "Experimental, TUI-first local dotfile manager with guarded recovery"
  homepage "https://github.com/katesongsy/dort"
  version "0.1.0"
  license "MIT"

  on_macos do
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/katesongsy/dort/releases/download/v0.1.0/dort-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "aaa271c5b864b76a6fed2b6169ed43649313615d8de0a20497ffbbe02c028ab5"
    end
    on_intel do
      url "https://github.com/katesongsy/dort/releases/download/v0.1.0/dort-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "b0dd05a3e2fdaad00436fd45d26c07333e748c38dd0a6478b027859bf645499e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/katesongsy/dort/releases/download/v0.1.0/dort-v0.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c22ffeeeede8ccf9697d7ed5cfa6ad3091a65d9ecc02e650124621ffea04d226"
    end
    on_intel do
      url "https://github.com/katesongsy/dort/releases/download/v0.1.0/dort-v0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "4679bec0653ce963c762a95063bd2badcead12a99fb8d0352653a85c508388c6"
    end
  end

  # These upstream binaries support Ubuntu, not arbitrary Linux distributions.
  def self.supported_ubuntu?(release)
    fields = release.each_line.filter_map do |line|
      match = /\A(ID|VERSION_ID)=(?:"([^"]*)"|'([^']*)'|([^\s]+))\s*\z/.match(line)
      [match[1], match[2] || match[3] || match[4]] if match
    end.to_h
    version = /\A(\d+)\.(\d+)\z/.match(fields.fetch("VERSION_ID", ""))
    return false unless fields["ID"] == "ubuntu" && version

    major, minor = version.captures.map(&:to_i)
    major > 24 || (major == 24 && minor >= 4)
  end

  def install
    if OS.linux?
      release = Pathname.new("/etc/os-release")
      unless release.file? && self.class.supported_ubuntu?(release.read)
        odie "Dort's prebuilt Linux binaries require Ubuntu 24.04 or newer (glibc 2.39+)."
      end
    end

    bin.install "dort"
    doc.install "LICENSE", "THIRD-PARTY-NOTICES.txt", "RUST-COPYRIGHT.html"
    pkgshare.install "BUILD-INFO.json"
  end

  test do
    home = testpath/"isolated-home"
    home.mkpath
    environment = {
      "HOME" => home.to_s,
      "XDG_CONFIG_HOME" => (home/"config").to_s,
      "XDG_STATE_HOME" => (home/"state").to_s,
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
