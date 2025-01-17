#let text_chars = "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVqQrRsStTuUvVwWxXyYzZ,.;:\'\""
#let digits = "0123456789"
#let neume_chars = "hrfn"
#let deco_chars = "deEvV\'"
#let group_chars = "pc({toslq"
#let rhythm_chars = "|;"

#let chant_parse(source) = {
  let source_len = source.len()
  if source.trim() == ""{
    panic("Text field is empty")
  }
  let raw_words = ()
  let proc_words = ()
  let no_text = false
  let word_break = false
  let chant_break = false
  let char_index = 0
  if source.at(0) == "(" {
    let no_text = true
  }

  while chant_break == false {
    let word = ""
    while word_break == false {
      let word = word + source.at(char_index)
      if char_index == source.len() {
        let chant_break = true
        let word_break = true
      } else if source.at(char_index) == " " {
        let word_break = true
      }
    }
    words.push(word)
  }

  for word in words {
    let proc_word = word_parse(no_text, word)
    proc_words.push(proc_word)
  }
}

#let word_parse(no_text, word) = {
  if no_text = false {
    if word.at(0) == "(" {
      panic("no text with annotation", word)
    }
  }
  // checking that parentheses match
  let open_count = 0
  let close_count = 0
  for char in word {
    if char == "(" {
      open_count += 1
    } else if char = ")" {
      close_count += 1
    }
  }
  if open_count != close_count {
    panic("mismatched parentheses", word)
  } else if open_count == 0 {
    panic("no annotation", word)
  }
  let sylls = ()
  while char_index < word.len() {
    let syll = ""
    let open_count = 0
    let close_count = 0
    let syll_break = false
    while syll_break == false {
      if word.at(char_index) == "(" {
        open_count += 1
        if open_count > 1 {
          let syll = syll + word.at(char_index)
        }
        char_index += 1
      } else if word.at(char_index) == ")" {
        close_count += 1
        if open_count > 1 {
          if (close_count + 1) == open_count {
            let syll = syll + word.at(char_index)
            char_index += 1
          } else if open_count == close_count {
            if word.at(char_index + 1) in text_chars {
              char_index += 1
              let syll_break = true
            }
          }
        }
      } else {
        char_index += 1
        let syll = syll + word.at(char_index)
      }
    }
    sylls.push(syll)
  }
  let proc_sylls = ()
  for syll in sylls {
    let proc_syll = syll_parse(syll)
    proc_sylls.push(proc_syll)
  }
  return proc_sylls
}

#let syll_parse(syll) = {
  let text = ""
  let char_index = 0
  let text_break = false
  while text_break = false {
    let char = syll.at(char_index)
    if char in text_chars {
      let text = text + char
      char_index += 1
    } else {
      let text_break = true
      char_index += 1
    }
  }
  let annos = ()
  while char_index < syll.len() {
    let anno_break = false
    let anno = ""
    while anno_break == false {
      if syll.at(char_index) == "(" {
        if syll.at(char_index + 1) == "(" {
          char_index += 1
          continue
        } else {
          let anno = anno + syll.at(char_index)
          char_index += 1
        }
      } else if syll.at(char_index) == ")" {
        if syll.at(char_index - 1) == ")" {
          char_index += 1
          let anno_break = true
          annos.push(anno)
        }
      } else {
        let anno = anno + syll.at(char_index)
        char_index += 1
      }
    }
  }
  let proc_syll = (text,)
  for anno in annos {
    let proc_anno = anno_parse(anno)
    proc_syll.push(proc_anno)
  }
  return proc_syll
}

#let anno_parse(anno) = {
  if anno.at(0) in digits {
    let proc_anno = neume_parse(anno)
  } else if anno.at(0) in group_chars {
    let proc_anno = group_parse(anno)
  } else if anno.at(0) in rhythm_chars {
    let proc_anno = rhythm_parse(anno)
  } else {
    panic("syntax error: leading character incorrect", anno)
  }
  return proc_anno
}

#let neume_parse(anno) = {
  let char_index = 0
  let type = "punctum"
  let mods = ()
  while char_index < anno.len() {
    if char_index == 0 {
      let val = int(anno.at(char_index))
      char_index += 1
    } else {
      if anno.at(char_index) == "h" {
        let type = "punctum_hollow"
      } else if anno.at(char_index) == "r" {
        let type = "rhombus"
      } else if anno.at(char_index) == "d" {
        mods.push("dot")
      } else if anno.at(char_index) == "e" {
        mods.push("episema_horiz")
      } else if anno.at(char_index) == "E" {
        mods.push("episema_vert")
      } else if anno.at(char_index) == "v" {
        mods.push("virga_right")
      } else if anno.at(char_index) == "V" {
        mods.push("virga_left")
      } else if anno.at(char_index) == "\'" {
        mods.push("accentus")
      } else {
        panic("unknown character in neume", anno)
      }
    }
    char_index += 1
  }
  let proc_anno = ("neume", val, mods)
  return proc_anno
}

#let rhythm_parse(anno) = {
  if anno.at(0) == ";" {
    if anno.at(1) == ";" {
      let type = "line break"
    } else {
      panic("incorrect syntax - single semicolon", anno)
    }
  } else {
    if anno.len() > 4 {
      panic("incorrect rhythm marking", anno)
    } else {
      if anno == "|" {
        let type = "bar_quarter"
      } else if anno == "||" {
        let type = "bar_half"
      } else if anno == "|||" {
        let type = "bar_full"
      } else if anno == "||||" {
        let type = "bar_double"
      } else {
        panic("incorrect rhythm marking", anno)
      }
    }
  }
  let proc_anno = ("rhythm", type)
  return proc_anno
}

#let group_parse(anno) = {
  if anno.at(0) == "p" {
    let type = "podatus"
    let proc_group = pod_parse(anno)
  } else if anno.at(0) == "c" {
    let type = "clivis"
    let proc_group = cliv_parse(anno)
  } else if anno.at(0) == "t" {
    let type = "torculus"
    let proc_group = torc_parse(anno)
  } else if anno.at(0) == "o" {
    let type = "porrectus"
    let proc_group = por_parse(anno)
  } else if anno.at(0) == "s" {
    let type = "scandicus"
    let proc_group = scan_parse(anno)
  } else if anno.at(0) == "l" {
    let type = "salicus"
    let proc_group = sal_parse(anno)
  } else if anno.at(0) == "q" {
    let type = "quilisma"
    let proc_group = quil_parse(anno)
  } else if anno.at(0) == "(" {
    let type = "tie_round"
    let proc_group = tie_round_parse(anno)
  } else if anno.at(0) == "{" {
    if anno.at(1) == "{" {
      let type = "tie_bracket_punctus"
      let proc_group = tie_brac_punc_parse(anno)
    } else {
      let type = "tie_bracket"
      let proc_group = tie_brac_parse(anno)
    }
  } else {
    panic("incorrect group syntax", anno)
  }
  return proc_group
}

#let pod_parse(anno) = {
  let char_index = 0
  let raw_neumes = ()
  while char_index < anno.len() {
    let val = "f"
    let neume_break = false
    while neume_break == false {
      if char_index < 2 {
        continue
      } else if val == "f" {
        let val = int(anno.at(char_index))
      } else if char == "d" {
        continue
      }
    }
  }
}

//TODO all the group parsers
