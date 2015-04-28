class ConfirmScene extends SceneBase{

	Button reselect_button;
	Button continue_button;

	UIMovie v_confirm_button=new UIMovie(g_papplet,"next.mov",true,0.6,0.6){
		void reachEnd(){
			changeToScene(SceneMode.SMILE_DETECT);
		}

		@Override
		void pauseAtLoop(){
			reselect_button.setEnable(true);
			continue_button.setEnable(true);
		}
	};

	ConfirmScene(){
		super();
		

		reselect_button=new Button(new PVector(205,840),new PVector(250,250),pg){		
		void Draw(){
				pg.pushStyle();
				pg.fill(255,80);
				pg.noStroke();
					pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
					pg.textFont(font,14);
					pg.text("NONONO",draw_location.x,draw_location.y);
				pg.popStyle();
			}
			void Clicked(){
				continue_button.setEnable(false);
				reselect_button.setEnable(false);
		
				changeToScene(SceneMode.SELECT_FRAME);
			}
		};	
		AddButton(reselect_button);

		continue_button=new Button(new PVector(625,840),new PVector(250,250),pg){		
			void Draw(){
				pg.pushStyle();
				pg.fill(255,0,0,80);
				pg.noStroke();
					pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
					pg.textFont(font,32);
					pg.text("GO!",draw_location.x,draw_location.y);
				pg.popStyle();
			}
			void Clicked(){
				// changeToScene(SceneMode.SMILE_DETECT);
				continue_button.setEnable(false);
				reselect_button.setEnable(false);
		
				v_confirm_button.setLooped(false);
			}
		};	
		AddButton(continue_button);
		
	}
	void Init(){
		v_confirm_button.initPlay();
		continue_button.setEnable(false);
		reselect_button.setEnable(false);

	}
	void End(){
		v_confirm_button.stop();
	}
	
	void DrawContent(){
		pg.background(0,0);

		v_confirm_button.drawOnGraph(pg,0,760);
	}
	
}