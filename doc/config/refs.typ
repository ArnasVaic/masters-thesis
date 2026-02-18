#import "utils.typ": get_supplement

#let ref_config(lang) = body =>  {

  // Req. R14
  // Supplement names for different kinds of figures
  show ref.where(form: "normal"): set ref(supplement: it => 
    get_supplement(it, lang)
  )

  // Req. R14
  // For Lithuanian we have to impose a different ordering of
  // supplement and numbering. Example:
  // LT: <numbering> <supplement>
  // EN: <supplement> <numbering> (default)
  show ref: it => {
    if lang == "lt" {
      let el = it.element

      if el == none or el.func() != figure { return it }
      let capt = it.element.caption

      link(
        el.location(), 
        numbering(
          el.numbering, ..counter(figure).at(el.location())
        ) + " " + el.supplement,
      )
    } else if lang == "en" {
      it
    }
  }

  body
}