#let text_chars = "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVqQrRsStTuUvVwWxXyYzZ,.;:\'\""
#let digits = "0123456789"
#let neume_chars = "hrfn"
#let deco_chars = "deEvV\'"
#let group_chars = "pc({toslq"
#let rhythm_chars = "|;"


#let porr_check(neumes) = {
  // pass is a dummy variable used to perform validity checks
  let pass = true
  if neumes.at(0).at(1) > neumes.at(1).at(1) {
    if neumes.at(1).at(1) < neumes.at(2).at(1) {
      pass = true
    } else {
      panic("incorrect sequence in porrectus", neumes)
    }
  } else {
    panic("incorrect sequence in porrectus", neumes)
  }
  if "dot" in neumes.at(0).at(2) {
    panic("dot not allowed on first neume of porrectus", neumes)
  } else if "dot" in neumes.at(1).at(2) {
    panic("dot not allowen on first neume of porrectus", neumes)
  }
  return pass
}

#let torc_check(neumes) = {
  let pass = true
  if neumes.at(0).at(1) < neumes.at(1).at(1) {
    if neumes.at(1).at(1) > neumes.at(2).at(1) {
      pass = true
    } else {
      panic("incorrect sequence in torculus", neumes)
    }
  } else {
    panic("incorrect sequence in torculus", neumes)
  }
  return pass
}

#let descend_check(neumes) = {
  let pass = true
  let neume_index = 0
  while neume_index < neumes.len() {
    if neumes.at(neume_index).at(1) < neumes.at(neume_index + 1).at(1) {
      neume_index += 1
    } else {
      panic("ascending neumes in descending neume group", neumes)
    }
  }
  return pass
}

#let ascend_check(neumes) = {
  let pass = true
  let neume_index = 0
  while neume_index < (neumes.len() - 1) {
    if neumes.at(neume_index).at(1) < neumes.at(neume_index + 1).at(1) {
      neume_index += 1
    } else {
      panic("descending neumes in ascending group type", neumes)
    }
  }
  return pass
}

#let group_mods(neumes) = {
  let pass = true
  for neume in neumes {
    if neume.at(0) != "punctum" {
      panic("only puncta allowed in joined groups", neumes)
    }
    let mods = neume.at(2)
    if "virga_right" in mods {
      panic("virgae not allowed in joined groups", neumes)
    } else if "virga_left" in mods {
      panic("virgae not allowed in joined groups", neumes)
    } else {
      pass = true
    }
  }
}

#let neume_parse(anno) = {
  let char_index = 0
  let type = "punctum"
  let mods = ()
  let val = 1
  while char_index < anno.len() {
    if char_index == 0 {
      val = int(anno.at(char_index))
      char_index += 1
    } else {
      if anno.at(char_index) == "h" {
        type = "punctum_hollow"
      } else if anno.at(char_index) == "r" {
        type = "rhombus"
      } else if anno.at(char_index) == "f" {
        type = "flat"
      } else if anno.at(char_index) == "n" {
        type = "natural"
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
  let proc_anno = (type, val, mods)
  return proc_anno
}

#let group_parse(anno) = {
  let raw_neumes = ()
  let char_index = 1
  while char_index < anno.len() {
    let neume_break = false
    let raw_neume = ""
    let val = "f"
    while neume_break == false {
      if anno.at(char_index) in "([{" {
        char_index += 1
        continue
      } else if anno.at(char_index) in digits {
        if val == "f" {
          val = anno.at(char_index)
          raw_neume = raw_neume + anno.at(char_index)
          char_index += 1
        } else {
          neume_break = true
        }
      } else if anno.at(char_index) in deco_chars {
        raw_neume = raw_neume + anno.at(char_index)
        char_index += 1
      } else if anno.at(char_index) in neume_chars {
        raw_neume = raw_neume + anno.at(char_index)
        char_index += 1
      } else if anno.at(char_index) in ")]}" {
        if (char_index + 1) == anno.len() {
          char_index += 1
        }else if anno.at(char_index + 1) in ")]}" {
          char_index += 2
        } else {
          char_index += 1
        }
        neume_break = true
      } else {
        panic("incorrect group notation", anno)
      }
    }
    raw_neumes.push(raw_neume)
  }
  let proc_neumes = ()
  for raw_neume in raw_neumes {
    let proc_neume = neume_parse(raw_neume)
    proc_neumes.push(proc_neume)
  }
  let type = "type"
  if anno.at(0) == "p" {
    type = "podatus"
    if proc_neumes.len() != 2 {
      panic("incorrect number of neumes in podatus", anno)
    }
    let pass = group_mods(proc_neumes)
    let pass = ascend_check(proc_neumes)
  } else if anno.at(0) == "c" {
      type = "clivis"
      if proc_neumes.len() != 2 {
        panic("incorrect number of neumes in clivis", anno)
      }
      let pass = group_mods(proc_neumes)
      let pass = descend_check(proc_neumes)
  } else if anno.at(0) == "t" {
      type = "torculus"
      if proc_neumes.len() != 3 {
        panic("incorrect number of neumes in torculus", anno)
      }
      let pass = group_mods(proc_neumes)
      let pass = torc_check(proc_neumes)
  } else if anno.at(0) == "o" {
      type = "porrectus"
      if proc_neumes.len() != 3 {
        panic("incorrect number of neumes in porrectus", anno)
      }
      let pass = group_mods(proc_neumes)
      let pass = porr_check(proc_neumes)
  } else if anno.at(0) == "s" {
      type = "scandicus"
      if proc_neumes.len() != 3 {
        panic("incorrect number of neumes in scandicus", anno)
      }
      let pass = group_mods(proc_neumes)
      let pass = ascend_check(proc_neumes)
  } else if anno.at(0) == "l" {
      type = "salicus"
      if proc_neumes.len() != 3 {
        panic("incorrect number of neumes in salicus", anno)
      }
      let pass = group_mods(proc_neumes)
      let pass = ascend_check(proc_neumes)
  } else if anno.at(0) == "q" {
      type = "quilisma"
      if proc_neumes.len() != 3 {
        panic("incorrect number of neumes in quilisma", anno)
      }
      let pass = group_mods(proc_neumes)
      let pass = ascend_check(proc_neumes)
  } else if anno.at(0) == "(" {
      type = "tie_round"
  } else if anno.at(0) == "{" {
      if anno.at(1) == "{" {
        type = "tie_bracket_punctus"
      } else {
        type = "tie_bracket"
      }
  } else {
      panic("incorrect group syntax", anno)
  }
  let proc_group = (type, proc_neumes)
  return proc_group
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

#let anno_parse(anno) = {
  let proc_anno = ()
  if anno.at(0) in digits {
    proc_anno = neume_parse(anno)
  } else if anno.at(0) in group_chars {
    proc_anno = group_parse(anno)
  } else if anno.at(0) in rhythm_chars {
    proc_anno = rhythm_parse(anno)
  } else {
    panic("syntax error: leading character incorrect", anno)
  }
  return proc_anno
}

#let syll_parse(syll) = {
  let text = ""
  let char_index = 0
  let text_break = false
  while char_index < syll.len() {
    let char = syll.at(char_index)
    if char in text_chars {
      text = text + char
      char_index += 1
    } else {
        break
    }
  }
  let annos = ()
  while char_index < syll.len() {
    let anno_break = false
    let anno = ""
    let open_count = 0
    let close_count = 0
    while anno_break == false {
      if syll.at(char_index) == "(" {
        open_count += 1
        if syll.at(char_index - 1) == "(" {
          anno = anno + syll.at(char_index)
          char_index += 1
        } else {
          char_index += 1
        }
      } else if syll.at(char_index) == ")" {
        close_count += 1
        if open_count > 0 and open_count == close_count {
          anno_break = true
          char_index += 1
          annos.push(anno)
        }
      } else {
        anno = anno + syll.at(char_index)
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

#let word_parse(no_text, word) = {
  if no_text == false {
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
    } else if char == ")" {
      close_count += 1
    }
  }
  if open_count != close_count {
    panic("mismatched parentheses", word)
  } else if open_count == 0 {
    panic("no annotation", word)
  }
  let sylls = ()
  let char_index = 0
  while char_index < word.len() {
    let syll = ""
    let syll_break = false
    while syll_break == false {
      syll = syll + word.at(char_index)
      char_index += 1
      if (char_index + 1) == word.len() {
        syll_break = true
        syll = syll + word.at(char_index)
        char_index += 1
      } else if word.at(char_index) == ")" and word.at(char_index + 1) in text_chars {
        syll_break = true
        syll = syll + word.at(char_index)
        char_index += 1
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
      word = word + source.at(char_index)
      char_index += 1
      if (char_index + 1) == source.len() {
        chant_break = true
        word_break = true
        word = word + source.at(char_index)
      } else if source.at(char_index) == " " {
        word_break = true
        char_index += 1
      }
    }
    raw_words.push(word)
  }

  for word in raw_words {
    let proc_word = word_parse(no_text, word)
    proc_words.push(proc_word)
  }
  return proc_words
}
