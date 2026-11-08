#!/usr/bin/env ruby
# Mount-free metadata/compatibility checks. Real Homebrew installs run only in disposable CI.
require "json"

ROOT = File.expand_path("..", __dir__)
RELEASE = JSON.parse(File.read(File.join(ROOT, "tests", "release.json")))

module OS
  class << self
    attr_accessor :platform

    def linux?
      platform == :linux
    end
  end
end

module Hardware
  module CPU
    class << self
      attr_accessor :architecture
    end
  end
end

# Evaluate only the formula's platform DSL, without loading or changing Homebrew.
class Formula
  class << self
    attr_accessor :metadata

    def inherited(child)
      child.metadata = {}
    end

    [:desc, :homepage, :version, :license, :url, :sha256].each do |field|
      define_method(field) { |value| metadata[field] = value }
    end

    def depends_on(value)
      metadata[:dependencies] = value
    end

    def on_macos
      yield if OS.platform == :macos
    end

    def on_linux
      yield if OS.platform == :linux
    end

    def on_arm
      yield if Hardware::CPU.architecture == :arm
    end

    def on_intel
      yield if Hardware::CPU.architecture == :intel
    end

    def test
      # No application execution in the mount-free DSL check.
    end
  end
end

def check(condition, message)
  raise message unless condition
end

platforms = {
  [:macos, :arm] => "aarch64-apple-darwin",
  [:macos, :intel] => "x86_64-apple-darwin",
  [:linux, :arm] => "aarch64-unknown-linux-gnu",
  [:linux, :intel] => "x86_64-unknown-linux-gnu",
}
platforms.each do |(os, architecture), target|
  Object.send(:remove_const, :Dort) if Object.const_defined?(:Dort)
  OS.platform = os
  Hardware::CPU.architecture = architecture
  load File.join(ROOT, "Formula", "dort.rb")
  expected = RELEASE.fetch("targets").fetch(target)
  check(Dort.metadata.fetch(:url) == expected.fetch("url"), "wrong URL for #{target}")
  check(Dort.metadata.fetch(:sha256) == expected.fetch("archive_sha256"), "wrong checksum for #{target}")
  check(Dort.metadata.fetch(:version) == RELEASE.fetch("version"), "wrong version")
  check(Dort.metadata.fetch(:license) == "MIT", "wrong license")
  check(Dort.metadata[:dependencies] == { macos: :sequoia }, "wrong macOS floor") if os == :macos
  puts "PASS formula metadata: #{target}"
end

{
  "ID=ubuntu\nVERSION_ID=\"24.04\"\n" => true,
  "ID='ubuntu'\nVERSION_ID=24.10\n" => true,
  "ID=ubuntu\nVERSION_ID=26.04\n" => true,
  "ID=ubuntu\nVERSION_ID=22.04\n" => false,
  "ID=ubuntu\nVERSION_ID=24.03\n" => false,
  "ID=debian\nVERSION_ID=13.0\n" => false,
  "ID=fedora\nVERSION_ID=42.0\n" => false,
  "VERSION_ID=24.04\n" => false,
  "ID=ubuntu\nVERSION_ID=invalid\n" => false,
  "" => false,
}.each do |release, supported|
  check(Dort.supported_ubuntu?(release) == supported, "Ubuntu compatibility guard mismatch")
end
puts "PASS Ubuntu compatibility refusal cases"
