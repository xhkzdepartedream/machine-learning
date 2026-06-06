#import "@local/ysz_tools:0.1.0": *
#set text(size: 9pt)
#show: conf.with(
  sidebar:false,
  title: "机器学习方法",
  author: "bjhh2025, xhkzdepartedream, kiwiizzz, zoomy",
  date: "2026.6"
)
#show heading: set block(below: 0em) // 默认值通常较大，可以改成 0.8em 或更小
#set footnote.entry(
  // 上方横线：默认只有 30% 宽，我们把它改成 100% 满宽，并设置粗细
  separator: line(length: 100%, stroke: 0.5pt),
  // clearance: 1.5em, // 脚注与正文之间的间距
  // gap: 0.8em,       // 多个脚注之间的间距
)
#note[
  1
]

// 2. 利用 show 规则在整个脚注区域的“下方”再加一条横线
#show footnote.entry: it => {
  it // 渲染脚注内容本身
  line(length: 100%, stroke: 0.5pt) // 下方横线
}
// #include "license.typ"

// #include "前言.typ"
// #pagebreak()

#outline(depth: 3)
#pagebreak()
#include "chapters/Chapter1&2-机器学习概论.typ"

#include "chapters/Chapter3.1-线性判别函数与感知机模型.typ"

#include "chapters/Chapter3.2-线性回归.typ"

#include "chapters/Chapter3.3-逻辑斯蒂回归与最大熵模型.typ"

#include "chapters/Chapter4-贝叶斯分类器.typ"

#include "chapters/Chapter5-支持向量机.typ"

#include "chapters/Chapter6-决策树.typ"

#include "chapters/Chapter7-集成学习.typ"

#include "chapters/Chapter8-降维与度量学习.typ"

#include "chapters/Chapter8.1-k近邻法.typ"

#include "chapters/Chapter9-聚类.typ"

#include "chapters/Chapter10-特征选择.typ"

#include "chapters/chapter11-半监督学习.typ"

#include "chapters/Chapter12-强化学习.typ"


// #include ("appendix/矩阵与向量运算.typ")

// #include "appendix/最优化算法.typ"

// #include "appendix/奇异值分解.typ"

