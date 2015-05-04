final String PARAM_FILE="param/smilecam_param.json";

void readParameterFile(){
	
	try{
		JSONObject param_json=loadJSONObject(PARAM_FILE);
		

		Kinect_Position.x=param_json.getFloat("KINECT_X");
		Kinect_Position.y=param_json.getFloat("KINECT_Y");
		Kinect_Scale.x=param_json.getFloat("KINECT_X_SCALE");
		Kinect_Scale.y=param_json.getFloat("KINECT_Y_SCALE");

		Smile_Weight=param_json.getFloat("SMILE_WEIGHT");

	}catch(Exception e){
		saveParameterFile();
	}
}


void saveParameterFile(){
	
	JSONObject param_json=new JSONObject();
	param_json.setFloat("KINECT_X",Kinect_Position.x);
	param_json.setFloat("KINECT_Y",Kinect_Position.y);
	param_json.setFloat("KINECT_X_SCALE",Kinect_Scale.x);
	param_json.setFloat("KINECT_Y_SCALE",Kinect_Scale.y);

	param_json.setFloat("SMILE_WEIGHT",Smile_Weight);

	saveJSONObject(param_json,PARAM_FILE);
}



void drawKinectRegion(PGraphics pg){
	
	pg.pushStyle();
	pg.noFill();
	pg.stroke(255,0,0);
	pg.strokeWeight(3);
		pg.rect(Kinect_Position.x,Kinect_Position.y,height*Kinect_Scale.x,width*Kinect_Scale.y);
	pg.popStyle();

}