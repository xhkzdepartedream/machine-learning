=== AdaBoost算法的解释

*1. 核心视角：指数损失函数的最小化*

AdaBoost 的所有公式（系数 $alpha_m$ 的计算、权值 $w$ 的更新）并非凭空捏造，其本质是在进行 *前向分步加法建模*，旨在最小化 *指数损失函数*：
$ L(y, f(x)) = exp(-y f(x)) $

其中 $y in {-1, +1}$，$f(x)$ 是强分类器的输出值。

#remark[
+ 如果 $y$ 和 $f(x)$ 符号相同（分类正确）且 $f(x)$ 绝对值很大（置信度高），则 $-y f(x)$ 为很大的负数，损失趋近于 0。
+ 如果符号相反（分类错误），损失会呈指数级爆炸增长。
]

AdaBoost 的迭代过程，实际上就是在使用 *贪心算法*，一步步地寻找基本分类器 $G_m$ 和系数 $alpha_m$，使得整体的指数损失最小化。


*2. 为什么 $alpha_m$ 是那个特定的公式？*

我们来看看 $alpha_m = 1/2 ln((1-e_m)/e_m)$ 是怎么来的。这是全算法最精妙的地方：它是损失函数的 *解析解 (Analytical Solution)*。

假设在第 $m$ 轮，我们已经有了前 $m-1$ 轮的组合 $f_(m-1)(x)$，现在的目标是找到最佳的 $alpha$ 和 $G(x)$ 来更新模型：
$ f_m (x) = f_(m-1) (x) + alpha G(x) $

我们的目标是最小化当前的总损失：
$ L(alpha, G) &= sum_(i=1)^N exp(-y_i (f_(m-1) (x_i) + alpha G(x_i))) \
&= sum_(i=1)^N underbrace(exp(-y_i f_(m-1) (x_i)), "记为 " tilde(w)_(m i)) exp(-y_i alpha G(x_i)) $

注意：这里的 $tilde(w)_(m i)$ 正是算法中第 $m$ 轮样本权值的非归一化形式。假设我们已经找到了使误差最小的 $G_m (x)$，现在解出最优的 $alpha$。将样本分为“正确分类”和“错误分类”两组：

$ L(alpha) &= sum_(y_i = G_m (x_i)) w_(m i) e^(-alpha) + sum_(y_i != G_m (x_i)) w_(m i) e^(alpha) \
            &= e^(-alpha) sum_("correct") w_(m i) + e^(alpha) sum_("incorrect") w_(m i) $

代入误差率 $e_m = sum_("incorrect") w_(m i)$ （假设权重已归一化），则正确分类的权重和为 $1 - e_m$：
$ L(alpha) = (1 - e_m) e^(-alpha) + e_m e^(alpha) $

对 $alpha$ 求导并令其为 0：
$ frac(partial L, partial alpha) = -(1 - e_m) e^(-alpha) + e_m e^(alpha) = 0 \
arrow.r.double (1 - e_m) e^(-alpha) = e_m e^(alpha) \
arrow.r.double frac(1 - e_m, e_m) = e^(2 alpha) \
arrow.r.double 2 alpha = ln(frac(1 - e_m, e_m)) \
arrow.r.double alpha = 1/2 ln(frac(1 - e_m, e_m)) $

*结论*：这个公式保证了在当前 $G_m$ 选定后，$alpha_m$ 的取值能让指数损失函数达到该方向上的 *极小值*。

*3. 权值更新公式的本质：梯度下降*

算法中的权值更新公式为：
$ w_(m+1, i) = w_(m, i) exp(-alpha_m y_i G_m (x_i)) $

如果我们把这公式递归展开：
$ w_(m+1, i) &= exp(-y_i f_(m-1) (x_i)) dot exp(-y_i alpha_m G_m (x_i)) \
&= exp(-y_i (f_(m-1) (x_i) + alpha_m G_m (x_i))) \
&= exp(-y_i f_m (x_i)) $

*数学含义*：
+ 样本 $i$ 的权值 $w_(m+1, i)$，在数值上正比于该样本在当前模型 $f_m$ 下的 *指数损失*。
+ 损失越大（分得越错），权重越大。

这可以理解为一种 *函数空间里的梯度下降*。每一轮的弱分类器 $G_m$，实际上是在拟合损失函数对于当前模型 $f_(m-1)$ 的负梯度方向。算法告诉下一轮的分类器：“请重点关注那些梯度（误差）最大的区域。”

*4. 0/1 损失的上界*

为什么不直接优化 0/1 损失（也就是分类错误率）？
+ 0/1 损失是不连续、非凸的，极难优化 (NP-hard)。
+ 指数损失函数 $e^(-y f(x))$ 是 0/1 损失 $I(y != "sign"(f(x)))$ 的 *光滑凸上界*。

数学上可以证明，随着指数损失不断降低并趋于 0，0/1 损失也会被迫趋于 0。AdaBoost 通过不断压低这个“上界”，间接地实现了分类错误率的最小化。

AdaBoost 的本质并非凭空捏造的权重调整，而是在进行 *前向分步加法建模 (Forward Stagewise Additive Modeling, FSAM)*。其核心目标是最小化 *指数损失函数*：
$ L(y, f(x)) = exp(-y f(x)) $
其中 $y in {-1, +1}$，$f(x)$ 是强分类器的输出值。

#remark[
  *直观理解：* 如果 $y$ 和 $f(x)$ 符号相同（分类正确）且 $|f(x)|$ 很大（置信度高），则 $-y f(x)$ 为很大的负数，损失 $L -> 0$。反之，损失会呈指数级爆炸增长。
]

AdaBoost 的迭代过程，实际上就是在使用 *贪心算法*，一步步地寻找基本分类器 $G_m$ 和系数 $alpha_m$，使得整体的指数损失最小化。

*关于 $alpha_m$ 的解析解推导*

$alpha_m = 1/2 ln((1-e_m)/e_m)$ 是损失函数的解析解。假设在第 $m$ 轮，我们已有 $f_(m-1)(x)$，现在的目标是寻找最佳的 $alpha$ 和 $G(x)$ 以最小化当前总损失：
$ L(alpha, G) &= sum_(i=1)^N exp(-y_i (f_(m-1) (x_i) + alpha G(x_i))) \
&= sum_(i=1)^N underbrace(exp(-y_i f_(m-1) (x_i)), "记为 " tilde(w)_(m i)) exp(-y_i alpha G(x_i)) $

这里的 $tilde(w)_(m i)$ 即第 $m$ 轮的样本权重。假设已找到最优 $G_m(x)$，将样本分为“正确”和“错误”两组求解 $alpha$：
$ L(alpha) = (1 - e_m) e^(-alpha) + e_m e^(alpha) $

对 $alpha$ 求导并令其为 0，即可解得：
$ alpha = 1/2 ln(frac(1 - e_m, e_m)) $
这保证了在 $G_m$ 选定后，$alpha_m$ 能让指数损失沿该方向达到极小值。

*权值更新的本质：函数空间梯度下降*

权值更新公式 $w_(m+1, i) = w_(m, i) exp(-alpha_m y_i G_m (x_i))$ 递归展开后为：
$ w_(m+1, i) = exp(-y_i f_m (x_i)) $

这意味着样本权值在数值上正比于该样本在当前模型下的 *指数损失*。每一轮的弱分类器 $G_m$，实际上是在拟合损失函数对于当前模型 $f_(m-1)$ 的 *负梯度方向*。这是一种 *函数空间 (Function Space) 中的梯度下降*，而不仅仅是参数调整。

*0/1 损失的上界*

之所以优化指数损失而不是 0/1 损失（错误率），是因为 0/1 损失非凸且不连续（NP-hard）。指数损失 $e^(-y f(x))$ 是 0/1 损失的 *光滑凸上界*。通过不断压低这个“上界”，间接迫使分类错误率趋于 0。