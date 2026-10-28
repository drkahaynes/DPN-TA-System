# DPN-TA-System

FIJI/ImageJ code for fluorescence image analysis in the DPN-TA study, developed in the Haynes Lab.

## Macro

`DPN_TA_BioTek_FIJI_Macro.ijm`

This macro processes BioTek-exported TIFF images. It identifies regions of interest (ROIs) in the RFP/Texas Red channel and measures GFP fluorescence within those ROIs at 500-ms and 1000-ms exposures.

## Requirements and input

- FIJI/ImageJ.
- Matching RFP and GFP images together in one folder.
- Filenames following this pattern:
  - RFP: `A1_01_4_1_Texas Red_001.tif`
  - GFP, 500 ms: `A1_01_2_1_CFP_001.tif`
  - GFP, 1000 ms: `A1_01_3_1_CFP_001.tif`

The filename encodes well, plate, channel, region, and image number. Matching images must share the same identifiers apart from channel number and channel name.

## Analysis settings

RFP segmentation uses:
- Background subtraction with rolling-ball radius 100 pixels and sliding paraboloid.
- Threshold range 2000–65535.
- Particle size 20–Infinity and circularity 0.00–1.00.

GFP images are measured without background subtraction.

Before running, enable Area and Mean gray value in ImageJ's Set Measurements dialog, clear any Redirect To selection, and disable Limit to threshold. Particle-size units depend on the image's spatial calibration.

## Running the macro

1. Download and open the `.ijm` file in FIJI's macro editor.
2. Run the macro.
3. Select the folder containing the matching TIFF images.

Images missing either matching GFP exposure are skipped. Fields with no detected RFP ROIs are also skipped.

## Output

The macro writes `DPN_TA_FIJI_measurements.txt` in the parent directory of the selected image folder.

The tab-delimited output contains source filenames, well, plate, region, GFP exposure, ROI count, ROI index, area, mean GFP intensity, and integrated density calculated as Area × Mean.

An existing output file with the same name is overwritten. Move or rename previous results before another run.
