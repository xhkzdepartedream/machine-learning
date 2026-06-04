#import "@preview/cuti:0.4.0":show-cn-fakebold
#show: show-cn-fakebold
#show:text.with(font:"New Computer Modern", size: 12pt)
#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

#set table(
  inset: 6pt,
  stroke: none
)

#show figure.where(
  kind: table
): set figure.caption(position: top)

#show figure.where(
  kind: image
): set figure.caption(position: bottom)

#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}
#let conf(
  title: none,
  subtitle: none,
  authors: (),
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: none,
  fontsize: 11pt,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  pagenumbering: "1",
  doc,
) = {
  set document(
    title: title,
    keywords: keywords,
  )
  set document(
      author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    columns: cols
  )

  set par(
    justify: true,
    leading: linestretch * 0.65em
  )
  set text(lang: lang,
           region: region,
           size: fontsize)

  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)

  show link: set text(fill: rgb(content-to-string(linkcolor))) if linkcolor != none
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
  }

  if title != none {
    place(top, float: true, scope: "parent", clearance: 4mm, block(below: 1em, width: 100%)[
      #if title != none {
        align(center, block[
            #text(weight: "bold", size: 1.5em, hyphenate: false)[#title #if thanks != none {
                footnote(thanks, numbering: "*")
                counter(footnote).update(n => n - 1)
              }]
            #(
              if subtitle != none {
                parbreak()
                text(weight: "bold", size: 1.25em, hyphenate: false)[#subtitle]
              }
             )])
      }

      #if authors != none and authors != [] {
        let count = authors.len()
        let ncols = calc.min(count, 3)
        grid(
          columns: (1fr,) * ncols,
          row-gutter: 1.5em,
          ..authors.map(author => align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ])
        )
      }

      #if date != none {
        align(center)[#block(inset: 1em)[
            #date
          ]]
      }

      #if abstract != none {
        block(inset: 2em)[
          #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
        ]
      }
    ])
  }
  doc
}
#show: doc => conf(
  abstract-title: [Abstract],
  pagenumbering: "1",
  cols: 1,
  doc,
)


== 机器学习练习
<机器学习练习>
== 机器学习基本概念
<机器学习基本概念>
(1) 请简述以下几种机器学习范式的区别,并各举一例：

监督学习(Supervised Learning)、无监督学习(Unsupervised
Learning)、半监督学习(Semi-supervised
Learning)、强化学习(Reinforcement Learning)

#block[
#set enum(numbering: "1.", start: 2)
+ 在机器学习建模过程中,一般包括哪些主要步骤？
]

== 模型评估与选择计
<模型评估与选择计>
某二分类模型在测试集上的混淆矩阵如下：

#figure(
  align(center)[#table(
    columns: (33.33%, 33.33%, 33.34%),
    align: (auto,auto,auto,),
    table.header([], [预测正类], [预测负类],),
    table.hline(),
    [实际正类], [45], [5],
    [实际负类], [15], [35],
  )]
  , kind: table
  )

请计算以下指标(保留两位小数)：准确率(Accuracy)、精确率(Precision)、召回率(Recall)、F1
值(F1-score)

== 交叉验证与模型选择
<交叉验证与模型选择>
在一个回归问题上使用了两种模型：线性回归(LR)与支持向量回归(SVR).

使用 #strong[5 折]交叉验证得到平均 MSE 如下：

#figure(
  align(center)[#table(
    columns: (14.16%, 14.32%, 14.32%, 14.32%, 14.33%, 14.33%, 14.21%),
    align: (auto,auto,auto,auto,auto,auto,auto,),
    table.header([模型], [Fold1], [Fold2], [Fold3], [Fold4], [Fold5], [平均
      MSE],),
    table.hline(),
    [LR], [25], [28], [27], [30], [26], [?],
    [SVR], [20], [23], [22], [21], [20], [?],
  )]
  , kind: table
  )

(1) 计算两种模型的平均 MSE,并判断哪一个更优.

(2) 简述交叉验证的主要作用.

== #strong[线性回归参数求解(最小二乘法)]
<线性回归参数求解最小二乘法>
已知简单线性回归模型为：$y = w_0 + w_1 x + epsilon$,其中,$epsilon$
为误差项.现有一组样本数据如下：

#figure(
  align(center)[#table(
    columns: (16.79%, 16.63%, 16.63%, 16.65%, 16.65%, 16.65%),
    align: (center,center,center,center,center,center,),
    table.header(table.cell(align: center)[#strong[x(自变量)]], table.cell(align: center)[#strong[1]], table.cell(align: center)[#strong[2]], table.cell(align: center)[#strong[3]], table.cell(align: center)[#strong[4]], table.cell(align: center)[#strong[5]],),
    table.hline(),
    table.cell(align: center)[y(因变量)], table.cell(align: center)[2], table.cell(align: center)[4], table.cell(align: center)[5], table.cell(align: center)[4], table.cell(align: center)[5],
  )]
  , kind: table
  )

请使用#strong[最小二乘法]求解模型参数 $w_0$(截距)和
$w_1$​(斜率),并写出关键计算步骤.

== #strong[岭回归正则化效果分析]
<岭回归正则化效果分析>
已知某多元线性回归问题中,特征矩阵 X
存在多重共线性(如两个特征高度相关),分别使用普通线性回归和岭回归(Ridge
Regression) 建模,回答以下问题：

#block[
#set enum(numbering: "(1)", start: 1)
+ 多重共线性会对普通线性回归的参数估计产生什么影响？(从参数稳定性、方差角度说明)
  \ (2) 岭回归通过引入正则化项$lambda sum_(j = 1)^p w_j^2$
  ($lambda gt.eq 0$, p 为特征数)解决该问题,简述正则化项的作用. \
  (3)~当正则化参数 $lambda$ 分别取以下值时,分析对岭回归模型参数$w_j$
  和模型泛化能力的影响：$lambda$ = 0; $lambda$ 趋近于正无穷.
]

== #strong[贝叶斯分类器计算]
<贝叶斯分类器计算>
假设一个二分类问题(类别 $C_1$ 与 $C_2$),观测特征为 $x$.已知如下信息

#figure(
  align(center)[#table(
    columns: (33.46%, 33.27%, 33.27%),
    align: (auto,auto,auto,),
    table.header([#strong[项目]], [$ C_1 $], [$ C_2 $],),
    table.hline(),
    [先验概率 $P\(C_i\)$], [0.6], [0.4],
    [条件概率 $P\(x\|C_i\)$], [0.5], [0.2],
  )]
  , kind: table
  )

请根据贝叶斯定理计算后验概率 $P\(C_1\|x\)$ 和 $P\(C_2\|x\)$
,并判断样本属于哪一类.

== #strong[朴素贝叶斯分类器原理分析]
<朴素贝叶斯分类器原理分析>
(1) 简述朴素贝叶斯(Naïve Bayes)分类器的基本假设;

(2) 说明这一假设的优缺点;

(3) 其常见变体有哪些？

== AdaBoost 权重更新与样本分布变化
<adaboost-权重更新与样本分布变化>
给定一个二分类数据集：

#figure(
  align(center)[#table(
    columns: (33.32%, 33.32%, 33.37%),
    align: (center,center,center,),
    table.header(table.cell(align: center)[#strong[样本]], table.cell(align: center)[$ upright(bold(x))_(upright(bold(i))) $], table.cell(align: center)[#strong[标签]
      $upright(bold(y))_(upright(bold(i)))$#strong[​]],),
    table.hline(),
    table.cell(align: center)[1], table.cell(align: center)[A], table.cell(align: center)[+1],
    table.cell(align: center)[2], table.cell(align: center)[B], table.cell(align: center)[+1],
    table.cell(align: center)[3], table.cell(align: center)[C], table.cell(align: center)[-1],
    table.cell(align: center)[4], table.cell(align: center)[D], table.cell(align: center)[-1],
  )]
  , kind: table
  )

第一个弱分类器 $h_1\(x\)$ 的预测如下：

#figure(
  align(center)[#table(
    columns: (49.92%, 50.08%),
    align: (center,center,),
    table.header(table.cell(align: center)[#strong[样本]], table.cell(align: center)[$ upright(bold(h))_(upright(bold(1))) upright(bold(\()) upright(bold(x))_(upright(bold(i))) upright(bold(\))) $],),
    table.hline(),
    table.cell(align: center)[A], table.cell(align: center)[+1],
    table.cell(align: center)[B], table.cell(align: center)[+1],
    table.cell(align: center)[C], table.cell(align: center)[-1],
    table.cell(align: center)[D], table.cell(align: center)[+1],
  )]
  , kind: table
  )

\(1)
计算弱分类器权重：$alpha_1 = 1 / 2 ln frac(1 - epsilon_1, epsilon_1)$​​

#block[
#set enum(numbering: "(1)", start: 2)
+ 计算新的样本分布 $D_2\(i\)$.
]

\(3) 请分析哪些样本的权重会上升？这意味着 AdaBoost
下一轮学习时会偏向哪些样本？解释其原因.

== Bagging 模型方差与集成优点
<bagging-模型方差与集成优点>
某回归问题中,单个基学习器的输出方差为
$V a r\(T_i\)= 1.2$,不同学习器之间的预测相关系数为 $rho = 0.2$.共有
$N = 50$ 个学习器.

\(1)
计算集成预测输出的#strong[总体方差]：$V a r\(macron(T)\)= rho V a r\(T_i\)+ frac(1 - rho, N) V a r\(T_i\)$

\(2) 若改为 $N = 200$ 个学习器,新的方差是多少？

\(3) 结合计算结果,Bagging
模型减少方差的机制是什么？为何当学习器越多、相关性越低时效果越好？

== PCA 主成分方向与投影
<pca-主成分方向与投影>
给定数据集如下,#strong[每一行]是一条样本：

$ X = mat(delim: "[", 2, 0, 1; 3, 1, 2; 4, 0, 3; 5, 2, 4; 6, 3, 5) $

#block[
#set enum(numbering: "(1)", start: 1)
+ 求特征值与特征向量,,并将特征向量进行单位化. \ (2)
  指出主成分方向,并计算方差贡献率. \ (3) 对样本
  $x =\[4\,med 0\,med 3\]^T$,计算其在第一主成分上的投影. \ (4)
  如果仅保留第一主成分,原始三维信息会损失多少？此损失代表什么含义？
]

== #strong[K-Means 聚类迭代与收敛分析]
<k-means-聚类迭代与收敛分析>
一维数据集：

$ x = { 1\,2\,3\,10\,11\,12 } $

初始中心为：

$ mu_1 = 2\,quad mu_2 = 10 $

#block[
#set enum(numbering: "(1)", start: 1)
+ 执行两次完整的 K-Means 迭代,每次写出簇分配与新的中心. \ (2)
  说明两步后算法是否收敛. \ (3) 若初始中心改为
  $mu_1 = 3\,mu_2 = 12$,结果会怎样变化？为什么 K-Means 对初始化敏感？
]

== #strong[高斯混合模型 (GMM)] 
<高斯混合模型-gmm>
有两个一维高斯成分：

#figure(
  align(center)[#table(
    columns: (24.99%, 24.99%, 25.01%, 25.01%),
    align: (center,center,center,center,),
    table.header(table.cell(align: center)[#strong[成分]], table.cell(align: center)[#strong[权重]
      $upright(bold(pi))_(upright(bold(k)))$#strong[​]], table.cell(align: center)[#strong[均值]
      $upright(bold(mu))_(upright(bold(k)))$], table.cell(align: center)[#strong[方差]
      $upright(bold(sigma))_(upright(bold(k)))^(upright(bold(2)))$],),
    table.hline(),
    table.cell(align: center)[1], table.cell(align: center)[0.4], table.cell(align: center)[0], table.cell(align: center)[1],
    table.cell(align: center)[2], table.cell(align: center)[0.6], table.cell(align: center)[3], table.cell(align: center)[1],
  )]
  , kind: table
  )

给定样本 $x = 1$.

\(1) 写出每个成分的后验概率(职责)：

$ gamma_k\(x\)= frac(pi_k thin cal(N)\(x\|mu_k\,sigma_k^2\), sum_(j = 1)^2 pi_j thin cal(N)\(x\|mu_j\,sigma_j^2\)) $

并代入数值计算.

#block[
#set enum(numbering: "(1)", start: 2)
+ 求两成分的责任度比值 $frac(gamma_1\(x\), gamma_2\(x\))$​. \ (3)
  分析哪个成分对该样本的解释更大？如果两个高斯方差变大,职责会发生什么变化？这说明了
  GMM 的哪种鲁棒性问题？
]

== 硬间隔 SVM 的最优超平面计算
<硬间隔-svm-的最优超平面计算>
给定二维样本集：

#figure(
  align(center)[#table(
    columns: (33.24%, 33.47%, 33.28%),
    align: (center,center,center,),
    table.header(table.cell(align: center)[#strong[样本]], table.cell(align: center)[#strong[特征]
      $upright(bold(\()) upright(bold(x))_(upright(bold(1))) upright(bold(\,med)) upright(bold(x))_(upright(bold(2))) upright(bold(\)))$], table.cell(align: center)[#strong[标签]
      $upright(bold(y))$],),
    table.hline(),
    table.cell(align: center)[A], table.cell(align: center)[$ upright(bold(\()) 0\,med 0 upright(bold(\))) $], table.cell(align: center)[+1],
    table.cell(align: center)[B], table.cell(align: center)[$ \(1\,med 1\) $], table.cell(align: center)[−1],
    table.cell(align: center)[C], table.cell(align: center)[$ \(2\,med 0\) $], table.cell(align: center)[-1],
  )]
  , kind: table
  )

(1)写出线性可分 SVM 的优化目标函数(原始形式).

(2)画出这些点在平面上的分布,并给出直观的分界线方向.

(3)将该问题化为拉格朗日对偶问题,求出支持向量与对偶变量
$alpha_i$​的非零条件.

(4)求出最优分离超平面方程 $w^top x + b = 0$.

(5)计算分类间隔的宽度.

== 核函数与软间隔SVM
<核函数与软间隔svm>
已知 SVM 的对偶形式为：

$ max_alpha med sum_i^() alpha_i - 1 / 2 sum_i^() sum_j^() alpha_i alpha_j y_i y_j K\(x_i\,x_j\) $

约束：$sum_i^() alpha_i y_i = 0\,med 0 lt.eq alpha_i lt.eq C$

#block[
#set enum(numbering: "1.", start: 1)
+ 若使用高斯核
  $K\(x_i\,x_j\)= e^(- parallel x_i - x_j parallel^2)$,说明此核在特征空间的非线性映射性质;

+ 分析参数 $C$ 过大或过小时对应"欠惩罚"和"过惩罚"的几何解释;
]

(3)给出硬间隔与软间隔 SVM
的几何差别示意(可用文字或符号说明支持向量位置变化);

(4)说明核函数必须满足的两个基本条件.

== 决策树构建与剪枝分析
<决策树构建与剪枝分析>
给定以下训练数据集(二维离散特征)：

#figure(
  align(center)[#table(
    columns: (24.99%, 24.98%, 24.99%, 25.05%),
    align: (center,center,center,center,),
    table.header(table.cell(align: center)[#strong[样本]], table.cell(align: center)[#strong[天气]], table.cell(align: center)[#strong[湿度]], table.cell(align: center)[#strong[是否打球(标签)]],),
    table.hline(),
    table.cell(align: center)[A], table.cell(align: center)[晴], table.cell(align: center)[高], table.cell(align: center)[否],
    table.cell(align: center)[B], table.cell(align: center)[晴], table.cell(align: center)[正常], table.cell(align: center)[是],
    table.cell(align: center)[C], table.cell(align: center)[阴], table.cell(align: center)[高], table.cell(align: center)[是],
    table.cell(align: center)[D], table.cell(align: center)[阴], table.cell(align: center)[正常], table.cell(align: center)[是],
    table.cell(align: center)[E], table.cell(align: center)[雨], table.cell(align: center)[高], table.cell(align: center)[否],
    table.cell(align: center)[F], table.cell(align: center)[雨], table.cell(align: center)[正常], table.cell(align: center)[是],
  )]
  , kind: table
  )

#block[
#set enum(numbering: "(1)", start: 1)
+ 计算在主节点上按"天气"划分时的信息增益,并判断是否是最优划分特征.

+ 画出对应的决策树结构(可用文字层次描述代替图形).

+ 若使用"基尼指数"作为划分标准,比较与信息增益的划分结果是否一致.

+ 简述决策树容易过拟合的原因,并说明两种剪枝方法(预剪枝 /
  后剪枝)的思路.
]

== #strong[强化学习：价值迭代与策略改进]
<强化学习价值迭代与策略改进>
给定两个状态的 MDP：

#figure(
  align(center)[#table(
    columns: (25%, 25%, 25%, 25%),
    align: (center,center,center,center,),
    table.header(table.cell(align: center)[#strong[状态]], table.cell(align: center)[#strong[动作]], table.cell(align: center)[#strong[奖励]], table.cell(align: center)[#strong[下一状态]],),
    table.hline(),
    table.cell(align: center)[s₁], table.cell(align: center)[a₁], table.cell(align: center)[4], table.cell(align: center)[s₂],
    table.cell(align: center)[s₂], table.cell(align: center)[a₁], table.cell(align: center)[1], table.cell(align: center)[s₁],
  )]
  , kind: table
  )

折扣因子 $gamma = 0.5$,初始 $V_0\(s_1\)= V_0\(s_2\)= 0$.

(1)写出价值迭代更新公式;

(2)分别计算 $V_1\,V_2\,V_3$;

(3)判断策略是否随迭代发生变化;

(4)解释价值迭代与策略迭代的关系与收敛特征.

== #strong[单隐藏层网络的反向传播计算]
<单隐藏层网络的反向传播计算>
一个简单神经网络结构如下： 输入层(2维)→ 隐藏层(2个神经元,Sigmoid
激活)→ 输出层(1个神经元,线性输出)

设定参数如下：

#v(0.5em)

#table(
  columns: (1fr, 2fr),
  stroke: (x, y) => if y == 1 { (bottom: 1pt + rgb("000")) } else { (bottom: 0.5pt + rgb("ddd")) },
  fill: (x, y) => if y == 0 { rgb("f7f7f7") } else { none },
  align: (col, row) => if row == 0 { left + horizon } else { left + horizon },
  inset: (x: 10pt, y: 8pt),
  
  // 表头
  [*参数*], [*值*],
  
  // 表格内容
  [输入 $x$], [$[1, 0]^T$],
  [期望输出 $y$], [$0.8$],
  [$W^(1) = mat(0.1, 0.4; 0.2, 0.3)$], [],
  [$b^(1) = [0, 0]^T$], [],
  [$W^(2) = [0.7, 0.5]^T$], [],
  [$b^(2) = 0.1$], [],
  [学习率 $eta = 0.1$], []
)

 \(1\) 写 出 前 向 传 播 过 程 , 计 算 各 层 输 出 ;

 \(2\)med 以 平 方 误 差 $L = 1 / 2\(y_(p r e d) - y\)^2med $为 损 失 , 推 导 对 所 有 参 数 的 梯 度 ;

 \(3\)若 将 激 活 函 数 改 为 R e L U , 说 明 梯 度 表 达 式 怎 样 简 化 , 且 在 何 种 输 入 下 可 能 

出现神经元失活(dead neuron).

== #strong[写出罗杰斯特回归模型学习的梯度下降算法.]
<写出罗杰斯特回归模型学习的梯度下降算法>
== #strong[试从极大似然的角度阐释线性回归;在什么情况下,岭回归等价于最大后验概率估计？请给出理论解释.]
<试从极大似然的角度阐释线性回归在什么情况下岭回归等价于最大后验概率估计请给出理论解释>
== #strong[机器学习综合题]
<机器学习综合题>
某银行希望利用机器学习模型自动评估客户的信用风险.每位客户的特征如下：

#figure(
  align(center)[#table(
    columns: (33.22%, 33.34%, 33.44%),
    align: (center,center,center,),
    table.header(table.cell(align: center)[#strong[特征]], table.cell(align: center)[#strong[类型]], table.cell(align: center)[#strong[说明]],),
    table.hline(),
    table.cell(align: center)[收入水平], table.cell(align: center)[高 /
    中 / 低], table.cell(align: center)[分类特征],
    table.cell(align: center)[年龄], table.cell(align: center)[连续型], table.cell(align: center)[(单位：岁)],
    table.cell(align: center)[是否有房], table.cell(align: center)[是 /
    否], table.cell(align: center)[分类特征],
    table.cell(align: center)[历史违约次数], table.cell(align: center)[连续型], table.cell(align: center)[(次)],
    table.cell(align: center)[信用风险标签], table.cell(align: center)[0
    \= 低风险,1 = 高风险], table.cell(align: center)[模型预测目标],
  )]
  , kind: table
  )

银行提供了如下 6 组训练样本(简化数据)：

#figure(
  align(center)[#table(
    columns: (16.66%, 16.66%, 16.68%, 16.66%, 16.67%, 16.67%),
    align: (center,center,center,center,center,center,),
    table.header(table.cell(align: center)[#strong[编号]], table.cell(align: center)[#strong[收入水平]], table.cell(align: center)[#strong[年龄]], table.cell(align: center)[#strong[是否有房]], table.cell(align: center)[#strong[违约次数]], table.cell(align: center)[#strong[信用风险]],),
    table.hline(),
    table.cell(align: center)[1], table.cell(align: center)[高], table.cell(align: center)[45], table.cell(align: center)[是], table.cell(align: center)[0], table.cell(align: center)[0],
    table.cell(align: center)[2], table.cell(align: center)[低], table.cell(align: center)[23], table.cell(align: center)[否], table.cell(align: center)[2], table.cell(align: center)[1],
    table.cell(align: center)[3], table.cell(align: center)[中], table.cell(align: center)[32], table.cell(align: center)[否], table.cell(align: center)[1], table.cell(align: center)[1],
    table.cell(align: center)[4], table.cell(align: center)[高], table.cell(align: center)[36], table.cell(align: center)[是], table.cell(align: center)[0], table.cell(align: center)[0],
    table.cell(align: center)[5], table.cell(align: center)[中], table.cell(align: center)[40], table.cell(align: center)[否], table.cell(align: center)[0], table.cell(align: center)[0],
    table.cell(align: center)[6], table.cell(align: center)[低], table.cell(align: center)[29], table.cell(align: center)[否], table.cell(align: center)[1], table.cell(align: center)[1],
  )]
  , kind: table
  )

#block[
#set enum(numbering: "(1)", start: 1)
+ 请给出：将"收入水平"(高/中/低)和"是否有房"(是/否)转换为数值的合理编码方式(例如
  0/1 或 One-Hot 等形式);编码后第 2
  条样本的特征向量应为何？(按顺序：收入、年龄、是否有房、违约次数).

+ 若模型首先考虑以"收入水平"作为划分属性(高、中、低),求此划分的信息增益.请写出计算过程,并说明最终是否选择"收入水平"作为首个划分节点(可定性判断).

+ 假设二分类问题中,采用支持向量方法,当惩罚系数 $C$
  较大时,会对模型的间隔与误分类率产生怎样的影响？简要说明.

+ 考虑一个简化的两层前馈神经网络：
]

#quote(block: true)[
输入层节点：2(收入编码与违约次数)

隐藏层节点：2,使用 Sigmoid 激活函数

输出层节点：1,使用 Sigmoid 输出(表示高风险概率)
]

已知：$x =\[1\,thin 2\]^T$,$W_1 = mat(delim: "[", 0.5, - 0.4; 0.3, 0.1)$,$b_1 = mat(delim: "[", 0; 0)$,$W_2 = mat(delim: "[", 0.6; - 0.2)$,$b_2 = 0$

请计算：隐藏层输出 $h = sigma\(W_1 x + b_1\)$;最终输出
$hat(y) = sigma\(W_2^T h + b_2\)$.

(其中 $sigma\(a\)= frac(1, 1 + e^(- a))$,保留两位小数即可)

(5)结合本任务特征特点与数据量(仅约 100
条样本),分析：若仅能选择决策树 / SVM /
神经网络三种之一,你会选择哪种？请从数据规模、特征类型、模型可解释性等方面说明理由.
