#import "../../notes.typ" :*
#show:notes

== EM算法

EM算法是一种迭代算法，1977年由Dempster等人总结提出，用于含有隐变量（hidden variable）的概率模型参数的极大似然估计或极大后验概率估计。*EM算法的每次迭代由两步组成：E步，求期望（expectation）；M步，求极大（maximization）。所以这一算法称为期望极大算法(expectation maximization algorithm），简称EM算法*。本章首先叙述EM算法，然后讨论EM算法的收敛性：作为EM算法的应用，介绍高斯混合模型的学习。

=== EM算法的引入
当模型含有隐变量时，就不能简单地使用这些估计方法。EM算法就是含有隐变量的概率模型参数的极大似然估计法或极大后验概率估计法。我们仅讨论极大似然估计，极大后验概率估计与其类似。

#algorithm[EM算法][
*输入*：观测变量数据 $Y$，隐变量数据 $Z$，联合分布 $P(Y, Z|theta)$，条件分布 $P(Z|Y, theta)$。

*输出*：模型参数 $theta$。

(1) 选择参数的初值 $theta^((0))$，开始迭代。

(2) E 步：记 $theta^((i))$ 为第 $i$ 次迭代参数 $theta$ 的估计值，在第 $i+1$ 次迭代的 E 步，计算

$ Q(theta, theta^((i))) &= E_Z [log P(Y, Z|theta)|Y, theta^((i))] \
&= sum_Z log P(Y, Z|theta) P(Z|Y, theta^((i))) $

这里，$P(Z|Y, theta^((i)))$ 是在给定观测数据 $Y$ 和当前的参数估计 $theta^((i))$ 下隐变量数据 $Z$ 的条件概率分布。

(3) M 步：求使 $Q(theta, theta^((i)))$ 极大化的 $theta$，确定第 $i+1$ 次迭代的参数的估计值 $theta^((i+1))$。

$ theta^((i+1)) = "arg" max_theta Q(theta, theta^((i))) $

(4) 重复第 2 步和第 3 步，直到收敛。
]

#definition[Q函数][
  完全数据的对数似然函数 $log P(Y, Z|theta)$ 关于在给定观测数据 $Y$ 和当前参数 $theta^((i))$ 下对未观测数据 $Z$ 的条件概率分布 $P(Z|Y, theta^((i)))$ 的期望称为 $Q$ 函数，即

$ Q(theta, theta^((i))) = E_Z [log P(Y, Z|theta) | Y, theta^((i))] $
]

(1) 步骤 (1) 中参数的初值可以任意选择，但需注意 EM 算法对初值是敏感的。

(2) 步骤 (2) 中 E 步求 $Q(theta, theta^((i)))$。$Q$ 函数式中 $Z$ 是未观测数据，$Y$ 是观测数据。注意，$Q(theta, theta^((i)))$ 的第 1 个变元表示要极大的参数，第 2 个变元表示参数的当前估计值。每次迭代实际在求 $Q$ 函数及其极大。

(3) 步骤 (3) 中 M 步求 $Q(theta, theta^((i)))$ 的极大化，得到 $theta^((i+1))$，完成一次迭代 $theta^((i)) -> theta^((i+1))$。后面将证明每次迭代使似然函数增大或达到局部极值。

(4) 步骤 (4) 给出停止迭代的条件，一般是对较小的正数 $epsilon_1, epsilon_2$，若满足
$ norm(theta^((i+1)) - theta^((i))) < epsilon_1 quad "或" quad norm(Q(theta^((i+1)), theta^((i))) - Q(theta^((i)), theta^((i)))) < epsilon_2 $
则停止迭代。


#example[双硬币实验][
  假设有两枚硬币 A 和 B，它们的材质不均匀：
  - 参数 $theta$：$theta_A$ 是硬币 A 正面朝上的概率，$theta_B$ 是硬币 B 正面朝上的概率。这两个是我们要求的未知参数。
  - 观测数据 $Y$：我们进行了 5 组实验，每组投掷 10 次。
    - 结果如下（H=正面，T=反面）：5H, 5T; 9H, 1T; 8H, 2T; 4H, 6T; 7H, 3T; 
  - 隐变量 $Z$：每组实验具体是用硬币 A 还是硬币 B 投的，我们不知道。
]

*第一阶段：场景设定与初始化*

首先，我们随机初始化一组参数作为起点：
$ theta_A^((0)) = 0.6, quad theta_B^((0)) = 0.5 $

#v(1em)
// 第二阶段：E步
*第二阶段：E 步——计算“责任/权重”*

我们的目标是在当前参数猜测下，计算每组数据属于 A 或 B 的概率。以第 1 组数据（5H, 5T）为例：

1. 计算似然 (Likelihood)：
如果是硬币 A (0.6) 产生的概率：
$ P(y_1 | theta_A) = 0.6^5 times (1-0.6)^5 approx 0.000796 $

如果是硬币 B (0.5) 产生的概率：
$ P(y_1 | theta_B) = 0.5^5 times (1-0.5)^5 approx 0.000976 $

2. 归一化 (计算权重 $mu$)：
计算 A 对第 1 组数据的“责任”权重 $mu_(1,A)$，即第 1 组数据由 A 产生的后验概率：
$ mu_(1,A) = P(y_1 | theta_A) / (P(y_1 | theta_A) + P(y_1 | theta_B)) = 0.000796 / (0.000796 + 0.000976) approx 0.45 $

这意味着：第 1 组数据有 45% 的概率是由 A 产生的。这就是我们在 $Q$ 函数中需要的“期望权重”。

#v(1em)
// 第三阶段：Q 函数
*第三阶段：构建 Q 函数——数学核心*

$Q$ 函数的本质是“期望的对数似然”，其通用形式为：
$ Q = sum [ "weight" times ln("likelihood") ] $

针对第 1 组数据，关于参数 $theta_A$ 的部分可以构建为：
$ Q_"part"(theta_A) = underbrace(0.45, "E 步算的权重") times underbrace([ 5 ln theta_A + 5 ln (1 - theta_A) ], "如果是 A 产生的对数似然") $

这一步的物理意义在于：我们不再因为“不知道是谁投的”而束手无策，而是利用 0.45 这个权重，强制把第 1 组数据的似然函数“分”给了 A。

#v(1em)
// 第四阶段：M步推导
*第四阶段：M 步原理——求导寻找极大值*

这是一个典型的高数求极值问题。我们需要找到一个新的 $theta_A$，让 $Q$ 函数的值最大。手段是对 $theta_A$ 求导，并令导数为 0。

1. 单组导数：
对上面的 $Q_"part"$ 关于 $theta_A$ 求导：
$ (partial Q) / (partial theta_A) = 0.45 times ( 5 / theta_A - 5 / (1 - theta_A) ) $

2. 总导数 (所有数据)：
如果有 $N$ 组数据，我们将它们全部加起来。设第 $j$ 组有 $H_j$ 个正面，$T_j$ 个反面，权重是 $mu_(j,A)$：
$ (partial Q_"total") / (partial theta_A) = sum_(j=1)^(N) mu_(j,A) ( H_j / theta_A - T_j / (1 - theta_A) ) = 0 $

#v(1em)
// 第五阶段：解方程
*第五阶段：解方程——导出“直觉公式”*

我们来解上面那个导数为 0 的方程，这一步展示了为什么代码中可以使用简单的加权平均。

首先移项：
$ 1 / theta_A sum (mu_(j,A) H_j) = 1 / (1 - theta_A) sum (mu_(j,A) T_j) $

交叉相乘：
$ (1 - theta_A) sum (mu_(j,A) H_j) = theta_A sum (mu_(j,A) T_j) $

注意 $H_j + T_j = N_j$ (总投掷次数)，合并同类项得到解析解：
$ theta_A = (sum mu_(j,A) H_j) / (sum mu_(j,A) N_j) $

结论：经过复杂的求导，最终留下的公式含义非常简单：
$ theta_A = ("A 的权重" times "正面次数") / ("A 的权重" times "总次数") $

这就是为什么我们在写代码时不需要写求导过程，直接写加权平均即可的原因。

#v(1em)
// 第六阶段：M步计算
*第六阶段：M 步计算——代入数值*

将具体的观测数据代入刚才推导出的公式。

计算 $theta_A^((1))$：
分子 (加权正面) 为 $0.45 times 5 + 0.80 times 9 + dots approx 21.3$。
分母 (加权总数) 为 $0.45 times 10 + 0.80 times 10 + dots = 29.8$。
$ theta_A^((1)) = 21.3 / 29.8 approx 0.71 $

计算 $theta_B^((1))$：
同理计算 B 的部分：
$ theta_B^((1)) = 11.7 / 20.2 approx 0.58 $

#v(1em)
// 第七阶段：总结
*第七阶段：迭代与总结*

我们得到了新的参数 $theta_A=0.71, theta_B=0.58$。接下来重复 E 步和 M 步，直到参数不再变化。

- *Q 函数的作用*：它是一个严谨的数学容器，容纳了“不确定性”（权重）和“似然性”（对数概率）。
- *求偏导的作用*：它是寻找最优解的引擎。它证明了“按比例切分数据并求均值”这种做法，在数学上是能让似然函数最大化的最优解，而不仅仅是一个直觉上的猜测。


#remark[
EM算法与初值的选择有关，不同的初值可能得到不同的参数估计值。
]


#example[
  *三硬币模型的数学心脏：Q 函数与求导推导*

在三硬币模型中，我们有观测数据 $y$（$N$ 次投掷结果），隐变量 $z$（标识来自硬币 B 还是 C），以及参数 $theta = {pi, p, q}$。
]

*1. 写出完全数据的对数似然*

首先，我们需要写出如果知道隐变量 $z$ 时的概率公式。
假设 $z_j = 1$ 代表第 $j$ 次选择了硬币 B，$z_j = 0$ 代表选择了硬币 C。

- 如果来自 B ($z_j=1$)：$P(y_j, z_j=1) = pi p^(y_j) (1-p)^(1-y_j)$
- 如果来自 C ($z_j=0$)：$P(y_j, z_j=0) = (1-pi) q^(y_j) (1-q)^(1-y_j)$

#v(1em)
*2. 写出 Q 函数的具体形式*

$Q$ 函数是“对数似然的期望”。在 E 步中，我们已经算出了第 $j$ 次投掷属于硬币 B 的概率（权重）$mu_j$。
属于硬币 C 的概率自然就是 $1 - mu_j$。

$Q(theta) = sum_(j=1)^N [ underbrace(mu_j, "B的权重") times ln(pi p^(y_j) (1-p)^(1-y_j)) + underbrace((1-mu_j), "C的权重") times ln((1-pi) q^(y_j) (1-q)^(1-y_j)) ] $

我们将 $\ln$ 展开，把参数分离出来，方便求导：

$ Q(theta) = sum_(j=1)^N [ mu_j (ln pi + y_j ln p + (1-y_j) ln(1-p)) + (1-mu_j) (ln(1-pi) + y_j ln q + (1-y_j) ln(1-q)) ] $

#v(1em)
*3. M 步推导之一：对 $pi$ 求导*

我们要找到最优的 $pi$（老板选 B 的概率）。只保留 $Q$ 函数中含 $pi$ 的项：
$ Q_pi = sum_(j=1)^N [ mu_j ln pi + (1-mu_j) ln(1-pi) ] $

对 $pi$ 求偏导并令其为 0：
$ (partial Q) / (partial pi) = sum_(j=1)^N [ mu_j / pi - (1-mu_j) / (1-pi) ] = 0 $

移项解方程：
$ 1/pi sum mu_j = 1/(1-pi) sum (1-mu_j) $
$ (1-pi) sum mu_j = pi (N - sum mu_j) $
$ sum mu_j - pi sum mu_j = N pi - pi sum mu_j $
$ sum mu_j = N pi $

*结果：*
$ pi = 1/N sum_(j=1)^N mu_j $
(物理意义：老板选 B 的概率 = 所有数据属于 B 的概率的平均值)

#v(1em)
*4. M 步推导之二：对 $p$ 求导*

我们要找到最优的 $p$（硬币 B 的正面率）。只保留 $Q$ 函数中含 $p$ 的项：
$ Q_p = sum_(j=1)^N mu_j [ y_j ln p + (1-y_j) ln(1-p) ] $

对 $p$ 求偏导并令其为 0：
$ (partial Q) / (partial p) = sum_(j=1)^N mu_j [ y_j / p - (1-y_j) / (1-p) ] = 0 $

移项解方程：
$ 1/p sum (mu_j y_j) = 1/(1-p) sum (mu_j (1-y_j)) $

交叉相乘并利用 $y_j + (1-y_j) = 1$：
$ (1-p) sum mu_j y_j = p sum (mu_j - mu_j y_j) $
$ sum mu_j y_j - p sum mu_j y_j = p sum mu_j - p sum mu_j y_j $
$ sum mu_j y_j = p sum mu_j $

*结果：*
$ p = (sum mu_j y_j) / (sum mu_j) $
(物理意义：硬币 B 的正面率 = B 分到的正面期望 / B 分到的总次数期望)

*注*：对 $q$ 的推导完全同理，只需将 $mu_j$ 换成 $(1-mu_j)$。

为什么EM算法能近似实现对观测数据的极大似然估计呢？下面通过近似求解观测数据的对数似然函数的极大化问题来导出EM算法，由此可以清楚地看出EM算法的作用。

我们面对一个含有隐变量的概率模型，目标是极大化观测数据（不完全数据）$Y$ 关于参数 $theta$ 的对数似然函数，即极大化

$ L(theta) = log P(Y|theta) = log sum_Z P(Y, Z|theta) = log (sum_Z P(Y|Z, theta) P(Z|theta)) $

注意到这一极大化的主要困难是上式中有未观测数据并有包含和（或积分）的对数。

事实上，EM 算法是通过迭代逐步近似极大化 $L(theta)$ 的。假设在第 $i$ 次迭代后 $theta$ 的估计值是 $theta^((i))$。我们希望新估计值 $theta$ 能使 $L(theta)$ 增加，即 $L(theta) > L(theta^((i)))$，并逐步达到极大值。为此，考虑两者的差：

$ L(theta) - L(theta^((i))) = log (sum_Z P(Y|Z, theta) P(Z|theta)) - log P(Y|theta^((i))) $

利用 Jensen 不等式得到其下界：

$ L(theta) - L(theta^((i))) &= log (sum_Z P(Z|Y, theta^((i))) frac(P(Y|Z, theta)P(Z|theta), P(Z|Y, theta^((i))))) - log P(Y|theta^((i))) \
&>= sum_Z P(Z|Y, theta^((i))) log frac(P(Y|Z, theta)P(Z|theta), P(Z|Y, theta^((i)))) - log P(Y|theta^((i))) \
&= sum_Z P(Z|Y, theta^((i))) log frac(P(Y|Z, theta)P(Z|theta), P(Z|Y, theta^((i))) P(Y|theta^((i)))) $

令

$ B(theta, theta^((i))) hat(=) L(theta^((i))) + sum_Z P(Z|Y, theta^((i))) log frac(P(Y|Z, theta)P(Z|theta), P(Z|Y, theta^((i))) P(Y|theta^((i)))) $

则

$ L(theta) >= B(theta, theta^((i))) $

即函数 $B(theta, theta^((i)))$ 是 $L(theta)$ 的一个下界，而且由前述定义可知：

$ L(theta^((i))) = B(theta^((i)), theta^((i))) $

因此，任何可以使 $B(theta, theta^((i)))$ 增大的 $theta$ 也可以使 $L(theta)$ 增大。为了使 $L(theta)$ 有尽可能大的增长，选择 $theta^((i+1))$ 使 $B(theta, theta^((i)))$ 达到极大，即

$ theta^((i+1)) = arg max_theta B(theta, theta^((i))) $

现在求 $theta^((i+1))$ 的表达式。省去对 $theta$ 的极大化而言是常数的项，由上述各式有

$ theta^((i+1)) &= arg max_theta (L(theta^((i))) + sum_Z P(Z|Y, theta^((i))) log frac(P(Y|Z, theta)P(Z|theta), P(Z|Y, theta^((i))) P(Y|theta^((i))))) \
&= arg max_theta (sum_Z P(Z|Y, theta^((i))) log (P(Y|Z, theta)P(Z|theta))) \
&= arg max_theta (sum_Z P(Z|Y, theta^((i))) log P(Y, Z|theta)) \
&= arg max_theta Q(theta, theta^((i))) $

上式等价于 EM 算法的一次迭代，即求 $Q$ 函数及其极大化。EM 算法是通过不断求解下界的极大化逼近求解对数似然函数极大化的算法。


#remark[
  EM算法不保证找到全局最优值。
]

=== EM算法的收敛性

#theorem[
  设 $P(Y|theta)$ 为观测数据的似然函数，$theta^((i)) (i=1,2, dots)$ 为 EM 算法得到的参数估计序列，$P(Y|theta^((i))) (i=1,2, dots)$ 为对应的似然函数序列，则 $P(Y|theta^((i)))$ 是单调递增的，即
$ P(Y|theta^((i+1))) >= P(Y|theta^((i))) $
]

#proof[
  由于
$ P(Y|theta) = (P(Y, Z|theta)) / (P(Z|Y, theta)) $
取对数有
$ log P(Y|theta) = log P(Y, Z|theta) - log P(Z|Y, theta) $
根据 $Q$ 函数的定义：
$ Q(theta, theta^((i))) = sum_Z log P(Y, Z|theta) P(Z|Y, theta^((i))) $
令
$ H(theta, theta^((i))) = sum_Z log P(Z|Y, theta) P(Z|Y, theta^((i))) $
于是对数似然函数可以写成
$ log P(Y|theta) = Q(theta, theta^((i))) - H(theta, theta^((i))) $
在上式中分别取 $theta$ 为 $theta^((i))$ 和 $theta^((i+1))$ 并相减，有
$ log P(Y|theta^((i+1))) - log P(Y|theta^((i))) \
  = [Q(theta^((i+1)), theta^((i))) - Q(theta^((i)), theta^((i)))] - [H(theta^((i+1)), theta^((i))) - H(theta^((i)), theta^((i)))] $
为证明似然函数单调递增，只需证明上式右端是非负的。对于上式右端的第 1 项，由于 $theta^((i+1))$ 使 $Q(theta, theta^((i)))$ 达到极大，所以有
$ Q(theta^((i+1)), theta^((i))) - Q(theta^((i)), theta^((i))) >= 0 $
对于第 2 项，可得：
$ H(theta^((i+1)), theta^((i))) - H(theta^((i)), theta^((i))) &= sum_Z (log (P(Z|Y, theta^((i+1)))) / (P(Z|Y, theta^((i))))) P(Z|Y, theta^((i))) \
&<= log (sum_Z (P(Z|Y, theta^((i+1)))) / (P(Z|Y, theta^((i)))) P(Z|Y, theta^((i)))) \
&= log (sum_Z P(Z|Y, theta^((i+1)))) = 0 $
这里的不等号由 Jensen 不等式得到。

由此可知对数似然函数差值公式的右端是非负的。
]

#theorem[
  设 $L(theta) = log P(Y|theta)$ 为观测数据的对数似然函数，$theta^((i)) (i=1,2, dots)$ 为 EM 算法得到的参数估计序列，$L(theta^((i))) (i=1,2, dots)$ 为对应的对数似然函数序列。
(1) 如果 $P(Y|theta)$ 有上界，则 $L(theta^((i))) = log P(Y|theta^((i)))$ 收敛到某一值 $L^*$；
(2) 在函数 $Q(theta, theta')$ 与 $L(theta)$ 满足一定条件的情况下，由 EM 算法得到的参数估计序列 $theta^((i))$ 的收敛值 $theta^*$ 是 $L(theta)$ 的稳定点。
]

#proof[
  (1) 由 $L(theta) = log P(Y|theta^((i)))$ 的单调性及 $P(Y|theta)$ 的有界性得到。
(2) 证明从略。
]

=== 高斯混合模型中的应用
高斯混合模型（GMM）是一个典型的无监督学习模型，一个 “软”聚类 模型，本质上是一个 概率密度估计模型。而K-Means是结果为圆形或球形的硬聚类。

EM算法的一个重要应用是高斯混合模型的参数估计。高斯混合模型应用广泛，在许多情况下，EM算法是学习高斯混合模型（Gaussian mixture model)的有效方法。

#remark[
  GMM 是一个描述数据的数学模型，但因为其公式中包含“和的对数”，导致无法直接计算参数；EM 算法通过引入“隐变量”和迭代机制，绕过了直接计算的数学难点，成为求解 GMM 参数最主流的方法。
]

#definition[高斯混合模型][
高斯混合模型是指具有如下形式的概率分布模型：

$ P(y|theta) = sum_(k=1)^K alpha_k phi.alt(y|theta_k) $

其中，$alpha_k$ 是系数，$alpha_k >= 0$，$sum_(k=1)^K alpha_k = 1$；$phi.alt(y|theta_k)$ 是高斯分布密度，$theta_k = (mu_k, sigma_k^2)$，

$ phi(y|theta_k) = 1 / (sqrt(2 pi) sigma_k) exp [ - (y - mu_k)^2 / (2 sigma_k^2) ] $

称为第 $k$ 个分模型。
]

一般混合模型可以由任意概率分布密度代替$phi.alt (y|theta_k)$中的高斯分布密度，我们只介绍最常用的高斯混合模型。

GMM 的世界观是这样的：每一次生成数据，只允许一个高斯分量（某个骰子筒）单独工作。公式里的那个加号 $sum$，并不是说数据点本身是由几个模型拼起来的，而是根据全概率公式，我们在计算观测概率时，必须把所有可能的来源都考虑进去。

假设观测数据 $y_1, y_2, dots, y_N$ 由高斯混合模型生成：

$ P(y|theta) = sum_(k=1)^K alpha_k phi.alt(y|theta_k) $

其中，参数 $theta = (alpha_1, dots, alpha_K; theta_1, dots, theta_K)$。我们利用 EM 算法来估计该模型的参数 $theta$。

*1. 明确隐变量，写出完全数据的对数似然函数*

可以设想观测数据 $y_j$ ($j=1, 2, dots, N$) 的产生过程如下：首先根据概率 $alpha_k$ 选择第 $k$ 个高斯分布分模型 $phi.alt(y|theta_k)$，然后由第 $k$ 个分模型的概率分布生成观测数据 $y_j$。

此时，观测数据 $y_j$ 是已知的，而反映观测数据 $y_j$ 来自第 $k$ 个分模型的数据是未知的。我们用隐变量 $gamma_(j k)$ 来表示这一未知关系，其定义如下：

$ gamma_(j k) = cases(
  1\, & "第" j "个观测来自第" k "个分模型",
  0\, & "否则"
) $

其中 $j=1, 2, dots, N$，$k=1, 2, dots, K$，且 $gamma_(j k)$ 是 0-1 随机变量。有了观测数据 $y_j$ 及未观测数据 $gamma_(j k)$，完全数据可以表示为：

$ (y_j, gamma_(j 1), gamma_(j 2), dots, gamma_(j K)), quad j=1, 2, dots, N $

完全数据的似然函数为：

$ P(y, gamma | theta) &= product_(j=1)^N P(y_j, gamma_(j 1), gamma_(j 2), dots, gamma_(j K) | theta) \
&= product_(k=1)^K product_(j=1)^N [alpha_k phi.alt(y_j | theta_k)]^(gamma_(j k)) \
&= product_(k=1)^K alpha_k^(n_k) product_(j=1)^N [phi.alt(y_j | theta_k)]^(gamma_(j k)) \
&= product_(k=1)^K alpha_k^(n_k) product_(j=1)^N { 1 / sqrt(2 pi sigma_k^2) exp [ - (y_j - mu_k)^2 / (2 sigma_k^2) ] }^(gamma_(j k)) $

式中，$n_k = sum_(j=1)^N gamma_(j k)$，且 $sum_(k=1)^K n_k = N$。于是，完全数据的对数似然函数可写为：

$ log P(y, gamma | theta) = sum_(k=1)^K { n_k log alpha_k + sum_(j=1)^N gamma_(j k) [ log (1 / sqrt(2 pi)) - log sigma_k - 1 / (2 sigma_k^2) (y_j - mu_k)^2 ] } $

*2. EM 算法的 E 步：确定 Q 函数*

Q 函数定义为完全数据对数似然函数在给定观测数据 $y$ 和当前参数估计 $theta^((i))$ 下关于未观测数据 $gamma$ 的期望：

$ Q(theta, theta^((i))) &= E[log P(y, gamma | theta) | y, theta^((i))] \
&= E [ sum_(k=1)^K { n_k log alpha_k + sum_(j=1)^N gamma_(j k) [ log (1 / sqrt(2 pi)) - log sigma_k - 1 / (2 sigma_k^2) (y_j - mu_k)^2 ] } ] \
&= sum_(k=1)^K { sum_(j=1)^N (E gamma_(j k)) log alpha_k + sum_(j=1)^N (E gamma_(j k)) [ log (1 / sqrt(2 pi)) - log sigma_k - 1 / (2 sigma_k^2) (y_j - mu_k)^2 ] } $

这里需要计算 $E(gamma_(j k) | y, theta)$，记为 $hat(gamma)_(j k)$。

$ hat(gamma)_(j k) &= E(gamma_(j k) | y, theta) = P(gamma_(j k) = 1 | y, theta) \
&= P(gamma_(j k) = 1, y_j | theta) / (sum_(k=1)^K P(gamma_(j k) = 1, y_j | theta)) \
&= (P(y_j | gamma_(j k) = 1, theta) P(gamma_(j k) = 1 | theta)) / (sum_(k=1)^K P(y_j | gamma_(j k) = 1, theta) P(gamma_(j k) = 1 | theta)) \
&= (alpha_k phi(y_j | theta_k)) / (sum_(k=1)^K alpha_k phi(y_j | theta_k)) $

其中 $j=1, 2, dots, N$，$k=1, 2, dots, K$。$hat(gamma)_(j k)$ 是在当前模型参数下第 $j$ 个观测数据来自第 $k$ 个分模型的概率，称为分模型 $k$ 对观测数据 $y_j$ 的*响应度*。

将 $hat(gamma)_(j k) = E gamma_(j k)$ 及 $n_k = sum_(j=1)^N E gamma_(j k)$ 代入 Q 函数表达式，即得：

$ Q(theta, theta^((i))) = sum_(k=1)^K { n_k log alpha_k + sum_(j=1)^N hat(gamma)_(j k) [ log (1 / sqrt(2 pi)) - log sigma_k - 1 / (2 sigma_k^2) (y_j - mu_k)^2 ] } $

*3. 确定 EM 算法的 M 步*

迭代的 M 步是求函数 $Q(theta, theta^((i)))$ 对 $theta$ 的极大值，即求新一轮迭代的模型参数：

$ theta^((i+1)) = arg max_theta Q(theta, theta^((i))) $

我们用 $hat(mu)_k$, $hat(sigma)_k^2$ 及 $hat(alpha)_k$ ($k=1, 2, dots, K$) 表示 $theta^((i+1))$ 的各参数。求 $hat(mu)_k$, $hat(sigma)_k^2$ 只需将 Q 函数分别对 $mu_k$, $sigma_k^2$ 求偏导数并令其为 0；求 $hat(alpha)_k$ 是在约束条件 $sum_(k=1)^K alpha_k = 1$ 下求偏导数并令其为 0 得到的。

计算结果如下：

$ hat(mu)_k = (sum_(j=1)^N hat(gamma)_(j k) y_j) / (sum_(j=1)^N hat(gamma)_(j k)), quad k=1, 2, dots, K $

$ hat(sigma)_k^2 = (sum_(j=1)^N hat(gamma)_(j k) (y_j - mu_k)^2) / (sum_(j=1)^N hat(gamma)_(j k)), quad k=1, 2, dots, K $

$ hat(alpha)_k = n_k / N = (sum_(j=1)^N hat(gamma)_(j k)) / N, quad k=1, 2, dots, K $

重复以上计算，直到对数似然函数值不再有明显的变化为止。


#algorithm[高斯混合模型参数估计的 EM 算法][
*输入*：观测数据 $y_1, y_2, dots, y_N$，高斯混合模型。

*输出*：高斯混合模型参数。

1.  取参数的初始值开始迭代。
2.  E 步：依据当前模型参数，计算分模型 $k$ 对观测数据 $y_j$ 的响应度：
    $ hat(gamma)_(j k) = (alpha_k phi.alt(y_j | theta_k)) / (sum_(k=1)^K alpha_k phi.alt(y_j | theta_k)), quad j=1, 2, dots, N; quad k=1, 2, dots, K $
3.  M 步：计算新一轮迭代的模型参数：
    $ hat(mu)_k &= (sum_(j=1)^N hat(gamma)_(j k) y_j) / (sum_(j=1)^N hat(gamma)_(j k)) \
    hat(sigma)_k^2 &= (sum_(j=1)^N hat(gamma)_(j k) (y_j - mu_k)^2) / (sum_(j=1)^N hat(gamma)_(j k)) \
    hat(alpha)_k &= (sum_(j=1)^N hat(gamma)_(j k)) / N $
4.  重复第 2 步和第 3 步，直到收敛。
]