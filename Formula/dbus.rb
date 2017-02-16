class Dbus < Formula
  # releases: even (1.10.x) = stable, odd (1.11.x) = development
  desc "Message bus system, providing inter-application communication"
  homepage "https://wiki.freedesktop.org/www/Software/dbus"
  url "https://dbus.freedesktop.org/releases/dbus/dbus-1.10.16.tar.gz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/d/dbus/dbus_1.10.16.orig.tar.gz"
  sha256 "a7b0ba6ea3e8d0e08afec5e3030d0245614268276620c536726f8fa6e5c43388"

  bottle do
    sha256 "3f9de5a716a7bf2854f60dd2151bf17347d60bb8be71a451a8b7d68c9780b5f7" => :sierra
    sha256 "f5572907ce488208dd6eed55eb46befe09ada2f8a2fab020f9d45be6cb029c4f" => :el_capitan
    sha256 "8868065744f1987b4eaf585b3111bcd6c3ff7eec176f7aa6c21edc91826977e6" => :yosemite
  end

  devel do
    url "https://dbus.freedesktop.org/releases/dbus/dbus-1.11.10.tar.gz"
    mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/d/dbus/dbus_1.11.10.orig.tar.gz"
    sha256 "d3d0b5f88a34b9f29120a2d4d5b2b46d3d9fe7af8b45e12fc4af93ed3f447275"
  end

  head do
    url "https://anongit.freedesktop.org/git/dbus/dbus.git"

    depends_on "autoconf" => :build
    depends_on "autoconf-archive" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "xmlto" => :build

  # Patch applies the config templating fixed in https://bugs.freedesktop.org/show_bug.cgi?id=94494
  # Homebrew pr/issue: 50219
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/0a8a55872e/d-bus/org.freedesktop.dbus-session.plist.osx.diff"
    sha256 "a8aa6fe3f2d8f873ad3f683013491f5362d551bf5d4c3b469f1efbc5459a20dc"
  end

  def install
    # Fix the TMPDIR to one D-Bus doesn't reject due to odd symbols
    ENV["TMPDIR"] = "/tmp"

    ENV["XML_CATALOG_FILES"] = "#{etc}/xml/catalog"

    system "./autogen.sh", "--no-configure" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          "--enable-xml-docs",
                          "--disable-doxygen-docs",
                          "--enable-launchd",
                          "--with-launchd-agent-dir=#{prefix}",
                          "--without-x",
                          "--disable-tests"
    system "make"
    ENV.deparallelize
    system "make", "install"
  end

  def post_install
    # Generate D-Bus's UUID for this machine
    system "#{bin}/dbus-uuidgen", "--ensure=#{var}/lib/dbus/machine-id"
  end

  test do
    system "#{bin}/dbus-daemon", "--version"
  end
end
