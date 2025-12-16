class WaylandXquartz < Formula
  desc "Protocol for a compositor to talk to its clients - XQuartz darwin-portability fork"
  homepage "https://wayland.freedesktop.org"
  license "MIT"
  url "https://github.com/XQuartz/wayland.git", using: :git, branch: "darwin-portability", revision: '04654ba7b57ccbf583db899a327f8f7000f90546'
  version "1.21.0-darwin"
  #head "https://github.com/XQuartz/wayland.git"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  
  depends_on "epoll-shim"

  patch do
    url "https://raw.githubusercontent.com/macports/macports-ports/refs/heads/master/devel/wayland/files/0001-Darwin-fixes-from-owl-compositor.patch"
    sha256 "68abe2366a1e96c41758809e21c29e365e1c118c94a22cf0fbeb3639956fa9b7"
  end
  patch do
    url "https://raw.githubusercontent.com/macports/macports-ports/refs/heads/master/devel/wayland/files/0002-wayland-os.c-LOCAL_PEERPID-may-not-be-defined.patch"
    sha256 "4149219172a7323bd96b1fbae4bd2fc31c0932da4c9db50b7d6710f32a3ab8b5"
  end
  patch do
    url "https://raw.githubusercontent.com/macports/macports-ports/refs/heads/master/devel/wayland/files/0003-os-wrappers-test-F_DUPFD_CLOEXEC-may-not-be-defined.patch"
    sha256 "47da54f913dfcf6e412401e6024cc77758d2535885d1b85d62255adce7ea3aa9"
  end

  patch :DATA
  
  
  def install
    meson_options = [ 'libraries=true', 'scanner=true', 'tests=false', 'documentation=false', 'dtd_validation=false' ]

    system "meson", "setup", "build", *std_meson_args, *( meson_options.map { |o| '-D'+o } )
    system "meson", "compile", "-C", "build", "--verbose"
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

__END__


diff --git a/egl/meson.build b/egl/meson.build
index b3cbdf3..55d979b 100644
--- a/egl/meson.build
+++ b/egl/meson.build
@@ -47,6 +47,11 @@ wayland_egl_dep = declare_dependency(
 	include_directories: [ root_inc, include_directories('.') ],
 )
 
+wayland_egl_backend_dep = declare_dependency(
+	include_directories: [ root_inc, include_directories('.') ],
+)
+
 if meson.version().version_compare('>= 0.54.0')
 	meson.override_dependency('wayland-egl', wayland_egl_dep)
+	meson.override_dependency('wayland-egl-backend', wayland_egl_backend_dep)
 endif
diff --git a/meson.build b/meson.build
index 9e0a6c9..426b7c4 100644
--- a/meson.build
+++ b/meson.build
@@ -7,6 +7,11 @@ project(
 		'warning_level=2',
 		'buildtype=debugoptimized',
 		'c_std=c99',
+		'libraries=true',
+		'scanner=true',
+		'tests=false',
+		'documentation=false',
+		'dtd_validation=false'
 	]
 )
 wayland_version = meson.project_version().split('.')
diff --git a/src/meson.build b/src/meson.build
index 42450ef..3a81063 100644
--- a/src/meson.build
+++ b/src/meson.build
@@ -79,6 +79,15 @@ if get_option('scanner')
 
 	if meson.can_run_host_binaries()
 		meson.override_find_program('wayland-scanner', wayland_scanner)
+
+		dep_scanner = declare_dependency(
+			variables: {
+				'wayland_scanner': wayland_scanner.full_path(),
+			},
+		)
+		if meson.version().version_compare('>= 0.54.0')
+			meson.override_dependency('wayland-scanner', dep_scanner)
+		endif
 	endif
 endif
 
