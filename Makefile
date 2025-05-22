TH_GEN_IDX=/usr/share/mythes/th_gen_idx.pl

.PHONY: all clean check check-rules check-thes packages

all: dicts/is.dic dicts/is.aff dicts/th_is.dat dicts/th_is.idx

clean:
	rm -f dicts/is.aff dicts/is.dic dicts/th_is.dat dicts/th_is.idx dicts/is.oxt dicts/is.xpi
	rm -f wiktionary.dic wiktionary.aff wordlist.diff
	rm -f huntest.aff huntest.dic
	#  rm -f ??wiktionary-latest-pages-articles.xml.bz2
	rm -f ??wiktionary-latest-pages-articles.xml ??wiktionary-latest-pages-articles.xml.texts
	rm -rf libreoffice-tmp/ mozilla-tmp/
	rm -rf dicts/

check: check-rules check-thes check-morph

check-rules:
	echo "Testing old rules..."
	find langs/is/rules/* -type d | while read i; \
	do \
	  cat langs/is/common-aff.d/*.aff > huntest.aff; \
	  if [ -f "$$i/aff" ]; then \
	    LINECOUNT="`grep -ce '^.' "$$i/aff"`"; \
	    echo "SFX X N $$LINECOUNT" >> huntest.aff; \
	    cat "$$i/aff" >> huntest.aff; \
	  fi; \
	  TESTNAME="`basename "$$i"`"; \
	  echo "Testing rule $$TESTNAME"; \
	  cp "$$i/dic" huntest.dic; \
	  test -z "`hunspell -l -d huntest < "$$i/good"`" || { echo "Good word test for $$TESTNAME failed: `hunspell -l -d huntest < "$$i/good"`"; exit 1; }; \
	  test -z "`hunspell -G -d huntest < "$$i/bad"`" || { echo "Bad word test for $$TESTNAME failed: `hunspell -G -d huntest < "$$i/bad"`"; exit 1; }; \
	done
	echo "Testing new rules..."
	test -z "`hunspell -l -d wiktionary < "langs/is/test.good"`" || { echo "Good word test failed: `hunspell -l -d wiktionary < "langs/is/test.good"`"; exit 1; };
	test -z "`hunspell -G -d wiktionary < "langs/is/test.bad"`" || { echo "Bad word test failed: `hunspell -G -d wiktionary < "langs/is/test.bad"`"; exit 1; };
	echo "All passed."

check-thes: dicts/th_is.dat
	! grep ")," $< # pipe, not comma, should separate meanings
	! grep "|[^\(]*)" $< # don't replace comma with pipe inside parentheses
	! grep -P "\xe2" $<
	! grep "([^)]\+(" $<
	! grep "<.*>" $< # no html-like tags
	! grep "&lt;.*&gt;" $< # no html-like tags (encoded)
	@echo "Thesaurus tests passed."
check-morph: dicts/is.dic dicts/is.aff
	@echo "Testing morphology..."
	@test -z "`hunspell -m -d dicts/is < langs/is/test.good | diff -q langs/is/test.morph -`" || { echo "Morphology test failed: `hunspell -m -d dicts/is < langs/is/test.good | diff langs/is/test.morph -`"; exit 1; };
	@echo "Morphology tests passed."

packages: dicts/is.oxt dicts/is.xpi dicts/SentenceExceptList.xml

# LibreOffice extension
dicts/is.oxt: %.oxt: %.aff %.dic dicts/th_is.dat dicts/th_is.idx \
		packages/libreoffice/META-INF/manifest.xml \
		packages/libreoffice/description.xml \
		packages/libreoffice/dictionaries.xcu \
		packages/copyright
	rm -rf $@ libreoffice-tmp
	cp -rf packages/libreoffice libreoffice-tmp
	cp packages/copyright libreoffice-tmp/license.txt
	cd libreoffice-tmp && sed -i 's/TODAYPLACEHOLDER/'`date +%Y.%m.%d`'/g' description.xml && zip -r ../$@ *
	zip $@ dicts/is.dic dicts/is.aff dicts/th_is.dat dicts/th_is.idx

# LibreOffice autocorrect blocklist - not the end of a sentence
dicts/SentenceExceptList.xml: iswiktionary-latest-pages-articles.xml
	echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>"  > $@
	echo "<block-list:block-list xmlns:block-list=\"http://openoffice.org/2001/block-list\">"  >> $@
	grep -C 3 "{{-is-}}" iswiktionary-latest-pages-articles.xml | grep -C 2 "{{-is-skammstöfun-}}" | grep "'''[^ ]\+\.'''" | grep -o "[^']\+" | xargs printf "  <block-list:block block-list:abbreviated-name=\"%s\"/>\n" | sort >> $@
	echo "</block-list:block-list>" >> $@

# Mozilla extension
dicts/is.xpi: %.xpi: %.aff %.dic \
		packages/mozilla/install.js \
		packages/mozilla/install.rdf
	rm -rf $@ mozilla-tmp
	cp -rf packages/mozilla mozilla-tmp
	cd mozilla-tmp && sed -i 's/TODAYPLACEHOLDER/'`date +%Y.%m.%d`'/g' install.js && sed -i 's/TODAYPLACEHOLDER/'`date +%Y.%m.%d`'/g' install.rdf && mkdir dictionaries && cp ../dicts/is.dic ../dicts/is.aff dictionaries/ && zip -r ../$@ *

dicts/is.aff: makedict.sh makedict.py iswiktionary-latest-pages-articles.xml.texts iswiktionary-latest-pages-articles.xml \
		$(wildcard langs/is/common-aff.d/*) $(wildcard "langs/is/rules/*/*")
	./$< is

dicts/is.dic: makedict.sh makedict.py iswiktionary-latest-pages-articles.xml.texts iswiktionary-latest-pages-articles.xml \
                $(wildcard langs/is/common-aff.d/*) $(wildcard "langs/is/rules/*/*")
	./$< is

dicts/th_%.dat: makethes.awk %wiktionary-latest-pages-articles.xml sortthes.py
	LC_ALL=is_IS.utf8 gawk -F " " -f $< <iswiktionary-latest-pages-articles.xml | LC_ALL=is_IS.utf8 ./sortthes.py > $@

%.idx: %.dat
	LC_ALL=is_IS.utf8 ${TH_GEN_IDX} -o $@ < $<

iswiktionary-latest-pages-articles.xml.bz2:
	wget https://dumps.wikimedia.org/iswiktionary/latest/$@ -O $@
	touch $@

iswiktionary-latest-pages-articles.xml: iswiktionary-latest-pages-articles.xml.bz2
	bunzip2 -kf $<
	touch $@

iswiktionary-latest-pages-articles.xml.texts: iswiktionary-latest-pages-articles.xml
	tr -d "\r\n" < iswiktionary-latest-pages-articles.xml | grep -o "{{[^.|{}]*|[^-.}][^ }]*[}|][^}]*" | sed "s/mynd=.*//g" | sed "s/lo.nf.et.ó=.*//g" | sort | uniq > $@

# Performance test target: perf.txt
randwordlist:
	tr -cd '[:alpha:]' < /dev/urandom | fold -w12 | head -n 100 > randwordlist
time=/usr/bin/time -o perf.txt -f "%E real\t%U user\t%S sys\t%M mem\t%C" --append
perf.txt: dicts/is.dic dicts/is.aff randwordlist
	hunspell -vv > perf.txt
	${time} hunspell -d dicts/is -a langs/is/wordlist > /dev/null
	${time} hunspell -d dicts/is -a randwordlist      > /dev/null
	${time} hunspell -d dicts/is -m langs/is/wordlist > /dev/null
	${time} hunspell -d dicts/is -m randwordlist      > /dev/null
	${time} hunspell -d dicts/is -s langs/is/wordlist > /dev/null
	${time} hunspell -d dicts/is -s randwordlist      > /dev/null
	@cat perf.txt
