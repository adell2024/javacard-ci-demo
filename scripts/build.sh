#!/bin/bash
set -e

echo "🛠️ Compilation Java..."
#javac -source 1.3 -target 1.3 -bootclasspath $JC_HOME/lib/api.jar -d build/classes src/main/java/fr/insa/*.java
#javac -source 1.6 -target 1.6 -bootclasspath $JC_HOME/lib/api.jar -d build/classes src/main/java/fr/insa/*.java
#javac -source 1.3 -target 1.3 -cp $JC_HOME/lib/api.jar -d build/classes src/main/java/fr/insa/*.java
java -jar lib/ecj.jar -1.3 -cp $JC_HOME/lib/api.jar -d build/classes src/main/java/fr/insa/*.java

echo "📦 Conversion CAP..."
# Package AID : 0x01:0x02:0x03:0x04:0x05:0x06:0x07:0x08:0x09:0x00 (10 octets)
# Applet AID : 0x01:0x02:0x03:0x04:0x05:0x06:0x07:0x08:0x09:0x00:0x00 (11 octets)
converter -classdir build/classes \
          -exportpath $JC_HOME/api_export_files \
          -applet 0x01:0x02:0x03:0x04:0x05:0x06:0x07:0x08:0x09:0x00:0x00 fr.insa.HelloWorldApplet \
          -d build/cap \
          -out CAP \
          fr.insa 0x01:0x02:0x03:0x04:0x05:0x06:0x07:0x08:0x09:0x00 1.0

echo "✅ CAP généré dans build/cap/"
ls -l build/cap/fr/insa/javacard/*.cap
