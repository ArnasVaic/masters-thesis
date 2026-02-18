#let figure_config() = {

  // Req. R10
  show figure.caption: set align(left)
  show figure.caption: it => {
    set par(justify: true)
    it
  }
}