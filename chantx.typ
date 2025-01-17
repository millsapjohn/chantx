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
  ]
}

// TODO: find remaining svgs
// TODO: figure out word/neume alignment logic
// TODO: add file opening logic
// TODO: test on varying fonts/sizes to make sure layouts are scaling right
