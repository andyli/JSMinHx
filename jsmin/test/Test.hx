package jsmin.test;

import jsmin.JSMin;

/*
	The test data is from http://fmarcia.info/jsmin/test1.html
*/
class Test extends haxe.unit.TestCase {
	public function testLevel1():Void {
		var o:String = haxe.Resource.getString("is.js");
		var r1:String = StringTools.trim(haxe.Resource.getString("is.min.1.js"));
		
		var min = new JSMin(o,1);
		var r = StringTools.trim(min.output);
		this.assertEquals(o,min.input);
		this.assertEquals(r1,r);
		this.assertEquals(o.length,min.oldSize);
		this.assertEquals(r1.length,r.length);
	}
	
	public function testLevel2():Void {
		var o:String = StringTools.trim(haxe.Resource.getString("is.js"));
		var r2:String = StringTools.trim(haxe.Resource.getString("is.min.2.js"));
	
		var min = new JSMin(o,2);
		var r = StringTools.trim(min.output);
		this.assertEquals(o.length,min.oldSize);
		this.assertEquals(r2.length,r.length);
		this.assertEquals(o,min.input);
		this.assertEquals(r2,r);
	}
	
	public function testLevel3():Void {
		var o:String = StringTools.trim(haxe.Resource.getString("is.js"));
		var r3:String = StringTools.trim(haxe.Resource.getString("is.min.3.js"));
	
		var min = new JSMin(o,3);
		var r = StringTools.trim(min.output);
		this.assertEquals(o.length,min.oldSize);
		this.assertEquals(r3.length,r.length);
		this.assertEquals(o,min.input);
		this.assertEquals(r3,r);
	}
}
