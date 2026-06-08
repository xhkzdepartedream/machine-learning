#set text(font :("Times New Roman","STSong"))
#import "@preview/cuti:0.4.0":show-cn-fakebold
#show: show-cn-fakebold
#show math.equation.where(block: false): it => math.display(it)
#show math.equation: set text(font: ("New Computer Modern Math",) , purple)
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
#let show_answer = true

#let answer(body) = {
  if show_answer {
    block(
      fill: gray.lighten(80%),   
      inset: 8pt,                
      radius: 4pt,               
      width: 100%,               
      stroke: 0.5pt + gray,      
    )[
        #set text(fill: blue,weight: "bold") // 这一行会让方框内所有的文字和公式都变成蓝色
  #show math.equation: set text(font: ("New Computer Modern Math",) , blue)
      #body
    ]
  } else {
    // 当开关为 false 时，什么都不渲染（返回空）
    none
  }
}
== 一、
请简要解释监督学习、无监督学习及强化学习之间的区别，并分别举一个应用实例。

== 二、
逻辑回归模型主要用于分类还是回归？是线性模型还是非线性模型？是生成式模型还是判别式模型？请给出逻辑回归的数学公式，并简要回答上述问题。

== 三、
随机森林是一种常用的集成学习算法。请回答以下问题：

(1) 简要说明随机森林的工作原理。

(2) 随机森林在特征选择方面有什么优势？

== 四、
对一维模式的两分类问题，设两类模式均为正态分布，其均值和方差分别为
$ mu_1 = 0, sigma_1^2 = 4; quad mu_2 = 2, sigma_2^2 = 4 $
采用（0-1）损失函数，且 $P(omega_1) = e P(omega_2)$，这里 $e$ 是自然对数的底数。

(1) 试大致绘出两类模式的密度函数曲线。

(2) 试写出基于自然对数的对数似然比的最小风险贝叶斯决策规则，计算基于 $x$ 的判决阈值与规则。

(3) 判断两个样本：$x_1 = 2, x_2 = 4$，分别属于哪一类。

== 五、
已知两类训练样本为
$ omega_1: X_1 = [0, 0]^T, quad X_2 = [0, 1]^T; quad omega_2: X_3 = [1, 0]^T, quad X_4 = [1, 1]^T $
设增广权矢量初值为 $W(1) = [0, 1, 1]^T$，用感知器算法求解判别函数，并绘出判别界面。

== 六、
有四个二维模式向量构成的样本集：
$ X_1 = [1, -1]^T, quad X_2 = [3, 3]^T, quad X_3 = [-1, 1]^T, quad X_4 = [-3, -3]^T $

(1) 求该样本集的均值向量和协方差矩阵。

(2) 求出协方差矩阵的全部特征值及对应的特征向量，并在图中标示出第一主元方向。

== 七、
设有 9 个一维模式样本：$X_1=0, X_2=1, X_3=2, X_4=6, X_5=7, X_6=8, X_7=10, X_8=11, X_9=12$，分别在下面两种参数条件下，用最大最小距离法对这些样本进行聚类分析。

(1) $Z_1=X_1, theta=0.4$

(2) $Z_1=X_3, theta=0.6$

== 八、
假设你正在为一家金融公司开发一个客户分类系统，以预测客户是否会违约。数据集包含以下字段：
- customer_id：客户 ID
- age：客户年龄
- income：年收入
- loan_amount：贷款金额
- loan_term：贷款期限（年）
- credit_score：信用评分
- default：是否违约（0：否，1：是）

公司希望你开发一个机器学习模型，根据客户的这些特征来预测客户是否会违约。
试回答一下问题：

a. 根据上述数据，你需要对数据进行哪些预处理步骤？列出至少三个步骤并简述其原因。

b. 针对分类问题，常见的机器学习模型有哪些？请列出两种，并简述它们的基本原理。

c. 你会选择哪些评估指标来评估分类模型的效果？列出两种并解释其含义。