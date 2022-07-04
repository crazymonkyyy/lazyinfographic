import raylib;
import basic;
import blob;
import monkyyykeys;
import basic;
enum textsize=32;
int selectedtext=0;
bool selectedreal(){
	return selectedtext>=0 && selectedtext<=100;
}
//Color toolcolor(){
//	return selectedtext>50? Colors.BLUE:Colors.GREEN;
//}
void pokeselected(){
	if(selectedtext>50){selectedtext-=50;}
	else{selectedtext+=50;}
}
string[100] strings; 
int[100] offsets;
struct button_{
	int x;
	int y;
	int which;
}
button_[] buttons;

string file;
void output(){
	int[] data=offsets[];
	foreach(e;buttons){
		data~=e.x;
		data~=e.y;
		data~=e.which;
	}
	string[] header;
	foreach(i;0..100){
		header~=i.to!string~":"~strings[i];
	}
	writeblob(file,data,header);
}
void input(){
	auto blob=readblob(file);
	if(blob.data.length==0){return;}
	foreach(i,ref e;offsets){
		e=blob.data[i];}
	foreach(i;iota(100,blob.data.length,3)){
		buttons~=
			button_(
				blob.data[i+0],
				blob.data[i+1],
				blob.data[i+2],);}
	foreach(i;0..100){
		strings[i]=blob.get(i.to!string~":");
	}
}
void main(string[] s){
	if(s.length>1){
		file=s[1];
	} else {
		file="temp";
	}
	input();
	InitWindow(1080, 780, "Hello, Raylib-D!");
	import keys;
	mixin setupdraw!"keys";
	void draw_(button_ b){
		draw(b.which,b.x,b.y,2);
	}
	int tool;
	bool showtool=true;
	while (!WindowShouldClose()){
		BeginDrawing();
		scope(exit) EndDrawing();
		int toolx=GetMouseX;
		int tooly=GetMouseY;
		button_ tooltip=button_(toolx,tooly,tool);
		with(button){
		if(mouse1.pressed){
			buttons~=tooltip;
			output;
		}
		if(mouse2){
			foreach(i;0..buttons.length){
				if(toolx>buttons[i].x&&toolx-32<buttons[i].x){
				if(tooly>buttons[i].y&&tooly-32<buttons[i].y){
					buttons=buttons.remove(i); break;
			}}}
			output;
		}
		if(mouse3.pressed){
			import std.process;
			tool=("./keysselector")
				.executeShell.output[0..$-1].to!int;
		}
		if(alt.pressed){
			showtool= ! showtool;
		}
		
		if(down.pressed){
			selectedtext++;
		}
		if(up.pressed){
			selectedtext--;
		}
		if(left.pressed&&selectedreal){
			offsets[selectedtext]--;
		}
		if(right.pressed&&selectedreal){
			offsets[selectedtext]++;
		}
		if(selectedreal){
			int i=GetCharPressed;
			if(i<255&&i>0){
				strings[selectedtext]~=cast(char)i;
				output;
			}
		}
		if(backspace.pressed&&selectedreal){
			strings[selectedtext]=strings[selectedtext][0..max(cast(int)$-1,0)];
			output;
		}
		if(f1){
			foreach(i;0..50){
				offsets[i]=toolx;
		}}
		if(tab.pressed){pokeselected;}
		foreach(e;buttons){
			draw_(e);
		}
		foreach(i;0..50){
			if(i==selectedtext && showtool){DrawCircle(offsets[i],i*(textsize+2),5,Colors.BLUE);}
			DrawText(strings[i].toStringz,offsets[i],i*(textsize+2),textsize,Colors.WHITE);
		}
		foreach(i;0..50){
			if(i+50==selectedtext && showtool){DrawCircle(offsets[i+50],i*(textsize+2),5,Colors.GREEN);}
			DrawText(strings[i+50].toStringz,offsets[i+50],i*(textsize+2),textsize,Colors.WHITE);
		}
		if(showtool){
			draw_(tooltip);
		}
		ClearBackground(Colors.BLACK);
	}}
	CloseWindow();
}