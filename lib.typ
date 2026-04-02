#import "@preview/numbly:0.1.0": numbly
#import "@preview/thmbox:0.3.0": *
#import "@preview/hydra:0.6.2": hydra
#import "@preview/i-figured:0.2.4"
#import "@preview/cetz:0.3.1"
#import "@preview/mitex:0.2.6": *
#import "@preview/cuti:0.4.0": show-cn-fakebold
#import "@preview/marginalia:0.3.1" as marginalia

// ======================================================
// 1. 全局组件定义
// ======================================================

#let a-note-counter = counter("a-note")
#let note = marginalia.note.with(
  counter: a-note-counter, 
  numbering: (..i) => text(
    weight: 500, font: "JetBrains Mono", size: 7pt, fill: rgb("#ff3a3a"),
    numbering("[a]", ..i),
  )
)

#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  show heading.where(level: 1): it => {
    let nos = counter(heading).at(it.location())
    let letter = numbering("A", ..nos)
    block(sticky: true, weight: "bold", size: 1.2em)[Appendix #letter #it.body]
  }
  body
}

#let unim(body) = {
  block(
    fill: luma(93.73%),        // 浅灰色背景
    width: 100%,
    inset: (x: 1em, y: 1em), // 内边距
    radius: 4pt,            // 圆角
    breakable: true,        // 核心：允许内容跨页断开
    [
      #set text(fill: luma(120), size: 0.95em) // 字色调浅，字号微调，视觉降权
      #body
    ]
  )
}

// ======================================================
// 2. 主配置函数 (conf)
// ======================================================


#let conf(
  title: "您的文档标题",
  subtitle: "",
  author: "作者姓名",
  date: datetime.today().display("[year]年[month]月[day]日"),
  header-title: "Machine Learning",
  header-chapter: "CHAPTER 4",
  font: ("New Computer Modern", "Source Han Serif", "SimSun"),
  font-size: 12pt,
  paper: "a4",
  margin: (top: 2.5cm, left: 1.5cm, right: 1.5cm, bottom: 1.5cm),
  heading-numbering: numbly("第{1}章", "{1}.{2}节", "{1}.{2}.{3}", "({5:a})"),
  body,
) = {
  // --- A. 基础样式 ---
  set text(font: font, size: font-size, lang: "zh")
  set par(first-line-indent: 0em, justify: true, leading: 0.65em)
  set block(spacing: 1.2em)
  set heading(numbering: heading-numbering)
  show figure.where(kind: "thmbox"): set block(breakable: true)
  show: thmbox-init(counter-level: 3)
  show: show-cn-fakebold

  // --- B. 封面页 (渲染完立刻结束，不带边栏规则) ---
  page(numbering: none, header: none, footer: none, margin: margin)[
    #set align(center); #set par(first-line-indent: 0em)
    #v(20%); #text(size: 32pt, weight: "bold")[#title]
    #if subtitle != "" [ #v(0.5em); #text(size: 18pt, fill: luma(100))[#subtitle] ]
    #v(4cm); #text(size: 16pt)[#author]
    #v(1em); #text(size: 14pt, fill: luma(80))[#date]
  ]
  
  pagebreak()
  counter(page).update(1)

  // --- C. 核心：注入边栏与正文样式 ---
  
  // 1. 启动边栏设置 (它会自动管理后续页面的 margin)
// 1. 启动边栏设置
  show: marginalia.setup.with(
    // 内侧（无旁注侧）：直接使用用户设置的 margin.left
    inner: (far: margin.left, width: 0pt, sep: 0pt), 
    
    // 外侧（旁注侧）：从 margin.right 开始往里算
    outer: (far: margin.right, width: 55mm, sep: 8mm),
    
    top: margin.top,
    bottom: margin.bottom,
    book: true, // 开启书本模式，inner/outer 会在奇偶页自动交换
    clearance: 10pt,
  )
  show: marginalia.show-frame

  // 2. 正文页面布局 (注意：这里绝对不能再 set margin 了！)
  set page(
    paper: paper,
   // numbering: "1",
    header: context {
      marginalia.header(
        text-style: (size: 11.5pt, font: font), [],
        [#smallcaps(header-title) #text(fill: luma(60%))[_ #header-chapter _]],
        [Page #counter(page).display("1 of 1", both: true)],
      )
    },
    // footer: context {
    //   set align(center); set text(size: 9pt, fill: luma(100))
    //   [#author —— #counter(page).display("1") —— #title]
    // },
  )

  // 3. 其他正文细节
  show math.equation: i-figured.show-equation.with(only-labeled: true, level: 2)
  show math.equation: set text(purple)
  show raw.where(block: false): it => box(fill: luma(240), inset: (x: 3pt), radius: 2pt, it)
  show raw.where(block: true): it => {
    block(fill: luma(252), stroke: 0.5pt + luma(200), radius: 6pt, width: 100%, clip: true,
      stack(dir: ttb,
        block(fill: luma(240), width: 100%, inset: 8pt, text(weight: "bold", size: 8pt, upper(it.lang))),
        block(width: 100%, inset: 12pt, it),
      )
    )
  }
  show heading: it => { it; par(text(size: 0pt, "")) }

  body
}