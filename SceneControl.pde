
void initScene(SceneMode iscene){
	
	arr_scene[iscene.getValue()].Init();


	// delay to ensure movies already init
	final SceneMode set_scene=iscene;
	Timer change_timer=new Timer();
	change_timer.schedule(new TimerTask(){
		@Override
		public void run(){
			cur_scene=set_scene;	
			if(cur_scene==SceneMode.SLEEP) setCameraViewSize(.5);
			else setCameraViewSize(1);
		}
	}, 10);
	
}

void changeToScene(SceneMode new_scene){
	
	// close current scene
	int imode=cur_scene.getValue();
	println("change to : "+imode+" "+new_scene.toString());
	arr_scene[imode].End();


	
	// transfer to new scene
	initScene(new_scene);


}

