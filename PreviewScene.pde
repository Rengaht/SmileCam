

class PreviewScene extends SceneBase{
	
	Timer wait_timer;

	UIMovie v_qrcode_count=new UIMovie(g_papplet,"count_20.mov",false,0,0){
		void reachEnd(){
			changeToScene(SceneMode.SLEEP);
		}
	};

	PreviewScene(){
		super();
		
	}
	void Init(){
		wait_timer=new Timer();
		wait_timer.schedule(new TimerTask(){
				@Override
				public void run(){
					// changeToScene(SceneMode.SLEEP);
				}
			}, 3000);

		v_qrcode_count.initPlay();
	}
	void End(){
		v_qrcode_count.stop();
	}
	
	void DrawContent(){
		pg.background(0,0);
		
		v_qrcode_count.drawOnGraph(pg,0,0);		
	}	
	
}