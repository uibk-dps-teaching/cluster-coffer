TEX      = latexrun
TEXFLAGS = --latex-cmd xelatex -Wall

SRC = $(wildcard *.tex)

.PHONY: all clean

all: cluster-coffer.pdf

clean:
	$(TEX) --clean-all
	$(RM) -r latex.out

cluster-coffer.pdf: $(SRC)

%.pdf: %.tex
	$(TEX) $(TEXFLAGS) $<
	$(TEX) $(TEXFLAGS) $<
