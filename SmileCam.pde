import oscP5.*;
import netP5.*;
import processing.video.*;
import java.util.HashMap;

import java.util.Timer;
import java.util.TimerTask;


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
float cur_t_camera_size=.5;
float dest_t_camera_size=.5;

/* graphic */
PImage happy_image,unhappy_image;
PFont font;


/* scene */
int mscene=6;
SceneMode cur_scene;
SceneBase[] arr_scene;

PApplet g_papplet;



void setup(){
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


void draw(){
	

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

void drawCameraView(){

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

		if(t_camera_size<1) t_camera_size+=.1;
	}

}
void setCameraViewSize(float set_dest_t){
	if(dest_t_camera_size!=set_dest_t){
		cur_t_camera_size=lerp(cur_t_camera_size,dest_t_camera_size,t_camera_size);
		dest_t_camera_size=set_dest_t;
		t_camera_size=0;
	}
}


void mousePressed(){
	arr_scene[cur_scene.getValue()].HandleMousePressed(mouseX,mouseY);
}
void keyPressed(){
	if(key=='a') DEBUG_MODE=!DEBUG_MODE; 
}

void initNetwork(){
	oscP5 = new OscP5(this,serverPort);
 	// clientRemote = new NetAddress("127.0.0.1",clientPort);
}

void oscEvent(OscMessage message) {
	
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


void sendMessage(){
	OscMessage myMessage = new OscMessage("/test");
	myMessage.add(123); 
	oscP5.send(myMessage, clientRemote); 
}


void initCamera(){
	
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



void initGraphicData(){

	happy_image=loadImage("happy.png");
	unhappy_image=loadImage("unhappy.png");

	
	font=loadFont("Consolas-14.vlw");
	textFont(font, 14);
}