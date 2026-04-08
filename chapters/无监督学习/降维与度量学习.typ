#import "@local/ysz_tools:0.1.0": *

#show: conf.with(
  title: "shabi",
)
#set math.equation(numbering: "(1)")

== 低维嵌入

核心直觉：空间扩张速度远超数据填充速度。在高维情形下出现的数据样本稀疏、距离计算困难等问题，是机器学习方法共同面临的严重障碍，被称为维数灾难（维数爆炸）。

为了缓解维数灾难,需要把原始高维度属性转换为一个低维度子空间,也就是学一个embedding。

#definition("多维缩放（Multiple Dimensional Scaling, MDS）")[
  要求数据在降维后（低维地图上）的欧氏距离，尽量等于降维前（原始高维空间中）的距离。
]

我们设$m$个样本在$d$维度里,距离矩阵是$bold(D) in RR^(m times m)$，目标是获得一个在$d' < d$维度的表示$bold(Z) in RR^(d' times m)$，使得在这个低维度里的距离和原来的距离一样.也就是$
d_(i j)^2 &= ||z_i||^2 + ||z_j||^2 - 2z_i^T z_j\
&= b_(i i) + b_(j j) - 2b_(i j)
$
其中$bold(B) = bold(Z)^T bold(Z) in RR^(m times m)$.
将低维空间的坐标中心点（原点）放在所有样本的几何中心上：#mi(`\sum_{i=1}^m \boldsymbol{z}_i = 0`)。则内积矩阵 $bold(B)$ 的每一行之和、每一列之和都变成了 0。

现在尝试求解$bold(B)$的每一个元素。注意到$
b_(i j)  = -1/2 (d_(i j)^2 - d_(i .)^2 - d_(j .)^2 + d_(. .)^2)
$
所以分析$bold(B)$的前$d'$特征值我们就能分析出$bold(Z)$.$bold(B)$半正定,于是$
 bold(B) = bold(V) Lambda bold(V)^T\
 bold(Z) = Lambda^(1/2)_* bold(V)^T_*
$

当然实际操作中选前$d'$大的特征值即可.
== 样本主成分分析：基于（样本）协方差矩阵
#note[
总体主成分分析（上帝视角）： 假设你拥有全知全能的视角，完全掌握了数据产生背后的绝对真理（即真实的概率分布）。这是一种*纯理论*的数学推导。

样本主成分分析（凡人视角）： 现实中我们永远无法获得“所有”数据，只能通过观测得到一个有限的数据集。我们利用这批数据去估计主成分。我们在机器学习代码里跑的 PCA，100% 都是样本主成分分析。
]

主成分分析（principal componentanalysis，PCA）是一种常用的无监督学习方法，这一方法*利用正交变换把由线性相关变量表示的观测数据转换为少数几个由线性无关变量表示的数据*，线性无关的变量称为*主成分*。主成分的个数通常小于原始变量的个数，所以*主成分分析属于降维方法*。主成分分析主要用于发现数据中的基本结构，即数据中变量之间的关系，是数据分析的有力工具，也用于其他机器学习方法的前处理。

// 主成分分析中，首先对给定数据进行规范化，使得数据每一变量的平均值为0，方差为1。之后对数据进行正交变换，原来由线性相关变量表示的数据通过正交变换变成由若干个线性无关的新变量表示的数据。新变量是可能的正交变换中变量的方差的和（信息保存）最大的，方差表示在新变量上信息的大小。将新变量依次称为第一主成分、第二主成分等。这就是主成分分析的基本思想。通过主成分分析，可以利用主成分近似地表示原始数据，这可理解为发现数据的“基本结构”：也可以把数据由少数主成分表示，这可理解为对数据降维。

// 下面给出主成分分析的直观解释。数据集合中的样本由实数空间（正交坐标系）中的点表示，空间的一个坐标轴表示一个变量，规范化处理后得到的数据分布在原点附近。*对原坐标系中的数据进行主成分分析等价于进行坐标系旋转变换*，将数据投影到新坐标系的坐标轴上：新坐标系的第一坐标轴、第二坐标轴等分别表示第一主成分、第二主成分等，数据在每一轴上的坐标值的平方表示相应变量的方差：并且，这个坐标系是在所有可能的新的坐标系中，坐标轴上的方差的和最大的。

// 主成分分析选择方差最大的方向（第一主成分）作为新坐标系的第一坐标轴，即$y_1$轴，在这里意味着选择椭圆的长轴作为新坐标系的第一坐标轴; 之后选择与第一坐标轴正交且方差次之的方向（第二主成分）作为新坐标系的第二坐标轴，即$y_2$轴，在这里意味着选择椭圆的短轴作为新坐标系的第二坐标轴。在新坐标系里，数据中的变量$y_1$和$y_2$是线性无关的如果主成分分析只取第一主成分，即新坐标系的$y_1$轴，那么等价于将数据投影在椭圆长轴上，用这个主轴表示数据，将二维空间的数据压缩到一维空间中。

// 下面再看方差最大的解释。假设有两个变量 $x_1$ 和 $x_2$，三个样本点 A, B, C，样本分布在由 $x_1$ 轴和 $x_2$ 轴组成的坐标系中。对坐标系进行旋转变换，得到新的坐标轴 $y_1$，表示新的变量 $y_1$。样本点 A, B, C 在 $y_1$ 轴上投影，得到 $y_1$ 轴的坐标值 A', B', C'。

// 坐标值的平方和 $O A'^2 + O B'^2 + O C'^2$ 表示样本在变量 $y_1$ 上的方差和。主成分分析旨在选取正交变换中方差最大的变量，作为第一主成分，也就是旋转变换中坐标值的平方和最大的轴。注意到旋转变换中样本点到原点的距离的平方和 $O A^2 + O B^2 + O C^2$ 保持不变，根据勾股定理，坐标值的平方和 $O A'^2 + O B'^2 + O C'^2$ 最大等价于样本点到 $y_1$ 轴的距离的平方和 $A A'^2 + B B'^2 + C C'^2$ 最小。所以，*等价地，主成分分析在旋转变换中选取离样本点的距离平方和最小的轴作为第一主成分*。*第二主成分等的选取在保证与已选坐标轴正交的条件下类似地进行*。

// 在数据总体（population）上进行的主成分分析称为总体主成分分析，在有限样本上进行的主成分分析称为样本主成分分析，前者是后者的基础。以下分别予以介绍。

=== 算法直觉与流程
PCA 的几何本质是通过对原坐标系进行*正交变换（旋转）*，寻找一组新的线性无关的坐标轴。这组新轴能够*最大化投影方差*（保留最多信息），或等价地*最小化投影误差*，从而揭示数据的“基本结构”并实现降维。

1. 预处理：数据规范化
在进行坐标变换前，需对实数空间中的原始数据进行均值归0，方差归1.
1. 几何直觉：坐标系旋转与方差最大化
   
高维数据的分布通常呈现超椭球体。对数据进行 PCA，等价于在原点附近*旋转坐标系*：
- *第一主成分 ($y_1$)*：选取方差最大的方向作为新坐标系的第一轴（对应*椭圆的长轴*）。此方向上保留了最大的数据信息。
- *第二主成分 ($y_2$)*：在与 $y_1$ 正交的约束下，选取方差次之的方向作为第二轴（对应*椭圆的短轴*）。

经过正交变换后，新坐标系中的各主成分（$y_1, y_2, dots$）彼此*线性无关*。

3. 数学底层逻辑：方差与误差的对偶性
PCA 选取“方差最大”方向的逻辑，完美等价于寻找“离样本点最近”的坐标轴。

假设空间中有样本点 $A$，原点为 $O$，$A$ 在新坐标轴 $y_1$ 上的投影点为 $A'$。根据勾股定理：
$ O A^2 = O A'^2 + A A'^2 $

- $O A^2$：样本点到原点距离的平方和（由于旋转不改变相对位置，此项为*常数*）。
- $O A'^2$：样本在 $y_1$ 轴上的投影坐标值平方和，即 *投影方差*（代表保留的信息）。
- $A A'^2$：样本点到 $y_1$ 轴的垂线距离平方和，即 *投影误差*（代表丢失的信息）。

由于距离总和常数不变，*最大化投影方差 $O A'^2$* 必然等价于 *最小化投影误差 $A A'^2$*。后续主成分的选取均在此正交与最优化条件下依次进行。
#image("/assets/image-12.png")


// 假设 $bold(x) = (x_1, x_2, dots, x_m)^T$ 是 $m$ 维随机变量，其均值向量是 $bold(mu)$：

// $ bold(mu) = E(bold(x)) = (mu_1, mu_2, dots, mu_m)^T $

// 协方差矩阵是 $bold(Sigma)$：

// $ bold(Sigma) = op("cov")(bold(x), bold(x)) = E[(bold(x) - bold(mu)) (bold(x) - bold(mu))^T] $

// 考虑由 $m$ 维随机变量 $bold(x)$ 到 $m$ 维随机变量 $bold(y) = (y_1, y_2, dots, y_m)^T$ 的线性变换：

// $ y_i = bold(alpha)_i^T bold(x) = alpha_(1i) x_1 + alpha_(2i) x_2 + dots + alpha_(m i) x_m $

// 其中，$bold(alpha)_i^T = (alpha_(1i), alpha_(2i), dots, alpha_(m i)), quad i = 1, 2, dots, m$。
// 由随机变量的性质可知：

// $ E(y_i) = bold(alpha)_i^T bold(mu), quad i = 1, 2, dots, m $

// $ op("var")(y_i) = bold(alpha)_i^T bold(Sigma) bold(alpha)_i, quad i = 1, 2, dots, m $

// $ op("cov")(y_i, y_j) = bold(alpha)_i^T bold(Sigma) bold(alpha)_j, quad i = 1, 2, dots, m; quad j = 1, 2, dots, m $

// #definition[总体主成分][
//   对于一个线性变换，如果他们满足下列条件：

//   (1) 系数向量 $bold(alpha)_i^T$ 是单位向量，即 $bold(alpha)_i^T bold(alpha)_i = 1, i = 1, 2, dots, m$；
  
//   (2) 变量 $y_i$ 与 $y_j$ 互不相关，即 $op("cov")(y_i, y_j) = 0 (i eq.not j)$；
  
//   (3) 变量 $y_1$ 是 $bold(x)$ 的所有线性变换中方差最大的；$y_2$ 是与 $y_1$ 不相关的 $bold(x)$ 的所有线性变换中方差最大的；一般地，$y_i$ 是与 $y_1, y_2, dots, y_(i-1) (i = 1, 2, dots, m)$ 都不相关的 $bold(x)$ 的所有线性变换中方差最大的，这时分别称 $y_1, y_2, dots, y_m$ 为 $bold(x)$ 的第一主成分、第二主成分、……、第 $m$ 主成分。
// ]

// 定义中的条件 (1) 表明线性变换是正交变换, $bold(alpha)_1, bold(alpha)_2, dots, bold(alpha)_m$ 是其一组标准正交基:
// $ bold(alpha)_i^"T" bold(alpha)_j = cases(
//   1\, & i = j,
//   0\, & i != j
// ) $

// 条件 (2) 和条件 (3) 给出了一个求主成分的方法: 第一步, 在 $bold(x)$ 的所有线性变换
// $ bold(alpha)_1^"T" bold(x) = sum_(i=1)^m alpha_(i 1) x_i $
// 中, 在 $bold(alpha)_1^"T" bold(alpha)_1 = 1$ 的条件下, 求方差最大的, 得到 $bold(x)$ 的第一主成分; 第二步, 在与 $bold(alpha)_1^"T" bold(x)$ 不相关的 $bold(x)$ 的所有线性变换
// $ bold(alpha)_2^"T" bold(x) = sum_(i=1)^m alpha_(i 2) x_i $
// 中, 在 $bold(alpha)_2^"T" bold(alpha)_2 = 1$ 的条件下, 求方差最大的, 得到 $bold(x)$ 的第二主成分; 第 $k$ 步, 在与 $bold(alpha)_1^"T" bold(x), bold(alpha)_2^"T" bold(x), dots, bold(alpha)_(k-1)^"T" bold(x)$ 不相关的 $bold(x)$ 的所有线性变换
// $ bold(alpha)_k^"T" bold(x) = sum_(i=1)^m alpha_(i k) x_i $
// 中, 在 $bold(alpha)_k^"T" bold(alpha)_k = 1$ 的条件下, 求方差最大的, 得到 $bold(x)$ 的第 $k$ 主成分; 如此继续下去, 直到得到 $bold(x)$ 的第 $m$ 主成分。

#algorithm("样本主成分分析：基于（样本）协方差矩阵的特征值分解")[
*输入：*样本集 $D = {bold(x)_1, bold(x)_2, dots, bold(x)_m}$；低维空间维数 $d'$。

*输出：*投影矩阵 $bold(W) = (bold(w)_1, bold(w)_2, dots, bold(w)_d')$。

*过程：*
1. *样本中心化*（消除平移偏差，将数据整体移动到坐标系原点附近）：
$
  bold(x)_i arrow l bold(x)_i - 1/m sum_(i=1)^m bold(x)_i
$

2. *计算样本协方差矩阵*（提取各维度间的相关性与变异程度。设 $bold(X)$ 为中心化后的 $d times m$ 样本矩阵）：
$
  bold(C) = bold(X) bold(X)^T
$

3. *特征值分解*（在原始空间中寻找一组全新的正交坐标轴，使得数据投影后的方差被逐级隔离）：
  对协方差矩阵 $bold(X) bold(X)^T$ 做特征值分解，求得特征值与对应的特征向量。

4. *提取主成分进行降维*（丢弃包含极小方差的“噪声”维度，保留包含最大信息量的前 $d'$ 个方向）：
  取最大的 $d'$ 个特征值所对应的特征向量 $bold(w)_1, bold(w)_2, dots, bold(w)_d'$。
]

#example[
我们使用一组均值非零的数据。假设有 $n=3$ 个样本，$p=2$ 个特征：
$ bold(X) = mat(
  3, 2;
  2, 3;
  1, 1
) $
]


*第一步：数据中心化*

首先计算每个特征（列）的均值：
$ overline(x)_1 = (3+2+1)/3 = 2 \
overline(x)_2 = (2+3+1)/3 = 2 $
均值向量为 $bold(mu) = (2, 2)$。

计算中心化矩阵 $bold(B) = bold(X) - bold(mu)$，即原始数据减去均值：
$ bold(B) = mat(
  3-2, 2-2;
  2-2, 3-2;
  1-2, 1-2
) = mat(
  1, 0;
  0, 1;
  -1, -1
) $

*第二步：计算协方差矩阵*

公式为 $bold(Sigma) = 1/(n-1) bold(B)^T bold(B)$。这里 $n=3$，分母为 $2$。
先计算内积矩阵 $bold(B)^T bold(B)$：
$ bold(B)^T bold(B) = mat(
  1, 0, -1;
  0, 1, -1
) mat(
  1, 0;
  0, 1;
  -1, -1
) = mat(
  2, 1;
  1, 2
) $

除以 $n-1=2$，得到协方差矩阵：
$ bold(Sigma) = 1/2 mat(
  2, 1;
  1, 2
) = mat(
  1, 0.5;
  0.5, 1
) $

*第三步：计算特征值与贡献度*

求解特征方程 $det(bold(Sigma) - lambda I) = 0$：
$ det(mat(
  1-lambda, 0.5;
  0.5, 1-lambda
)) = (1-lambda)^2 - 0.5^2 = 0 $

$ (1-lambda)^2 = 0.25 => 1-lambda = plus.minus 0.5 $

解得特征值：
$lambda_1 = 1.5$ (最大特征值，方差最大) \
$lambda_2 = 0.5$ (次大特征值)

*贡献度分析*：
总方差 $= 1.5 + 0.5 = 2.0$。
第一主成分贡献率 $= 1.5 / 2.0 = 75%$。
这说明如果只保留第一主成分，虽然去除了噪声（或次要信息），但也损失了 25% 的原始数据差异。

*第四步：计算特征向量*

对于 $lambda_1 = 1.5$，求解方程组 $(bold(Sigma) - 1.5 I) bold(v) = bold(0)$：
$ mat(
  1-1.5, 0.5;
  0.5, 1-1.5
) vec(v_1, v_2) = mat(
  -0.5, 0.5;
  0.5, -0.5
) vec(v_1, v_2) = vec(0, 0) $

由 $-0.5 v_1 + 0.5 v_2 = 0$ 整理得 $v_1 = v_2$。
取基础解向量 $bold(v) = (1, 1)^T$。
进行单位化（除以模长 $sqrt(1^2+1^2) = sqrt(2)$）：
$ bold(alpha)_1 = vec(1/sqrt(2), 1/sqrt(2)) approx vec(0.707, 0.707) $

*第五步：降维投影*

将中心化后的矩阵 $bold(B)$ 投影到第一主成分方向 $bold(alpha)_1$ 上。
注意：一定要用*中心化后*的数据乘以特征向量。
$ bold(Y)_("new") = bold(B) dot bold(alpha)_1 = mat(
  1, 0;
  0, 1;
  -1, -1
) vec(0.707, 0.707) $

计算过程：
样本 1: $1(0.707) + 0(0.707) = 0.707$ \
样本 2: $0(0.707) + 1(0.707) = 0.707$ \
样本 3: $-1(0.707) - 1(0.707) = -1.414$

*结果总结*

#align(center, table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: center,
  [*样本*], [*原始坐标* $(x_1, x_2)$], [*PCA得分* $(y_1)$],
  [Sample 1], [$(3, 2)$], [$0.707$],
  [Sample 2], [$(2, 3)$], [$0.707$],
  [Sample 3], [$(1, 1)$], [$-1.414$]
))

注：样本 1 和样本 2 在原始数据中有明显区别（一个 3,2 一个 2,3），但在第一主成分看来，它们的“综合得分”是一样的（都是高于平均水平）。它们之间的细微区别（25% 的信息）被丢弃了。

#remark[
  如果保留所有的主成分，PCA 就仅仅是一个正交变换（Orthogonal Transformation），或者更通俗地说，就是一次坐标轴旋转。
]


#unim[
*1. 为什么数据中心化操作不会失真？*

#remark[
  中心化（$x_i - mu$）在几何上等同于坐标系的“平移”，而不是“缩放”或“扭曲”。
  数据的内部结构（点与点之间的相对距离）和形状（数据的分布形态）在平移后完全保持不变。做这一步是为了让后续计算（特别是协方差公式）变得极其简洁。
]
#proof[
  根据方差的定义：$op("Var")(x) = E[(x - mu)^2]$。
  如果我们构造新变量 $x' = x - mu$（即中心化），那么新变量的均值为 0。
  新方差 $op("Var")(x') = E[(x' - 0)^2] = E[(x - mu)^2]$。
  
  可见 $op("Var")(x') = op("Var")(x)$，数据的波动性（信息量）完全没有丢失。
]

*2. 为什么“确定投影方向”等价于“确定系数向量”？*

#remark[
  几何上的“方向”和代数上的“系数”是同一事物的两种表达。
  投影直线在空间中的指向，由一个单位向量 $bold(alpha)$ 决定。而线性变换公式中的系数 $alpha_1, alpha_2$，恰好就是这个单位向量在坐标轴上的分量。
]

#proof[
  假设有一个单位方向向量 $bold(alpha) = (alpha_1, alpha_2)^T$。
  数据点 $bold(x) = (x_1, x_2)^T$ 在该方向上的投影长度（标量）$y$ 由点积公式给出：
  $ y = bold(alpha) dot bold(x) = bold(alpha)^T bold(x) $
  展开后即为线性变换形式：
  $ y = alpha_1 x_1 + alpha_2 x_2 $
  因此，寻找最佳的线性组合系数，就是在寻找最佳的空间投影方向。
]


*3. 为什么协方差矩阵能算出方差最大的方向？*

#remark[
  协方差矩阵 $bold(Sigma)$ 本质上是一个“方差计算器”。它不仅记录了数据的形状，还决定了二次型 $bold(alpha)^T bold(Sigma) bold(alpha)$ 的值。
  通过拉格朗日乘数法可以证明，使得这个二次型（投影方差）取极值的方向，必然是 $bold(Sigma)$ 的特征向量方向。
]

#proof[
  我们的目标是：在约束 $bold(alpha)^T bold(alpha) = 1$ 下，最大化方差 $f(bold(alpha)) = bold(alpha)^T bold(Sigma) bold(alpha)$。
  构造拉格朗日函数：
  $ L(bold(alpha), lambda) = bold(alpha)^T bold(Sigma) bold(alpha) - lambda (bold(alpha)^T bold(alpha) - 1) $
  对 $bold(alpha)$ 求导并令其为 0：
  $ (partial L) / (partial bold(alpha)) = 2 bold(Sigma) bold(alpha) - 2 lambda bold(alpha) = 0 $
  化简得特征方程定义式：
  $ bold(Sigma) bold(alpha) = lambda bold(alpha) $
  
  这证明了：最优投影方向 $bold(alpha)$ 必须是协方差矩阵的特征向量。
  同时，将上式左乘 $bold(alpha)^T$，可得最大方差值恰好等于特征值：
  $ "Var"(y) = bold(alpha)^T (bold(Sigma) bold(alpha)) = bold(alpha)^T (lambda bold(alpha)) = lambda (bold(alpha)^T bold(alpha)) = lambda $
]

*4. 协方差矩阵与原始数据的关系：为什么最大化二次型就是最大化原始方差？*

#remark[
  协方差矩阵 $bold(Sigma)$ 可以被视为原始海量数据 $bold(X)$ 的一个“高保真压缩包”。
  它已经预先计算并存储了数据在各个维度上的离散程度和相关性。
  公式 $f(bold(alpha)) = bold(alpha)^T bold(Sigma) bold(alpha)$ 并不是一个抽象定义的函数，它实际上就是*投影后新变量方差*的精确计算公式。
  
  因此，不需要每次都对所有原始数据点进行投影计算，直接利用矩阵 $bold(Sigma)$ 即可瞬间算出任意方向上的方差。
]

#proof[
  假设原始数据向量为 $bold(x)$（已中心化，即 $E[bold(x)] = bold(0)$）。
  我们将数据投影到单位方向 $bold(alpha)$ 上，得到新变量（标量）$y$：
  $ y = bold(alpha)^T bold(x) $
  
  我们的目标是计算 $y$ 的方差。因为均值为 0，方差等于平方的期望：
  $ "Var"(y) = E[y^2] $
  
  将 $y$ 的定义代入：
  $ "Var"(y) = E[(bold(alpha)^T bold(x))^2] $
  
  利用标量的转置等于其自身 $(bold(alpha)^T bold(x))^T = bold(x)^T bold(alpha)$，将平方展开为“自己乘自己”：
  $ "Var"(y) = E[(bold(alpha)^T bold(x)) (bold(x)^T bold(alpha))] $
  
  根据矩阵乘法的结合律，写成：
  $ "Var"(y) = E[bold(alpha)^T (bold(x) bold(x)^T) bold(alpha)] $
  
  在期望运算 $E[dot]$ 中，$bold(alpha)$ 是常数向量，只有 $bold(x)$ 是随机变量。因此可以将 $bold(alpha)$ 提取到期望符号外面：
  $ "Var"(y) = bold(alpha)^T dot underbrace(E[bold(x) bold(x)^T], "协方差矩阵 " bold(Sigma)) dot bold(alpha) $
  
  最终得证：
  $ "Var"(y) = bold(alpha)^T bold(Sigma) bold(alpha) $
  
  这证明了：最大化二次型 $bold(alpha)^T bold(Sigma) bold(alpha)$，在数学上严格等价于最大化原始数据投影后的方差。
]

#theorem[
  $m$ 维随机变量 $bold(y) = (y_1, y_2, dots, y_m)^T$ 的分量依次是 $bold(x)$ 的第一主成分到第 $m$ 主成分的充要条件是：

  (1) $bold(y) = bold(A)^T bold(x)$， $bold(A)$ 为正交矩阵：
  $
    bold(A) = mat(
      delim: "[",
      alpha_11, alpha_12, dots, alpha_(1m);
      alpha_21, alpha_22, dots, alpha_(2m);
      dots.v, dots.v, , dots.v;
      alpha_(m 1), alpha_(m 2), dots, alpha_(m m)
    )
  $

  (2) $bold(y)$ 的协方差矩阵为对角矩阵：
  $
    op("cov")(bold(y)) = op("diag")(lambda_1, lambda_2, dots, lambda_m) \
    lambda_1 >= lambda_2 >= dots >= lambda_m
  $

  其中，$lambda_k$ 是 $bold(Sigma)$ 的第 $k$ 个特征值，$bold(alpha)_k$ 是对应的单位特征向量，$k = 1, 2, dots, m$。
]

]


#unim[
=== 深入理解PCA：数学推导、性质与应用考量
*1. 特征值分解与协方差矩阵对角化*
  
设 $lambda_k$ 是协方差矩阵 $bold(Sigma)$ 的第 $k$ 个特征值，$bold(alpha)_k$ 是对应的单位特征向量，即满足：
$ bold(Sigma) bold(alpha)_k = lambda_k bold(alpha)_k, quad k = 1, 2, dots, m $

将所有特征向量组合成矩阵 $bold(A) = [bold(alpha)_1, bold(alpha)_2, dots, bold(alpha)_m]$，将特征值组合成对角矩阵 $bold(Lambda) = op("diag")(lambda_1, dots, lambda_m)$，上述关系可写为矩阵形式：
$ bold(Sigma) bold(A) = bold(A) bold(Lambda) $

由于 $bold(A)$ 是正交矩阵，满足 $bold(A)^T bold(A) = bold(A) bold(A)^T = bold(I)$。在等式两边左乘 $bold(A)^T$，得到谱分解公式：
$ bold(A)^T bold(Sigma) bold(A) = bold(Lambda) quad "和" quad bold(Sigma) = bold(A) bold(Lambda) bold(A)^T $

因此，总体主成分 $bold(y) = bold(A)^T bold(x)$ 的协方差矩阵为：
$ op("cov")(bold(y)) = op("cov")(bold(A)^T bold(x)) = bold(A)^T bold(Sigma) bold(A) = bold(Lambda) $
这证明了主成分之间互不相关，且方差为特征值。

*2. 总方差守恒性质*

利用矩阵迹（trace）的性质，总体主成分 $bold(y)$ 的方差之和等于随机变量 $bold(x)$ 的方差之和：
$ sum_(i=1)^m "var"(x_i) = op("tr")(bold(Sigma)) = op("tr")(bold(A) bold(Lambda) bold(A)^T) = op("tr")(bold(A)^T bold(A) bold(Lambda)) = op("tr")(bold(Lambda)) = sum_(i=1)^m lambda_i $

*3. 因子负荷量 (Factor Loading) 的推导*

第 $k$ 个主成分 $y_k$ 与变量 $x_i$ 的相关系数 $rho(y_k, x_i)$ 称为因子负荷量。

首先计算 $y_k$ 与 $x_i$ 的协方差。令 $bold(e)_i$ 为基本单位向量（第 $i$ 个分量为 1），则 $x_i = bold(e)_i^T bold(x)$，$y_k = bold(alpha)_k^T bold(x)$。
$ op("cov")(y_k, x_i) = op("cov")(bold(alpha)_k^T bold(x), bold(e)_i^T bold(x)) = bold(alpha)_k^T bold(Sigma) bold(e)_i = bold(e)_i^T bold(Sigma) bold(alpha)_k = lambda_k bold(e)_i^T bold(alpha)_k = lambda_k alpha_(i k) $

代入相关系数公式：
$ rho(y_k, x_i) = frac(op("cov")(y_k, x_i), sqrt("var"(y_k) "var"(x_i))) = frac(lambda_k alpha_(i k), sqrt(lambda_k) sqrt(sigma_(i i))) = frac(sqrt(lambda_k) alpha_(i k), sqrt(sigma_(i i))) $

*4. 因子负荷量的性质*

(1) 第 $k$ 个主成分 $y_k$ 与 $m$ 个变量的因子负荷量加权平方和满足：
$ sum_(i=1)^m sigma_(i i) rho^2(y_k, x_i) = sum_(i=1)^m sigma_(i i) frac(lambda_k alpha_(i k)^2, sigma_(i i)) = lambda_k sum_(i=1)^m alpha_(i k)^2 = lambda_k bold(alpha)_k^T bold(alpha)_k = lambda_k $

(2) $m$ 个主成分与第 $i$ 个变量 $x_i$ 的因子负荷量平方和为 1：
由于 $x_i$ 可表示为 $y_1, dots, y_m$ 的线性组合，且 $y_k$ 互不相关，故 $x_i$ 与 $y_1, dots, y_m$ 的相关系数平方和为 1：
$ sum_(k=1)^m rho^2(y_k, x_i) = 1 $

主成分分析的主要目的是降维，所以一般选择 $k$ ($k << m$) 个主成分（线性无关变量）来代替 $m$ 个原有变量（线性相关变量），使问题得以简化，并能保留原有变量的大部分信息。这里所说的信息是指原有变量的方差。为此，先给出一个定理，说明选择 $k$ 个主成分是最优选择。

#theorem[
  对任意正整数 $q$, $1 <= q <= m$, 考虑正交线性变换
  $ y = B^top x $
  其中, $y$ 是 $q$ 维向量, $B^top$ 是 $q times m$ 矩阵, 令 $y$ 的协方差矩阵为
  $ Sigma_y = B^top Sigma B $
  则 $Sigma_y$ 的迹 $op("tr")(Sigma_y)$ 在 $B=A_q$ 时取得最大值, 其中矩阵 $A_q$ 由正交矩阵 $A$ 的前 $q$ 列组成。
]

#remark[
  “最优”是指：在约束为 $k$ 维的前提下，PCA 提供了数学上信息损失最小的线性解。
]




]


在实际问题中，不同变量可能有不同的量纲，直接求主成分有时会产生不合理的结果。为了消除这个影响，常常对各个随机变量实施规范化，使其均值为 0，方差为 1。

设 $bold(x) = (x_1, x_2, dots, x_m)^top$ 为 $m$ 维随机变量，$x_i$ 为第 $i$ 个随机变量，$i=1, 2, dots, m$，令
$ x_i^* = (x_i - E(x_i)) / sqrt(op("var")(x_i)), quad i = 1, 2, dots, m $
其中，$E(x_i)$, $op("var")(x_i)$ 分别是随机变量 $x_i$ 的均值和方差，这时 $x_i^*$ 就是 $x_i$ 的规范化随机变量。

显然，规范化随机变量的协方差矩阵就是相关矩阵 $bold(R)$。主成分分析通常在规范化随机变量的协方差矩阵即相关矩阵上进行。

对照总体主成分的性质可知，规范化随机变量的总体主成分有以下性质：

(1) 规范化变量主成分的协方差矩阵是
$ bold(Lambda)^* = op("diag")(lambda_1^*, lambda_2^*, dots, lambda_m^*) $
其中，$lambda_1^* >= lambda_2^* >= dots >= lambda_m^* >= 0$ 为相关矩阵 $bold(R)$ 的特征值。

(2) 协方差矩阵的特征值之和为 $m$:
$ sum_(k=1)^m lambda_k^* = m $

(3) 规范化随机变量 $x_i^*$ 与主成分 $y_k^*$ 的相关系数（因子载荷）为
$ rho(y_k^*, x_i^*) = sqrt(lambda_k^*) e_(i k)^*, quad k, i = 1, 2, dots, m $
其中，$bold(e)_k^* = (e_(1k)^*, e_(2k)^*, dots, e_(m k)^*)^top$ 为矩阵 $bold(R)$ 对应于特征值 $lambda_k^*$ 的单位特征向量。

(4) 所有规范化随机变量 $x_i^*$ 与主成分 $y_k^*$ 的相关系数的平方和等于 $lambda_k^*$:
$ sum_(i=1)^m rho^2(y_k^*, x_i^*) = sum_(i=1)^m lambda_k^* e_(i k)^(*2) = lambda_k^*, quad k=1, 2, dots, m $

(5) 规范化随机变量 $x_i^*$ 与所有主成分 $y_k^*$ 的相关系数的平方和等于 1:
$ sum_(k=1)^m rho^2(y_k^*, x_i^*) = sum_(k=1)^m lambda_k^* e_(i k)^(*2) = 1, quad i=1, 2, dots, m $

#remark[
  这其实相对于前面只是多了一个标准化操作，其他方面没有区别。

  相关系数也可以看成协方差：一种剔除了两个变量量纲影响、标准化后的特殊协方差,它消除了两个变量变化幅度的影响，而只是单纯反应两个变量每单位变化时的相似程度。
]

#example[
  $ bold(X) = mat(

  3, 2;

  2, 3;

  1, 1

) $
我们使用之前的数据 $bold(X)$ 来验证上述五条性质。
]
*0. 数据准备*


计算得到特征（列）均值均为 2，样本方差均为 1。因此，规范化后的数据 $x^*$ 与中心化数据数值相同。
计算得到相关矩阵（即规范化数据的协方差矩阵）：
$ bold(R) = mat(1, 0.5; 0.5, 1) $

*(1) 验证特征值排序*
求解 $|bold(R) - lambda bold(I)| = 0$，得到特征值：
$ lambda_1^* = 1.5, quad lambda_2^* = 0.5 $
满足 $lambda_1^* > lambda_2^*$，构成对角阵：
$ bold(Lambda)^* = mat(1.5, 0; 0, 0.5) $

*(2) 验证特征值之和*
特征值之和为 $1.5 + 0.5 = 2$。
变量个数 $m=2$。
$ sum_(k=1)^2 lambda_k^* = 2 = m $
验证成立。

*(3) 计算因子载荷（相关系数）*
首先求单位特征向量：
- 对应 $lambda_1^*=1.5$：$bold(e)_1^* = (1/sqrt(2), 1/sqrt(2))^top approx (0.707, 0.707)^top$
- 对应 $lambda_2^*=0.5$：$bold(e)_2^* = (1/sqrt(2), -1/sqrt(2))^top approx (0.707, -0.707)^top$

根据公式 $rho(y_k^*, x_i^*) = sqrt(lambda_k^*) e_(i k)^*$ 计算：
- 第一主成分 ($k=1$)：
  $ rho(y_1^*, x_1^*) = sqrt(1.5) dot 0.707 = sqrt(0.75) approx 0.866 $
  $ rho(y_1^*, x_2^*) = sqrt(1.5) dot 0.707 = sqrt(0.75) approx 0.866 $
- 第二主成分 ($k=2$)：
  $ rho(y_2^*, x_1^*) = sqrt(0.5) dot 0.707 = sqrt(0.25) = 0.5 $
  $ rho(y_2^*, x_2^*) = sqrt(0.5) dot (-0.707) = -0.5 $

*(4) 验证性质：行平方和（对主成分贡献）*
验证 $sum_(i=1)^m rho^2(y_k^*, x_i^*) = lambda_k^*$：
- 对于第一主成分 ($k=1$)：
  $ 0.866^2 + 0.866^2 = 0.75 + 0.75 = 1.5 = lambda_1^* $
- 对于第二主成分 ($k=2$)：
  $ 0.5^2 + (-0.5)^2 = 0.25 + 0.25 = 0.5 = lambda_2^* $
验证成立。

*(5) 验证性质：列平方和（变量的信息解释）*
验证 $sum_(k=1)^m rho^2(y_k^*, x_i^*) = 1$：
- 对于变量 $x_1$ ($i=1$)：
  $ rho^2(y_1^*, x_1^*) + rho^2(y_2^*, x_1^*) = 0.75 + 0.25 = 1 $
- 对于变量 $x_2$ ($i=2$)：
  $ rho^2(y_1^*, x_2^*) + rho^2(y_2^*, x_2^*) = 0.75 + 0.25 = 1 $
验证成立。


== 样本主成分分析

#definition[样本主成分][
 给定样本矩阵 $bold(X)$。一般地，样本第 $i$ 主成分 $y_i = bold(a)_i^top bold(x)$ 是在 $bold(a)_i^top bold(a)_i = 1$ 和 $bold(a)_i^top bold(x)_j$ 与 $bold(a)_k^top bold(x)_j (k < i, j=1, 2, dots, n)$ 的样本协方差 $bold(a)_k^top bold(S) bold(a)_i = 0$ 条件下，使 $bold(a)_i^top bold(x)_j (j=1, 2, dots, n)$ 的样本方差 $bold(a)_i^top bold(S) bold(a)_i$ 最大的 $bold(x)$ 的线性变换。
]

样本主成分与总体主成分具有同样的性质，这从样本主成分的定义容易看出。只要以样本协方差矩阵 $bold(S)$ 代替总体协方差矩阵 $bold(Sigma)$ 即可。样本主成分的性质不再重述。

在使用样本主成分时，一般假设样本数据是规范化的，即对样本矩阵作如下变换：
$ x_(i j)^* = (x_(i j) - overline(x)_i) / sqrt(s_(i i)), quad i=1, 2, dots, m, quad j=1, 2, dots, n $
其中，
$ overline(x)_i = 1/n sum_(j=1)^n x_(i j), quad i=1, 2, dots, m $
$ s_(i i) = 1/(n-1) sum_(j=1)^n (x_(i j) - overline(x)_i)^2, quad i=1, 2, dots, m $

为了方便，将规范化变量 $x_(i j)^*$ 仍记作 $x_(i j)$，规范化的样本矩阵仍记作 $bold(X)$。这时，样本协方差矩阵 $bold(S)$ 就是样本相关矩阵 $bold(R)$：
$ bold(R) = 1/(n-1) bold(X) bold(X)^top $

样本协方差矩阵 $bold(S)$ 是总体协方差矩阵 $bold(Sigma)$ 的无偏估计，样本相关矩阵 $bold(R)$ 是总体相关矩阵的无偏估计，$bold(S)$ 的特征值和特征向量是 $bold(Sigma)$ 的特征值和特征向量的极大似然估计。

#algorithm[样本主成分分析：基于相关矩阵的特征值分解][
  给定样本矩阵 $bold(X)$，利用数据的样本协方差矩阵或者样本相关矩阵的特征值分解进行主成分分析。具体步骤如下：

  (1) 对观测数据按式 (16.48) 进行规范化处理，得到规范化数据矩阵，仍以 $bold(X)$ 表示。

  (2) 依据规范化数据矩阵，计算样本相关矩阵 $bold(R)$:
  $ bold(R) = [r_(i j)]_(m times m) = 1/(n-1) bold(X) bold(X)^top $
  其中，
  $ r_(i j) = 1/(n-1) sum_(l=1)^n x_(i l) x_(l j), quad i, j = 1, 2, dots, m $

  (3) 求样本相关矩阵 $bold(R)$ 的 $k$ 个特征值和对应的 $k$ 个单位特征向量。
  求解 $bold(R)$ 的特征方程
  $ |bold(R) - lambda bold(I)| = 0 $
  得 $bold(R)$ 的 $m$ 个特征值：
  $ lambda_1 >= lambda_2 >= dots >= lambda_m $
  求方差贡献率 $sum_(i=1)^k eta_i$ 达到预定值的主成分个数 $k$。
  求前 $k$ 个特征值对应的单位特征向量：
  $ bold(a)_i = (a_(1i), a_(2i), dots, a_(m i))^top, quad i = 1, 2, dots, k $

  (4) 求 $k$ 个样本主成分
  以 $k$ 个单位特征向量为系数进行线性变换，求出 $k$ 个样本主成分：
  $ y_i = bold(a)_i^top bold(x), quad i = 1, 2, dots, k $

  (5) 计算 $k$ 个主成分 $y_j$ 与原变量 $x_i$ 的相关系数 $rho(x_i, y_j)$，以及 $k$ 个主成分对原变量 $x_i$ 的贡献率 $nu_i$。

  (6) 计算 $n$ 个样本的 $k$ 个主成分值
  将规范化样本数据代入 $k$ 个主成分式 (16.50)，得到 $n$ 个样本的主成分值。第 $j$ 个样本 $bold(x)_j = (x_(1j), x_(2j), dots, x_(m j))^top$ 的第 $i$ 主成分值是
  $ y_(i j) = (a_(1i), a_(2i), dots, a_(m i)) (x_(1j), x_(2j), dots, x_(m j))^top = sum_(l=1)^m a_(l i) x_(l j), $
  $ i = 1, 2, dots, m, quad j = 1, 2, dots, n $
]

主成分分析得到的结果可以用于其他机器学习方法的输入。比如，将样本点投影到以主成分为坐标轴的空间中，然后应用聚类算法就可以对样本点进行聚类。

#example(title: "学生成绩的主成分分析")[
  假设有 $n$ 个学生参加四门课程（语文 $x_1$、外语 $x_2$、数学 $x_3$、物理 $x_4$）的考试。将学生的考试成绩看作随机变量的取值，对考试成绩数据进行标准化处理，得到样本相关矩阵 $bold(R)$，如下表所示。

#figure(
  table(
    columns: 5,
    stroke: none,
    table.hline(),
    table.header(
      [*课程*], [*语文* ($x_1$)], [*外语* ($x_2$)], [*数学* ($x_3$)], [*物理* ($x_4$)]
    ),
    table.hline(),
    [语文], [1.00], [0.44], [0.29], [0.33],
    [外语], [0.44], [1.00], [0.35], [0.32],
    [数学], [0.29], [0.35], [1.00], [0.60],
    [物理], [0.33], [0.32], [0.60], [1.00],
    table.hline()
  ),
  caption: "样本相关矩阵 R"
)
]
*解*：对样本相关矩阵进行特征值分解，得到相关矩阵的特征值，并按大小排序：
$ lambda_1 = 2.17, quad lambda_2 = 0.87, quad lambda_3 = 0.57, quad lambda_4 = 0.39 $

这些特征值就是各主成分的方差贡献率。假设要求主成分的累计方差贡献率大于 75%，那么只需取前两个主成分即可（$k=2$），因为：
$ (lambda_1 + lambda_2) / (sum_(i=1)^4 lambda_i) = (2.17 + 0.87) / 4 = 0.76 > 75% $

求出对应于特征值 $lambda_1, lambda_2$ 的单位特征向量，列于下表。

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr, auto),
    stroke: none,
    align: center,
    table.hline(),
    table.header(
      [*项目*], [*$x_1$*], [*$x_2$*], [*$x_3$*], [*$x_4$*], [*方差贡献率*]
    ),
    table.hline(),
    [$y_1$], [0.460], [0.476], [0.523], [0.537], [0.543],
    [$y_2$], [0.574], [0.486], [$-0.476$], [$-0.456$], [0.218],
    table.hline()
  ),
  caption: "单位特征向量和主成分的方差贡献率"
)

由此可得第一、第二主成分的表达式：
$ y_1 = 0.460 x_1 + 0.476 x_2 + 0.523 x_3 + 0.537 x_4 $
$ y_2 = 0.574 x_1 + 0.486 x_2 - 0.476 x_3 - 0.456 x_4 $

接下来由特征值和单位特征向量求出第一、第二主成分的因子负荷量 $rho(y_k, x_i) = sqrt(lambda_k) a_(i k)$，如下表所示。

#figure(
  table(
    columns: 5,
    stroke: none,
    align: center,
    table.hline(),
    table.header(
      [*项目*], [*$x_1$*], [*$x_2$*], [*$x_3$*], [*$x_4$*]
    ),
    table.hline(),
    [$y_1$], [0.678], [0.701], [0.770], [0.791],
    [$y_2$], [0.536], [0.453], [$-0.444$], [$-0.425$],
    [$y_1, y_2$ 对 $x_i$ 的贡献率], [0.747], [0.697], [0.790], [0.806],
    table.hline()
  ),
  caption: "主成分的因子负荷量和贡献率"
)

*结果分析*：
1. *第一主成分 $y_1$*：所有因子负荷量均为正数，且数值相近（物理 $x_4$ 略大）。这说明各门课程成绩提高都会使 $y_1$ 提高。因此，$y_1$ 反映了学生的*整体成绩*。
2. *第二主成分 $y_2$*：因子负荷量有正有负。正的是语文和外语（文科），负的是数学和物理（理科）。这说明文科好理科差会使 $y_2$ 升高。因此，$y_2$ 反映了学生的*文科与理科成绩的差异*（文科倾向）。

下图将原变量在由两个主成分构成的平面坐标系中表示出来。

#figure(image("/fig/因子负荷量分布图.png", width: 70%), caption: "因子负荷量分布图")

给定样本矩阵$X$，利用数据矩阵奇异值分解进行主成分分析。具体过程如下，这里假设有$k$个主成分。

对于 $m times n$ 实矩阵 $A$，假设其秩为 $r$，$0 < k < r$，则可以将矩阵 $A$ 进行截断奇异值分解：

$ A approx U_k Sigma_k V_k^T $

式中 $U_k$ 是 $m times k$ 矩阵，$V_k$ 是 $n times k$ 矩阵，$Sigma_k$ 是 $k$ 阶对角矩阵；$U_k, V_k$ 分别由取 $A$ 的完全奇异值分解的矩阵 $U, V$ 的前 $k$ 列，$Sigma_k$ 由取 $A$ 的完全奇异值分解的矩阵 $Sigma$ 的前 $k$ 个对角线元素得到。

定义一个新的 $n times m$ 矩阵 $X'$：

$ X' = 1 / sqrt(n - 1) X^T $

$X'$ 的每一列均值为零。不难得知：

$ X'^T X' &= (1 / sqrt(n - 1) X^T)^T (1 / sqrt(n - 1) X^T) \
&= 1 / (n - 1) X X^T $

即 $X'^T X'$ 等于 $X$ 的协方差矩阵 $S_X$：

$ S_X = X'^T X' $

主成分分析归结于求协方差矩阵 $S_X$ 的特征值和对应的单位特征向量，所以问题转化为求矩阵 $X'^T X'$ 的特征值和对应的单位特征向量。

假设 $X'$ 的截断奇异值分解为 $X' = U Sigma V^T$，那么 $V$ 的列向量就是 $S_X = X'^T X'$ 的单位特征向量。因此，$V$ 的列向量构成 $X$ 的主成分的正交直角坐标系。于是，求 $X$ 主成分可以通过求 $X'$ 的奇异值分解来实现。具体算法如下。

#algorithm[样本主成分分析：基于样本的奇异值分解][
*输入*：$m times n$ 样本矩阵 $X$，其每一行元素的均值为零。 \
*输出*：$k times n$ 样本主成分矩阵 $Y$。 \
参数：主成分个数 $k$。

(1) 构造新的 $n times m$ 矩阵：

$ X' = 1 / sqrt(n - 1) X^T $

$X'$ 每一列的均值为零。

(2) 对矩阵 $X'$ 进行截断奇异值分解，得到：

$ X' = U Sigma V^T $

有 $k$ 个奇异值、奇异向量。矩阵 $V^T$ 和 $X$ 的乘积构成样本主成分矩阵。

(3) 求 $k times n$ 样本主成分矩阵：

$ Y = V^T X $
]

#example[
  为了展示上述算法的具体计算过程，假设有一个 $m=2$ (两个特征)，$n=3$ (三个样本) 的数据矩阵 $X$。

(1) *输入数据与预处理*

给定样本矩阵 $X$，其中每一行代表一个特征，每一列代表一个样本。假设数据如下（已满足每一行均值为零的要求）：

$ X = mat(
  -1, 0, 1;
  -2, 0, 2
) $

这里 $m=2, n=3$。
]

(2) *构造矩阵 $X'$*

根据公式 $X' = 1 / sqrt(n - 1) X^T$，其中 $1 / sqrt(n - 1) = 1 / sqrt(2)$：

$ X' = 1 / sqrt(2) mat(
  -1, -2;
  0, 0;
  1, 2
) $

(3) *对 $X'$ 进行截断奇异值分解*

#remark[
  截断奇异值分解是指只保留前 $k$ 个最大的奇异值（$k < r$），将剩余的 $r-k$ 个奇异值置为 0。
]
首先计算 $X'^T X'$，即协方差矩阵 $S_X$：

$ S_X &= X'^T X' = (1 / sqrt(2) mat(
  -1, 0, 1;
  -2, 0, 2
)) (1 / sqrt(2) mat(
  -1, -2;
  0, 0;
  1, 2
)) \
&= 1/2 mat(
  2, 4;
  4, 8
) = mat(
  1, 2;
  2, 4
) $

求解 $S_X$ 的特征值和特征向量：
特征方程 $|lambda I - S_X| = (lambda - 1)(lambda - 4) - 4 = lambda^2 - 5lambda = 0$。
解得特征值 $lambda_1 = 5, lambda_2 = 0$。
对应的奇异值 $sigma_1 = sqrt(5), sigma_2 = 0$。

求对应的单位特征向量（即矩阵 $V$ 的列向量）：
对于 $lambda_1 = 5$，解方程 $(S_X - 5I)v_1 = 0$，归一化后得 $v_1 = 1 / sqrt(5) (1, 2)^T$。
对于 $lambda_2 = 0$，解方程 $S_X v_2 = 0$，归一化后得 $v_2 = 1 / sqrt(5) (2, -1)^T$。

于是得到正交矩阵 $V$：

$ V = 1 / sqrt(5) mat(
  1, 2;
  2, -1
) $

(4) *求主成分矩阵 $Y$*

假设我们需要保留 1 个主成分 ($k=1$)。
取 $V$ 的前 $1$ 列得到 $V_k$（也就是截断 $V$）：

$ V_k = 1 / sqrt(5) mat(
  1;
  2
) $

最后，根据公式 $Y = V_k^T X$ 计算 $1 times 3$ 的主成分矩阵：

$ Y &= (1 / sqrt(5) mat(1, 2)) mat(
  -1, 0, 1;
  -2, 0, 2
) \
&= 1 / sqrt(5) mat(
  1(-1)+2(-2), 1(0)+2(0), 1(1)+2(2)
) \
&= 1 / sqrt(5) mat(
  -5, 0, 5
) \
&= mat(
  -sqrt(5), 0, sqrt(5)
) $

这就是降维后的数据矩阵，原有的 2 维数据被压缩到了 1 维，且保留了最大的方差信息。

== 核化线性降维
面对卷曲的流形，只用直线去投影，会把不同层的数据强行“压”在一起，导致颜色混杂，丢失了流形原本的结构。

假设存在一个非线性映射函数 $Phi$，能把原始的低维样本 #mi(`\boldsymbol{x}_i`) 变成高维空间的样本 #mi(`\boldsymbol{z}_i`)，即 #mi(`\boldsymbol{z}_i = \phi(\boldsymbol{x}_i)`)。如果在高维空间里做 PCA，我们原本要求解的目标依然是特征值问题：
#mitex(`\left( \sum_{i=1}^m \boldsymbol{z}_i \boldsymbol{z}_i^\top \right) \mathbf{W} = \lambda \mathbf{W}`)

#mi(`\mathbf{W}`) 就是高维空间里的主成分方向。

令#mi(`\alpha_i = \frac{1}{\lambda} \boldsymbol{z}_i^\top \mathbf{W}`)，#mitex(`\mathbf{W} = \frac{1}{\lambda} \left( \sum_{i=1}^m \mathbf{z}_i \mathbf{z}_i^\mathrm{T} \right) \mathbf{W} = \sum_{i=1}^m \mathbf{z}_i \frac{\mathbf{z}_i^\mathrm{T} \mathbf{W}}{\lambda} = \sum_{i=1}^m \mathbf{z}_i \boldsymbol{\alpha}_i=\mathbf{Z}\mathbf{\alpha}`)

将#mi(`\mathbf{W}`)的表示代入：
#mitex(`\left( \mathbf{Z}\mathbf{Z}^\top\right) (\mathbf{Z}\boldsymbol{\alpha}) = \lambda (\mathbf{Z}\boldsymbol{\alpha})`)

等式两边同时左乘一个 #mi(`\mathbf{Z}^\top`)：#mitex(` \mathbf{Z}^\top\mathbf{Z} (\mathbf{Z}^\top\mathbf{Z}) \boldsymbol{\alpha} = \lambda \mathbf{Z}^\top\mathbf{Z} \boldsymbol{\alpha}`)

#mi(`\mathbf{Z}^\top\mathbf{Z}`) 是一个 #mi(`m \times m`) 的方阵，里面的每一个元素刚好就是 #mi(`\boldsymbol{z}_i^\top \boldsymbol{z}_j`)。故可以用核函数直接计算的核矩阵 #mi(`\mathbf{K}`)。

把 #mi(`\mathbf{K} = \mathbf{Z}^\top\mathbf{Z}`) 代进去：

#mitex(`\mathbf{K} \mathbf{K} \boldsymbol{\alpha} = \lambda \mathbf{K} \boldsymbol{\alpha}`)

等式两边消去一个 #mi(`\mathbf{K}`)（简化说明，严格证明涉及特征空间分解）：

#mitex(`\mathbf{K} \boldsymbol{\alpha} = \lambda \boldsymbol{\alpha}`)

#mi(`\mathbf{K}`)是一个 #mi(`m \times m`) 的常数矩阵，靠低维样本代入核函数 #mi(`\kappa(\boldsymbol{x}_i, \boldsymbol{x}_j)`) 瞬间算完。#mi(`\lambda`) 是标量，相当于一个新的特征值。#mi(`\boldsymbol{\alpha}`) 就是已知矩阵 #mi(`\mathbf{K}`) 的特征向量。

模型训练好了（求出了 #mi(`\boldsymbol{\alpha}`)），现在来了一个新样本 #mi(`\boldsymbol{x}`)，我们怎么把它降维呢？按理说，应该是新样本的高维坐标 #mi(`\phi(\boldsymbol{x})`) 乘以高维主成分 #mi(`\mathbf{w}_j`)：

#mitex(`z_j = \mathbf{w}_j^\top \phi(\boldsymbol{x})`)

把第 2 步中 #mi(`\mathbf{w}_j = \sum \alpha_i^j \phi(\boldsymbol{x}_i)`) 代入进去，再次出现了内积，并立刻用核函数替换：

#mitex(`z_j = \sum_{i=1}^m \alpha_i^j \kappa(\boldsymbol{x}_i, \boldsymbol{x})`)

#remark[为了求出一个新样本降维后的坐标，你需要用核函数去*计算新样本 #mi(`\boldsymbol{x}`) 和所有的训练样本 #mi(`\boldsymbol{x}_i`) 的关系并求和*。这与线性 PCA 完全不同（线性 PCA 只需要把新样本乘上一个投影矩阵就结束了）。所以，KPCA 虽然能处理复杂的非线性结构，但代价是*极高的预测（推理）计算开销*。]

== 流形学习
流形是在局部与欧氏空间同胚的空间.抛开*微分几何*而直观地说,在一个小邻域里,我们能用欧式距离来刻画.想在局部建立降维映射关系,然后再设法将局部映射关系推广到全局.#note[
  我讨厌微分几何
]
#figure(

  align(center,image("/assets/104892ea657562cb985bf412ad9262c9_720.png")),
  caption:[
    一个流形学习的例子.显然我们不希望距离算成绿色的线段,而是根据红色的线走;所以我们需要通过$k$近邻.这就是著名的ISOMAP算法.他通过算$k$近邻来计算距离矩阵,然后再输入到之前说过的MDS酱味算法.
  ]
)
=== 局部线性嵌入,LLE
局部线性嵌入试图保持邻域内的线性关系，并使得该线性关系在降维后的空间中继续保持.为每个样本$bold(x)_i$找到近邻$Q$,然后计算线性重构的系数$bold(w)_i$,也就是
$
  min_(i in cal(I))sum_(i=1)^m ||bold(x)_i - sum_(j in Q_i) w_(i j) bold(x)_j||^2 s.t. sum_(j in Q_i) w_(i j) = 1
$
得到解
$
 w_(i j) = (sum_(k in Q_i)C_(j k)^(-1))/(sum_(l,s in Q_i)C_(l s)^(-1)), C_(j k) eq.delta (bold(x_i)-bold(x_j))^T (bold(x_i)-bold(x_j))
$<lle>

当然我们想得到一个更低维度的嵌入,而且LLE规定$w$是不变的.所以,只需要考虑把低维度坐标$bold(z)$替换$bold(x)$即可.令
$
bold(Z) eq.delta \(z_1,dots,z_m\) in RR^(d' times m),\
bold(M) eq.delta (bold(I) - bold(W))^T (bold(I) - bold(W))
$
则@lle 可以被重写为
$
 min_(bold(Z)) tr(bold(Z)^T bold(M) bold(Z)) and bold(Z) bold(Z)^T = bold(I).
$

== 度量学习
#definition("度量学习的一般框架")[
度量学习的核心是学习一个半正定对称矩阵 #mi(`\mathbf{M}`)，使得：
- 相似样本在该度量下距离更近
- 不相似样本在该度量下距离更远

不同的度量学习方法针对不同目标获得"好"的半正定对称距离度量矩阵 #mi(`\mathbf{M}`)。
]
=== 研究动机

在机器学习中，对高维数据进行降维的主要目的是希望找到一个*合适的低维空间*，在此空间中进行学习能比原始空间性能更好。

事实上，每个空间对应了在样本属性上定义的一个*距离度量*，而寻找合适的空间，实质上就是在寻找一个*合适的距离度量*。那么，为何不直接尝试"学习"出一个合适的距离度量呢？——这就是度量学习的核心思想。

#note[
传统降维方法（如 PCA、MDS）是先假设一个距离度量（通常是欧氏距离），然后寻找保持该度量的低维表示。而度量学习则反其道而行之：直接学习距离度量本身，让数据告诉我们什么样的距离才是"好"的距离。
]

=== 度量学习基础

==== 平方欧氏距离

欲对距离度量进行学习，必须有一个便于学习的距离度量表达形式。对两个 $d$ 维样本 #mi(`\boldsymbol{x}_i`) 和 #mi(`\boldsymbol{x}_j`)，它们之间的平方欧氏距离可写为：

#mitex(`\mathrm{dist}_{\mathrm{ed}}^2(\boldsymbol{x}_i, \boldsymbol{x}_j) = \|\boldsymbol{x}_i - \boldsymbol{x}_j\|_2^2 = \\ \mathrm{dist}_{ij,1}^2 + \mathrm{dist}_{ij,2}^2 + \cdots + \mathrm{dist}_{ij,d}^2`)

其中 #mi(`\mathrm{dist}_{ij,k}`) 表示 #mi(`\boldsymbol{x}_i`) 与 #mi(`\boldsymbol{x}_j`) 在第 $k$ 维上的距离。

==== 加权距离（属性权重）

若假定不同属性的重要性不同，则可引入属性权重 #mi(`\boldsymbol{w}`)，得到加权欧氏距离：

#mitex(`\begin{aligned}
\mathrm{dist}_{\mathrm{wed}}^2(\boldsymbol{x}_i, \boldsymbol{x}_j) &= \|\boldsymbol{x}_i - \boldsymbol{x}_j\|_2^2 \\
&= w_1 \cdot \mathrm{dist}_{ij,1}^2 + \cdots + w_d \cdot \mathrm{dist}_{ij,d}^2 \\
&= (\boldsymbol{x}_i - \boldsymbol{x}_j)^\mathrm{T} \mathbf{W} (\boldsymbol{x}_i - \boldsymbol{x}_j)
\end{aligned}`)

其中 #mi(`w_i \geq 0`)，#mi(`\mathbf{W} = \mathrm{diag}(\boldsymbol{w})`) 是一个对角矩阵，#mi(`(\mathbf{W})_{ii} = w_i`)。

#remark[
此时权重矩阵 $W$ 的非对角元素均为零，这意味着坐标轴是正交的，即属性之间无关。但现实问题中往往不是这样——例如考虑西瓜的"重量"和"体积"这两个属性，它们显然是正相关的，其对应的坐标轴不再正交。
]

==== 度量矩阵推广

为此将 $W$ 替换为一个普通的*半正定对称矩阵* #mi(`\mathbf{M}`)，于是得到了马氏距离（Mahalanobis distance）：

#mitex(`\mathrm{dist}_{\mathrm{mah}}^2(\boldsymbol{x}_i, \boldsymbol{x}_j) = (\boldsymbol{x}_i - \boldsymbol{x}_j)^\mathrm{T} \mathbf{M} (\boldsymbol{x}_i - \boldsymbol{x}_j) = \|\boldsymbol{x}_i - \boldsymbol{x}_j\|_{\mathbf{M}}^2`)

其中 #mi(`\mathbf{M}`) 亦称*度量矩阵*，而*度量学习则是对 #mi(`\mathbf{M}`) 进行学习*。

==== 度量矩阵的性质

注意到为了保持距离非负且对称，#mi(`\mathbf{M}`) 必须是（半）正定对称矩阵，即必有正交基 #mi(`\mathbf{P}`) 使得 #mi(`\mathbf{M}`) 能写为：

#mitex(`\mathbf{M} = \mathbf{P} \mathbf{P}^\mathrm{T}`)

#note[
*半正定矩阵（Positive Semidefinite Matrix）*

一个 $n times n$ 的实对称矩阵 #mi(`\mathbf{A}`) 称为半正定矩阵，如果对于任意非零向量 #mi(`\boldsymbol{x} \in \mathbb{R}^n`)，都满足：

#mitex(`\boldsymbol{x}^\mathrm{T} \mathbf{A} \boldsymbol{x} \geq 0`)

半正定矩阵的主要性质：
- *特征值非负*：所有特征值 $lambda_i \geq 0$
- *可分解性*：任意半正定矩阵 #mi(`\mathbf{A}`) 都可分解为 #mi(`\mathbf{A} = \mathbf{P} \mathbf{P}^\mathrm{T}`)，其中 #mi(`\mathbf{P}`) 是某个矩阵
- *距离非负*：若度量矩阵 #mi(`\mathbf{M}`) 是半正定的，则对任意两点 #mi(`\boldsymbol{x}_i, \boldsymbol{x}_j`)，马氏距离 #mi(`\|\boldsymbol{x}_i - \boldsymbol{x}_j\|_{\mathbf{M}}^2 \geq 0`) 恒成立

*正交基（Orthogonal Basis）*

一组向量 #mi(`\{\boldsymbol{p}_1, \boldsymbol{p}_2, \ldots, \boldsymbol{p}_k\}`) 称为正交基，如果满足：
- *两两正交*：#mi(`\boldsymbol{p}_i^\mathrm{T} \boldsymbol{p}_j = 0`)（当 $i \neq j$）
- *单位长度*：#mi(`\|\boldsymbol{p}_i\|_2 = 1`)

若矩阵 #mi(`\mathbf{P}`) 的列向量构成正交基，则 #mi(`\mathbf{P}`) 是正交矩阵，满足 #mi(`\mathbf{P}^\mathrm{T} \mathbf{P} = \mathbf{I}`)。

*两者关系*

根据谱分解定理，任意半正定对称矩阵 #mi(`\mathbf{M}`) 都可以进行特征值分解：
#mitex(`\mathbf{M} = \mathbf{Q} \mathbf{\Lambda} \mathbf{Q}^\mathrm{T}`)
其中 #mi(`\mathbf{Q}`) 是正交矩阵（列向量为标准正交特征向量），#mi(`\mathbf{\Lambda}`) 是对角矩阵（对角线为非负特征值）。

令 #mi(`\mathbf{P} = \mathbf{Q} \mathbf{\Lambda}^{1/2}`)，则 #mi(`\mathbf{M} = \mathbf{P} \mathbf{P}^\mathrm{T}`)。这就是度量矩阵分解的理论依据。
]

对 #mi(`\mathbf{M}`) 进行学习当然要设置一个目标。假定我们是希望提高近邻分类器的性能，则可将 #mi(`\mathbf{M}`) 直接嵌入到近邻分类器的评价指标中去，通过优化该性能指标相应地求得 #mi(`\mathbf{M}`)。#note[
在新空间算“欧氏距离”（用 #mi(`\mathbf{P}`) 投影），在数学上完全等价于在原空间算“加权距离”（用 #mi(`\mathbf{M}`) 做中间件）。这就是 #mi(`\mathbf{M} = \mathbf{P}\mathbf{P}^T`) 的来历。
]

下面以近邻成分分析为例讨论。

=== 近邻成分分析（NCA）

近邻成分分析（Neighbourhood Component Analysis, NCA）相对于K means有两点不同。
+ K means进行判别时通常使用*多数投票法*，邻域中的每个样本投 1 票，邻域外的样本投 0 票。不妨将其替换为*概率投票法*。
+ 直接算欧氏距离，模型会平等地对待每一个维度。但如果某些特征用处不大，欧氏距离就会失效。NCA 学习一个矩阵 P，*把原始数据通过 P 投影*后，在新的空间里，同类样本会聚集在一起。
  
对于任意样本 #mi(`\boldsymbol{x}_j`)，它对 #mi(`\boldsymbol{x}_i`) 分类结果影响的概率为：

#mitex(`p_{ij} = \frac{\exp(-\|\boldsymbol{x}_i - \boldsymbol{x}_j\|_{\mathbf{M}}^2)}{\sum_l \exp(-\|\boldsymbol{x}_i - \boldsymbol{x}_l\|_{\mathbf{M}}^2)} \qquad \text{式 (10.35)}`)

当 $i = j$ 时，$p_(i j)$ 最大。显然，#mi(`\boldsymbol{x}_j`) 对 #mi(`\boldsymbol{x}_i`) 的影响随着它们之间距离的增大而减小。

若以*留一法（LOO）正确率的最大化*为目标，则可计算 #mi(`\boldsymbol{x}_i`) 的留一法正确率，即它被自身之外的所有样本正确分类的概率为：

#mitex(`p_i = \sum_{j \in \Omega_i} p_{ij}`)

其中 #mi(`\Omega_i`) 表示与 #mi(`\boldsymbol{x}_i`) 同类的样本集合。

整个样本集上的留一法正确率为：

#mitex(`\sum_{i=1}^m p_i = \sum_{i=1}^m \sum_{j \in \Omega_i} p_{ij}`)

将式 (10.35) 带入上式。



再考虑到 #mi(`\mathbf{M} = \mathbf{P} \mathbf{P}^\mathrm{T}`)，则 NCA 的优化目标为：

#mitex(`\min_{\mathbf{P}} 1 - \sum_{i=1}^m \sum_{j \in \Omega_i} \frac{\exp(-\|\mathbf{P}^\mathrm{T} \boldsymbol{x}_i - \mathbf{P}^\mathrm{T} \boldsymbol{x}_j\|_2^2)}{\sum_l \exp(-\|\mathbf{P}^\mathrm{T} \boldsymbol{x}_i - \mathbf{P}^\mathrm{T} \boldsymbol{x}_l\|_2^2)}`)

求解即可得到*最大化近邻分类器 LOO 正确率*的距离度量矩阵 #mi(`\mathbf{M}`)。

#algorithm("近邻成分分析（NCA）")[
*输入：* 样本集 #mi(`D = \{(\boldsymbol{x}_1, y_1), (\boldsymbol{x}_2, y_2), \ldots, (\boldsymbol{x}_m, y_m)\}`)；目标维度 $d'$。

*输出：* 度量矩阵 #mi(`\mathbf{M}`) 或降维矩阵 #mi(`\mathbf{P} \in \mathbb{R}^{d \times d'}`)。

*过程：*
1. *初始化*：初始化降维矩阵 #mi(`\mathbf{P}`)（如随机初始化或使用 PCA 结果）。
2. *计算概率*：对于每对样本 $(i, j)$，计算概率投票：
   $
   p_(i j) = exp(-||bold(P)^T bold(x)_i - bold(P)^T bold(x)_j||_2^2) / (sum_l exp(-||bold(P)^T bold(x)_i - bold(P)^T bold(x)_l||_2^2))
   $
3. *计算目标函数*：计算留一法正确率：
   $
   f(bold(P)) = sum_(i=1)^m sum_(j in Omega_i) p_(i j)
   $
4. *梯度优化*：通过梯度上升法更新 #mi(`\mathbf{P}`)，最大化目标函数 $f(bold(P))$。
5. *输出结果*：返回优化后的 #mi(`\mathbf{P}`)，度量矩阵为 #mi(`\mathbf{M} = \mathbf{P} \mathbf{P}^\mathrm{T}`)。
]

#remark[
NCA 的目标函数是 *1 减去留一法正确率*，因此是最小化问题。这等价于最大化留一法正确率。优化过程通常使用梯度下降法（或梯度上升法，取决于符号约定）。
]

=== 度量学习的扩展

==== 监督学习目标

实际上，我们*不仅能把错误率*这样的监督学习目标作为度量学习的优化目标，还能在度量学习中引入*领域知识*。

==== 领域知识引入

若已知某些样本相似、某些样本不相似，则可定义*必连*（must-link）约束集合 #mi(`\mathcal{M}`) 与*勿连*（cannot-link）约束集合 #mi(`\mathcal{C}`)：
- #mi(`(\boldsymbol{x}_i, \boldsymbol{x}_j) \in \mathcal{M}`) 表示 #mi(`\boldsymbol{x}_i`) 与 #mi(`\boldsymbol{x}_j`) 相似
- #mi(`(\boldsymbol{x}_i, \boldsymbol{x}_k) \in \mathcal{C}`) 表示 #mi(`\boldsymbol{x}_i`) 与 #mi(`\boldsymbol{x}_k`) 不相似

显然，我们希望相似的样本之间距离较小，不相似的样本之间距离较大。

==== 约束优化问题

于是可通过求解下面这个凸优化问题获得适当的度量矩阵：

#mitex(`\begin{aligned}
\min_{\mathbf{M}} \quad & \sum_{(\boldsymbol{x}_i, \boldsymbol{x}_j) \in \mathcal{M}} \|\boldsymbol{x}_i - \boldsymbol{x}_j\|_{\mathbf{M}}^2 \\
\mathrm{s.t.} \quad & \sum_{(\boldsymbol{x}_i, \boldsymbol{x}_k) \in \mathcal{C}} \|\boldsymbol{x}_i - \boldsymbol{x}_k\|_{\mathbf{M}}^2 \geq 1 \\
& \mathbf{M} \succeq 0
\end{aligned}`)

其中约束 #mi(`\mathbf{M} \succeq 0`) 表明 #mi(`\mathbf{M}`) 必须是半正定的。上式要求在不相似样本间的距离不小于 1 的前提下，使相似样本间的距离尽可能小。

=== 度量学习与降维的关系

不同的度量学习方法针对不同目标获得"好"的半正定对称距离度量矩阵 #mi(`\mathbf{M}`)。若 #mi(`\mathbf{M}`) 是一个*低秩矩阵*，则通过对 #mi(`\mathbf{M}`) 进行特征值分解，总能找到一组正交基，其正交基数目为矩阵 #mi(`\mathbf{M}`) 的秩 #mi(`\mathrm{rank}(\mathbf{M})`)，小于原属性数 $d$。

于是，度量学得的结果可衍生出一个*降维矩阵*：

#mitex(`\mathbf{P} \in \mathbb{R}^{d \times \mathrm{rank}(\mathbf{M})}`)

能用于降维的目的。

#remark[
度量学习与降维之间存在紧密联系：
- 度量学习学得一个度量矩阵 #mi(`\mathbf{M}`)
- 若 #mi(`\mathbf{M}`) 是低秩的，则其自然蕴含了降维
- 通过对 #mi(`\mathbf{M}`) 进行特征值分解 #mi(`\mathbf{M} = \mathbf{P} \mathbf{P}^\mathrm{T}`)，可得降维矩阵 #mi(`\mathbf{P}`)
- 原始样本 #mi(`\boldsymbol{x}`) 经 #mi(`\mathbf{P}^\mathrm{T} \boldsymbol{x}`) 变换后即为降维后的表示

因此，度量学习不仅可以改善距离度量，还能同时实现降维，一举两得。
]