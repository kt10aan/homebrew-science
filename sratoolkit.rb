class Sratoolkit < Formula
  homepage "https://github.com/ncbi/sra-tools"
  # doi "10.1093/nar/gkq1019"
  # tag "bioinformatics"

  url "https://github.com/ncbi/sra-tools/archive/2.5.0.tar.gz"
  sha256 "4aca37fcb022c67bbf7acd8c78386a2f46f68817d369144fc24ac1a22ddb94df"
  head "https://github.com/ncbi/sra-tools.git"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-science"
    cellar :any
    sha256 "964d931b8e9c57bb32622d5627f914c8e0e9f54bec52e95a2429e264668cf80e" => :yosemite
    sha256 "d67ebf5724b97eb1862a2fc5b6d2a872d2af80bbc52bf465eb69e975113c02b6" => :mavericks
    sha256 "03a4a2de29671c99a87d738642aecedfb35fab035a238dc87bb966207c3473d5" => :mountain_lion
  end

  resource "ngs-sdk" do
    url "https://github.com/ncbi/ngs/archive/1.1.1.tar.gz"
    sha256 "1eedd2aa2363b2320559762fa0223a98f9b766ac0f252566edc09253ea7da8f4"
  end

  resource "ncbi-vdb" do
    url "https://github.com/ncbi/ncbi-vdb/archive/2.5.0.tar.gz"
    sha256 "f3ab2f05471e160bee19b59e641e2004df406bc9a30f335d6efe532b32e9901e"
  end

  depends_on "autoconf" => :build
  depends_on "libxml2"
  depends_on "libmagic" => :recommended
  depends_on "hdf5" => :recommended

  def install
    ENV.deparallelize
    resource("ngs-sdk").stage do
      cd "ngs-sdk" do
        system "./configure", "--prefix=#{prefix}", "--build=#{prefix}"
        system "make"
        system "make", "test"
        system "make", "install"
      end
    end

    resource("ncbi-vdb").stage do
      system "./configure", "--with-ngs-sdk-prefix=#{prefix}", "--prefix=#{prefix}", "--build=#{prefix}"
      system "make"
      system "make", "install"
      (include/"ncbi-vdb").install Dir["*"]
    end

    inreplace "tools/copycat/Makefile", "-smagic-static", "-smagic"

    # Fix the error: undefined reference to `SZ_encoder_enabled'
    inreplace "tools/pacbio-load/Makefile", "-shdf5 ", "-shdf5 -ssz "

    system "./configure", "--prefix=#{prefix}", "--with-ngs-sdk-prefix=#{prefix}", "--with-ncbi-vdb-sources=#{include}/ncbi-vdb", "--with-ncbi-vdb-build=#{prefix}", "--prefix=#{prefix}", "--build=#{prefix}"
    system "make"
    system "make", "install"
    rm_rf "#{bin}/ncbi"
    rm_rf "#{prefix}/sra-tools"
    rm_rf "#{prefix}/ngs-sdk"
    rm_rf "#{prefix}/ncbi-vdb"
    rm_rf "#{lib}64"
    rm_rf "#{include}"
  end

  test do
    system bin/"fastq-dump", "SRR000001"
    assert File.read("SRR000001.fastq").include?("@SRR000001.1 EM7LVYS02FOYNU length=284")
  end
end
