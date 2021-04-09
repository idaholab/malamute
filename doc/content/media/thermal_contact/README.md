# Freya Thermal Contact Media Folder How-To

NOTE: ALL commands below must be run in the `freya/doc/content/media/thermal_contact`
directory! A working LaTeX distribution (with TikZ) is also required!

To make a PDF image of Freya thermal contact verification test summary, simply
run `make`.

To make PNG images of Freya thermal contact media (and update the current version
based on changes in the image source files) run `make png`. This requires an
ImageMagick installation! Note that metadata in all generated PNG files will
change, showing git diffs. Only commit those PNG files whose visual content
*actually* changed due to code changes!

To clean the directory of the generated PDF, log files, and intermediate LaTeX
files, run `make clean`.
