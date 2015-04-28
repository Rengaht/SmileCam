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
			if(cur_happy>0.2) image(happy_image,0,0);
			else image(unhappy_image,0,0);

			text(happy_score,0,0);
		popMatrix();
	}
	void updateHappyScore(float score){
		cur_happy=score;
		happy_score+=score;
	}
	void updateGeometry(PVector pos_,PVector sizee_){
		if(pos_.x==0 && pos_.y==0){
			mlost_track++;
			// return;
		}else{
			mlost_track=0;
		}
		position=pos_.get(); sizee=sizee_.get();
	}
	
	boolean hasLostTrack(){
		return mlost_track>MLOST_FRAME;
	}



}