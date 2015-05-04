class FrameAnimation{
	
	float ani_t,ani_vel;
	float delay_fr;

	float start_pos,end_pos;

	boolean ani_start=false;
	

	FrameAnimation(float set_length){
		this(set_length,0);
	}
	FrameAnimation(float set_length,float set_delay){
		// total_length=set_length;
		ani_vel=1.0/set_length;
		delay_fr=set_delay;

		// start_pos=set_start;
		// end_pos=set_end;

		Reset();
	}
	void Start(){
		ani_start=true;
	}
	float GetPos(){
		Update();
		// return lerp(start_pos,end_pos,constrain(ani_t,0,1));
		return constrain(sin(ani_t*(HALF_PI)),0,1);
	}
	void Update(){
		if(ani_start)
			if(ani_t<1) ani_t+=ani_vel;
	}
	void Reset(){
		ani_start=false;
		ani_t=-delay_fr*ani_vel;
		// Start();
	}
	void Restart(){
		Reset();
		Start();
	}

}