require 'formula'

class Cufflinks < Formula
  homepage 'http://cufflinks.cbcb.umd.edu/'
  url 'http://cufflinks.cbcb.umd.edu/downloads/cufflinks-2.2.0.tar.gz'
  sha1 '9745a6cc0515d2d1d7ed22b2ced3bda9243f2b17'

  depends_on 'boost'    => :build
  depends_on 'samtools' => :build
  depends_on 'eigen'    => :build

  def install
    ENV['EIGEN_CPPFLAGS'] = "-I#{Formula["eigen"].include}/eigen3"
    ENV.append 'LIBS', '-lboost_system-mt -lboost_thread-mt'
    cd 'src' do
      # Fixes 120 files redefining `foreach` that break building with boost
      # See http://seqanswers.com/forums/showthread.php?t=16637
      `for x in *.cpp *.h; do sed 's/foreach/for_each/' $x > x; mv x $x; done`
      inreplace 'common.h', 'for_each.hpp', 'foreach.hpp'
    end
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system 'make'
    ENV.j1
    system 'make install'
  end

  test do
    system "#{bin}/cuffdiff 2>&1 |grep -q cuffdiff"
  end
end
