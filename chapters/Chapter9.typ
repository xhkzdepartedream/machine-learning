#import "@local/ysz_tools:0.1.0": *

#show: conf.with(
  title: "shabi",
)

== 聚类方法
形式化地：
#note[聚类（Clustering）是按照某个特定标准（如距离）把一个数据集分割成不同的类或簇，使得同一个簇内的数据对象的相似性尽可能大，同时不在同一个簇中的数据对象的差异性也尽可能地大。聚类后同一类的数据尽可能聚集到一起，不同类数据尽量分离。

#unim[
  *硬聚类（hardclustering）*方法：一个聚类方法假定一个样本只能属于一个类或类的交集为空集。
  
  *软聚类（softclustering）*方法：一个样本可以属于多个类或类的交集不为空集。
]
]
#image("/assets/image-13.png")


#remark[*相似性测度、聚类准则和聚类算法*称为聚类分析的三要素。]


// *均值聚类*是基于中心的聚类方法，通过迭代，将样本分到个类中，使得每个样本与其所属类的中心或均值最近，得到个“平坦的”、非层次化的类别，构成对空间的划分。$k$均值聚类的算法于1967年由MacQueen提出。

// 聚类和分类的区别，要不要加？ ppt p8

=== 聚类的基本概念

聚类的对象是观测数据或样本集合。假设有$n$个样本，每个样本由$m$个属性的特征向量组成。矩阵的第$j$列表示第$j$个样本：
$
  X=[x_"i j"]_(m times n)=mat(
    x_11,x_12,dots,x_"1n";
    x_21,x_22,dots,x_"2n";
    dots.v,dots.v,,dots.v;
    x_"m1",x_"m2",dots,x_"mn";
  )
$

在聚类中，可以将样本集合看作是向量空间中点的集合，以该空间的距离表示样本之间的相似度。


聚类试图将数据集中的样本划分为若干个通常是不相交的子集，每个子集称为一个簇。

用$G$表示类或簇(cluster)，用$x_i,x_j$表示类中的样本，用$n_G$表示$G$中样本的个数，用$d_(i j)$表示样本$x_i$与$x_j$之间的距离。

#definition[类或簇][
  设$T$为给定的正数，若对于集合$G$中任意两个样本$x_i,x_j$, 有
  $
    d_(i j) lt.eq T
  $
  则称$G$为一个类或簇。
]

// #definition[类或簇][
//   设$T$为给定的正数，若对于集合$G$中任意两个样本$x_i$, 一定存在$G$中的另一个样本$x_j$，使得
//   $
//     d_(i j) lt.eq T
//   $
//   则称$G$为一个类或簇。
// ]

// #definition[类或簇][
//   设$T$为给定的正数，若对于集合$G$中任意一个样本$x_i$, $G$中的另一个样本$x_j$满足，
//   $
//     ( 1 ) / ( n _ ( G ) - 1 ) sum _ ( x _ ( j ) in G ) d _ ( i j ) lt.eq.slant T
//   $
//   则称$G$为一个类或簇。
// ]

// #definition[类或簇][
//   设$T$和$V$为给定的两个正数，若集合$G$中任意两个样本$x_i,x_j$的距离$d_(i j)$满足
//   $
//     ( 1 ) / ( n _ ( G ) ( n _ ( G ) - 1 ) ) sum _ ( x _ ( i ) in G ) sum _ ( x _ ( j ) in G )  d _ ( i j ) lt.eq.slant T \ d _ ( i j ) lt.eq.slant V
//   $
//   则称$G$为一个类或簇。
// ]

// 这4个定义中第1个是最常用的，并且它可以推出来其他3个定义。
// 这上面是何意味？注释了。——yyl

#unim[
类的特征可以通过不同角度来刻画，常用的特征有下面3种：
1. 类的均值$overline(x)_G$，又称为类的中心
$
  overline(x)_G=1/n_G sum_(i=1)^n_G x_i
$
  式中$n_G$是类的样本个数。
2. 类的直径(diameter)$D_G$, 类的直径是类中任意两个样本之间的最大距离，即：
$
  D_G=max_(x_i,x_j in G) d_(i j)
$
3. 类的样本散布矩阵(scatter matrix)$A_G$与样本协方差矩阵(covariance matrix)$S_G$类的样本散布矩阵$A_G$为
$
  A _ ( G ) = sum _ ( i = 1 ) ^ ( n _ ( G ) ) ( x _ ( i ) - overline( x ) _ ( G ) ) ( x _ ( i ) - overline( x ) _ ( G ) ) ^ ( T )
$
样本协方差矩阵$S_G$为
$
  S _ ( G ) 
  & = ( 1 ) / ( n _ ( G ) - 1 ) A _ ( G ) \ 
  & = ( 1 ) / ( n _ ( G ) - 1 ) sum _ ( i = 1 ) ^ ( n _ ( G ) ) ( x _ ( i ) - overline( x ) _ ( G ) ) ( x _ ( i ) - overline( x ) _ ( G ) ) ^ ( T )
$

考虑类$G_p$与类$G_q$之间的距离$D(p,q)$，也称为连接。类与类之间的距离也有多种定义。

设类$G_p$包含$n_p$个样本，$G_q$包含$n_q$个样本，分别用$overline(x)_p$和$overline(x)_q$表示$G_p$和$G_q$的均值，即类的中心。

1. 最短距离或单连接(single linkage): 定义类$G_p$的样本与类$G_q$的样本之间的最短距离为两类之间的距离：
$
  D _ ( p q ) = min { d _ ( i j ) | x _ ( i ) in G _ ( p ) , x_j in G_q}
$
2. 最长距离或完全连接(complete linkage): 定义类$G_p$的样本与类$G_q$的样本之间的最长距离为两类之间的距离：
$
  D _ ( p q ) = max { d _ ( i j ) | x _ ( i ) in G _ ( p ) , x_j in G_q}
$
3. 中心距离：定义类$G_p$的样本与类$G_q$的中心之间的距离为两类之间的距离：
$
  D_(p q)=d_(overline(x)_p overline(x)_q)
$
4. 平均距离：定义类$G_p$的样本与类$G_q$任意两个样本之间距离的平均值为两类之间的距离：
$
  D _ ( p q ) = ( 1 ) / ( n _ ( p ) n _ ( q ) ) sum _ ( x _ ( i ) in G _ ( p ) ) sum _ ( x _ ( j ) in G _ ( q ) ) d _ ( i j )
$
]
// 请问以上unim块又是哪来的东西——yyl

== 性能指标#note[
  评价标准分成了两派：
- 外部指标：事先知道数据的真实分类（参考模型）。
- 内部指标：完全不知道真实分类，只能通过测量数据点之间的实际物理/几何距离来评价。
]
=== 外部指标

通过考察所有样本对 $(x_i, x_j)$（其中 $i < j$），根据它们在 $C$ 和 $C^*$ 中是否属于同一个簇，将其分为四类：
- $a = |"SS"|$：Same-Same。在聚类结果中属于同簇，在参考模型中也属于同簇。（预测正确）
- $b = |"SD"|$：Same-Different。在聚类结果中属于同簇，但在参考模型中属于不同簇。（预测错误）
- $c = |"DS"|$：Different-Same。在聚类结果中属于不同簇，但在参考模型中属于同簇。（预测错误）
- $d = |"DD"|$：Different-Different。在聚类结果中属于不同簇，在参考模型中也属于不同簇。（预测正确）

$ a + b + c + d = m(m - 1) / 2 = C_m^2$#note[即从 $m$ 个样本中任取两个样本的组合数。]

有了$a,b,c,d$我们就可以拼装出不同的评价指标：#note[
#unim[
  1. Jaccard 系数 (JC)完全忽略了 #mi(`d`)（因为大部分毫不相干的点被分在不同组是很正常的，数值往往极大，会掩盖有效信息）。它只关心：在所有“被算法凑在一起”或“原本就该在一起”的样本对中，真正凑对成功的比例是多少。

  2. Rand 指数 (RI)是最直观的“准确率”。分子 #mi(`a+d`) 是算法所有做对的决定（不管是成功凑对还是成功拆散），分母是总共有多少对。

  3. Fowlkes and Mallows 指数 (FMI)是两个比例的几何平均数。#mi(`\frac{a}{a+b}`) 衡量了“算法聚在一起的对中，有多少是真的”（查准率）；#mi(`\frac{a}{a+c}`) 衡量了“原本该在一起的对中，算法找出了多少”（查全率）。]
]

- *Jaccard系数 (JC):* $a / (a + b + c)$
- *FM指数 (FMI):* $sqrt(a / (a + b) dot a / (a + c))$
- *Rand指数 (RI):* $(a + d) / (a + b + c + d)$ (即预测正确的样本对比例)

#remark[
  上述指标的结果均在$[0,1]$区间，值越大越好。
]

=== 内部指标

#definition[
  1. *簇内样本平均距离 #mi(`avg(C)`)*
#mitex(`avg(C) = \frac{2}{|C|(|C|-1)} \sum_{x_i, x_j \in C} dist(x_i, x_j)`)

  2. *簇内样本最远距离 (直径) #mi(`diam(C)`)*
#mitex(`diam(C) = \max_{x_i, x_j \in C} dist(x_i, x_j)`)

  3. *簇间最近样本距离 #mi(`d_{min}(C_i, C_j)`)*
#mitex(`d_{min}(C_i, C_j) = \min_{x_i \in C_i, x_j \in C_j} dist(x_i, x_j)`)
#note[
1. 把同一个簇里的人两两之间量一下距离，算个平均数。这个值越小越好，说明簇内足够紧凑。
2. 同一个簇里，相距最远的两个人有多远。这就好比一个团队的“直径”。这个值同样越小越好，说明圈子没有拉得太长。
3. A 簇边缘的人和 B 簇边缘的人，最容易发生混淆的两个点的距离。这个值越大越好，说明两个圈子界限分明，井水不犯河水。
]
]


定义 $mu_i = 1/abs(C_i) sum_(x in C_i) x$ 为簇 $C_i$ 内样本的均值向量，则两个聚类簇 $C_i$ 和 $C_j$ 的中心距离为：

$ d_"cen"(C_i, C_j) = "dist"(mu_i, mu_j) $

聚类分析常用的内部指标, 簇内越紧密越好（高内聚），簇间越疏远越好（低耦合）：

$ "DBI" = 1/k sum_(i=1)^k max_(j != i) ( ("avg"(C_i) + "avg"(C_j)) / (d_"cen" (mu_i, mu_j)) ) $

$ "DI" = min_(1 <= i <= k) { min_(j != i) ( (d_"min" (C_i, C_j)) / (max_(1 <= l <= k) "diam"(C_l)) ) } $#note[
*DB指数 (Davies-Bouldin Index, DBI)*, 衡量“最坏情况下的簇间重叠程度”, 用“簇内的平均分散程度”（簇有多松散）除以“簇中心之间的距离”（簇隔得有多远）。

*Dunn指数 (Dunn Index, DI)*, 衡量“最小的簇间间距”相对于“最大的簇内直径”的比率, 找出所有簇之间最近的距离，除以所有簇中最大的那个直径。
]

DBI指数越小（或DI指数越大）就越意味着簇内距离越小同时簇间距离越大，说明聚类的性能越好。

== 距离计算
#image("/assets/image-14.png")

=== 有序属性

#definition[闵可夫斯基距离][
  给定样本集合$X$, $X$是$m$维实数向量空间$R^m$中点的集合，其中$x_i,x_j in X, x_i=(x_"1i",x_"2i",dots,x_"mi")^T, x_j=(x_"1j",x_"2j",dots,x_"mj")^T$, 样本$x_i$与$x_j$的闵可夫斯基距离(Minkowski distance)定义为
  $
    d_"ij"=(sum_(k=1)^m |x_"ki"-x_"kj"|^p)^(1/p)
  $
  $p gt.eq 1$, 当$p=2$时称为欧氏距离，$p=1$时称为曼哈顿距离，$p=infinity$时称为切比雪夫距离：
  $
    d_"ij"=max_k |x_"ki"-x_"kj"|
  $
]

#definition[马哈拉诺比斯距离(马氏距离)][
  #note[
  马氏距离本质上解决两个直觉问题：“单位不统一”和“变量之间有裙带关系（相关性）”。

  考虑*各个分量（特征）之间的相关性，且与各个分量的尺度无关*。马哈拉诺比斯距离越大，相似度越小。因此计算距离时要用方差归一化。
  ]
  给定一个样本集合$X$, $X=[x_(i j)_(m times n)]$, 其协方差矩阵记作$S$。样本$x_i$与$x_j$之间的马氏距离$d_(i j)$定义为
  $
    d _ ( i j ) = [ ( x _ ( i ) - x _ ( j ) ) ^ ( upright( T ) ) S ^ ( - 1 ) ( x _ ( i ) - x _ ( j ) ) ] ^ ( ( 1 ) / ( 2 ) )
  $
  其中, 
  $
    (x _ ( i ) = ( x _ ( 1 i ) , x _ ( 2 i ) , dots.h.c , x _ ( m i ) ) ^ ( upright( T ) ) , quad x _ ( j ) = ( x _ ( 1 j ) , x _ ( 2 j ) , dots.h.c , x _ ( m j ) ) ^ ( upright( T ) )
  $
#mitex(`
S = \frac{1}{m} \sum_{i=1}^m (\mathbf{x}_i - \mathbf{M})(\mathbf{x}_i - \mathbf{M})^T
`)
1.  先减：每个样本都减去均值（去中心化）。
2.  再乘：每个样本生成一个 #mi(`n \times n`) 的小矩阵。
3.  最后加：把这 #mi(`m`) 个小矩阵全部叠在一起，再除以 #mi(`m`)（或者 #mi(`m-1`)）。
]

#definition[相关系数][
  样本$x_i$与$x_j$之间的相关系数定义为
  $
    r _ ( i j ) = ( sum _ ( k = 1 ) ^ ( m ) ( x _ ( k i ) - tilde( x ) _ ( i ) ) ( x _ ( k j ) - tilde( x ) _ ( j ) ) ) / ( [ sum _ ( k = 1 ) ^ ( m ) ( x _ ( k i ) - tilde( x ) _ ( i ) ) ^ ( 2 ) sum _ ( k = 1 ) ^ ( m ) ( x _ ( k j ) - tilde( x ) _ ( j ) ) ^ ( 2 ) ] ^ ( ( 1 ) / ( 2 ) ) )
  $
  其中，
  $
    overline( x ) _ ( i ) = ( 1 ) / ( m ) sum _ ( k = 1 ) ^ ( m ) x _ ( k i ) , quad overline( x ) _ ( j ) = ( 1 ) / ( m ) sum _ ( k = 1 ) ^ ( m ) x _ ( k j )
  $#note[
    相关系数的绝对值越接近1，表示样本越相似；越接近0，表示样本越不相似。
  ]
]

#definition[夹角余弦][
  样本$x_i$与$x_j$之间的夹角余弦定义为
  $
    s _ ( i j ) = ( sum _ ( k = 1 ) ^ ( m ) x _ ( k i ) x _ ( k j ) ) / ( ( sum _ ( k = 1 ) ^ ( m ) x _ ( k i ) ^ ( 2 ) sum _ ( k = 1 ) ^ ( m ) x _ ( k j ) ^ ( 2 ) ) ^ ( ( 1 ) / ( 2 ) ) )
  $
]

=== 无序属性
+ 连续属性 (continuous attribute)：在定义域上有无穷多个可能的取值
+ 离散属性 (categorical attribute)：在定义域上是有限个可能的取值
+ 有序属性 (ordinal attribute)：例如定义域为{1,2,3}的离散属性，“1”与“2”比较接近、与“3”比较远，称为有序属性
+ 无序属性 (non-ordinal attribute)：例如定义域为{飞机，火车，轮船}这样的离散属性，不能直接在属性值上进行计算，称为无序属性

#definition[VDM][
#mitex(`VDM_p(a, b) = \sum_{i=1}^k \left| \frac{m_{u,a,i}}{m_{u,a}} - \frac{m_{u,b,i}}{m_{u,b}} \right|^p`)

1.  分母 #mi(`m_{u,a}`) 和 #mi(`m_{u,b}`)：
    这就是在整个数据集里，属性 #mi(`u`)（比如“职业”） 取值为 #mi(`a`)（比如“医生”）的总人数。
2.  分子 #mi(`m_{u,a,i}`)：
    这是在第 #mi(`i`) 个簇里，属性 #mi(`u`) 取值为 #mi(`a`) 的人数。
3.  分数 #mi(`\frac{m_{u,a,i}}{m_{u,a}}`)：
    代表了取值为 #mi(`a`) 的样本掉进第 #mi(`i`) 个簇的概率。
    比如：所有的“医生”里，有 #mi(`80\%`) 都在 1 号簇（常出现在医院的组）。
4.  相减并求和 #mi(`\sum |\dots - \dots|^p`)：
    比较“医生”和“护士”在所有 #mi(`k`) 个簇里的分布概率差。如果他们在每个簇里的占比都差不多，减出来的差值就很小，距离也就很近。
]


// 下面这个交给ysz——yyl
MinkovDM


在现实世界里，一个样本往往既有数字（身高、年龄），又有文字（性别、职业）。
前半部分 #mi(`\sum |x_{iu} - x_{ju}|^p`)：这是传统的闵可夫斯基距离，用来算数字属性（有序属性）。

后半部分 #mi(`\sum VDM_p(x_{iu}, x_{ju})`)：这是刚才学的 VDM，用来算文字属性（无序属性）。

逻辑：把能减的数字直接减，不能减的文字用 VDM 算，最后全部加起来开个方。

== 原型聚类
原型是指样本空间中具有代表性的“点”。通常情况下，算法先对原型进行初始化，再对原型进行迭代更新求解。

=== $k$均值聚类
==== $k$均值聚类的算法理念与流程
// ysz删减一下这部分的废话。这部分写得不太好，重点不够明确。——yyl
$k$均值聚类是基于样本集合划分的聚类算法。$k$均值聚类将样本集合划分为$k$个子集，构成$k$个类，将$n$个样本分到$k$个类中，每个样本到其所属类的中心的距离最小。每个样本只能属于一个类，所以*$k$均值聚类是硬聚类*。下面分别介绍$k$均值聚类的模型、策略、算法，讨论算法的特性及相关问题。

给定$n$个样本的集合$X={x_1,x_2,dots,x_n}$，每个样本由一个特征向量表示，特征向量的维数是$m$. $k$均值聚类的目标是将$n$个样本分到$k$个不同的类或簇中，这里假设$k<n$. $k$个类$G_1,G_2,dots,G_k$形成对样本集合$X$的划分，其中$G_i inter G_j=nothing, union_(i=1)^k G_i=X$. 用$C$表示划分，一个划分对应着一个聚类结果。

$k$均值聚类归结为样本集合$X$的划分，或者从样本到类的函数的选择问题。$k$均值聚类的策略是通过损失函数的最小化选取最优的划分或函数$C^*$.

首先采用欧氏距离平方作为样本之间的距离$d(x_i,x_j)$, 然后定义*样本与其所属类的中心之间的距离之和*为损失函数，即
$
  W(C)=sum_(l=1)^k sum_(C(i)=l) norm(x_i- overline(x)_l)^2
$
式中$overline(x)_l=(overline(x)_(1l),overline(x)_2l,dots,overline(x)_(m l))^T$是第$l$个类的均值或中心，$n_l=sum_(i=1)^n I(C(i)=l)$, $W(C)$也称为能量，表示相同类中的样本相似的程度。$k$均值聚类就是求解最优化问题：
$
  C^* &=arg min_C W(C)
$
相似的样本被聚到同类时，损失函数值最小，这个目标函数的最优化能达到聚类的目的。但是，这是一个组合优化问题，$n$个样本分到$k$类，所有可能分法的数目是
$
  S ( n , k ) = ( 1 ) / ( k ! ) sum _ ( l = 1 ) ^ ( k ) ( - 1 ) ^ ( k - l ) binom( k , l ) k ^ ( n )
$
这个数字是指数级的，$k$均值聚类的最优解求解是NP困难问题，现实中采用迭代的方法求解。

$k$均值聚类的算法是一个迭代的过程，每次迭代包括两个步骤。首先选择个$k$类的中心，将样本逐个指派到与其最近的中心的类中，得到一个聚类结果：然后更新每个类的样本的均值，作为类的新的中心；重复以上步骤，直到收敛为止。具体过程如下。

首先，对于给定的中心值$(m_1,m_2,dots,m_k)$，求一个划分$C$，使得目标函数极小化：
$
  min _ ( m _ ( 1 ) , m _ ( 2 ) , dots.h.c , m _ ( k ) ) sum _ ( l = 1 ) ^ ( k ) sum _ ( C ( i ) = l ) ^ ( k ) norm( x _ ( i ) - m _ ( l ) ) ^ ( 2 )
$
就是说在划分确定的情况下，使样本和其所属类的中心之间的距离总和最小。求解结果，对于每个包含$n_l$个样本的类$G_l$，更新其均值$m_l$:
$
  m _ ( l ) = ( 1 ) / ( n _ ( l ) ) sum _ ( C ( i ) = l ) x _ ( i ) , quad l = 1 , 2 , dots.h.c , k
$

#algorithm("K means聚类")[
  *输入*: 样本集 $D = (x_1, x_2, dots, x_m)$；聚类簇数 $k$.

  *输出*: 簇划分 $C = (C_1, C_2, dots, C_k)$.

  过程:
  + 从 $D$ 中随机选择 $k$ 个样本作为初始均值向量 $(mu_1, mu_2, dots, mu_k)$.
  + repeat
    + 令 $C_i = nothing quad (1 lt.eq i lt.eq k)$.
    + for $j = 1, 2, dots, m$ do
      + 计算样本 $x_j$ 与各均值向量 $mu_i (1 lt.eq i lt.eq k)$ 的距离: $d_(j i) = ||x_j - mu_i|| ^ 2$.
      + 根据距离最近的均值向量确定 $x_j$ 的簇标记: 
        $ lambda_j = "arg" min_(i in (1, 2, dots, k)) d_(j i) $
      + 将样本 $x_j$ 划入相应的簇: $C_(lambda_j) = C_(lambda_j) union (x_j)$.
    + end for
    + for $i = 1, 2, dots, k$ do
      + 计算新均值向量: $mu_i' = (1) / (|C_i|) sum_(x in C_i) x$.
      + if $mu_i' eq.not mu_i$ then
        将当前均值向量 $mu_i$ 更新为 $mu_i'$.
      + else 保持当前均值向量不变.
      + end if
    + end for
  + until 当前均值向量均未更新
]

$k$均值聚类算法的复杂度是$O(m n k)$, 其中$m$是样本维数，$n$是样本个数，$k$是类别个数。

==== $k$均值聚类的算法特点与局限性

$k$均值聚类有以下特点：基于划分的聚类方法：类别数$k$事先指定：以欧氏距离平方表示样本之间的距离，以中心或样本的均值表示类别：以样本和其所属类的中心之间的距离的总和为最优化的目标函数；得到的类别是*平坦的、非层次化的*。算法是迭代算法，*不能保证得到全局最优*。

#remark[
  - “平坦”意味着所有生成的簇（Clusters）处于同一层级，地位平等。
  - “非层次化”意味着簇之间不存在“嵌套”或“包含”关系（即没有父类和子类的概念）。
]

$k$均值聚类属于启发式方法，*不能保证收敛到全局最优*，*初始中心的选择会直接影响聚类结果*(选择不同的初始中心会得到不同的聚类结果)。注意，类中心在聚类的过程中会发生移动，但是往往不会移动太大，因为在每一步，样本被分到与其最近的中心的类中。

聚类结果的质量可以用类的平均直径来衡量。一般地，类别数变小时，平均直径会增加; 类别数变大超过某个值以后，平均直径会不变，而这个值正是最优的值。下图说明类别数与平均直径的关系。实验时，可以采用二分查找，快速找到最优的值。

#figure(image("/fig/类别数与平均直径的关系.png", width: 50%), caption: "类别数与平均直径的关系")

K均值适合的聚类数据类型是自然族：球形、等尺寸、等密度。
待聚类数据中各个自然类的样本数据量不平衡时；
待聚类数据中各个自然类的样本密度不一致时；
待聚类数据中各个自然类的样本分布不是球形时；
k均值的效果不太理想。



#note[
  本章介绍两种原型聚类方法：*学习向量量化（LVQ）* 和 *高斯混合聚类（GMM）*。二者的共同思路是用少量"原型"代表整个数据集，每个原型对应一个簇，样本按与各原型的距离或隶属概率完成划分。区别在于原型的形式：LVQ 用一个向量，GMM 用一个完整的高斯分布。
]

=== 学习向量量化（LVQ）

==== 定位与动机

与 k-均值等无监督聚类不同，LVQ（Learning Vector Quantization）*假设数据集带有类别标记*，在学习过程中借助这些监督信息，不断*更新原型向量*，从而得到更符合类别边界的划分结果。

==== 问题设定

给定带标记训练集：

#mitex(`D = \{(\boldsymbol{x}_1, y_1), (\boldsymbol{x}_2, y_2), \ldots, (\boldsymbol{x}_m, y_m)\}`)

其中 #mi(`\boldsymbol{x}_j \in \mathbb{R}^n`) 为 #mi(`n`) 维特征向量，#mi(`y_j \in \mathcal{Y}`) 为类别标记。


目标是学得 #mi(`q`) 个 #mi(`n`) 维*原型向量* #mi(`\{\boldsymbol{p}_1, \boldsymbol{p}_2, \ldots, \boldsymbol{p}_q\}`)，每个 #mi(`\boldsymbol{p}_i`) 附带一个预设的类别标记 #mi(`t_i \in \mathcal{Y}`)。#note[
  这是说，事先决定要用 q 个代表点来划分空间，并且每个代表点预先指定它代表哪个类别。比如用 3 个代表点，2 个代表猫、1 个代表狗。]
训练完成后，每个原型向量定义其对应的 *Voronoi 区域*——样本空间中与该原型距离最近的所有点都归入对应的簇。

==== 算法流程

#algorithm[

  *输入：* 样本集 $D = {(x_1, y_1), (x_2, y_2), ..., (x_m, y_m)}$; \
  #h(3em) 原型向量个数 $q$ 及各原型对应的类别标记 ${t_1, t_2, ..., t_q}$; \
  #h(3em) 学习率 $eta in (0, 1)$.

  *过程：*
  + 随机初始化一组原型向量 ${p_1, p_2, ..., p_q}$
  + *repeat*
  
    - 从 $D$ 中随机取一个样本 $(x_j, y_j)$

    - 计算 $x_j$ 与每个 $p_i$ 的距离：$d_i = norm(x_j - p_i)$

    - 找到最近原型：$p^* = arg min_(i in {1,...,q}) d_i$，记其类别标记为 $t^*$

    - *if* $y_j = t^*$ *then* #h(2em) \# 类别相同，令 $p^*$ 靠近 $x_j$

        $p' = p^* + eta dot (x_j - p^*)$

    - *else* #h(4.1em) \# 类别不同，令 $p^*$ 远离 $x_j$

        $p' = p^* - eta dot (x_j - p^*)$
#note[
更新规则的几何解释

两种更新方式的本质是调整 #mi(`\boldsymbol{p}^*`)的位置。

*情形一：标记相同，#mi(`\boldsymbol{p}^*`)靠近*

#mitex(`\boldsymbol{p}' = \boldsymbol{p}^* + \eta \cdot (\boldsymbol{x}_j - \boldsymbol{p}^*)`)

更新后两者距离为：

#mitex(`\|\boldsymbol{p}' - \boldsymbol{x}_j\| = (1 - \eta)\,\|\boldsymbol{p}^* - \boldsymbol{x}_j\|`)

即距离缩短为原来的 #mi(`(1-\eta)`) 倍，#mi(`\boldsymbol{p}^*`) 向 #mi(`\boldsymbol{x}_j`) 移动。

*情形二：标记不同，#mi(`\boldsymbol{p}^*`)远离*

#mitex(`\boldsymbol{p}' = \boldsymbol{p}^* - \eta \cdot (\boldsymbol{x}_j - \boldsymbol{p}^*)`)

更新后两者距离为：

#mitex(`\|\boldsymbol{p}' - \boldsymbol{x}_j\| = (1 + \eta)\,\|\boldsymbol{p}^* - \boldsymbol{x}_j\|`)

即距离扩大为原来的 #mi(`(1+\eta)`) 倍，#mi(`\boldsymbol{p}^*`) 远离 #mi(`\boldsymbol{x}_j`)。

#note[
  *学习率 #mi(`\eta`) 的作用*：#mi(`\eta`) 越大，原型向量对单个样本的响应越激烈；#mi(`\eta`) 越小，收敛越平稳但速度较慢。实践中通常随迭代轮次衰减。
]
    ]


  3. 将 $p^*$ 更新为 $p'$

  *until* 满足停止条件

  *输出：* 原型向量 ${p_1, p_2, ..., p_q}$
]


==== Voronoi 划分与聚类效果

训练完成后，#mi(`q`) 个原型向量将样本空间划分为 #mi(`q`) 个 Voronoi 区域：样本 #mi(`\boldsymbol{x}`) 被划入与其欧氏距离最近的原型 #mi(`\boldsymbol{p}_{i^*}`) 所对应的簇 #mi(`C_{i^*}`)。随着迭代轮数增加（50 → 100 → 200 → 400 轮），各原型不断调整位置，簇的边界逐渐清晰、稳定。

=== 高斯混合聚类（GMM）

LVQ 以一个点代表一个簇，表达能力有限。高斯混合模型（Gaussian Mixture Model, GMM）改用一个*高斯分布*来刻画每个簇，能够表达更丰富的形状（椭圆形、旋转簇等），同时通过软分配给出每个样本属于各簇的概率。

==== 基础：多元高斯分布

对 #mi(`n`) 维随机向量 #mi(`\boldsymbol{x}`)，若其服从均值为 #mi(`\boldsymbol{\mu}`)、协方差矩阵为 #mi(`\boldsymbol{\Sigma}`) 的高斯分布，概率密度函数为：

#mitex(`p(\boldsymbol{x}) = \frac{1}{(2\pi)^{n/2}|\boldsymbol{\Sigma}|^{1/2}} \exp\!\left(-\frac{1}{2}(\boldsymbol{x} - \boldsymbol{\mu})^\top \boldsymbol{\Sigma}^{-1} (\boldsymbol{x} - \boldsymbol{\mu})\right)`)

简记为 #mi(`p(\boldsymbol{x} \mid \boldsymbol{\mu}, \boldsymbol{\Sigma})`)，其中：

- #mi(`\boldsymbol{\mu}`)：#mi(`n`) 维均值向量，描述分布的中心位置；
- #mi(`\boldsymbol{\Sigma}`)：#mi(`n \times n`) 正定协方差矩阵，描述分布的形状与方向；
- #mi(`|\boldsymbol{\Sigma}|`)：#mi(`\boldsymbol{\Sigma}`) 的行列式，出现在归一化常数中。

==== 高斯混合分布的定义

高斯混合模型将 #mi(`k`) 个高斯分量加权叠加：

#mitex(`p_{\mathcal{M}}(\boldsymbol{x}) = \sum_{i=1}^k \alpha_i \cdot p(\boldsymbol{x} \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)`)

每个分量由三元组 #mi(`(\alpha_i, \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)`) 描述：

#table(
  columns: 3,
  [参数], [含义], [约束],
  [#mi(`\alpha_i`)], [混合系数（先验权重）], [#mi(`\alpha_i > 0`)，且 #mi(`\displaystyle\sum_{i=1}^k \alpha_i = 1`)],
  [#mi(`\boldsymbol{\mu}_i`)], [第 #mi(`i`) 个分量的均值向量], [无约束],
  [#mi(`\boldsymbol{\Sigma}_i`)], [第 #mi(`i`) 个分量的协方差矩阵], [正定矩阵]
)

==== 样本生成过程与隐变量

高斯混合模型的所有样本来源可以理解为一个两阶段生成过程：
// warning：以下部分未审查，极有可能存在错误！
+ 以先验概率 #mi(`\alpha_i`) 选择第 #mi(`i`) 个混合成分。令*隐变量* #mi(`z_j \in \{1, \ldots, k\}`) 表示生成的样本 #mi(`\boldsymbol{x}_j`) 所来自的混合成分，即 #mi(`P(z_j = i) = \alpha_i`)；
+ 从选定的高斯分量 #mi(`\mathcal{N}(\boldsymbol{\mu}_j, \boldsymbol{\Sigma}_j)`) 中采样，得到观测样本 #mi(`\boldsymbol{x}_j`)。

实际上 #mi(`z_j`) 未知，利用贝叶斯定理求 #mi(`z_j`) 的*后验概率*（已观测到的 #mi(`\boldsymbol{x}_j`) 来自第 #mi(`i`) 个分量的概率）：

#mitex(`\gamma_{ji} = p_{\mathcal{M}}(z_j = i \mid \boldsymbol{x}_j) = \frac{P(z_j=i) \cdot p(\boldsymbol{x}_j \mid z_j=i)}{p_{\mathcal{M}}(\boldsymbol{x}_j)} = \frac{\alpha_i \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)}{\displaystyle\sum_{l=1}^k \alpha_l \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_l, \boldsymbol{\Sigma}_l)}`)

#note[
  #mi(`\gamma_{ji}`) 是软聚类的核心量：它不是 0/1 的硬分配，而是样本 #mi(`\boldsymbol{x}_j`) 对各成分连续的隶属概率，满足 #mi(`\sum_{i=1}^k \gamma_{ji} = 1`)。
]

==== 聚类规则

求得所有 #mi(`\gamma_{ji}`) 后，将样本 #mi(`\boldsymbol{x}_j`) 划入使后验概率最大的那个成分所对应的簇：

#mitex(`\lambda_j = \mathop{\arg\max}_{1 \le i \le k}\ \gamma_{ji}`)

*从原型聚类角度理解*：高斯混合聚类以高斯分布作为原型，簇划分由后验概率（样本属于该成分的平均后验概率）确定，即每个样本被划入后验概率最大的簇标记所对应的簇。

==== 参数估计：最大对数似然

给定样本集 #mi(`D`)，模型参数 #mi(`\{(\alpha_i, \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)\}`) 通过最大化对数似然来确定：

#mitex(`LL(D) = \ln \prod_{j=1}^m p_{\mathcal{M}}(\boldsymbol{x}_j) = \sum_{j=1}^m \ln \left(\sum_{i=1}^k \alpha_i \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)\right)`)

对 #mi(`\boldsymbol{\mu}_i`) 求偏导并令其为零：

#mitex(`\frac{\partial\, LL(D)}{\partial\, \boldsymbol{\mu}_i} = \sum_{j=1}^m \frac{\alpha_i \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)}{\displaystyle\sum_l \alpha_l \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_l, \boldsymbol{\Sigma}_l)} \cdot (\boldsymbol{x}_j - \boldsymbol{\mu}_i) = \sum_{j=1}^m \gamma_{ji}\,(\boldsymbol{x}_j - \boldsymbol{\mu}_i) = 0`)

解出 #mi(`\boldsymbol{\mu}_i`)，并类似地对 #mi(`\boldsymbol{\Sigma}_i`) 和 #mi(`\alpha_i`)（利用拉格朗日乘子法处理 #mi(`\sum \alpha_i = 1`) 的约束）求导，得到参数的闭式更新公式：

#mitex(`\boldsymbol{\mu}_i' = \frac{\displaystyle\sum_{j=1}^m \gamma_{ji}\, \boldsymbol{x}_j}{\displaystyle\sum_{j=1}^m \gamma_{ji}}`)

#mitex(`\boldsymbol{\Sigma}_i' = \frac{\displaystyle\sum_{j=1}^m \gamma_{ji}\,(\boldsymbol{x}_j - \boldsymbol{\mu}_i)(\boldsymbol{x}_j - \boldsymbol{\mu}_i)^\top}{\displaystyle\sum_{j=1}^m \gamma_{ji}}`)

#mitex(`\alpha_i' = \frac{\displaystyle\sum_{j=1}^m \gamma_{ji}}{m}`)

*直观理解*：#mi(`\boldsymbol{\mu}_i'`) 是所有样本以后验概率 #mi(`\gamma_{ji}`) 为权重的加权均值；#mi(`\boldsymbol{\Sigma}_i'`) 是对应的加权协方差；#mi(`\alpha_i'`) 等于各样本归属第 #mi(`i`) 个成分的平均后验概率。

==== EM 算法框架

由于 #mi(`\gamma_{ji}`) 依赖参数、参数又依赖 #mi(`\gamma_{ji}`)，形成循环依赖，无法直接求解，因此采用 *EM（期望最大化）算法*迭代求解：

- *E 步（Expectation）*：固定当前参数 #mi(`\{(\alpha_i, \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)\}`)，按 2.3 节的公式计算每个样本对每个成分的后验概率 #mi(`\gamma_{ji}`)；
- *M 步（Maximization）*：固定 #mi(`\gamma_{ji}`)，按 2.5 节的公式更新所有参数；
- 重复 E/M 两步直至收敛（参数变化量低于阈值）。

每次迭代都保证对数似然不减，算法收敛至局部最优。

==== 完整算法伪代码
#algorithm[
  *输入*：样本集 #mi(`D = \{\boldsymbol{x}_1, \boldsymbol{x}_2, \ldots, \boldsymbol{x}_m\}`)；高斯混合成分个数 #mi(`k`)

  *过程*：
  + 初始化高斯混合分布的模型参数 #mi(`\{(\alpha_i, \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i) \mid 1 \leqslant i \leqslant k\}`)
  + repeat
  + *[E步]* for #mi(`j = 1, \ldots, m`) do
  + 根据当前参数计算 #mi(`\gamma_{ji}`)（各成分生成样本 #mi(`\boldsymbol{x}_j`) 的后验概率）
  + end for
  + *[M步]* for #mi(`i = 1, \ldots, k`) do
  + 计算新均值向量：#mi(`\boldsymbol{\mu}_i' = (\sum_j \gamma_{ji} \boldsymbol{x}_j) / (\sum_j \gamma_{ji})`)
  + 计算新协方差矩阵：#mi(`\boldsymbol{\Sigma}_i' = (\sum_j \gamma_{ji} (\boldsymbol{x}_j - \boldsymbol{\mu}_i)(\boldsymbol{x}_j - \boldsymbol{\mu}_i)^\top) / (\sum_j \gamma_{ji})`)
  + 计算新混合系数：#mi(`\alpha_i' = (\sum_j \gamma_{ji}) / m`)
  + end for
  + 将模型参数 #mi(`\{(\alpha_i, \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)\}`) 更新为 #mi(`\{(\alpha_i', \boldsymbol{\mu}_i', \boldsymbol{\Sigma}_i')\}`)
  + until 满足停止条件
  + *[划簇]* #mi(`C_i = \varnothing`)（#mi(`1 \leqslant i \leqslant k`)）
  + for #mi(`j = 1, \ldots, m`) do
  + 令 #mi(`\lambda_j = \arg\max_i \gamma_{ji}`)，根据 #mi(`\gamma_{ji}`) 确定 #mi(`\boldsymbol{x}_j`) 的簇标记 #mi(`\lambda_j`)
  + 将 #mi(`\boldsymbol{x}_j`) 并入相应的簇：#mi(`C_{\lambda_j} = C_{\lambda_j} \cup \{\boldsymbol{x}_j\}`)
  + end for
  + return 簇划分结果 #mi(`C = \{C_1, C_2, \ldots, C_k\}`)
]

==== 聚类效果

随着迭代轮数增加（5 → 10 → 20 → 50 轮），各高斯分量的均值和协方差逐渐收敛，簇的划分趋于稳定清晰。

=== 两种方法横向对比

#table(
  columns: 3,
  [维度], [LVQ], [高斯混合聚类],
  [原型形式], [向量（空间中一个点）], [高斯分布（均值 + 协方差）],
  [是否需要标记], [是（利用类别标记）], [否（纯无监督）],
  [簇的表达能力], [凸、各向同性区域], [可表达椭圆形、旋转簇],
  [样本归属方式], [硬分配（最近原型）], [软分配（后验概率最大）],
  [求解方式], [在线迭代（逐样本更新）], [批量迭代（EM 算法）],
  [参数数量], [#mi(`q \times n`)（原型坐标）], [#mi(`k \times (1 + n + n^2)`)（混合系数、均值、协方差）]
)

=== 关键概念速查

*Voronoi 区域*：每个原型向量"管辖"的样本空间子集——所有与该原型欧氏距离最近的点。LVQ 的聚类边界即由 Voronoi 图给出。

*混合系数 #mi(`\alpha_i`)*：先验概率，反映第 #mi(`i`) 个高斯分量在整体分布中的比重，可理解为"随机抽取一个样本，它来自成分 #mi(`i`) 的先验概率"。

*后验概率 #mi(`\gamma_{ji}`)*：在观测到 #mi(`\boldsymbol{x}_j`) 之后，该样本来自第 #mi(`i`) 个成分的概率。它综合了先验权重 #mi(`\alpha_i`) 和该分量对 #mi(`\boldsymbol{x}_j`) 的拟合程度 #mi(`p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)`)，是软聚类决策的依据。

*EM 算法*：专门处理含隐变量的最大似然估计问题的迭代框架。E 步计算隐变量的期望（即后验概率），M 步在给定期望下最大化似然函数，两步交替直至收敛。每次迭代保证对数似然单调不减。

*软分配 vs. 硬分配*：GMM 的 #mi(`\gamma_{ji}`) 是连续概率值（软分配），每个样本同时"部分属于"多个簇；LVQ 和 k-均值则将样本唯一地分配给一个簇（硬分配）。软分配在簇边界附近更具鲁棒性，也更自然地表达了不确定性。

== 密度聚类

=== DBSCAN 聚类密度

密度聚类也称为*基于密度的聚类*（density-based clustering），此类算法假设聚类结构能通过*样本分布的紧密程度*来确定。通常情况下，密度聚类算法从样本密度的角度来考察样本之间的可连接性，并基于可连接样本不断扩展聚类簇来获得最终的聚类结果。

*DBSCAN*是一种基于密度的聚类算法（density-based clustering），其基于一组"邻域"参数（#mi(`\epsilon`)、#mi(`MinPts`)）来刻画样本分布的紧密程度。

给定样本集 #mi(`D = \{\boldsymbol{x}_1, \boldsymbol{x}_2, \ldots, \boldsymbol{x}_m\}`)，定义如下几个概念：

#definition[$epsilon$-邻域][
  对 #mi(`\boldsymbol{x}_j \in D`)，其 #mi(`\epsilon`)-邻域包含样本集 #mi(`D`) 中与 #mi(`\boldsymbol{x}_j`) 的距离*不大于* #mi(`\epsilon`) 的样本（假设为欧氏距离）：
  
  #mitex(`N_\epsilon(\boldsymbol{x}_j) = \{\boldsymbol{x}_i \in D \mid \text{dist}(\boldsymbol{x}_i, \boldsymbol{x}_j) \leq \epsilon\}`)
]

#definition[核心对象][
  若 #mi(`\boldsymbol{x}_j`) 的 #mi(`\epsilon`)-邻域至少包含 #mi(`MinPts`) 个样本，则 #mi(`\boldsymbol{x}_j`) 是一个核心对象：
  
  #mitex(`|N_\epsilon(\boldsymbol{x}_j)| \geqslant MinPts`)
]

#definition[密度直达][
  若 #mi(`\boldsymbol{x}_j`) 位于 #mi(`\boldsymbol{x}_i`) 的 #mi(`\epsilon`)-邻域中，且 #mi(`\boldsymbol{x}_i`) 是核心对象，则称 #mi(`\boldsymbol{x}_j`) 由 #mi(`\boldsymbol{x}_i`) *密度直达*。
]

#definition[密度可达][
  对 #mi(`\boldsymbol{x}_i`) 与 #mi(`\boldsymbol{x}_j`)，若存在样本序列 #mi(`\boldsymbol{p}_1, \boldsymbol{p}_2, \ldots, \boldsymbol{p}_n`)，其中 #mi(`\boldsymbol{p}_1 = \boldsymbol{x}_i`)，#mi(`\boldsymbol{p}_n = \boldsymbol{x}_j`)且 #mi(`\boldsymbol{p}_{i+1}`) 由 #mi(`\boldsymbol{p}_i`) 密度直达，则称 #mi(`\boldsymbol{x}_j`) 由 #mi(`\boldsymbol{x}_i`) *密度可达*。
]

#definition[密度相连][
  对 #mi(`\boldsymbol{x}_i`) 与 #mi(`\boldsymbol{x}_j`)，若存在 #mi(`\boldsymbol{x}_k`) 使得 #mi(`\boldsymbol{x}_i`) 与 #mi(`\boldsymbol{x}_j`) 均由 #mi(`\boldsymbol{x}_k`) 密度可达，则称 #mi(`\boldsymbol{x}_i`) 与 #mi(`\boldsymbol{x}_j`) *密度相连*。
]

#note[
*形象理解*：

- #mi(`\epsilon`) 描述了某一样本的邻域距离阈值
- #mi(`MinPts`) 描述了某一样本的距离为 #mi(`\epsilon`) 的邻域中样本个数的阈值
- *密度直达*：就像"密切接触者"——直接在一个邻域内
- *密度可达*：就像"次密接"——通过中间人间接连接
- *密度相连*：就像"次次密接"——有一个共同的源头

#figure(image("/assets/image-15.png", width: 60%), caption: "密度直达/可达/相连的概念图示（红色点为核心对象，MinPts = 3")

- 绿色点均为异常点，既不是核心点也不是边界点
]

=== DBSCAN 聚类簇的定义

基于上述概念，DBSCAN 将"簇"定义为：*由密度可达关系导出的最大的密度相连样本集合*。给定邻域参数（#mi(`\epsilon`)、#mi(`MinPts`)），簇 #mi(`C \subseteq D`) 是满足以下性质的非空样本子集：

1. *连续性*：#mi(`\boldsymbol{x}_i \in C`)，#mi(`\boldsymbol{x}_j \in C`) #mi(`\Rightarrow`) #mi(`\boldsymbol{x}_i`) 与 #mi(`\boldsymbol{x}_j`) 密度相连
2. *最大性*：#mi(`\boldsymbol{x}_i \in C`)，若 #mi(`\boldsymbol{x}_j`) 由 #mi(`\boldsymbol{x}_i`) 密度可达 #mi(`\Rightarrow`) #mi(`\boldsymbol{x}_j \in C`)

#remark[
  一个 DBSCAN 的簇里面可以有*一个或者多个核心对象*：
  
  - 如果只有一个核心对象，则簇里其他的非核心对象样本都在这个核心对象的 #mi(`\epsilon`)-邻域里
  - 如果有多个核心对象，则簇里的任意一个核心对象的 #mi(`\epsilon`)-邻域中一定有一个其他的核心对象，否则这两个核心对象无法密度可达。这些核心对象的 #mi(`\epsilon`)-邻域里所有的样本的集合组成的一个 DBSCAN 聚类簇。
]

=== DBSCAN 聚类步骤

DBSCAN 算法初始任意选择一个核心对象，然后*找到所有这个核心对象能够密度可达的样本集合，即为一个聚类簇*。接着继续选择另一个没有类别的核心对象去寻找密度可达的样本集合，这样就得到另一个聚类簇。*一直运行到所有核心对象都有类别为止*。

从任意核心对象出发，基于密度可达性扩展聚类。完成一簇后再挑选未被选中的核心点重复过程，直至遍历完所有核心点。

==== 算法流程

#algorithm[
  *输入*：样本集 #mi(`D = \{\boldsymbol{x}_1, \boldsymbol{x}_2, \ldots, \boldsymbol{x}_m\}`)；邻域参数（#mi(`\epsilon`), #mi(`MinPts`))。

  *输出*：簇划分 #mi(`\mathcal{C} = \{C_1, C_2, \ldots, C_k\}`)。

  过程：
  
  // 第一阶段：找出所有核心对象
  + 初始化核心对象集合：#mi(`\Omega = \varnothing`)
  + for #mi(`j = 1, 2, \ldots, m`) do
    + 确定样本 #mi(`\boldsymbol{x}_j`) 的 #mi(`\epsilon`)-邻域 #mi(`N_\epsilon(\boldsymbol{x}_j)`)
    + if #mi(`|N_\epsilon(\boldsymbol{x}_j)| \geqslant MinPts`) then
      + 将样本 #mi(`\boldsymbol{x}_j`) 加入核心对象集合：#mi(`\Omega = \Omega \cup \{\boldsymbol{x}_j\}`)
    + end if
  + end for
  
  // 第二阶段：基于核心对象扩展聚类簇
  + 初始化聚类簇数：#mi(`k = 0`)
  + 初始化未访问样本集合：#mi(`\Gamma = D`)
  + while #mi(`\Omega \neq \varnothing`) do
    + 记录当前未访问样本集合：#mi(`\Gamma_{\text{old}} = \Gamma`)
    + 随机选取一个核心对象 #mi(`\boldsymbol{o} \in \Omega`)，初始化队列 #mi(`Q = \langle \boldsymbol{o} \rangle`)
    + #mi(`\Gamma = \Gamma \setminus \{\boldsymbol{o}\}`)
    + while #mi(`Q \neq \varnothing`) do
      + 取出队列 #mi(`Q`) 中的首个样本 #mi(`\boldsymbol{q}`)
      + if #mi(`|N_\epsilon(\boldsymbol{q})| \geqslant MinPts`) then
        + 令 #mi(`\Delta = N_\epsilon(\boldsymbol{q}) \cap \Gamma`)
        + 将 #mi(`\Delta`) 中的样本加入队列 #mi(`Q`)
        + #mi(`\Gamma = \Gamma \setminus \Delta`)
      + end if
    + end while
    + #mi(`k = k + 1`)，生成聚类簇 #mi(`C_k = \Gamma_{\text{old}} \setminus \Gamma`)
    + #mi(`\Omega = \Omega \setminus C_k`)
  + end while
]

#unim[
*算法执行过程示意*：

// #figure(image("/fig/DBSCAN_执行过程.png", width: 60%), caption: "DBSCAN 聚类算法的执行过程动画示意（#mi(`\epsilon = 1.00`)，#mi(`MinPts = 4`))")
// ]

// #figure(image("/fig/DBSCAN_Cluster_Process.png", width: 60%), caption: "DBSCAN 聚类过程可视化（月亮形数据集)")
]

=== DBSCAN 聚类分析

==== 参数对聚类结果的影响

DBSCAN 算法的性能高度依赖于两个参数 #mi(`\epsilon`) 和 #mi(`MinPts`) 的选择。不同参数组合会导致截然不同的聚类结果。

// #figure(
//   grid(
//     columns: 4,
//     rows: 2,
//     column-gutter: 4pt,
//     row-gutter: 4pt,
//     image("/fig/DBSCAN_eps_0.05.png"),
//     image("/fig/DBSCAN_eps_0.1_minpts_5.png"),
//     image("/fig/DBSCAN_eps_0.1_cluster_3.png"),
//     image("/fig/DBSCAN_eps_0.1_minpts_10.png"),
//     image("/fig/DBSCAN_eps_0.15.png"),
//     image("/fig/DBSCAN_eps_0.2.png"),
//     image("/fig/DBSCAN_minpts_15.png"),
//     image("/fig/DBSCAN_minpts_20.png"),
//   ),
//   caption: "不同参数下的 DBSCAN 聚类结果对比"
// )

#table(
  columns: 4,
  [参数设置], [聚类数], [效果分析], [原因],
  [#mi(`\epsilon = 0.05`), #mi(`MinPts = 5`)], [38], [过碎], [#mi(`\epsilon`) 太小，邻域过小，难以形成密度可达链],
  [#mi(`\epsilon = 0.1`), #mi(`MinPts = 5`)], [5], [较合理], [参数适中，能正确识别两个环形簇],
  [#mi(`\epsilon = 0.15`), #mi(`MinPts = 5`)], [3], [偏少], [#mi(`\epsilon`) 增大，两个环开始合并],
  [#mi(`\epsilon = 0.2`), #mi(`MinPts = 5`)], [2], [过少], [#mi(`\epsilon`) 太大，所有点连成一个大簇],
  [#mi(`\epsilon = 0.1`), #mi(`MinPts = 10`)], [3], [较合理], [增大 #mi(`MinPts`) 使簇更紧密],
  [#mi(`\epsilon = 0.1`), #mi(`MinPts = 15`)], [7], [过碎], [#mi(`MinPts`) 太大，核心对象减少],
  [#mi(`\epsilon = 0.1`), #mi(`MinPts = 20`)], [17], [过碎], [核心对象进一步减少，簇被割裂],
)

#note[
  *参数选择经验*：
  
  - #mi(`\epsilon`) *过小* #mi(`\rightarrow`) 簇数过多，大部分点被识别为噪声
  - #mi(`\epsilon`) *过大* #mi(`\rightarrow`) 簇数过少，多个簇被合并
  - #mi(`MinPts`) *过小* #mi(`\rightarrow`) 容易将噪声误判为核心对象
  - #mi(`MinPts`) *过大* #mi(`\rightarrow`) 核心对象减少，簇被割裂
  
  *实用技巧*：通常先固定 #mi(`MinPts`)（经验值 4~10），然后通过绘制 K-距离图（K-distance graph）来选择合适的 #mi(`\epsilon`) 值。
]

==== DBSCAN 算法特点

一般来说，DBSCAN 算法有以下几个特点：

#table(
  columns: 2,
  [特点], [说明],
  [需要确定参数], [需要提前确定 #mi(`\epsilon`) 和 #mi(`MinPts`) 值],
  [无需预设簇数], [*不需要*提前设置聚类类别的个数（与 K-means 的关键区别）],
  [对初值不敏感], [对初始核心对象选取不敏感],
  [对噪声不敏感], [能有效识别并处理异常点/噪声],
  [密度不均效果差], [对*密度不均*的数据聚合效果不好],
)

#unim[
*DBSCAN 与 K-means 的对比*：

| 特性 | K-means | DBSCAN |
|------|---------|--------|
| 簇形状 | 球形/凸形 | 任意形状 |
| 簇数 | 需预先指定 | 自动确定 |
| 噪声处理 | 无法处理 | 能识别噪声 |
| 参数 | 簇数 #mi(`k`) | #mi(`\epsilon`), #mi(`MinPts`) |
| 密度不均 | 效果好 | 效果差 |
| 复杂度 | #mi(`O(tkmn)`) | #mi(`O(mn)`) 或使用空间索引 #mi(`O(n \log n)`) |
]

=== 算法复杂度分析

DBSCAN 算法的时间复杂度主要取决于邻域查询的效率：

- *朴素实现*：对每个样本计算与所有其他样本的距离，复杂度为 #mi(`O(m^2)`)，其中 #mi(`m`) 为样本数
- *使用空间索引*（如 k-d tree、R-tree）：可将复杂度降至 #mi(`O(m \log m)`)
- *最坏情况*：当所有点都是核心对象且密度相连时，仍需遍历所有点对，复杂度退化为 #mi(`O(m^2)`)

空间复杂度为 #mi(`O(m)`)，主要用于存储样本集、核心对象集合和聚类结果。

=== 应用场景与局限性

==== 适用场景

1. *簇形状不规则*：数据呈现非球形、非凸形的簇结构
2. *含噪声数据*：数据集中存在异常点或噪声，需要鲁棒的聚类方法
3. *簇数未知*：无法预先确定聚类簇的个数
4. *密度可分*：不同簇之间存在密度差异，簇内密度相对均匀

==== 局限性

1. *密度不均*：当数据集中不同簇的密度差异较大时，难以用一组参数同时处理好所有簇
2. *高维数据*：在高维空间中，"距离"的概念变得模糊（维度灾难），#mi(`\epsilon`) 的选择变得困难
3. *参数敏感*：#mi(`\epsilon`) 和 #mi(`MinPts`) 的选择对结果影响显著，需要经验或交叉验证
4. *边界点归属*：边界点可能被多个簇共享，DBSCAN 通常将其随机分配给最先发现的簇

#remark[
  *改进算法*：针对 DBSCAN 的局限性，研究者提出了多种改进算法：
  
  - *OPTICS*：通过可达距离图展示不同密度下的聚类结构，避免了单一参数选择的困难
  - *HDBSCAN*：层次 DBSCAN，自动确定参数，能处理密度不均的数据
  - *DENCLUE*：基于密度分布函数的聚类方法
]


== 层次聚类

=== 层次聚类思想

层次聚类（Hierarchical Clustering）假设类别之间存在层次结构，将样本聚到层次化的类中。因为每个样本只属于一个类，所以*层次聚类属于硬聚类*。

层次聚类算法可以*自上而下*或*自下而上*实现：

#table(
  columns: 3,
  [方法], [方向], [核心思想],
  [凝聚式（agglomerative）], [自下而上], [将每个对象作为单独的一组，然后根据同类相近、异类相异的原则，合并对象，直到所有的组合并成一个，或达到一个终止条件为止],
  [分裂式（divisive）], [自上而下], [将所有的对象置于一类，在迭代的每一步中，一个类不断地分为更小的类，直到每个对象在单独的一个类中，或达到一个终止条件],
)

// #figure(
//   grid(
//     columns: 2,
//     column-gutter: 8pt,
//     image("/fig/层次聚类_散点图.png"),
//     image("/fig/层次聚类_树状图.png"),
//   ),
//   caption: "层次聚类示意图（左：样本分布；右：对应的树状图 Dendrogram）"
// )

层次聚类其实是一组*有依赖关系*的聚类，后一聚类类依赖前一聚类结果，是在前一聚类结果的基础上，按照一定规则进行新的聚类。因为有依赖关系，因此这一组聚类就形成一个*树状结构*。

#remark[
  凝聚式层次聚类需要预先确定下面3个要素：
  1. *距离或相似度*：如何度量样本或类之间的距离
  2. *合并规则*：选择哪两个类进行合并
  3. *停止条件*：何时终止聚类过程
]

=== 凝聚式层次聚类算法

以下讨论的是*凝聚式层次聚类法*。

==== 算法描述

凝聚式层次聚类的核心思想是：从每个样本自成一类开始，逐步合并距离最近的两个类，直到满足停止条件。

#algorithm[
  *输入*：样本集合 #mi(`D = \{\boldsymbol{x}_1, \boldsymbol{x}_2, \ldots, \boldsymbol{x}_N\}`)；停止条件。

  *输出*：对样本集合的一个层次化聚类（树状结构）。

  过程：
  
  // 初始化
  + N个初始模式样本自成一类，即建立N类：#mi(`G_1(0), G_2(0), \ldots, G_N(0)`)
  + 计算各类之间（即各样本间）的距离，得一 #mi(`N \times N`) 维距离矩阵 #mi(`\boldsymbol{D}(0)`)
  
  // 迭代合并
  + 假设已求得距离矩阵 #mi(`\boldsymbol{D}(n)`)（#mi(`n`) 为逐次聚类合并的次数），找出 #mi(`\boldsymbol{D}(n)`) 中的最小元素，将其对应的两类合并为一类。由此建立新的分类：#mi(`G_1(n+1), G_2(n+1), \ldots`)
  + 再次计算：经过合并后，各个类别之间的距离，得 #mi(`\boldsymbol{D}(n+1)`)。显然，#mi(`\boldsymbol{D}(n+1)`) 的维数是 #mi(`\boldsymbol{D}(n)`) 的维数减一。
  + 跳至上一步，重复计算及合并。
  
  // 结束条件（满足其一即可）
  + *取距离阈值 #mi(`T`)*：当 #mi(`\boldsymbol{D}(n)`) 的最小分量*超过给定值 #mi(`T`)* 时（即：当前各聚类类间的距离，都足够大），算法停止。所得即为聚类结果。
  + *不设阈值*：一直将全部样本聚成一类为止，输出聚类的分级树（得到全部可能的聚类结果——谱系聚类的名称由来）。
]

这里我们举一个欧氏距离的例子，可以看出聚合层次聚类算法的复杂度是 #mi(`O(n^3 m)`)，其中 #mi(`m`) 是样本的维数，#mi(`n`) 是样本个数。通过使用*优先队列（堆）*或 k-d tree 等数据结构优化，可以将复杂度降低到 #mi(`O(n^2 \log n)`) 甚至更低，但最原始的朴素实现是 #mi(`O(n^3 m)`)。

#unim[
*关键点理解*：

- 层次聚类的每一次合并都*依赖前一次的结果*，因此形成一个不可逆的树状结构
- 一旦两个类被合并，就无法再分开（这是与 K-means 的本质区别）
- 最终得到的树状图（Dendrogram）可以在任意高度"切割"，得到不同粒度的聚类结果
]

=== 类间距离计算方法

层次聚类最关键的一步就是*计算两个类簇的相似度*。定义类间距离的方法不同，分类结果会不太一致。

==== 最短距离法（单链距离法）

如 #mi(`H`)、#mi(`K`) 是两个聚类，则两类间的最短距离定义为：

#mitex(`D_{HK} = \min \{ D(\boldsymbol{X}_H, \boldsymbol{X}_K) \} \quad \boldsymbol{X}_H \in H, \boldsymbol{X}_K \in K`)

其中 #mi(`D(\boldsymbol{X}_H, \boldsymbol{X}_K)`) 为 #mi(`H`) 类中的某个样本 #mi(`\boldsymbol{X}_H`) 和 #mi(`K`) 类中的某个样本 #mi(`\boldsymbol{X}_K`) 之间的欧氏距离。

#mi(`D_{HK}`)：#mi(`H`) 类中所有样本与 #mi(`K`) 类中所有样本之间的最小距离。

若 #mi(`K`) 类由 #mi(`I`) 和 #mi(`J`) 两类合并而成，且 #mi(`H`) 与 #mi(`I`)、#mi(`H`) 与 #mi(`J`) 的距离，已先期算出，则得到*递推公式*：

#mitex(`D_{HK} = \min \{ D_{HI}, D_{HJ} \}`)

#unim[
*特点*：最短距离法的*包容性极强*——只要两个簇中有一对样本距离足够近，就会将两个簇合并。这可能导致"链式效应"（chaining effect），即簇被拉得很长。
]

==== 最长距离法（全链距离法）

#mitex(`D_{HK} = \max \{ D(\boldsymbol{X}_H, \boldsymbol{X}_K) \} \quad \boldsymbol{X}_H \in H, \boldsymbol{X}_K \in K`)

若 #mi(`K`) 类由 #mi(`I`)、#mi(`J`) 两类合并而成，则

#mitex(`
\begin{aligned}
D_{HI} &= \max \{ D(\boldsymbol{X}_H, \boldsymbol{X}_I) \} \quad \boldsymbol{X}_H \in H, \boldsymbol{X}_I \in I \\
D_{HJ} &= \max \{ D(\boldsymbol{X}_H, \boldsymbol{X}_J) \} \quad \boldsymbol{X}_H \in H, \boldsymbol{X}_J \in J
\end{aligned}
`)

有递推公式：

#mitex(`D_{HK} = \max \{ D_{HI}, D_{HJ} \}`)

#unim[
*特点*：最长距离法*只要存在缺点就坚决不合并*——只有当两个簇中所有样本对之间的距离都较小时，才会合并。这倾向于产生紧凑的、球形的簇。
]

==== 类平均距离法（组平均距离法）

#mitex(`D_{HK} = \sqrt{ \frac{1}{n_H n_K} \sum_{i \in H} \sum_{j \in K} d_{ij}^2 }`)

其中 #mi(`d_{ij}^2`)：#mi(`H`) 类任一样本 #mi(`\boldsymbol{X}_i`) 和 #mi(`K`) 类任一样本 #mi(`\boldsymbol{X}_j`) 之间的欧氏距离平方。

若 #mi(`K`) 类由 #mi(`I`) 和 #mi(`J`) 类合并产生，则递推式为：

#mitex(`D_{HK} = \sqrt{ \frac{n_I}{n_I + n_J} D_{HI}^2 + \frac{n_J}{n_I + n_J} D_{HJ}^2 }`)

#unim[
*特点*：均连接法是*从全局出发顾全大局的一种度量*——考虑了两个簇中所有样本对的平均距离，兼顾了单链接和全链接的特点。
]

#note[
  实际问题中常用几种不同的方法，比较分类结果，从而选择一个比较切合实际的分类。
  
  *三种方法的直观对比*：
  
  - *单链接*：看两个簇"最近"的两个点——容易合并，但可能产生链式效应
  - *全链接*：看两个簇"最远"的两个点——谨慎合并，簇更紧凑
  - *均链接*：看两个簇所有点的"平均"距离——折中方案，兼顾全局
]

=== AGNES聚类方法

AGNES（AGglomerative NESting）聚类是一种采用*自底向上聚合策略*的层次聚类算法。该算法通过不断合并距离最近的聚类簇，直到达到预设的聚类簇个数或满足其他停止条件为止。

==== AGNES流程

假设有 #mi(`m`) 个待聚类的样本：

1. *初始化*：把每个样本归为一簇，计算每两个簇之间的距离，也就是样本与样本之间的相似度
2. *合并*：寻找各个簇之间最近的两个簇，把他们归为一类（簇的总数减少一个）
3. *更新*：重新计算新生成的这个簇与各个旧簇之间的*相似度*
4. *重复*：重复步骤2和3直到所有样本点都归为一簇，结束

==== 类簇相似度度量的三种方式

#table(
  columns: 2,
  [方法], [定义与公式],
  [单链接（single-linkage）], [取类间最小距离 #mitex(`d_{\min}(C_i, C_j) = \min_{\boldsymbol{x} \in C_i, \boldsymbol{z} \in C_j} \text{dist}(\boldsymbol{x}, \boldsymbol{z})`)],
  [全链接（complete-linkage）], [取类间最大距离 #mitex(`d_{\max}(C_i, C_j) = \max_{\boldsymbol{x} \in C_i, \boldsymbol{z} \in C_j} \text{dist}(\boldsymbol{x}, \boldsymbol{z})`)],
  [均链接（average-linkage）], [取类间两两的平均距离 #mitex(`d_{\text{avg}}(C_i, C_j) = \frac{1}{|C_i||C_j|} \sum_{\boldsymbol{x} \in C_i} \sum_{\boldsymbol{z} \in C_j} \text{dist}(\boldsymbol{x}, \boldsymbol{z})`)],
)

#remark[
  *三种链接方法的特点总结*：
  
  - *单链接*：*包容性极强*——容易合并，对噪声敏感
  - *全链接*：*只要存在缺点就坚决不合并*——对异常值敏感，簇更紧凑
  - *均链接*：*从全局出发顾全大局*——折中方案，鲁棒性较好
]

=== 层次聚类方法的特点

#table(
  columns: 2,
  [特点类型], [说明],
  [无需指定簇数], [层次聚类算法*不要求我们指定聚类的数量*，我们甚至可以选择哪个聚类看起来最好],
  [对距离度量的选择], [该算法对距离度量的选择*不敏感*],
  [可恢复层次结构], [当底层数据具有层次结构时，*可以恢复层次结构*],
  [时间复杂度高], [层次聚类的优点是以*低效率*为代价的，通常具有 #mi(`O(n^3)`) 的时间复杂度，与 k-means 和高斯混合模型的线性时间复杂度不同],
)

#unim[
*层次聚类 vs. 原型聚类*：

- *层次聚类*：产生树状结构，可以灵活选择聚类粒度；但计算开销大，不适合大规模数据
- *原型聚类*（K-means、LVQ、GMM）：产生"平坦的"划分；计算效率高，但需要预设簇数
]

=== 延伸阅读：复杂网络的社区发现

近20年来，*复杂网络*（complex network）研究广泛，是复杂系统的抽象。人们发现复杂网络具有一定的*社区结构*，即复杂网络并不是一大批性质完全相同的节点随机连接在一起，也不是各种类型的节点之间不相关的随意链接，而是"乱中有序"——*相同类型节点之间连接较多，构成一个一个的小社区*（Community）。

// #figure(image("/fig/复杂网络_社区发现.png", width: 70%), caption: "复杂网络的社区结构（左：原始网络；右：社区划分结果）")

层次聚类的树状结构天然适合社区发现任务：通过在不同高度切割树状图，可以得到不同粒度的社区划分。