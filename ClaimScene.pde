class ClaimScene extends SceneBase{
	
	Button agree_button=new Button(new PVector(204,1074),new PVector(260,260),pg){
		
		void Draw(){
			pg.pushStyle();
			pg.fill(255,0,0,80);
			pg.noStroke();
				pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
				pg.textFont(font,14);
				pg.text("YES",draw_location.x,draw_location.y);
			pg.popStyle();
		}
		void Clicked(){
			// changeToScene(SceneMode.SELECT_FRAME);
			agree_button.setEnable(false);
			disagree_button.setEnable(false);

			v_claim_back.setLooped(false);
		}
	};

	Button disagree_button=new Button(new PVector(620,1074),new PVector(260,260),pg){
		
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
			agree_button.setEnable(false);
			disagree_button.setEnable(false);

			changeToScene(SceneMode.SLEEP);
		}
	};

	UIMovie v_claim_back=new UIMovie(g_papplet,"notice.mov",true,1.2,1.2){
		void reachEnd(){
			changeToScene(SceneMode.SELECT_FRAME);
		}
		@Override
		void pauseAtLoop(){
			agree_button.setEnable(true);
			disagree_button.setEnable(true);
		}
	};

	
	ClaimScene(){
		super();
		AddButton(agree_button);
		AddButton(disagree_button);

		
	}
	void Init(){
		v_claim_back.initPlay();
		agree_button.setEnable(false);
		disagree_button.setEnable(false);
	}
	void End(){
		v_claim_back.stop();
	}
	
	void DrawContent(){
		pg.background(0,0);

		v_claim_back.drawOnGraph(pg,0,290);

	}
	
}