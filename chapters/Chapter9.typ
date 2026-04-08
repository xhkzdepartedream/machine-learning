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
// 下面这个不知道放哪。——yyl
// 层次聚类又有聚合（自下而上）和分裂（自上而下）两种方法。

// 聚合法开始将每个样本各自分到一个类，之后将相距最近的两类合并，建立一个新的类，重复此操作直到满足停止条件，得到层次化的类别；分裂法开始将所有样本分到一个类，之后将已有类中相距最远的样本分到两个新的类，重复此操作直到满足停止条件，得到层次化的类别。

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

#algorithm[
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
  事先决定要用 q 个代表点来划分空间，并且每个代表点预先指定它代表哪个类别。比如用 3 个代表点，2 个代表猫、1 个代表狗。]
训练完成后，每个原型向量定义其对应的 *Voronoi 区域*——样本空间中与该原型距离最近的所有点都归入对应的簇。

==== 算法流程

#algorithm[

  *输入：* 样本集 $D = {(x_1, y_1), (x_2, y_2), ..., (x_m, y_m)}$; \
  #h(3em) 原型向量个数 $q$ 及各原型对应的类别标记 ${t_1, t_2, ..., t_q}$; \
  #h(3em) 学习率 $eta in (0, 1)$.

  *过程：*
  + 随机初始化一组原型向量 ${p_1, p_2, ..., p_q}$
  + *repeat*
  
    #h(1em) 从 $D$ 中随机取一个样本 $(x_j, y_j)$

    #h(1em) 计算 $x_j$ 与每个 $p_i$ 的距离：$d_i = norm(x_j - p_i)$

    #h(1em) 找到最近原型：$p^* = arg min_(i in {1,...,q}) d_i$，记其类别标记为 $t^*$

    #h(1em) *if* $y_j = t^*$ *then* #h(2em) \# 类别相同，令 $p^*$ 靠近 $x_j$

    #h(3em) $p' = p^* + eta dot (x_j - p^*)$

    #h(1em) *else* #h(4.1em) \# 类别不同，令 $p^*$ 远离 $x_j$

    #h(3em) $p' = p^* - eta dot (x_j - p^*)$
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

    #h(1em) *end if*

  #h(1em) 将 $p^*$ 更新为 $p'$
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

高斯混合模型可以理解为一个两阶段生成过程：

+ 以先验概率 #mi(`\alpha_i`) 选择第 #mi(`i`) 个混合成分。令*隐变量* #mi(`z_i \in \{1, \ldots, k\}`) 表示生成的样本 #mi(`\boldsymbol{x}_i`) 来自第 #mi(`i`) 个混合成分，即 #mi(`P(z_i = i) = \alpha_i`)；
+ 从选定的高斯分量 #mi(`\mathcal{N}(\boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)`) 中采样，得到观测样本 #mi(`\boldsymbol{x}_j`)。

由于 #mi(`z_j`) 未知，利用贝叶斯定理求 #mi(`z_j`) 的*后验概率*（已观测到 #mi(`\boldsymbol{x}_j`) 后，它来自第 #mi(`i`) 个分量的概率）：

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
输入：样本集 D = {x₁, x₂, …, xₘ}；高斯混合成分个数 k

过程：
+ 初始化高斯混合分布的模型参数 {(αᵢ, μᵢ, Σᵢ) | 1 ≤ i ≤ k}
+ repeat
+ [E步] for j = 1, …, m do
+ 根据当前参数计算 γⱼᵢ（各成分生成样本 xⱼ 的后验概率）
+ end for
+ [M步] for i = 1, …, k do
+ 计算新均值向量：μᵢ' = (Σⱼ γⱼᵢ xⱼ) / (Σⱼ γⱼᵢ)
+ 计算新协方差矩阵：Σᵢ' = (Σⱼ γⱼᵢ (xⱼ-μᵢ)(xⱼ-μᵢ)ᵀ) / (Σⱼ γⱼᵢ)
+ 计算新混合系数：αᵢ' = (Σⱼ γⱼᵢ) / m
+ end for
+ 将模型参数 {(αᵢ, μᵢ, Σᵢ)} 更新为 {(αᵢ', μᵢ', Σᵢ')}
+ until 满足停止条件
+ [划簇] Cᵢ = ∅（1 ≤ i ≤ k）
+ for j = 1, …, m do
+ 令 λⱼ = argmaxᵢ γⱼᵢ，根据 γⱼᵢ 确定 xⱼ 的簇标记 λⱼ
+ 将 xⱼ 并入相应的簇：C_{λⱼ} = C_{λⱼ} ∪ {xⱼ}
+ end for
+ return 簇划分结果 C = {C₁, C₂, …, C_k}
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


== 层次聚类
层次聚类假设类别之间存在层次结构，将样本聚到层次化的类中。层次聚类又有聚合（agglomerative）或自下而上（bottom-up）聚类、分裂（divisive）或自上而下（top-down）聚类两种方法。因为每个样本只属于一个类，所以*层次聚类属于硬聚类*。聚合聚类开始将每个样本各自分到一个类，之后将相距最近的两类合并，建立一个新的类，重复此操作直到满足停止条件，得到层次化的类别。分裂聚类开始将所有样本分到一个类，之后将已有类中相距最远的样本分到两个新的类，重复此操作直到满足停止条件，得到层次化的类别。

聚合聚类需要预先确定下面3个要素：距离或相似度、合并规则和停止条件。

这里我们举一个欧氏距离的例子，可以看出聚合层次聚类算法的复杂度是$O(n^3 m)$, 其中$m$是样本的维数，$n$是样本个数。通过使用*优先队列（堆）*或 k-d tree 等数据结构优化，可以将复杂度降低到 $O(n^2 log n)$ 甚至更低，但最原始的朴素实现是 $O(n^3 m)$。：
#algorithm[
  *输入*：$n$个样本组成的样本集合及样本之间的距离。
  *输出*：对样本集合的一个层次化聚类。

  + 计算$n$个样本两两之间的欧氏距离${d_(i j)}$，记作矩阵$D=[d_(i j)]_(n times n)$
  + 构造$n$个类，每个类只包含一个样本。
  + 合并类间距最小的两个类，其中最短距离为类间距离，构建一个新类。
  + 计算新类与当前各类的距离，若类的个数为1，终止计算。否则回到步骤3.
]

