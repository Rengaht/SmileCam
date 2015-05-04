

class PreviewScene extends SceneBase{
	
	Timer wait_timer;
	PImage photo_frame;
	PImage qrcode_frame;
	FrameAnimation photo_ani,qrcode_ani;
	
	boolean qrcode_ready=false;

	Button reset_button=new Button(new PVector(624,1420),new PVector(205,205),pg){
		
		void Draw(){
			pg.pushStyle();
			pg.fill(255,0,0,80);
			pg.noStroke();
				pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
				pg.textFont(font,14);
				pg.text("again",draw_location.x,draw_location.y);
			pg.popStyle();
		}
		void Clicked(){
			changeToScene(SceneMode.SMILE_DETECT);
		}
	};

	UIMovie v_qrcode_count=new UIMovie(g_papplet,"count_20.mov",false,0,0){
		void reachEnd(){
			changeToScene(SceneMode.SLEEP);
		}
	};
	UIMovie v_fly_out=new UIMovie(g_papplet,"end.mov",false,0,0){
		void reachEnd(){
			reset_button.setEnable(true);
		}
	};
	UIMovie v_wait=new UIMovie(g_papplet,"wait.mov",false,0,0){
		void reachEnd(){
			
			println("qrcode ready!");
			
			qrcode_ready=true;

			v_qrcode_count.initPlay();
			v_fly_out.initPlay();

			qrcode_ani.Restart();
			photo_ani.Restart();
		}
	};

	PreviewScene(){
		super();

		AddButton(reset_button);

		photo_frame=loadImage("photo_frame.png");
		qrcode_frame=loadImage("qrcode_frame.png");
		photo_ani=new FrameAnimation(24,12);
		qrcode_ani=new FrameAnimation(15,10);
	}
	void Init(){
		// wait_timer=new Timer();
		// wait_timer.schedule(new TimerTask(){
		// 		@Override
		// 		public void run(){
		// 			// changeToScene(SceneMode.SLEEP);
		// 		}
		// 	}, 3000);

		qrcode_ready=false;

		v_wait.initPlay();
		reset_button.setEnable(false);

	}
	void End(){
		v_qrcode_count.stop();
		v_fly_out.stop();
	}
	
	void DrawContent(){
		pg.background(0,0);
		
		v_wait.drawOnGraph(pg,0,810);
		
		if(!qrcode_ready) return;

		v_qrcode_count.drawOnGraph(pg,0,0);		
		v_fly_out.drawOnGraph(pg,0,0);		

		pg.pushMatrix();
			float cur_photo_pos=lerp(1920,131.74,photo_ani.GetPos());
			pg.translate(366.5,cur_photo_pos);
			pg.rotate(radians(6));
			pg.image(photo_frame,0,0);
			pg.image(save_pg,23,23,621,1104);
		pg.popMatrix();

		pg.pushMatrix();
			float cur_qrcode_pos=lerp(1920,1366,qrcode_ani.GetPos());
			pg.translate(159.6,cur_qrcode_pos);
			pg.rotate(radians(-3));
			pg.image(qrcode_frame,0,0);
			pg.image(qrcode_pg,27,27);
		pg.popMatrix();

	}	
	
}