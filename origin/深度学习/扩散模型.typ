#import"../../notes.typ":*
#show:notes

== 扩散模型

=== 基本概念
设$x_0$为数据样本，$x_T$为随机噪声，假设扩散过程需要$T$步，整个过程可以表示为
$
  x=x_0 -> x_1 -> x_2 -> dots->x_(T-1)->x_T=z
$

DDPM把拆解的过程建模为：
$
  x_t=alpha_t x_(t-1)+beta_t epsilon_t, #h(2em)epsilon_t tilde.op N(0,I)
$<diffusion_base>
其中有$alpha_t,beta_t>0, alpha_t^2+beta_t^2=1$,$beta_t$通常接近于0，代表着单步扩散对原样本的破坏程度。噪声$epsilon_t$的引入则是对于原始信号的一种破坏。

#remark[
  这里的$alpha$与$beta$的定义与原论文不同。
]

反复执行上面的迭代过程我们可以得到：
$
  x_t
  &=alpha_t x_(t-1)+beta_t epsilon_t\
  &=alpha_t (alpha_(t-1) x_(t-2)+beta_(t-1)epsilon_(t-1))+beta_t epsilon_t\
  &=dots\
  &=(alpha_t dots alpha_1)x_0+(alpha_t dots alpha_2)beta_1 epsilon_1+(alpha_t dots alpha_3)beta_2 epsilon_2+dots+alpha_t beta_(t-1)epsilon_(t-1)+beta_t epsilon_t 
$<diffusion_expansion>

后面$t$项是多个相互独立的正态噪声之和，均值为0，方差为各方差之和。由于$alpha_t^2+beta_t^2=1$, 我们就会发现中@eqt:diffusion_expansion 的各项系数的平方和依然是1，即:
$
  (alpha_t dots alpha_1)^2+(alpha_t dots alpha_2)^2beta^2_1+(alpha_t dots alpha_3)^2beta^2_2+dots+alpha_t^2 beta^2_(t-1)+beta^2_t=1
$
所以实际上有
$
  x_t=(alpha_t dots alpha_1)x_0+sqrt(1-(alpha_t dots alpha_1)^2)macron(epsilon)_t eq.delta macron(alpha)_t x_0+macron(beta)_t macron(epsilon)_t,#h(1em)macron(epsilon)_t tilde.op N(0,I)
$<diffusion_recursion>
#remark[
  这为计算$x_t$带来了极大的便利性，另一方面DDPM会选择适当的$alpha_t$形式，使得有$macron(alpha)_T approx 0$，这意味着经过$T$步扩散后，原始数据样本完全转化为随机噪声。
]

扩散是$x_(t-1)->x_t$的过程，这样我们得到许多数据对$(x_(t-1),x_t)$，那么生成就需要从这些数据对中学习一个$x_t->x_(t-1)$的模型，记为$mu(x_t)$, 我们容易想到学习方案就是最小化两者的欧式距离：
$
  norm(x_(t-1)-mu(x_t))^2
$
接下来我们还需要做进一步地细化，首先由@eqt:diffusion_base 可以改写为$x_(t-1)=1/alpha_t (x_t-beta_t epsilon_t)$，这启发我们可以把$mu(x_t)$设计成
$
  mu(x_t)=1/alpha_t (x_t-beta epsilon_theta (x_t,t))
$<diffusion_generate>
的形式，其中$theta$是训练参数，带入损失函数得到
$
  norm(x_(t-1)-mu(x_t))^2=frac(beta_t^2,alpha_t^2)norm(epsilon_t-epsilon_theta (x_t,t))^2
$
前面的因子$frac(beta_t^2,alpha_t^2)$代表loss权重，这里暂时忽略，结合@eqt:diffusion_base 和 @eqt:diffusion_recursion 可以得到$x_t$的表达式
$
  x_t=macron(alpha)_t x_0+alpha_t macron(beta)_(t-1)macron(epsilon)_(t-1)+beta_t epsilon_t
$

得到损失函数形式
$
  norm(epsilon_t-epsilon_theta (macron(alpha)_t x_0+alpha_t macron(beta)_(t-1)macron(epsilon)_(t-1)+beta_t epsilon_t, t))^2
$<diffusion_loss1>

#note[
  注意这里不能用@eqt:diffusion_recursion 来给出$x_t$，这是因为我们事先采样了$epsilon_t$，就不能再独立地采样$macron(epsilon)_t$了，因为这二者是不独立的。
]

=== 降低方差
实际上，通过@eqt:diffusion_loss1 就可以进行DDPM的训练了，但是这在实践中存在方差过大的风险，从而导致收敛过慢。而实际上@eqt:diffusion_loss1 包含了4个需要采样的随机变量：

+ 从所有训练样本中采样一个$x_0$
+ 从正态分布$N(0,I)$中采样$macron(epsilon)_(t-1), epsilon_t$;
+ 从$1 tilde.op T$中采样一个$t$.

要采样的随机变量越多，就越难对损失函数做准确的估计，反过来说就是每次对损失函数进行估计的波动（方差）过大了。很幸运的是，我们可以通过一个积分技巧来将$macron(epsilon)_(t-1), epsilon_t$合并成单个正态随机变量，从而缓解一下方差大的问题。

我们知道$alpha_t macron(beta)_(t-1)macron(epsilon)_(t-1)+beta_t epsilon_t$实际上相当于单个随机变量$macron(beta)_t epsilon|epsilon tilde.op N(0,I)$, 同理$beta_t macron(epsilon)_(t-1)-alpha_t macron(beta)_(t-1)epsilon_t$实际上相当于单个随机变量$macron(beta)_t w|w tilde N(0,I)$, 并且可以验证$EE[epsilon w^T]=0$, 所以这是两个相互独立的正态随机变量。

#proof[

  计算随机变量$A=alpha_t macron(beta)_(t-1)macron(epsilon)_(t-1)+beta_t epsilon_t$和$B=beta_t macron(epsilon)_(t-1)-alpha_t macron(beta)_(t-1)epsilon_t$的协方差，由于$macron(epsilon)_(t-1)$和$epsilon_t$相互独立，且均服从标准正态分布$N(0,I)$，我们有：
  $
    EE[A B^T]=EE[(alpha_t macron(beta)_(t-1)macron(epsilon)_(t-1)+beta_t epsilon_t)(beta_t macron(epsilon)_(t-1)-alpha_t macron(beta)_(t-1)epsilon_t)^T]
  $
  展开乘积并利用期望的线性性质：
  $
    EE[A B^T]=alpha_t macron(beta)_(t-1) beta_t EE[macron(epsilon)_(t-1)macron(epsilon)^T_(t-1)]-alpha_t^2 macron(beta)^2_(t-1)EE[macron(epsilon)_(t-1)epsilon_t^T]+beta_t^2 EE[epsilon_t macron(epsilon)_(t-1)^T]-beta_t alpha_t macron(beta)_(t-1) EE[epsilon_t epsilon_t^T]
  $
  由于$macron(epsilon)_(t-1)$和$epsilon_t$独立，所以$EE[macron(epsilon)_(t-1)epsilon_t^T]=EE[epsilon_t macron(epsilon)_(t-1)^T]=0$, 而且有$EE[macron(epsilon)_(t-1)macron(epsilon)^T_(t-1)]=EE[epsilon_t epsilon_t^T]=I$, 代入得：
  $
    EE[A B^T]=alpha_t macron(beta)_(t-1) beta_t I - beta_t alpha_t macron(beta)_(t-1) I=0
  $
  因此$A$和$B$的协方差矩阵为0，所以
  $
    EE[epsilon w^T]=1/macron(beta)^2_t EE[A B^T]=0
  $
  $A$和$B$均是独立正态随机变量$macron(epsilon)_(t-1)$和$epsilon_t$的线性组合，因此$(A,B)$服从联合正态分布。对于联合正态分布的随机向量，协方差矩阵为0等价于两者独立，所以$epsilon$和$w$是相互独立的。
]

接下来我们反过来将$epsilon_t$用$epsilon,w$重新表示出来
$
  epsilon_t=frac((beta_t epsilon-alpha_t macron(beta)_(t-1)w)macron(beta)_t, beta_t^2+alpha^2_t macron(beta)_(t-1)^2)=frac(beta_t epsilon-alpha_t macron(beta)_(t-1)w, macron(beta)_(t))
$
#note[
  在实际训练中，我们是固定$x_0$和$t$，随机采样噪声$macron(epsilon)_(t-1)$和$epsilon_t$，构造出$x_(t-1)$和$x_t$，然后计算损失，不断重复采样，求平均损失。这里求平均损失的过程，在数学上我们用期望表示。
]

带入@eqt:diffusion_loss1 得到
$
  &EE_(macron(epsilon)_(t-1),epsilon_t tilde.op N(0,I))[norm(epsilon_t-epsilon_theta (macron(alpha)_t x_0+alpha_t macron(beta)_(t-1)macron(epsilon)_(t-1)+beta_t epsilon_t, t))^2]\
  =&EE_(w,epsilon tilde.op N(0,I))[norm(frac(beta_t epsilon-alpha_t macron(beta)_(t-1)w, macron(beta)_(t))-epsilon_theta (macron(alpha)_t x_0+macron(beta)_t epsilon,t))^2]
$
注意到，现在损失函数关于关于$w$是二次的，所以可用展开后把期望算出来，结果是
$
  beta_t^2/macron(beta)_t^2 EE_(epsilon tilde.op N(0,I)) [norm(epsilon-macron(beta)_t/beta_t epsilon_theta (macron(alpha)_t x_0+macron(beta)_t epsilon, t))^2]+"常数"
$
#note[
  这里面我们要训练的参数是$theta$(通常是Unet的参数)，而$alpha_t$和$beta_t$都是通过超参数或预定义函数处理的，不需要训练，因而他们在损失函数计算中被当作常数。

  在满足$alpha_t^2+beta_t^2=1$的前提下，常见的集中调度策略是：

  1. 线性调度(DDPM 原论文)
  $
    beta_t=10^(-4)+(t-1)/(T-1)(0.02-10^(-4))
  $
  2. 余弦调度
  $
    macron(alpha)_t=frac(cos(frac(t/T+0.008,1.008)dot pi/2), cos(0.008/1.008 dot pi/2))
  $
  #h(2em)再通过$macron(alpha)_t=product_(s=1)^(t)alpha_s$反推出$alpha_t$
  3. 平方根调度
  $
    alpha_t=sqrt(1-(t/T)^p)
  $
  其中$p$是超参数，通常取$p=1$或$2$.
]

我们省略常数和损失函数的权重，得到DDPM的损失函数：
$
  norm(epsilon-macron(beta)_t/beta_t epsilon_theta (macron(alpha)_t x_0+macron(beta)_t epsilon, t))^2
$

#remark[
  这里对于$epsilon$是在进行蒙特卡洛估计，会使用较大的批次来计算整体的期望。
]

=== 递归生成

训练完之后，我们可以从一个随机噪声$x_T tilde.op N(0,I)$出发执行$T$步@eqt:diffusion_generate 来进行生成：
$
  x_(t-1)=1/alpha_t (x_t - beta_t epsilon_theta (x_t, t))
$

这对应于自回归解码中的Greedy Search。如果要进行Random Sample，那么需要补上噪声项：
$
  x_(t-1)=1/alpha_t (x_t-beta_t epsilon_theta(x_t,t))+sigma_t z, #h(2em)z tilde N(0,I)
$
一般来说，我们可以让$sigma_t=beta_t$, 即正向和反向的方差保持同步。这个采样过程跟传统扩散模型的朗之万采样不一样的地方在于：DDPM的采样每次都从一个随机噪声出发，需要重复迭代$T$步来得到一个样本输出. DDPM的一大缺点就是采样速度慢，后面有很多工作都致力于提升DDPM的采样速度。

=== 贝叶斯视角

正向就是将样本数据$x$逐渐变为随机噪声$z$的过程，反向就是将随机噪声$z$逐渐变为样本数据$x$的过程，反向过程就是我们希望得到的“生成模型”。正向过程的每一步都是@eqt:diffusion_base , 其实这也可以看作是求$p(x_t|x_(t-1))$的过程。

根据贝叶斯定理有：
$
  p(x_(t-1)|x_t)=(p(x_t|x_(t-1))p(x_(t-1)))/(p(x_t))
$
而我们并不知道$p(x_t), p(x_(t-1))$的表达式，所以我们只能在给定$x_0$的条件下使用贝叶斯定理：
$
  p(x_(t-1)|x_t,x_0)=(p(x_t|x_(t-1))p(x_(t-1)|x_0))/(p(x_t|x_0))
$
而我们已知
$
  p(x_t|x_(t-1))=N(x_t;alpha_t x_(t-1), beta^2_t I)\
  p(x_(t-1)|x_0)=N(x_(t-1);macron(alpha)_(t-1)x_0, macron(beta)_(t-1)^2 I)\
  p(x_t|x_0)=N(x_t;macron(alpha)_t x_0, macron(beta)_t^2 I)
$

所以有
$
  p(x_(t-1)|x_t,x_0) prop frac(exp(-norm(x_t-alpha_t x_(t-1))^2/(2 beta_t^2)) dot exp(-norm(x_(t-1)-macron(alpha)_(t-1) x_(0))^2/(2 beta_(t-1)^2)),exp(-(norm(x_t-macron(alpha)_t x_0)^2)/(2 beta_t^2)))
$
由于分母的指数项不含$x_(t-1)$，我们只需要关注分子的指数部分。
$
  -1/2[norm(x_t-alpha_t x_(t-1))^2/( beta_t^2) + norm(x_t-macron(alpha)_t x_0)^2/( beta_t^2)]+"常数"
$
展开平方项并合并得到：
$
  -1/2 [alpha_t^2/beta_t^2+1/beta_(t-1)^2]x_(t-1)^T x_(t-1) + [alpha_t/beta^2_t x_t^T + macron(alpha)_(t-1)/macron(beta)_(t-1)^2 x_0^T]x_(t-1)
$
写成高斯分布的形式：
$
  -1/2 (x_(t-1)-mu)^T Sigma^(-1) (x_(t-1)-mu)
$
其中：
$
  Sigma&^(-1)=(alpha^2_t/beta_t^2+1/macron(beta)_(t-1)^2)I\
  mu=Sigma (alpha_t/beta_t^2 x_t + macron(alpha)_(t-1)/macron(beta)_(t-1)^2)x_0
$
得到：
$
  mu=(alpha_t macron(beta)_(t-1)^2)/beta_t^2 x_t + (macron(alpha)_(t-1) beta_t^2)/macron(beta)_t^2 x_0\
  Sigma=(macron(beta)^2_(t-1)beta_t^2)/macron(beta)^2_t I
$
所以有
$
  p(x_(t-1)|x_t,x_0)=N(x_(t-1);(alpha_t macron(beta)_(t-1)^2)/beta_t^2 x_t + (macron(alpha)_(t-1) beta_t^2)/macron(beta)_t^2 x_0, (macron(beta)^2_(t-1)beta_t^2)/macron(beta)^2_t I)
$

我们仍然需要进一步地去掉$x_0$，可以试图用$x_t$来表示$x_0$，这样就可以顺利完成表示了。假设用$macron(mu)(x_t)$表示$x_0$, 损失函数为$norm(x_0-macron(mu)(x_t))^2$, 训练完后我们就认为
$
  p(x_(t-1)|x_t) approx p(x_(t-1)|x_t, x_0=macron(mu)(x_t))
$
这个$macron(mu)$，实现了从带噪数据$x_t$到原始数据$x_0$的转换，所以是一个去噪模型(Denoising), 这就是DDPM的第一个D的含义。
我们只需要将$macron(mu)(x_t)$参数化为
$
  macron(mu)(x_t)=1/macron(alpha)_t (x_t-macron(beta)_t epsilon_theta (x_t,t))
$
#remark[
  此时的$epsilon_theta$与前面的不一样，但是与原论文保持了一致。
]
损失函数变为
$
  norm(x_0-macron(mu)(x_t))^2=macron(beta)_t^2/macron(alpha)_t^2 norm(epsilon_t-epsilon_theta_theta (macron(alpha)_t x_0 + macron(beta)_t epsilon, t))^2
$
省略前面的系数，就是最终的损失函数了。另外我们也可以得到：
$
  p(x_(t-1)|x_t) approx p(x_(t-1)|x_t, x_0=macron(mu)(x_t))=N(x_(t-1);1/alpha_t (x_t-beta_t^2 / macron(beta_t) epsilon_theta (x_t,t)), (macron(beta)^2_(t-1)beta_t^2)/macron(beta)^2_t I)
$
#note[
  特别注意，
  $
    (alpha_t macron(beta)_(t-1)^2)/beta_t^2 + (macron(alpha)_(t-1) beta_t^2)/(macron(alpha)_t macron(beta)_t^2) =1/alpha_t
  $
]
这就是反向的采样过程所用的分布，连同采样过程所用的方差也一并确定下来了。
