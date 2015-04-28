enum SceneMode {
	SLEEP(0),
	CLAIM(1),
	SELECT_FRAME(2),
	CONFIRM_FRAME(3),
	SMILE_DETECT(4),
	PREVIEW_PHOTO(5),
	ALL_END(6);

	private final int value;
    SceneMode(int value){
        this.value=value;
    }
    public int getValue(){ return value; }

  

};