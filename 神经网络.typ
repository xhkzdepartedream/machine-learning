#set page(
  paper: "a4",
  margin: (x: 1cm, y: 1cm),
)
#set text(
  font: ("Linux Libertine", "Source Han Serif SC"),
  size: 11pt,
  lang: "zh"
)
#set heading(numbering: "1.")

// 标题
#align(center, text(17pt)[
  *全连接前馈神经网络 (MLP) 计算手册*
])

#v(1em)

= 符号系统与维度定义

假设神经网络共有 $L$ 层（不含输入层），输入层索引为 $0$。

- *层索引*: $l = 1, 2, ..., L$
- *神经元数量*: 第 $l$ 层有 $n_l$ 个神经元。
- *输入向量*: $a^((0)) in RR^(n_0 times 1)$

#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: horizon,
  [*符号*], [*含义*], [*形状 (Shape)*],
  
  $W^((l))$, [第 $l$ 层权重矩阵], [$(n_l, n_(l-1))$],
  $b^((l))$, [第 $l$ 层偏置向量], [$(n_l, 1)$],
  $z^((l))$, [第 $l$ 层线性输出], [$(n_l, 1)$],
  $a^((l))$, [第 $l$ 层激活输出], [$(n_l, 1)$],
  $sigma(dot)$, [激活函数 (逐元素)], [N/A]
)

= 前向传播 (Forward Propagation)

对第 $l = 1, 2, ..., L$ 层依次计算：

== 线性变换
利用矩阵乘法计算加权和：
$ z^((l)) = W^((l)) a^((l-1)) + b^((l)) $
_注意：$W^((l))$ 的行数决定了当前层的输出维度。_

== 非线性激活
$ a^((l)) = sigma(z^((l))) $
_注意：激活函数 $sigma$ 逐元素 (Element-wise) 作用于向量 $z^((l))$ 的每个分量。_

= 反向传播 (Backpropagation)

核心利用链式法则。定义*误差项 (Error Term)* $delta^((l))$ 为损失函数 $cal(L)$ 对线性输出 $z^((l))$ 的梯度：
$ delta^((l)) := (partial cal(L)) / (partial z^((l))) $

== 输出层误差 ($l=L$)
$ delta^((L)) = nabla_(a^((L))) cal(L) dot.o sigma'(z^((L))) $

*说明*:
- $nabla_(a^((L))) cal(L)$: 损失函数对最终预测值的导数（例如 MSE 损失下为 $a^((L)) - y$）。
- $dot.o$: Hadamard 积（逐元素乘法）。
- $sigma'(z^((L)))$: 输出层激活函数的导数。

== 隐藏层误差 ($l = L-1, ..., 1$)
将误差从后一层传回当前层：
$ delta^((l)) = (W^((l+1)))^T delta^((l+1)) dot.o sigma'(z^((l))) $

*注意*:
- 必须使用后一层权重的*转置* $(W^((l+1)))^T$。
- 同样需要乘以当前层的激活导数 $dot.o sigma'(z^((l)))$。

= 参数梯度计算

获得误差项 $delta^((l))$ 后，直接计算梯度：

== 权重梯度
$ (partial cal(L)) / (partial W^((l))) = delta^((l)) (a^((l-1)))^T $
_形状检查：$(n_l, 1) times (1, n_(l-1)) -> (n_l, n_(l-1))$，与 $W^((l))$ 一致。_

== 偏置梯度
$ (partial cal(L)) / (partial b^((l))) = delta^((l)) $

= 参数更新 (梯度下降)

设定学习率为 $eta$：
$ W^((l)) arrow.l W^((l)) - eta (partial cal(L)) / (partial W^((l))) $
$ b^((l)) arrow.l b^((l)) - eta (partial cal(L)) / (partial b^((l))) $

= 批量 (Batch) 计算扩展

若 Batch Size 为 $m$，输入矩阵 $X$ 形状为 $(n_0, m)$。

1. *前向传播 (广播机制)*:
   $ Z^((l)) = W^((l)) A^((l-1)) + b^((l)) bold(1)^T $
   其中 $b^((l))$ 会自动广播至 $m$ 列。

2. *反向传播 (平均梯度)*:
   $ (partial cal(L)) / (partial W^((l))) = 1/m Delta^((l)) (A^((l-1)))^T $
   $ (partial cal(L)) / (partial b^((l))) = 1/m sum_(i=1)^m Delta^((l))_( :, i) $

= 常用激活函数导数表

在此框架下，只需替换 $sigma'(z)$ 即可：

#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: horizon,
  [*激活函数*], [*$sigma(z)$*], [*导数 $sigma'(z)$*],
  
  [Sigmoid], [$1 / (1 + e^(-z))$], [$a^((l)) dot.o (1 - a^((l)))$],
  [Tanh], [$(e^z - e^(-z)) / (e^z + e^(-z))$], [$1 - (a^((l)))^2$],
  [ReLU], [$max(0, z)$], [$1 "if" z > 0 "else" 0$]
)