# Machine Learning Notes

Contributor:[bjhh2005](https://github.com/bjhh2005),[xhkzdepartedream](https://github.com/xhkzdepartedream),[kiwiizzz](https://github.com/whoisKIWIIZZZ),[Zoomy](https://github.com/zoomy14112),[红隼饲养员](https://google.com)

基于 Typst 排版系统编写的机器学习笔记,参考李航《统计学习方法》与周志华《机器学习》(西瓜书)体系,覆盖机器学习核心理论与算法.

**内容范围:** 共 12 章,从机器学习概论、线性模型、贝叶斯分类器、支持向量机、决策树,到集成学习、降维、聚类、特征选择、半监督学习及强化学习.附录另含奇异值分解、最优化算法等内容.

**特色:**
- **分层次阅读** — 使用 `#note()` 边栏注释提供延伸说明,`#unim[]` 标记仅需了解的选读内容,便于不同深度的学习
- **术语索引** — 涵盖主要概念的中英文索引,按拼音排序
- **配套资源** — 含期末复习试卷(含详解)、12 讲幻灯片,以及编译好的最终 PDF
- **考试导向** — 各章穿插大量例题,紧密围绕课程考试重点

## 目录结构

```
.
├── 机器学习笔记.typ          # 主入口:按序引入所有章节并生成索引
├── lib.typ                   # 样式库:页面布局、定理/算法/例题等区块样式
├── 前言.typ                  # 序言
├── 封面.typ                  # 封面页
├── 神经网络.typ              # 全连接前馈神经网络(MLP)计算手册(独立章节)
├── pinyin-sort.typ           # 索引拼音排序映射表
├── license.typ               # HHY 开放笔记许可协议
│
├── chapters/                 # 核心章节(Typst源文件,共16个)
│   ├── Chapter1&2-机器学习概论.typ
│   ├── Chapter3.1-线性判别函数与感知机模型.typ
│   ├── Chapter3.2-线性回归.typ
│   ├── Chapter3.3-逻辑斯蒂回归与最大熵模型.typ
│   ├── Chapter4-贝叶斯分类器.typ
│   ├── Chapter5-支持向量机.typ
│   ├── Chapter6-决策树.typ
│   ├── Chapter7-集成学习.typ
│   ├── Chapter7.1-Bagging与随机森林.typ
│   ├── Chapter7.2-Boosting.typ
│   ├── Chapter8-降维与度量学习.typ
│   ├── Chapter8.1-k近邻法.typ
│   ├── Chapter9-聚类.typ
│   ├── Chapter10-特征选择.typ
│   ├── Chapter11-半监督学习.typ
│   └── Chapter12-强化学习.typ
│
├── appendix/                 # 附录(当前版本暂未编译)
│   ├── 奇异值分解.typ
│   ├── 最优化算法.typ
│   └── 矩阵与向量运算.typ
│
├── assets/                   # 嵌入式图片(PNG,25张)
│
├── fig/                      # 额外图片(封面、kd树、聚类等)
│
├── slides/                   # 讲座幻灯片PDF(13个)
│
├── review_material/          # 考试复习资料(PDF)
│
└── 机器学习笔记final.pdf     # 编译完成的最终文档
```

## License
MIT