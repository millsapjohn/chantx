# Chantx

Gregorian Chant engraving for Typst

## Principles

Chantx aims to be comparable in scope and feature set to the existing Gregorio project, a LaTeX package for typesetting plainchant/Gregorian chant. However, it has some key differences:

1. Chantx is not nearly as automated as Gregorio. Gregorio attempts to automate the drawing of virgae and the grouping of notes. That's a great feature set, but at this time I'm not nearly good enough a programmer to work it all out. Most of the neume decorations have to be applied manually in Chantx.

2. Chantx does not use the pre-existing GABC notation format, primarily because I don't like some of the transcription choices made in GABC. Hopefully the notation is fairly easy to pick up, but at this time I have no plans to write any kind of software to convert between GABC and my TOML-based GCNT format. More on that below:

## File Format

Based on item 2 above, I've made the decision to use a domain-specific markup language I'm calling GCNT (Gregorian Chant Notation, Typst) for annotating chants. This markup format (specified below) should be embedded into a "Text" field in a TOML file. The minimum required fields in the TOML file are:

- Name (Name of the chant piece)
- Clef (the clef type and location, as specified below)
- Text (the GCNT markup of the chant, as specified below)

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

As with all TOML files, these fields can be arranged in any order. It is recommended to fill out as many fields as are known, even if they are not used at the time. Version 1.0 will only utilize the clef and text fields, but further support for using and styling the other fields will be included in future versions.

### Clef

The "Clef" field in the TOML file should consist of a single string of two characters. The first character should be an integer indicating the position of the clef on the staff. The second character is either a "c" or an "f" indicating the type of clef to be drawn.

### Example TOML File

In a file named "example_chant.toml":

        Name = "Example Chant"

        Clef = "7c"

        Text = "Al(7)le(6)lu(p[56])ia.(t[676])"

While not absolutely required, it is recommended for the sake of readability (and minimizing errors) to use a TOML multiline string, with line-ending backslashes, like so:

        Text = """
            some(7) text(8) in(4) \
            a(5) read(8)able(7) \
            for(6)mat(7) \
            """
Line-ending backslashes are essentially "ignored" by the TOML parser, so be sure to include the necessary spaces before them. For example,

    Text = """
      some text in\
      a readable\
      format
      """
Will be rendered as "some text ina readableformat". As mentioned above, whitespaces are important to the GCNT parsing engine for determining where words begin and end (and where to automatically apply hyphenation), so be careful.

## GCNT Format

Within the "Text" field is the text of the chant. This is arranged in a way that's superficially similar to GABC notation: a syllable of lyrics, followed by the associated notes and their markings within parentheses, i.e.:

    Si(7v)on(t[676])

Note that there is not a space between the text and parentheses; this is important, as the parser will treat anything separated by a whitespace character as a separate word, which affects automated hyphenation.

The entire text of the chant must be contained within a single string. As shown above, the easiest way to keep your score clean is to use a multiline string with line-ending backslashes. When arranged this way, newline characters within the score have no effect. A newline within the engraving can be forced with a pair of semicolons, for example `Si(7v)on(t[676])(;;)`. 

### Basic Neumes

Within the parentheses, a number corresponds to a position on the staff. A single number without further annotations is treated as a basic punctus. Multiple numbers, forming a group, must be enclosed within further brackets (discussed below).

The basic neume types are listed below:

- no marks: basic/filled punctum
- h: hollow punctum
- r: rhombus (diamond-shaped neume)
- f: flat
- n: natural

### Grouping Marks

Grouping marks define how chantx will join multiple neumes together. The grouping marks are as follows:

- (): neumes unjoined, "parenthesis" tie above staff
- {}: neumes unjoined, "curly bracket" tie above staff
- {{}}: neumes unjoined, "curly bracket" tie with accentus above staff
- []: all other grouping types, preceded by one of the following letters:
    - p: podatus (ascending note pair)
    - c: clivis (descending note pair)
    - t: torculus (three-note group consisting of an ascent followed by a descent)
    - o: porrectus (three-note group consisting of a descent followed by an ascent)
    - s: scandicus (ascending three-note group, first neume is ictic)
    - l: salicus (ascending three-note group, second neume is ictic)
    - q: quilisma (ascending three-note group, meaning uncertain/debated)

Within the "unjoined" grouping types, any neume or decorative mark (see below) is allowed. Within the "joined" grouping types, only filled neumes are allowed, and only "d" (dot), "\'" (accentus), and "e"/"E" (episema) decorative marks are allowed. In a porrectus, only the last neume can have a dot decoration.

Note that the above brackets are still contained within the parentheses for the annotation. For example, three neumes unjoined with a "parenthesis" tie above the staff might be annotated thus: `Al((757))`.

In situations where multiple neumes/neume groups apply to the same syllable, they should be contained within separate parentheses. For example, to annotate a podatus followed by a torculus on the same syllable, you might write `Al(p[23])(t[343])`.

Note that the chantx parsing engine will require that the number of notes associated with a grouping mark (or lack thereof) must match the rules for that mark. An annotation such as `Al(565)` will not compile, as it contains multiple notes; similarly, `Al(t[5656])` will not compile because four notes are included in a three-note grouping (a torculus).

Finally, note that for the "joined" grouping types, all neumes must meet the rules regarding ascent and descent for that group type. For example, an annotation of `Al(p[65])` will generate an error, because a podatus is defined as an ascending group - the second note must be higher than the first.

### Division Markings

- |: quarter bar
- ||: half bar
- |||: full bar
- ||||: double bar
- ;;: force line break

Division markings must be enclosed within their own parentheses. For example, to add a quarter bar, you might indicate it like so: `Al(7)le(6)lu(7)ia;(6)(|)`.

### Other Marks

There are several other marks available in the notation:

- d: dotted neume
- \': accentus (placed above staff)
- v: right virga (vertical line attached to right edge of neume)
- V: left virga (vertical line attached to left edge of neume)
- e: horizontal episema (line)
- E: vertical episema (line)

These "decorative" marks always follow directly after the neume they affect. For example, adding a right virga to the first neume in a tied group might be indicated like so: `Al((5v65))`.

NOTE: at this time, chantx is not "opinionated" about assigning common marks to certain neumes. For example, in many chants, it is common to have a left virga attached to the first neume in a clivis. At this time, chantx does not add such virgae by default. Similarly, chantx will not put a double bar at the end of a chant unless instructed to do so with a `(;;)` annotation. The only "automatic" formatting chantx will do to your chant is hyphenating between syllables, and adding line breaks where necessary.

### Future Improvements

Chantx 1.0 hopes to be feature-complete enough to render decent-looking chants that use most of the most common neumes and group types. However, in order to shorten development time, the initial version will be focusing on writing the GCNT notation parsing engine and ensuring neumes render correctly on a page, rather than putting together an exhaustive list of supported neumes and groups. Future versions of the software will (hopefully) include many additional features, such as:

- rendering the custos at the end of lines
- rendering decorative initial letters at the beginning of chants
- multiple dots on a neume
- rendering the various liquescent groups
- control over where quarter and half bars are placed on the staff
- support for showing/styling text annotations on the chants, such as Mode, usage, etc.

It is to be hoped that any changes to the GCNT notation format will be backwards-compatible; i.e., any chant written with the "1.0" version of the notation system will render identically with any future versions. 

Feel free to open a feature request or discussion to ask for a neume or group you need to be added to the annotation system; however, do be aware that any such requests received prior to the release of version 1.0 will not be addressed until 1.0 is out.
