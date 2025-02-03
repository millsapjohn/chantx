#let text_chars = "aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVqQrRsStTuUvVwWxXyYzZ,.;:\'\""
#let digits = "0123456789"
#let neume_chars = "hrfn"
#let deco_chars = "deEvV\'"
#let group_chars = "pc({toslq"
#let rhythm_chars = "|;"


#let porr_check(neumes) = {
  let pass = true
  if neumes.at(0).at(1) > neumes.at(1).at(1) {
    if neumes.at(1).at(1) < neumes.at(2).at(1) {
      continue
    } else {
      panic("incorrect sequence in porrectus")
    }
  } else {
    panic("incorrect sequence in porrectue")
  }
  if "dot" in neumes.at(0).at(2) {
    panic("dot not allowed on first neume of porrectus")
  } else if "dot" in neumes.at(1).at(2) {
    panic("dot not allowen on first neume of porrectus")
  }
  return pass
}

#let torc_check(neumes) = {
  let pass = true
  if neumes.at(0).at(1) < neumes.at(1).at(1) {
    if neumes.at(1).at(1) > neumes.at(2).at(1) {
      continue
    } else {
      panic("incorrect sequence in torculus")
    }
  } else {
    panic("incorrect sequence in torculus")
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
      panic("ascending neumes in descending neume group")
    }
  }
  return pass
}

#let ascend_check(neumes) = {
  let pass = true
  let neume_index = 0
  while neume_index < neumes.len() {
    if neumes.at(neume_index).at(1) < neumes.at(neume_index + 1).at(1) {
      neume_index += 1
    } else {
      panic("descending neumes in ascending group type")
    }
  }
  return pass
}

#let group_mods(neumes) = {
  let pass = true
  for neume in neumes {
    if neume.at(0) != "punctum" {
      panic("only puncta allowed in joined groups")
    }
    let mods = neume.at(1)
    if "virga_right" in mods {
      panic("virgae not allowed in joined groups")
    } else if "virga_left" in mods {
      panic("virgae not allowed in joined groups")
    } else {
      continue
    }
  }
}

#let group_parse(anno) = {
  let raw_neumes = ()
  let char_index = 1
  while char_index < anno.len() {
    let neume_break = false
    let raw_neume = ""
    let val = "f"
    while neume_break == false {
      if anno.at(char_index) == "{" {
        char_index += 1
        continue
      } else if anno.at(char_index) in digits {
        if val = "f" {
          let val = anno.at(char_index)
          let raw_neume = raw_neume + anno.at(char_index)
          char_index += 1
        } else {
          let neume_break = true
        }
      } else if anno.at(char_index) in deco_chars {
        let raw_neume = raw_neume + anno.at(char_index)
        char_index += 1
      } else if anno.at(char_index) in neume_chars {
        let raw_neume = raw_neume + anno.at(char_index)
        char_index += 1
      } else if anno.at(char_index) == "}" {
        let neume_break = true
      } else {
        panic("incorrect group notation", anno)
      }
    }
    raw_neumes.push(raw_neume)
  }
  let proc_neumes = ()
  for raw_neume in raw_neumes {
    let proc_neume = neum_parse(raw_neume)
    proc_neumes.push(proc_neume)
  }
  if anno.at(0) == "p" {
    let type = "podatus"
    if proc_neumes.len() != 2 {
      panic("incorrect number of neumes in podatus", anno)
    }
    let pass = group_mods(proc_neumes)
    let pass = ascend_check(proc_neumes)
  } else if anno.at(0) == "c" {
    let type = "clivis"
    if proc_neumes.len() != 2 {
      panic("incorrect number of neumes in clivis", anno)
    }
    let pass = group_mods(proc_neumes)
    let pass = descend_check(proc_neumes)
  } else if anno.at(0) == "t" {
    let type = "torculus"
    if proc_neumes.len() != 3 {
      panic("incorrect number of neumes in torculus", anno)
    }
    let pass = group_mods(proc_neumes)
    let pass = torc_check(proc_neumes)
  } else if anno.at(0) == "o" {
    let type = "porrectus"
    if proc_neumes.len() != 3 {
      panic("incorrect number of neumes in porrectus", anno)
    }
    let pass = group_mods(proc_neumes)
    let pass = porr_check(proc_neumes)
  } else if anno.at(0) == "s" {
    let type = "scandicus"
    if proc_neumes.len() != 3 {
      panic("incorrect number of neumes in scandicus", anno)
    }
    let pass = group_mods(proc_neumes)
    let pass = ascend_check(proc_neumes)
  } else if anno.at(0) == "l" {
    let type = "salicus"
    if proc_neumes.len() != 3 {
      panic("incorrect number of neumes in salicus", anno)
    }
    let pass = group_mods(proc_neumes)
    let pass = ascend_check(proc_neumes)
  } else if anno.at(0) == "q" {
    let type = "quilisma"
    if proc_neumes.len() != 3 {
      panic("incorrect number of neumes in quilisma", anno)
    }
    let pass = group_mods(proc_neumes)
    let pass = ascend_check(proc_neumes)
  } else if anno.at(0) == "(" {
    let type = "tie_round"
  } else if anno.at(0) == "{" {
    if anno.at(1) == "{" {
      let type = "tie_bracket_punctus"
    } else {
      let type = "tie_bracket"
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
      } else if anno.at(char_index) == "f" {
        let type = "flat"
      } else if anno.at(char_index) == "n" {
        let type = "natural"
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
}
