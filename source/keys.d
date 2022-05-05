private enum name=cleanupname(__FILE__);
mixin template tilemapsettings(string s:name){
	enum xcount=34;
	enum ycount=24;
	enum width=16;
	enum height=16;
}
string cleanupname(string s){//I was getting the path dispite what the spec says
	import std.string;
	return s[
		lastIndexOf(s,'/')+1..
		lastIndexOf(s,'.')];
}

//import raylib;

mixin template setupdraw(string name_:name,bool b=true){
	static if(b){
		mixin tilemapsettings!name_;
	}
	Rectangle getrect(int i){
		assert(i<=xcount*ycount);
		return Rectangle(
			(i%xcount)*width,
			(i/xcount)*height,
			width,
			height);
	}
	Texture2D image=LoadTexture("assets/"~name_~".png");
	void draw(int which,int x, int y){
		DrawTextureRec(image,getrect(which),Vector2(x,y),Colors.WHITE);
	}
	void draw(int which,int x,int y,float scale){
		DrawTextureTiled(image,getrect(which),Rectangle(x,y,width*scale,height*scale),
				Vector2(0,0),0,scale,Colors.WHITE);
	}
	mixin("void draw"~name_~"(T...)(T args){draw(args);}");
}