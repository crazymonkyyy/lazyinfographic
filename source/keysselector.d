enum name=cleanupname2(__FILE__);
enum scale=2;
string cleanupname(string s){//I was getting the path dispite what the spec says
	import std.string;
	return s[
		lastIndexOf(s,'/')+1..
		lastIndexOf(s,'.')];
}
string cleanupname2(string s){
	string s_=cleanupname(s);
	assert(s_[$-8..$]=="selector");
	return s_[0..$-8];
}
void main(){
	import raylib;
	mixin("import "~name~";");
	mixin tilemapsettings!name;
	SetTraceLogLevel(int.max);
	InitWindow(xcount*width*scale, ycount*height*scale, "Hello, Raylib-D!");
	mixin setupdraw!(name,false);
	SetTargetFPS(60);
	int tool=0;
	while (!WindowShouldClose()){
		BeginDrawing();
			ClearBackground(Colors.BLACK);
			DrawTextureEx(image,Vector2(0,0),0,scale,Colors.WHITE);
			foreach(i;0..xcount*ycount){
				auto r=getrect(i);
				if(
					GetMouseX/scale>r.x    &&
					GetMouseX/scale<r.w+r.x&&
					GetMouseY/scale>r.y    &&
					GetMouseY/scale<r.h+r.y)
					{tool=i;}
			}
			Rectangle r=getrect(tool);
			r.x*=scale;
			r.y*=scale;
			r.h*=scale;
			r.w*=scale;
			DrawRectangleLinesEx(r,4,Colors.GRAY);
			if(IsMouseButtonPressed(0)){
				import std;
				tool.writeln; return;
			}
		EndDrawing();
	}
	CloseWindow();
}