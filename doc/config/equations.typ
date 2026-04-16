#import "@preview/equate:0.3.2": equate

#let equation_config = (body) => {

  // Req. 17
  set math.equation(numbering: "(1.1)")
  show: equate.with(breakable: true, sub-numbering: true)

  body
}