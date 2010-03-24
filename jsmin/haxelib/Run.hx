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
		
		var last:String = (new neko.io.Path(args[args.length-1])).toString();
		var slash = last.substr(-1);
		if (slash=="/"|| slash=="\\") 
			last = last.substr(0,last.length-1);
		if (neko.FileSystem.exists(last) && neko.FileSystem.isDirectory(last)) {
			neko.Sys.setCwd(last);
		}
		
		if (args.length < 3){
			printUsage();
			return;
		}
		
		var result:String;
		var input:String;
		try {
			input = neko.io.File.getContent(args[0]);
		} catch(e:Dynamic) {
			neko.Lib.println("Cannot read input file: "+args[0]);
			printUsage();
			return;
		}
	
		if (args.length >= 5) {
			result = new JSMin(input,Std.parseInt(args[2]),args[3]).output;
		} else if (args.length >= 4) {
			result = new JSMin(input,Std.parseInt(args[2])).output;
		} else {
			result = new JSMin(input).output;
		}
		
		var fout = neko.io.File.write(args[1], false);
		fout.writeString(result);
		fout.close();
	} 
}
