#!rdmd -I./mylibs
enum localfolders=[
	"experiments",
	"mylibs",
	"raylib",
	"source",
];
enum mixfolders=[//consider not making a distinction
	"source",
];
enum defualtbiuld="source/app.d";
struct toggleableflag{
	string me;
	string disable;
}
enum toggleableflags=[
	toggleableflag("-run","b"),//-run needs to be kept last
];
enum linuxflags=[
	"-L-lraylib",
];
enum windowsflags=[//todo find msvc16
	//"raylib.lib",
	"raylibdll.lib",
	"WinMM.lib",
	"MSVCRT.lib",
	"OLDNAMES.lib",
	"-L=/NODEFAULTLIB:MSVCRT",
	//"raylib.dll",
	//"-m32mscoff",
	"-m64",
];
version(Windows){
	enum platformflags=windowsflags;
	enum win=true;
}
version(linux){
	enum platformflags=linuxflags;
	enum win=false;
}
enum flags=[
	"-i",
]~platformflags;

enum defualtcompiler="dmd ";
import basic;
import scombinators;
void main(string[] s){
	//s.writeln;
	bool verbose=true;//TODO: make flag for verbose
	string constructcommand(string[] args){
		int indentifyfile(){
			int i=0;
			while(args.length>i && args[i][0]=='-'){
				i++;}
			if(args.length==i){
				"auto biulding ".write;
				defualtbiuld.write;
				" with ".write;
				args.writeln;
				args~=defualtbiuld;
			}
			return i;
		}
		int wherefile=indentifyfile;
		string[] biuldflags(){return args[0..wherefile];}
		dstring  file(){return args[wherefile].to!dstring;}
		string[] rest(){return args[min(wherefile+1,$)..$];}//TODO make a safe slice ulity already
		dstring compiler=defualtcompiler;//TODO: make flags for alt compilers
		toggleableflag[] toggles;
		auto passedbiuldflags=
			biuldflags.map!(a=>a).sfoldmapoutput!(toggles,//TODO dont copy and paste metaprogramming with lazy modifications that work once for supposely code with standards
				(s,ref toggles){
					//"processing ".writeln(s);
					foreach(i;0..toggles.length){
						if(s[1..$]==toggles[i].disable){
							//"disabling ".writeln(toggles[i].me);
							toggles=toggles[0..i]~toggles[i+1..$];
							//"toggles left".writeln(toggles);
							return "";
					}}
					return s;
				})(toggleableflags)
				.filter!(a=>a!="")
				.array// Im unsure, but my current belief is that chain(foo,bar) where foo is lazy and bar is depentant on foo, can act incorrectly; so this .array is to make it eager
				//TODO: understand if chain or sfoldmapoutput is to blame for spooky action at a distence
			;
		auto combinedflags=
			chain(
				localfolders.map!(a=>"-I./"~a),
				mixfolders.map!(a=>"-J=./"~a),
				flags,
				passedbiuldflags,
				toggles.map!(a=>a.me))
			.joiner(" ")
			.array
			;
		return (compiler~combinedflags~" "~file~" "~
			(rest.joiner(" ").array)).to!string;
	}
	string c;
	//static if(win){
	//	c=constructcommand(s[0..$]);
	//}else{
		c=constructcommand(s[1..$]);
	//}
	if(verbose){
		c.writeln;
	}
	import std.process;
	auto pid=spawnShell(c);
	wait(pid);
}