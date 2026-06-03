#import "@local/ysz_tools:0.1.0": *

#show: conf.with(
  title: "shabi_ML",
)

== 未标记样本与半监督学习

=== 背景与现实需求
在传统的监督学习中，我们依赖大量的有标记样本（Labeled Samples）来训练分类器。然而，在许多现实任务中，获取标记是一个需要消耗大量人力、物力和时间的过程。相比之下，未标记样本（Unlabeled Samples）的收集则显得极其容易且成本低廉。

例如，在医学影像分析中，医院可以轻易获得数以万计的医学影像，但是如果希望医学专家对这些影像中的病灶进行逐一精确标识，则是不现实的。

#definition[半监督学习 (Semi-Supervised Learning)][
  让学习器不依赖外界交互，自动地利用未标记样本来提升学习性能的学习方法，即为半监督学习。
]

=== 未标记样本的效用与直观理解
#note[
  #example(title: "未标记样本的撮合效用")[
    假设在二维空间中只有一个正样本 $+$ 和一个负样本 $-$。如果此时输入一个待预测样本 $bold(x)$ 正好位于两者的中点，仅基于监督学习只能随机猜测。

    如果我们能观察到大量灰色的未标记样本（它们呈两个圆环状簇结构分布），根据它们揭示的密度结构，我们可以非常笃定地将中点处的样本判别为正类，因为该样本通过未标记样本的"撮合"与正样本聚在了同一个簇中。
  ]
]

未标记样本虽然没有直接的标记信息，但如果它们与有标记样本是从相同的数据源独立同分布采样而来，则它们所包含的关于数据分布的信息对建立模型将大有裨益。

为了更好地理解未标记样本的利用方式，我们将相关的方法分类并与主动学习进行对比：

1. *主动学习 (Active Learning)*：
   引入外部"标注者"（如专家）进行交互。它首先用少量标记数据训练模型，然后利用某种挑选策略在未标记样本中筛选出"最不确定"或"信息量最大"的样本向标注者查询标记，最后用新标记的样本更新模型。其主动权在算法，旨在用尽量少的标注代价获取尽可能好的性能。

2. *(纯) 半监督学习 (Pure Semi-Supervised Learning)*：
   自动利用未标记样本，不需要与外界交互。它是基于*开放世界假设 (Open World Assumption)*，即假定训练集中的未标记样本并非最终的待预测样本，目标是获得对未知新样本的最优泛化性能。

3. *直推学习 (Transductive Learning)*：
   同样不与外界交互。但它是基于*封闭世界假设 (Closed World Assumption)*，假定学习过程中观察到的未标记样本恰好就是待预测的测试数据，目标是仅在这些特定的未标记样本上取得最优预测效果。

=== 未标记样本利用的核心假设
要利用未标记样本，必然要做一些将数据分布信息与类别标记相联系的假设。最基础的假设为"相似的样本拥有相似的输出"。具体细分为两种：

- *聚类假设 (Cluster Assumption)*：
  假设数据存在簇结构，同一个簇的样本属于同一个类别。这意味着决策边界应当尽量穿过数据稀疏的区域，而不是穿过高密度的簇内部。

- *流形假设 (Manifold Assumption)*：
  假设数据分布在一个流形结构上，邻近的样本拥有相似的输出值。邻近程度常用相似程度来刻画。流形假设可看作聚类假设的推广，但它对输出值没有限制（可以是连续值），适用范围更广，可用于回归等更多学习任务。

---

== 生成式方法 (Generative Methods)

=== 基本假设
#definition[生成式半监督学习][
  直接基于生成式模型的方法。此类方法假设所有数据（有标记和无标记）都是由同一个潜在的生成式模型生成的。
]

通过潜在模型的参数，我们可以将未标记数据与学习目标联系起来。未标记数据的标记可以看作是模型的缺失参数，通常可基于 *EM 算法 (Expectation-Maximization)* 进行极大似然估计求解。

=== 高斯混合模型 (GMM) 的引入
假定样本 $bold(x)$ 的真实类别标记 $y in cal(Y) = {1, 2, dots, N}$。数据样本是基于如下高斯混合模型生成：
$ p(bold(x)) = sum_(i=1)^N alpha_i dot p(bold(x) | mu_i, Sigma_i) $
其中，混合系数 $alpha_i >= 0$ 且 $sum_(i=1)^N alpha_i = 1$；$bold(mu)_i$ 和 $bold(Sigma)_i$ 分别为第 $i$ 个高斯混合成分的均值向量和协方差矩阵。

令 $f(bold(x)) in cal(Y)$ 表示模型对 $bold(x)$ 的预测标记，$Theta in {1, 2, dots, N}$ 表示样本隶属的高斯混合成分。根据最大化后验概率，分类规则定义为：
$
  f(bold(x)) &= arg max_(j in cal(Y)) p(y = j | bold(x)) \
  &= arg max_(j in cal(Y)) sum_(i=1)^N p(y = j | Theta = i, bold(x)) dot p(Theta = i | bold(x)) //\tag{13.2}
$
不失一般性，若假定第 $i$ 个类别对应于第 $i$ 个高斯混合成分，即当且仅当 $i = j$ 时 $p(y = j | Theta = i, bold(x)) = 1$，否则为 $0$。此时上式简化为：
$ f(bold(x)) = arg max_(j in cal(Y)) p(Theta = j | bold(x)) $
其中，样本由第 $i$ 个高斯混合成分生成的后验概率为：
$ p(Theta = i | bold(x)) = (alpha_i dot p(bold(x) | mu_i, Sigma_i)) / (sum_(k=1)^N alpha_k dot p(bold(x) | mu_k, Sigma_k)) $

#note[
  在式 (13.2) 中：
  - 估计类别与混合成分的对应概率 $p(y = j | Theta = i, bold(x))$ 时必须知道标记，故仅能使用有标记数据。
  - 估计混合成分后验概率 $p(Theta = i | bold(x))$ 时不涉及标记，因此可以同时利用有标记和未标记数据。引入海量未标记样本将极大地提高对 $p(Theta = i | bold(x))$ 估计的准确性。
]

=== 联合对数似然估计
给定有标记样本集 $D_l = {(bold(x)_1, y_1), dots, (bold(x)_l, y_l)}$ 和未标记样本集 $D_u = {bold(x)_(l+1), dots, bold(x)_(l+u)}$，$l << u$。假设样本独立同分布，则高斯混合模型参数的联合对数似然为：
$
  LL(D_l union D_u) = sum_((bold(x)_j, y_j) in D_l) ln ( sum_(i=1)^N alpha_i dot p(bold(x)_j | mu_i, Sigma_i) dot p(y_j | Theta = i, bold(x)_j) )\ + sum_(bold(x)_j in D_u) ln ( sum_(i=1)^N alpha_i dot p(bold(x)_j | mu_i, Sigma_i) ) //\tag{13.4}
$
上式第一项为基于有标记数据的*有监督项*，第二项为基于未标记数据的*无监督项*。

=== EM 算法求解步骤
高斯混合模型的参数估计可以通过 EM 算法迭代更新求解：

1. *E 步 (Expectation)*：根据当前模型参数计算未标记样本 $bold(x)_j in D_u$ 属于各高斯混合成分的后验概率：
   $ gamma_(j i) = (alpha_i dot p(bold(x)_j | mu_i, Sigma_i)) / (sum_(k=1)^N alpha_k dot p(bold(x)_j | mu_k, Sigma_k)) $

2. *M 步 (Maximization)*：更新模型参数。令 $l_i$ 表示第 $i$ 类的有标记样本数目（即 $l_i = sum_((bold(x)_j, y_j) in D_l) bb(I)(y_j = i)$），更新公式为：
   $ mu_i = 1 / (sum_(bold(x)_j in D_u) gamma_(j i) + l_i) ( sum_(bold(x)_j in D_u) gamma_(j i) bold(x)_j + sum_( (bold(x)_j, y_j) in D_l and y_j = i ) bold(x)_j ) $

   $ Sigma_i = 1 / (sum_(bold(x)_j in D_u) gamma_(j i) + l_i) ( sum_(bold(x)_j in D_u) gamma_(j i) (bold(x)_j - mu_i)(bold(x)_j - mu_i)^T + sum_( (bold(x)_j, y_j) in D_l and y_j = i ) (bold(x)_j - mu_i)(bold(x)_j - mu_i)^T ) $

   $ alpha_i = 1 / m ( sum_(bold(x)_j in D_u) gamma_(j i) + l_i ) $
   其中 $m = l + u$ 为总样本数。

=== 生成式方法的特点
- *推广*：若将高斯混合模型换成混合专家模型、朴素贝叶斯模型等，即可推导出其他的生成式半监督学习方法。
- *优点*：算法简单易实现，在标记样本极少时由于先验结构强，往往表现优异。
- *局限性*：此类方法极其依赖*模型假设的准确性*。若假设的生成式模型与真实数据分布不吻合，利用未标记数据反而会降低模型的泛化性能。因此，除非拥有充分可靠的领域先验知识，否则在现实任务中很难直接保证假设的精确度。

---

== 半监督支持向量机 (S3VM)

=== TSVM 基本原理
半监督支持向量机中最著名的是 *TSVM (Transductive Support Vector Machine，直推支持向量机)*。与标准 SVM 一样，TSVM 也是针对二分类问题的学习方法。

#note[
  #remark[S3VM 与标准 SVM 决策边界的差异 (低密度间隔划分)][
    - 标准 SVM 仅寻找使有标记样本间隔最大化的超平面，这可能会把超平面直接切在未标记样本密集的区域。
    - TSVM 则同时考虑有标记和未标记样本，它试图穿过未标记样本最稀疏的地方（低密度区域），并让所有样本（包括带有伪标记的未标记样本）的整体间隔最大化。
  ]
]

TSVM 试图考虑对未标记样本进行各种可能的标记指派（Label Assignment），在所有可能的结果中，寻求一个在所有样本上间隔最大化的划分超平面。确定划分超平面后，未标记样本的指派标记即为最终预测结果。

=== TSVM 形式化优化目标
给定 $D_l = {(bold(x)_1, y_1), dots, (bold(x)_l, y_l)}$，其中 $y_i in {-1, +1}$，以及未标记样本集 $D_u = {bold(x)_(l+1), dots, bold(x)_(l+u)}$，$l << u$。TSVM 的目标是尝试为 $D_u$ 给出预测标记 $hat(bold(y)) = (hat(y)_(l+1), dots, hat(y)_(l+u))$（$hat(y)_j in {-1, +1}$）以最小化如下目标函数：
$
  min_(bold(w), b, hat(bold(y)), bold(xi)) & quad 1/2 ||bold(w)||_2^2 + C_l sum_(i=1)^l xi_i + C_u sum_(i=l+1)^(l+u) xi_i \
  "s.t." & quad y_i (bold(w)^T bold(x)_i + b) >= 1 - xi_i, quad i=1, 2, dots, l \
  & quad hat(y)_j (bold(w)^T bold(x)_j + b) >= 1 - xi_j, quad j=l+1, l+2, dots, l+u \
  & quad xi_i >= 0, quad i=1, 2, dots, l+u
$
其中，$(bold(w), b)$ 确定了划分超平面，$bold(xi)$ 为松弛向量；$C_l$ 和 $C_u$ 是用户指定的折中参数，分别用于控制有标记与未标记样本在模型惩罚项中的重要程度。

由于尝试所有可能的 $hat(bold(y))$ 是一个穷举的过程（复杂度达 $2^u$），仅当 $u$ 很小时才可能直接求解。在一般情形下，必须考虑高效的局部搜索近似策略。

=== 类别不平衡问题及其改进
在对未标记样本进行指派及调整的过程中，极易出现指派的类别严重失衡的问题，进而干扰 SVM 的正常训练。

为了减轻类别不平衡所造成的不利影响，可对算法进行改进：将优化目标中的 $C_u sum_(i=l+1)^(l+u) xi_i$ 项拆分为 $C_u^+$ 和 $C_u^-$ 两项，分别对应指派为正例和反例的未标记样本：
$ C_u sum_(i=l+1)^(l+u) xi_i --> C_u^+ sum_(i: hat(y)_i = 1) xi_i + C_u^- sum_(j: hat(y)_j = -1) xi_j $
并在初始化时令：
$ C_u^+ = (u_-) / (u_+) C_u^- $
其中，$u_+$ 与 $u_-$ 分别为基于伪标记指派为正、反例的未标记样本数。

=== TSVM 算法流程与标记置换机制
TSVM 通过局部搜索迭代寻找近似解。

#algorithm("TSVM 算法")[
  *输入*：有标记样本集 $D_l$；未标记样本集 $D_u$；折中参数 $C_l, C_u$。 \
  *输出*：未标记样本的预测结果 $hat(bold(y))$。 \
  *过程*：
  1. 用 $D_l$ 训练一个标准 $"SVM"_l$；
  2. 用 $"SVM"_l$ 对 $D_u$ 中的样本进行预测，得到初始伪标记 $hat(bold(y)) = (hat(y)_(l+1), dots, hat(y)_(l+u))$；
  3. 初始化参数 $C_u << C_l$；
  4. *while* $C_u < C_l$ *do*
  5. #h(1.5em) 基于 $D_l, D_u, hat(bold(y)), C_l, C_u$ 求解式 (13.9)，得到 $(bold(w), b), bold(xi)$；
  6. #h(1.5em) *while* $exists i, j$ 满足 $(hat(y)_i hat(y)_j < 0) and (xi_i > 0) and (xi_j > 0) and (xi_i + xi_j > 2)$ *do*
  7. #h(3em) $hat(y)_i = -hat(y)_i$；
  8. #h(3em) $hat(y)_j = -hat(y)_j$；
  9. #h(3em) 基于 $D_l, D_u, hat(bold(y)), C_l, C_u$ 重新求解式 (13.9)，得到新参数 $(bold(w), b), bold(xi)$；
  10. #h(1.5em) *end while*
  11. #h(1.5em) $C_u = min(2 C_u, C_l)$；
  12. *end while*
]

#note[
  #remark[标记置换置信条件分析 (第 6-10 行)][
    如果在某轮求解中，存在一对未标记样本 $bold(x)_i$ 和 $bold(x)_j$：
    1. 它们被指派了不同的伪标记 ($hat(y)_i hat(y)_j < 0$)；
    2. 且它们的松弛变量满足 $xi_i > 0$ 和 $xi_j > 0$；
    3. 并且它们的松弛变量之和 $xi_i + xi_j > 2$。

    这说明它们在当前划分面下都位于错误的一侧，且错误非常严重。如果将它们的标记对调重新训练，可以严格保证式 (13.9) 的目标函数值*单调下降*。
  ]
]

尽管如此，搜索每一对可能出错的伪标记样本并进行调整，计算开销仍然极大。因此，半监督支持向量机的研究重点在于如何设计更加高效的大规模优化求解策略。

---

== 图半监督学习 (Graph-Based Semi-Supervised Learning)

=== 基本思想与图映射关系
图半监督学习方法将数据集映射为一个图 $G = (V, E)$：
- 数据集中每个样本对应于图中的一个结点 $v in V$。
- 若两个样本之间的相似度很高，则对应的结点之间存在一条边，边的强度（权值）正比于样本之间的相似度。
- 有标记样本对应的结点已被染色（有初始标签），未标记样本对应的结点尚未染色。半监督学习的过程就是颜色在图上顺着边不断扩散、传播的动态过程。

=== 亲和矩阵与图拉普拉斯矩阵
给定数据集，我们首先构建亲和矩阵 $bold(W)$。通常基于高斯函数定义为：
$
  W_(i j) = cases(
    exp(- (||bold(x)_i - bold(x)_j||_2^2) / (2 sigma^2)) &"if" i != j,
    0 &"otherwise"
  ) //\tag{13.11}
$
其中 $sigma > 0$ 是用户指定的高斯函数带宽参数。度矩阵 $bold(D) = "diag"(d_1, dots, d_(l+u))$ 是一个对角矩阵，其对角线元素为 $d_i = sum_(j=1)^(l+u) W_(i j)$。

=== 二分类标记传播闭式解
假定我们希望学得一个实值函数 $f : V -> RR$，对应的分类规则为 $y_i = "sign"(f(bold(x)_i))$。直观上，相似的样本应具有相似的标记，故可定义关于 $f$ 的能量函数：
$
  E(f) &= 1/2 sum_(i=1)^(l+u) sum_(j=1)^(l+u) W_(i j) (f(bold(x)_i) - f(bold(x)_j))^2 \
  &= bold(f)^T (bold(D) - bold(W)) bold(f) = bold(f)^T bold(L) bold(f) //\tag{13.12}
$
其中 $bold(L) = bold(D) - bold(W)$ 为拉普拉斯矩阵。将函数 $bold(f)$ 划分为有标记部分 $bold(f)_l$ 和未标记部分 $bold(f)_u$。以第 $l$ 行与第 $l$ 列为界，采用分块矩阵表示方式：
$
  bold(W) = mat(bold(W)_(l l), bold(W)_(l u); bold(W)_(u l), bold(W)_(u u)), quad
  bold(D) = mat(bold(D)_(l l), bold(0)_(l u); bold(0)_(u l), bold(D)_(u u))
$
能量函数 $E(f)$ 可重写为：
$
  E(f) = (bold(f)_l^T quad bold(f)_u^T) (mat(bold(D)_(l l), bold(0)_(l u); bold(0)_(u l), bold(D)_(u u)) - mat(bold(W)_(l l), bold(W)_(l u); bold(W)_(u l), bold(W)_(u u))) mat(bold(f)_l; bold(f)_u)
$
最小化能量的函数在有标记样本上必须满足 $bold(f)_l = bold(y)_l$，为了求在未标记样本上的输出，我们对 $bold(f)_u$ 求偏导并令其为 $0$：
$
  (partial E(f)) / (partial bold(f)_u) = 0 \
  => (bold(D)_(u u) - bold(W)_(u u)) bold(f)_u - bold(W)_(u l) bold(f)_l = 0 \
  => bold(f)_u = (bold(D)_(u u) - bold(W)_(u u))^(-1) bold(W)_(u l) bold(f)_l //\tag{13.15}
$
令标记传播矩阵 $bold(P) = bold(D)^(-1) bold(W)$，其对应分块为 $bold(P)_(u u) = bold(D)_(u u)^(-1) bold(W)_(u u)$，$bold(P)_(u l) = bold(D)_(u u)^(-1) bold(W)_(u l)$。上式可进一步重写为：
$ bold(f)_u = (bold(I) - bold(P)_(u u))^(-1) bold(P)_(u l) bold(f)_l $

=== 多分类标记传播与规范拉普拉斯矩阵
在多分类任务中，定义非负标记矩阵 $bold(F) in RR^((l+u) times |cal(Y)|)$。其第 $i$ 行向量对应于示例 $bold(x)_i$ 的类别后验概率。

首先将 $bold(F)$ 初始化为 $bold(Y)$，其中：
$ bold(Y)_(i j) = cases(1 &"if" (1 <= i <= l) and (y_i = j), 0 &"otherwise") $
其前 $l$ 行为已知有标记样本的 One-hot 编码，剩余行为 $0$。基于度矩阵构建标记传播矩阵 $bold(S) = bold(D)^(-1/2) bold(W) bold(D)^(-1/2)$。算法采用如下迭代计算式：
$ bold(F)(t+1) = alpha bold(S) bold(F)(t) + (1 - alpha) bold(Y) $
其中，$alpha in (0, 1)$ 用于控制标记传播项与初始化项的折中比重。由于 $bold(S)$ 的特征值绝对值不大于 $1$，当 $t -> infinity$ 时，迭代必收敛。收敛解为：
$ bold(F)^\* = (1 - alpha)(bold(I) - alpha bold(S))^(-1) bold(Y) $

#note[
  #remark[正则化框架等价性][
    上述迭代算法的收敛解，在数学上等价于如下正则化框架的最优解：
    $ min_(bold(F)) 1/2 ( sum_(i,j=1)^(l+u) W_(i j) || 1 / sqrt(d_i) bold(F)_i - 1 / sqrt(d_j) bold(F)_j ||_2^2 + mu sum_(i=1)^l ||bold(F)_i - bold(Y)_i||_2^2 ) $
    其中第一项为流形约束（强迫近邻样本具有相似的归一化表示），第二项为拟合约束（强迫有标记样本的预测值逼近真实标签），$mu = (1 - alpha) / alpha$ 为正则化参数。
  ]
]

=== 图半监督学习的局限性
1. *存储和计算开销巨大*：对于拥有 $m$ 个样本的数据集，亲和矩阵的规模达 $O(m^2)$。当数据规模较大时，矩阵逆运算和存储都难以直接承受。
2. *外部样本预测困难 (Out-of-Sample Issue)*：构图时无法预知未出现的测试样本。当接收到新样本时，要么必须将其加入原数据集重新构建整个图并重新运行标记传播，要么必须额外引入一个预测机制（如归纳学习器）来逼近传播结果。

---

== 基于分歧的方法 (Disagreement-Based Methods)

=== 协同训练与多视图数据
基于分歧的方法使用多个学习器，而学习器之间的分歧（Disagreement）对未标记数据的利用至关重要。

其代表是 协同训练 (Co-training) 算法。协同训练最初是针对多视图（Multi-view）数据设计的，是多视图学习（Multi-view learning）的里程碑。

#note[
  #example(title: "电影数据的多视图性质")[
    在现实生活中，一个数据对象往往拥有多个属性集，每个属性集构成一个视图（View）：
    - 图像画面特征集（视图 1）
    - 声音频域特征集（视图 2）
    - 字幕文本特征集（视图 3）
    这些视图从不同侧面描述了同一部电影，它们是相通且互补的。
  ]
]

在多视图数据中，每个样本可以表示为 $(⟨ bold(x)^1, bold(x)^2 ⟩, y)$，其中 $bold(x)^1$ 和 $bold(x)^2$ 分别是样本在两个不同视图下的属性向量。

=== 协同训练算法流程
协同训练的基本思路是：在每个视图上训练一个独立的分类器，然后让各自的分类器去挑选置信度最高的未标记样本，将其预测结果赋予伪标记，并提供给另一个视图下的分类器作为新增的有标记样本进行训练。

#algorithm("协同训练 (Co-training) 算法")[
  *输入*：有视图标记样本集 $D_l$；未标记样本集 $D_u$；缓冲池大小 $s$；每轮挑选正、反例数 $p, n$；基学习算法 $cal(L)$；训练轮数 $T$。 \
  *输出*：视图分类器 $h_1, h_2$。 \
  *过程*：
  1. 从 $D_u$ 中随机抽取 $s$ 个样本构成缓冲池 $D_s$，$D_u = D_u ∖ D_s$；
  2. 根据 $D_l$ 分离出各视图对应的标记数据集 $D_l^1, D_l^2$；
  3. *for* $t = 1, 2, dots, T$ *do*
  4. #h(1.5em) $h_1 = cal(L)(D_l^1)$；
  5. #h(1.5em) $h_2 = cal(L)(D_l^2)$；
  6. #h(1.5em) 计算 $h_1$ 在 $D_s$ 上的预测置信度，选出 $p$ 个正例和 $n$ 个反例，组成带伪标记的数据：
     #h(3em) $tilde(D)_p^2 = {(bold(x)_i^2, +1) | bold(x)_i^1 in D_p}$，$tilde(D)_n^2 = {(bold(x)_i^2, -1) | bold(x)_i^1 in D_n}$；
  7. #h(1.5em) 计算 $h_2$ 在 $D_s$ 上的预测置信度，选出 $p$ 个正例和 $n$ 个反例，组成带伪标记的数据：
     #h(3em) $tilde(D)_p^1 = {(bold(x)_i^1, +1) | bold(x)_i^2 in D_p}$，$tilde(D)_n^1 = {(bold(x)_i^1, -1) | bold(x)_i^2 in D_n}$；
  8. #h(1.5em) 从缓冲池中移除这些被挑选的样本：$D_s = D_s ∖ (D_p union D_n)$；
  9. #h(1.5em) *if* $h_1$ 和 $h_2$ 的参数在本轮迭代中均未发生改变 *then* break；
  10. #h(1.5em) *else*
  11. #h(3em) $D_l^1 = D_l^1 union (tilde(D)_p^1 union tilde(D)_n^1)$；
  12. #h(3em) $D_l^2 = D_l^2 union (tilde(D)_p^2 union tilde(D)_n^2)$；
  13. #h(3em) 从 $D_u$ 中随机抽取 $2p + 2n$ 个样本补充到缓冲池 $D_s$ 中；
  14. #h(1.5em) *end if*
  15. *end for*
]

理论证明，如果两个视图满足充分性（即每个视图单独就足以让分类器收敛）和条件独立性（给定类别标记时，两个视图的属性条件独立），则利用未标记样本通过协同训练可以将弱分类器的泛化性能提升到任意高。

虽然在现实任务中"条件独立性"几乎无法完美满足，但协同训练在实际应用中依然能带来显著的性能提升。

=== 单视图协同训练与分歧特征
对于只有单个视图的数据，依然可以通过基于分歧的方法进行半监督学习。此时我们必须通过人为引入差异来构建"分歧"：
- 使用不同的基学习器算法（如 SVM 与 决策树 结合）；
- 采用不同的样本子集采样（如 Bagging 的自助法采样）；
- 使用差异明显的模型参数设置。

只要多个弱学习器之间保持显著的分歧，它们就能通过相互提供伪标记样本的形式来提高整体的泛化性能。该方法较少受到强模型假设的制约，简单有效，因而得到了广泛的应用。

---

== 半监督聚类 (Semi-Supervised Clustering)

=== 监督信息的形式
聚类通常是无监督学习，但在很多现实任务中，我们可以获得一些额外的监督信息。通过引入监督信息，我们可以显著约束和指导聚类方向。

监督信息通常有两种基本形式：

- *必连（Must-link）与勿连（Cannot-link）约束*：
  必连约束 $cal(M)$ 规定两个样本必须被划分到同一个簇，勿连约束 $cal(C)$ 规定两个样本不能被划分到同一个簇。

- *少量有标记样本*：
  直接提供少量已知类别（或目标簇标签）的样本。

=== 约束 $k$ 均值 (Constrained k-means) 算法
约束 $k$ 均值算法利用第一类监督信息（即约束集合 $cal(M)$ 和 $cal(C)$）。它在常规 $k$-means 指派样本时，强迫每一次划分都符合已知的必连和勿连约束。

#algorithm("约束 k-means 算法")[
  *输入*：样本集 $D = {bold(x)_1, dots, bold(x)_m}$；必连约束集 $cal(M)$；勿连约束集 $cal(C)$；聚类簇数 $k$。 \
  *输出*：簇划分 ${C_1, C_2, dots, C_k}$。 \
  *过程*：
  1. 从 $D$ 中随机选取 $k$ 个样本作为初始均值向量 ${bold(mu)_1, dots, bold(mu)_k}$；
  2. *repeat*
  3. #h(1.5em) 令 $C_j = emptyset (1 <= j <= k)$；
  4. #h(1.5em) *for* $i = 1, 2, dots, m$ *do*
  5. #h(3em) 计算样本 $bold(x)_i$ 到各均值向量 $bold(mu)_j (1 <= j <= k)$ 的距离：$d_(i j) = ||bold(x)_i - bold(mu)_j||_2$；
  6. #h(3em) 初始化候选簇索引集合 $cal(K) = {1, 2, dots, k}$；
  7. #h(3em) is_merged = false；
  8. #h(3em) *while* not is_merged *do*
  9. #h(4.5em) 从候选集合 $cal(K)$ 中找出距离最近的簇索引：$r = arg min_(j in cal(K)) d_(i j)$；
  10. #h(4.5em) 检查如果将 $bold(x)_i$ 划入簇 $C_r$，是否会违背 $cal(M)$ 和 $cal(C)$ 的约束；
  11. #h(4.5em) *if* 没有违背约束 *then*
  12. #h(6em) $C_r = C_r union {bold(x)_i}$；
  13. #h(6em) is_merged = true；
  14. #h(4.5em) *else*
  15. #h(6em) $cal(K) = cal(K) ∖ {r}$；
  16. #h(6em) *if* $cal(K) = emptyset$ *then* 算法中止并报错退出；
  17. #h(4.5em) *end if*
  18. #h(3em) *end while*
  19. #h(1.5em) *end for*
  20. #h(1.5em) *for* $j = 1, 2, dots, k$ *do*
  21. #h(3em) 更新均值中心：$bold(mu)_j = 1/|C_j| sum_(bold(x) in C_j) bold(x)$；
  22. #h(1.5em) *end for*
  23. *until* 均值向量不再更新
]

#note[
  #remark[算例分析][
    以西瓜数据集 4.0 (30 个样本) 为例，在限定必连集 $cal(M)$ 和勿连集 $cal(C)$ 条件下，设置 $k = 3$，经历 5 轮迭代收敛，给出三个簇的最终划分结果。
  ]
]

=== 约束种子 $k$ 均值 (Constrained Seed k-means) 算法
当我们拥有少量有标记样本时，可以直接将它们作为种子 (Seeds)。约束种子 $k$-means 将这些种子用于初始化聚类中心，并在随后的迭代中，固定种子样本的簇隶属关系，仅允许未标记样本改变归属。

#algorithm("约束种子 k-means 算法")[
  *输入*：样本集 $D = {bold(x)_1, dots, bold(x)_m}$；少量有标记样本集合 $S = union.big_(j=1)^k S_j$（$S_j$ 为第 $j$ 簇的种子样本集）；聚类簇数 $k$。 \
  *输出*：簇划分 ${C_1, C_2, dots, C_k}$。 \
  *过程*：
  1. *for* $j = 1, 2, dots, k$ *do*
  2. #h(1.5em) 根据种子计算初始中心：$bold(mu)_j = 1/|S_j| sum_(bold(x) in S_j) bold(x)$；
  3. *end for*
  4. *repeat*
  5. #h(1.5em) 令 $C_j = S_j (1 <= j <= k)$；
  6. #h(1.5em) *for* 各个未标记样本 $bold(x)_i in D ∖ S$ *do*
  7. #h(3em) 计算样本 $bold(x)_i$ 到各均值向量 $bold(mu)_j (1 <= j <= k)$ 的距离：$d_(i j) = ||bold(x)_i - bold(mu)_j||_2$；
  8. #h(3em) 找出距离最近的簇索引：$r = arg min_(j in {1, dots, k}) d_(i j)$；
  9. #h(3em) 将样本划入相应的簇：$C_r = C_r union {bold(x)_i}$；
  10. #h(1.5em) *end for*
  11. #h(1.5em) *for* $j = 1, 2, dots, k$ *do*
  12. #h(3em) 重新计算均值中心：$bold(mu)_j = 1/|C_j| sum_(bold(x) in C_j) bold(x)$；
  13. #h(1.5em) *end for*
  14. *until* 均值向量不再更新
]

有标记样本在这个算法中扮演了"引路人"的硬性锚点角色，它强制均值中心贴近物理类别分布，使无监督的聚类结构能够自底而上地与我们希望的真实类别语义保持高度契合。
