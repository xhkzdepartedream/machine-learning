#import"../../notes.typ":*
#show:notes


== 逻辑斯蒂回归与最大熵模型

=== 逻辑斯蒂回归模型/对数几率回归分类器

逻辑斯蒂回归是统计学习中的经典分类方法，最大熵是概率模型学习的一个准则，将其推广到分类问题得到最大熵模型。*逻辑斯蒂回归模型与最大熵模型都属于对数线性模型。*模型学习就是在给定的训练数据条件下对模型进行极大似然估计或正则化的极大似然估计。

#remark[
  有时会简称为逻辑模型，但“逻辑”是音译“逻辑斯蒂（logistic）”的缩写，并不是说这个算法具有怎样的逻辑性。
]

比方说广告投入金额$x$和销售量$y$的关系，散点图如下，这种情况适用一元线性回归。但在许多实际问题中，因变量$y$是分类型，只取0、1两个值。如果用阶跃函数来拟合往往效果不错，但是这并不是一个连续函数。*理想的情况，是像线性回归的函数一样，X和Y之间的关系，是用一个可导的函数来描述的。*


我们试图用一个模型，他输入是$x in R^n$，而输出是$y in {0,1}$。这里其实输出的是$P(Y=0|x)$和$P(Y=1|x)$，如果沿用线性回归模型，会发现他的值域是$(-infinity,+infinity)$，而概率则是$(0,1)$上的。我们首先定义*几率*为发生的概率与不发生的概率的商。即对于概率为$p$的几率为$p/(1-p)$，这样范围就变成了$(0,+infinity)$，再对这个式子取对数得到*对数几率*或*logic函数*是：
$
  "logic"(p)=log p/(1-p)
$
这样取值范围就变成$(-infinity,+infinity)$了，这里就引入最关键的假设：
#note[
  *特征 $X$的线性组合$X beta$(或者$w dot x + b$的形式)，正好等于这个“对数几率”​。*
]

再根据这个假设我们反解出$P$:
$
  P=1/(1+e^(-X beta))
$
#remark[
而这个其实就是我们常见的Sigmoid函数了。
]

#definition[
  二阶逻辑斯蒂回归模型是如下条件的概率分布：
  $
    P(Y=1|x)&=frac(exp(w dot x+b),1+exp(w dot x+b))\
    P(Y=0|x)&=1-P(Y=1|x)
  $
  这里，$x in R^n$是输入，$Y in {0,1}$是输出，$w in R^n$和$b in R$是参数，$w$称为权值向量，$b$称为偏置，$w dot x$为$w$和$x$的内积。
]
对于给定训练数据集$T={dots(x_i,y_i)dots}x_i in R^n, y_i in {0,1}$，可以应用极大似然估计法估计模型参数，从而得到逻辑斯蒂回归模型。设
$
  P(Y=1|x)=pi(x),#h(2em)P(Y=0|x)=1-pi(x)
$
似然函数为
$
  product_(i=1)^N (pi(x_i))^(y_i)(1-pi(x_i))^(1-y_i)
$
对数似然函数为
$
  L(w)&=sum_(i=1)^N [y_i log pi(x_i)+(1-y_i) log(1-pi(x_i))]\
  &=sum_(i=1)^N [y_i log frac(pi(x_i), 1-pi(x_i))+log(1-pi(x_i))]\
  &=sum_(i=1)^N {y_i (w dot x_i)-log[1+exp(w dot x_i)]}
$
对$L(w)$求极大值，得到$w$的估计值$hat(w)$。这样问题变成了以对数似然函数为目标函数的最优化问题。逻辑斯蒂回归学习中通常采用的方法是*梯度下降法*和*拟牛顿法*。

负对数似然函数定义为：
$
  J(w)=-L(w)=-sum_(i=1)^N y_i (w dot x_i)-log[1+exp(w dot x_i)]
$
所以有:
$
  nabla J(w)=(partial J(w))/(partial w)=sum_(i=1)^N x_i (pi(x_i)-y_i)
$
$pi(x_i)=1/(1+exp(-w dot x_i))$是逻辑函数，表示样本$x_i$属于正类的概率。

梯度下降法具体的更新公式为：
$
  w^((k+1))=w^((k))-alpha nabla J(w^((k)))=w^((k))-alpha sum_(i=1)^N x_i (pi(x_i)-y_i)
$
其中$pi(x_i)$使用当前参数$w^((k))$计算。

在实际应用中，常使用随机梯度下降（SGD）或小批量梯度下降以提高计算效率。SGD每次使用一个样本更新：
$
  w^((k+1))=w^((k))-alpha x_i (pi(x_i)-y_i)
$
- 特征标准化可以加速收敛。
- 学习率$alpha$可能需要调整，如使用学习率衰减策略。

也可以将问题进一步推广到多项逻辑斯蒂回归模型中，用于多类分类。假设离散型随机变量$Y$的取值集合是${1,2,dots,K}$，那么多项逻辑斯蒂回归模型是：
$
  P(Y=k|x)&=frac(exp(w_k dot x),1+sum_(k=1)^(K-1) exp(w_k dot x)),#h(2em) k=1,2,dots,K-1\
  P(Y=K|x)&=frac(1,1+sum_(k=1)^(K-1) exp(w_k dot x)),#h(2em) k=K
$
这里，$x in R^(n+1), w_k in R^(n+1)$

这个其实就是softmax函数。将各个输出节点的输出值范围映射到[0, 1]，并且约束各个输出节点的输出值的和为1。

#remark[
  hardmax最大的特点就是只选出其中一个最大的值，即非黑即白。但是往往在实际中这种方式是不合情理的，比如对于文本分类来说，一篇文章或多或少包含着各种主题信息，我们更期望得到文章对于每个可能的文本类别的概率值（置信度），可以简单理解成属于对应类别的可信度。所以此时用到了soft的概念，Softmax的含义就在于不再唯一的确定某一个最大值，而是为每个输出分类的结果都赋予一个概率值，表示属于每个类别的可能性。
]

指数函数曲线呈现递增趋势，最重要的是斜率逐渐增大，也就是说在x轴上一个很小的变化，可以导致y轴上很大的变化。这种函数曲线能够将输出的数值拉开距离。经过使用指数形式的Softmax函数能够将差距大的数值距离拉的更大。在深度学习中通常使用反向传播求解梯度进而使用梯度下降进行参数更新的过程，而指数函数在求导的时候比较方便。($(e^x)^prime=e^x$)

当使用Softmax函数作为输出节点的激活函数的时候，一般使用交叉熵作为损失函数。由于Softmax函数的数值计算过程中，很容易因为输出节点的输出值比较大而发生数值溢出的现象，在计算交叉熵的时候也可能会出现数值溢出的问题。现在可以构建比较复杂的神经网络模型，最重要的原因之一得益于反向传播算法。反向传播算法从输出端也就是损失函数开始向输入端基于链式法则计算梯度，然后通过计算得到的梯度，应用梯度下降算法迭代更新待优化参数。这样对于softmax函数求导就至关重要了。

这里我们把softmax函数形式记为
$
  "Softmax"(z_i)=e^(z_i)/(sum_(c=1)^C e^(z_c))eq.delta p_i
$
对于$z_i$对应的输出$y_i$, 会受到$z_1,z_2,dots,z_i,dots,z_C$的影响，需要分别求出对于每个$z_j$的偏导数。显然对于$j=i$情况下的偏导数$(partial y_i)/(partial z_i)$与$j eq.not i$的其他情况是不一样的。所以需要分情况讨论。最终答案为：
$
  (partial y_i)/(partial z_j)=cases(
    p_i (1-p_j) #h(1em)&j=i,
    -p_j dot p_i&j eq.not i
  )
$

#algorithm[逻辑斯蒂回归模型][
  *输入*：训练数据集 $T={(x_1,y_1),(x_2,y_2),dots,(x_N,y_N)}$，其中 $x_i in R^n, y_i in {0,1}$；学习率 $alpha$；最大迭代次数 $K$ 或收敛阈值 $epsilon$。

  *输出*：模型参数 $w$ 和 $b$。

  + *数据预处理*：
    为了计算方便，将权重向量和输入向量加以扩充。令 $hat(w)=(w^T, b)^T$，对每个样本令 $hat(x)_i=(x_i^T, 1)^T$。
    此时模型简化为 $P(Y=1|x) = pi(hat(x)) = frac(1, 1+e^(-hat(w) dot hat(x)))$。

  + *初始化*：
    选择初始权重 $hat(w)^((0))$（通常初始化为零向量或微小的随机向量），设置迭代计数器 $k=0$。

  + *迭代优化*：
    重复以下步骤，直到满足停止条件（如梯度模长 $norm(nabla J(hat(w))) < epsilon$ 或 $k >= K$）：
    
    - *计算预测概率*：对于所有 $i=1,dots,N$，利用当前参数计算：
      $ pi(hat(x)_i) = frac(1, 1 + exp(-hat(w)^((k)) dot hat(x)_i)) $
      
    - *计算梯度*：基于负对数似然函数计算梯度（批量梯度）：
      $ nabla J(hat(w)^((k))) = sum_(i=1)^N (pi(hat(x)_i) - y_i) hat(x)_i $
      
    - *更新参数*：沿负梯度方向更新权重：
      $ hat(w)^((k+1)) = hat(w)^((k)) - alpha nabla J(hat(w)^((k))) $
      
    - *更新计数*：$k arrow.l k + 1$

  + *输出结果*：
    得到最终参数 $hat(w)^*$，将其拆分为权值向量 $w^*$ 和偏置 $b^*$，构建最终分类模型：
    $ f(x) = cases(1 & "if " P(Y=1|x) > 0.5, 0 & "otherwise") $
]


=== 最大熵模型
假设离散随机变量$X$的概率分布是$P(X)$，我们前面介绍过其熵是$H(P)=-sum_x P(x)log P(x)$且有不等式$0 lt.eq.slant H(P) lt.eq.slant log |X|$成立。$|X|$表示$X$的取值个数。当且仅当$X$满足均匀分布的时候，右边的等号成立，即$X$服从均匀分布时，熵最大。
#note[
  最大熵原理认为要选择的概率模型首先必须满足已有的约束条件，在没有更多信息的情况下，*那些不确定的部分都是等可能的*。最大熵原理通过熵的最大化来表示等可能，形而上的“等可能”不容易实现，但是熵可以作为一个数值指标。
]

假设分类模型是一个条件概率分布$P(Y|X)$，$X in cal(X) subset.eq R^n$表示输入，$Y in cal(Y)$表示输出，$cal(X)$和$cal(Y)$表示输入和输出的集合。这个模型表示的是对于给定的输入$X$，以条件概率$P(Y|X)$输出$Y$。

给定一个训练数据集$T$，*学习的目标是用最大熵原理选择最好的分类模型*。首先考虑模型应该满足的条件，给定训练数据集，可以确定联合分布$P(X,Y)$的经验分布和边缘分布$P(X)$的经验分布，分别以$tilde(P)(X,Y)$和$tilde(P)(X)$表示。这里计算其实就是古典概型中的频率计算。

用特征函数$f(x,y)$描述输入$x$和输出$y$之间的某一个事实。定义是：
$
  f(x,y)=cases(
    1 #h(2em)&x"与"y"满足某一事实",
    0 &"otherwise"
  )
$
特征函数$f(x,y)$关于经验分布$tilde(P)(x,y)$的期望值用$E_(tilde(P))(f)$表示，而关于模型$P(Y|X)$与经验分布$tilde(P)(X)$的期望值用$E_P (f)$表示。如果模型能够获取训练数据中的信息，那么就可以假设两个期望相等：
$
  E_p (f)=E_(tilde(P)) (f)
$
即：
$
  sum_(x,y) tilde(P) (x)P(y|x)f(x,y)=sum_(x,y)tilde(P)(x,y)f(x,y)
$
#remark[
  这就是模型学习的约束条件。加入有$n$个特征函数$f_i (x,y),i=1,2,dots,n$，那么就有$n$个约束条件。
]

#definition[

假设满足所有约束条件的模型集合为
$
  cal(C)eq.triple{P in cal(P)|E_P (f_i)=E_(tilde(P))(f_i),i=1,2,dots,n}
$
定义在条件概率分布$P(X|Y)$上的条件熵为：
$
  H(P)=-sum_(x,y)tilde(P)(x)P(y|x)log P(y|x)
$
则模型集合$cal(C)$中条件熵$H(P)$最大的模型称为最大熵模型。
]

#remark[
最大熵模型的学习过程就是求解最大熵模型的过程，最大熵模型的学习可以形式化为约束最优化问题。

]

对于给定的训练数据集$T$以及特征函数$f_i (x,y),i=1,2,dots,n$，最优化问题习惯上把求最大值问题改写为等价求最小值问题：
$
  &min_(P in cal(C))#h(1em)-H(P)=sum_(x,y)tilde(P)(x)P(y|x)log P(y|x)\
  &s.t.#h(1em)E_P(f_i)-E_(tilde(P))(f_i)=0,#h(1em)i=1,2,dots,n\
  &sum_y P(y|x)=1
$

我们将约束最优化的原始问题转换为无约束最优化的对偶问题，通过求解对偶问题求解原始问题。引入拉格朗日乘子$w_0,w_1,dots,w_n$，定义拉格朗日函数$L(P,w)$:
$
  L(P,w)eq.triple -H(P)+w_0(1-sum_y P(y|x))+sum_(i=1)^n w_i (E_(tilde(P))(f_i)-E_P (f_i))
$

最优化原始问题是$min_(P in cal(C))max_w L(P,w)$，对偶问题是$max_w min_(P in cal(C))L(P,w)$.
#remark[
  由于拉格朗日函数$L(P,w)$是$P$的凸函数，所以原始问题的解和对偶问题的解是等价的。
]

首先，求解对偶问题内部的极小化问题，$min_(P in cal(C)) L(P,w)$是$w$的函数，将其记作
$
  Psi(w)=min_(P in cal(C)) L(P,w)=L(P_w,w)
$
$Psi(w)$称为对偶函数，同时将其解记作：
$
  P_w=arg min_(P in cal(C)) L(P,w)=P_w (y|x)
$
具体地，求$L(P,w)$对$P(y|x)$的偏导数：
$
  frac(partial L(P,w),partial P(y|x))&=sum_(x,y)tilde(P)(x)(log P(y|x)+1)-sum_y w_0-sum_(x,y)(tilde(P)(x)sum_(i=1)^n w_i f_i (x,y))\
  &=sum_(x,y)tilde(P)(x)(log P(y|x)+1-w_0-sum_(i=1)^n w_i f_i (x,y))
$
令偏导数为0，在$tilde(P)(x)>0$的情况下，解得：
$
  P(y|x)=exp(sum_(i=1)^n w_i f_i (x,y)+w_0-1)=frac(exp(sum_(i=1)^n w_i f_i (x,y)),exp(1-w_0))
$
由于$sum_y P(y|x)=1$，得：
$
  P_w (y|x)=1/(Z_w (x))exp(sum_(i=1)^n w_i f_i (x,y))
$
其中，
$
  Z_w (x)=sum_y exp(sum_(i=1)^n w_i f_i (x,y))
$
$Z_w (x)$称为规范化因子，$f_i (x,y)$是特征函数，$w_i$是特征的权重。

之后求解对偶问题外部的极大化问题：
$
  max_w Psi(w)
$
其解记作$w^*$，即：
$
  w^*=arg max_w Psi(w)
$
最大熵模型的学习最终归结为对偶函数$Psi(w)$的极大化。
#remark[
  常见方法是对$w_i$分别求偏导令偏导数为0得到答案。
]

#theorem[
  对偶函数的极大化等价于最大熵模型的极大似然估计。
]

#proof[

已知训练数据的经验概率分布$tilde(P) (X,Y)$，条件概率分布$P(Y|X)$的对数似然函数表示为：
$
  L_(tilde(P)) (P_w)=log product_(x,y)tilde(P)(x,y)]^P(y|x)=sum_(x,y) tilde(P)(x,y)log P(y|x)
$
当条件概率分布是最大熵模型时，对数似然函数是：
$
  L_(tilde(P)) (P_w)&=sum_(x,y) tilde(P)(x,y)log P(y|x)\
  &=sum_(x,y)tilde(P) (x,y)sum_(i=1)^n w_i f_i (x,y)-sum_(x,y) tilde(P)(x,y)log Z_w (x)\
  &=sum_(x,y)tilde(P) (x,y)sum_(i=1)^n w_i f_i (x,y)-sum_(x) tilde(P)(x)log Z_w (x)\
$
而对于对偶函数有：
$
  Psi(w)&=sum_(x,y)tilde(P)(x)P_w (y|x)log P_w (y|x)+sum_(i=1)^n w_i (sum_(x,y) tilde(P)(x,y) f_i (x,y)-sum_(x,y)tilde(P)(x)P_w (y|x)f_i (x,y))\
  &=sum_(x,y)tilde(P)(x,y)sum_(i=1)^n w_i f_i (x,y)+sum_(x,y) tilde(P)(x) P_w (y|x)(log P_w (y|x)-sum_(i=1)^n w_i f_i (x,y))\
  &=sum_(x,y)tilde(P)(x,y)sum_(i=1)^n w_i f_i (x,y)-sum_(x,y)tilde(P)(x)P_w (y|x)log Z_w (x)\
  &=sum_(x,y)tilde(P)(x,y)sum_(i=1)^n w_i f_i (x,y)-sum_x tilde(P)(x)log Z_w (x)#h(3em) (sum_y P(y|x)=1)
$

所以有：
$
  Psi(w)=L_ (tilde(P))(P_w)
$
]

可以将最大熵模型写成更一般的形式：
$
  P_w (y|x)=1/(Z_w (x))exp(sum_(i=1)^n w_i f_i (x,y))\
  Z_w (x)=sum_y exp(sum_(i=1)^n w_i f_i (x,y))
$
这里$x in R^n$为输入，$y in {1,2,dots,K}$为输出，$w in R^n$为权重向量，$f_i (x,y),i=1,2,dots,n$为任意实值特征函数。



#algorithm[最大熵模型][
  *输入*：训练数据集 $T={(x_1,y_1),(x_2,y_2),dots,(x_N,y_N)}$；特征函数集合 ${f_1, f_2, dots, f_n}$。

  *输出*：最大熵模型 $P_w (y|x)$，即确定最优参数 $w^*$。

  + *计算经验期望*：
    对于每个特征函数 $f_i (i=1,dots,n)$，根据训练数据计算其关于经验分布的期望值：
    $ E_(tilde(P))(f_i) = sum_(x,y) tilde(P)(x,y) f_i(x,y) = frac(1, N) sum_(j=1)^N f_i(x_j, y_j) $
    这一步只需要计算一次，作为后续优化的目标约束。

  + *初始化参数*：
    初始化权重向量 $w^((0)) = (w_1, w_2, dots, w_n)^T$ (通常设为 0)，设置迭代计数 $k=0$。

  + *迭代优化*：
    重复以下步骤，直到收敛（如参数变化量小于阈值 $epsilon$）：

    - *计算规范化因子*：对于训练集中出现的每个 $x$，计算当前参数下的 $Z_w(x)$：
      $ Z_w(x) = sum_y exp(sum_(i=1)^n w_i f_i(x,y)) $
    
    - *计算模型期望*：基于当前模型 $P_w(y|x)$ 计算特征函数的期望：
      $ E_P(f_i) = sum_(x,y) tilde(P)(x) P_w(y|x) f_i(x,y) = frac(1, N) sum_(j=1)^N sum_y P_w(y|x_j) f_i(x_j, y) $
      其中 $P_w(y|x) = frac(1, Z_w(x)) exp(sum_(i=1)^n w_i f_i(x,y))$。

    - *更新参数*：利用梯度上升法（或 GIS/IIS 算法）更新 $w$。
      对数似然函数的梯度为 $g_i = E_(tilde(P))(f_i) - E_P(f_i)$。
      $ w_i^((k+1)) = w_i^((k)) + alpha dot (E_(tilde(P))(f_i) - E_P(f_i)) $
      （注：若是 GIS/IIS 算法，更新步长会有特定的解析解形式，而非固定学习率 $alpha$）。

  + *输出模型*：
    得到最优参数 $w^*$，输出最终的最大熵模型：
    $ P_(w^*) (y|x) = frac(1, Z_(w^*) (x)) exp(sum_(i=1)^n w_i^* f_i (x,y)) $
]