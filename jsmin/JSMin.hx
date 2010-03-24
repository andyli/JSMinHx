/* 
haXe port by Andy Li 2010-03-24.

jsmin.js - 2009-11-05
Author: Billy Hoffman
This is a patched version of jsmin.js created by Franck Marcia which
supports important comments denoted with /*! ...
Permission is hereby granted to use the Javascript version under the same
conditions as the jsmin.js on which it is based.

jsmin.js - 2006-08-31
Author: Franck Marcia
This work is an adaptation of jsminc.c published by Douglas Crockford.
Permission is hereby granted to use the Javascript version under the same
conditions as the jsmin.c on which it is based.

jsmin.c
2006-05-04

Copyright (c) 2002 Douglas Crockford  (www.crockford.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Update:
	add level:
		1: minimal, keep linefeeds if single
		2: normal, the standard algorithm
		3: agressive, remove any linefeed and doesn't take care of potential
		   missing semicolons (can be regressive)
	store stats
		jsmin.oldSize
		jsmin.newSize
*/

package jsmin;

class JSMin {
	private static var _EOF:String = null;
	private static var LETTERS:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
	private static var DIGITS:String = '0123456789';
	private static var ALNUM:String = LETTERS + DIGITS + '_$\\';
	
	/* isAlphanum -- return true if the character is a letter, digit, underscore,
			dollar sign, or non-ASCII character.
	*/
	public static function isAlphanum(c:String):Bool {
		return (c != _EOF) && (ALNUM.indexOf(c) > -1 || c.charCodeAt(0) > 126);
	}
	
	/* get -- return the next character. Watch out for lookahead. If the
			character is a control character, translate it to a space or
			linefeed.
	*/
	private function get():String {
		var c = theLookahead;
		if (get_i == get_l) {
			return _EOF;
		}
		theLookahead = _EOF;
		if (c == _EOF) {
			c = input.charAt(get_i);
			++get_i;
		}
		if (c >= ' ' || c == '\n') {
			return c;
		}
		if (c == '\r') {
			return '\n';
		}
		return ' ';
	}
	private var get_i:Int;
	private var get_l:Int;
	
	
	/* peek -- get the next character without getting it.
	*/
	private function peek():String {
		theLookahead = get();
		return theLookahead;
	}
	
	/* next -- get the next character, excluding comments. peek() is used to see
			if a '/' is followed by a '/' or '*'.
	*/
	private function next():String {
		var c = get();
		if (c == '/') {
			switch (peek()) {
			case '/':
				while (true) {
					c = get();
					if (c <= '\n') {
						return c;
					}
				}
			case '*':
				//this is a comment. What kind?
				get();
				if(peek() == '!') {
					//important comment
					var d = '/*!';
					while (true) {
						c = get();
						switch (c) {
						case '*':
							if (peek() == '/') {
								get();
								return d+'*/';
							}
						case _EOF:
							throw 'Error: Unterminated comment.';
						default:
							//modern JS engines handle string concats much better than the 
							//array+push+join hack.
							d+=c;
						}
					}					
				} else {
					//unimportant comment
					while (true) {
						switch (get()) {
						case '*':
							if (peek() == '/') {
								get();
								return ' ';
							}
						case _EOF:
							throw 'Error: Unterminated comment.';
						}
					}
				}
			default:
				return c;
			}
		}
		return c;
	}
	
	/* action -- do something! What you do is determined by the argument:
			1   Output A. Copy B to A. Get the next B.
			2   Copy B to A. Get the next B. (Delete A).
			3   Get the next B. (Delete B).
	   action treats a string as a single character. Wow!
	   action recognizes a regular expression if it is preceded by ( or , or =.
	*/
	private function action(d:Int):String {
		var r:Array<String> = new Array<String>();

		if (d == 1) {
			r.push(a);
		}

		if (d < 3) {
			a = b;
			if (a == '\'' || a == '"') {
				while (true) {
					r.push(a);
					a = get();
					if (a == b) {
						break;
					}
					if (a <= '\n') {
						//throw 'Error: unterminated string literal: ' + a;
					}
					if (a == '\\') {
						r.push(a);
						a = get();
					}
				}
			}
		}

		b = next();

		if (b == '/' && '(,=:[!&|'.indexOf(a) > -1) {
			r.push(a);
			r.push(b);
			while (true) {
				a = get();
				if (a == '/') {
					break;
				} else if (a =='\\') {
					r.push(a);
					a = get();
				} else if (a <= '\n') {
					throw 'Error: unterminated Regular Expression literal';
				}
				r.push(a);
			}
			b = next();
		}

		return r.join('');
	}
	
	/* m -- Copy the input to the output, deleting the characters which are
			insignificant to JavaScript. Comments will be removed. Tabs will be
			replaced with spaces. Carriage returns will be replaced with
			linefeeds.
			Most spaces and linefeeds will be removed.
	*/
	private function m():String {

		var r:Array<String> = new Array<String>();
		a = '\n';

		r.push(action(3));

		while (a != _EOF) {
			switch (a) {
			case ' ':
				if (isAlphanum(b)) {
					r.push(action(1));
				} else {
					r.push(action(2));
				}
			case '\n':
				switch (b) {
				case '{','[','(','+','-':
					r.push(action(1));
				case ' ':
					r.push(action(3));
				default:
					if (isAlphanum(b)) {
						r.push(action(1));
					} else {
						if (level == 1 && b != '\n') {
							r.push(action(1));
						} else {
							r.push(action(2));
						}
					}
				}
			default:
				switch (b) {
				case ' ':
					if (isAlphanum(a)) {
						r.push(action(1));
					} else {
						r.push(action(3));
					}
				case '\n':
					if (level == 1 && a != '\n') {
						r.push(action(1));
					} else {
						switch (a) {
						case '}',']',')','+','-','"','\'':
							if (level == 3) {
								r.push(action(3));
							} else {
								r.push(action(1));
							}
						default:
							if (isAlphanum(a)) {
								r.push(action(1));
							} else {
								r.push(action(3));
							}
						}
					}
				default:
					r.push(action(1));
				}
			}
		}

		return r.join('');
	}

	
	private var a:String;
	private var b:String;
	private var theLookahead:String;
	
	public var input(default,null):String;
	public var level(default,null):Int;
	public var comment(default,null):String;
	public var output(default,null):String;
	public var oldSize(default,null):Int;
	public var newSize(default,null):Int;

	public function new(p_input:String, ?p_level:Int = 2 , ?p_comment:String = "") {
		input = p_input;
		level = (p_level < 1 || p_level > 3) ? 2 : p_level;
		comment = (p_comment.length > 0) ? p_comment + '\n' : "";
		
		get_i = 0;
		get_l = input.length;
		
		a = '';
		b = '';
		theLookahead = _EOF;
		
		oldSize = input.length;
		var ret = m();
		newSize = ret.length;
		
		output = comment + ret;
	}
}
