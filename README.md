Hunspell-is: The Icelandic spelling dictionary & thesaurus project
==================================================================


Introduction
------------

Hunspell-is is a series of scripts to generate a spelling dictionary and a
thesaurus based on [the Icelandic Wiktionary Project](http://is.wiktionary.org)
and a word list.


Download Pre-Built Packages
---------------------------

*  [Spelling dictionary extension for LibreOffice](http://extensions.libreoffice.org/extension-center/hunspell-is-the-icelandic-spelling-dictionary-project)


What if I spot an error?
------------------------

If you find a word that shouldn't be in the dictionary, you should:

1.  Check if the word is in [the wordlist](https://raw.github.com/nifgraup/hunspell-is/master/langs/is/wordlist).
2.  If the offending word is there, [contact us](#contact) and have the word
removed.
3.  If it isn't there, look it up on [Wiktionary](http://is.wiktionary.org).
4.  If you find it there, press the "Edit" tab and correct the mistake.

If you want to add new words to the dictionary, please do so by adding it to
[Wiktionary](http://is.wiktionary.org). Adding words to the word list is out of
the scope of this project but if you would like to take over maintainance of
the wordlist, please [contact us](#contact).


Development instructions
------------------------

### Dependencies ###

*  bzip2                          http://www.bzip.org/
*  GNU awk                        http://www.gnu.org/software/gawk/
*  GNU Bash                       http://www.gnu.org/software/bash/
*  GNU ed                         http://www.gnu.org/software/ed/
*  GNU Core Utilities             http://www.gnu.org/software/coreutils/
*  GNU Wget                       http://www.gnu.org/software/wget/
*  Hunspell                       http://hunspell.sf.net/


### Usage Instructions ###

	makedict.sh list				# lists supported languages
	makedict.sh LANGUAGE			# generates a dictionary for LANGUAGE, e.g. is
	makedict.sh packages LANGUAGE	# Creates spell checking extensions for applications
	makedict.sh test LANGUAGE		# Runs test cases for wiktionary extraction rules
	makedict.sh clean				# remove temporary files


Contributors
--------------------
*  Development & project maintainer: Björgvin Ragnarsson,
*  Contributors to the Icelandic Wiktionary,
*  Original word list was released into the public domain in the early nineties
by Orðabók Háskóla Íslands & Reiknistofnun Háskóla Íslands.


Contact
-------
All correspondance should go through the [mailing list](https://groups.google.com/group/hunspell-is).

