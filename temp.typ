好的，我们来详细讲解这个推导过程，并回答旁边的问题。

---

## 📌 一、整体内容概览

这段文字来自信息论或概率统计教材，主要内容包括：

- **Definition 0.1.1**：定义离散随机变量的熵（Entropy）。
- **Theorem 0.1.2**：证明熵的最大值为 $\log n$，当且仅当分布是均匀分布时取到。
- **Proof**：使用拉格朗日乘数法求解带约束的优化问题。
- **旁注问题**：“这为什么不是 Jensen 不等式直接解决？或者考虑 $f(x) \triangleq x \log x$ 的凸性”

---

## 📘 二、Definition 0.1.1 —— 熵的定义

设 $X$ 是一个取有限个值的离散随机变量，其可能取值为 $x_1, x_2, ..., x_n$，对应的概率为：

$$
P(X = x_i) = p_i, \quad i = 1, 2, ..., n
$$

则随机变量 $X$ 的**熵**定义为：

$$
H(X) = -\sum_{i=1}^{n} p_i \log(p_i)
$$

> 💡 注意：
> - 对数底可以是 2（单位 bit）或 e（单位 nat），不影响最大值的位置。
> - 熵只依赖于概率分布 $p = (p_1, ..., p_n)$，与具体取值 $x_i$ 无关，因此也可记作 $H(p)$。

---

## 🧮 三、Theorem 0.1.2 —— 熵的最大值

定理指出：

$$
0 \le H(p) \le \log n
$$

其中：

- 最小值 0：当某个 $p_i = 1$，其余为 0 时（确定性事件）。
- 最大值 $\log n$：当所有 $p_i = \frac{1}{n}$ 时（均匀分布）。

下面重点看**如何证明最大值是 $\log n$**。

---

## 🔍 四、Proof —— 拉格朗日乘数法推导

目标：在约束条件 $\sum_{i=1}^n p_i = 1$ 下，最大化熵函数：

$$
\max_{p_i} \left( -\sum_{i=1}^n p_i \log p_i \right), \quad \text{s.t. } \sum_{i=1}^n p_i = 1
$$

### Step 1: 构造拉格朗日函数

引入拉格朗日乘子 $\lambda$，构造拉格朗日函数：

$$
L(p_i, \lambda) = -\sum_{i=1}^n p_i \log p_i + \lambda \left( \sum_{i=1}^n p_i - 1 \right)
$$

### Step 2: 求偏导并令其为 0

对每个 $p_i$ 求偏导：

$$
\frac{\partial L}{\partial p_i} = -\log p_i - 1 + \lambda = 0
$$

> 📝 推导细节：
> - $\frac{d}{dp}(p \log p) = \log p + 1$ （自然对数下）
> - 所以 $\frac{d}{dp}(-p \log p) = -\log p - 1$
> - 加上约束项的导数 $\lambda$，得：$-\log p_i - 1 + \lambda = 0$

整理得：

$$
\log p_i = \lambda - 1 \Rightarrow p_i = e^{\lambda - 1}
$$

也就是说，**所有 $p_i$ 都相等！**

再代入约束条件 $\sum p_i = 1$：

$$
\sum_{i=1}^n p_i = n \cdot e^{\lambda - 1} = 1 \Rightarrow e^{\lambda - 1} = \frac{1}{n}
\Rightarrow p_i = \frac{1}{n}
$$

### Step 3: 计算最大熵

将 $p_i = \frac{1}{n}$ 代入熵公式：

$$
H(p) = -\sum_{i=1}^n \frac{1}{n} \log \left( \frac{1}{n} \right) = -n \cdot \frac{1}{n} \cdot (-\log n) = \log n
$$

✅ 得证：熵的最大值为 $\log n$，在均匀分布时取得。

---

## ❓ 五、回答旁边的提问：

> “这为什么不是 Jensen 不等式直接解决？或者考虑 $f(x) \triangleq x \log x$ 的凸性”

这是一个非常好的问题！实际上，**确实可以用 Jensen 不等式更简洁地证明这个结论**，而且这是信息论中非常经典的方法。

---

### ✅ 方法一：用 Jensen 不等式（推荐）

我们知道函数 $f(x) = x \log x$ 在 $x > 0$ 上是**严格凸函数**（因为二阶导数 $f''(x) = \frac{1}{x} > 0$）。

根据 **Jensen 不等式**：

对于凸函数 $f$，有：

$$
f\left( \mathbb{E}[X] \right) \le \mathbb{E}[f(X)]
$$

但这里我们要处理的是熵：

$$
H(p) = -\sum p_i \log p_i = \sum p_i \log \frac{1}{p_i}
$$

我们可以写成期望形式：

令随机变量 $Y$ 取值 $\log \frac{1}{p_i}$，概率为 $p_i$，则：

$$
H(p) = \mathbb{E}\left[ \log \frac{1}{p_Y} \right]
$$

现在考虑函数 $g(x) = \log x$，它是**凹函数**（因为二阶导数 $g''(x) = -\frac{1}{x^2} < 0$）。

由 Jensen 不等式（凹函数版本）：

$$
\mathbb{E}[g(Y)] \le g(\mathbb{E}[Y])
$$

即：

$$
\mathbb{E}\left[ \log \frac{1}{p_Y} \right] \le \log \left( \mathbb{E}\left[ \frac{1}{p_Y} \right] \right)
$$

但这似乎不太直观。换一种方式：

我们想证明：

$$
H(p) = -\sum p_i \log p_i \le \log n
$$

等价于：

$$
\sum p_i \log \frac{1}{p_i} \le \log n
$$

两边除以 $\log n$（假设底数相同），或直接变形：

考虑：

$$
\sum p_i \log \frac{1}{p_i} \le \log n \iff \sum p_i \log \frac{n}{p_i} \le \log n + \sum p_i \log n = \log n + \log n = 2\log n?
$$

不对，重新来：

更好的方法是利用 KL 散度或直接用 Jensen：

---

### 🎯 标准 Jensen 证明如下：

考虑函数 $f(x) = -\log x$，它是**凸函数**（因为 $f''(x) = \frac{1}{x^2} > 0$）。

那么：

$$
H(p) = \sum_{i=1}^n p_i \cdot (-\log p_i) = \mathbb{E}_p[-\log p_i]
$$

而由于 $f(x) = -\log x$ 是凸函数，由 Jensen 不等式：

$$
\mathbb{E}_p[f(p_i)] \ge f(\mathbb{E}_p[p_i])
$$

但注意：这里的“期望”是对索引 $i$ 的加权平均，权重是 $p_i$，所以：

$$
\sum p_i (-\log p_i) \ge -\log \left( \sum p_i \cdot p_i \right)
$$

这也不对，因为 $\sum p_i \cdot p_i$ 不是我们想要的。

---

### ✅ 正确做法（最简洁）：

我们想证明：

$$
H(p) = -\sum p_i \log p_i \le \log n
$$

等价于：

$$
\sum p_i \log \frac{1}{p_i} \le \log n
$$

移项：

$$
\sum p_i \log \frac{1}{p_i} - \log n \le 0
\Rightarrow \sum p_i \left( \log \frac{1}{p_i} - \log n \right) \le 0
\Rightarrow \sum p_i \log \frac{1}{n p_i} \le 0
$$

注意到：

$$
\sum p_i \log \frac{1}{n p_i} = - \sum p_i \log (n p_i) = - D_{KL}(p \| u)
$$

其中 $u_i = \frac{1}{n}$ 是均匀分布，$D_{KL}$ 是 KL 散度，恒 ≥ 0，所以：

$$
- D_{KL}(p \| u) \le 0 \Rightarrow H(p) \le \log n
$$

等号成立当且仅当 $p = u$，即均匀分布。

---

### 或者直接用 Jensen：

考虑函数 $f(x) = x \log x$，它在 $x > 0$ 上是凸函数。

那么：

$$
\sum_{i=1}^n \frac{1}{n} f(p_i) \ge f\left( \sum_{i=1}^n \frac{1}{n} p_i \right) = f\left( \frac{1}{n} \sum p_i \right) = f\left( \frac{1}{n} \right)
$$

即：

$$
\frac{1}{n} \sum p_i \log p_i \ge \frac{1}{n} \log \frac{1}{n}
\Rightarrow \sum p_i \log p_i \ge \log \frac{1}{n} = -\log n
\Rightarrow -\sum p_i \log p_i \le \log n
$$

✅ 完美！这就是用 Jensen 不等式的标准证明！

---

## 🧠 六、总结 & 回答原问题

> **“这为什么不是 Jensen 不等式直接解决？”**

→ **其实完全可以！而且更简洁优雅！**

作者选择用拉格朗日乘数法，可能是为了：

1. 展示优化方法在信息论中的应用；
2. 让学生练习拉格朗日乘数法；
3. 从“极值点”的角度理解为什么均匀分布使熵最大；
4. 有些课程先讲优化，后讲 Jensen，所以按教学顺序安排。

但从数学上讲，**Jensen 不等式是更直接、更本质的工具**，尤其适用于这类凸/凹函数的期望不等式。

---

## 📚 附：两种方法对比

| 方法             | 优点                          | 缺点                     |
|------------------|-------------------------------|--------------------------|
| 拉格朗日乘数法   | 显示极值点位置，适合教学       | 步骤较多，需微积分基础    |
| Jensen 不等式    | 简洁、深刻、通用性强           | 需要知道函数凸性及不等式 |

---

## ✅ 最终答案：

- 推导过程正确，通过拉格朗日乘数法求出在 $\sum p_i = 1$ 约束下，熵 $H(p)$ 在 $p_i = \frac{1}{n}$ 时取得最大值 $\log n$。
- 旁边的问题很有洞察力：**确实可以用 Jensen 不等式更简单地证明**，只需利用 $f(x) = x \log x$ 的凸性或 $f(x) = -\log x$ 的凸性结合期望即可。
- 教材选用拉格朗日法可能是出于教学目的，但 Jensen 法是更高级、更优雅的解法。

---

如果你还想深入探讨 KL 散度、相对熵、或者连续变量的微分熵，也可以继续问我 😊