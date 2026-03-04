#import "../../notes.typ":*
#show:notes

== 主成分分析

主成分分析（principal componentanalysis，PCA）是一种常用的无监督学习方法，这一方法*利用正交变换把由线性相关变量表示的观测数据转换为少数几个由线性无关变量表示的数据*，线性无关的变量称为*主成分*。主成分的个数通常小于原始变量的个数，所以*主成分分析属于降维方法*。主成分分析主要用于发现数据中的基本结构，即数据中变量之间的关系，是数据分析的有力工具，也用于其他机器学习方法的前处理。

=== 总体主成分分析

主成分分析中，首先对给定数据进行规范化，使得数据每一变量的平均值为0，方差为1。之后对数据进行正交变换，原来由线性相关变量表示的数据通过正交变换变成由若干个线性无关的新变量表示的数据。新变量是可能的正交变换中变量的方差的和（信息保存）最大的，方差表示在新变量上信息的大小。将新变量依次称为第一主成分、第二主成分等。这就是主成分分析的基本思想。通过主成分分析，可以利用主成分近似地表示原始数据，这可理解为发现数据的“基本结构”：也可以把数据由少数主成分表示，这可理解为对数据降维。

下面给出主成分分析的直观解释。数据集合中的样本由实数空间（正交坐标系）中的点表示，空间的一个坐标轴表示一个变量，规范化处理后得到的数据分布在原点附近。*对原坐标系中的数据进行主成分分析等价于进行坐标系旋转变换*，将数据投影到新坐标系的坐标轴上：新坐标系的第一坐标轴、第二坐标轴等分别表示第一主成分、第二主成分等，数据在每一轴上的坐标值的平方表示相应变量的方差：并且，这个坐标系是在所有可能的新的坐标系中，坐标轴上的方差的和最大的。

主成分分析选择方差最大的方向（第一主成分）作为新坐标系的第一坐标轴，即$y_1$轴，在这里意味着选择椭圆的长轴作为新坐标系的第一坐标轴; 之后选择与第一坐标轴正交且方差次之的方向（第二主成分）作为新坐标系的第二坐标轴，即$y_2$轴，在这里意味着选择椭圆的短轴作为新坐标系的第二坐标轴。在新坐标系里，数据中的变量$y_1$和$y_2$是线性无关的如果主成分分析只取第一主成分，即新坐标系的$y_1$轴，那么等价于将数据投影在椭圆长轴上，用这个主轴表示数据，将二维空间的数据压缩到一维空间中。

下面再看方差最大的解释。假设有两个变量 $x_1$ 和 $x_2$，三个样本点 A, B, C，样本分布在由 $x_1$ 轴和 $x_2$ 轴组成的坐标系中。对坐标系进行旋转变换，得到新的坐标轴 $y_1$，表示新的变量 $y_1$。样本点 A, B, C 在 $y_1$ 轴上投影，得到 $y_1$ 轴的坐标值 A', B', C'。

坐标值的平方和 $O A'^2 + O B'^2 + O C'^2$ 表示样本在变量 $y_1$ 上的方差和。主成分分析旨在选取正交变换中方差最大的变量，作为第一主成分，也就是旋转变换中坐标值的平方和最大的轴。注意到旋转变换中样本点到原点的距离的平方和 $O A^2 + O B^2 + O C^2$ 保持不变，根据勾股定理，坐标值的平方和 $O A'^2 + O B'^2 + O C'^2$ 最大等价于样本点到 $y_1$ 轴的距离的平方和 $A A'^2 + B B'^2 + C C'^2$ 最小。所以，*等价地，主成分分析在旋转变换中选取离样本点的距离平方和最小的轴作为第一主成分*。*第二主成分等的选取在保证与已选坐标轴正交的条件下类似地进行*。

在数据总体（population）上进行的主成分分析称为总体主成分分析，在有限样本上进行的主成分分析称为样本主成分分析，前者是后者的基础。以下分别予以介绍。

假设 $bold(x) = (x_1, x_2, dots, x_m)^T$ 是 $m$ 维随机变量，其均值向量是 $bold(mu)$：

$ bold(mu) = E(bold(x)) = (mu_1, mu_2, dots, mu_m)^T $

协方差矩阵是 $bold(Sigma)$：

$ bold(Sigma) = op("cov")(bold(x), bold(x)) = E[(bold(x) - bold(mu)) (bold(x) - bold(mu))^T] $

考虑由 $m$ 维随机变量 $bold(x)$ 到 $m$ 维随机变量 $bold(y) = (y_1, y_2, dots, y_m)^T$ 的线性变换：

$ y_i = bold(alpha)_i^T bold(x) = alpha_(1i) x_1 + alpha_(2i) x_2 + dots + alpha_(m i) x_m $

其中，$bold(alpha)_i^T = (alpha_(1i), alpha_(2i), dots, alpha_(m i)), quad i = 1, 2, dots, m$。
由随机变量的性质可知：

$ E(y_i) = bold(alpha)_i^T bold(mu), quad i = 1, 2, dots, m $

$ op("var")(y_i) = bold(alpha)_i^T bold(Sigma) bold(alpha)_i, quad i = 1, 2, dots, m $

$ op("cov")(y_i, y_j) = bold(alpha)_i^T bold(Sigma) bold(alpha)_j, quad i = 1, 2, dots, m; quad j = 1, 2, dots, m $

#definition[总体主成分][
  对于一个线性变换，如果他们满足下列条件：

  (1) 系数向量 $bold(alpha)_i^T$ 是单位向量，即 $bold(alpha)_i^T bold(alpha)_i = 1, i = 1, 2, dots, m$；
  
  (2) 变量 $y_i$ 与 $y_j$ 互不相关，即 $op("cov")(y_i, y_j) = 0 (i eq.not j)$；
  
  (3) 变量 $y_1$ 是 $bold(x)$ 的所有线性变换中方差最大的；$y_2$ 是与 $y_1$ 不相关的 $bold(x)$ 的所有线性变换中方差最大的；一般地，$y_i$ 是与 $y_1, y_2, dots, y_(i-1) (i = 1, 2, dots, m)$ 都不相关的 $bold(x)$ 的所有线性变换中方差最大的，这时分别称 $y_1, y_2, dots, y_m$ 为 $bold(x)$ 的第一主成分、第二主成分、……、第 $m$ 主成分。
]

定义中的条件 (1) 表明线性变换是正交变换, $bold(alpha)_1, bold(alpha)_2, dots, bold(alpha)_m$ 是其一组标准正交基:
$ bold(alpha)_i^"T" bold(alpha)_j = cases(
  1\, & i = j,
  0\, & i != j
) $

条件 (2) 和条件 (3) 给出了一个求主成分的方法: 第一步, 在 $bold(x)$ 的所有线性变换
$ bold(alpha)_1^"T" bold(x) = sum_(i=1)^m alpha_(i 1) x_i $
中, 在 $bold(alpha)_1^"T" bold(alpha)_1 = 1$ 的条件下, 求方差最大的, 得到 $bold(x)$ 的第一主成分; 第二步, 在与 $bold(alpha)_1^"T" bold(x)$ 不相关的 $bold(x)$ 的所有线性变换
$ bold(alpha)_2^"T" bold(x) = sum_(i=1)^m alpha_(i 2) x_i $
中, 在 $bold(alpha)_2^"T" bold(alpha)_2 = 1$ 的条件下, 求方差最大的, 得到 $bold(x)$ 的第二主成分; 第 $k$ 步, 在与 $bold(alpha)_1^"T" bold(x), bold(alpha)_2^"T" bold(x), dots, bold(alpha)_(k-1)^"T" bold(x)$ 不相关的 $bold(x)$ 的所有线性变换
$ bold(alpha)_k^"T" bold(x) = sum_(i=1)^m alpha_(i k) x_i $
中, 在 $bold(alpha)_k^"T" bold(alpha)_k = 1$ 的条件下, 求方差最大的, 得到 $bold(x)$ 的第 $k$ 主成分; 如此继续下去, 直到得到 $bold(x)$ 的第 $m$ 主成分。

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

#proof[略]

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
=== 样本主成分分析


#definition[样本主成分][
 给定样本矩阵 $bold(X)$。样本第一主成分 $y_1 = bold(a)_1^top bold(x)$ 是在 $bold(a)_1^top bold(a)_1 = 1$ 条件下，使 $bold(a)_1^top bold(x)_j (j=1, 2, dots, n)$ 的样本方差 $bold(a)_1^top bold(S) bold(a)_1$ 最大的 $bold(x)$ 的线性变换；样本第二主成分 $y_2 = bold(a)_2^top bold(x)$ 是在 $bold(a)_2^top bold(a)_2 = 1$ 和 $bold(a)_2^top bold(x)_j$ 与 $bold(a)_1^top bold(x)_j (j=1, 2, dots, n)$ 的样本协方差 $bold(a)_2^top bold(S) bold(a)_1 = 0$ 条件下，使 $bold(a)_2^top bold(x)_j (j=1, 2, dots, n)$ 的样本方差 $bold(a)_2^top bold(S) bold(a)_2$ 最大的 $bold(x)$ 的线性变换；一般地，样本第 $i$ 主成分 $y_i = bold(a)_i^top bold(x)$ 是在 $bold(a)_i^top bold(a)_i = 1$ 和 $bold(a)_i^top bold(x)_j$ 与 $bold(a)_k^top bold(x)_j (k < i, j=1, 2, dots, n)$ 的样本协方差 $bold(a)_k^top bold(S) bold(a)_i = 0$ 条件下，使 $bold(a)_i^top bold(x)_j (j=1, 2, dots, n)$ 的样本方差 $bold(a)_i^top bold(S) bold(a)_i$ 最大的 $bold(x)$ 的线性变换。
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

#algorithm[相关矩阵的特征值分解算法][
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

#algorithm[主成分分析算法][
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
