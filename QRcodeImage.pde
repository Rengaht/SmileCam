
final int QRCODE_WIDTH=335;

void createQRcodeImage(String qrcode_url){
	
    String myCodeText=qrcode_url;
    
    try{
        Hashtable<EncodeHintType,Object> hintMap=new Hashtable<EncodeHintType,Object>();
        hintMap.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.L);
        hintMap.put(EncodeHintType.MARGIN, 0);

        QRCodeWriter qrCodeWriter=new QRCodeWriter();
        BitMatrix byteMatrix=qrCodeWriter.encode(myCodeText,BarcodeFormat.QR_CODE, QRCODE_WIDTH, QRCODE_WIDTH, hintMap);
        int CrunchifyWidth=byteMatrix.getWidth();
        
        qrcode_pg=createGraphics(CrunchifyWidth,CrunchifyWidth);
        qrcode_pg.beginDraw();
        qrcode_pg.background(0,0);
         
         for(int i=0;i<CrunchifyWidth;i++)
            for(int j=0;j<CrunchifyWidth;j++)
                if(byteMatrix.get(i,j)){
                	qrcode_pg.set(i,j,color(0));
                }

        qrcode_pg.endDraw();


    }catch(Exception e){
        e.printStackTrace();
    }

}
