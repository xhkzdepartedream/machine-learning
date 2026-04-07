````markdown
# 原型聚类法——完整笔记

> 本章介绍两种原型聚类方法：**学习向量量化（LVQ）** 和 **高斯混合聚类（GMM）**。二者的共同思路是用少量"原型"代表整个数据集，每个原型对应一个簇，样本按与各原型的距离或隶属概率完成划分。区别在于原型的形式：LVQ 用一个向量，GMM 用一个完整的高斯分布。

---

## 一、学习向量量化（LVQ）

### 1.1 定位与动机

与 k-均值等无监督聚类不同，LVQ（Learning Vector Quantization）**假设数据集带有类别标记**，在学习过程中借助这些监督信息引导原型向量的更新方向，从而得到更符合类别边界的划分结果。

### 1.2 问题设定

给定带标记训练集：

$$D = \{(\boldsymbol{x}_1, y_1), (\boldsymbol{x}_2, y_2), \ldots, (\boldsymbol{x}_m, y_m)\}$$

其中 $\boldsymbol{x}_j \in \mathbb{R}^n$ 为 $n$ 维特征向量，$y_j \in \mathcal{Y}$ 为类别标记。

目标是学得 $q$ 个 $n$ 维**原型向量** $\{\boldsymbol{p}_1, \boldsymbol{p}_2, \ldots, \boldsymbol{p}_q\}$，每个 $\boldsymbol{p}_i$ 附带一个预设的类别标记 $t_i \in \mathcal{Y}$。训练完成后，每个原型向量定义其对应的 **Voronoi 区域**——样本空间中与该原型距离最近的所有点都归入对应的簇。

### 1.3 算法流程

```
输入：样本集 D = {(x₁,y₁),…,(xₘ,yₘ)}
      原型向量个数 q 及各原型对应的类别标记 {t₁,…,t_q}
      学习率 η ∈ (0, 1)

过程：
1.  随机初始化一组原型向量 {p₁, p₂, …, p_q}
2.  repeat
3.    从 D 中随机取一个样本 (xⱼ, yⱼ)
4.    计算 xⱼ 与每个 pᵢ 的距离：dᵢ = ‖xⱼ - pᵢ‖
5.    找到最近原型：p* = argmin dᵢ，记其类别标记为 t*
6.    if yⱼ == t*  then          ← 类别相同，令 p* 靠近 xⱼ
7.      p' = p* + η · (xⱼ - p*)
8.    else                        ← 类别不同，令 p* 远离 xⱼ
9.      p' = p* - η · (xⱼ - p*)
10.   end if
11.   将 p* 更新为 p'
12. until 满足停止条件

输出：原型向量 {p₁, p₂, …, p_q}
```

### 1.4 更新规则的几何解释

两种更新方式的本质是调整 $\boldsymbol{p}^*$ 与 $\boldsymbol{x}_j$ 之间的距离：

**情形一：标记相同，靠近**

$$\boldsymbol{p}' = \boldsymbol{p}^* + \eta \cdot (\boldsymbol{x}_j - \boldsymbol{p}^*)$$

更新后两者距离为：

$$\|\boldsymbol{p}' - \boldsymbol{x}_j\| = (1 - \eta)\,\|\boldsymbol{p}^* - \boldsymbol{x}_j\|$$

即距离缩短为原来的 $(1-\eta)$ 倍，$\boldsymbol{p}^*$ 向 $\boldsymbol{x}_j$ 移动。

**情形二：标记不同，远离**

$$\boldsymbol{p}' = \boldsymbol{p}^* - \eta \cdot (\boldsymbol{x}_j - \boldsymbol{p}^*)$$

更新后两者距离为：

$$\|\boldsymbol{p}' - \boldsymbol{x}_j\| = (1 + \eta)\,\|\boldsymbol{p}^* - \boldsymbol{x}_j\|$$

即距离扩大为原来的 $(1+\eta)$ 倍，$\boldsymbol{p}^*$ 远离 $\boldsymbol{x}_j$。

> **学习率 $\eta$ 的作用**：$\eta$ 越大，原型向量对单个样本的响应越激烈；$\eta$ 越小，收敛越平稳但速度较慢。实践中通常随迭代轮次衰减。

### 1.5 Voronoi 划分与聚类效果

训练完成后，$q$ 个原型向量将样本空间划分为 $q$ 个 Voronoi 区域：样本 $\boldsymbol{x}$ 被划入与其欧氏距离最近的原型 $\boldsymbol{p}_{i^*}$ 所对应的簇 $C_{i^*}$。随着迭代轮数增加（50 → 100 → 200 → 400 轮），各原型不断调整位置，簇的边界逐渐清晰、稳定。

---

## 二、高斯混合聚类（GMM）

LVQ 以一个点代表一个簇，表达能力有限。高斯混合模型（Gaussian Mixture Model, GMM）改用一个**高斯分布**来刻画每个簇，能够表达更丰富的形状（椭圆形、旋转簇等），同时通过软分配给出每个样本属于各簇的概率。

### 2.1 基础：多元高斯分布

对 $n$ 维随机向量 $\boldsymbol{x}$，若其服从均值为 $\boldsymbol{\mu}$、协方差矩阵为 $\boldsymbol{\Sigma}$ 的高斯分布，概率密度函数为：

$$p(\boldsymbol{x}) = \frac{1}{(2\pi)^{n/2}|\boldsymbol{\Sigma}|^{1/2}} \exp\!\left(-\frac{1}{2}(\boldsymbol{x} - \boldsymbol{\mu})^\top \boldsymbol{\Sigma}^{-1} (\boldsymbol{x} - \boldsymbol{\mu})\right)$$

简记为 $p(\boldsymbol{x} \mid \boldsymbol{\mu}, \boldsymbol{\Sigma})$，其中：

- $\boldsymbol{\mu}$：$n$ 维均值向量，描述分布的中心位置；
- $\boldsymbol{\Sigma}$：$n \times n$ 正定协方差矩阵，描述分布的形状与方向；
- $|\boldsymbol{\Sigma}|$：$\boldsymbol{\Sigma}$ 的行列式，出现在归一化常数中。

### 2.2 高斯混合分布的定义

高斯混合模型将 $k$ 个高斯分量加权叠加：

$$p_{\mathcal{M}}(\boldsymbol{x}) = \sum_{i=1}^k \alpha_i \cdot p(\boldsymbol{x} \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)$$

每个分量由三元组 $(\alpha_i, \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)$ 描述：

| 参数 | 含义 | 约束 |
|---|---|---|
| $\alpha_i$ | 混合系数（先验权重） | $\alpha_i > 0$，且 $\displaystyle\sum_{i=1}^k \alpha_i = 1$ |
| $\boldsymbol{\mu}_i$ | 第 $i$ 个分量的均值向量 | 无约束 |
| $\boldsymbol{\Sigma}_i$ | 第 $i$ 个分量的协方差矩阵 | 正定矩阵 |

### 2.3 样本生成过程与隐变量

高斯混合模型可以理解为一个两阶段生成过程：

1. 以先验概率 $\alpha_i$ 选择第 $i$ 个混合成分，此选择由**隐变量** $z_j \in \{1, \ldots, k\}$ 记录，即 $P(z_j = i) = \alpha_i$；
2. 从选定的高斯分量 $\mathcal{N}(\boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)$ 中采样，得到观测样本 $\boldsymbol{x}_j$。

由于 $z_j$ 未知，利用贝叶斯定理求 $z_j$ 的**后验概率**（已观测到 $\boldsymbol{x}_j$ 后，它来自第 $i$ 个分量的概率）：

$$\gamma_{ji} = p_{\mathcal{M}}(z_j = i \mid \boldsymbol{x}_j) = \frac{P(z_j=i) \cdot p(\boldsymbol{x}_j \mid z_j=i)}{p_{\mathcal{M}}(\boldsymbol{x}_j)} = \frac{\alpha_i \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)}{\displaystyle\sum_{l=1}^k \alpha_l \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_l, \boldsymbol{\Sigma}_l)}$$

> $\gamma_{ji}$ 是软聚类的核心量：它不是 0/1 的硬分配，而是样本 $\boldsymbol{x}_j$ 对各成分连续的隶属概率，满足 $\sum_{i=1}^k \gamma_{ji} = 1$。

### 2.4 聚类规则

求得所有 $\gamma_{ji}$ 后，将样本 $\boldsymbol{x}_j$ 划入使后验概率最大的那个成分所对应的簇：

$$\lambda_j = \mathop{\arg\max}_{1 \le i \le k}\ \gamma_{ji}$$

**从原型聚类角度理解**：高斯混合聚类以高斯分布作为原型，簇划分由后验概率（样本属于该成分的平均后验概率）确定，即每个样本被划入后验概率最大的簇标记所对应的簇。

### 2.5 参数估计：最大对数似然

给定样本集 $D$，模型参数 $\{(\alpha_i, \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)\}$ 通过最大化对数似然来确定：

$$LL(D) = \ln \prod_{j=1}^m p_{\mathcal{M}}(\boldsymbol{x}_j) = \sum_{j=1}^m \ln \left(\sum_{i=1}^k \alpha_i \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)\right)$$

对 $\boldsymbol{\mu}_i$ 求偏导并令其为零：

$$\frac{\partial\, LL(D)}{\partial\, \boldsymbol{\mu}_i} = \sum_{j=1}^m \frac{\alpha_i \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)}{\displaystyle\sum_l \alpha_l \cdot p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_l, \boldsymbol{\Sigma}_l)} \cdot (\boldsymbol{x}_j - \boldsymbol{\mu}_i) = \sum_{j=1}^m \gamma_{ji}\,(\boldsymbol{x}_j - \boldsymbol{\mu}_i) = 0$$

解出 $\boldsymbol{\mu}_i$，并类似地对 $\boldsymbol{\Sigma}_i$ 和 $\alpha_i$（利用拉格朗日乘子法处理 $\sum \alpha_i = 1$ 的约束）求导，得到参数的闭式更新公式：

$$\boldsymbol{\mu}_i' = \frac{\displaystyle\sum_{j=1}^m \gamma_{ji}\, \boldsymbol{x}_j}{\displaystyle\sum_{j=1}^m \gamma_{ji}}$$

$$\boldsymbol{\Sigma}_i' = \frac{\displaystyle\sum_{j=1}^m \gamma_{ji}\,(\boldsymbol{x}_j - \boldsymbol{\mu}_i)(\boldsymbol{x}_j - \boldsymbol{\mu}_i)^\top}{\displaystyle\sum_{j=1}^m \gamma_{ji}}$$

$$\alpha_i' = \frac{\displaystyle\sum_{j=1}^m \gamma_{ji}}{m}$$

**直观理解**：$\boldsymbol{\mu}_i'$ 是所有样本以后验概率 $\gamma_{ji}$ 为权重的加权均值；$\boldsymbol{\Sigma}_i'$ 是对应的加权协方差；$\alpha_i'$ 等于各样本归属第 $i$ 个成分的平均后验概率。

### 2.6 EM 算法框架

由于 $\gamma_{ji}$ 依赖参数、参数又依赖 $\gamma_{ji}$，形成循环依赖，无法直接求解，因此采用 **EM（期望最大化）算法**迭代求解：

- **E 步（Expectation）**：固定当前参数 $\{(\alpha_i, \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)\}$，按 2.3 节的公式计算每个样本对每个成分的后验概率 $\gamma_{ji}$；
- **M 步（Maximization）**：固定 $\gamma_{ji}$，按 2.5 节的公式更新所有参数；
- 重复 E/M 两步直至收敛（参数变化量低于阈值）。

每次迭代都保证对数似然不减，算法收敛至局部最优。

### 2.7 完整算法伪代码

```
输入：样本集 D = {x₁, x₂, …, xₘ}；高斯混合成分个数 k

过程：
1.  初始化高斯混合分布的模型参数 {(αᵢ, μᵢ, Σᵢ) | 1 ≤ i ≤ k}
2.  repeat
3.    [E步] for j = 1, …, m do
4.            根据当前参数计算 γⱼᵢ（各成分生成样本 xⱼ 的后验概率）
5.          end for
6.    [M步] for i = 1, …, k do
7.            计算新均值向量：μᵢ' = (Σⱼ γⱼᵢ xⱼ) / (Σⱼ γⱼᵢ)
8.            计算新协方差矩阵：Σᵢ' = (Σⱼ γⱼᵢ (xⱼ-μᵢ)(xⱼ-μᵢ)ᵀ) / (Σⱼ γⱼᵢ)
9.            计算新混合系数：αᵢ' = (Σⱼ γⱼᵢ) / m
10.         end for
11.   将模型参数 {(αᵢ, μᵢ, Σᵢ)} 更新为 {(αᵢ', μᵢ', Σᵢ')}
12. until 满足停止条件
13. [划簇] Cᵢ = ∅（1 ≤ i ≤ k）
14. for j = 1, …, m do
15.   令 λⱼ = argmaxᵢ γⱼᵢ，根据 γⱼᵢ 确定 xⱼ 的簇标记 λⱼ
16.   将 xⱼ 并入相应的簇：C_{λⱼ} = C_{λⱼ} ∪ {xⱼ}
17. end for
18. return 簇划分结果 C = {C₁, C₂, …, C_k}
```

### 2.8 聚类效果

随着迭代轮数增加（5 → 10 → 20 → 50 轮），各高斯分量的均值和协方差逐渐收敛，簇的划分趋于稳定清晰。

---

## 三、两种方法横向对比

| 维度 | LVQ | 高斯混合聚类 |
|---|---|---|
| 原型形式 | 向量（空间中一个点） | 高斯分布（均值 + 协方差） |
| 是否需要标记 | 是（利用类别标记） | 否（纯无监督） |
| 簇的表达能力 | 凸、各向同性区域 | 可表达椭圆形、旋转簇 |
| 样本归属方式 | 硬分配（最近原型） | 软分配（后验概率最大） |
| 求解方式 | 在线迭代（逐样本更新） | 批量迭代（EM 算法） |
| 参数数量 | $q \times n$（原型坐标） | $k \times (1 + n + n^2)$（混合系数、均值、协方差） |

---

## 四、关键概念速查

**Voronoi 区域**：每个原型向量"管辖"的样本空间子集——所有与该原型欧氏距离最近的点。LVQ 的聚类边界即由 Voronoi 图给出。

**混合系数 $\alpha_i$**：先验概率，反映第 $i$ 个高斯分量在整体分布中的比重，可理解为"随机抽取一个样本，它来自成分 $i$ 的先验概率"。

**后验概率 $\gamma_{ji}$**：在观测到 $\boldsymbol{x}_j$ 之后，该样本来自第 $i$ 个成分的概率。它综合了先验权重 $\alpha_i$ 和该分量对 $\boldsymbol{x}_j$ 的拟合程度 $p(\boldsymbol{x}_j \mid \boldsymbol{\mu}_i, \boldsymbol{\Sigma}_i)$，是软聚类决策的依据。

**EM 算法**：专门处理含隐变量的最大似然估计问题的迭代框架。E 步计算隐变量的期望（即后验概率），M 步在给定期望下最大化似然函数，两步交替直至收敛。每次迭代保证对数似然单调不减。

**软分配 vs. 硬分配**：GMM 的 $\gamma_{ji}$ 是连续概率值（软分配），每个样本同时"部分属于"多个簇；LVQ 和 k-均值则将样本唯一地分配给一个簇（硬分配）。软分配在簇边界附近更具鲁棒性，也更自然地表达了不确定性。
````