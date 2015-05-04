final float FLASH_LIGHT_INTERVAL=40;
PVector Kinect_Position=new PVector(-480,0);
PVector Kinect_Scale=new PVector(1,1);
float Smile_Weight=10;

class SmileDetectScene extends SceneBase{
	
	Timer smile_timer;
	Timer photo_timer;

	boolean detect_smile=false;
	float photo_time=0;


	float tflash_light;

	HashMap<Integer,TrackedFace> face_map;
	SmileBar smile_bar;

	UIMovie v_camera_notify=new UIMovie(g_papplet,"look.mov",false,0,0){
		void reachEnd(){
			println("start detect!!");
			this.stop();
			startSmileDetect();
		}
	};

	UIMovie v_detect_count=new UIMovie(g_papplet,"count_10.mov",false,0,0){
		void reachEnd(){
			// flash light and save image
			if(tflash_light<=0) tflash_light=FLASH_LIGHT_INTERVAL;
			// changeToScene(SceneMode.PREVIEW_PHOTO);
		}
	};
	

	SmileDetectScene(){
		super();
		face_map=new HashMap<Integer,TrackedFace>();
		smile_bar=new SmileBar();
	}
	void Init(){
		
		detect_smile=false;

		
		
		// pg.background(0);
		photo_time=0;
		face_map.clear();
		
		v_camera_notify.initPlay();

		tflash_light=-FLASH_LIGHT_INTERVAL;

		
		smile_bar.Init();

		if(iselected_frame>-1){
			// if(arr_frame_movie[iselected_frame].istage==0) arr_frame_movie[iselected_frame].initPlay();	
			if(arr_frame_movie[0].istage==0) arr_frame_movie[0].initPlay();	
		} 

	}
	void End(){
		v_camera_notify.stop();
		v_detect_count.stop();

		if(iselected_frame>-1){
			// arr_frame_movie[iselected_frame].stop();
			// arr_frame_movie[iselected_frame+1].stop();
			// arr_frame_movie[iselected_frame+2].stop();
			arr_frame_movie[0].stop();
			arr_frame_movie[1].stop();
			arr_frame_movie[2].stop();
		}
	}
	
	void DrawContent(){

		pg.background(0,0);

		if(iselected_frame>-1){
			// arr_frame_movie[iselected_frame].drawOnGraph(pg,0,0);
			arr_frame_movie[0].drawOnGraph(pg,0,0);
			if(smile_bar.smile_score>30){
				// if(!arr_frame_movie[iselected_frame+1].isplaying) arr_frame_movie[iselected_frame+1].initPlay();
				if(!arr_frame_movie[1].isplaying) arr_frame_movie[1].initPlay();
				arr_frame_movie[1].drawOnGraph(pg,0,0);
			}
			if(smile_bar.smile_score>60){
				// if(!arr_frame_movie[iselected_frame+2].isplaying) arr_frame_movie[iselected_frame+2].initPlay();
				if(!arr_frame_movie[2].isplaying && arr_frame_movie[1].istage==2) arr_frame_movie[2].initPlay();
				arr_frame_movie[2].drawOnGraph(pg,0,0);				
			}
		}

		v_camera_notify.drawOnGraph(pg,0,270);
		v_detect_count.drawOnGraph(pg,0,0);
		
		
		if(DEBUG_MODE) drawKinectRegion(pg);

		if(detect_smile || DEBUG_MODE){
			
			smile_bar.drawOnGraph(pg,351,36);
			
			if(detect_smile && DEBUG_MODE) 
				if(random(4)<1) smile_bar.addSmileScore(.2*Smile_Weight);

			for(TrackedFace face:face_map.values()){
				face.drawDebug();
				smile_bar.addSmileScore(.1*Smile_Weight);
			}
			
			for(Integer fkey:face_map.keySet()){
				TrackedFace face=face_map.get(fkey);
				if(face.hasLostTrack()) face_map.remove(fkey);
			}
			
		}





		if(tflash_light>0){
			pg.pushStyle();
			pg.fill(255,constrain(tflash_light,0,FLASH_LIGHT_INTERVAL*.6)/(FLASH_LIGHT_INTERVAL*.6)*255);
				pg.rect(0,0,width,height);
			pg.popStyle();
			tflash_light--;
			
			// println(tflash_light);

			if(tflash_light==0){
				// println("!! flash light end!");

				prepareSaveImage((int)random(4),(int)random(3));

				changeToScene(SceneMode.PREVIEW_PHOTO);
			}
		}
		



	}
	void startSmileDetect(){

	
		v_detect_count.initPlay();	
		detect_smile=true;

		smile_timer=new Timer();
		smile_timer.schedule(new TimerTask(){
				@Override
				public void run(){
					endSmileDetect();
				}
		}, 7000);

		
	
	}
	void endSmileDetect(){
		detect_smile=false;
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

		smile_bar.addSmileScore(is_happy*Smile_Weight);

	}
	void addFace(int tracking_id,PVector face_pos,PVector face_size,float is_happy){
		println("add new face: "+tracking_id);
		face_map.put(tracking_id,new TrackedFace(face_pos,face_size,is_happy));
	}
}