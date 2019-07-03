require 'formula'

class Burstcoind < Formula
  desc "Burstcoin Wallet"
  homepage "https://burst-coin.org"
  url "https://github.com/burst-apps-team/burstcoin/archive/v2.4.0.zip"
  sha256 "ae9de7e8972577284ed824ee9208391d4b43da3f1c337c189339c23211d68eb9"

  bottle :unneeded

  depends_on :java => "1.8"
  depends_on "maven" => :build

  def install
    system "mvn", "clean", "package", "-DskipTests"
    bin.install Dir["dist/tmp/burst.jar"]
    bin.install Dir["dist/tmp/html"]
    bin.install Dir["dist/tmp/conf"]
    bin.install Dir["dist/tmp/lib"]
    bin.install Dir["dist/tmp/burst.sh"]
    (bin/"burstcoind").write <<~EOS
                  #!/bin/bash
                  export JAVA_HOME=$(#{Language::Java.java_home_cmd("1.8")})
                  cd #{prefix}/bin
                  java -cp #{prefix}/bin/burst.jar:conf brs.Burst "$@"
    EOS
    chmod 0555, bin/"burstcoind"
    inreplace "#{prefix}/bin/conf/brs-default.properties", "DB.Url=jdbc:mariadb://localhost:3306/burstwallet", "DB.Url=jdbc:h2:./burst_db/burst;DB_CLOSE_ON_EXIT=False"
    inreplace "#{prefix}/bin/conf/brs-default.properties", "DB.Username=", "DB.Username=sa"
    inreplace "#{prefix}/bin/conf/brs-default.properties", "DB.Password=", "DB.Password=sa"
  end
  test do
    system "#{prefix}bin/burst.sh" "--help"
  end
end
