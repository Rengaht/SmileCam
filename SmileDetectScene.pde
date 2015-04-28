final float FLASH_LIGHT_INTERVAL=40;

class SmileDetectScene extends SceneBase{
	
	Timer smile_timer;
	Timer photo_timer;

	boolean detct_finish=false;
	float photo_time=0;


	float tflash_light;

	HashMap<Integer,TrackedFace> face_map;

	UIMovie v_camera_notify=new UIMovie(g_papplet,"look.mov",false,0,0){
		void reachEnd(){
			println("start detect!!");
			this.stop();
			v_detect_count.initPlay();	
		}
	};

	UIMovie v_detect_count=new UIMovie(g_papplet,"count_10.mov",false,0,0){
		void reachEnd(){
			// flash light and save image
			if(tflash_light<=0) tflash_light=FLASH_LIGHT_INTERVAL;
			// changeToScene(SceneMode.PREVIEW_PHOTO);
		}
	};

	UIMovie v_bar=new UIMovie(g_papplet,"bar.mov",false,0,0){
		void reachEnd(){

		}
	};

	SmileDetectScene(){
		super();
		face_map=new HashMap<Integer,TrackedFace>();

	}
	void Init(){
		
		detct_finish=false;

		smile_timer=new Timer();
		smile_timer.schedule(new TimerTask(){
				@Override
				public void run(){
					endSmileDetect();
				}
			}, 7000);
		
		
		// pg.background(0);
		photo_time=0;
		face_map.clear();
		
		v_camera_notify.initPlay();

		tflash_light=-FLASH_LIGHT_INTERVAL;
	}
	void End(){
		v_camera_notify.stop();
		v_detect_count.stop();
	}
	
	void DrawContent(){

		pg.background(0,0);

		if(!detct_finish){
			// if(random(10)>1) return;
			// pg.image(unhappy_image,random(width),random(height));
			
		}else{
			// pg.image(unhappy_image,width/2-photo_time/2,height/2-photo_time/2,photo_time,photo_time);
			// photo_time+=photo_time/20+10;
		}

		v_camera_notify.drawOnGraph(pg,0,270);
		v_detect_count.drawOnGraph(pg,0,0);



		for(TrackedFace face:face_map.values()){
			face.drawDebug();
		}
		for(Integer fkey:face_map.keySet()){
			TrackedFace face=face_map.get(fkey);
			if(face.hasLostTrack()) face_map.remove(fkey);
		}


		if(tflash_light>=0){
			pg.pushStyle();
			pg.fill(255,constrain(tflash_light,0,FLASH_LIGHT_INTERVAL*.6)/(FLASH_LIGHT_INTERVAL*.6)*255);
				pg.rect(0,0,width,height);
			pg.popStyle();
			tflash_light--;
			
			// println(tflash_light);

			if(tflash_light<=0){
				// println("!! flash light end!");
				changeToScene(SceneMode.PREVIEW_PHOTO);
			}
		}
		
	}
	void endSmileDetect(){
		detct_finish=true;
		// photo_timer=new Timer();
		// photo_timer.schedule(new TimerTask(){
		// 		@Override
		// 		public void run(){
		// 			// TODO: take picture

		// 			// changeToScene(SceneMode.PREVIEW_PHOTO);
		// 		}
		// 	}, 3000);
	}
	void updateFace(int tracking_id,PVector face_pos,PVector face_size,float is_happy){

		if(face_map.containsKey(tracking_id)){
			println("update face: "+tracking_id);
			TrackedFace face=face_map.get(tracking_id);
			face.updateGeometry(face_pos,face_size);
			face.updateHappyScore(is_happy);

		}else{
			println("add new face: "+tracking_id);
			addFace(tracking_id,face_pos,face_size,is_happy);
		}

	}
	void addFace(int tracking_id,PVector face_pos,PVector face_size,float is_happy){
		println("add new face: "+tracking_id);
		face_map.put(tracking_id,new TrackedFace(face_pos,face_size,is_happy));
	}
}