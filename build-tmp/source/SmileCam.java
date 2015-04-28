import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import processing.video.*; 
import java.util.HashMap; 
import java.util.Timer; 
import java.util.TimerTask; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SmileCam extends PApplet {










boolean DEBUG_MODE=true;

/* network */
final int serverPort=7000;
final int clientPort=12000;

OscP5 oscP5;
NetAddress clientRemote;

/* cam */
boolean cam_ready=false;
Capture capture_cam;

float t_camera_size=0;
float cur_t_camera_size=.5f;
float dest_t_camera_size=.5f;

/* graphic */
PImage happy_image,unhappy_image;
PFont font;


/* scene */
int mscene=6;
SceneMode cur_scene;
SceneBase[] arr_scene;

PApplet g_papplet;



public void setup(){
	size(1080,1920,P3D);
	initNetwork();
	initCamera();	

	initGraphicData();
	
	g_papplet=this;
		

	arr_scene=new SceneBase[mscene];
	arr_scene[0]=new SleepScene();
	arr_scene[1]=new ClaimScene();
	arr_scene[2]=new SelectFrameScene();
	arr_scene[3]=new ConfirmScene();
	arr_scene[4]=new SmileDetectScene();
	arr_scene[5]=new PreviewScene();
	

	initScene(SceneMode.SLEEP);


}


public void draw(){
	

	background(0);
	drawCameraView();


	try{
		arr_scene[cur_scene.getValue()].draw();
		image(arr_scene[cur_scene.getValue()].pg,0,0);
	}catch(Exception e){
		println(e);
	}

	
	if(DEBUG_MODE){
		pushStyle();
		stroke(255);
		// textSize(16);
			text("fps="+String.valueOf(frameRate),10,20);
		popStyle();
	}

}

public void drawCameraView(){

	if(cam_ready){
		if(capture_cam.available()){
		    capture_cam.read();
		    capture_cam.loadPixels();
		}
		pushMatrix();
		translate(width,0);
		rotate(PI/2);
		translate(height,0);
		scale(-1,1);
			float cur_t_size=cur_t_camera_size+(dest_t_camera_size-cur_t_camera_size)*sin(HALF_PI*t_camera_size);
			//lerp(cur_t_camera_size,dest_t_camera_size,t_camera_size);
			image(capture_cam,0,0,height*cur_t_size,width*cur_t_size);
		popMatrix();

		if(t_camera_size<1) t_camera_size+=.1f;
	}

}
public void setCameraViewSize(float set_dest_t){
	if(dest_t_camera_size!=set_dest_t){
		cur_t_camera_size=lerp(cur_t_camera_size,dest_t_camera_size,t_camera_size);
		dest_t_camera_size=set_dest_t;
		t_camera_size=0;
	}
}


public void mousePressed(){
	arr_scene[cur_scene.getValue()].HandleMousePressed(mouseX,mouseY);
}
public void keyPressed(){
	if(key=='a') DEBUG_MODE=!DEBUG_MODE; 
}

public void initNetwork(){
	oscP5 = new OscP5(this,serverPort);
 	// clientRemote = new NetAddress("127.0.0.1",clientPort);
}

public void oscEvent(OscMessage message) {
	
	if(cur_scene!=SceneMode.SMILE_DETECT) return;


	print("### received an osc message.");
	print(" addrpattern: "+message.addrPattern());
	println(" typetag: "+message.typetag());
	String addr=message.addrPattern();

	if(!addr.equals("/face")) return;

	Integer tracking_id=new Integer(message.get(0).intValue());  
	float is_happy=message.get(1).floatValue();
	PVector face_pos=new PVector(message.get(2).floatValue(),message.get(3).floatValue());
	PVector face_size=new PVector(message.get(4).floatValue(),message.get(5).floatValue());
	println(tracking_id+" "+is_happy+" "+face_pos+" "+face_size);

	((SmileDetectScene)arr_scene[cur_scene.getValue()]).updateFace(tracking_id,face_pos,face_size,is_happy);
}


public void sendMessage(){
	OscMessage myMessage = new OscMessage("/test");
	myMessage.add(123); 
	oscP5.send(myMessage, clientRemote); 
}


public void initCamera(){
	
	String[] cameras=Capture.list();
  	if(cameras.length==0){
	    println("There are no cameras available for capture.");
	    return;
	}
	    // println("Available cameras:");
	    // for (int i = 0; i < cameras.length; i++) {
	    //   println(cameras[i]);
 	   // }
    capture_cam=new Capture(this, height,width);
    capture_cam.start();     
 	cam_ready=true;
}



public void initGraphicData(){

	happy_image=loadImage("happy.png");
	unhappy_image=loadImage("unhappy.png");

	
	font=loadFont("Consolas-14.vlw");
	textFont(font, 14);
}
class ClaimScene extends SceneBase{
	
	Button agree_button=new Button(new PVector(204,1074),new PVector(260,260),pg){
		
		public void Draw(){
			pg.pushStyle();
			pg.fill(255,0,0,80);
			pg.noStroke();
				pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
				pg.textFont(font,14);
				pg.text("YES",draw_location.x,draw_location.y);
			pg.popStyle();
		}
		public void Clicked(){
			// changeToScene(SceneMode.SELECT_FRAME);
			agree_button.setEnable(false);
			disagree_button.setEnable(false);

			v_claim_back.setLooped(false);
		}
	};

	Button disagree_button=new Button(new PVector(620,1074),new PVector(260,260),pg){
		
		public void Draw(){
			pg.pushStyle();
			pg.fill(255,80);
			pg.noStroke();
				pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
				pg.textFont(font,14);
				pg.text("NONONO",draw_location.x,draw_location.y);
			pg.popStyle();
		}
		public void Clicked(){
			agree_button.setEnable(false);
			disagree_button.setEnable(false);

			changeToScene(SceneMode.SLEEP);
		}
	};

	UIMovie v_claim_back=new UIMovie(g_papplet,"notice.mov",true,1.2f,1.2f){
		public void reachEnd(){
			changeToScene(SceneMode.SELECT_FRAME);
		}
		public @Override
		void pauseAtLoop(){
			agree_button.setEnable(true);
			disagree_button.setEnable(true);
		}
	};

	
	ClaimScene(){
		super();
		AddButton(agree_button);
		AddButton(disagree_button);

		
	}
	public void Init(){
		v_claim_back.initPlay();
		agree_button.setEnable(false);
		disagree_button.setEnable(false);
	}
	public void End(){
		v_claim_back.stop();
	}
	
	public void DrawContent(){
		pg.background(0,0);

		v_claim_back.drawOnGraph(pg,0,290);

	}
	
}
class ConfirmScene extends SceneBase{

	Button reselect_button;
	Button continue_button;

	UIMovie v_confirm_button=new UIMovie(g_papplet,"next.mov",true,0.6f,0.6f){
		public void reachEnd(){
			changeToScene(SceneMode.SMILE_DETECT);
		}

		public @Override
		void pauseAtLoop(){
			reselect_button.setEnable(true);
			continue_button.setEnable(true);
		}
	};

	ConfirmScene(){
		super();
		

		reselect_button=new Button(new PVector(205,840),new PVector(250,250),pg){		
		public void Draw(){
				pg.pushStyle();
				pg.fill(255,80);
				pg.noStroke();
					pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
					pg.textFont(font,14);
					pg.text("NONONO",draw_location.x,draw_location.y);
				pg.popStyle();
			}
			public void Clicked(){
				continue_button.setEnable(false);
				reselect_button.setEnable(false);
		
				changeToScene(SceneMode.SELECT_FRAME);
			}
		};	
		AddButton(reselect_button);

		continue_button=new Button(new PVector(625,840),new PVector(250,250),pg){		
			public void Draw(){
				pg.pushStyle();
				pg.fill(255,0,0,80);
				pg.noStroke();
					pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
					pg.textFont(font,32);
					pg.text("GO!",draw_location.x,draw_location.y);
				pg.popStyle();
			}
			public void Clicked(){
				// changeToScene(SceneMode.SMILE_DETECT);
				continue_button.setEnable(false);
				reselect_button.setEnable(false);
		
				v_confirm_button.setLooped(false);
			}
		};	
		AddButton(continue_button);
		
	}
	public void Init(){
		v_confirm_button.initPlay();
		continue_button.setEnable(false);
		reselect_button.setEnable(false);

	}
	public void End(){
		v_confirm_button.stop();
	}
	
	public void DrawContent(){
		pg.background(0,0);

		v_confirm_button.drawOnGraph(pg,0,760);
	}
	
}


class PreviewScene extends SceneBase{
	
	Timer wait_timer;

	UIMovie v_qrcode_count=new UIMovie(g_papplet,"count_20.mov",false,0,0){
		public void reachEnd(){
			changeToScene(SceneMode.SLEEP);
		}
	};

	PreviewScene(){
		super();
		
	}
	public void Init(){
		wait_timer=new Timer();
		wait_timer.schedule(new TimerTask(){
				@Override
				public void run(){
					// changeToScene(SceneMode.SLEEP);
				}
			}, 3000);

		v_qrcode_count.initPlay();
	}
	public void End(){
		v_qrcode_count.stop();
	}
	
	public void DrawContent(){
		pg.background(0,0);
		
		v_qrcode_count.drawOnGraph(pg,0,0);		
	}	
	
}
abstract class SceneBase{
	ArrayList<Button> button_list;
	PGraphics pg;
	SceneBase(){
		pg=createGraphics(width,height,P3D);
		button_list=new ArrayList<Button>();
	}
	public void draw(){
		pg.beginDraw();
			DrawContent();
			if(DEBUG_MODE){
				for(Button b:button_list){
					if(b.enable) b.Draw();
				}
			}
		pg.endDraw();
	}
	public abstract void DrawContent();
	public abstract void Init();
	public abstract void End();
	public void HandleMousePressed(float mouse_x,float mouse_y){
		for(Button b:button_list){
			if(b.enable) b.checkClicked(new PVector(mouse_x,mouse_y));
		}
	}
	public void AddButton(Button b){
		button_list.add(b);
	}
}

abstract class Button{
	PVector draw_location;
	PVector touch_location,touch_sizee;
	PGraphics pg;
	boolean enable;



	Button(PVector dloc_,PVector loc_,PVector sizee_,PGraphics pg_){
		draw_location=dloc_;
		touch_location=loc_; touch_sizee=sizee_;
		pg=pg_;
		enable=true;
		Init();
	}
	Button(PVector loc_,PVector sizee_,PGraphics pg_){
		this(loc_.get(),loc_,sizee_,pg_);
	}
	public void checkClicked(PVector mouse_pos){
		if( (mouse_pos.x>touch_location.x && mouse_pos.x<touch_location.x+touch_sizee.x)
			&& (mouse_pos.y>touch_location.y && mouse_pos.y<touch_location.y+touch_sizee.y)){
			this.Clicked();
		}
	}
	public void setEnable(boolean set_enable){
		enable=set_enable;
	}
	public void Init(){}
	
	public abstract void Draw();
	public abstract void Clicked();
}

public void initScene(SceneMode iscene){
	
	arr_scene[iscene.getValue()].Init();


	// delay to ensure movies already init
	final SceneMode set_scene=iscene;
	Timer change_timer=new Timer();
	change_timer.schedule(new TimerTask(){
		@Override
		public void run(){
			cur_scene=set_scene;	
			if(cur_scene==SceneMode.SLEEP) setCameraViewSize(.5f);
			else setCameraViewSize(1);
		}
	}, 10);
	
}

public void changeToScene(SceneMode new_scene){
	
	// close current scene
	int imode=cur_scene.getValue();
	println("change to : "+imode+" "+new_scene.toString());
	arr_scene[imode].End();


	
	// transfer to new scene
	initScene(new_scene);


}

class SelectFrameScene extends SceneBase{
	
	final String[] frame_title={"#1","#2","#3","#4"};
	final PVector[] frame_position={new PVector(66,1112),new PVector(316,1140),new PVector(566,1101),new PVector(814,1135)};

	int mframe=4;
	int iselected_frame=-1;
	Button[] arr_frame_button;
	Button top_button;

	PImage yellow_frame;
	boolean yellow_enable=false;

	UIMovie v_list_button=new UIMovie(g_papplet,"list_export down.mov",true,2,2){
		public void reachEnd(){
			// changeToScene(SceneMode.CONFIRM_FRAME);
		}
	};
	UIMovie v_list_people=new UIMovie(g_papplet,"list_export down people.mov",true,2,2){
		public void reachEnd(){
			changeToScene(SceneMode.CONFIRM_FRAME);
		}
		public @Override
		void pauseAtLoop(){
			println("people pause at loop!!");
		}
	};
	UIMovie v_selection_in=new UIMovie(g_papplet,"list_in_up.mov",true,2,2){
		public void reachEnd(){
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
				public void Draw(){
					pg.pushStyle();
					pg.fill(255,80);
					pg.noStroke();
						pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
						pg.textFont(font,14);
						pg.text(frame_title[p],draw_location.x,draw_location.y);
					pg.popStyle();
				}
				public void Clicked(){
					selectFrame(p);
				}
			};	
			AddButton(arr_frame_button[i]);
		}

		top_button=new Button(new PVector(231,531),new PVector(618,534),pg){
				public void Draw(){
					pg.pushStyle();
					pg.fill(255,0,0,80);
					pg.noStroke();
						pg.rect(draw_location.x,draw_location.y,touch_sizee.x,touch_sizee.y);
						pg.textFont(font,14);
						pg.text("go!",draw_location.x,draw_location.y);
					pg.popStyle();
				}
				public void Clicked(){
					goIntoFrame();
				}
		};
		AddButton(top_button);



		v_selection_out=new UIMovie[mframe];
		for(int i=0;i<mframe;++i){
			
			v_selection_out[i]=new UIMovie(g_papplet,"list_out_up_"+(i+1)+".mov",true,0.1f,0.1f){
				public void reachEnd(){
				}
			};
		}

		yellow_frame=loadImage("list_yellow.png");

	}
	public void Init(){
		v_list_people.initPlay();
		v_list_button.initPlay();
		v_selection_in.initPlay();

		iselected_frame=-1;

		top_button.setEnable(false);
		for(int i=0;i<mframe;++i) arr_frame_button[i].setEnable(false);
		
	}
	public void End(){
		v_list_people.stop();
		v_list_button.stop();
		v_selection_in.stop();
		for(int i=0;i<mframe;++i) v_selection_out[i].stop();
	}
	
	public void DrawContent(){
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
	
	public void selectFrame(int iframe){
		
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

	public void reselectFrame(){
		println("Reselect");

		Init();
	}

	public void goIntoFrame(){
		yellow_enable=false;
		for(int i=0;i<mframe;++i) arr_frame_button[i].setEnable(false);
		top_button.setEnable(false);


		v_list_button.setLooped(false);
		v_list_people.setLooped(false);
		v_selection_out[iselected_frame].setLooped(false);	
	}
}
class SleepScene extends SceneBase{
	
	// Button start_button=new Button(new PVector(200,865),new PVector(680,156),pg){
	Button start_button=new Button(new PVector(0,0),new PVector(width,height),pg){

		public void Draw(){
			pg.pushStyle();
			pg.fill(255,80);
			pg.noStroke();
				pg.rect(touch_location.x,touch_location.y,touch_sizee.x,touch_sizee.y);
				pg.textFont(font,14);
				pg.text("start",draw_location.x,draw_location.y);
			pg.popStyle();
		}
		public void Clicked(){
			// println("Clicked!");
			this.setEnable(false);
			v_start_button.setLooped(false);
		}
	};

	UIMovie v_start_button=new UIMovie(g_papplet,"standby.mov",true,0,2.25f){
		public void reachEnd(){
			changeToScene(SceneMode.CLAIM);
		}
	};

	SleepScene(){
		super();
		AddButton(start_button);

		
	}
	public void Init(){
		v_start_button.initPlay();
		start_button.setEnable(true);
	}
	public void End(){
		v_start_button.stop();
	}
	
	public void DrawContent(){
		pg.background(0,0);

		// for(int i=0;i<6;++i)
		// 	pg.image(happy_image,(width-200)/6*i+100,(height-happy_image.height)*abs(sin((float)frameCount/20+i)));

		v_start_button.drawOnGraph(pg,0,810);
	}
	
}
final float FLASH_LIGHT_INTERVAL=40;

class SmileDetectScene extends SceneBase{
	
	Timer smile_timer;
	Timer photo_timer;

	boolean detct_finish=false;
	float photo_time=0;


	float tflash_light;

	HashMap<Integer,TrackedFace> face_map;

	UIMovie v_camera_notify=new UIMovie(g_papplet,"look.mov",false,0,0){
		public void reachEnd(){
			println("start detect!!");
			this.stop();
			v_detect_count.initPlay();	
		}
	};

	UIMovie v_detect_count=new UIMovie(g_papplet,"count_10.mov",false,0,0){
		public void reachEnd(){
			// flash light and save image
			if(tflash_light<=0) tflash_light=FLASH_LIGHT_INTERVAL;
			// changeToScene(SceneMode.PREVIEW_PHOTO);
		}
	};

	UIMovie v_bar=new UIMovie(g_papplet,"bar.mov",false,0,0){
		public void reachEnd(){

		}
	};

	SmileDetectScene(){
		super();
		face_map=new HashMap<Integer,TrackedFace>();

	}
	public void Init(){
		
		detct_finish=false;

		smile_timer=new Timer();
		smile_timer.schedule(new TimerTask(){
				@Override
				public void run(){
					endSmileDetect();
				}
			}, 7000);
		
		
		// pg.background(0);
		photo_time=0;
		face_map.clear();
		
		v_camera_notify.initPlay();

		tflash_light=-FLASH_LIGHT_INTERVAL;
	}
	public void End(){
		v_camera_notify.stop();
		v_detect_count.stop();
	}
	
	public void DrawContent(){

		pg.background(0,0);

		if(!detct_finish){
			// if(random(10)>1) return;
			// pg.image(unhappy_image,random(width),random(height));
			
		}else{
			// pg.image(unhappy_image,width/2-photo_time/2,height/2-photo_time/2,photo_time,photo_time);
			// photo_time+=photo_time/20+10;
		}

		v_camera_notify.drawOnGraph(pg,0,270);
		v_detect_count.drawOnGraph(pg,0,0);



		for(TrackedFace face:face_map.values()){
			face.drawDebug();
		}
		for(Integer fkey:face_map.keySet()){
			TrackedFace face=face_map.get(fkey);
			if(face.hasLostTrack()) face_map.remove(fkey);
		}


		if(tflash_light>=0){
			pg.pushStyle();
			pg.fill(255,constrain(tflash_light,0,FLASH_LIGHT_INTERVAL*.6f)/(FLASH_LIGHT_INTERVAL*.6f)*255);
				pg.rect(0,0,width,height);
			pg.popStyle();
			tflash_light--;
			
			// println(tflash_light);

			if(tflash_light<=0){
				// println("!! flash light end!");
				changeToScene(SceneMode.PREVIEW_PHOTO);
			}
		}
		
	}
	public void endSmileDetect(){
		detct_finish=true;
		// photo_timer=new Timer();
		// photo_timer.schedule(new TimerTask(){
		// 		@Override
		// 		public void run(){
		// 			// TODO: take picture

		// 			// changeToScene(SceneMode.PREVIEW_PHOTO);
		// 		}
		// 	}, 3000);
	}
	public void updateFace(int tracking_id,PVector face_pos,PVector face_size,float is_happy){

		if(face_map.containsKey(tracking_id)){
			println("update face: "+tracking_id);
			TrackedFace face=face_map.get(tracking_id);
			face.updateGeometry(face_pos,face_size);
			face.updateHappyScore(is_happy);

		}else{
			println("add new face: "+tracking_id);
			addFace(tracking_id,face_pos,face_size,is_happy);
		}

	}
	public void addFace(int tracking_id,PVector face_pos,PVector face_size,float is_happy){
		println("add new face: "+tracking_id);
		face_map.put(tracking_id,new TrackedFace(face_pos,face_size,is_happy));
	}
}
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
	public void drawDebug(){
		
		if(mlost_track>0) return;

		pushMatrix();
		translate(position.x,position.y);
			if(cur_happy>0.2f) image(happy_image,0,0);
			else image(unhappy_image,0,0);

			text(happy_score,0,0);
		popMatrix();
	}
	public void updateHappyScore(float score){
		cur_happy=score;
		happy_score+=score;
	}
	public void updateGeometry(PVector pos_,PVector sizee_){
		if(pos_.x==0 && pos_.y==0){
			mlost_track++;
			// return;
		}else{
			mlost_track=0;
		}
		position=pos_.get(); sizee=sizee_.get();
	}
	
	public boolean hasLostTrack(){
		return mlost_track>MLOST_FRAME;
	}



}
final float TIME_DIFF_THRES=.075f;

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

	public void read(){
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
	public void setLooped(boolean set_looped){
		looped=set_looped;

		if(flag_stop){
			if(looped) this.pause();
			else this.play();
		}
	}
	public void drawOnGraph(PGraphics pg,float x_,float y_){
		this.read();
		pg.image(this,x_,y_);
	}
	public void initPlay(){
		
		if(loop_start_time!=0 || loop_end_time!=0) looped=true;

		flag_jumped=false;

		this.jump(0);
		this.play();

	}
	public void stop(){
		super.stop();
		this.jump(0);
	}
	abstract public void reachEnd();
	public void pauseAtLoop(){}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SmileCam" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
