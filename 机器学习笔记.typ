#import "notes.typ": notes

#show:notes

#include "封面.typ"

#include "license.typ"

#include "前言.typ"
#pagebreak()
#outline(depth: 2)

#include("./chapters/监督学习/机器学习及监督学习概论.typ")

#include("chapters/监督学习/线性回归.typ")

#include("./chapters/监督学习/线性判别函数与感知机模型.typ")

#include("./chapters/监督学习/k近邻法.typ")

#include("./chapters/监督学习/朴素贝叶斯法.typ")

#include("./chapters/监督学习/决策树.typ")

#include("./chapters/监督学习/逻辑斯蒂回归与最大熵模型.typ")


// #include ("chapters/监督学习/拉格朗日对偶.typ")

#include ("chapters/监督学习/支持向量机.typ")

#include "chapters/监督学习/Boosting.typ"

#include "chapters/监督学习/Bagging与随机森林.typ"

#include "chapters/监督学习/Stacking(堆叠泛化).typ"

#include "chapters/无监督学习/无监督学习概论.typ"

#include "chapters/无监督学习/聚类方法.typ"

#include "chapters/无监督学习/主成分分析.typ"

#include "chapters/无监督学习/EM算法.typ"

// #include "chapters/深度学习/扩散模型.typ"

#include "chapters/深度学习/前馈神经网络.typ"


// #include ("appendix/矩阵与向量运算.typ")

#include "appendix/最优化算法.typ"

#include "appendix/奇异值分解.typ"

