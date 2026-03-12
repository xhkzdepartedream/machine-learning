// --- 导入外部依赖 ---
#import "@preview/numbly:0.1.0": numbly
#import "@preview/thmbox:0.3.0": *
#import "@preview/hydra:0.6.2": hydra
#import "@preview/i-figured:0.2.4"
#import "@preview/cetz:0.3.1"
#import "@preview/mitex:0.2.6":*

// --- 定义模板函数 ---
#let notes(
  font: ("Source Han Serif SC"),
  margin:(top: 2.5cm, left: 1.5cm, right: 1.5cm, bottom: 1.5cm),
  font-size: 12pt,
  paper: "a4",
  heading-numbering: numbly(
    "第{1}章",
    "{1}.{2}节",
    "{1}.{2}.{3}",
    "{1}.{2}.{3}.{4}",
    "({5:a})"
  ),
  
  body
) = [
  #show: thmbox-init(counter-level: 3)
  #show math.equation: i-figured.show-equation.with(only-labeled: true, level:2)
  #set page(
    paper: paper, 
    margin: margin,
    numbering: "1",
    header: context {
      if calc.odd(here().page()) {
        align(right, emph(hydra(2)))
      } else {
        align(left, emph(hydra(3)))
      }
      line(length: 100%)
    },
    footer:  context 
    {
      if here().page() == 1{
        // set align(center)
        // counter(page).display("I")
      }
      else if here().page() <= 4{
        set align(center)
         counter(page).display("I")
      }
      else{
        set align(center)
        counter(page).display(
          "北郊HH——1——机器学习"
        )
      }
      
    }
  )
    
  #set text(font: font, size: font-size, lang: "zh")
  #set heading(numbering: heading-numbering)
  
  #body
  
]

#let abstract = note.with(
  variant: "Abstract",
  color: purple,
) 