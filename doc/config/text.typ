#let text_config(lang) = body =>  {

  set text(

    // Req. R3.1
    font: "Libertinus Serif",

    // Req. R3.2
    size: 12pt,

    // Req. R3.3
    weight: "regular",

    // Req. R3.3
    style: "normal",

    // Unspecified, language configuration
    lang: lang,
  )

  body
}
