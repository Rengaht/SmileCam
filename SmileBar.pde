class SmileBar{

	PImage bar_top;
	PImage bar_bottom;

	// PGraphics subpg;
	// PShader bar_shader;

	int smile_score;
	float dest_smile_score;

	SmileBar(){
		bar_top=loadImage("bar_2.png");
		bar_bottom=loadImage("bar_1.png");

		// bar_shader=loadShader("bar_shader.glsl");

		// subpg=createGraphics(680,180,P3D);
	}

	void drawOnGraph(PGraphics pg,float dx,float dy){
		pg.pushMatrix();
		pg.translate(dx,dy);

		pg.pushStyle();
		pg.noStroke();

		pg.image(bar_bottom,0,0);


		pg.beginShape();
		pg.texture(bar_top);
			pg.vertex(0,0,0,0);
			pg.vertex(0,180,0,180);
			float draw_length=180+smile_score*5;
			pg.vertex(draw_length,180,draw_length,180);
			pg.vertex(draw_length,0,draw_length,0);
		pg.endShape();

		pg.pushStyle();
		pg.textFont(score_font,60);
		pg.fill(255);
		pg.textAlign(RIGHT,BASELINE);
			pg.pushMatrix();
				pg.translate(160,120);

				pg.pushMatrix();
				pg.scale(1.1,1.5);
					pg.text('%',0,0);
				pg.popMatrix();
				
				float char_pos=pg.textWidth('%')*1.1;
				
				pg.scale(1,1.5);
					String num_str=str(smile_score);
					int num_len=num_str.length();

					
					for(int i=num_len-1;i>=0;--i){
						char num_char=num_str.charAt(i);
						pg.text(num_char,-char_pos,0);
						char_pos+=pg.textWidth(num_char);
					}
			pg.popMatrix();
		pg.popStyle();

		pg.popStyle();

		pg.popMatrix();

		updateSmileScore();
	
	}
	void addSmileScore(){
		addSmileScore(1);
	}
	void addSmileScore(float add_score){
		dest_smile_score=smile_score+add_score;
	}


	void updateSmileScore(){
		if(smile_score<dest_smile_score) smile_score+=1;	
		smile_score=constrain(smile_score,0,100);
	}

	void Init(){
		smile_score=0;
		dest_smile_score=0;
	}

}