#import "../notes.typ":*
#show :notes

== 奇异值分解

奇异值分解（singular valuedecomposition，SVD）是一种矩阵因子分解方法，是线性代数的概念，但在机器学习中被广泛使用，成为其重要工具。

任意一个$m times n$矩阵，都可以表示为三个矩阵的乘积（因子分解）形式，分别是$m$阶正交矩阵、由降序排列的非负的对角线元素组成的$m times n$矩形对角矩阵和$n$阶正交矩阵，称为该矩阵的奇异值分解。矩阵的奇异值分解一定存在，但不唯一。


奇异值分解可以看作是矩阵数据压缩的一种方法，即用因子分解的方式近似地表示原始矩阵，这种近似是在平方损失意义下的最优近似。

=== 奇异值分解的定义与性质

#definition[奇异值分解][
  矩阵的奇异值分解是指将一个非零的$m times n$实矩阵$A$, $A in R^(m times n)$, 表示为以下3个实矩阵乘积形式的运算(这里我们不讨论复数矩阵上的情况)，即进行矩阵的因子分解：
  $
    A=U Sigma V^(-1)
  $
  其中，$U$是$m$阶正交矩阵，$V$是$n$阶正交矩阵，$Sigma$是由降序排列的非负的对角线元素组成的$m times n$矩阵对角矩阵(rectangular diagonal matrix), 满足
  $
    &U U^T=I\
    &V V^T =I\
    &Sigma="diag"(sigma_1,sigma_2,dots,sigma_p)\
    &sigma_1 gt.eq sigma_2 gt.eq dots gt.eq sigma_p gt.eq 0\
    &p=min(m,n)
  $
]

#remark[
  正交矩阵（Orthogonal Matrix）是一个满足以下条件的方阵 $Q$：$Q^T Q = Q Q^T = I$其中 $I$ 是单位矩阵。

  $
    Q^{-1} = Q^T
  $
  矩阵的每一行（或每一列）都是单位向量，且两两互相垂直（正交）。
  - 单位性：向量长度为 1（$abs(v) = 1$）。
  - 正交性：任意两个不同向量的点积为 0（$v_i dot v_j = 0, i eq.not j$）。

  用正交矩阵乘以一个向量 $x$（即线性变换 $Q x$），相当于在空间中进行旋转（Rotation）或镜面反射（Reflection）。
  - 长度不变：$abs(Q x) = abs(x)$。
  - 角度不变：向量之间的相对夹角保持不变。
]

$U Sigma V^T$称为矩阵$A$的奇异值分解，$sigma_i$称为矩阵$A$的奇异值，$U$的列向量称为左奇异向量，$V$的列向量称为右奇异向量。

- 右奇异向量 ($V$)：矩阵 $V$ 的列向量是 $A^T A$ 的特征向量。
- 左奇异向量 ($U$)：矩阵 $U$ 的列向量是 $A A^T$ 的特征向量。
- 奇异值 ($Sigma$)：矩阵 $Sigma$ 对角线上的非零奇异值 $sigma_i$ 是 $A^T A$（或 $AA^T$）非零特征值 $lambda_i$ 的平方根。
$
  sigma_i=sqrt(lambda_i)
$
#remark[
  注意奇异值分解不要求矩阵是方阵，事实上矩阵的奇异值分解可以看作是方阵的对角化的推广。

  但在 SVD 中，$Sigma$ 的维度必须完全跟随原始矩阵 $A$ 的维度。原始矩阵 $A$ 是 $5 times 4$。所以 $Sigma$ 也必须是 $5 times 4$。它的“对角线”是指从左上角 $(1,1)$ 开始，向右下延伸的那些位置 $(i, i)$。如果行多列少，下面多出来的行全是 0。如果列多行少，右边多出来的列全是 0。
]

#remark[
  矩阵的奇异值分解不是唯一的。
]

#theorem[奇异值分解基本定理][
  若$A$为一个$m times n$实矩阵，$A in R^(m times n)$, 则$A$的奇异值分解存在：
  $
    A=U Sigma V^T
  $
  其中，$U$是$m$阶正交矩阵，$V$是$n$阶正交矩阵，$Sigma$是$m times n$矩形对角矩阵，其对角线元素非负，且按降序排列。
]

#proof[
  证明是构造性的，对给定的矩阵 $A$, 构造出其奇异值分解的各个矩阵。为了方便，不妨假设 $m gt.eq n$, 如果 $m < n$ 证明仍然成立。证明分为 3 部分。

  *1. 确定 $V$ 和 $Sigma$*

  矩阵 $A$ 是 $m times n$ 实矩阵，则矩阵 $A^T A$ 是 $n$ 阶实对称矩阵。因而 $A^T A$ 的特征值都是实数，并且存在一个 $n$ 阶正交实矩阵 $V$ 实现 $A^T A$ 的对角化，使得 $V^T (A^T A) V = Lambda$ 成立，其中 $Lambda$ 是 $n$ 阶对角矩阵，其对角线元素由 $A^T A$ 的特征值组成。而且，$A^T A$ 的特征值都是非负的。事实上，令 $lambda$ 是 $A^T A$ 的一个特征值，$x$ 是对应的特征向量，则
  $
    norm( A x ) ^ ( 2 ) = x ^ ( T ) A ^ ( T ) A x = lambda x ^ ( T ) x = lambda norm( x ) ^ ( 2 )
  $
  于是
  $
    lambda = ( norm( A x ) ) ^ ( 2 )  / ( norm( bold( upright( x ) ) ) ^ ( 2 ) ) gt.eq.slant 0
  $

  设 $A^T A$ 的特征值为 $lambda_1, lambda_2, dots, lambda_n$。将它们按降序排列：
  $ lambda_1 gt.eq lambda_2 gt.eq dots gt.eq lambda_n gt.eq 0 $

  设前 $r$ 个特征值为正数（$r$ 为矩阵 $A$ 的秩），其余为 0：
  $ lambda_1 gt.eq dots gt.eq lambda_r > 0, quad lambda_(r+1) = dots = lambda_n = 0 $

  取 $A^T A$ 对应于上述特征值的 $n$ 个单位正交特征向量 $v_1, v_2, dots, v_n$。构造 $n$ 阶矩阵 $V$：
  $ V = [v_1, v_2, dots, v_n] $
  由于 $\{v_i\}$ 是标准正交系，故 $V$ 是 $n$ 阶正交矩阵。根据对角化理论，它满足：
  $ V^T (A^T A) V = Lambda = op("diag")(lambda_1, dots, lambda_n) $

  定义 $A$ 的奇异值为 $sigma_i = sqrt(lambda_i) (i=1, dots, n)$。构造 $m times n$ 的矩形对角矩阵 $Sigma$：
  $
    Sigma = mat(
      sigma_1, , , ;
      , dots.down, , ;
      , , sigma_r, ;
      , , , 0_((m-r) times (n-r))
    ) = mat(D, 0; 0, 0)
  $
  其中 $D = op("diag")(sigma_1, dots, sigma_r)$ 是 $r$ 阶对角矩阵。

  *2. 确定 $U$*

  我们需要构造一个 $m$ 阶正交矩阵 $U$。设 $A^T A$ 对应的单位特征向量为 $v_1, v_2, dots, v_n$，它们构成了正交矩阵 $V = [v_1, dots, v_n]$ 的列。

  *第一步：构造 $U$ 的前 $r$ 列* ($r$ 是矩阵 $A$ 的秩)\
  对于 $i = 1, dots, r$，令 $ u_i = 1/sigma_i A v_i $。我们要证明这些 $u_i$ 是标准正交的。计算内积：
  $
    u_i^T u_j = (1/sigma_i A v_i)^T (1/sigma_j A v_j) = 1/(sigma_i sigma_j) v_i^T A^T A v_j
  $
  由于 $v_j$ 是特征向量，$A^T A v_j = lambda_j v_j = sigma_j^2 v_j$，代入得：
  $
    u_i^T u_j = 1/(sigma_i sigma_j) v_i^T (sigma_j^2 v_j) = sigma_j/sigma_i v_i^T v_j
  $
  利用 $V$ 的正交性（$v_i^T v_j = delta_(i j)$）：
  - 若 $i eq.not j$，则 $u_i^T u_j = 0$。
  - 若 $i = j$，则 $u_i^T u_i = 1$。
  因此 $\{u_1, dots, u_r\}$ 是标准正交系。

  *第二步：扩张 $U$ 的后 $m-r$ 列* \
  将 $\{u_1, dots, u_r\}$ 扩充为 $RR^m$ 的一组标准正交基 $\{u_1, dots, u_m\}$，构造矩阵：
  $ U = [u_1 space dots space u_r quad u_(r+1) space dots space u_m] $

  #remark[
    前 $r$ 个是算出来的（由数据决定），后 $m-r$ 个是凑出来的（为了满足数学形式要求，在剩下的空间里随便找一组正交基填满）。
  ]

  *3. 验证分解结果*

  我们要证明 $A = U Sigma V^T$，这等价于证明 $A V = U Sigma$。我们逐列比较等式两边。

  *对于前 $r$ 列 ($1 lt.eq j lt.eq r$)：* \
  右边 $(U Sigma)$ 的第 $j$ 列为 $U (sigma_j e_j) = sigma_j u_j$。
  代入 $u_j$ 的定义，得 $sigma_j (1/sigma_j A v_j) = A v_j$，即为左边 $(A V)$ 的第 $j$ 列。

  *对于后 $n-r$ 列 ($r+1 lt.eq j lt.eq n$)：* \
  右边 $Sigma$ 对应列全为 0，故 $(U Sigma)$ 第 $j$ 列为 $bold(0)$。
  左边需证明 $A v_j = bold(0)$。计算其模长平方：
  $
    norm(A v_j)^2 = v_j^T A^T A v_j = v_j^T (lambda_j v_j) = 0
  $
  故 $A v_j = bold(0)$。两边相等。

  综上，$A V = U Sigma$ 成立。又因 $V$ 是正交矩阵，右乘 $V^T$ 得 $A = U Sigma V^T$。
]

+ *唯一性*：
   矩阵 $A$ 的奇异值 $sigma_1, sigma_2, dots, sigma_n$ 是*唯一*的。但是，正交矩阵 $U$ 和 $V$ *不是唯一*的。奇异值 $Sigma$ 是唯一的

+ *秩 (Rank)*：
   矩阵 $A$ 的秩等于非零奇异值的个数 $r$（即矩阵 $Sigma$ 的秩）。这也意味着 $A$ 和 $Sigma$ 具有相同的秩。

+ *$A^T$ 的值域 (行空间) $R(A^T)$*：
   由 $A$ 的前 $r$ 个右奇异向量 $v_1, dots, v_r$ 构成一组标准正交基。

+ *$A$ 的零空间 (Null Space) $N(A)$*：
   由 $A$ 的后 $n-r$ 个右奇异向量 $v_(r+1), dots, v_n$ 构成一组标准正交基。

+ *$A$ 的值域 (列空间) $R(A)$*：
   由 $A$ 的前 $r$ 个左奇异向量 $u_1, dots, u_r$ 构成一组标准正交基。

+ *$A^T$ 的零空间 (左零空间) $N(A^T)$*：
   由 $A$ 的后 $m-r$ 个左奇异向量 $u_(r+1), dots, u_m$ 构成一组标准正交基。

=== 奇异值分解的计算

给定$m times n$矩阵$A$, 下面对其进行矩阵奇异值分解。

*1. 求$A^T A$的特征值和特征向量*

计算对称矩阵$W=A^T A$, 再求解特征方程
$
  (W-lambda I)x=0
$
得到特征值$lambda_i$, 并将特征值由大到小排序:
$
  lambda _ ( 1 ) gt.eq.slant lambda _ ( 2 ) gt.eq.slant dots.h.c gt.eq.slant lambda _ ( n ) gt.eq.slant 0
$
将特征值$lambda_i (i=1,2,dots,n)$带入特征方程求得对应的特征向量。（特征值的和是矩阵的迹，特征值的积是矩阵对应行列式的值）

*2. 求$n$阶正交矩阵$V$*

将特征向量单位化，得到单位特征向量$v_1,v_2,dots,v_n$, 构成$n$阶正交矩阵$V$.
$
  V = mat( delim: "["  ,  v _ ( 1 ) , v _ ( 2 ) , dots.h.c , v _ ( n ) )
$

*3. 求$m times n$对角矩阵$Sigma$*

计算$A$的奇异值:
$
  sigma_i =sqrt(lambda_i), quad i=1,2,dots,n
$
构造$m times n$矩形对角矩阵$Sigma$，主对角线元素是奇异值，其余元素是0.(超出部分补0)
$
  Sigma = "diag"(sigma_1,sigma_2,dots,sigma_n)
$

*4. 求$m$阶正交矩阵$U$*

对 $A$ 的前 $r$ 个正奇异值，令
$
  u_j = 1/sigma_j A v_j, quad j=1, 2, dots, r
$
得到：
$
  U_1 = [u_1 space u_2 space dots space u_r]
$

求 $A^T$ 的零空间的一组标准正交基 $\{u_(r+1), u_(r+2), dots, u_m\}$，令
$
  U_2 = [u_(r+1) space u_(r+2) space dots space u_m]
$
并令
$
  U = [U_1 space U_2]
$

*5. 得到奇异值分解*
$
  A=U Sigma V^T
$

其实在具体应用中，可以通过求$A^T A$的特征值进行，但不直接计算$A^T A$. 按照这个思路还会有更多有效的算法，这里不再展开。

#example[
  给定矩阵 $A$, 对其进行奇异值分解：
$
  A = mat(
    1, 1;
    2, 2;
    0, 0
  )
$
]

*1. 计算 $A^T A$ 的特征值和特征向量（确定 $V$ 和 $Sigma$）*

首先计算 $A^T A$：
$
  A^T A &= mat(1, 2, 0; 1, 2, 0) mat(1, 1; 2, 2; 0, 0) \
        &= mat(5, 5; 5, 5)
$

计算特征多项式以求解特征值：
$
  |lambda I - A^T A| = det(mat(lambda-5, -5; -5, lambda-5)) = (lambda-5)^2 - 25 = lambda^2 - 10lambda = 0
$
解得特征值为 $lambda_1 = 10, lambda_2 = 0$。

根据 $sigma_i = sqrt(lambda_i)$，得到奇异值：
$
  sigma_1 = sqrt(10), quad sigma_2 = 0
$
由于 $A$ 是 $3 times 2$ 矩阵，故 $Sigma$ 也是 $3 times 2$ 矩阵：
$
  Sigma = mat(
    sqrt(10), 0;
    0, 0;
    0, 0
  )
$

接下来求解 $A^T A$ 的特征向量（即 $V$ 的列向量）：

对于 $lambda_1 = 10$，解方程 $(10 I - A^T A)x = 0$：
$
  mat(5, -5; -5, 5) mat(x_1; x_2) = 0 arrow.double x_1 = x_2
$
取特征向量 $xi_1 = [1, 1]^T$，单位化后得到 $v_1 = [1/sqrt(2), 1/sqrt(2)]^T$。

对于 $lambda_2 = 0$，解方程 $(0 I - A^T A)x = 0$：
$
  mat(-5, -5; -5, -5) mat(x_1; x_2) = 0 arrow.double x_1 = -x_2
$
取特征向量 $xi_2 = [1, -1]^T$，单位化后得到 $v_2 = [1/sqrt(2), -1/sqrt(2)]^T$。

从而得到 $2$ 阶正交矩阵 $V$ 及其转置：
$
  V = mat(1/sqrt(2), 1/sqrt(2); 1/sqrt(2), -1/sqrt(2)), quad V^T = mat(1/sqrt(2), 1/sqrt(2); 1/sqrt(2), -1/sqrt(2))
$

*2. 确定 $U$*

$U$ 是一个 $3$ 阶正交矩阵。
对于非零奇异值 $sigma_1 = sqrt(10)$，利用公式 $u_1 = 1/sigma_1 A v_1$ 计算第一列：
$
  u_1 &= 1/sqrt(10) mat(1, 1; 2, 2; 0, 0) mat(1/sqrt(2); 1/sqrt(2)) \
      &= 1/sqrt(20) mat(2; 4; 0) = 1/(2 sqrt(5)) mat(2; 4; 0) = mat(1/sqrt(5); 2/sqrt(5); 0)
$

接下来需要将 $\{u_1\}$ 扩充为 $RR^3$ 的一组标准正交基。我们需要找到与 $u_1$ 正交的单位向量 $u_2, u_3$。
即求解 $A^T$ 的零空间（$A^T x = 0$）：
$
  mat(1, 2, 0; 1, 2, 0) mat(x_1; x_2; x_3) = 0 arrow.double x_1 + 2x_2 = 0
$
这是一组平面方程。我们可以选取两个线性无关的解：
1. 令 $x_2 = 1, x_3 = 0 arrow.double x_1 = -2$。解为 $[-2, 1, 0]^T$。单位化后得 $u_2 = [-2/sqrt(5), 1/sqrt(5), 0]^T$。
2. 令 $x_2 = 0, x_3 = 1 arrow.double x_1 = 0$。解为 $[0, 0, 1]^T$。单位化后得 $u_3 = [0, 0, 1]^T$。

验证正交性：$u_1 dot u_2 = 0$, $u_1 dot u_3 = 0$, $u_2 dot u_3 = 0$。
于是得到 $U$：
$
  U = mat(
    1/sqrt(5), -2/sqrt(5), 0;
    2/sqrt(5), 1/sqrt(5), 0;
    0, 0, 1
  )
$

*3. 结果*

矩阵 $A$ 的奇异值分解 $A = U Sigma V^T$ 为：
$
  A = mat(
    1/sqrt(5), -2/sqrt(5), 0;
    2/sqrt(5), 1/sqrt(5), 0;
    0, 0, 1
  )
  mat(
    sqrt(10), 0;
    0, 0;
    0, 0
  )
  mat(
    1/sqrt(2), 1/sqrt(2);
    1/sqrt(2), -1/sqrt(2)
  )
$

// TODO: 未完待续