final float TIME_DIFF_THRES=.075;

abstract class UIMovie extends AlphaMovie{
	
	float loop_start_time;
	float loop_end_time;
	
	boolean isplaying=false;

	private boolean looped=false;
	private boolean cur_looped;

	private boolean flag_stop=false; // start at loop point, i.e. start_time==end_time
	boolean loop_at_end=false;

	private boolean flag_jumped=false; // trigger loop pause once
	private boolean flag_end=false; // trigger reachEnd once

	

	UIMovie(PApplet parent,String filename,boolean set_looped,float start_time,float end_time){

		super(parent,filename);

		looped=set_looped;
		cur_looped=set_looped;

		loop_start_time=start_time;
		loop_end_time=end_time;

		if(loop_start_time==loop_end_time) flag_stop=true;

		isplaying=false;
	}

	void read(){
		if(this.available()) super.read();

		// println(this.time());

		if(this.time()==this.duration() && !flag_end){
			reachEnd();	
			flag_end=true;
			// isplaying=false;
		} 

		if(!cur_looped) return;

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
		cur_looped=set_looped;

		if(flag_stop){
			if(cur_looped) this.pause();
			else this.play();
		}
	}
	void drawOnGraph(PGraphics pg,float x_,float y_){
		this.read();
		pg.image(this,x_,y_);
	}
	void initPlay(){
		
		if(looped) cur_looped=true;

		flag_jumped=false;
		flag_end=false;
		
		this.jump(0);
		this.play();

		isplaying=true;
	}
	void stop(){
		super.stop();
		this.jump(0);

		isplaying=false;
	}
	abstract public void reachEnd();
	public void pauseAtLoop(){}
}