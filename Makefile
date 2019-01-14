LATEXMK=latexmk --halt-on-error -bibtex -pdf

SaplingSecurityProof.pdf: SaplingSecurityProof.tex refs.bib
	$(MAKE) proof

.PHONY: auxproof
auxproof:
	mkdir -p aux
	rm -f aux/SaplingSecurityProof.*
	$(LATEXMK) -auxdir=aux -outdir=aux SaplingSecurityProof

.PHONY: proof
proof:
	$(MAKE) auxproof
	mv -f aux/SaplingSecurityProof.pdf .

.PHONY: pvcproof
pvcproof:
	mkdir -p aux
	rm -f aux/SaplingSecurityProof.*
	$(LATEXMK) -auxdir=aux -pvc SaplingSecurityProof

.PHONY: html
html: SaplingSecurityProof.pdf
	# Can't use --split-pages 1 because XHR doesn't work by default on local files in Chrome.
	pdf2htmlEX --decompose-ligature 1 --font-size-multiplier 65 --fit-width 1000 --dest-dir html SaplingSecurityProof.pdf

.PHONY: clean
clean:
	rm -f aux/* html/* \
              SaplingSecurityProof.dvi SaplingSecurityProof.pdf SaplingSecurityProof.bbl \
              SaplingSecurityProof.blg SaplingSecurityProof.brf SaplingSecurityProof.toc \
              SaplingSecurityProof.aux SaplingSecurityProof.out SaplingSecurityProof.log \
              SaplingSecurityProof.bcf SaplingSecurityProof.run.xml SaplingSecurityProof.fls \
              SaplingSecurityProof.fdb_latexmk \

optimizer-installed.flag:
	# Nail down git commits to make backdooring somewhat harder.
	git clone https://github.com/pts/sam2p.git
	cd sam2p && git reset --hard a2d7819107324faf7b0904fc7074f7dd4a0e16c7 && $(MAKE)
	git clone https://github.com/pts/tif22pnm.git
	cd tif22pnm && git reset --hard 22217c1a3ea355a899e9c7c79903488ca13d1dfe && $(MAKE)
	git clone https://github.com/pts/pdfsizeopt.git
	cd pdfsizeopt && git reset --hard 47a03403d70f6975888cee966858bebc51b76463
	touch optimizer-installed.flag

.PHONY: clean-optimizer
clean-optimizer:
	rm -rf sam2p tif22pnm pdfsizeopt optimizer-installed.flag

.PHONY: optproof
optproof: optimizer-installed.flag
	$(MAKE) auxproof
	PATH="${PATH}:$(CURDIR)/sam2p:$(CURDIR)/tif22pnm" pdfsizeopt/pdfsizeopt --v=40 --use-image-optimizer=sam2p \
              --tmp-dir=aux aux/SaplingSecurityProof.pdf SaplingSecurityProof.pdf

.PHONY: optimized
optimized: optproof
