package jsmin.haxelib;

import jsmin.JSMin;

class Run {
	static public function printUsage():Void {
		neko.Lib.println("Usage: haxelib run jsmin inputFile outputFile [level] [comment]");
	}
	
	static public function test():Void {
		var runner = new haxe.unit.TestRunner();
		runner.add(new jsmin.test.Test());
		runner.run();
	}

	static public function main():Void {
		var args = neko.Sys.args();
		
		if (args.length >= 1 && args[0] == "test") {
			test();
			return;
		}
		
		if (args.length < 2){
			printUsage();
			return;
		}
		
		var result:String;
		var input:String;
		try {
			input = neko.io.File.getContent(neko.Sys.getCwd()+args[0]);
		} catch(e:Dynamic) {
			neko.Lib.println("Cannot read input file: "+(neko.Sys.getCwd()+args[0]));
			printUsage();
			return;
		}
	
		if (args.length >= 4) {
			result = new JSMin(input,Std.parseInt(args[2]),args[3]).output;
		} else if (args.length >= 3) {
			result = new JSMin(input,Std.parseInt(args[2])).output;
		} else {
			result = new JSMin(input).output;
		}
		
		var fout = neko.io.File.write(args[1], false);
		fout.writeString(result);
		fout.close();
	} 
}
