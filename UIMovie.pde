final float TIME_DIFF_THRES=.075;

abstract class UIMovie extends AlphaMovie{
	
	float loop_start_time;
	float loop_end_time;
	private boolean looped=false;

	private boolean flag_jumped=false;
	private boolean flag_stop=false;

	UIMovie(PApplet parent,String filename,boolean set_looped,float start_time,float end_time){

		super(parent,filename);

		looped=set_looped;
		loop_start_time=start_time;
		loop_end_time=end_time;

		if(loop_start_time==loop_end_time) flag_stop=true;
	}

	void read(){
		if(this.available()) super.read();

		// println(this.time());

		if(this.time()==this.duration()) reachEnd();

		if(!looped) return;

		if(flag_stop){
			if(!flag_jumped && abs(this.time()-loop_end_time)<TIME_DIFF_THRES ){
				this.pause();
				flag_jumped=true;
				pauseAtLoop();
			}
		}else{

			if(!flag_jumped && abs(this.time()-loop_end_time)<TIME_DIFF_THRES){
				flag_jumped=true;
				this.jump(loop_start_time);			
				// println("Jump to Loop Start!");
			}
			if(flag_jumped && abs(this.time()-loop_start_time)>TIME_DIFF_THRES){
				flag_jumped=false;
			}
		}



	}
	void setLooped(boolean set_looped){
		looped=set_looped;

		if(flag_stop){
			if(looped) this.pause();
			else this.play();
		}
	}
	void drawOnGraph(PGraphics pg,float x_,float y_){
		this.read();
		pg.image(this,x_,y_);
	}
	void initPlay(){
		
		if(loop_start_time!=0 || loop_end_time!=0) looped=true;

		flag_jumped=false;

		this.jump(0);
		this.play();

	}
	void stop(){
		super.stop();
		this.jump(0);
	}
	abstract public void reachEnd();
	public void pauseAtLoop(){}
}