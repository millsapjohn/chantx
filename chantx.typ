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
      let val = ((7 - int(note.at(1))) * 5pt) - 33pt
      place(top, dx: offset, dy: val, punctum)
    }
  ]
}
