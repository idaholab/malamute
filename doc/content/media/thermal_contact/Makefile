OBJECTS=thermal_two_block.pdf
NAMES=$(basename $(OBJECTS))
IMAGES=$(NAMES:=.png)

all : $(OBJECTS)

$(OBJECTS): %.pdf: %.tex
	pdflatex $<

png : $(OBJECTS)
	convert -density 300 $(word 1, $(OBJECTS)) -quality 90 $(word 1, $(IMAGES))

clean :
	@rm $(NAMES:=.aux) $(NAMES:=.log) $(OBJECTS) 2>/dev/null || true
