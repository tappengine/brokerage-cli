# Homebrew formula skeleton for the Buildmarkets CLI.
#
#   brew install buildmarkets/tap/bm
#
# The release workflow updates `version`, the URLs, and the sha256 sums on each
# tagged release (e.g. via brew bump-formula-pr).
class Bm < Formula
  desc "Buildmarkets developer CLI for the brokerage API"
  homepage "https://github.com/tappengine/brokerage-cli"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/tappengine/brokerage-cli/releases/download/v#{version}/bm_darwin_arm64"
      sha256 "REPLACE_WITH_DARWIN_ARM64_SHA256"
    end
    on_intel do
      url "https://github.com/tappengine/brokerage-cli/releases/download/v#{version}/bm_darwin_amd64"
      sha256 "REPLACE_WITH_DARWIN_AMD64_SHA256"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/tappengine/brokerage-cli/releases/download/v#{version}/bm_linux_arm64"
      sha256 "REPLACE_WITH_LINUX_ARM64_SHA256"
    end
    on_intel do
      url "https://github.com/tappengine/brokerage-cli/releases/download/v#{version}/bm_linux_amd64"
      sha256 "REPLACE_WITH_LINUX_AMD64_SHA256"
    end
  end

  def install
    # The release asset is the bare binary; install it as both `bm` and the
    # long-form alias `buildmarkets`.
    bin.install Dir["*"].first => "bm"
    bin.install_symlink bin/"bm" => "buildmarkets"
  end

  test do
    assert_match "bm #{version}", shell_output("#{bin}/bm --version")
  end
end
