#let c_clef = image("./resources/c_clef.svg")
#let f_clef = image("./resources/f_clef.svg")
#let punctum = image("./resources/punctum.svg")
#let punctum_hollow = image("./resources/punctum_hollow.svg")

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
    #let new_notes = notes.enumerate()
    #for note in new_notes {
      let offset = (note.at(0) * 10pt) + 40pt
      let val = ((9 - int(note.at(1))) * 5pt) - 33pt
      place(top, dx: offset, dy: val, punctum)
    }
  ]
}

// no letter: punctum
// h: hollow punctum
// p: podatus (ascending pair)
// c: clivis (descending pair)
// d: dot (same level for odd notes (between lines), top right for even notes (on lines))
// t: torculus (three note group not solely ascending or descending)
// o: porrectus (the swoopy one)
// a: scandicus (ascending triplet)
// l: salicus (ascending triplet with second note ictic)
// q: quilisma (ascending triplet with jagged second note)
// e: episema (horizontal line above neume) (only goes above first note in groups)
// v: right virga (vertical line attached to neume)
// V: left virga
// |: quarter bar
// ||: half bar
// |||: full bar
// ||||: double bar
// ;;: force line break
// groups of numbers without letters following will be grouped with a tie

// gcnt (Gregorian Chant Notation, Typst) file extension
