final int MLOST_FRAME=3;




class TrackedFace{
	PVector position,sizee;
	float cur_happy;
	float happy_score;
	int mlost_track;

	TrackedFace(PVector position_,PVector size_,float happy_){
		position=position_;
		sizee=size_;
		cur_happy=happy_;
		happy_score=0;
		mlost_track=0;
	}
	void drawDebug(){
		
		if(mlost_track>0) return;

		pushMatrix();
		translate(position.x,position.y);
			if(cur_happy>0.5) image(smile_image[2],0,0);
			else if(cur_happy>0.2) image(smile_image[1],0,0);
			else image(smile_image[0],0,0);

			// text(happy_score,0,0);
			if(DEBUG_MODE){
				pushStyle();
				stroke(255,0,0);
				noFill();
					rect(0,0,sizee.x,sizee.y);
				popStyle();
			}
		popMatrix();
	}

	void updateHappyScore(float score){
		cur_happy=score;
		// happy_score+=score;
	}

	void updateGeometry(PVector pos_,PVector sizee_){
		if(pos_.x==0 && pos_.y==0){
			mlost_track++;
			// return;
		}else{
			mlost_track=0;
		}
		PVector scaled_pos=pos_.get();
		scaled_pos.x*=Kinect_Scale.x;
		scaled_pos.y*=Kinect_Scale.y;
		
		scaled_pos.add(Kinect_Position);
		position=scaled_pos;

		sizee=sizee_.get();
		sizee.x*=Kinect_Scale.x;
		sizee.y*=Kinect_Scale.y;
		

	}
	
	boolean hasLostTrack(){
		return mlost_track>MLOST_FRAME;
	}


}