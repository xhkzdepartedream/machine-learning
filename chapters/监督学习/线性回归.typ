// #import "../../notes.typ":*
// #show:notes
#import "@local/ysz_tools:0.1.0":*
#show: conf.with(
   title:"s"
)
#import "@preview/cuti:0.4.0":show-cn-fakebold
#show:show-cn-fakebold
//#show ",":"，"
//#show ":":"："
#import "@preview/cetz:0.4.1"
#import "@preview/mitex:0.2.5": *
#show math.equation: it => {
  show "xx": $bold(x)$
  it
}
== 线性回归
=== 基本概念
#definition[线性回归][
线性回归（linear regression）是利用称为线性回归方程的最小二乘函数对一个或多个自变量和因变量之间关系进行建模的一种回归分析。这种函数是一个或多个称为回归系数的模型参数的线性组合。只有一个自变量的情况称为简单回归，大于一个自变量情况的叫做多元回归（multivariable linear regression）。

给定数据集$D={("xx"_1,y_1),(x_2,y_2),dots,(x_m,y_m)}$, 样本空间由$d$维向量张成, $x_i=(x_"i1",x_"i2",dots,x_"id")^T, y_i in RR$, 则：

线性回归方程为：
$
  hat(y_i)=g(x_i)=x_i^T w+w_0
$
$hat(y_i)$是回归预测值，$w=(w_1,dots,w_d)^T$和$w_0$是模型的参数。
]

最小化MSE, 求解最优参数：
$
  w^*=arg min_w sum_(i=1)^m (hat(y_i)-y_i)^2=arg min_w (y-X w)^T (y-X w)
$
这里直接令
$
  L(w)=(y-X w)^T (y-X w)
$
求导得
$
  (partial L(w))/(partial w)=2X^T (X w-y)=0\
  w^*=(X^T X)^(-1)X^T y
$
所以得到
$
  hat(y_i)=g(x_i)=x_i^T (X^T X)^(-1)X^T y
$

这便是最小二乘法.
若$X^T X$为满秩矩阵，则$(X^T X)^(-1)$可求，最优参数$w^*$可直接解出，但是往往会遇到样本维数远大于样本个数（此时行数小于列数，一定不满秩）的情况，比如图像样本，则会导致$X^T X$不满秩。若不可逆，则采用梯度下降法（后续展开）来训练参数。

#remark[
  这里的$w$是把$x_i^T w+w_0$中的$w$与$w_0$结合成一个相同的向量了，这样形式更加简洁。

  同时$X$矩阵也增加了一个全是1的列。
]




// #note[矩阵求导方法][
// 方法一：展开求导法 (Standard Expansion)

// 这是最稳健的方法，核心是将矩阵运算展开成多项式形式，类比标量求导。
// 展开矩阵乘法：
// 利用转置性质 $(bold(A) - bold(B))^T = bold(A)^T - bold(B)^T$，将式子展开：
// $ L(bold(w)) &= (bold(y)^T - bold(w)^T bold(X)^T) (bold(y) - bold(X) bold(w))
// &= bold(y)^T bold(y) - underbrace(bold(y)^T bold(X) bold(w), "标量 A") - underbrace(bold(w)^T bold(X)^T bold(y), "标量 B") + bold(w)^T bold(X)^T bold(X) bold(w) $
// 合并同类项：
// 注意 $bold(y)^T bold(X) bold(w)$ 的结果是一个实数（标量）。实数的转置等于它自身：
// $(bold(y)^T bold(X) bold(w))^T = bold(w)^T bold(X)^T bold(y)$
// 因此中间两项相等，可以合并：
// $L(bold(w)) = bold(y)^T bold(y) - 2 bold(w)^T bold(X)^T bold(y) + bold(w)^T bold(X)^T bold(X) bold(w)$
// 逐项求导：
// 利用矩阵求导公式：
// $nabla_{bold(w)} (bold(w)^T bold(a)) = bold(a)$ （类比 $a x$' 的导数为 $a$）
// $nabla_{bold(w)} (bold(w)^T bold(A) bold(w)) = 2 bold(A) bold(w)$ （类比 $a x^2$' 的导数为 $2a x$）
// 得：
// $(partial L(bold(w))) / (partial bold(w)) = 0 - 2 bold(X)^T bold(y) + 2 bold(X)^T bold(X) bold(w)$
// 方法二：链式法则法 (Chain Rule)
// 这是更快捷的方法，将 $(bold(y) - bold(X) bold(w))$ 看作一个整体，避免繁琐的展开。
// 令中间变量 $bold(z) = bold(y) - bold(X) bold(w)$，则 $L(bold(w)) = bold(z)^T bold(z)$。
// 根据复合函数求导法则（外层导数 $times$ 内层导数）：
// $(partial L) / (partial bold(w)) = (partial bold(z)) / (partial bold(w))^T dot (partial L) / (partial bold(z))$
// 外层导数 ($L$ 对 $bold(z)$)：
// $L = bold(z)^T bold(z) = ||bold(z)||^2$，类比 $x^2$，导数为 $2bold(z)$。
// $(partial L) / (partial bold(z)) = 2 bold(z) = 2(bold(y) - bold(X) bold(w))$
// 内层导数 ($bold(z)$ 对 $bold(w)$)：
// $bold(z) = bold(y) - bold(X) bold(w)$，类比 $-a x$，导数系数为 $-bold(X)$。
// $(partial bold(z)) / (partial bold(w)) = -bold(X)$
// 组合：
// 注意维度匹配（内层系数转置后左乘外层）：
// $ (partial L(bold(w))) / (partial bold(w)) &= (-bold(X))^T dot 2(bold(y) - bold(X) bold(w))
// &= -2 bold(X)^T (bold(y) - bold(X) bold(w))
// &= -2 bold(X)^T bold(y) + 2 bold(X)^T bold(X) bold(w) $
// ]
// #note[
// 特别地，对于二元线性回归，有：
// $
// w_1&=frac(sum_(i=1)^n (x_i-macron(x))(y_i-macron(y)), sum_(i=1)^n (x_i-macron(x))^2)
// w_0&=macron(y)-w_1 macron(x)
// $
// ]
微分法 (Differential Method)：这是处理复杂表达式最高效的方法。首先计算标量函数的微分 $d f$，然后将其整理成与 $d X$ 内积的形式，即 $ d f = tr((∂f/∂X)ᵀ d X)$，从而直接读出导数。
$$

=== 岭回归与拉索回归

岭回归（Ridge regression）和拉索回归（ Lasso regression ）是带有正则化的线性回归。

岭回归在线性回归代价函数上添加了$L_2$正则化项：
$
  L(w)=1/(2m)[sum_(i=1)^m (hat(y_i)-y_i)^2+lambda sum_(j=1)^d w_j^2]
$
岭回归代价函数最小二乘优化的闭式解：
$
  w^*=(X^T X+lambda I)^(-1) X^T y
$
$I$是单位矩阵，保证$(X^T X+lambda I)$可逆，$w$具有闭式解。

#align(center, table(
  columns: (1.2fr, 1.5fr, 1.5fr),
  align: horizon + left,
  // ===== 表头 =====
  table.header(
    [*特性维度*],
    [*闭式解 (解析解)*],
    [*梯度下降法 (迭代法)*],
  ),
  // ===== 表格主体 =====
  [*计算效率*],
  [特征维度高时，计算逆矩阵的*代价非常高*（复杂度约$O(n³)$）],
  [通过迭代逼近，*避免直接求逆*，适合高维特征],

  [*内存需求*],
  [需要*一次性将整个数据集矩阵加载到内存*中计算],
  [支持*分批处理数据*（如随机梯度下降），对内存友好],

  [*适用问题*],
  [标准线性岭回归],
  [适用范围更广，可用于其他*不可微或更复杂的损失函数*（如Lasso回归的L1正则项）],

  [*灵活性*],
  [固定形式，调整正则化参数λ后需*重新计算*],
  [灵活，便于*在线学习*（模型可随新数据增量更新）],

  [*实现与稳定性*],
  [依赖矩阵求逆，当矩阵接近奇异时，即使有正则化，数值计算仍可能*不稳定*],
  [实现相对直接，数值稳定性较好，尤其适合大规模问题],
))

#note[
  即使有了闭式解，梯度下降法仍然有必要性。
]

岭回归代价函数的梯度下降迭代：
$
  w_k^((i+1)) <- w_k^((i))-eta nabla_w_k L(w_k^((i)))=w_k^((i))-eta/m (X^T (X w-y)+lambda w_k^((i)))
$

拉索回归在线性回归代价函数上添加了$L_1$正则化项（拉索回归没有通用的闭式解）:
$
  L(w)=1/(2m)[sum_(i=1)^m (hat(y_i)-y_i)^2+lambda sum_(j=1)^d |w_j| ]
$

#note[正则化项设计对比][
  - *L2正则化（岭回归）*​​：惩罚项是权重的平方和。这是一个平滑的、凸的函数，其梯度在权重接近零时也会变小。因此，在优化过程中，权重会逐渐缩小，但除非正则化参数λ趋于无穷大，否则权重不会精确为零。这意味着所有特征都会被保留，只是权重值变小了。
  - *L1正则化（Lasso 回归）*​​：惩罚项是权重的绝对值之和。这是一个非平滑的函数，在零点处不可导（有“尖点”）。当使用梯度下降或专用算法（如坐标下降）优化时，这些尖点使得最优解更容易出现在坐标轴上，即某些权重恰好为零。这称为*稀疏性*。

#figure(
  table(
    columns: 2,
    align: left,
    [*L2 正则化 (圆形约束)*], [*L1 正则化 (棱形约束)*],
    [$w_1^2 + w_2^2 <= C$], [$|w_1| + |w_2| <= C$],
    [约束区域是一个*圆*。圆形是光滑的，没有突出的顶点。], [约束区域是一个*棱形*（正方形旋转）。它有尖锐的*顶点*，且顶点位于坐标轴上。],
    [等高线膨胀时，极大概率切在圆周的非轴位置（$w_1 != 0, w_2 != 0$）。], [等高线膨胀时，极易先碰到向外突出的*尖角*（即坐标轴 $w_i=0$ 的位置）。],
    [*结论*：参数变小，但很难为 0。], [*结论*：参数容易卡在坐标轴上，变为 0。]
  ),
  caption: "L1 与 L2 约束区域的几何对比"
)
#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: horizon,
  [*场景*], [*首选方法*], [*理由*],
  [特征维度极高，噪音多], [*L1 (Lasso)*], [自带特征选择，能把无用特征系数置为 0，模型更简单。],
  [需要模型解释性], [*L1 (Lasso)*], [得到稀疏解，容易解释哪几个特征起了决定性作用。],
  [特征较少，且都很重要], [*L2 (Ridge)*], [保留所有特征信息，通常预测精度略高，计算更稳定。],
  [特征间存在多重共线性], [*L2 (Ridge)*], [L1 倾向于随机保留相关特征中的一个；L2 会平摊权重，更稳健。]
)
]


=== 相关量化指标
- 平均绝对误差(Mean Absolute Error, MAE):
$
  "MAE"=1/n sum_(i=1)^n |hat(y_i)-y_i|
$
- 均方误差(Mean-Square Error, MSE):
$
  "MSE"=1/n sum_(i=1)^n (hat(y_i)-y_i)^2
$
- 均方根误差(Root MSE):
$
  "RMSE"=sqrt(1/n sum_(i=1)^n (hat(y_i)-y_i)^2)
$
- 残差平方和(Sum of Squares due to Error, SSE):
$
  "SSE"=sum_(i=1)^n (hat(y_i)-y_i)^2
$
- 回归平方和(Sum of Squares of Regression, SSR):
$
  "SSR"=sum_(i=1)^n (hat(y_i)-macron(y))^2
$
- 总离平方和(Total Sum of Squares, SST):
$
  "SST"=sum_(i=1)^n (y_i-macron(y))^2
$
- $R$-平方系数(决定系数)($R$-Square):
$
  R^2="SSR"/"SST"=1-"SSE"/"SST"
$

#theorem[
  当$L(w)$不考虑正则化损失时，有：
  $
    "SST"="SSR"+"SSE"
  $
  当考虑正则化损失式，等式退化为不等式：
  $
    "SST"<"SSR"+"SSE"
  $
]
#proof[
$
  "SST"&=sum_(i=1)^n (y_i-macron(y))^2=sum_(i=1)^n (y_i-hat(y_i)+hat(y_i)-macron(y))^2\
  &=sum_(i=1)^n (hat(y_i)-y_i)^2+sum_(i=1)^n (hat(y_i)-macron(y))^2+2sum_(i=1)^n (y_i-hat(y_i))(hat(y_i)-macron(y))\
  &="SSE"+"SSR"+2sum_(i=1)^n (y_i-hat(y_i))(hat(y_i)-macron(y))
$
下证$sum_(i=1)^n (y_i-hat(y_i))(hat(y_i)-macron(y))=0$.

注意到:
$
  (partial L(w))/(partial w_0)=0 arrow.double.r sum_(i=1)^m (hat(y_i)-y_i)=0\
  
$
$  
  &(partial L(w))/(partial w)=0 arrow.double.r sum_(i=1)^m x_i^T w (hat(y_i)-y_i)=0
$
所以有:
$
  sum_(i=1)^n (y_i-hat(y_i))(hat(y_i)-macron(y))
  &=sum_(i=1)^n (y_i - hat(y_i))hat(y_i)-macron(y)sum_(i=1)^m x_i^T w (hat(y_i)-y_i)\
  &=sum_(i=1)^n (y_i-hat(y_i))hat(y_i)\
  &=sum_(i=1)^n (y_i-hat(y_i))(x_i^T w+w_0)\
  &=sum_(i=1)^n (y_i-hat(y_i))x_i^T w+w_0 sum_(i=1)^n (y_i-hat(y_i))=0
$
]

#note[
  这个等式的核心含义是：​因变量 y的总变异（SST）可以精确地分解为两部分​：一部分是由回归模型解释的变异（SSR）​,另一部分是模型无法解释的剩余变异（SSE）​.

  普通最小二乘有完美的数学性质, 正则化是为了实用目的​（防止过拟合）而进行的修改。
]
用于代价（损失）函数的MAE、MSE与用于回归性能度量的MAE、MSE的区别联系
#align(center, table(

  columns: (1fr, 1fr, 1fr),
  table.header(
    [*方面*],
    [*作为损失函数*], 
    [*作为性能度量*]
  ),
  [*计算阶段*],
  [训练过程中不断计算],
  [训练完成后一次性计算],
  
  [*数据使用*],
  [使用训练数据],
  [使用验证集/测试集],
  
  [*目的*],
  [指导参数优化],
  [评估模型泛化能力],
  
  [*影响模型*],
  [直接影响权重更新],
  [不影响模型内部参数]
))

#theorem[
  在二元线性回归中，$R^2=rho_(X Y)^2$.
  $
    rho_(X Y)=frac("Cov"(X,Y),sqrt("Var"(X)"Var"(Y)))=frac(sum_(i=1)^n (x_i-macron(x))(y_i-macron(y)), sqrt(sum_(i=1)^n (x_i-macron(x))sum_(i=1)^n (y_i-macron(y))))
  $
]

#proof[
  只需要带入公式得到，此时
  $
    "SSR"=sum_(i=1)^n (hat(y_i)-macron(y))^2=w_1^2 sum_(i=1)^n (x_i-macron(x))^2=frac((sum_(i=1)^n (x_i-macron(x))(y_i-macron(y)))^2, sum_(i=1)^n (x_i-macron(x))^2)
  $
  其余只需要带入计算即可得到结论。
]

#note[
  $R^2$衡量的是因变量$Y$的方差中有多少比例可以被自变量$X$解释, $rho_(X Y)^2$表示两个变量共享的方差比例, 定理将这两个看似不同的概念统一起来，使$R^2$有了更直观的统计意义。

  这可以带来使得，在简单线性回归中，可以直接用相关系数计算$R^2$, 无需进行完整的回归分析, 提供了验证回归模型效果的快速方法。
]

#definition[广义线性回归][
  广义线性回归的基本形式：
  $
    hat(y_i)=sigma(z_i)=sigma(x_i^T w+w_0)
  $
  其中，$sigma$是单调可微的联系函数(link function), 也称为激活函数。
]

同时也存在多项式回归的情况，多项式回归方程：
$
  hat(y_i)=g(x_i)=w_0+w_11 x_"i1"+w_12 x_"i2"+dots+w_"id" x_"id"+w_21 x^2_"i1"+dots+w_n x_"i1"x_"i2"+dots
$
#remark[
  包含偏置参数，一次项，高次项，交叉项等。这里要额外注意过拟合现象。*将多项式回归中的高次项和交叉项视为新的特征变量，从而将非线性问题转化为线性问题。*
]


通过一组基函数 $Phi(bold(x))$，可以将低维数据映射到高维特征空间，从而实现非线性回归：

$
  g(bold(x)) = sum_(j=0)^M w_j phi_j (bold(x)) = bold(w)^T Phi(bold(x))
$

其中：
- $bold(w) = [w_0, w_1, dots, w_M]^T$ 是待求的 *权重向量*。
- $Phi(bold(x)) = [phi_0(bold(x)), phi_1(bold(x)), dots, phi_M (bold(x))]^T$ 是选定的一组 *基函数向量*。
- 通常令 $phi_0(bold(x)) = 1$ 作为偏置项。
#remark[说人话：利用已有的样本特征生成新的样本,或者叫latent space?]


// 需要一个线性可分的实例,等他发ppt吧
#example[

为了深入理解岭回归的计算过程及其对模型参数的影响，我们构建一个极简的一元线性回归数据集进行手算推导。

*任务定义*：
给定 3 个样本点，建立线性模型 $hat(y) = w_0 + w_1 x$。
设定正则化参数 $lambda = 1$。

*数据集*：
#align(center, table(
  columns: (auto, auto, auto),
  inset: 8pt,
  align: center,
  [*样本 ID*], [*特征 $x$*], [*标签 $y$*],
  [1], [1], [2],
  [2], [2], [3],
  [3], [3], [5]
))
]
为了使用闭式解 $w^*=(X^T X+lambda I)^(-1) X^T y$，我们需要先构建设计矩阵 $X$ 和标签向量 $y$。
注意：为了包含偏置项 $w_0$，我们需要在 $X$ 中增加一列全为 1 的列。

$
  X = mat(
    1, 1;
    1, 2;
    1, 3
  ), quad
  y = mat(
    2;
    3;
    5
  ), quad
  w = vec(w_0, w_1)
$

1. *计算 $X^T X$ (Gram Matrix)*：
$
  X^T X &= mat(1, 1, 1; 1, 2, 3) mat(1, 1; 1, 2; 1, 3) \
  &= mat(
    1+1+1, 1+2+3;
    1+2+3, 1+4+9
  ) = mat(3, 6; 6, 14)
$

2. *计算 $X^T y$*：
$
  X^T y &= mat(1, 1, 1; 1, 2, 3) mat(2; 3; 5) \
  &= vec(2+3+5, 2+6+15) = vec(10, 23)
$

我们设定 $lambda = 1$。此时正则化矩阵为 $lambda I$。

#remark[
  在实际工程中，通常不对偏置项 $w_0$ 进行正则化（即 $I$ 的第一行第一列设为 0），因为偏置表示截距，不影响模型的复杂度和方差。但为了严格匹配上述闭式解公式 $w^*=(X^T X+lambda I)^(-1) X^T y$，我们在本例中对所有参数一视同仁地进行正则化。
]

1. *计算 $X^T X + lambda I$*：
$
  A &= mat(3, 6; 6, 14) + 1 dot mat(1, 0; 0, 1) \
    &= mat(4, 6; 6, 15)
$

2. *计算逆矩阵 $A^(-1)$*：
  对于二阶矩阵 $M = mat(a, b; c, d)$，其逆矩阵为 $M^(-1) = 1/(a d - b c) mat(d, -b; -c, a)$。
  
  - 行列式 $|A| = 4 times 15 - 6 times 6 = 60 - 36 = 24$。
  - 逆矩阵：
  $
    A^(-1) = 1/24 mat(15, -6; -6, 4)
  $

3. *求解最优参数 $w^*$*：
$
  w^* &= A^(-1) (X^T y) \
      &= 1/24 mat(15, -6; -6, 4) vec(10, 23) \
      &= 1/24 vec(15 times 10 + (-6) times 23, (-6) times 10 + 4 times 23) \
      &= 1/24 vec(150 - 138, -60 + 92) \
      &= 1/24 vec(12, 32) = vec(0.5, 1.333)
$

*结果*：岭回归模型方程为 $hat(y) = 0.5 + 1.333 x$。

我们使用求得的岭回归模型计算预测值和误差。

1. *预测值*：
$
  hat(y)_1 &= 0.5 + 1.333(1) = 1.833 \
  hat(y)_2 &= 0.5 + 1.333(2) = 3.166 \
  hat(y)_3 &= 0.5 + 1.333(3) = 4.500
$

2. *残差平方和 (SSE)*：
$
  "SSE" &= (1.833 - 2)^2 + (3.166 - 3)^2 + (4.500 - 5)^2 \
        &= (-0.167)^2 + (0.166)^2 + (-0.5)^2 \
        &approx 0.028 + 0.028 + 0.25 = 0.306
$

3. *总离差平方和 (SST)*：
  $y$ 的均值 $macron(y) = (2+3+5)/3 = 3.333$。
$
  "SST" &= (2 - 3.333)^2 + (3 - 3.333)^2 + (5 - 3.333)^2 \
        &= (-1.333)^2 + (-0.333)^2 + (1.667)^2 \
        &approx 1.777 + 0.111 + 2.778 = 4.666
$

4. *决定系数 $R^2$*：
$
  R^2 = 1 - "SSE"/"SST" = 1 - 0.306/4.666 approx 0.934
$

*评估*：模型的 $R^2$ 为 0.934，说明该岭回归模型能解释约 93.4% 的数据变异，拟合效果良好且参数受到了约束。

我们沿用之前的极简数据集，演示如何用梯度下降法求解 Lasso。

#example[

*数据集回顾*：
$
  X = mat(1, 1; 1, 2; 1, 3), quad y = vec(2, 3, 5)
$

*参数设置*：
- 正则化系数：$lambda = 1$
- 学习率：$eta = 0.1$
]
- *初始化策略*：为了展示 Lasso 的收缩效果，我们*不从 0 开始*，而是从普通最小二乘法 (OLS) 的最优解开始。
  $ w^((0)) = vec(0.33, 1.5) $ (这是我们在上个例子算出的 OLS 解)

*梯度公式*：
$ nabla J(w) = underbrace(-X^T (y - X w), "数据梯度") + underbrace(lambda dot "sign"(w), "正则梯度") $

*迭代第 1 步*：

1. *计算数据梯度*：
   因为我们是从 OLS 最优解 $w^((0))$ 开始的，此时数据拟合误差最小（导数为 0）。
   $ nabla_("data") approx vec(0, 0) $
   (注：实际上是 $X^T X w - X^T y$，OLS 解正好让它为 0)。

2. *计算正则梯度* ($lambda=1$)：
   $ w_0 = 0.33 > 0 arrow.r "sign" = 1 $
   $ w_1 = 1.5 > 0 arrow.r "sign" = 1 $
   $ nabla_("reg") = lambda vec(1, 1) = vec(1, 1) $

3. *更新权重*：
   $ w^((1)) &= w^((0)) - eta (nabla_("data") + nabla_("reg")) \
             &= vec(0.33, 1.5) - 0.1 (vec(0, 0) + vec(1, 1)) \
             &= vec(0.33 - 0.1, 1.5 - 0.1) \
             &= vec(0.23, 1.4) $

   *观察*：Lasso 对两个参数都执行了“减法”，强制它们变小。

*迭代第 2 步*：

现在 $w$ 变了，数据梯度不再是 0 了（因为偏离了 OLS 最优解，MSE 变大了）。

1. *计算预测值与误差*：
   $ hat(y) = X w^((1)) = mat(1, 1; 1, 2; 1, 3) vec(0.23, 1.4) = vec(1.63, 3.03, 4.43) $
   $ e = y - hat(y) = vec(2, 3, 5) - vec(1.63, 3.03, 4.43) = vec(0.37, -0.03, 0.57) $

2. *计算数据梯度* $-X^T e$：
   $ nabla_("data") = - mat(1, 1, 1; 1, 2, 3) vec(0.37, -0.03, 0.57) $
   - 偏置项梯度：$-(0.37 - 0.03 + 0.57) = -0.91$
   - $x$项梯度：$-(1 times 0.37 + 2 times (-0.03) + 3 times 0.57) = -(0.37 - 0.06 + 1.71) = -2.02$
   $ nabla_("data") = vec(-0.91, -2.02) $
   (说明：数据梯度是负的，想要把 $w$ *推大* 回去，以减小误差)。

3. *计算正则梯度* ($w$ 仍大于 0)：
   $ nabla_("reg") = vec(1, 1) $
   (说明：Lasso 依然坚定地想把 $w$ *推小*，方向是正的)。

4. *更新权重*：
   $ w^((2)) &= w^((1)) - eta (nabla_("data") + nabla_("reg")) \
             &= vec(0.23, 1.4) - 0.1 (vec(-0.91, -2.02) + vec(1, 1)) \
             &= vec(0.23, 1.4) - vec(0.009, -0.102) \
             &= vec(0.221, 1.502) $

   *分析*：
   - 对于 $w_1$ (特征权重)：数据梯度想加 0.202，Lasso 想减 0.1。合力是加 0.102。
   - 这说明在 $lambda=1$ 的情况下，特征 $x$ 非常重要，数据梯度的力量超过了惩罚项，权重出现了反弹。
   
   *思考*：如果我们将 $lambda$ 设得很大（比如 10），正则梯度就会变成 10，远超数据梯度，权重就会迅速被“减”到 0。

假设经过多轮迭代，某个不重要的权重 $w_j$ 变得很小，比如 $0.05$，且此时数据梯度也很小（比如 $-0.05$）。

- Lasso 更新：
  $ w_"new" = 0.05 - eta (-0.05 + 1) approx 0.05 - 0.1 = -0.05 $
  (它跨过了 0 点)。
在专门的算法（如*软阈值法* Soft Thresholding 或 坐标下降）中，会包含一步判断：
$ S(w, lambda) = "sign"(w) dot max(|w| - lambda, 0) $
如果 $|w| < lambda$，直接置为 0。