// DPN-TA BioTek batch FIJI macro 
// Uses RFP/Texas Red channel to identify RFP+ nuclei, 
// then measures GFP 500 ms and GFP 1000 ms in those ROIs. 

setBatchMode(true); 

inputDir = getDirectory("Choose folder containing BioTek .tif images"); 
parentDir = File.getParent(inputDir); 
outputFile = parentDir + File.separator + "DPN_TA_FIJI_measurements.txt"; 

// Settings
rollingBall = 100;
thresholdLower = 2000;
thresholdUpper = 65535;
particleSize = "20-Infinity";
particleCircularity = "0.00-1.00";

// If you want to subtract background from GFP before measuring, set true. 
// To match your current manual pipeline, leave false. 
backgroundSubtractGFP = false;

// Start output file
header = "RFP_file\tGFP_file\tWell\tPlate\tRegion\tGFP_exposure_ms\tROI_count\tROI_index\tArea\tMean\tIntDen\n";
File.saveString(header, outputFile);

list = getFileList(inputDir);

for (i = 0; i < list.length; i++) {

	file = list[i];

	// Find RFP files only 
  if (!endsWith(file, ".tif")) continue;
  if (indexOf(file, "Texas Red") == -1) continue;
  if (indexOf(file, "_4_") == -1) continue;

  rfpFile = file;
  rfpPath = inputDir + rfpFile;

	// Corresponding GFP files 
	gfp500File = replace(rfpFile, "_4_", "_2_");
  gfp500File = replace(gfp500File, "Texas Red", "CFP");
 
  gfp1000File = replace(rfpFile, "_4_", "_3_");
  gfp1000File = replace(gfp1000File, "Texas Red", "CFP");

  gfp500Path = inputDir + gfp500File;
  gfp1000Path = inputDir + gfp1000File;

  // Skip if matching GFP images are missing 
  if (!File.exists(gfp500Path)) {
    print("Missing GFP 500 ms file for: " + rfpFile);
    continue; 
  }
  if (!File.exists(gfp1000Path)) {
    print("Missing GFP 1000 ms file for: " + rfpFile);
    continue; 
  }

  // Parse metadata from filename:
  // Example: A1_01_4_1_Texas Red_001.tif
  parts = split(rfpFile, "_");
  well = parts[0];
  plate = parts[1];

  region = parts[3];

  // -------------------------- 
  // Make RFP ROIs 
  // -------------------------- 
  roiManager("Reset");
  open(rfpPath);
  rfpTitle = getTitle();

  run("Subtract Background...", "rolling=" + rollingBall + " sliding");
  setThreshold(thresholdLower, thresholdUpper);
  run("Convert to Mask");

  run("Analyze Particles...", "size=" + particleSize + " circularity=" + particleCircularity + " add");

  roiCount = roiManager("count");
 
  close(rfpTitle);

  if (roiCount == 0) {
      print("No RFP ROIs found for: " + rfpFile); 
      continue; 
  }
 
  // -------------------------- 
  // Measure GFP 500 ms 
  // -------------------------- 
  measureGFP(gfp500Path, gfp500File, rfpFile, well, plate, region, "500", roiCount, outputFile, backgroundSubtractGFP, rollingBall); 

  // -------------------------- 
  // Measure GFP 1000 ms 
  // -------------------------- 
  measureGFP(gfp1000Path, gfp1000File, rfpFile, well, plate, region, "1000", roiCount, outputFile, backgroundSubtractGFP, rollingBall); 

  roiManager("Reset");
}

setBatchMode(false); 
print("Done. Results saved to:"); 
print(outputFile); 

// -------------------------- 
// Function: measure GFP image using current ROI Manager ROIs 
// -------------------------- 
function measureGFP(gfpPath, gfpFile, rfpFile, well, plate, region, exposure, roiCount, outputFile, backgroundSubtractGFP, rollingBall) { 

	open(gfpPath); 
	gfpTitle = getTitle(); 

  if (backgroundSubtractGFP) {
      run("Subtract Background...", "rolling=" + rollingBall + " sliding"); 
  }

  run("Clear Results"); 

  roiManager("Select", 0); 
  for (r = 0; r < roiCount; r++) {
      roiManager("Select", r); 
      run("Measure"); 
  }

  n = nResults; 

	for (r = 0; r < n; r++) {
      area = getResult("Area", r); 
      mean = getResult("Mean", r); 
      intden = area * mean; 

    line = rfpFile + "\t" + gfpFile + "\t" + well + "\t" + plate + "\t" + region + "\t" + exposure + "\t" + roiCount + "\t" + (r+1) + "\t" + area + "\t" + mean + "\t" + intden + "\n"; 
  	File.append(line, outputFile); 
  }

	close(gfpTitle); 
}
