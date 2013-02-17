/******************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\******************************************************************************/
package com.odbol.leap;

import java.io.IOException;
import java.lang.Math;
import java.net.InetSocketAddress;

import com.leapmotion.leap.*;


import com.relivethefuture.osc.data.BasicOscListener;
import com.relivethefuture.osc.data.OscMessage;
import com.relivethefuture.osc.transport.OscClient;
import com.relivethefuture.osc.transport.OscServer;


class Sample {
	
	static OscClient osc;
	
	static int oscPort = 8000;
	static private String oscAddr = "127.0.0.1";
	
    public static void main(String[] args) {
    	

    	try {
			osc = new OscClient(true);//as of now, the TCP implementation of OSCLib is broken (getting buffer overflows!), so we have to use UDP.
			osc.connect(new InetSocketAddress(oscAddr, oscPort));
		}
		catch (Exception e) {
            e.printStackTrace();
            return;
		}	
		
    	
    	
        // Create a sample listener and controller
        SampleListener listener = new SampleListener();
        Controller controller = new Controller();

        // Have the sample listener receive events from the controller
        controller.addListener(listener);

        
        
        // Keep this process running until Enter is pressed
        System.out.println("Press Enter to quit...");
        try {
            System.in.read();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // Remove the sample listener when done
        controller.removeListener(listener);
    }
    

	static class SampleListener extends Listener {
	    public void onInit(Controller controller) {
	        System.out.println("Initialized");
	    }
	
	    public void onConnect(Controller controller) {
	        System.out.println("Connected");
	    }
	
	    public void onDisconnect(Controller controller) {
	        System.out.println("Disconnected");
	    }
	
	    public void onExit(Controller controller) {
	        System.out.println("Exited");
	    }
	
	    public void onFrame(Controller controller) {
	        // Get the most recent frame and report some basic information
	        Frame frame = controller.frame();
	        System.out.println("Frame id: " + frame.id()
	                         + ", timestamp: " + frame.timestamp()
	                         + ", hands: " + frame.hands().count()
	                         + ", fingers: " + frame.fingers().count()
	                         + ", tools: " + frame.tools().count());
	
	        if (!frame.hands().empty()) {
	            // Get the first hand
	            Hand hand = frame.hands().get(0);
	
	            // Check if the hand has any fingers
	            FingerList fingers = hand.fingers();
	            if (!fingers.empty()) {
	                // Calculate the hand's average finger tip position
	                Vector avgPos = Vector.zero();
	                for (Finger finger : fingers) {
	                    avgPos = avgPos.plus(finger.tipPosition());
	                    
	    				OscMessage m = new OscMessage("/finger/" + finger.id() + "/pos/");
	    				m.addArgument(finger.tipPosition());
	    				try {
	    					osc.sendPacket(m);
	    				} catch (Exception e) {
	    					e.printStackTrace();
	    				}
	                    
	                }
	                avgPos = avgPos.divide(fingers.count());
	                System.out.println("Hand has " + fingers.count()
	                                 + " fingers, average finger tip position: " + avgPos);
	            }
	
	            // Get the hand's sphere radius and palm position
	            System.out.println("Hand sphere radius: " + hand.sphereRadius()
	                             + " mm, palm position: " + hand.palmPosition());
	
	            // Get the hand's normal vector and direction
	            Vector normal = hand.palmNormal();
	            Vector direction = hand.direction();
	
	            // Calculate the hand's pitch, roll, and yaw angles
	            System.out.println("Hand pitch: " + Math.toDegrees(direction.pitch()) + " degrees, "
	                             + "roll: " + Math.toDegrees(normal.roll()) + " degrees, "
	                             + "yaw: " + Math.toDegrees(direction.yaw()) + " degrees\n");
	        }
	    }
	}

}