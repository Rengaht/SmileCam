class SleepScene extends SceneBase{
	
	// Button start_button=new Button(new PVector(200,865),new PVector(680,156),pg){
	Button start_button=new Button(new PVector(0,0),new PVector(width,height),pg){

		void Draw(){
			pg.pushStyle();
			pg.fill(255,80);
			pg.noStroke();
				pg.rect(touch_location.x,touch_location.y,touch_sizee.x,touch_sizee.y);
				pg.textFont(font,14);
				pg.text("start",draw_location.x,draw_location.y);
			pg.popStyle();
		}
		void Clicked(){
			// println("Clicked!");
			this.setEnable(false);
			v_start_button.setLooped(false);
		}
	};

	UIMovie v_start_button=new UIMovie(g_papplet,"standby.mov",true,0,3){
		void reachEnd(){
			changeToScene(SceneMode.CLAIM);
		}
	};

	SleepScene(){
		super();
		AddButton(start_button);

		
	}
	void Init(){
		v_start_button.initPlay();
		start_button.setEnable(true);
	}
	void End(){
		v_start_button.stop();
	}
	
	void DrawContent(){
		pg.background(0,0);

		// for(int i=0;i<6;++i)
		// 	pg.image(happy_image,(width-200)/6*i+100,(height-happy_image.height)*abs(sin((float)frameCount/20+i)));

		v_start_button.drawOnGraph(pg,0,810);
	}
	
}