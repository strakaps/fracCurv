import geostoch.io.*;
import geostoch.image.*;
import geostoch.image.qia.steiner.DeterministicSteinerFormula2D;
import geostoch.image.qia.steiner.ValueCache;
import geostoch.image.ops.OuterEucDistTrans;
import geostoch.image.ops.ThresholdOp;
import geostoch.image.qia.Measure2D;

import java.io.*;


public class Haupt {

	/**
	 * @param args
	 */

	public static void main(String[] args) {

		String 	inputFileName = args[0],
				dataFileName  = args[0]+".dat";
		float 	rmin 	= Float.parseFloat(args[1]),
				step	= Float.parseFloat(args[2]),
				rmax	= Float.parseFloat(args[3]);
		
	try {	

		BufferedWriter bfw = new BufferedWriter(new FileWriter(
				dataFileName));

		//einlesen
	    File fin = new File(inputFileName);
	    FileInputStream fileInputStream = new FileInputStream(fin);

	    BinaryImage anImage = PBMReader.read(fileInputStream);
	    fileInputStream.close();
	    System.out.println("Finished reading image.");

	    FloatImage distrans = OuterEucDistTrans.apply(anImage);
	    
//	initiate Radius-array for Steiner formula
		float [] theRadii = new float[1000];
		theRadii[0] = 100;
		for(int i = 1; i<theRadii.length; i++) {
			theRadii[i] = theRadii[i-1] + 20.3f;
		}
		
//	total curvatures
		double x,y_0,y_1,y_2;

//  Write column names	   	
	   	bfw.write("x,y0,y1,y2");
	   	bfw.newLine();
//  Fill with data
	   	for(float r = rmin; r < rmax; r = r * step) {
			Measure2D d = 
				new Measure2D(ThresholdOp.apply(distrans, 0, r));
			
			x		= -Math.log(r);
			y_0		= Math.log(Math.abs(d.eulerNumber()));		
			y_1 	= Math.log(d.boundaryLength()/2 / r);	
			y_2 	= Math.log(d.area() / Math.pow(r, 2));			
	   						
			bfw.write(x+","+y_0+","+y_1+","+y_2);
			bfw.newLine();

	  		System.out.println(r+"  "+y_0+"  "+y_1+"  "+y_2);
	   	}//for
	   	
   bfw.close();
	}//try   
	      catch (FileNotFoundException e) {
	            e.printStackTrace();
	      }
	      catch (IOException e) {
	            e.printStackTrace();
	      }

	
	}//main
	      
	    
}//class
