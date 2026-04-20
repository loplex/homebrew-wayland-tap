class Wayland < Formula
  desc "Core Wayland window system code and protocol"
  homepage "https://wayland.freedesktop.org"
  license "MIT"
  url "https://gitlab.freedesktop.org/lopin/wayland.git", using: :git, branch: "macos", revision: '5bf30a3e7e1dd3f77485a57a16b896c0dcffa13e'
  version "1.24.91-lopin1"
  #head "https://gitlab.freedesktop.org/lopin/wayland.git"

  depends_on "meson" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "doxygen" => :build
  depends_on "docbook" => :build
  depends_on "xmlto" => :build
  depends_on "graphviz" => :build
  depends_on "mdbook" => :build

  depends_on "epoll-shim"

  def install
    meson_options = [ "xml_catalog=#{etc}/xml/catalog" ]

    system "meson", "setup", "build", *std_meson_args, *( meson_options.map { |o| '-D'+o } )
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "test", "-C", "build", "--verbose" 
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~C
      #include "wayland-server.h"
      #include "wayland-client.h"

      int main(int argc, char* argv[]) {
        const char *socket;
        struct wl_protocol_logger *logger;
        return 0;
      }
    C
    system ENV.cc, "test.c", "-o", "test", "-I#{include}"
    system "./test"
  end
end
