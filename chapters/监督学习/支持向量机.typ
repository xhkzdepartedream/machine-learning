#import "@local/ysz_tools:0.1.0": *
#show: conf
#import "@preview/cuti:0.4.0":show-cn-fakebold
#show:show-cn-fakebold
#import "@preview/marginalia:0.3.1" as marginalia: note, notefigure, wideblock
#import "@preview/mitex:0.2.6": *
#show: marginalia.setup.with(
  inner: (far: 1mm, width: 1mm, sep: 1mm), //we dont use inner btw
  outer: (far: 5mm, width: 55mm, sep: 8mm),
  top: 2.5cm,
  bottom: 2.5cm,
  book: true,
  clearance: 20pt,
)
#show: marginalia.show-frame
#let a-note-counter = counter("a-note")
#let note = note.with(counter: a-note-counter, numbering: (..i) => text(
  weight: 500,
  font: "JetBrains Mono",
  size: 7pt,
  style: "normal",
  fill: rgb("#ff3a3a"),
  numbering("[a]", ..i),
))
#set page(header: context if here().page() > 0 {
  marginalia.header(
    text-style: (size: 11.5pt, number-type: "old-style"),
    [],
    [#smallcaps[Machine Learning] #text(fill: luma(60%))[_CHAPTER 3_]],
    [Page #counter(page).display("1 of 1", both: true)],
  )
})
#let remark = note
#let appendix(body) = {
  // 1. 重置标题计数器
  counter(heading).update(0)
  
  // 2. 针对附录内部的所有标题设置新格式
  set heading(numbering: "A.1")
  
  // 3. (可选) 如果你希望一级标题显示为 "附录 A. xxx"
  show heading.where(level: 1): it => {
    let nos = counter(heading).at(it.location())
    let letter = numbering("A", ..nos)
    block(sticky: true,[Appendix #letter #it.body])
  }

  body
}
== 支持向量机
支持向量机(support vector machine, SVM)是一种二类分类模型,它的基本模型是定义在特征空间上的*间隔最大*的线性分类器,间隔最大使他有别于感知机；支持向量机还包括核技巧,这使它成为实质上的非线性分类器.

支持向量机的学习策略就是*间隔最大化*,可形式化为一个求解凸二次规划的问题,也等价于正则化的合页损失函数的最小化问题.支持向量机的学习算法是求解凸二次规划的最优化算法.

由简到繁的模型有：线性可分支持向量机(linear SVM in linearly separable case)、线性支持向量机(linear SVM) 以及非线性支持向量机(non-linear SVM).简单模型是复杂模型的基础,也是复杂模型的特殊情况.

当*训练数据线性可分*时,通过硬间隔最大化,学习一个线性可分支持向量机,又称*硬间隔支持向量机*；当*训练数据近似线性可分*时,通过软间隔最大化,也学习一个线性的分类器,即*线性支持向量机*,又称为*软间隔支持向量机*；当*训练数据线性不可分*时,通过使用*核技巧及软间隔最大化*,学习*非线性支持向量机*.

当输入空间为欧式空间或离散集合、特征空间为希尔伯特空间时,核函数表示将输入从输入空间映射到特征空间得到的特征向量之间的内积.通过使用核函数可以学习非线性支持向量机,等价于隐式地在高维的特征空间中学习线性支持向量机.这样的方法称为核技巧.核方法是比支持向量机更为一般的机器学习方法.

=== 线性可分支持向量机与硬间隔最大化
#abstract[
感知机只是为了能够找到正确划分的超平面而已,超平面会有无数个而且对于新样本的划分质量不高,所以评判的标准从*正确划分训练集*变成了*以最大把握划分训练集*,因而提出了*函数间隔和几何间隔*的概念.进一步地,由于间隔值取值本身不影响最优化问题的答案,所以最后得到的优化问题是：
$
  &min_(w,b) 1/2 norm(w)^2 quad,
  &s.t.  y_i (w dot x_i+b) - 1 gt.eq.slant 0, #h(1em)i=1,2,dots,N
$
由此得到分离超平面：
  $
    w^* dot x+b^*=0
  $
分类决策函数：
  $
    f(x)="sign"(w^* dot x+b^*)
  $
进一步地利用拉格朗日对偶性,转化为了：
$
  &min_alpha #h(1em)1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j (x_i dot x_j)-sum_(i=1)^N alpha_i\
  &s.t. #h(1em)sum_(i=1)^N alpha_i y_i =0, alpha_i gt.eq.slant 0,i=1,2,dots,N
$
进而求得原始最优化问题的解$w^*,b^*$:
  $
    w^*=sum_(i=1)^N alpha_i^* y_i x_i\
    b^*=y_j-sum_(i=1)^N alpha_i^* y_i (x_i dot x_j)
  $
]
==== 线性可分支持向量机
考虑一个二分类问题,假设输入空间与特征空间为两个不同的空间,输入空间为欧式空间或离散集合,特征空间为欧式空间或希尔伯特空间.线性可分支持向量机、线性支持向量机假设这两个空间的元素一一对应,并将输入空间中的输入映射为特征空间中的特征向量.非线性支持向量机利用一个从输入空间到特征空间的非线性映射将输入映射为特征向量.所有输入都由输入空间转换到特征空间,支持向量机的学习是在特征空间进行的.
#note[
  输入空间是数据的“原始形式”或“自然状态”,而特征空间是经过精心设计和转换后、更适合机器学习模型理解的“表示形式”.​
]

假设给定一个特征空间上的训练数据集
$
  T={(x_1,y_1),(x_2,y_2),dots,(x_N,y_N)}
$
其中,$x_i in cal(X)=R^n, y_i in cal(Y)={+1,-1},i=1,2,dots,N$. $x_i$为第$i$个特征向量,也称为实例,$y_i$为$x_i$的类标记.当$y_i = +1$时,称$x_i$为正例；否则称为负例.$(x_i,y_i)$称为样本点,*假设训练数据集是线性可分的*.

学习的目标是在特征空间中找到一个分离超平面,能将实例分到不同的类.分离超平面对应于方程$w dot x+b=0$,它由法向量$w$和截距$b$决定,可以用$(w,b)$来表示.分离超平面将特征划分为两部分,一部分是正类,一部分是负类.法向量指向的一侧为正类,另一侧为负类.

一般地,当训练数据集线性可分时,存在无穷个分离超平面可将两类数据正确分开.感知机利用误分类最小的策略求得分离超平面,但是这样的解是无穷多个；线性可分支持向量机采用间隔最大化求最优分离超平面,这时解唯一.
#remark[
这里来讲讲*希尔伯特空间*是指什么.

+ *线性空间*：定义了加法和数乘,空间里的一个元素就可以由其他元素线性表出.
+ *度量空间*：一个定义了距离的空间我们把它成为度量空间,而距离的定义需要满足:
  - 非负性、同一性.$d(x,y) gt.eq.slant 0$当且仅当$x=y$时取等号;
  - 对称性：$d(x,y)=d(y,x)$
  - 三角不等式：$d(x,z)lt.eq.slant d(x,y)+d(y,z)$
+ *赋范空间*：赋范空间就是定义了范数的空间.而范数的定义要满足：
  - 非负性：$norm(x)gt.eq.slant 0$
  - 数乘性：$norm("ax")=|a|norm(x)$
  - 三角不等式：$norm(x+y) lt.eq.slant norm(x)+norm(y)$
  可以发现,有了范数一定能利用范数定义距离,但是有距离不能定义范数.
+ *线性赋范空间*：如题,线性,而且要有范数.
+ *巴拿赫空间*：就是完备的赋范空间,即：如果一个空间是完备的,那么该空间中的任何一个柯西序列都收敛在该空间之内.柯西序列就是随着序数增加,值之间的距离越来越小的序列.（其实就是学高数的时候柯西判别数列收敛的方法）完备要求,其实就隐含了有*距离*的概念.所以巴拿赫空间满足距离、范数、完备.
+ *内积空间*：在一个线性空间上定义了内积运算的空间.定义了内积才能定义角度,定义正则.内积运算需要满足：
  - 严格正定性：$(x,y) gt.eq.slant 0$,等号成立当且仅当$x=0$
  - 共轭对称性：$(x,y)=overline((y,x))$
  - 对第一变量线性：$("ax"+"bz",y)=a(x,y)+b(z,y)$（等价于对第二变量共轭线性）
+ *欧式空间*：日常空间,定义了内积的有限维实线性空间.
+ *希尔伯特空间*：完备的内积空间.希尔伯特空间中的元素一般是函数,因为一个函数可以视为一个无穷维的向量.这个空间的基底就是一组无限多的函数.
+ *再生核希尔伯特空间*：核技巧将不能线性可分的数据集映射到高维空间,使其变得线性可分.我们定义了一种核函数（例如径向基函数）,就定义了一个希尔伯特空间,而这个核函数的再生性使得我们可以不去计算高维特征空间中的內积,而只需计算核函数,降低了大量的计算量.
]

#definition("线性可分支持向量机")[
  给定线性可分训练数据集,通过间隔最大化或等价地求解相应的凸二次规划问题学习得到的分离超平面为：
  $
    w^* dot x+b^*=0
  $
  以及对应的分类决策函数
  $
    f(x)="sign"(w^* dot x + b^*)
  $
  称为线性可分支持向量机.
]

下面我们来叙述有关间隔最大与相应约束最优化的问题.
==== 函数间隔和几何间隔
一般来说,一个点距离分离超平面的远近可以表示分类预测的确信程度.在超平面$w dot x+b=0$确定的情况下,$|w dot x+b|$能够相对地表示*点$x$距离超平面的远近*.而$w dot x+b$的符号和类标记$y$的符号是否一致能够表示*分类是否正确*,所以可用量$y(w dot x+b)$来表示分类的正确性及确信度,这就是*函数间隔(functional margin)*的概念.



#definition("几何间隔")[
  #note[#definition("函数间隔")[
  对于给定的训练数据集$T$和超平面$(w,b)$,定义超平面$(w,b)$关于样本点$(x_i,y_i)$的函数距离为：
  $
    hat(gamma_i)=y_i (w dot x_i + b)
  $
  定义超平面$(w,b)$关于训练数据集$T$的函数间隔为超平面$(w,b)$关于$T$中所有样本点$(x_i,y_i)$的函数间隔之最小值,即：
  $
    hat(gamma)=min_(i=1,2,dots,N)hat(gamma_i)
  $
]

但选择超平面时,只有函数间隔还不够.因为只要成比例地改变$w$和$b$,超平面并不会改变,而函数间隔却变成了两倍,因而要对$w,b$进行规范化,这时函数间隔就变成了几何间隔(geometric margin).]对于给定训练数据集$T$和超平面$(w,b)$,定义超平面$(w,b)$关于样本点的几何间隔为
  $
    gamma_i=y_i (w/norm(w)dot x_i+b/norm(w))
  $
  定义超平面$(w,b)$关于训练数据集$T$的几何间隔为超平面$(w,b)$关于$T$中所有样本点$(x_i,y_i)$的几何间隔之最小值,即：
  $
    gamma=min_(i=1,2,dots,N)hat(gamma_i)
  $
]

==== 间隔最大化
间隔最大化的直观解释是：对训练数据集找到*几何间隔最大的超平面*,意味着以充分大的确信度对训练数据进行分类.也就是说,不仅将正负实例点分开,而且对最难分的实例点（离超平面最近的点）也有足够大的确信度将他们分开.这样的超平面对于未知新实例有很好分类预测能力.

具体地,这个问题可以表示为下面的约束最优化问题：
$
  &max_(w,b) gamma\
  &s.t. y_i (w/norm(w)dot x_i+b/norm(w)) gt.eq.slant gamma, #h(1em)i=1,2,dots,N
$

我们把问题转换到函数间隔上：
$
  &max_(w,b) hat(gamma)/norm(w) \
  &s.t. y_i (w dot x_i+b) gt.eq.slant hat(gamma), #h(1em)i=1,2,dots,N
$

而函数间隔$hat(gamma)$的取值其实对上面的不等式约束是没有影响的（它是标量）,所以可用取$hat(gamma)=1$,而如果最大化$1/norm(w)$,其实和最小化$1/2 norm(w)^2$是等价的#remark[
  
  这里能够把$1/norm(w)$变成$1/2 norm(w)^2$其实就是依据的是单调性；而之所以会选择$1/2 norm(w)^2$,其实是因为他凸且光滑,求导为$w$便于使用梯度下降或拉格朗日对偶方法,*是出于数学便利性*.

  而$norm(w)$在$w=0$处不可导.

  而且$1/2 norm(w)^2$是一个凸函数,且有最小值0,具有良好的数学性质.
],所以问题转换为了
$
  &min_(w,b) 1/2 norm(w)^2\
  &s.t. y_i (w dot x_i+b) - 1 gt.eq.slant 0, #h(1em)i=1,2,dots,N
$
这是一个凸二次规划问题.



#algorithm("训练：线性可分支持向量机")[
  *输入：*线性可分训练数据集$T={(x_1,y_1),(x_2,y_2),dots,(x_N,y_N)}$,其中$x_i in cal(X) = R^n, y_i in cal(Y)={-1,+1},i=1,2,dots,N$.

  *输出：*最大间隔分离超平面和分类决策函数.

  1. 构造并求解约束最优化问题,求得$w^*,b^*$：
  $
    &min_(w,b) 1/2 norm(w)^2\
  &s.t. y_i (w dot x_i+b) - 1 gt.eq.slant 0, #h(1em)i=1,2,dots,N
  $
  2. 由此得到分离超平面：
  $
    w^* dot x+b^*=0
  $
  分类决策函数：
  $
    f(x)="sign"(w^* dot x+b^*)
  $
]

#theorem[
  若训练数据集$T$线性可分,则可将训练数据集中的样本点完全正确分开的最大间隔分离超平面存在且唯一.
]

#proof[
  
*1. 存在性*

由于训练数据集线性可分,所以算法中的最优化问题一定存在可行解.又由于目标函数有下界,所以优化问题必有解,记作$(w^*,b^*)$.由于训练数据集中既有正类点又有负类点,所以$(w,b)=(0,b)$不是最优化问题的可行解,因而最优解$(w^*,b^*)$必满足$w^* eq.not 0$.由此得知分离超平面的存在性.

*2. 唯一性*

首先证明解中$w^*$的唯一性.假设问题存在两个最优解$(w^*_1,b^*_1)$和$(w^*_2,b^*_2)$. 显然$norm(w^*_1)=norm(w^*_2)=c$,其中$c$是一个常数.令$w=(w^*_1 + w^*_2)/2, b=(b^*_1 + b^*_2)/2$,易知$(w,b)$是问题的可行解,即满足$y_i (w dot x_i + b)-1 gt.eq.slant 0,#h(1em)i=1,2,dots,N$,从而有：
$
  c lt.eq.slant norm(w) lt.eq.slant 1/2 norm(w^*_1) + 1/2 norm(w^*_2)=c
$
这样的话,$norm(w)=norm(w^*_1)=norm(w^*_2), w^*_1=lambda w_2^*, |lambda|=1$.若$lambda=-1$,则$w=0$,$(w,b)$不是问题的可行解,出现矛盾；所以$lambda=1$,这样就有$w^*_1=w^*_2$,我们就证明出了$w^*$的唯一性.

下面我们证明$b^*_1=b^*_2$.设$x'_1$和$x'_2$是集合${x_i |y_i = +1}$中分别对应于$(w^*,b_1^*)$和$(w^*,b^*_2)$使得问题的不等式等号成立的点,$x_1#h(-0.5em)prime.double$和$x_2#h(-0.5em)prime.double$是集合${x_i |y_i = -1}$中分别对应于$(w^*,b_1^*)$和$(w^*,b^*_2)$使得问题的不等式等号成立的点,则有：
$
  b_1^*- b_2^*=-1/2 w^*(x'_1 + x_1#h(-0.5em)prime.double -x'_2 - x_2#h(-0.5em)prime.double)
$
又因为：
$
  w^* dot x' _2 + b_1^* gt.eq.slant 1=w^* dot x' _1 + b^*_1 \
  w^* dot x' _1 + b_2^* gt.eq.slant 1=w^* dot x' _2 + b^*_2 
$
所以,$w^* dot (x' _1-x' _2)=0$,同理有$w^* dot (x_1#h(-0.5em)prime.double -x_2#h(-0.5em)prime.double)=0$.因此
$
  b_1^*=b_2^*
$
所以解是唯一的.

综上,解存在且唯一.
]

#definition("支持向量")[
  在线性可分情况下,训练数据集的样本点中,与分离*超平面距离最近的样本点*的实例称为*支持向量(support vector)*.支持向量是使约束条件式等号成立的点,即：
  $
    y_i (w dot x_i + b)-1=0
  $
  对$y_i = +1$的正实例点,支持向量在超平面
  $
    H_1:w dot x+b=1
  $
  上,对$y_i = -1$的负例点,支持向量在超平面
  $
    H_2:w dot x+b=-1
  $
  上.在$H_1$和$H_2$上的点就是*支持向量*.#remark[
  其实就是卡住最大间隔超平面的那些点,被称为支持向量.注意SV是点.
]
]

#figure(
  align(image("/assets/image-6.png"),center),
  caption:[
    红色的东西就是支持向量.线(无论是虚线还是实线)都是超平面.
  ]
)

$H_1$与$H_2$平行,并且没有实例点落在他们中间,在二者之间形成一个长带,分离超平面与他们平行且位于他们中央.*长带的宽度,即$H_1$与$H_2$之间的距离称为间隔(margin)*.间隔的长度为$2/norm(w)$, $H_1$和$H_2$称为间隔边界.
#note[
  由于支持向量在确定分离超平面中起着决定性作用,所以将这种分类模型称为支持向量机.支持向量的个数一般很少,所以支持向量机由很少的“重要的”训练样本确定.
]

==== 求解：线性可分支持向量机的最优化问题

上面的问题为原始最优化问题,应用拉格朗日对偶性,通过求解对偶问题得到原始问题的最优解,就是线性可分支持向量机的对偶算法(dual algorithm).
#remark[
这样做的优点有：
+ 对偶问题往往容易求解.
+ 自然引入核函数,从而推广到非线性分类问题.
]

首先构建拉格朗日函数,为此对每一个不等式约束引入拉格朗日乘子$alpha_i gt.eq.slant 0, i=1,2,dots,N$,定义拉格朗日函数：
$
  L(w,b,bold(alpha))=1/2 norm(w)^2-sum_(i=1)^N alpha_i y_i (w dot x_i + b)+sum_(i=1)^N alpha_i
$
其中,$bold(alpha)=(alpha_1,alpha_2,dots,alpha_N)^T$为拉格朗日乘子向量.

根据拉格朗日对偶性,原始问题的对偶问题是极大极小问题：#note[
  一方面,max那一块是和原本的最大值优化问题无异;但是min就是排除非法情形.例如,约束是$h_i (x) gt.eq.slant 0 $,我们只需要让对应系数$->infinity$,就能在最小值优化过程中解决之.
]
$
  max_(bold(alpha)) min_(w,b) L(w,b,bold(alpha))//todo:展开说说 
$
$
  &nabla_w L(w,b,alpha)=w-sum_(i=1)^N alpha_i y_i x_i=0\
  &nabla_b L(w,b,alpha)=-sum_(i=1)^N alpha_i y_i = 0\ 

  ==> &w=sum_(i=1)^N alpha_i y_i x_i\
  ==> &sum_(i=1)^N alpha_i y_i=0
$
带入到拉格朗日函数,得到#note[
  求和恒等变形丑陋而糟糕.
]
#note[
  好吧,好像是trivial的.]：
#wideblock[
  $
  L(w,b,alpha) &=1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j (x_i dot x_j)-sum_(i=1) alpha_i y_i [(sum_(j=1)^N alpha_j y_j x_j)dot x_i + b ]+sum_(i=1)^N alpha_i\
  &= -1/2  sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j (x_i dot x_j)+sum_(i=1)^N alpha_i
$

]
现在对偶问题就转换为了#note[
  我们仍然习惯上把极大问题转换为极小问题,得到
$
  &min_alpha #h(1em)1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j (x_i dot x_j)-sum_(i=1)^N alpha_i\
  &s.t. #h(1em)sum_(i=1)^N alpha_i y_i =0, alpha_i gt.eq.slant 0,i=1,2,dots,N
$
]
$
  &max_alpha #h(1em)-1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j (x_i dot x_j)+sum_(i=1)^N alpha_i\
  &s.t. #h(1em)sum_(i=1)^N alpha_i y_i =0, alpha_i gt.eq.slant 0,i=1,2,dots,N
$


原始问题满足拉格朗日对偶条件,所以存在$w^*, alpha^*, beta^*$,使$w^*$是原始问题的解,$alpha^*,beta^*$是对偶问题的解.

#theorem[
  设$alpha^*=(alpha_1^*,alpha_2^*,dots,alpha_l^*)^T$是对偶最优化问题的解,则存在下标$j$,使得$alpha_j^*>0$,并可按下式求得原始最优化问题的解$w^*,b^*$:
  $
    w^*=sum_(i=1)^N alpha_i^* y_i x_i\
    b^*=y_j-sum_(i=1)^N alpha_i^* y_i (x_i dot x_j)
  $
  
]

#proof[
  易知：
  $
    &nabla_w L(w^*,b^*,alpha^*)=w^*-sum_(i=1)^N alpha_i^* y_i x_i = 0\
    &nabla_b L(w^*,b^*,alpha^*)=-sum_(i=1)^N alpha_i^* y_i=0\
    &alpha_i^* (y_i (w^* dot x_i + b) - 1)=0,#h(1em)i=1,2,dots,N\
  $
  #note[KKT 条件的互补松弛性:
    上面这个式子,称为互补松弛条件.*对于每个约束,拉格朗日乘子与约束的“松弛”的乘积为0*.这意味着：
    - 如果$alpha_i^*>0$,则必须有$y_i (w^* dot x_i + b^*)-1=0$,即样本点$(x_i,y_i)$恰好落在分类间隔的边界上（这些点称为支持向量）.
    - 如果$y_i (w^* dot x_i+b^*)-1>0$（即点被正确分类且不在边界上）,则必须有$alpha_i^*=0,$表示这些点对最终分类器没有贡献.

    这个条件确保了最优解只有支持向量（边界上的点）影响模型参数.
  ]
  $  
    &y_i (w^* dot x_i + b^*)-1 gt.eq.slant 0,#h(1em)i=1,2,dots,N\
    &alpha_i^* gt.eq.slant 0,#h(1em),i=1,2,dots,N\
  $
  
  由此得：
  $
    w^*=sum_i alpha_i^* y_i x_i
  $
  其中至少有一个$alpha_j^*>0$（用反证法,假设$alpha^*=0$,那么$w^*=0$,而这不是原始最优化问题的解,矛盾）,对此$j$有：
  $
    y_j (w^* dot x_j + b^*) -1=0
  $
  而且：
  $
    y_j^2=1
  $
  所以有：
  $
    b^*= y_j-sum_(i=1)^N alpha_i^* y_i (x_i dot x_j)
  $
]

那么分离超平面可以写成
$
  sum_(i=1)^N alpha_i^* y_i (x dot x_i) + b^*=0
$
分类决策函数可以写成
$
  f(x)="sign"[sum_(i=1)^N alpha_i^* y_i (x dot x_i) + b^*]
$#remark[
  这就是说,分类决策函数只依赖于输入$x$和所有训练样本输入的内积.在预测阶段,新点$x$的预测,只需要计算它与支持向量的内积即可.
]<neiji>

综上所述,对于给定的线性可分训练数据集,可以首先求对偶问题的解$alpha^*$,再求出原始问题的解$w^*, b^*$,从而得到分离超平面及分类决策函数.这种算法称为线性可分支持向量机的对偶学习算法,是线性可分支持向量机学习的基本算法.在现实问题中,训练数据集往往线性不可分,样本中出现噪声或特一点,此时有更一般的学习算法.

#example[
  *1. 准备数据*

假设有 3 个样本点（2 个正例,1 个负例）：
- 正例 ($y=+1$): $x_1 = (3, 3)^T, x_2 = (4, 3)^T$
- 负例 ($y=-1$): $x_3 = (1, 1)^T$
]

*2. 第一步：计算 Gram 矩阵 (内积矩阵)*

我们需要计算所有样本两两之间的内积 $x_i dot x_j$：
$ G = [x_i dot x_j] = mat(
  18, 21, 6;
  21, 25, 7;
  6, 7, 2
) $

计算细节示例：$x_1 dot x_1 = 3 times 3 + 3 times 3 = 18$.

*3. 第二步：构建对偶问题*

对偶问题（极小值形式）的目标函数为：
$ min_alpha 1/2 sum_(i=1)^3 sum_(j=1)^3 alpha_i alpha_j y_i y_j (x_i dot x_j) - sum_(i=1)^3 alpha_i $

约束条件：
$ sum_(i=1)^3 alpha_i y_i = 0 arrow.r alpha_1 + alpha_2 - alpha_3 = 0 arrow.r alpha_3 = alpha_1 + alpha_2 $
$ alpha_i gt.eq 0, quad i=1,2,3 $

将 Gram 矩阵和 $y$ 值代入目标函数,并利用约束消去 $alpha_3$,得到关于 $alpha_1, alpha_2$ 的函数 $S(alpha_1, alpha_2)$：
$ S(alpha_1, alpha_2) = 4 alpha_1^2 + 13/2 alpha_2^2 + 10 alpha_1 alpha_2 - 2 alpha_1 - 2 alpha_2 $

*4. 第三步：求解最优 $alpha^*$*

对 $alpha_1, alpha_2$ 求偏导并令其为 0：
$ cases(
  (partial S) / (partial alpha_1) = 8 alpha_1 + 10 alpha_2 - 2 = 0,
  (partial S) / (partial alpha_2) = 13 alpha_2 + 10 alpha_1 - 2 = 0
) $

联立解得 $alpha_1 = 1.5, alpha_2 = -1$.由于 $alpha_2 = -1 < 0$ 违反约束,说明极值在边界上.
令 $alpha_2 = 0$,代回第一个方程 $4 alpha_1 = 1$,得 $alpha_1 = 0.25$.
此时 $alpha_3 = alpha_1 + alpha_2 = 0.25$.

故最优解为：
$ alpha^* = (0.25, 0, 0.25)^T $
#note[
  固定 $alpha_2$ 后,我们失去了在 $alpha_2$ 方向调节的自由,所以不能要求 $alpha_2$ 方向的导数为 0；但我们在 $alpha_1$ 方向依然是自由的,必须保证该方向的导数为 0.因而这里必须带入第1个方程求得$alpha_1$,而不能代入第2个方程.
]

*5. 第四步：计算原始参数 $w^*$ 和 $b^*$*

计算 $w^*$：
$ w^* = sum_(i=1)^3 alpha_i^* y_i x_i = 0.25 dot x_1 + 0 dot x_2 + 0.25 dot (-1) dot x_3 $
$ w^* = 0.25 vec(3, 3) - 0.25 vec(1, 1) = vec(0.5, 0.5) $

计算 $b^*$：
选择支持向量 $x_1$（因为 $alpha_1^* > 0$）,利用 $b^* = y_1 - w^* dot x_1$：
$ b^* = 1 - (0.5 times 3 + 0.5 times 3) = 1 - 3 = -2 $
(注：若使用 $x_3$ 验证,结果也是 -2)

*6. 最终结果*

分离超平面方程：
$ 0.5 x^((1)) + 0.5 x^((2)) - 2 = 0 $
整理得：
$ x^((1)) + x^((2)) - 4 = 0 $

分类决策函数：
$ f(x) = "sign"(0.5 x^((1)) + 0.5 x^((2)) - 2) $

此例直观展示了 SVM 的稀疏性：$x_2$ 对应的 $alpha_2^* = 0$,它不是支持向量,对最终模型没有影响.

=== 线性支持向量机与软间隔最大化

==== 线性支持向量机
通常训练数据集不是线性可分的,意味着某些样本点$(x_i,y_i)$不能满足函数间隔大于等于1的约束条件.为了解决这个问题,可以对每个样本点$(x_i,y_i)$引入一个松弛变量$xi_i gt.eq.slant 0$,使函数间隔加上松弛变量大于等于1.这样,约束条件变为
$
  y_i (w dot x_i + b) gt.eq.slant 1-xi_i
$
同时,对于每个松弛变量$xi_i$,支付一个代价$xi_i$.目标函数变成：
$
  1/2 norm(w)^2+C sum_(i=1)^N xi_i
$#remark[
  这里面的代价形式其实是不一定的,可以是二次的,对数的等等.
]
这里,$C>0$称为惩罚参数,一般由应用问题决定,$C$值大时对误分类的惩罚增大,$C$值小时对误分类的惩罚减小.

最小化目标函数有两层含义：使$1/2 norm(w)^2$尽量小即间隔尽量大,同时使误分类点的个数尽量少,$C$是调和二者的系数.这称为*软间隔最大化*.

线性不可分的线性支持向量机的学习问题变成如下凸二次规划问题（原始问题）：
$
  &min_(w,b,xi) #h(1em)1/2 norm(w)^2+C sum_(i=1)^N xi_i\
  &s.t.#h(1em) y_i (w dot x_i +b)gt.eq.slant 1-xi_i,#h(1em)i=1,2,dots,N\
  &#h(2em)xi_i gt.eq.slant 0,#h(1em)i=1,2,dots,N\
$
这是一个凸二次规划问题,因而关于$(w,b,xi)$的解是存在的.可以证明$w$的解是唯一的,而$b$的解可能不唯一,而是存在于一个区间.

设原始问题的解是$w^*,b^*$,于是可以得到分离超平面$w^* dot x+b^*=0$及分类决策函数$f(x)="sign"(w^* dot x+b^*)$,称这样的模型为*训练样本线性不可分时的线性支持向量机*,简称为*线性支持向量机*.显然,*线性支持向量机包含线性可分支持向量机*.
#definition("线性支持向量机")[
  对于给定的线性不可分的训练数据集,通过求解凸二次规划问题,即软间隔最大化问题,得到的分离超平面为
  $
    w^* dot x + b^*=0
  $
  以及对应的分类决策函数
  $
    f(x)="sign"(w^* dot x + b^*)
  $
  称为线性支持向量机.
]
==== 学习的对偶算法
为了构建拉格朗日函数,我们将不等式约束对应到乘子：
  - 针对分类间隔约束 $y_i (w dot x_i + b) - 1 + xi_i gt.eq.slant 0$,引入乘子 $alpha_i gt.eq.slant 0$.
  - 针对松弛变量非负约束 $xi_i gt.eq.slant 0$,引入乘子 $mu_i gt.eq.slant 0$.
根据拉格朗日对偶性（对于 $g(x) gt.eq.slant 0$ 的约束,构建 $L = f(x) - sum lambda g(x)$）,我们在目标函数中减去乘子与约束的乘积：
  $
    L(w,b,xi,alpha,mu) &= underbrace(1/2 norm(w)^2 + C sum_(i=1)^N xi_i, "原始目标")
    - sum_(i=1)^N alpha_i underbrace([y_i (w dot x_i + b) - 1 + xi_i], "间隔约束")
    - sum_(i=1)^N mu_i underbrace(xi_i, "非负")\

$
$alpha_i gt.eq.slant 0, mu_i gt.eq.slant 0$

对偶问题是拉格朗日函数的极大极小问题,首先求极小,由
$
  &nabla_w L(w,b,xi,alpha,mu)=w-sum_(i=1)^N alpha_i y_i x_i=0\
  &nabla_b L(w,b,xi,alpha,mu)=-sum_(i=1)^N alpha_i y_i=0\
  &nabla_(xi_i) L(w,b,xi,alpha,mu)=C-alpha_i-mu_i=0\
$
得：
$
  w=sum_(i=1)^N alpha_i y_i x_i\
  sum_(i=1)^N alpha_i y_i=0\
  C-alpha_i-mu_i=0
$
带回可得：
$
  min_(w,b,xi) L(w,b,xi,alpha,mu)=-1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j (x_i dot x_j)+sum_(i=1)^N alpha_i
$
再对其求$alpha$的极大,即得对偶问题：
$
  &max_alpha #h(1em)-1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j (x_i dot x_j)+sum_(i=1)^N alpha_i\
  &s.t.#h(1em)sum_(i=1)^N alpha_i y_i=0,C-alpha_i-mu_i=0,alpha_i gt.eq.slant 0,mu_i gt.eq.slant 0,#h(1em)i=1,2,dots,N\
$
#theorem[
  设$alpha^*=(alpha_1^*,alpha_2^*,dots,alpha_N^*)^T$是对偶问题的一个解,若存在$alpha^*$的一个分量$alpha_j^*,0<alpha_j^*<C$,则原始问题的解$w^*,b^*$可以按下式求解：
  $
    &w^*=sum_(i=1)^N alpha_i^* y_i x_i\
    &b^*=y_j-sum_(i=1)^N y_i alpha_i^* (x_i dot x_j)\
  $
]

#proof[
  原始问题是凸二次规划问题,解满足KKT条件,即得：
  $
    &nabla_w L(w^*,b^*,xi^*,alpha^*,mu^*)=w^*-sum_(i=1)^N alpha_i^* y_i x_i=0\
    &nabla_b L(w^*,b^*,xi^*,alpha^*,mu^*)=-sum_(i=1)^N alpha_i^* y_i=0\
    &nabla_xi L(w^*,b^*,xi^*,alpha^*,mu^*)=C-alpha^*-mu^*=0\
  $
  $
    alpha_i^*(y_i (w^* dot x_i+b^*)-1+xi^*_i)=0
  $
  #note[
    这个式子的作用与前面线性可分支持向量机的是一致的.
  ]
  $
    mu_i^* xi_i^*=0
  $
  #note[
    - 这个式子与上面的式子类似,如果松弛变量$xi_i^*>0$,说明该样本点被允许违反间隔约束,则必须有$mu_i^*=0$
    - 反之,如果拉格朗日乘子$mu_i^*>0$,说明对松弛惩罚是活跃的,则必须有$xi_i^*=0$,说明该点严格遵守了间隔约束.
  ]
  $
    y_i (w^* dot x_i^*+b^*)-1+xi_i^* gt.eq.slant 0\
    xi_i^* gt.eq.slant 0,
    alpha_i ^* gt.eq.slant 0,
    mu_i^* gt.eq.slant 0,
    #h(1em)i=1,2,dots,N
  $
  若存在$a_j^*,0<a_j^*<C$,则$y_i (w^* dot x_i + b^*)-1=0$,则有：
  $
    &w^*=sum_(i=1)^N alpha_i^* y_i x_i\
    &b^*=y_j-sum_(i=1)^N y_i alpha_i^* (x_i dot x_j)\
  $
]

由此可知,分离超平面可以写成
$
  sum_(i=1)^N alpha_i^* y_i (x dot x_i)+b^*=0
$
分类决策函数可以写成
$
  f(x)="sign"[sum_(i=1)^N alpha_i^* y_i (x dot x_i)+b^*]
$

综上所述,我们得到以下算法
#algorithm("线性支持向量机")[
  *输入：*训练数据集$T={(x_1,y_1),(x_2,y_2),dots,(x_N,y_N)}$,其中,$x_i in cal(X)=R^n, y_i in cal(Y)={-1,+1},i=1,2,dots,N$.

  *输出：*分离超平面和分类决策函数.

  1. 选择惩罚参数$C>0$,构造并求解凸二次规划问题,求得最优解$alpha^*=(alpha_1^*, alpha_2^*,dots,alpha_N^*)^T$：
  $
    &min_alpha #h(1em)1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j (x_i dot x_j)-sum_(i=1)^N alpha_i\
  &s.t.#h(1em)sum_(i=1)^N alpha_i y_i=0,0 lt.eq.slant alpha_i lt.eq.slant C,i=1,2,dots,N
  $
  2. 计算$w^*=sum_(i=1)^N alpha_i^* y_i x_i$
    
    选择$alpha^*$的一个分量$alpha_j^*$满足条件$0<alpha^*_j<C$,计算
    $
      b^*=y_j-sum_(i=1)^N y_i alpha_i^* (x_i dot x_j)
    $
  3. 求得分离超平面
$
  sum_(i=1)^N alpha_i^* y_i (x dot x_i)+b^*=0
$
分类决策函数
$
  f(x)="sign"[sum_(i=1)^N alpha_i^* y_i (x dot x_i)+b^*]
$
]
理论上$b$的解可能是不唯一的,但实际意义中,往往只会出现算法叙述的情况.

#example[
  虽然该数据是线性可分的,但通过设定参数 $C$,完全可以演示软间隔算法的通用步骤.当 $C$ 足够大时,软间隔解将收敛于硬间隔解.

  *1. 输入数据与参数设定*

  我们将惩罚参数设定为 $C = 1$.
  训练数据 $T$ 包含 3 个样本点：
  - 正例 ($y=+1$): $x_1 = (3, 3)^T, x_2 = (4, 3)^T$
  - 负例 ($y=-1$): $x_3 = (1, 1)^T$
]

*2. 第一步：构造并求解对偶问题*

  我们需要求解以下带约束的凸二次规划问题：
  $ min_alpha 1/2 sum_(i=1)^3 sum_(j=1)^3 alpha_i alpha_j y_i y_j (x_i dot x_j) - sum_(i=1)^3 alpha_i $
  
  约束条件变为（注意增加了 $alpha_i lt.eq C$）：
  $ cases(
    sum_(i=1)^3 alpha_i y_i = alpha_1 + alpha_2 - alpha_3 = 0,
    0 lt.eq alpha_i lt.eq 1\, quad i="1,2,3"
  ) $

  代入 Gram 矩阵（内积）并利用 $alpha_3 = alpha_1 + alpha_2$ 消元后,目标函数 $S(alpha_1, alpha_2)$ 与硬间隔情况一致：
  $ S(alpha_1, alpha_2) = 4 alpha_1^2 + 13/2 alpha_2^2 + 10 alpha_1 alpha_2 - 2 alpha_1 - 2 alpha_2 $

  我们对 $alpha_1, alpha_2$ 求偏导并令其为 0,联立解得无约束极值点：
  $ alpha_1 = 1.5, quad alpha_2 = -1 $
  这不满足 $0 lt.eq alpha_i$ 的约束.最小值必然在边界上.
  
  经过边界分析（令 $alpha_2=0$）,我们得到最优解：
  $ alpha_1^* = 0.25, quad alpha_2^* = 0 $
  从而推导 $alpha_3^* = alpha_1^* + alpha_2^* = 0.25$.

  *关键检查：验证约束条件 $0 lt.eq alpha_i^* lt.eq C$*
  此时解为 $alpha^* = (0.25, 0, 0.25)^T$.
  由于我们要保证 $alpha_i^* lt.eq 1$ (即 $C=1$),显然 $0.25 lt.eq 1$ 成立.
  所以该解在可行域内,是本问题的最优解.

  *3. 第二步：计算 $w^*$ 和 $b^*$*

  *计算 $w^*$*：
  $ w^* = sum_(i=1)^3 alpha_i^* y_i x_i = 0.25 x_1 - 0.25 x_3 = vec(0.5, 0.5) $

  *计算 $b^*$*：
  根据算法步骤,我们需要选择一个分量 $alpha_j^*$,满足 *严格不等式*：
  $ 0 < alpha_j^* < C $
  
  检查我们的解：
  - $alpha_1^* = 0.25$,满足 $0 < 0.25 < 1$.
  - $alpha_3^* = 0.25$,满足 $0 < 0.25 < 1$.
  
  我们可以选择 $j=1$（即利用支持向量 $x_1$）来计算 $b^*$：
  $ b^* &= y_1 - sum_(i=1)^3 y_i alpha_i^* (x_i dot x_1) \
        &= 1 - [1 dot 0.25 dot (18) + 1 dot 0 dot (21) + (-1) dot 0.25 dot (6)] \
        &= 1 - [4.5 - 1.5] \
        &= 1 - 3 = -2 $

  (注：如果选取 $j=3$ 计算,结果同样是 -2.这体现了 KKT 条件的一致性.)

  *4. 第三步：输出结果*

  分离超平面：
  $ 0.5 x^((1)) + 0.5 x^((2)) - 2 = 0 $

  分类决策函数：
  $ f(x) = "sign"(0.5 x^((1)) + 0.5 x^((2)) - 2) $

  *结果分析*：
  在这个例子中,因为数据本身线性可分且我们给的 $C$ 比较宽松（$C=1 > 0.25$）,所有的支持向量（$x_1, x_3$）都落在间隔边界上（$xi_i=0$）,所以 $0 < alpha_i < C$.
  
  如果我们将 $C$ 设得极小（例如 $C=0.1$）,那么 $alpha_1, alpha_3$ 将会被强制截断在 0.1 处,此时 $alpha_i = C$,这些点就会变成“误分类”或“间隔内”的支持向量.
==== 支持向量
在线性不可分的情况下,将对偶问题的解$alpha^*=(alpha_1^*,alpha_2^*,dots,alpha_N^*)^T$中对应于$alpha_i^*>0$的样本点$(x_i,y_i)$的实例$x_i$称为支持向量（软间隔的支持向量）.*软间隔的支持向量$x_i$或者在间隔边界上,或者在间隔边界与分离超平面之间,或者在分离超平面误分一侧.*

#figure(
  image("/assets/image-7.png"),caption:[
    一个漂亮的图例子#note[
  - 若$alpha_i^*<C$,则$xi_i=0$,支持向量$x_i$恰好落在间隔边界上；
- 若$alpha_i^*=C,0<xi_i<1$,则分类正确,$x_i$在间隔边界与分离超平面之间；
- 若$a_i^*=C,xi_i=1$,则$x_i$在分离超平面上；
- 若$a_i^*=C,xi_i>1$,则$x_i$位于分离超平面误分一侧.
  ]])
#grid(
  columns: 2,
  gutter: 15pt,
  // 子图 (a)
  figure(
    image("/assets/image-8.png", width: 100%),
    caption: [使用高C值SVM,间隔违例较少,但是间隔也较小 ],
    //supplement: none, // 隐藏默认的 "Figure" 字样
  ),
  // 子图 (b)
  figure(
    image("/assets/image-8.png", width: 100%),
    caption: [使用低C值SVM,间隔违例较多,但是间隔较大,泛化能力更强 ],
    //supplement: none,
  ),
)
==== 合页损失函数
线性支持向量机学习还有另一种解释,就是最小化以下目标函数：
$
  sum_(i=1)^N [1-y_i (w dot x_i + b )]_+ + lambda norm(w)^2
$
目标函数的第1项是经验损失或经验风险,函数
$
  L(y(w dot x+b))=[1-y(w dot x + b)]_+
$
称为合页损失函数(hinge loss function).下标“+”表示以下取正值的函数：
$
  [z]_+=cases(
    z #h(1em)z>0,
    0 #h(1em)z lt.eq.slant 0
  )
$
这就是说,当样本点$(x_i,y_i)$被正确分类且函数间隔（确信度）$y_i (w dot x_i + b)>1$时,损失是0；否则损失时$1-y_i (w dot x_i + b)$；目标函数的第2项是系数是$lambda$的$w$的$L_2$范数,是正则化项.

#theorem[
  线性支持向量机原始最优化问题
  $
    &min_(w,b,xi) #h(1em)1/2 norm(w)^2+C sum_(i=1)^N xi_i\
    &s.t. #h(1em)y_i (w dot x_i +b)gt.eq.slant 1-xi_i,xi_i gt.eq.slant 0, #h(1em)i=1,2,dots,N
  $
  等价于最优化问题
  $
    min_(w,b) sum_(i=1)^N [1-y_i (w dot x_i + b)]_+ + lambda norm(w)^2
  $
]

#proof[
  令
  $
    [1-y_i (w dot x_i + b)]_+=xi_i 
  $
  则$xi_i gt.eq.slant 0$. 当$1-y_i (w dot x_i + b)>0$时,有$y_i (w dot x_i + b)=1-xi_i$; 当$1-y_i (w dot x_i + b)lt.eq.slant 0$时,$xi_i=0$,所以$y_i (w dot x_i +b)gt.eq.slant 1-xi_i$;所以优化式就转化成了
  $
    min_(w,b)#h(1em)sum_(i=1)^N xi_i + lambda norm(w)^2
  $
  若取$lambda=1/(2C)$,则：
  $
    min_(w,b)#h(1em)1/C (1/2 norm(w)^2+C sum_(i=1)^N xi_i)
  $
  与原始优化问题等价.
]

合页损失函数是0-1损失函数的上界.由于0-1损失函数不是连续可导的,直接优化由其构成的目标函数比较困难,可以认为线性支持向量机是优化由0-1损失函数的上界构成的目标函数.这时的上界损失函数又称为代理损失函数(surrogate loss function).
#remark[
  当样本点$(x_i,y_i)$被正确分类时,损失是0,否则损失是$-y_i (w dot x_i + b)$,相比之下,合页损失函数不仅要求分类正确,而且确信度足够高时损失才是0. 也就是说,合页损失函数对学习有更高的要求.
]

=== 非线性支持向量机与核函数
非线性分类问题是指通过利用非线性模型才能很好地进行分类的问题.#note[醍醐灌顶!]一般来说,如果能用$R^n$中的一个超曲面将(之前提到的)正负例正确分开,则称这个问题为非线性可分问题.
#remark[
  所采取的方法是进行一个非线性变换,将非线性问题变换为线性问题,通过解变换后的线性问题的方法求解原来的非线性问题.
]


设原空间为$cal(X) subset R^2, x=(x^((1)),x^((2)))^T in cal(X)$,新空间$cal(Z) subset R^2, z=(z^((1)),z^((2)))^T in cal(Z)$,定义在原空间为$cal(X) subset R^2$变换为新空间$cal(Z) subset R^2$,原空间中的点相应地变换为新空间中的点,原空间中的椭圆
$
  w_1 (x^((1)))^2+w_2 (x^((2)))^2 + b=0
$
变换成为新空间中的直线
$
  w_1 z^((1))+ w_2 z^((2))+b=0
$
这样,原空间的非线性可分问题就变成了新空间的线性可分问题.

1. 使用一个变换将原空间的数据映射到新空间.
2. 新空间里用线性分类学习方法进行学习.
#remark[
  核技巧属于这种方法.通过一个非线性变换将输入空间（欧氏空间$R^n$或离散集合）对应于一个特征空间（希尔伯特空间$cal(H)$）,使得在输入空间$R^n$中的超曲面模型对应于特征空间$cal(H)$中的超平面模型（支持向量机）.根据@neiji,我们能知道SVM的关键是算内积,所以我们不需要知道变换本身(参考下面的定义,我们只需要$K$,甚至不需要知道$phi.alt$.)
]

#definition[
  设$cal(X)$是输入空间（欧氏空间$R^n$的子集或离散集合）,又设$cal(H)$为特征空间（希尔伯特空间）,如果存在一个从$cal(X)$到$cal(H)$的映射
  $
    phi.alt(x):cal(X) arrow.r cal(H)
  $
  使得对所有$x,z in cal(X)$,函数$K(x,z)$满足条件
  $
    K(x,z)=phi.alt(x)dot phi.alt(z)
  $
  则称$K(x,z)$为核函数,$phi.alt(x)$为映射函数,式中的运算为内积.

  核函数一定有
  $
    K(x,z)=K(z,x)
  $
]
#remark[
  虽然在推导中使用的是$phi.alt(x)$,但是实际我们需要计算的是$K$,学习在隐式地在特征空间进行的,不需要显式地定义特征空间和映射函数,这就是核技巧.
]
#example[
  假设输入空间是$R^2$,核函数是$K(x,z)=(x dot z)^2$,试找出其相关的特征空间$cal(H)$和映射$phi(x):R^2 arrow.r cal(H)$.

  取特征空间$cal(H)=R^3$,记$x=(x^((1)),x^((2)))^T,z=(z^((1)),z^((2)))^T$,由于
  $
    (x dot z)^2=(x^((1))z^((2))+x^((2))z^((2)))^2=(x^((1))z^((1)))^2+2x^((1))z^((1))x^((2))z^((2))+(x^((2))z^((2)))^2
  $
  所以可以取映射
  $
    phi.alt(x)=((x^((1)))^2,sqrt(2)x^((1))x^((2)),(x^((2)))^2)^T
  $
  容易验证$phi.alt(x)dot phi.alt(z)=(x dot z)^2=K(x,z)$
  仍取$cal(H)=R^3$以及
  $
    phi.alt(x)=1/sqrt(2) ((x^((1)))^2-(x^((2)))^2,2x^((1))x^((2)),(x^((1)))^2+(x^((2)))^2)^T
  $
  还可以取$cal(H)=R^4$和
  $
    phi.alt(x)=((x^((1)))^2,x^((1))x^((2)),x^((1))x^((2)),(x^((2)))^2)^T
  $
]
#note[
  对于多项式核都是这样的套路,展开多项式、识别特征项、确定系数.
]

对偶问题的目标函数中的内积$x_i dot x_j$可以用核函数$K(x_i,x_j)=phi.alt(x_i)dot phi.alt(x_j)$来代替,对偶问题的目标函数成为：
$
  W(alpha)=1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j K(x_i,x_j)-sum_(i=1)^N alpha_i
$
同样,分类决策函数中的内积也可以用核函数代替,分类决策函数式成为
$
  f(x)
  &="sign"(sum_(i=1)^(N_s) a_i^* y_i phi.alt(x_i)dot phi.alt(x)+b^*)\
  &="sign"(sum_(i=1)^(N_x) a_i^* y_i K(x_i,x)+b^*)
$

通常所说的核函数就是*正定核函数*.一个函数$K$是正定核函数,当且仅当Gram矩阵$
 KK eq.delta [K(x_i,x_j)]_(m times m)
$
是半正定的.证明见附录.
#note[
  这其实就是对于正定核的等价定义.对于一个具体函数验证它是否为正定核函数并不容易,因为要求对任意有限输入集${x_1,x_2,dots,x_m}$验证$K$对应的Gram矩阵是半正定矩阵.在实际问题中往往应用已有的核函数.
]
#table(
  columns: (auto, 1fr), // 第一列自适应，第二列占据剩余空间
  align: (left + horizon, center + horizon), // 第一列左对齐，第二列居中
  inset: 10pt, // 单元格内边距
  stroke: (y: 0.5pt), // 仅保留横线，模拟学术论文风格
  
  // 表头（可选）
  [*名称*], [*表达式*],
  
  [线性核], $kappa(bold(x)_i, bold(x)_j) = bold(x)_i^T bold(x)_j$,
  
  [多项式核], $kappa(bold(x)_i, bold(x)_j) = (bold(x)_i^T bold(x)_j)^d$,
  
  [高斯核], $kappa(bold(x)_i, bold(x)_j) = exp(- frac(||bold(x)_i - bold(x)_j||^2, 2 sigma^2))$,
  
  [拉普拉斯核], $kappa(bold(x)_i, bold(x)_j) = exp(- frac(||bold(x)_i - bold(x)_j||, sigma))$,
  
  [Sigmoid 核], $kappa(bold(x)_i, bold(x)_j) = tanh(beta bold(x)_i^T bold(x)_j + theta)$,
)
假设$K(x,z)$是定义在$cal(X) times cal(X)$上的对称函数,并且对任意的$x_1,x_2,dots,x_m in cal(X)$,$K(x,z)$关于$x_1,x_2,dots,x_m$的Gram矩阵是半正定的.可以依据函数$K(x,z)$构成一个希尔伯特空间,步骤是：首先定义映射$phi.alt$并构成向量空间$cal(S)$,然后在$cal(S)$上定义内积构成内积空间,最后将$cal(S)$完备化构成希尔伯特空间.#remark[
  一个对称矩阵$A$是半正定的,如果对于任意实向量$c=(c_1,c_2,dots,c_m)^T$,都有：
  $
    c^T A c gt.eq.slant 0
  $
  这意味着二次型$sum_(i=1)^m sum_(j=1)^m c_i c_j A_(i j)gt.eq.slant 0$在核函数语境下,我们要求Gram矩阵是半正定的,即
  $
    sum_(i=1)^m sum_(j=1)^m c_i c_j K(x_i,x_j) gt.eq.slant 0
  $
  这个条件确保了核函数是正定核,保证了核函数对于内积具有非负性.
]

先定义映射
$
  phi.alt:x |->  K(dot,x)
$
根据这一映射,对任意$x_i in cal(X), alpha_i in R, i=1,2,dots,m$,定义线性组合
$
  f(dot)=sum_(i=1)^m alpha_i K(dot,x_i)
$
考虑由线性组合为元素的集合$cal(S)$,由于集合$cal(S)$对加法和数乘运算是封闭的,所以$cal(S)$构成一个向量空间.接着在$cal(S)$上定义一个运算$*$:对任意$f,g in cal(S)$,有：
$
  f(dot)=sum_(i=1)^m alpha_i K(dot,x_i)\
  g(dot)=sum_(j=1)^l beta_j K(dot,z_j)\
  f * g=sum_(i=1)^m sum_(j=1)^l alpha_i beta_j K(x_i,z_j)
$
证明运算$*$是空间$cal(S)$的内积,就要证明：
$
  &(c f)*g=c(f*g),c in R\
  &(f+g)*h=f*h+g*h,h in S\
  &f*g=g*f\
  &f*f gt.eq.slant 0,f*f=0 arrow.r.l.double f=0\
$
现在我们证明：$f*f gt.eq.slant 0,f*f=0 arrow.r.l.double f=0$

由Gram矩阵的半正定性知非负性,下面证明下面的等价关系.充分性显然,下证必要性：

对于任意的$x in cal(X)$,有
$
  K(dot,x)*f=sum_(i=1)^m alpha_i K(x,x_i)=f(x)
$#remark[
  $K(dot,x)$可以看作一个特殊的函数$g in cal(S)$,他对应于点$x$的映射.具体地,$g(dot)=K(dot,x)$,这等价于$g$是一个线性组合（只有一项,系数为1,点为$x$）：
  $
    g(dot)=1 dot K(dot,x)
  $
  即,$l=1,beta_1=1,z_1=x$.
]
于是,
$
  |f(x)|^2=|K(dot,x)*f|^2
$
由柯西不等式有：
$
  |K(dot,x)*f|^2 lt.eq.slant &(K(dot,x)*K(dot,x))(f*f)\
  &=K(x,x)(f*f)
$
所以有：
$
  |f(x)|^2 lt.eq.slant K(x,x)(f*f)
$
此式表明,当$f*f=0$时,对任意的$x$都有$|f(x)|=0$.

至此,证明了$*$为向量空间$cal(S)$的内积,因此$cal(S)$是一个内积空间.我们仍然用$dot$来表示内积运算.

再根据内积得到范数
$
  norm(f)=sqrt(f dot f)
$
得到赋范向量空间,进一步可以再完备化得到希尔伯特空间,这样的希尔伯特空间称为再生核希尔伯特空间,因为核$K$具有再生性.
$
  K(dot,x)dot f=f(x)
$
及
$
  K(dot,x)dot K(dot,z)=K(x,z)
$
称为再生核.


#definition[
  从非线性分类训练集,通过核函数与软间隔最大化或凸二次规划学习得到的分类决策函数
  $
    f(x)="sign"(sum_(i=1)^(N_s) a_i^* y_i K(x,x_i)+b^*)
  $
  称为非线性支持向量机,$K(x,z)$是正定核函数.
]

#algorithm[
  *输入：*训练数据集$T={(x_1,y_1),(x_2,y_2),dots,(x_N,y_N)}$,其中$x_i in cal(X)=R^2,y_i in cal(Y)={-1,+1},i=1,2,dots,N$

  *输出：*分类决策函数.

  1. 选取适当的核函数$K(x,z)$和适当的参数$C$,构造并求解最优化问题,求得最优解$alpha^*=(alpha_1^*,alpha_2^*,dots,alpha_N^*)^T$
  $
    &min_(alpha) #h(1em)1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j K(x_i,x_j)-sum_(i=1)^N alpha_i\
    &s.t. #h(1em)sum_(i=1)^N alpha_i y_i=0,0 lt.eq.slant alpha_i lt.eq.slant C,i=1,2,dots,N
  $
  2. 选择$alpha^*$的一个正分量$0<alpha_j*<C$,计算
  $
    b^*=y_j -sum_(i=1)^N alpha_i^* y_i K(x_i,x_j)
  $
  3. 构造决策函数：
  $
    f(x)="sign"(sum_(i=1)^(N_s) a_i^* y_i K(x,x_i)+b^*)
  $
]

=== 序列最小最优化算法

如何高效地实现支持向量机学习是一个重要的问题,现在我们学习序列最小最优化(sequential minimal optimization, SMO)算法,于1998年由Platt提出.

SMO算法要解如下凸二次规划的对偶问题：
$
  &min_(alpha) #h(1em)1/2 sum_(i=1)^N sum_(j=1)^N alpha_i alpha_j y_i y_j K(x_i,x_j)-sum_(i=1)^N alpha_i\
  &s.t. #h(1em)sum_(i=1)^N alpha_i y_i=0,0 lt.eq.slant alpha_i lt.eq.slant C,i=1,2,dots,N
$
在这个问题中,变量是拉格朗日乘子,一个变量$alpha_i$对应于一个样本点$(x_i,y_i)$；变量的总数等于训练样本容量$N$.

SMO算法是一个启发式算法,其基本思路是: 如果所有变量的解都满足此最优化问题的KKT条件,那么这个最优化问题的解就得到了,因为KKT条件是该最优化问题的充分必要条件.否则,选择两个变量,固定其他变量,*针对这两个变量构建一个二次规划问题*.这个二次规划问题关于这两个变量的解应该更接近原始二次规划问题的解,因为这会使得原始二次规划问题的目标函数值变得更小.重要的是,这时子问题可以通过解析方法求解,这样就可以大大提高了求解速度.子问题有两个变量,一个是违反KKT条件最严重的一个,另一个由约束条件自动确定.

注意,子问题的两个变量中只有一个是自由变量,假设$alpha_1$, $alpha_2$为两个变量, $alpha_3, alpha_4, dots, alpha_N$固定,我们易得：
$
  alpha_1=-y_1 sum_(i=2)^N alpha_i y_i
$

如果$alpha_2$确定,那么$alpha_1$也随之确定,所以子问题中同时更新两个变量.整个SMO算法包括两个部分：*求解两个变量二次规划的解析方法*和*选择变量的启发式方法*.

不失一般性,假设选择的两个变量是$alpha_1, alpha_2$,其他变量$alpha_i (i=3,4,dots,N)$是固定的.于是SMO的最优化问题的子问题可以写成
$
  min_(alpha_1,alpha_2)#h(1em)W(alpha_1, alpha_2)=&1/2 K_11 alpha_1^2+1/2 K_22 alpha_2^2+y_1 y_2 K_12 alpha_1 alpha_2 -\
  &(alpha_1+alpha_2)+y_1 alpha_1 sum_(i=3)^N y_i alpha_i K_(i 1)+y_2 alpha_2 sum_(i=3)^N y_i alpha_i K_(i 2)\
  s.t.#h(1em) alpha_1 y_1+alpha_2 &y_2=-sum_(i=3)^N y_i alpha_i=sigma.alt, #h(1em)0 lt.eq.slant alpha_i lt.eq.slant C, i=1,2
$
其中, $K_(i j)=K(x_i,x_j),i,j=1,2,dots,N$, $sigma.alt$是常数.

易知$alpha_1, alpha_2$确定其一就可以确定另外一个,所以这其实是一个单变量的最优化问题,不妨考虑为变量$alpha_2$的最优化问题.

当$y_1 eq.not y_2$时,$alpha_1-alpha_2=k$, 因为$0 lt.eq.slant alpha_1,alpha_2 lt.eq.slant C$, 所以有$alpha_2 in [k, C+k] inter [0,C]$, 所以定义$L=max(0,k)=max(0,alpha_2-alpha_1), H=min(C, C+alpha_2-alpha_1)$, 则有$L lt.eq.slant alpha_2^("new") lt.eq.slant H$, 对于$y_1=y_2$的情况,同理有$L=max(0,alpha_2+alpha_1-C), H=min(C, alpha_2+alpha_1)$.

#theorem[
  设未经不等式取值范围约束时的$alpha_2$的最优解为$alpha_2^("new, unc")$,然后再求剪辑后$alpha_2$的解$alpha_2^"new"$.记
  $
    g(x)=sum_(i=1)^N alpha_i y_i K(x_i, x)+b\
    E_i=g(x_i)-y_i,#h(1em)i=1,2
  $
  $E_i$为函数$g(x)$对输入$x_i$的预测值与真实输出$y_i$之差.

  前述最优化问题沿着约束方向未经剪辑时的解是
  $
    alpha_2^("new, unc")=alpha_2^"old"+(y_2 (E_1-E_2))/eta
  $
  其中,
  $
    eta=K_11+K_22-2K_12=norm(Phi(x_1)-Phi(x_2))^2

  $
  $Phi(x)$是输入空间到特征空间的映射.

  经剪辑后$alpha_2$的解是
  $
    alpha_2^"new"=cases(
      H","#h(3em)&alpha_2^"new, unc">H,
      alpha_2^"new,unc"#h(-2em)"," &L lt.eq.slant alpha_2^"new,unc" lt.eq.slant H,
      L","&alpha_2^"new,unc"<L
    )
  $
  由$alpha_2^"new"$求得$alpha_1^"new"$是
  $
    alpha_1^"new"=alpha_1^"old"+y_1 y_2 (alpha_2^"old"-alpha_2^"new")
  $
]

#proof[
  暂略.
]

#theorem[阈值 $b$ 的更新][
  在每一步更新完 $alpha_1$ 和 $alpha_2$ 后,需要更新 $b$.
  
  若 $0 < alpha_1^"new" < C$,由 $alpha_1$ 的支持向量条件可得 $b_1^"new"$：
  $ b_1^"new" = -E_1 - y_1 K_11 (alpha_1^"new" - alpha_1^"old") - y_2 K_21 (alpha_2^"new" - alpha_2^"old") + b^"old" $
  
  若 $0 < alpha_2^"new" < C$,由 $alpha_2$ 的支持向量条件可得 $b_2^"new"$：
  $ b_2^"new" = -E_2 - y_1 K_12 (alpha_1^"new" - alpha_1^"old") - y_2 K_22 (alpha_2^"new" - alpha_2^"old") + b^"old" $
  
  最终的 $b^"new"$ 更新规则为：
  $ b^"new" = cases(
    b_1^"new"\, & "若" 0 < alpha_1^"new" < C,
    b_2^"new"\, & "若" 0 < alpha_2^"new" < C,
    (b_1^"new" + b_2^"new")/2\, & "否则"
  ) $
]
SMO算法在每个子问题中选择两个变量优化,其中至少一个变量是违反KKT条件的.

SMO称选择第1个变量的过程为外层循环.外层循环在训练样本中选取违反KKT条件最严重的样本点,并将其对应的变量作为第1个变量.具体地,
$
  alpha_i=0 arrow.double.l.r y_i g(x_i)&gt.eq.slant 1\
  0 <alpha_i < C arrow.double.l.r y_i g(x_i)&= 1\
  alpha_i=C arrow.double.l.r y_i g(x_i)&lt.eq.slant 1\
$
其中,$g(x)=sum_(i=1)^N alpha_i y_i K(x_i, x)+b$.

该检验是在$epsilon$范围内进行的,在检验过程中,外层循环首先遍历所有满足条件$0<alpha_i<C$的样本点,即在间隔边界上的支持向量点,检验它们是否满足KKT条件.如果这些样本点都满足KKT条件,那么遍历整个训练集,检验他们是否都满足KKT条件.

变量2的选择暂略.

#algorithm[SMO算法][
  *输入*：训练数据集$T={(x_1,y_1),(x_2,y_2),dots,(x_N,y_N)}$,其中, $x_i in cal(X)=R^n, y_i in cal(Y)={-1,+1},i=1,2,dots,N$, 精度$epsilon$.

  *输出*：近似解$hat(alpha)$.

  1. 取初值$alpha^((0))=0$, 令$k=0$;
  2. 选取优化变量$alpha_1^((k)), alpha_2^((k))$,解析求解两个变量的最优化问题,求得最优解$alpha_1^((k+1)), alpha_2^((k+1))$, 更新$alpha$为$alpha^((k+1))$;
  3. 若在精度$epsilon$范围内满足停机条件,则转步骤4,否则令$k=k+1$, 转步骤2：
  $
    sum_(i=1)^N alpha_i y_i=0, #h(1em)0lt.eq.slant C, #h(1em)i=1,2,dots, N\
    y_i dot g(x_i)=cases(
      gt.eq.slant 1","#h(2em)&{x_i|alpha_i=0},
      =1"," &{x_i|0<alpha_i<C},
      lt.eq.slant 1","&{x_i|alpha_i=C}
    )
  $
  其中,
  $
    g(x)=sum_(i=1)^N alpha_i y_i K(x_i, x)+b
  $
  4. 取$hat(alpha)=alpha^((k+1))$
]

#example[
  *1. 输入数据与参数设定*

  我们将惩罚参数设定为 $C = 1$.
  训练数据 $T$ 包含 3 个样本点：
  - 正例 ($y=+1$): $x_1 = (3, 3)^T, x_2 = (4, 3)^T$
  - 负例 ($y=-1$): $x_3 = (1, 1)^T$
]

*1. 初始化*
  
  设初始拉格朗日乘子全为 0,偏置 $b=0$：
  $ alpha^((0)) = (0, 0, 0)^T, quad b^((0)) = 0 $

  *2. 变量选择 (Heuristic)*
  
  SMO 需要选择两个变量 $alpha_i, alpha_j$ 进行优化.
  根据 KKT 条件检验,所有点目前的函数间隔都是 $y(w dot x + b) = 0 < 1$,都违反了约束.
  我们假设外层循环选中了 $x_1$（违反 KKT 最严重）,内层循环根据误差最大原则选中了 $x_3$.
  
  *选定优化对：* $x_1$ (索引1) 和 $x_3$ (索引2).即我们要更新 $alpha_1$ 和 $alpha_3$.
  (注意：为了方便公式对应,下文称 $alpha_1$ 为第一个变量,$alpha_3$ 为第二个变量).

  *3. 计算预测值与误差 E*
  
  当前模型 $f(x) = 0$ (因为 $alpha=0$).
  计算选定样本的误差 $E_k = f(x_k) - y_k$：
  $ E_1 = 0 - y_1 = -1 $
  $ E_3 = 0 - y_3 = 0 - (-1) = +1 $

  *4. 计算核函数值与 eta*
  
  计算所需的内积（Gram 矩阵元素）：
  $ K_11 = x_1 dot x_1 = 18 $
  $ K_33 = x_3 dot x_3 = 2 $
  $ K_13 = x_1 dot x_3 = 6 $
  
  计算二阶导数 $eta$ (即目标函数关于 $alpha_3$ 的二阶导数)：
  $ eta = K_11 + K_33 - 2 K_13 = 18 + 2 - 2(6) = 8 $

  *5. 计算未经剪辑的 $alpha_3^("new, unc")$*
  
  根据 SMO 更新公式：
  $ alpha_3^("new, unc") &= alpha_3^("old") + (y_3 (E_1 - E_3)) / eta \
  &= 0 + ((-1) dot (-1 - 1)) / 8 \
  &= 2 / 8 = 0.25 $

  *6. 剪辑边界 L 与 H*
  
  因为 $y_1 \neq y_3$ ($1 \neq -1$),限制条件为：
  $ L &= max(0, alpha_3^("old") - alpha_1^("old")) = max(0, 0) = 0 \
    H &= min(C, C + alpha_3^("old") - alpha_1^("old")) = min(1, 1) = 1 $
  
  $alpha_3^("new, unc") = 0.25$ 落在 $[0, 1]$ 之间,无需剪辑：
  $ alpha_3^("new") = 0.25 $

  *7. 更新 $alpha_1$*
  
  根据 $sum alpha y = 0$ 的约束同步更新 $alpha_1$：
  $ alpha_1^("new") &= alpha_1^("old") + y_1 y_3 (alpha_3^("old") - alpha_3^("new")) \
  &= 0 + (1)(-1)(0 - 0.25) \
  &= 0.25 $
  
  此时 $alpha = (0.25, 0, 0.25)^T$.

  *8. 更新阈值 b*
  
  我们需要分别计算 $b_1$ 和 $b_2$：
  $ b_1 &= b^("old") - E_1 - y_1(alpha_1^("new")-alpha_1^("old"))K_11 - y_3(alpha_3^("new")-alpha_3^("old"))K_13 \
  &= 0 - (-1) - 1(0.25)(18) - (-1)(0.25)(6) \
  &= 1 - 4.5 + 1.5 = -2 $
  
  $ b_2 &= b^("old") - E_3 - y_1(alpha_1^("new")-alpha_1^("old"))K_13 - y_3(alpha_3^("new")-alpha_3^("old"))K_33 \
  &= 0 - 1 - 1(0.25)(6) - (-1)(0.25)(2) \
  &= -1 - 1.5 + 0.5 = -2 $
  
  因为 $alpha_1^("new"), alpha_3^("new") \in (0, C)$,所以 $b_1 = b_2$.
  更新 $b^("new") = -2$.

  *9. 结果验证*
  
  经过这一轮迭代,我们得到：
  $ w = 0.25 x_1 - 0.25 x_3 = (0.5, 0.5)^T $
  $ b = -2 $
  这正好就是我们之前用全局代数法求出的精确解！说明对于这个简单数据集,SMO 一步就收敛了.
  #appendix[
    = Proof of Theorems
    #theorem[
  设$K:cal(X)times cal(X)arrow.r R$是对称函数,则$K(x,z)$为正定核函数的充要条件是对任意$x_i in cal(X),i=1,2,dots,m$,$K(x,z)$对应的Gram矩阵是半正定矩阵.
]
#proof[
  
  *必要性.*由于$K(x,z)$是$cal(X)times cal(X)$上的正定核,所以存在从$cal(X)$到希尔伯特空间$cal(H)$的映射$phi.alt$,使得
  $
    K(x,z)=phi.alt(x)dot phi.alt(z)
  $
  于是,对任意$x_1,x_2,dots,x_m$,构造$K(x,z)$关于$x_1,x_2,dots,x_m$的Gram矩阵：
  $
    [K_(i j)]_(m times m)=[K(x_i,x_j)]_(m times m)
  $
  对任意$c_1,c_2,dots,c_m in R$,有：
  $
    sum_(i,j=1)^m c_i c_j K(x_i,x_j)
    &=sum_(i,j=1)^m c_i c_j (phi.alt(x_i)dot phi.alt(x_j))\
    &=(sum_i c_i phi.alt(x_i))dot (sum_j c_j phi.alt(x_j))\
    &=norm(sum_i c_i phi.alt(x_i))^2 gt.eq.slant 0
  $
  表面$K(x,z)$关于$x_1,x_2,dots,x_m$的Gram矩阵是半正定的.

  *充分性.*
  对任意$x_1,x_2,dots,x_m in cal(X)$,已知对称函数$K(x,z)$关于$x_1,x_2,dots,x_m$的Gram矩阵是半正定的,对于给定的$K(x,z)$,可以构造从$cal(X)$到某个希尔伯特空间$cal(H)$的映射：
  $
    phi.alt:x arrow.r K(dot,x)
  $
  易知：
  $
    K(dot,x)dot f =f(x)\
    K(dot,x)dot K(dot,z)=K(x,z)\
  $
  表明$K(x,z)$是$cal(X)times cal(X)$上的核函数.
]
  ]