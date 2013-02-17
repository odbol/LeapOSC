(
x = {

	arg mousex, mousey, noiseAmt = 0.06;
	var x, r, f;
	x = Mix.fill(4, {
		LFSaw.ar((LFPulse.kr(noiseAmt,0,0.5,2,34 + {0.1.rand2}.dup)).midicps, 0, 0.01)
	});
	r = mousex;
	f = LinExp.kr(SinOsc.kr(0.07),-1,1,300,mousey);
	x = RLPF.ar(x, f, r).softclip;
	x = RLPF.ar(x, f, r).softclip;
}.play;


o = OSCFunc.newMatching({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln;
	msg[1..].postln;
	x.set("mousex", msg[msg.size - 2].linlin(-200,200,0.2,0.7));
	x.set("mousey", msg[msg.size - 3].linlin(-200,200,0,5000));
	msg[msg.size - 2].postln;}, '/hand/0/finger/0/pos', nil, 8000);

OSCFunc.newMatching({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln;
	msg[1..].postln;
	x.set("noiseAmt", msg[msg.size - 3].linlin(-200,200,0,5));
	msg[msg.size - 2].postln;}, '/hand/0/finger/2/pos', nil, 8000);
)