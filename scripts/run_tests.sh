#!/bin/bash
set -e

echo "🚀 Génération du script de chargement (cap-download)..."
scriptgen -o /tmp/load_raw.scr build/cap/fr/insa/javacard/insa.cap

echo "powerup;" > /tmp/load.scr
grep -v "^$" /tmp/load_raw.scr | grep -v "^//" >> /tmp/load.scr
echo "powerdown;" >> /tmp/load.scr

echo "🚀 Arrêt de toute instance CREF existante..."
pkill -f cref || true
sleep 2

echo "🚀 Phase 1 - Chargement du code sur CREF..."
cref -o hello.eeprom > /tmp/cref_load.log 2>&1 &
CREF_PID=$!
sleep 3

echo "🔬 Exécution de l'upload (cap-download)..."
apdutool /tmp/load.scr > /tmp/load.out 2>&1
if grep -q "SW1: 90, SW2: 00" /tmp/load.out; then
    echo "✅ Chargement du code réussi"
else
    echo "❌ Échec du chargement du code. Détails :"
    cat /tmp/load.out
    kill $CREF_PID 2>/dev/null || true
    exit 1
fi

kill $CREF_PID 2>/dev/null || true
sleep 2

# Phase 1.5 : Installation de l'instance
echo "🚀 Phase 1.5 - Installation de l'instance..."
cref -i hello.eeprom -o hello.eeprom > /tmp/cref_install.log 2>&1 &
CREF_PID=$!
sleep 3

# Commande INSTALL pour créer une instance avec l'AID de l'applet
# L'installateur est sélectionné (AID: A00000006203010801)
# Puis INSTALL (0x80 0xB8) avec les paramètres : Package AID + Applet AID
# Ici, on suppose que l'AID du package est 01:02:03:04:05:06:07:08:09:00 (10 octets)
# et l'AID de l'instance est 01:02:03:04:05:06:07:08:09:00:00 (11 octets)
echo "powerup;" > /tmp/install.scr
echo "0x00 0xA4 0x04 0x00 0x09 0xA0 0x00 0x00 0x00 0x62 0x03 0x01 0x08 0x01 0x7F;" >> /tmp/install.scr  # SELECT installateur
echo "0x80 0xB8 0x00 0x00 0x0D 0x0B 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x00 0x00 0x00 0x7F;" >> /tmp/install.scr  # INSTALL
echo "powerdown;" >> /tmp/install.scr

apdutool /tmp/install.scr > /tmp/install.out 2>&1
if grep -q "SW1: 90, SW2: 00" /tmp/install.out; then
    echo "✅ Installation de l'instance réussie"
else
    echo "❌ Échec de l'installation. Détails :"
    cat /tmp/install.out
    kill $CREF_PID 2>/dev/null || true
    exit 1
fi

kill $CREF_PID 2>/dev/null || true
sleep 2

echo "🚀 Phase 2 - Tests avec EEPROM restaurée..."
cref -i hello.eeprom -o hello.eeprom > /tmp/cref_test.log 2>&1 &
CREF_PID=$!
sleep 3

echo "🔬 Exécution des tests APDU..."
for test_script in tests/apdu/*.scr; do
    echo "▶️  Test : $(basename $test_script)"
    apdutool "$test_script" > /tmp/out.txt 2>&1
    if grep -q "SW1: 90, SW2: 00" /tmp/out.txt; then
        echo "✅ PASS"
    else
        echo "❌ FAIL"
        cat /tmp/out.txt
        kill $CREF_PID 2>/dev/null || true
        exit 1
    fi
done

echo "✅ Tous les tests sont PASS"
kill $CREF_PID 2>/dev/null || true
