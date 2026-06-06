#import "@local/ysz_tools:0.1.0": *

= 半监督学习
== 未标记样本与半监督学习

=== 背景与现实需求
在传统的监督学习中，我们依赖大量的有标记样本（Labeled Samples）来训练分类器。然而，在许多现实任务中，获取标记是一个需要消耗大量人力、物力和时间的过程。相比之下，未标记样本（Unlabeled Samples）的收集则显得极其容易且成本低廉。

例如，在医学影像分析中，医院可以轻易获得数以万计的医学影像，但是如果希望医学专家对这些影像中的病灶进行逐一精确标识，则是不现实的。

#definition[半监督学习 (Semi-Supervised Learning)][
  让学习器不依赖外界交互，自动地利用未标记样本来提升学习性能的学习方法，即为半监督学习。
]

=== 未标记样本的效用与直观理解#note[
  #example(title: "未标记样本的撮合效用")[
    假设在二维空间中只有一个正样本 $+$ 和一个负样本 $-$。如果此时输入一个待预测样本 $bold(x)$ 正好位于两者的中点，仅基于监督学习只能随机猜测。

    #image("/assets/image-17.png")

    如果我们能观察到大量灰色的未标记样本，根据它们揭示的密度结构，我们可以非常笃定地将中点处的样本判别为正类。
  ]
]

未标记样本虽然没有直接的标记信息，但如果它们与有标记样本是从相同的数据源独立同分布采样而来，则它们所包含的关于数据分布的信息对建立模型将大有裨益。

为了更好地理解未标记样本的利用方式，我们将相关的方法分类并与主动学习进行对比：

1. *主动学习 (Active Learning)*：
   引入外部"标注者"（如专家）进行交互。它首先用少量标记数据训练模型，然后利用某种挑选策略在未标记样本中筛选出"最不确定"或"信息量最大"的样本，向标注者查询标记，最后用新标记的样本更新模型。其主动权在算法，旨在用尽量少的标注代价获取尽可能好的性能。

2. *(纯) 半监督学习 (Pure Semi-Supervised Learning)*：
   自动利用未标记样本，不需要与外界交互。它是基于*开放世界假设 (Open World Assumption)*，即假定训练集中的未标记样本并非最终的待预测样本，目标是获得对未知新样本的最优泛化性能。

3. *直推学习 (Transductive Learning)*：
   同样不与外界交互。但它是基于*封闭世界假设 (Closed World Assumption)*，假定学习过程中观察到的未标记样本恰好就是待预测的测试数据，目标是仅在这些特定的未标记样本上取得最优预测效果。
#cetz.canvas({
  // 1. 显式调用 set-style，避免使用 import cetz.draw: * 覆盖原生函数
  cetz.draw.set-style(
    tree: (
      direction: "right",
      grow: 4.5,     // 层级之间的横向距离
      spread: 2.0,   // 同层节点之间的纵向距离
      stroke: rgb("7f8c8d") + 1pt
    )
  )

  // 2. 此时这里的 rect 已经是 Typst 原生的正牌 rect 容器了
  let node-style = (
    fill: rgb("f0f4f8"), 
    stroke: rgb("4a90e2") + 1.5pt, 
    inset: 8pt, 
    radius: 4pt
  )
  
  let leaf-style = (
    fill: rgb("eef9f0"), 
    stroke: rgb("2ecc71") + 1.5pt, 
    inset: 8pt, 
    radius: 4pt
  )

  // 3. 渲染渲染树结构
  cetz.tree.tree(
    (
      rect(..node-style)[*是否引入外部“专家”？*],
      // 上分支
      rect(..leaf-style)[
        #align(center)[
          *【主动学习】* \
          #text(size: 0.85em, fill: gray.darken(30%))[_(花钱请专家针对性标注)_]
        ]
      ],
      // 下分支
      (
        rect(..node-style)[*否*],
        rect(..leaf-style)[
          #align(center)[
            *【纯 半监督学习】* \
            #text(size: 0.85em, fill: gray.darken(30%))[_(假设测试集是任意未知的样本)_]
          ]
        ],
        rect(..leaf-style)[
          #align(center)[
            *【直推学习】* \
            #text(size: 0.85em, fill: gray.darken(30%))[_(假设测试集就是手头这批未标记数据)_]
          ]
        ],
      )
    )
  )
})
=== 未标记样本利用的核心假设
要利用未标记样本，必然要做一些将数据分布信息与类别标记相联系的假设。最基础的假设为"相似的样本拥有相似的输出"。具体细分为两种：

- *聚类假设 (Cluster Assumption)*：
  假设数据存在簇结构，同一个簇的样本属于同一个类别。这意味着决策边界应当尽量穿过数据稀疏的区域，而不是穿过高密度的簇内部。

- *流形假设 (Manifold Assumption)*：
  假设数据分布在一个流形结构上，邻近的样本拥有相似的输出值。邻近程度常用相似程度来刻画。流形假设可看作聚类假设的推广，但它对输出值没有限制（可以是连续值），适用范围更广，可用于回归等更多学习任务。


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
  - 估计类别与混合成分的对应概率 $p(y = j | Theta = i, bold(x))$ 时*必须知道标记*，故仅能使用有标记数据。
  - 估计混合成分后验概率 $p(Theta = i | bold(x))$ 时*不涉及标记*，因此可以同时利用有标记和未标记数据。引入海量未标记样本将极大地提高对 $p(Theta = i | bold(x))$ 估计的准确性。
]

=== 联合对数似然估计
给定有标记样本集 $D_l = {(bold(x)_1, y_1), dots, (bold(x)_l, y_l)}$ 和未标记样本集 $D_u = {bold(x)_(l+1), dots, bold(x)_(l+u)}$，$l << u$。假设样本独立同分布，则高斯混合模型参数的联合对数似然为：
$
  LL(D_l union D_u) = sum_((bold(x)_j, y_j) in D_l) ln ( sum_(i=1)^N alpha_i dot p(bold(x)_j | mu_i, Sigma_i) dot p(y_j | Theta = i, bold(x)_j) )\ + sum_(bold(x)_j in D_u) ln ( sum_(i=1)^N alpha_i dot p(bold(x)_j | mu_i, Sigma_i) )
$#note[
上式第一项为基于有标记数据的*有监督项*：模型不仅要解释为什么这里有个点，还要解释为什么这个点是个猫。要算的是联合概率 #mi(`p(\mathbf{x}_j, y_j)`)。
- #mi(`\alpha_i \cdot p(\mathbf{x}_j \mid \mathbf{mu}_i, \mathbf{\Sigma}_i)`)：这和前面一样，是第 #mi(`i`) 个高斯成分产生出这个点 #mi(`\mathbf{x}_j`) 的概率。
- #mi(`p(y_j \mid \Theta = i, \mathbf{x}_j)`)：这是一个修正因子。“如果这个点确实是由第 #mi(`i`) 个高斯成分产生的，那么这个成分恰好是 #mi(`y_j`)（猫）的概率是多少？”

第二项为基于未标记数据的*无监督项*。

- 由第 #mi(`i`) 个高斯生成的概率是 #mi(`p(\mathbf{x}_j \mid \mathbf{mu}_i, \mathbf{\Sigma}_i)`)。
- 第 #mi(`i`) 个高斯的先验概率是 #mi(`\alpha_i`)。
- 两者相乘，再把所有 #mi(`N`) 个高斯成分的结果加起来（#mi(`\sum_{i=1}^N`)），就得到了这个点在整个高斯混合模型里的总出场概率。
]
#remark[
  最普遍的数学推导中，我们还没做“一个高斯成分完美对应一个类别”的强假设。
]
=== EM 算法求解步骤
高斯混合模型的参数估计可以通过 EM 算法迭代更新求解：

1. *E 步 (Expectation)*：根据当前模型参数计算未标记样本 $bold(x)_j in D_u$ 属于各高斯混合成分的后验概率：
   $ gamma_(j i) = (alpha_i dot p(bold(x)_j | mu_i, Sigma_i)) / (sum_(k=1)^N alpha_k dot p(bold(x)_j | mu_k, Sigma_k)) $

2. *M 步 (Maximization)*：更新模型参数。令 $l_i$ 表示第 $i$ 类的有标记样本数目（即 $l_i = sum_((bold(x)_j, y_j) in D_l) bb(I)(y_j = i)$），更新公式为：
   $ mu_i = 1 / (sum_(bold(x)_j in D_u) gamma_(j i) + l_i) ( sum_(bold(x)_j in D_u) gamma_(j i) bold(x)_j + sum_( (bold(x)_j, y_j) in D_l and y_j = i ) bold(x)_j ) $#note[
    本质上是一个加权平均：
    1. 右边项（硬证据）： #mi(`\sum \mathbf{x}_j`)。这是正牌的有标记数据（#mi(`D_l`)）。如果标签写着它是猫（#mi(`y_j = i`)），那它的权重就是整整的 #mi(`1`)。
    2. 左边项（软证据）： #mi(`\sum \gamma_{ji} \mathbf{x}_j`)。这是未标记数据（#mi(`D_u`)）。若只有 #mi(`0.8`) 的概率是猫，那就只贡献 #mi(`0.8`) 个点的力量。
    3. 分母（总贡献点数）： #mi(`\sum \gamma_{ji} + l_i`)。把有标记的猫的数量（#mi(`l_i`)）和未标记数据里凑出来的“虚拟猫”的数量（#mi(`\sum \gamma_{ji}`)）加在一起，作为总分母。
   方差 #mi(`\mathbf{\Sigma}_i`) 和混合系数 #mi(`\alpha_i`) 也是用这种“真猫”与“虚拟猫”合力的方式更新出来的。
   ]

   $ Sigma_i = 1 / (sum_(bold(x)_j in D_u) gamma_(j i) + l_i) ( sum_(bold(x)_j in D_u) gamma_(j i) (bold(x)_j - mu_i)(bold(x)_j - mu_i)^T \ + sum_( (bold(x)_j, y_j) in D_l and y_j = i ) (bold(x)_j - mu_i)(bold(x)_j - mu_i)^T ) $

   $ alpha_i = 1 / m ( sum_(bold(x)_j in D_u) gamma_(j i) + l_i ) $
   其中 $m = l + u$ 为总样本数。


#algorithm("生成式半监督高斯混合模型 EM 算法")[
*输入*：有标记样本集 $D_l = {(bold(x)_1, y_1), (bold(x)_2, y_2), dots, (bold(x)_l, y_l)}$； \
      未标记样本集 $D_u = {bold(x)_(l+1), bold(x)_(l+2), dots, bold(x)_(l+u)}$； \
      高斯混合成分个数 $N$。

*输出*：高斯混合模型参数 $alpha_i, bold(mu)_i, Sigma_i$ ($i = 1, 2, dots, N$)。

*过程*：

1. 初始化高斯混合模型参数 $alpha_i, bold(mu)_i, Sigma_i$ ($i = 1, 2, dots, N$)。

2. *循环迭代*直至收敛（如对数似然函数值不再显著增加）：
   - *E 步 (Expectation)*：根据当前模型参数计算每个未标记样本 $bold(x)_j in D_u$ 属于各高斯混合成分的后验概率（软标签）：
     $ gamma_(j i) = (alpha_i dot p(bold(x)_j | bold(mu)_i, Sigma_i)) / (sum_(k=1)^N alpha_k dot p(bold(x)_j | bold(mu)_k, Sigma_k)) $
   
   - *M 步 (Maximization)*：利用有标记数据与未标记数据的组合信息更新模型参数。令 $l_i$ 表示第 $i$ 类的有标记样本数目（即 $l_i = sum_((bold(x)_j, y_j) in D_l) bb(I)(y_j = i)$），对每个成分 $i = 1, 2, dots, N$ 更新：
     - 更新均值向量 $bold(mu)_i$、协方差矩阵 $Sigma_i$；
     - 更新混合系数 $alpha_i$（其中总样本数 $m = l + u$）。
]

=== 生成式方法的特点
- *推广*：若将高斯混合模型换成混合专家模型、朴素贝叶斯模型等，即可推导出其他的生成式半监督学习方法。
- *优点*：算法简单易实现，在标记样本极少时由于先验结构强，往往表现优异。
- *局限性*：此类方法极其依赖*模型假设的准确性*。若假设的生成式模型与真实数据分布不吻合，利用未标记数据反而会降低模型的泛化性能。因此，除非拥有充分可靠的领域先验知识，否则在现实任务中很难直接保证假设的精确度。

== 半监督支持向量机 (S3VM)

=== TSVM 基本原理
半监督支持向量机中最著名的是 *TSVM (Transductive Support Vector Machine，直推支持向量机)*。与标准 SVM 一样，TSVM 也是针对二分类问题的学习方法。

  #remark[S3VM 与标准 SVM 决策边界的差异 (低密度间隔划分)][
    - 标准 SVM 仅寻找使有标记样本间隔最大化的超平面，这可能会把超平面直接切在未标记样本密集的区域。
    - TSVM 则同时考虑有标记和未标记样本，它试图穿过未标记样本最稀疏的地方（低密度区域），并让所有样本（包括带有伪标记的未标记样本）的整体间隔最大化。
  ]


TSVM 试图考虑*对未标记样本进行各种可能的标记指派*（Label Assignment），在*所有可能的结果*中，寻求一个在*所有样本上间隔最大化*的划分超平面。确定划分超平面后，未标记样本的指派标记即为最终预测结果。

=== TSVM 形式化优化目标
给定 $D_l = {(bold(x)_1, y_1), dots, (bold(x)_l, y_l)}$，其中 $y_i in {-1, +1}$，以及未标记样本集 $D_u = {bold(x)_(l+1), dots, bold(x)_(l+u)}$，$l << u$。TSVM 的目标是尝试为 $D_u$ 给出预测标记 $hat(bold(y)) = (hat(y)_(l+1), dots, hat(y)_(l+u))$（$hat(y)_j in {-1, +1}$）以最小化如下目标函数：
$
  min_(bold(w), b, hat(bold(y)), bold(xi)) & quad 1/2 ||bold(w)||_2^2 + C_l sum_(i=1)^l xi_i + C_u sum_(i=l+1)^(l+u) xi_i \
  "s.t." & quad y_i (bold(w)^T bold(x)_i + b) >= 1 - xi_i, quad i=1, 2, dots, l \
  & quad hat(y)_j (bold(w)^T bold(x)_j + b) >= 1 - xi_j, quad j=l+1, l+2, dots, l+u \
  & quad xi_i >= 0, quad i=1, 2, dots, l+u quad quad quad (13.9)
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
  6. #h(1.5em) *while* $exists i, j$ 满足 $(hat(y)_i hat(y)_j < 0) and (xi_i > 0) and (xi_j > 0) and (xi_i + xi_j > 2)$ *do* #note[
       如果在某轮求解中，存在一对未标记样本 #mi(`bold(x)_i`) 和 #mi(`bold(x)_j`)：
    1. 它们被指派了不同的伪标记 (#mi(`hat(y)_i hat(y)_j < 0`))；
    2. 且它们的松弛变量满足 #mi(`xi_i > 0`) 和 #mi(`xi_j > 0`)；
    3. 并且它们的松弛变量之和 #mi(`xi_i + xi_j > 2`)。

    这说明它们在当前划分面下都位于错误的一侧，且错误非常严重。如果将它们的标记对调重新训练，可以严格保证式目标函数值*单调下降*。]
  7. #h(3em) $hat(y)_i = -hat(y)_i$；
  8. #h(3em) $hat(y)_j = -hat(y)_j$；
  9.  #h(3em) 基于 $D_l, D_u, hat(bold(y)), C_l, C_u$ 重新求解式 (13.9)，得到新参数 $(bold(w), b), bold(xi)$；
  10. #h(1.5em) *end while*
  11. #h(1.5em) $C_u = min(2 C_u, C_l)$；
  12. *end while*
]


尽管如此，搜索每一对可能出错的伪标记样本并进行调整，计算开销仍然极大。因此，半监督支持向量机的研究重点在于如何设计更加高效的大规模优化求解策略。


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
假定我们希望学得一个实值函数 $f : V -> RR$，对应的分类规则为 $y_i = "sign"(f(bold(x)_i))$。直观上，相似的样本应具有相似的标记(为了满足流形假设（或平滑性约束）)，故可定义关于 $f$ 的能量函数：#note[
  可以把这个能量理解为“社会舆论压力”或“朋友圈的不和谐度”。
  
  如果我和你是死党（#mi(`W_{ij}`) 很大），但是我的观点和你的观点差了十万八千里（#mi(`(f_i - f_j)^2`) 很大），那我们俩在一起就会天天吵架，整个网络的“不和谐能量”就会飙升。
  
  算法的目标是：最小化这个能量。也就是强迫关系铁的人，必须拥有相似的观点。所谓的图拉普拉斯矩阵 #mi(`L = D - W`)，在数学上没有魔法，它纯粹是一个优雅的包装盒。有了它，我们就能把全网所有人两两吵架的能量，用一个极简的矩阵乘法 #mi(`\mathbf{f}^T \mathbf{L} \mathbf{f}`) 表示出来，方便后续求导。
]
#mitex(`
\begin{aligned}
E(f) &= \frac{1}{2} \sum_{i=1}^{m} \sum_{j=1}^{m} (\mathbf{W})_{ij} (f(\boldsymbol{x}_i) - f(\boldsymbol{x}_j))^2 \\
&= \frac{1}{2} \left( \sum_{i=1}^{m} d_i f^2(\boldsymbol{x}_i) + \sum_{j=1}^{m} d_j f^2(\boldsymbol{x}_j) - 2 \sum_{i=1}^{m} \sum_{j=1}^{m} (\mathbf{W})_{ij} f(\boldsymbol{x}_i) f(\boldsymbol{x}_j) \right) \\
&= \sum_{i=1}^{m} d_i f^2(\boldsymbol{x}_i) - \sum_{i=1}^{m} \sum_{j=1}^{m} (\mathbf{W})_{ij} f(\boldsymbol{x}_i) f(\boldsymbol{x}_j) \\
&= \boldsymbol{f}^\mathrm{T} (\mathbf{D} - \mathbf{W}) \boldsymbol{f}
\end{aligned}
\tag{13.12}
`)
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
$ bold(f)_u = (bold(I) - bold(P)_(u u))^(-1) bold(P)_(u l) bold(f)_l $#note[
  把人分成两拨：
  - 铁杆派（#mi(`\mathbf{f}_l`)）：这帮人有初始标签，立场坚定，打死也不改颜色。
  - 墙头草（#mi(`\mathbf{f}_u`)）：这帮人没标签，他们的颜色完全取决于周围的朋友。
    - 为了让全网的吵架能量最小，这群墙头草最终会达到一个平衡：每个墙头草的颜色，正好等于他所有邻居颜色的加权平均。
]


=== 多分类标记传播与规范拉普拉斯矩阵
在多分类任务中，定义非负标记矩阵 $bold(F) in RR^((l+u) times |cal(Y)|)$。其第 $i$ 行向量对应于示例 $bold(x)_i$ 的类别后验概率。

首先将 $bold(F)$ 初始化为 $bold(Y)$，其中：
$ bold(Y)_(i j) = cases(1 &"if" (1 <= i <= l) and (y_i = j), 0 &"otherwise") $
其前 $l$ 行为已知有标记样本的 One-hot 编码，剩余行为 $0$。基于度矩阵构建标记传播矩阵 $bold(S) = bold(D)^(-1/2) bold(W) bold(D)^(-1/2)$。算法采用如下迭代计算式：
$ bold(F)(t+1) = alpha bold(S) bold(F)(t) + (1 - alpha) bold(Y) $
其中，$alpha in (0, 1)$ 用于控制标记传播项与初始化项的折中比重。#note[
  - #mi(`\alpha`) 趋近于 1 时：模型极其信任网络中“朋友之间的小道消息传话”。颜色在图上会扩散得非常剧烈、非常远。但缺点是传着传着，最初那几个有标记样本的真实标签（正确答案）就会被稀释、甚至被洗脑洗掉。

  - #mi(`\alpha`) 趋近于 0 时：模型极其保守，只认死理。大家几乎不怎么传话，未标记样本很难从周围邻居那里学到有效的分布信息。]由于 $bold(S)$ 的特征值绝对值不大于 $1$，当 $t -> infinity$ 时，迭代必收敛。收敛解为：
$ bold(F)^\* = (1 - alpha)(bold(I) - alpha bold(S))^(-1) bold(Y) $

  #remark[正则化框架等价性][
    上述迭代算法的收敛解，在数学上等价于如下正则化框架的最优解：
    $ min_(bold(F)) 1/2 ( sum_(i,j=1)^(l+u) W_(i j) || 1 / sqrt(d_i) bold(F)_i - 1 / sqrt(d_j) bold(F)_j ||_2^2 + mu sum_(i=1)^l ||bold(F)_i - bold(Y)_i||_2^2 ) $
    其中第一项为流形约束（强迫近邻样本具有相似的归一化表示），第二项为拟合约束（强迫有标记样本的预测值逼近真实标签），$mu = (1 - alpha) / alpha$ 为正则化参数。
  ]


=== 图半监督学习的局限性
1. *存储和计算开销巨大*：对于拥有 $m$ 个样本的数据集，亲和矩阵的规模达 $O(m^2)$。当数据规模较大时，矩阵逆运算和存储都难以直接承受。
2. *外部样本预测困难 (Out-of-Sample Issue)*：构图时无法预知未出现的测试样本。当接收到新样本时，要么必须将其加入原数据集重新构建整个图并重新运行标记传播，要么必须额外引入一个预测机制（如归纳学习器）来逼近传播结果。


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
#remark[协同训练的基本思路是：在每个视图上训练一个独立的分类器，然后让各自的分类器去*挑选置信度最高的未标记样本*，将其预测结果赋予*伪标记*，并*提供给另一个视图*下的分类器作为新增的有标记样本进行训练。]

#algorithm("协同训练 (Co-training) 算法")[
  *输入*：有视图标记样本集 $D_l$；未标记样本集 $D_u$；缓冲池大小 $s$；每轮挑选正、反例数 $p, n$；基学习算法 $cal(L)$；训练轮数 $T$。 \
  *输出*：视图分类器 $h_1, h_2$。 \
  *过程*：
  1. 从 $D_u$ 中随机抽取 $s$ 个样本构成*缓冲池* $D_s$，$D_u = D_u ∖ D_s$；#note[
   为什么不直接从海量的未标记集 #mi(`D_u`) 里挑样本，非要搞一个大小为 #mi(`s`) 的“缓冲池 #mi(`D_s`)”？
   
   *为了防止标签漂移（Label Drift）和类别不平衡。*如果直接从几百万数据的 #mi(`D_u`) 里挑，分类器可能每轮挑出来的全都是长得极其相似的、极端的“超级大正例”。这样不仅无法给另一个分类器带来新知识，还会让数据集瞬间失去平衡。
   
   搞一个小的缓冲池，强迫分类器只能在这一小撮电影里挑选最自信的 #mi(`p`) 个正例和 #mi(`n`) 个反例。这样能保证挑出来的样本具有随机性和多样性，让两边的训练能稳步、均衡地推进。]
  2. 根据 $D_l$ 分离出各视图对应的标记数据集 $D_l^1, D_l^2$；
  3. *for* $t = 1, 2, dots, T$ *do*
  4. #h(1.5em) $h_1 = cal(L)(D_l^1)$；
  5. #h(1.5em) $h_2 = cal(L)(D_l^2)$；
  6. #h(1.5em) 计算 $h_1$ 在 $D_s$ 上的预测置信度，选出 $p$ 个正例和 $n$ 个反例，组成带伪标记的数据：
     #h(3em) $tilde(D)_p^2 = {(bold(x)_i^2, +1) | bold(x)_i^1 in D_p}$，$tilde(D)_n^2 = {(bold(x)_i^2, -1) | bold(x)_i^1 in D_n}$；
  7. #h(1.5em) 计算 $h_2$ 在 $D_s$ 上的预测置信度，选出 $p$ 个正例和 $n$ 个反例，组成带伪标记的数据：
     #h(3em) $tilde(D)_p^1 = {(bold(x)_i^1, +1) | bold(x)_i^2 in D_p}$，$tilde(D)_n^1 = {(bold(x)_i^1, -1) | bold(x)_i^2 in D_n}$；
  8. #h(1.5em) 从缓冲池中移除这些被挑选的样本：$D_s = D_s ∖ (D_p union D_n)$；
  9.  #h(1.5em) *if* $h_1$ 和 $h_2$ 的参数在本轮迭代中均未发生改变 *then* break；
  10. #h(1.5em) *else*
  11. #h(3em) $D_l^1 = D_l^1 union (tilde(D)_p^1 union tilde(D)_n^1)$；
  12. #h(3em) $D_l^2 = D_l^2 union (tilde(D)_p^2 union tilde(D)_n^2)$；
  13. #h(3em) 从 $D_u$ 中随机抽取 $2p + 2n$ 个样本补充到缓冲池 $D_s$ 中；
  14. #h(1.5em) *end if*
  15. *end for*
]

理论证明，如果两个视图满足：
- 充分性（即每个视图单独就足以让分类器收敛）：任何一个单独的视图，都包含了足够完整的信息，多给点数据它自己就能把题解出来。
- 条件独立性（给定类别标记时，两个视图的属性条件独立）#note[
  充分性保证了两个分类器能“互相提供有用的新知识”；条件独立性保证了它们“不会互相传染对方的偏见和错误”。
]
则利用未标记样本通过协同训练可以将弱分类器的泛化性能提升到任意高。

虽然在现实任务中"条件独立性"几乎无法完美满足#note[
  条件独立性要求“给定类别时，两个视图完全不相关”。但这在现实中是不可能的。
  
  比如一部动作片（给定类别），它的画面往往有“追逐爆炸”（视图 1），而它的音效也必然会有“轰鸣和枪声”（视图 2）。画面和音效在暗中是有强烈的因果和物理关联的，绝对做不到数学上的完全独立。所以现实中协同训练只能尽力逼近，无法达到理论上的任意高精度。
]，但协同训练在实际应用中依然能带来显著的性能提升。

=== 单视图协同训练与分歧特征
对于只有单个视图的数据，依然可以通过基于分歧的方法进行半监督学习。此时我们必须通过人为引入差异来构建"分歧"：
- 使用不同的基学习器算法（如 SVM 与 决策树 结合）；
- 采用不同的样本子集采样（如 Bagging 的自助法采样）；
- 使用差异明显的模型参数设置。

只要多个弱学习器之间保持显著的分歧，它们就能通过相互提供伪标记样本的形式来提高整体的泛化性能。该方法较少受到强模型假设的制约，简单有效，因而得到了广泛的应用。


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
*输入*：样本集 $D = {bold(x)_1, bold(x)_2, dots, bold(x)_m}$； \
      必连约束集 $cal(M)$，规定必须划入同一簇的样本对； \
      勿连约束集 $cal(C)$，规定绝不能划入同一簇的样本对； \
      聚类簇数 $k$。

*输出*：簇划分 ${C_1, C_2, dots, C_k}$。

*过程*：

1. *选择初始中心*：从样本集 $D$ 中随机选取 $k$ 个样本作为各个簇的初始均值向量 ${bold(mu)_1, bold(mu)_2, dots, bold(mu)_k}$。

2. *策略迭代*（重复执行以下步骤，直至均值向量不再发生更新）：
   - 清空当前的簇分配，令每个簇 $C_j = emptyset (1 <= j <= k)$。
   - 对每个示例 $bold(x)_i  (i = 1, 2, dots, m)$，在其*合规的*有效候选簇集合 $cal(K)_("valid")$ 中，寻找距离其最近的簇索引 $r$：
     $ r = arg min_(j in cal(K)_("valid")) ||bold(x)_i - bold(mu)_j||_2 $
    - *安全审查与合法候选集 $cal(K)_("valid")$*：集合 $cal(K)_("valid")$ 初始为 ${1, 2, dots, k}$。在考核样本 $bold(x)_i$ 拟塞入簇 $j$ 时，必须通过以下两条硬性红线的政审：
    - *必连遵从*：若存在约束 $(bold(x)_i, bold(x)_a) in cal(M)$，且已指派样本 $bold(x)_a in C_A$，则必须满足 $j = A$。
    - *勿连回避*：若存在约束 $(bold(x)_i, bold(x)_b) in cal(C)$，且已指派样本 $bold(x)_b in C_B$，则必须满足 $j != B$。
    随后将该样本并入对应簇中：$C_r = C_r union {bold(x)_i}$。
   - 在全体样本指派完成后，基于各簇吸纳的新成员，重新计算并动态更新其均值中心：
     $ bold(mu)_j = 1 / (|C_j|) sum_(bold(x) in C_j) bold(x) , quad (j = 1, 2, dots, k) $#note[
  *规则死锁与中止*：若某个样本身上背负的必连与勿连约束过于繁重或自相矛盾，导致遍历所有簇均告违规（即有效候选集完全归空 $cal(K)_("valid") = emptyset$），意味着在当前中心布局下无解，算法将立即中断并抛出异常退出。
]
]
#note[
  以西瓜数据集 4.0 (30 个样本) 为例，在限定必连集 $cal(M)$ 和勿连集 $cal(C)$ 条件下，设置 $k = 3$，经历 5 轮迭代收敛，给出三个簇的最终划分结果。
]

=== 约束种子 $k$ 均值 (Constrained Seed k-means) 算法
当我们拥有少量有标记样本时，可以直接将它们作为种子 (Seeds)。约束种子 $k$-means 将这些种子用于初始化聚类中心，并在随后的迭代中，固定种子样本的簇隶属关系，仅允许未标记样本改变归属。

#algorithm("约束种子 k-means 算法")[
*输入*：样本集 $D = {bold(x)_1, bold(x)_2, dots, bold(x)_m}$； \
      少量有标记样本集合 $S = union.big_(j=1)^k S_j$，其中 $S_j$ 为已经明确归属于第 $j$ 簇的种子样本集； \
      聚类簇数 $k$。

*输出*：簇划分 ${C_1, C_2, dots, C_k}$。

*过程*：

1. *锚定初始中心*：对每个簇 $j = 1, 2, dots, k$，严格基于其专属的种子样本集 $S_j$ 计算初始均值向量：
   $ bold(mu)_j = 1 / (|S_j|) sum_(bold(x) in S_j) bold(x) $

2. 重复执行以下步骤，直至均值向量不再发生更新：
   - *种子复位*：强行让所有带标签的种子选手回到各自的大本营，作为各簇的固定底座，令 $C_j = S_j (1 <= j <= k)$。
   - *普通兵就近归队*：对每一个未标记样本 $bold(x)_i in D "\\" S$，计算其到各个簇中心的欧氏距离，直接将其划分至距离最近的那个簇 $C_r$ 中：
     $ r = arg min_(j in {1, 2, dots, k}) ||bold(x)_i - bold(mu)_j||_2 $
     $ C_r = C_r union {bold(x)_i} $
   - *中心动态修正*：在全体未标记样本吸纳完毕后，融合种子样本与新并入的样本，重新计算并动态调整各簇的均值中心：
     $ bold(mu)_j = 1 / (|C_j|) sum_(bold(x) in C_j) bold(x) , quad (j = 1, 2, dots, k) $
]

#remark[
- 种子样本在此算法中扮演了不可动摇的约束角色。与常规 $k$-means 相比，种子样本的簇归属关系在前期的“种子复位”阶段被强制固定，在后续的迭代中*不允许改变归属*。它们的存在就像磁铁，牢牢吸引特征相似的未标记样本向其靠拢。
- *算法的鲁棒性*：由于不引入离散的“必连/勿连”链条约束，样本指派时不需要进行条件排除，因而算法运行平滑高效，*彻底免疫了因约束冲突而导致的死锁和崩盘退出风险*。
]

有标记样本在这个算法中扮演了"引路人"的硬性锚点角色，它强制均值中心贴近物理类别分布，使无监督的聚类结构能够自底而上地与我们希望的真实类别语义保持高度契合。
