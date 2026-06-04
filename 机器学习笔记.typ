#import "@local/ysz_tools:0.1.0": *
#set text(size: 9pt)
#show: conf.with(
  sidebar:false,
)

#include "封面.typ"

#include "license.typ"

#include "前言.typ"
#pagebreak()
#outline(depth: 2)

#include "chapters/Chapter1&2-机器学习概论.typ"

#include "chapters/Chapter3.1-线性判别函数与感知机模型.typ"

#include "chapters/Chapter3.2-线性回归.typ"

#include "chapters/Chapter3.3-逻辑斯蒂回归与最大熵模型.typ"

#include "chapters/Chapter4-贝叶斯分类器.typ"

#include "chapters/Chapter5-支持向量机.typ"

#include "chapters/Chapter6-决策树.typ"

#include "chapters/Chapter7-集成学习.typ"

#include "chapters/Chapter7.1-Bagging与随机森林.typ"

#include "chapters/Chapter7.2-Boosting.typ"

#include "chapters/Chapter8-降维与度量学习.typ"

#include "chapters/Chapter8.1-k近邻法.typ"

#include "chapters/Chapter9-聚类.typ"

#include "chapters/Chapter10-特征选择.typ"

#include "chapters/chapter11-半监督学习.typ"

#include "chapters/Chapter12-强化学习.typ"


// #include ("appendix/矩阵与向量运算.typ")

// #include "appendix/最优化算法.typ"

// #include "appendix/奇异值分解.typ"

