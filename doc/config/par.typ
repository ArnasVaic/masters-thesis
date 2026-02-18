#let par_config = body =>  {

  set par(

    // Req. R4
    leading: 1.1 * 0.65em,

    // Req. R15
    first-line-indent: (amount: 1.5em, all: true),
  )

  // Req. R4 (omit increased spacing from code snippets)
  show raw.where(block: true): set par(leading: 0.65em)

  body
}
