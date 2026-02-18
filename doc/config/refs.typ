#import "utils.typ"

#let reference_config(lang) = {

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
  if lang == "lt" {
    show ref: it => {
      let el = it.element

      if el == none or el.func() != figure { return it }
      let capt = it.element.caption

      link(
        el.location(), 
        numbering(
          el.numbering, ..counter(figure).at(el.location())
        ) + " " + el.supplement,
      )
    }
  }
}