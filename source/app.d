import raylib;
import basic;
enum textsize=32;
int selectedtext=0;
bool selectedreal(){
	return selectedtext>=0 && selectedtext<=50;
}
string[50] strings; 
int[50] offsets;
struct button{
	int x;
	int y;
	int which;
}
button[] buttons;
void main(){
	InitWindow(1080, 780, "Hello, Raylib-D!");
	import keys;
	strings[3]="hi";
	strings[5]="bye";
	offsets[5]=100;
	mixin setupdraw!"keys";
	void draw_(button b){
		draw(b.which,b.x,b.y,2);
	}
	int tool;
	bool showtool=true;
	while (!WindowShouldClose()){
		BeginDrawing();
		scope(exit) EndDrawing();
		int toolx=GetMouseX;
		int tooly=GetMouseY;
		button tooltip=button(toolx,tooly,tool);
		
		if(IsMouseButtonPressed(0)){
			buttons~=tooltip;
		}
		if(IsMouseButtonPressed(1)){
			buttons=buttons[0..max(0,cast(int)$-1)];
		}
		if(IsMouseButtonPressed(2)){
			import std.process;
			tool=("./keysselector")
				.executeShell.output[0..$-1].to!int;
		}
		if(IsKeyPressed(KeyboardKey.KEY_LEFT_ALT)){
			showtool= ! showtool;
		}
		
		if(IsKeyPressed(KeyboardKey.KEY_DOWN)){
			selectedtext++;
		}
		if(IsKeyPressed(KeyboardKey.KEY_UP)){
			selectedtext--;
		}
		if(IsKeyPressed(KeyboardKey.KEY_LEFT)&&selectedreal){
			offsets[selectedtext]--;
		}
		if(IsKeyPressed(KeyboardKey.KEY_RIGHT)&&selectedreal){
			offsets[selectedtext]++;
		}
		if(selectedreal){
			int i=GetCharPressed;
			if(i<255&&i>0){
				strings[selectedtext]~=cast(char)i;
			}
		}
		if(IsKeyPressed(KeyboardKey.KEY_BACKSPACE)&&selectedreal){
			strings[selectedtext]=strings[selectedtext][0..max(cast(int)$-1,0)];
		}
		
		foreach(e;buttons){
			draw_(e);
		}
		foreach(i;0..50){
			if(i==selectedtext && showtool){DrawCircle(offsets[i],i*(textsize+2),5,Colors.BLUE);}
			DrawText(strings[i].toStringz,offsets[i],i*(textsize+2),textsize,Colors.WHITE);
		}
		if(showtool){
			draw_(tooltip);
		}
		ClearBackground(Colors.BLACK);
	}
	CloseWindow();
}