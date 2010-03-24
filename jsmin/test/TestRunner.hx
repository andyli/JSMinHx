package jsmin.test;

class TestRunner extends haxe.unit.TestRunner {
	public function new(){
		super();
		this.add(new Test());
	}
	
	static public function main():Void {
		new TestRunner().run();
	}
}
