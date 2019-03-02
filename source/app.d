import std.stdio;
import std.math;
import std.typecons;
import std.string;
import std.conv;
import std.algorithm;
import std.regex;
import std.range;
import codewars.shortcuts;

version(prob00)
{
	void invoke()
	{
		writeln(cast(uint)(cast(double)dumbRead!uint / 3.785));
	}
}

version(prob01)
{
	alias ringSurface = (r, w) => 2 * PI * r * w;
	enum erf = 196.935e+6;
	void invoke()
	{
		auto r = treadf!("%f %f\n", double, double);
		writeln(
			cast(ulong)(ringSurface(r[0], r[1]) / erf)
		);
	}
}

version(prob02)
{
	string[] board = [
		['.', '.', '.', '.', '.', '.', '.', '.',],
		['.', '.', '.', '.', '.', '.', '.', '.',],
		['.', '.', '.', '.', '.', '.', '.', '.',],
		['.', '.', '.', 'W', 'B', '.', '.', '.',],
		['.', '.', '.', 'B', 'W', '.', '.', '.',],
		['.', '.', '.', '.', '.', '.', '.', '.',],
		['.', '.', '.', '.', '.', '.', '.', '.',],
		['.', '.', '.', '.', '.', '.', '.', '.',]
	];
	void replace(uint v, uint h, char r)
	{
		ubyte[] cp = cast(ubyte[])board[v];
		cp[h] = cast(ubyte)r;
		board[v] = cast(string)cp;
	}
	alias Point = Tuple!(int, int);
	Point[] offsets = [
		Point(-1, 0),
		Point(1, 0),
		Point(-1, -1),
		Point(-1, 1),
		Point(1, -1),
		Point(1, 1),
		Point(0, -1),
		Point(0, 1)
	];
	void simulateMove(string move, char r)
	{
		int h = cast(int)move[0] - cast(int)'a';
		int v = [move[1]].to!int - 1;
		// writeln(v, "\t", h);
		// board[v][h].writeln;
		// board[v][h] = '*';
		replace(v, h, r);
		foreach(perm; offsets)
		{
			// the perm (permutation) describes the direction that the line is going to travel
			bool linearReplace = false;
			Point[] queue;
			for (int i = 8; i >= 1; i--)
			{
				// compute the new coordinates
				int th = h + perm[0] * i;
				int tv = v + perm[1] * i;
				if (th < 0 || th > 7) continue; // invalid coordinate
				if (tv < 0 || tv > 7) continue; // invalid coordinate
				// writeln(tv, "\t", th, "\t", board[tv][th], "\t", r);
				// check this coordinate
				char here = board[tv][th];
				if (here != '.') // we found a matching point
				{
					// writeln("target point:\t", tv, "\t", th, "\t", linearReplace);
					if (i == 1 && linearReplace == false) // ensure that it was a linear replace before
						continue;
					else if (linearReplace == false && here != r) // we want to start on the right track
						continue;
					{
						linearReplace = true;
						queue ~= Point(th, tv);
					}
				}
				else if (here == '.') // if there is a point that is inbetween some arbitrary point and where we are now that is empty
				{
					linearReplace = false;
					queue = []; // empty queue, because there was a point that broke the link
				}
			}
			// queue.writeln;
			if (linearReplace)
				foreach(p; queue)
					replace(p[1], p[0], r);
		}
	}
	void invoke()
	{
		char r = 'W';
		string ln;
		while ((ln = readln.strip) != "END")
		{
			simulateMove(ln, r);
			r  = r == 'W' ? 'B' : 'W'; 
		}
		foreach(l; board)
			l.writeln;
	}
}

version(prob03)
{
	void invoke()
	{
		string[] tok = readln.strip.split(" ");
		string s = tok[0];
		writeln(s.replace(tok[1], tok[2]));
	}
}

version(prob04)
{
	alias Peter = Tuple!(uint, "of13", uint, "of11", uint, "of6", uint, "sum");
	void invoke()
	{
		uint peppers = dumbRead!uint;
		uint max13 = peppers / 13;
		uint max11 = peppers / 11;
		uint max6 = peppers / 6;
		Peter[] solutions;
		for(int i = 0; i < max13; i++)
		{
			for(int j = 0; j < max11; j++)
			{
				for (int k = 0; k < max6; k++)
				{
					int sum13 = i * 13;
					int sum11 = j * 11;
					int sum6 = k * 6;
					if (sum13 + sum11 + sum6 == peppers)
					{
						solutions ~= Peter(i, j, k, sum13 + sum11 + sum6);
					}
				}
			}
		}
		bool pCmp(const Peter left, const Peter right)
		{
			return left.of13 > right.of13;
		}
		solutions.sort!(pCmp);
		if (solutions.length == 0)
			writeln(peppers, " peppers cannot be packed.");
		else
			writeln(solutions[0].sum, " peppers can be packed at most\n", solutions[0].of13, " package(s) of 13\n", solutions[0].of11, " package(s) of 11\n", solutions[0].of6, " package(s) of 6\n", solutions[0].of13 + solutions[0].of11 + solutions[0].of6, " total package(s)");
	}
}

version(prob05)
{
	alias Sides = Tuple!(int, int, int, int, int);
	Sides[] computeSides(int l, int u)
	{
		Sides[] ret;
		alias S = (a, b, c) => (a + b + c) / 2;
		alias A = (a, b, c, s) => sqrt(s*(s-a)*(s-b)*(s-c));
		for (int a = 3; a <= u; a++)
		{
			for (int b = 4; b <= u; b++)
			{
				for (int c = l; c <= u; c++)
				{
					int s = S(a, b, c);
					double tArea = A(cast(double)a, cast(double)b, cast(double)c, cast(double)s);
					// check if its an int
					if (tArea != tArea.round) continue;
					int tPerimeter = a + b + c;
					for (int i = 2; i <= u; i++)
					{
						for (int j = 6; j <= u; j++)
						{
							int rPerimeter = (2 * i) + (2 * j);
							double rArea =  cast(double)i * cast(double)j;
							if (rPerimeter == tPerimeter && rArea == tArea)
							{
								ret ~= Sides(a, b, c, i, j);
							}
						}
					}
				}
			}
		}
		return ret;
	}
	void serialize(ref Sides s)
	{
		int[] arr = [ s[0], s[1], s[2] ];
		arr.sort;
		s[0] = arr[0];
		s[1] = arr[1];
		s[2] = arr[2];
		arr = [ s[3], s[4] ];
		arr.sort;
		s[3] = arr[0];
		s[4] = arr[1];
	}
	bool present(Sides[] sides, Sides s)
	{
		foreach(z; sides)
			if (z == s)
				return true;
		return false;
	}
	void invoke()
	{
		int u, l;
		readf!"%d %d\n"(l, u);
		auto r = computeSides(l, u);
		Sides[] printed;
		foreach(ref s; r)
		{
			s.serialize();
			if (present(printed, s)) continue;
			writeln("(", s[0], ", ", s[1], ", ", s[2], ") (", s[3], ", ", s[4], ")");
			printed ~= s;
		}
	}
}

version(prob07)
{
	alias Occurances = Tuple!(char, int);
	void invoke()
	{
		int[char] occMap;
		Occurances[] occ;
		string ln;
		while ((ln = readln.stripRight) != "###")
		{
			ln = ln.replaceAll(regex("[^a-zA-z]", "g"), "");
			foreach(c; ln)
			{
				char C = cast(char)c.toUpper;
				occMap[C]++;
			}
		}
		//writeln(occMap);
		foreach(key, val; occMap.byPair)
		{
			occ ~= Occurances(key, val);
		}
		occ.sort!((a,b) => a[1] > b[1]);
		foreach(o; occ)
		{
			string s;
			foreach(_; o[1].iota)
				s ~= "*";
			writeln(o[0], ": ", s);
		}
		foreach(i; iota(cast(int)'A', cast(int)'Z'+1))
		{
			if ((cast(char)i in occMap) is null)
				writeln(cast(char)i);
		}
	}
}

version(prob08)
{
	void invoke()
	{
		string sentence = readln.stripRight;//replaceAll(regex("[^a-zA-z]", "g"), "");
		string[] tok = sentence.split(" ");
		string decoded = readln.stripRight.split(" ")[1];
		string sanitater = sentence.replaceAll(regex("[^a-zA-z]", "g"), "");
		for (int i = 0; i < sanitater.length - decoded.length; i++)
		{
			string sstr = sanitater[i..i+decoded.length];
			//sstr.writeln;
			for (int s; s < 26; s++)
			{
				bool match = true;
				foreach(j, c; sstr)
				{
					char nC = cast(char)(((cast(int)c-0x41 + s) % 26) + 0x41);
					if (nC != decoded[j])
						match = false;
				}
				if (match == true)
				{
					foreach(t; tok)
					{
						string dec;
						foreach(c; t)
						{
							dec ~= cast(char)(((cast(int)c-0x41 + s) % 26) + 0x41);
						}
						write(dec, " ");
					}
					writeln;
					return;
				}
			}
		}
	}
}

version(unittest)
{
}
else
{
	void main()
	{
		invoke();
	}
}
