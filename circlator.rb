class Circlator < Formula
  desc "A tool to circularize genome assemblies"
  homepage "https://github.com/sanger-pathogens/circlator"
  url "https://github.com/sanger-pathogens/circlator/archive/v1.2.0.tar.gz"
  sha256 "46749b9e0dadb51b677e5cd1e3f1a0c1ca6c5139945a6cf4575f3fed818cf95d"
  head "https://github.com/sanger-pathogens/circlator.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d292c6d6bb730ac1574d9ce5bd4eb35cb1a7f785a87e191bb758a832649db1d6" => :el_capitan
    sha256 "61e8c3a5489bd09c7012c2fe325aa557445ef78c1ae27c8a31d2d478b71db209" => :yosemite
    sha256 "7765ab7ce30088c19218285eaf2ad68152a3a4a22c0c059b1ec4c078649e99d3" => :mavericks
  end

  # tag "bioinformatics"

  depends_on "zlib" unless OS.mac?
  depends_on :python3
  depends_on "bwa"
  depends_on "prodigal"
  depends_on "samtools"
  depends_on "spades"
  depends_on "homebrew/python/pymummer"

  resource "pysam" do
    url "https://pypi.python.org/packages/source/p/pysam/pysam-0.8.3.tar.gz"
    sha256 "343e91a1882278455ef9a5f3c9fc4921c37964341785bf22432381d18e6d115e"
  end

  resource "pyfastaq" do
    url "https://pypi.python.org/packages/source/p/pyfastaq/pyfastaq-3.10.0.tar.gz"
    sha256 "a09604f5143abf27280abbdfcdb85878f760380876a971139b9536955f1cb73c"
  end

  resource "bio_assembly_refinement" do
    url "https://pypi.python.org/packages/source/b/bio_assembly_refinement/bio_assembly_refinement-0.5.0.tar.gz"
    sha256 "8d5e8d6c5ad23602015f8099842b607928e46c1393c9acb3beddba8d0351f263"
  end

  def install
    version = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", HOMEBREW_PREFIX/"lib/python#{version}/site-packages"

    %w[pysam pyfastaq bio_assembly_refinement].each do |r|
      resource(r).stage do
        system "python3", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    system "python3", *Language::Python.setup_install_args(libexec)
    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    assert_match "Available commands", shell_output("#{bin}/circlator 2>&1", 0)
    assert_match "1.2.0", shell_output("#{bin}/circlator version 2>&1", 0)
  end
end
