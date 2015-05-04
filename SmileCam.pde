import oscP5.*;
import netP5.*;
import processing.video.*;

import java.util.HashMap;
import java.util.Hashtable;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;


import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;



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
PImage[] smile_image;
PFont font,score_font;
PGraphics save_pg,qrcode_pg;

int iselected_frame=-1;
FrameMovie[] arr_frame_movie;


/* scene */
int mscene=6;
SceneMode cur_scene;
SceneBase[] arr_scene;

PApplet g_papplet;



void setup(){
	size(1080,1920,P3D);
	// frameRate(30);
	
	initNetwork();
	initCamera();	

	readParameterFile();

	g_papplet=this;
	initGraphicData();
	
	
		

	arr_scene=new SceneBase[mscene];
	arr_scene[0]=new SleepScene();
	arr_scene[1]=new ClaimScene();
	arr_scene[2]=new SelectFrameScene();
	arr_scene[3]=new ConfirmScene();
	arr_scene[4]=new SmileDetectScene();
	arr_scene[5]=new PreviewScene();
	

	initScene(SceneMode.SLEEP);
	// initScene(SceneMode.SMILE_DETECT);
	// prepareSaveImage((int)random(3),0);
	// initScene(SceneMode.PREVIEW_PHOTO);
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
	if(DEBUG_MODE){
		if(key==CODED){
			switch(keyCode){
				case RIGHT:
					Kinect_Position.x+=.1;
					break;
				case LEFT:
					Kinect_Position.x-=.1;
					break;
				case DOWN:
					Kinect_Position.y+=.1;
					break;
				case UP:
					Kinect_Position.y-=.1;
					break;
			}	
		}
	}
	switch(key){
		case 'a':
			DEBUG_MODE=!DEBUG_MODE; 
			break;
		case 's':
			saveParameterFile();
			break;
		case 'r':
			readParameterFile();
			break;

		
		case 'z':
			Kinect_Scale.x+=.1;
			break;
		case 'x':
			Kinect_Scale.x-=.1;
			break;

		case 'c':
			Kinect_Scale.y+=.1;
			break;
		case 'v':
			Kinect_Scale.y-=.1;
			break;
	}
			
}

void initNetwork(){
	oscP5 = new OscP5(this,serverPort);
 	// clientRemote = new NetAddress("127.0.0.1",clientPort);
}

void oscEvent(OscMessage message) {
	
	if(cur_scene!=SceneMode.SMILE_DETECT) return;


	// print("### received an osc message.");
	// print(" addrpattern: "+message.addrPattern());
	// println(" typetag: "+message.typetag());
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

	smile_image=new PImage[3];
	smile_image[0]=loadImage("smile1.png");
	smile_image[1]=loadImage("smile2.png");
	smile_image[2]=loadImage("smile3.png");
	
	
	font=loadFont("Consolas-14.vlw");
	textFont(font, 14);

	score_font=loadFont("MyriadPro-BoldCond-60.vlw");

	save_pg=createGraphics(width,height);
	qrcode_pg=createGraphics(335,335);

	loadFrameMovie();
}

String createUId(){

	String day_info=nf(year(),4)+nf(month(),2)+nf(day(),2)+"_"+nf(hour(),2)+nf(minute(),2)+nf(second(),2);
	String uid=UUID.randomUUID().toString();

	return day_info+uid;

}
void prepareSaveImage(int iframe,int istage){
	

	save_pg.beginDraw();
	save_pg.clear();
	save_pg.background(0);
	// photo
	save_pg.pushMatrix();
		save_pg.translate(width,0);
		save_pg.rotate(PI/2);
		save_pg.translate(height,0);
		save_pg.scale(-1,1);
			save_pg.image(capture_cam,0,0);
	save_pg.popMatrix();


	// frame
	PImage frame_image=loadImage("frame_"+nf(iframe+1,1)+".png");
	save_pg.image(frame_image,0,0);

	save_pg.endDraw();
	
	createQRcodeImage("hahaha");

	saveImage();

}

void saveImage(){

	println("Save Image!!");
	save_pg.save("created/"+createUId()+".png");

}

