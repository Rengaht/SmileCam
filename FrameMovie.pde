final String[] FRAME_PATH={"frame/FIRE/"};

class FrameMovie{
	
	UIMovie enter_movie;
	// UIMovie loop_movie;
	AlphaMovie loop_movie;
	boolean isplaying=false;

	int istage; // 0: stop, 1: enter, 2: loop
	
	float t_transition=0;

	FrameMovie(int frame_index,int stage_index){
		
		istage=0;
		
		enter_movie=new UIMovie(g_papplet,FRAME_PATH[frame_index]+"F"+nf(stage_index+1,1)+"_1.mov",false,0,0){
			void reachEnd(){
				println("enter_movie stop!");
				loop_movie.loop();
				istage=2;
				t_transition=millis();
			}
		};
		// loop_movie=new UIMovie(g_papplet,FRAME_PATH[frame_index]+"F"+nf(stage_index+1,1)+"_2.mov",true,0,2){
		// 	void reachEnd(){
				
		// 	}
		// };
		loop_movie=new AlphaMovie(g_papplet,FRAME_PATH[frame_index]+"F"+nf(stage_index+1,1)+"_2.mov");
		
	}
	void initPlay(){
		enter_movie.initPlay();
		istage=1;
		isplaying=true;
		// loop_movie.initPlay();
		// loop_movie.pause();
		// loop_movie.jump(0);
	}

	void read(){
		if(istage==1) enter_movie.read();
		else if(istage==2) loop_movie.read();

		// println("enter: "+enter_movie.time()+"  loop"+loop_movie.time());

	}

	void drawOnGraph(PGraphics pg,float x_,float y_){
		this.read();
		if(istage==1) pg.image(enter_movie,x_,y_);
		else if(istage==2){
			if(millis()-t_transition<TIME_DIFF_THRES) pg.image(enter_movie,x_,y_);
			pg.image(loop_movie,x_,y_);	
		} 

	}
	void stop(){
		istage=0;
		enter_movie.stop();
		loop_movie.stop();

		isplaying=false;
		
	}


}



void loadFrameMovie(){

	arr_frame_movie=new FrameMovie[3];
	for(int i=0;i<3;++i) arr_frame_movie[i]=new FrameMovie(0,i);

}

