(

    // harmonic zither
    // use mouse to strum strings
x = {
	arg mousex, mousey, noiseAmt;
	var pitch, out, triggerSpacing, panSpacing;
	// harmonic series
	pitch = [ 50, 53.86, 57.02, 59.69, 62, 64.04, 65.86, 67.51, 69.02, 71.69, 72.88, 74 ];
	//mousex = MouseX.kr;
	//mousey = MouseY.kr;
	triggerSpacing = 1.9 / (pitch.size - 1);
	panSpacing = 1.5 / (pitch.size - 1);
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



o = OSCFunc.newMatching({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln;
	msg[1..].postln;
	x.set("mousex", msg[msg.size - 3].linlin(-200,200,0,1));
	x.set("mousey", msg[msg.size - 2].linlin(-200,200,0,1));
	msg[msg.size - 2].postln;}, '/hand/0/finger/0/pos', nil, 8000);

OSCFunc.newMatching({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln;
	msg[1..].postln;
	x.set("noiseAmt", msg[msg.size - 3].linlin(-200,200,0,10));
	msg[msg.size - 2].postln;}, '/hand/0/finger/2/pos', nil, 8000);
)
o.free;
of.free;

(0..99).linlin(0,100,10,1000).plot2

