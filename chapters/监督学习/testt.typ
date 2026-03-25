#let appendix(body) = {
  // 1. 重置标题计数器
  counter(heading).update(0)
  
  // 2. 针对附录内部的所有标题设置新格式
  set heading(numbering: "A.1")
  
  // 3. (可选) 如果你希望一级标题显示为 "附录 A. xxx"
  show heading.where(level: 1): it => {
    let nos = counter(heading).at(it.location())
    let letter = numbering("A", ..nos)
    block(sticky: true,[Appendix #letter #it.body])
  }

  body
}

// --- 使用方法 ---

= 第一章 绪论
这是正文。

#appendix[
  = 调查问卷
  这里会自动编号为 A.

  == 问卷设计详情
  这里会自动编号为 A.1.
  
  = 原始代码
  这里会自动编号为 B.
]