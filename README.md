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

## GCNT Format

Within the "Text" field is the text of the chant. This is arranged in a way that's superficially similar to GABC notation: a syllable of lyrics, followed by the associated notes and their markings within parentheses, i.e.:

    Si(7v)on(t[676])

Note that there is not a space between the text and parentheses; this is important, as the parser will treat anything separated by a whitespace character as a separate word, which affects automated hyphenation.

The entire text of the chant must be contained within a single string. As shown above, the easiest way to keep your score clean is to use a multiline string with line-ending backslashes. When arranged this way, newline characters within the score have no effect. A newline within the engraving can be forced with a pair of semicolons `;;`. 

### Basic Neumes

Within the parentheses, a number corresponds to a position on the staff. A single number without further annotations is treated as a basic punctus. Multiple numbers, forming a group, must be enclosed within further brackets (discussed below).

The basic neume types are listed below:

- no marks: basic/filled punctum
- h: hollow punctum
- r: rhombus (diamond-shaped neume)

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
    - q: quilisma (ascending triplet, meaning uncertain)

Note that the above brackets are still contained within the parentheses for the annotation. For example, three neumes unjoined with a "parenthesis" tie above the staff might be annotated thus: `Al((757))`.

In situations where multiple neumes/neume groups apply to the same syllable, they should be contained within the same pair of parentheses. For example, to annotate a podatus followed by a torculus on the same syllable, you might write `Al(p[23]t[343])`.

Note that the chantx parsing engine will require that the number of notes associated with a grouping mark (or lack thereof) must match the rules for that mark. An annotation such as `Al(565)` will not compile, as it contains multiple notes; similarly, `Al(t[5656])` will not compile because four notes are included in a three-note grouping (a torculus).

### Division Markings

- |: quarter bar
- ||: half bar
- |||: full bar
- ||||: double bar
- ;;: force line break

Division markings can be contained in parentheses with other markings, or enclosed within their own parentheses. For example, to add a quarter bar, you might indicate it like so: `Al(7)le(6)lu(7)ia;(6)(|)`.

### Other Marks

There are several other marks available in the notation:

- d: dotted neume
- \': accentus (placed above staff)
- v: right virga (vertical line attached to right edge of neume)
- V: left virga (vertical line attached to left edge of neume)
- e: episema (horizontal line above neume)

These "decorative" marks always follow directly after the neume they affect. For example, adding a right virga to the first neume in a tied group might be indicated like so: `Al([5v65])`.

NOTE: at this time, chantx is not "opinionated" about assigning common marks to certain neumes. For example, in many chants, it is common to have a left virga attached to the first neume in a clivis. At this time, chantx does not add such virgae by default.

### General Approach to Conventions

Building on the above, chantx at this time is not strongly opinionated about most conventions, and will let you do things that are "wrong". For example, adding a dot to a rhombus is unheard-of in plainchant, but chantx will happily let you do so if you desire. The only exceptions at this time are for things that are hard to render. For example, you cannot put a rhombus in a torculus, because there is no good way to render such an annotation.

### Future Improvements

Chantx 1.0 will be somewhat limited in scope, focusing on writing the GCNT notation parsing engine and ensuring neumes render correctly on a page. Future versions of the software will (hopefully) include many additional features, such as:

- rendering the custos at the end of lines
- rendering decorative initial letters at the beginning of chants
- support for showing/styling text annotations on the chants, such as Mode, usage, etc.

Given that writing the parser is the most labor-intensive part of the work, future versions after 1.0 should be relatively quick in coming.
