#let get_supplement(it, lang) = {

  let localized_table_supplement = if lang == "lt" { "lentelė." } else { "Table" }
  let localized_image_supplement = if lang == "lt" { "pav." } else { "Figure" }
  let localized_code_supplement = if lang == "lt" { "išeities kodas" } else { "Listing" }

  if it.func() == figure and it.kind == table {
    return localized_table_supplement
  }
  else if it.func() == figure and it.kind == image {
    return localized_image_supplement
  }
  else if it.func() == figure and it.kind == raw {
    return localized_code_supplement
  }
  else {
    return it.supplement
  }
}