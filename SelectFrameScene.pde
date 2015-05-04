


class SelectFrameScene extends SceneBase{
	
	final String[] frame_title={"#1","#2","#3","#4"};
	final PVector[] frame_position={new PVector(66,1112),new PVector(316,1140),new PVector(566,1101),new PVector(814,1135)};

	int mframe=4;
	
	Button[] arr_frame_button;
	Button top_button;

	PImage yellow_frame;
	boolean yellow_enable=false;

	UIMovie v_list_button=new UIMovie(g_papplet,"list_export down.mov",true,2,2){
		void reachEnd(){
			// changeToScene(SceneMode.CONFIRM_FRAME);
		}
	};
	UIMovie v_list_people=new UIMovie(g_papplet,"list_export down people.mov",true,2,2){
		void reachEnd(){
			if(iselected_frame>-1) changeToScene(SceneMode.CONFIRM_FRAME);
		}
		@Override
		void pauseAtLoop(){
			println("people pause at loop!!");
		}
	};
	UIMovie v_selection_in=new UIMovie(g_papplet,"list_in_up.mov",true,2,2){
		void reachEnd(){
			selectFrame(0);
			top_button.setEnable(true);
			for(int i=0;i<mframe;++i) arr_frame_button[i].setEnable(true);
		}
	};
	UIMovie[] v_selection_out;


	SelectFrameScene(){
		super();

		arr_frame_button=new Button[mframe];

		for(int i=0;i<mframe;++i){
			final int p=i;
			arr_frame_button[i]=new Button(new PVector(64+253*i,1093+(i==1?50:(i==3?20:0))),new PVector(230,230),pg){		
				void Draw(){
					pg.pushStyle();
					pg.fill(255,80);
					pg.noStroke();
						pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
						pg.textFont(font,14);
						pg.text(frame_title[p],draw_location.x,draw_location.y);
					pg.popStyle();
				}
				void Clicked(){
					selectFrame(p);
				}
			};	
			AddButton(arr_frame_button[i]);
		}

		top_button=new Button(new PVector(231,531),new PVector(618,534),pg){
				void Draw(){
					pg.pushStyle();
					pg.fill(255,0,0,80);
					pg.noStroke();
						pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
						pg.textFont(font,14);
						pg.text("go!",draw_location.x,draw_location.y);
					pg.popStyle();
				}
				void Clicked(){
					goIntoFrame();
				}
		};
		AddButton(top_button);



		v_selection_out=new UIMovie[mframe];
		for(int i=0;i<mframe;++i){
			
			v_selection_out[i]=new UIMovie(g_papplet,"list_out_up_"+(i+1)+".mov",true,0.1,0.1){
				void reachEnd(){
				}
			};
		}

		yellow_frame=loadImage("list_yellow.png");

	}
	void Init(){
		v_list_people.initPlay();
		v_list_button.initPlay();
		v_selection_in.initPlay();

		iselected_frame=-1;

		top_button.setEnable(false);
		for(int i=0;i<mframe;++i) arr_frame_button[i].setEnable(false);
		
	}
	void End(){
		v_list_people.stop();
		v_list_button.stop();
		v_selection_in.stop();
		for(int i=0;i<mframe;++i) v_selection_out[i].stop();
	}
	
	void DrawContent(){
		pg.background(0,0);
		
		v_list_button.drawOnGraph(pg,0,1040);
		
		
		if(iselected_frame<0) v_selection_in.drawOnGraph(pg,0,550);
		else{
			v_selection_out[iselected_frame].drawOnGraph(pg,0,400);
			
			if(yellow_enable){
				pg.pushStyle();
				pg.fill(0,180);
				pg.noStroke();
					for(int i=0;i<mframe;++i){
						if(i==iselected_frame) pg.image(yellow_frame,frame_position[i].x-12,frame_position[i].y-15);
						else pg.rect(frame_position[i].x,frame_position[i].y,189,203);
					}
				pg.popStyle();
			}
		}
		v_list_people.drawOnGraph(pg,0,1040);
	}
	
	void selectFrame(int iframe){
		
		// second click
		if(iframe==iselected_frame){
			goIntoFrame();
			return;	
		} 

		println("Frame #"+iframe);
		iselected_frame=iframe;
		yellow_enable=true;

		v_selection_out[iselected_frame].initPlay();
	}

	void reselectFrame(){
		println("Reselect");

		Init();
	}

	void goIntoFrame(){
		yellow_enable=false;
		for(int i=0;i<mframe;++i) arr_frame_button[i].setEnable(false);
		top_button.setEnable(false);


		v_list_button.setLooped(false);
		v_list_people.setLooped(false);
		v_selection_out[iselected_frame].setLooped(false);	
	}
}