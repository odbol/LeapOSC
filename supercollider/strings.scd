(

// harmonic zither
// use mouse to strum strings
x = {
	arg mousex, mousey, noiseAmt;
	var pitch, out, triggerSpacing, panSpacing;
	// harmonic series
	//pitch = [ 50, 53.86, 57.02, 59.69, 62, 64.04, 65.86, 67.51, 69.02, 71.69, 72.88, 74 ];
	//pitch = [ 52, 62, 76, 57, 71, 67, 52-24, 62-24, 76-24, 57-24, 71-24, 67-24 ];

	pitch = [ 52, 62, 76, 52-24, 62-24, 76-24, 77-24 ];
	//mousex = MouseX.kr;
	//mousey = MouseY.kr;
	triggerSpacing = 1.0 / (pitch.size - 1);
	panSpacing = 1.0 / (pitch.size - 1);
	out = Mix.arFill(pitch.size, { arg i;
		var trigger, pluck, period, string;
		// place trigger points from 0.25 to 0.75
		trigger = HPZ1.kr(mousex > (0.05 + (i * triggerSpacing))).abs;
		pluck = PinkNoise.ar(Decay.kr(trigger, noiseAmt));
		period = pitch.at(i).midicps.reciprocal;
		string = CombL.ar(pluck, period, period, 8);
		Pan2.ar(string, i * panSpacing - 0.75);
	});
	LPF.ar(out, 12000);
	LeakDC.ar(out);
}.play;



o = OSCFunc.newMatching({ arg msg, time, addr, recvPort;
	var mX;

	[msg, time, addr, recvPort].postln;
	msg[1..].postln;
	mX = msg[msg.size - 3].linlin(-200,200,0,1);
	mX.postln;
	x.set("mousex", mX);
	x.set("mousey", msg[msg.size - 1].linlin(-200,200,0,1));
}, '/hand/0/finger/0/pos', nil, 8000);

OSCFunc.newMatching({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln;
	msg[1..].postln;
	x.set("noiseAmt", msg[msg.size - 2].linlin(100,400,0,5));
}, '/hand/0/finger/2/pos', nil, 8000);
)
o.free;
of.free;

(0..99).linlin(0,100,10,1000).plot2

