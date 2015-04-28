abstract class SceneBase{
	ArrayList<Button> button_list;
	PGraphics pg;
	SceneBase(){
		pg=createGraphics(width,height,P3D);
		button_list=new ArrayList<Button>();
	}
	void draw(){
		pg.beginDraw();
			DrawContent();
			if(DEBUG_MODE){
				for(Button b:button_list){
					if(b.enable) b.Draw();
				}
			}
		pg.endDraw();
	}
	abstract void DrawContent();
	abstract void Init();
	abstract void End();
	void HandleMousePressed(float mouse_x,float mouse_y){
		for(Button b:button_list){
			if(b.enable) b.checkClicked(new PVector(mouse_x,mouse_y));
		}
	}
	void AddButton(Button b){
		button_list.add(b);
	}
}

abstract class Button{
	PVector draw_location;
	PVector touch_location,touch_sizee;
	PGraphics pg;
	boolean enable;



	Button(PVector dloc_,PVector loc_,PVector sizee_,PGraphics pg_){
		draw_location=dloc_;
		touch_location=loc_; touch_sizee=sizee_;
		pg=pg_;
		enable=true;
		Init();
	}
	Button(PVector loc_,PVector sizee_,PGraphics pg_){
		this(loc_.get(),loc_,sizee_,pg_);
	}
	void checkClicked(PVector mouse_pos){
		if( (mouse_pos.x>touch_location.x && mouse_pos.x<touch_location.x+touch_sizee.x)
			&& (mouse_pos.y>touch_location.y && mouse_pos.y<touch_location.y+touch_sizee.y)){
			this.Clicked();
		}
	}
	void setEnable(boolean set_enable){
		enable=set_enable;
	}
	public void Init(){}
	
	abstract void Draw();
	abstract void Clicked();
}