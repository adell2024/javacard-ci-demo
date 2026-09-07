package fr.insa;

import javacard.framework.*;

public class HelloWorldApplet extends Applet {

    private static final byte[] HELLO_WORLD = {
        (byte)'H', (byte)'e', (byte)'l', (byte)'l', (byte)'o',
        (byte)' ', (byte)'W', (byte)'o', (byte)'r', (byte)'l', (byte)'d'
    };
    private static final short HELLO_WORLD_LEN = 11;

    private static final byte CLA_APPLET = (byte)0x80;
    private static final byte INS_GET_HELLO = (byte)0x01;

    private HelloWorldApplet() {
        register();
    }

    public static void install(byte[] bArray, short bOffset, byte bLength) {
        new HelloWorldApplet();
    }

    public void process(APDU apdu) {
        if (selectingApplet()) return;

        byte[] buffer = apdu.getBuffer();
        byte cla = (byte)(buffer[ISO7816.OFFSET_CLA] & 0xFF);
        byte ins = (byte)(buffer[ISO7816.OFFSET_INS] & 0xFF);

        if (cla != CLA_APPLET) {
            ISOException.throwIt(ISO7816.SW_CLA_NOT_SUPPORTED);
        }

        switch (ins) {
            case INS_GET_HELLO:
                sendHelloWorld(apdu);
                break;
            default:
                ISOException.throwIt(ISO7816.SW_INS_NOT_SUPPORTED);
        }
    }

    private void sendHelloWorld(APDU apdu) {
        byte[] buffer = apdu.getBuffer();
        Util.arrayCopyNonAtomic(HELLO_WORLD, (short)0, buffer, (short)0, HELLO_WORLD_LEN);
        apdu.setOutgoingAndSend((short)0, HELLO_WORLD_LEN);
    }
}
