# MALAMUTE Thermal Contact Media Folder README

NOTE: A working LaTeX distribution (with the TikZ package) and ImageMagick is
required for these instructions.

To update the `thermal_two_block.png` file based on changes in the image source
file, run the following two commands in your Terminal in
`malamute/doc/content/media/thermal_contact`:

```
% pdflatex thermal_two_block.tex
% convert -density 300 thermal_two_block.pdf -quality 90 thermal_two_block.png
```
