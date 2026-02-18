#let bibliography_config(lang) = (body) => {

  // Req. R8
  set bibliography(

    // LaTeX template uses \bibliographystyle{plain}, however
    // Typst does not have this by default, so we use a plain.csl
    // file from:
    // https://github.com/para-lipics/bibtex-plain-csl
    // 
    // LaTeX template: https://www.overleaf.com/project/60c9ac7c5cf5eefc6065666a (macros.tex)
    style: "plain.csl",

    // Only include cited sources.
    full: false,

    title: 
      if lang == "lt" 
        [ Literatūros šaltiniai ] 
      else if lang == "en"
        [ References ]
  )

  body
}