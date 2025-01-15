#let c_clef = image("./resources/c_clef.svg")
#let f_clef = image("./resources/f_clef.svg")
#let punctum = image("./resources/punctum.svg")
#let punctum_hollow = image("./resources/punctum_hollow.svg", width: 1%)
#let dot = image("./resources/dot.svg")

#let chant(root, clef, text) = {
  let val = (7 - root) * 5pt + 2pt
  block()[
    #place(top + left, line(length: 100%, stroke: 0.5pt))
    #place(top + left, dy: -10pt, line(length: 100%, stroke: 0.5pt))
    #place(top + left, dy: -20pt, line(length: 100%, stroke: 0.5pt))
    #place(top + left, dy: -30pt, line(length: 100%, stroke: 0.5pt))
    #if clef == "c" {
      place(top, float: true, dy: val, c_clef)
    } else {
      place(top, float: true, dy: val, f_clef)
    }
    #let words = text.split()
    #let notes = ()
    #let final_words = ()
    #for word in words {
      let parts = word.split(")")
      for part in parts {
        if part.len() == 0 {
          continue
        } else {
          let (text, note) = part.split("(")
          notes.push(note)
          if part == parts.at(-2) {
            final_words.push(text + " ")
          } else {
            final_words.push(text + "-")
          }
        }
      }
    }
    #notes.at(1).len()
    #notes.at(1).slice(0,1)
    #type(notes.at(1))
    #let indices = array.range(notes.len())
    #for index in indices {
      if notes.at(index).len() == 1 {
        let offset = (index * 20pt) + 40pt
        let val = ((7 - int(notes.at(index))) * 5pt) - 33pt
        place(top, dx: offset, dy: val, punctum)
      } else if notes.at(index).len() == 2 {
          let offset = (index * 20pt) + 40pt
          let val = ((7 - int(notes.at(index).slice(0,1))) * 5pt) - 33pt
          if notes.at(index).at(1) == "h" {
            place(top, dx: offset, dy: val, punctum_hollow)
          } else if notes.at(index).at(1) == "d" {
            place(top, dx: offset, dy: val, punctum)
            place(top, dx: (offset + 6pt), dy: val, dot)
          }
        }
    }
  ]
}

// no letter: punctum
// h: hollow punctum
// r: rhombus (diamond) TODO
// p: podatus (ascending pair) TODO
// c: clivis (descending pair) TODO
// d: dot
// ': accentus TODO
// (): parenthesis brace over notes TODO
// {}: curly brace over notes TODO
// {{}}: curly brace with accentus over notes TODO
// t: torculus (triplet, ascent followed by descent) TODO
// o: porrectus (the swoopy one) TODO
// s: scandicus (ascending triplet) TODO
// l: salicus (ascending triplet with second note ictic) TODO
// q: quilisma (ascending triplet with jagged second note) TODO
// e: episema (horizontal line above neume) (only goes above first note in groups) TODO
// v: right virga (vertical line attached to neume) TODO
// V: left virga TODO
// |: quarter bar TODO
// ||: half bar TODO
// |||: full bar TODO
// ||||: double bar TODO
// ;;: force line break TODO
// groups of numbers without letters following will be grouped with a tie TODO

// gcnt (Gregorian Chant Notation, Typst) file extension - formatted as a TOML file
// TODO: finish logic for all neumes
// TODO: find svg for tie
// TODO: figure out word/neume alignment logic
// TODO: add file opening logic
// TODO: test on varying fonts/sizes to make sure layouts are scaling right
