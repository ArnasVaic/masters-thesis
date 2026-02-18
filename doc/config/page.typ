#let page_config = body => {

  // Req. R1
  set page(columns: 1)

  // Req. R2
  set page(
    margin: (
      top: 20mm,
      bottom: 20mm,
      left: 30mm,
      right: 15mm,
    ),
  )

  // Req. R5
  set page(
    numbering: "1",
    number-align: right + bottom,
  )

  body
}
