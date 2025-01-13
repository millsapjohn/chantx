# Chantx

Gregorian Chant engraving for Typst

## Principles

Chantx aims to be comparable in scope and feature set to the existing Gregorio project, a LaTeX package for typesetting plainchant/Gregorian chant. However, it has some key differences:

1. Chantx is not nearly as automated as Gregorio. Gregorio attempts to automate the drawing of virgae and the grouping of notes. That's a great feature set, but at this time I'm not nearly good enough a programmer to work it all out. Most of the neume decorations have to be applied manually in Chantx.

2. Chantx does not use the pre-existing GABC notation format. For one, I don't like some of the choices in GABC for representing various neumes. For another, Typst has built-in data loading capabilities that, if used, prevent me from having to write a parser from scratch.

## File Format

Based on item 2 above, I've made the decision to use a markup language I'm calling GCNT (Gregorian Chant Notation, Typst). This markup format (specified below) should be embedded into a TOML file. The minimum required fields in the TOML file are:

- Name (Name of the chant piece)
- Clef (the clef type and location, as specified below)
- Text (the GCNT markup of the chant)

Additional, optional fields:

- GCNT_License (license applied to the file, if any)
- Score_License (license applied to the original score, if any)
- Office_Part (liturgical use of the chant)
- Occasion (where in the Kalendar the chant is used)
- Meter (rhythmic meter of the piece, if any)
- Commentary (any notes related to the piece that the transcriber wants to share)
- Transcriber (person who transcribed the chant to GCNT)
- Arranger (person who arranged the chant)
- Author (person who authored the chant)
- Compose_Date (date the chant was composed, if known)
- Arrange_Date (date the chant was arranged, if known)
- Transcribe_Date (date the chant was transcribed)
- Manuscript (from which the chant was taken)
- Language (of the lyrics, i.e. Latin)
- Mode (mode of the chant)
- Notes (any other notes)

As with all TOML files, these fields can be arranged in any order. It is recommended to fill out as many fields as are known, even if they are not used at the time.

## GCNT Format

Within the "Text" field is the text of the chant. This is arranged in a way that's superficially similar to GABC notation: a syllable of lyrics, followed by the associated notes and their markup within parentheses, i.e.:

    Si(7v)on(676t)

Note that there is not a space between the text and parentheses; this is important, as the parser will treat anything separated by a whitespace character as a separate word, which affects automated hyphenation.

The entire text of the chant should be contained within a single string. Within this string, carriage returns/newline characters are treated as whitespace, but do not force a new line; this allows the user to insert line breaks for readibility without affecting the engraving of the score. A newline within the engraving can be forced with a pair of semicolons `;;`. 

### Neumes

Within the parentheses, a number corresponds to a position on the staff. A single number without further annotations is treated as a basic punctus. Multiple numbers without further annotations are treated as multiple puncti grouped together with a tie. 

Annotations consist of a single letter after one or more numbers, listed below:

- h: hollow punctum
- p: podatus
- c: clivis
- d: dotted punctum
- t: torculus
- o: porrectus
- a: scandicus
- l: salicus
- q: quilisma
- e: episema
- v: right virga
- V: left virga

### Rhythmic Marks

- |: quarter bar
- ||: half bar
- |||: full bar
- ||||: double bar
- ;;: force line break
