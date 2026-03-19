#import "@preview/cetz:0.4.2": canvas, draw

#set page(width: auto, height: auto, margin: 1cm)

#canvas({
  import draw: *
  
  // 1. 绘制坐标轴
  line((0, 0), (0, 6), mark: (end: ">"), stroke: 0.8pt) // Y轴
  line((0, 0), (8, 0), mark: (end: ">"), stroke: 0.8pt) // X轴
  
  // 定义直线的斜率和截距 (y = kx + b)
  let k = -0.4
  let b_mid = 4.5
  let margin = 0.8
  
  // 2. 绘制超平面
  // 中间实线 (Decision Boundary)
  line((1, k*1 + b_mid), (7, k*7 + b_mid), stroke: 1pt, name: "boundary")
  
  // 3. 绘制间隔边界 (Margin Boundaries)
  // H1 (上虚线)
  line((1, k*1 + b_mid + margin), (7, k*7 + b_mid + margin), stroke: (dash: "dashed"), name: "H1")
  content("H1", [ $H_1$ ], anchor: "west", padding: .2)
  
  // H2 (下虚线)
  line((1, k*1 + b_mid - margin), (7, k*7 + b_mid - margin), stroke: (dash: "dashed"), name: "H2")
  content("H2", [ $H_2$ ], anchor: "west", padding: .2)

  // 4. 绘制样本点 (随机分布)
  let circles = ((3, 5), (4, 5.2), (3.5, 4), (5, 4.5), (6.5, 4.2), (5.5, 3.5))
  let crosses = ((1, 2.5), (2, 3), (1.5, 1.5), (3, 2), (4, 2.2), (4.5, 1.2), (5, 2.5))
  
  for p in circles { circle(p, radius: 0.08, stroke: 0.5pt) }
  for p in crosses { 
    line((p.at(0)-0.1, p.at(1)-0.1), (p.at(0)+0.1, p.at(1)+0.1), stroke: 0.5pt)
    line((p.at(0)-0.1, p.at(1)+0.1), (p.at(0)+0.1, p.at(1)-0.1), stroke: 0.5pt)
  }

  // 5. 标注支持向量 (SV) - 刚好落在虚线上的点
  let sv_circle1 = (3.5, k*3.5 + b_mid + margin)
  let sv_circle2 = (5.5, k*5.5 + b_mid + margin)
  let sv_cross = (4, k*4 + b_mid - margin)
  
  // 绘制 SV (加粗或特殊标记)
  circle(sv_circle1, radius: 0.08, fill: black)
  circle(sv_circle2, radius: 0.08, fill: black)
  // 叉号 SV
  line((sv_cross.at(0)-0.1, sv_cross.at(1)-0.1), (sv_cross.at(0)+0.1, sv_cross.at(1)+0.1), stroke: 1.5pt)
  line((sv_cross.at(0)-0.1, sv_cross.at(1)+0.1), (sv_cross.at(0)+0.1, sv_cross.at(1)-0.1), stroke: 1.5pt)
  
  // 文字标注 SV
  content((sv_circle1.at(0), sv_circle1.at(1) + 0.4), [支持向量 (SV)], size: 8pt)
  content((sv_cross.at(0), sv_cross.at(1) - 0.4), [支持向量 (SV)], size: 8pt)

  // 6. 绘制法向量 w
  let mid_point = (4, k*4 + b_mid)
  line(mid_point, (4.3, k*4 + b_mid + 1), mark: (end: ">"), stroke: 1pt)
  content((4.5, k*4 + b_mid + 0.8), [ $w$ ])

  // 7. 绘制距离标注 2/||w||
  let dist_start = (7, k*7 + b_mid + margin)
  let dist_end = (7, k*7 + b_mid - margin)
  line(dist_start, dist_end, mark: (start: ">", end: ">"), stroke: 0.5pt)
  content((7.6, k*7 + b_mid), [ $2 / norm(w)$ ])
})