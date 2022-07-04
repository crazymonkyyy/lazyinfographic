import std.stdio;
void writeblob(string file, int[] data, string[] header){
	auto o=File(file~".blob","w");
	o.writeln("BLOB file type ^tm");
	foreach(s;header){
		o.writeln(s);}
	o.writeln("END");
	int error;
	foreach(i;data){
		error=(error+i)%int.max;}
	o.write(*(cast(char[4]*)(&error)));
	foreach(i;data){
		o.write(*(cast(char[4]*)(&i)));
	}
}
struct blob{
	string file;
	int[] data;
	string[] header;
	int expectederror(){
		int error;
		foreach(i;data){
			error=(error+i)%int.max;}
		return error;
	}
	int reportederror;
	bool isvalid(){
		return expectederror==reportederror;}
	void rewrite(){
		writeblob(file,data,header);}
	string get(string s){
		foreach(t;header){
			if(t.length>s.length && t[0..s.length]==s){
				return t[s.length..$];
		}}
		return "";
	}
}

blob readblob(string file){
	blob o;
	o.file=file;
	import std.file;
	if(!exists(file~".blob")){ return o;}
	auto i=File(file~".blob");
	auto i_=i.byLineCopy;
	assert(i_.front=="BLOB file type ^tm","file appears to not be a blob");
	assert(i_.front=="BLOB file type ^tm","std is being awful");
	i_.popFront;
	while(i_.front!="END"){
		o.header~=i_.front;
		i_.popFront;
	}
	//spooky popfront of spookyness
	auto i__=i.byChunk(4);
	int take(T)(T a){
		ubyte[4] o;
		foreach(i,b;a){
			o[i]=b;}
		return *(cast(int*)(&o));
	}
	o.reportederror=take(i__.front);
	i__.popFront;
	while(!i__.empty){
		o.data~=take(i__.front);
		i__.popFront;
	}
	return o;
}
	
	
enum blobwords=["width","height","depth","strange","charm","truth","beauty"];