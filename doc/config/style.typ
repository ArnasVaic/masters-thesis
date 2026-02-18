#import "bibliography.typ": bibliography_config
#import "headings.typ": heading_config
#import "figures.typ": figure_config
#import "page.typ": page_config
#import "text.typ": text_config
#import "refs.typ": ref_config
#import "par.typ": par_config

#let style_config(lang) = body => {
  
  assert(
    lang == "lt" or lang == "en", 
    message: "Language has to be either 'lt' or 'en'" 
  )

  show: bibliography_config(lang)
  show: figure_config(lang)
  show: text_config(lang)
  show: ref_config(lang)
   
  show: heading_config
  show: page_config
  show: par_config
  
  body
}