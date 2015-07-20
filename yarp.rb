class Yarp < Formula
  desc "Yet Another Robot Platform"
  homepage "http://yarp.it"
  url "https://github.com/robotology/yarp/archive/v2.3.64.tar.gz"
  sha256 "3882b38c39ec9c5fdd06c68f3a4ad21da718bd2733ed7d6a5fb78d9f36dad6b2"
  head "https://github.com/robotology/yarp.git"

  option "with-qt5", "Build the Qt5 GUI applications"
  option "with-yarprun-log", "Build with yarprun_log support"
  option "with-opencv", "Build the opencv_grabber device"
  option "with-lua", "Build with Lua bindings"
  option "with-python", "Build with Python bindings"
  option "with-serial", "Build the serial/serialport devices"

  depends_on "pkg-config" => :build
  depends_on "cmake" => :build
  depends_on "ace"
  depends_on "gsl"
  depends_on "sqlite"
  depends_on "readline"
  depends_on "jpeg"
  depends_on "homebrew/science/opencv" => :optional
  depends_on "qt5" => :optional
  depends_on "lua" => :optional
  depends_on "python" => :optional

  if build.with?("lua") || build.with?("python")
    depends_on "swig"
  end

  def install
    args = std_cmake_args + %W[
      -DCREATE_LIB_MATH=TRUE
      -DCREATE_DEVICE_LIBRARY_MODULES=TRUE
      -DCREATE_OPTIONAL_CARRIERS=TRUE
      -DENABLE_yarpcar_mjpeg_carrier=TRUE
      -DENABLE_yarpcar_rossrv_carrier=TRUE
      -DENABLE_yarpcar_tcpros_carrier=TRUE
      -DENABLE_yarpcar_xmlrpc_carrier=TRUE
      -DENABLE_yarpcar_bayer_carrier=TRUE
      -DENABLE_yarpcar_priority_carrier=TRUE
      -DCREATE_IDLS=TRUE
    ]

    args << "-DCREATE_GUIS=TRUE" if build.with? "qt5"
    args << "-DENABLE_YARPRUN_LOG=ON" if build.with? "yarprun-log"
    args << "-DENABLE_yarpmod_opencv_grabber=ON" if build.with? "opencv"

    if build.with? "lua"
      args << "-DYARP_COMPILE_BINDINGS=ON"
      args << "-DCREATE_LUA=ON"
    end

    if build.with? "python"
      args << "-DYARP_COMPILE_BINDINGS=ON"
      args << "-DCREATE_PYTHON=ON"
    end

    if build.with? "serial"
      args << "-DENABLE_yarpmod_serial=ON"
      args << "-DENABLE_yarpmod_serialport=ON"
    end

    system "cmake", *args
    system "make", "install"
    bash_completion.install "scripts/yarp_completion"
  end

  def caveats; <<-EOS.undent
    You need to add in your ~/.bash_profile or similar:

      export YARP_DATA_DIRS=#{HOMEBREW_PREFIX}/share/yarp
    EOS
  end

  test do
    system "#{bin}/yarp", "check"
  end
end
