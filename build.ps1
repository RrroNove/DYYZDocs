# ============================================================
# DYYZDocs 站点生成脚本
# 将单页站点拆分为多页面站点,并生成主文件跳转导航
# 运行: pwsh -NoProfile -ExecutionPolicy Bypass -File build.ps1
# 修改内容后重新运行本脚本即可重新生成全部页面
# ============================================================
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------- 公共头部 ----------
$head = @'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="__DESC__">
<title>__TITLE__</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
'@

# ---------- 公共左侧导航栏(所有页面共用) ----------
$nav = @'
<!-- ===== 左侧导航栏 ===== -->
<nav id="sideNav">
  <div class="inner">
    <div class="nav-head">
      <a href="DYYZDocs.html" class="logo">DYYZ<span>Docs</span></a>
      <button class="nav-close" onclick="closeNav()" aria-label="关闭菜单">✕</button>
    </div>
    <div class="nav-tag">都匀一中 · 新生指南</div>
    <ul class="nav-links" id="navLinks">
      <li class="nav-group open">
        <div class="nav-group-head">
          <a href="preread.html">看前须知</a>
          <button class="nav-group-toggle" onclick="toggleGroup(this)" aria-label="折叠">▸</button>
        </div>
        <ul class="nav-sublinks">
          <li><a href="preread.html#preread-audience">这份指南是给谁的</a></li>
          <li><a href="preread.html#preread-accuracy">信息准确性</a></li>
          <li><a href="preread.html#preread-howto">使用建议</a></li>
        </ul>
      </li>
      <li class="nav-group open">
        <div class="nav-group-head">
          <a href="essentials.html">新生须知</a>
          <button class="nav-group-toggle" onclick="toggleGroup(this)" aria-label="折叠">▸</button>
        </div>
        <ul class="nav-sublinks">
          <li><a href="essentials.html#es-report">报到</a></li>
          <li><a href="essentials.html#es-military">军训</a></li>
          <li><a href="essentials.html#es-uniform">三色衣</a></li>
          <li><a href="essentials.html#es-course">课程</a></li>
          <li><a href="essentials.html#es-subject">选科</a></li>
          <li><a href="essentials.html#es-class">分班</a></li>
          <li><a href="essentials.html#es-exam">考试</a></li>
        </ul>
      </li>
      <li class="nav-group open">
        <div class="nav-group-head">
          <a href="courses.html">课程建议</a>
          <button class="nav-group-toggle" onclick="toggleGroup(this)" aria-label="折叠">▾</button>
        </div>
        <ul class="nav-sublinks">
          <li class="nav-group open">
            <div class="nav-group-head">
              <a href="courses.html#course-subjects">科目概览</a>
              <button class="nav-group-toggle" onclick="toggleGroup(this)" aria-label="折叠">▸</button>
            </div>
            <ul class="nav-sublinks">
              <li><a href="courses.html#sub-yuwen">语文</a></li>
              <li><a href="courses.html#sub-shuxue">数学</a></li>
              <li><a href="courses.html#sub-yingyu">英语</a></li>
              <li><a href="courses.html#sub-wuli">物理</a></li>
              <li><a href="courses.html#sub-huaxue">化学</a></li>
              <li><a href="courses.html#sub-shengwu">生物</a></li>
              <li><a href="courses.html#sub-zhengzhi">政治</a></li>
              <li><a href="courses.html#sub-lishi">历史</a></li>
              <li><a href="courses.html#sub-dili">地理</a></li>
            </ul>
          </li>
          <li><a href="courses.html#course-select">选课建议</a></li>
          <li><a href="courses.html#course-score">赋分制度</a></li>
        </ul>
      </li>
      <li class="nav-group open">
        <div class="nav-group-head">
          <a href="life.html">校园生活</a>
          <button class="nav-group-toggle" onclick="toggleGroup(this)" aria-label="折叠">▸</button>
        </div>
        <ul class="nav-sublinks">
          <li><a href="life.html#life-canteen">食堂与餐饮</a></li>
          <li><a href="life.html#life-dorm">宿舍生活</a></li>
          <li><a href="life.html#life-day">走读</a></li>
          <li><a href="life.html#life-schedule">作息时间</a></li>
          <li><a href="life.html#life-sports">运动场地</a></li>
          <li><a href="life.html#life-club">社团与活动</a></li>
          <li><a href="life.html#life-library">图书馆</a></li>
        </ul>
      </li>
      <li class="nav-group open">
        <div class="nav-group-head">
          <a href="faq.html">常见问题</a>
          <button class="nav-group-toggle" onclick="toggleGroup(this)" aria-label="折叠">▸</button>
        </div>
        <ul class="nav-sublinks">
          <li><a href="faq.html#faq-report">报到当天需要带什么?</a></li>
          <li><a href="faq.html#faq-military">军训持续多久?</a></li>
          <li><a href="faq.html#faq-dorm">住宿如何分配?</a></li>
          <li><a href="faq.html#faq-xuanke">新高考如何选科?</a></li>
          <li><a href="faq.html#faq-canteen">食堂如何收费?</a></li>
          <li><a href="faq.html#faq-help">遇到问题找谁?</a></li>
        </ul>
      </li>
      <li class="nav-group open">
        <div class="nav-group-head">
          <a href="about.html">关于我们</a>
          <button class="nav-group-toggle" onclick="toggleGroup(this)" aria-label="折叠">▸</button>
        </div>
        <ul class="nav-sublinks">
          <li><a href="about.html#au-qqgroup">QQ群</a></li>
          <li><a href="about.html#au-editor">编辑人QQ</a></li>
        </ul>
      </li>
    </ul>
    <div class="nav-foot">
      <button class="sidebar-collapse" onclick="toggleSidebar()" aria-label="收起侧边栏">« 收起侧边栏</button>
    </div>
  </div>
</nav>

<!-- 移动端:打开按钮 + 遮罩;桌面端:侧边栏收起后浮现的展开按钮 -->
<button class="hamburger" onclick="openNav()" aria-label="打开菜单">☰</button>
<button class="sidebar-open" onclick="toggleSidebar()" aria-label="展开侧边栏">»</button>
<div class="overlay" id="overlay" onclick="closeNav()"></div>
'@

# ---------- 公共页脚 ----------
$foot = @'
<footer>
  © 2026 DYYZDocs · 为都匀一中新生编写的生活与课程指南
</footer>

<script src="script.js"></script>
</body>
</html>
'@

# ---------- 工具函数 ----------
function New-Hero {
  param([string]$h1, [string]$sub)
  return '<header class="page-hero" id="top">' + "`n" +
    '  <div class="container">' + "`n" +
    '    <h1>' + $h1 + '</h1>' + "`n" +
    '    <p class="subtitle">' + $sub + '</p>' + "`n" +
    '  </div>' + "`n" +
    '</header>'
}

function New-Page {
  param([string]$name, [string]$title, [string]$desc, [string]$hero, [string]$body)
  $html = $head.Replace('__TITLE__', $title).Replace('__DESC__', $desc)
  $html = $html + $nav + $hero + '<main>' + "`n" + $body + '</main>' + $foot
  Set-Content -LiteralPath (Join-Path $dir $name) -Value $html -Encoding utf8
  Write-Host ('生成: ' + $name)
}

# ============================================================
# 1. 看前须知
# ============================================================
$prereadBody = @'
<section id="preread">
  <div class="container">
    <div class="plain-text">
      <h4 id="preread-audience">这份指南是给谁的</h4>
      <p>本指南面向都匀一中新生，同时欢迎在校生进行参考对比。</p>
      <h4 id="preread-accuracy">信息准确性</h4>
      <p>指南内容基于往届经验与公开信息整理,可能存在出入或更新滞后。涉及报到安排、选科政策、作息时间等具体事项,请以学校官方通知为准。</p>
      <h4 id="preread-howto">使用建议</h4>
      <p>建议先浏览左侧目录,快速了解指南结构;需要时再根据导航定位到具体板块。遇到与实际情况不符的地方,欢迎通过文末联系方式反馈。</p>
    </div>
  </div>
</section>
'@
New-Page -name 'preread.html' -title '看前须知 - DYYZDocs' -desc '都匀一中新生指南 · 看前须知' `
  -hero (New-Hero -h1 '看前须知' -sub '开始阅读之前,先了解这份指南的定位与注意事项。') `
  -body $prereadBody

# ============================================================
# 2. 新生须知
# ============================================================
$essentialsBody = @'
<section id="essentials">
  <div class="container">
    <div class="plain-text">
      <h4 id="es-report">报到</h4>
      <p>入学报到一般在开学前进行,请留意学校通知的具体时间、地点与流程。当天携带录取通知书、身份证或户口本复印件、团员档案等材料,按指引完成报到、入住与领取生活用品。</p>
      <h4 id="es-military">军训</h4>
      <p>军训是入学第一课,通常持续一周左右。按时参加、听从指挥,建议备好防晒用品、水壶和舒适的运动鞋,训练中身体不适要及时向教官或老师报告。</p>
      <h4 id="es-uniform">三色衣</h4>
      <p>都匀一中的三种校服分别代表不同年级，分别为红、黄、蓝三色，每个年级都有各自的年级部，关于假期、校内活动等事件由三个年级部一起协商并作出协调。</p>
      <h4 id="es-course">课程</h4>
      <p>高一课程包括语文、数学、外语等必修科目,以及新高考下的其他科目。课程进度比初中明显加快,建议尽早适应节奏,重视课堂效率与课后预习复习。</p>
      <h4 id="es-subject">选科</h4>
      <p>贵州实行新高考"3+1+2"模式:语数外为必考,再从物理、历史中选择 1 门作为首选科目,从政治、地理、化学、生物中选择 2 门作为再选科目。建议结合兴趣、优势学科与目标专业方向综合决定。</p>
      <h4 id="es-class">分班</h4>
      <p>入学初会进行分班,通常综合参考入学成绩等因素;选科确定后可能再次重新分班。请以学校通知为准,不必过度焦虑,分班只是开始,后续的努力更重要。</p>
      <h4 id="es-exam">考试</h4>
      <p>高中阶段主要有月考、期中、期末等考试。成绩可用于检验学习效果、了解自身排名,也为选科提供参考。认真对待每一次考试,及时复盘总结。</p>
    </div>
  </div>
</section>
'@
New-Page -name 'essentials.html' -title '新生须知 - DYYZDocs' -desc '都匀一中新生指南 · 新生须知' `
  -hero (New-Hero -h1 '新生须知' -sub '入学前需要了解的证件、纪律与注意事项。') `
  -body $essentialsBody

# ============================================================
# 3. 课程建议(科目概览 · 选课建议 · 赋分制度 整合页)
# ============================================================
$coursesBody = @'
<section id="courses">
  <div class="container">

    <!-- 1. 科目概览 -->
    <h3 class="sub-title" id="course-subjects"><span class="num">01</span>科目概览 · 9 大学科</h3>
    <p class="sub-sub">九大科目的学习特点与建议,帮助你快速建立学科认知。</p>
    <div class="plain-text">
      <h4 id="sub-yuwen">语文</h4>
      <p>语言与文字的艺术,积累与表达并重。这门学科靠日积月累,很难临时突击,建议坚持阅读与写作,循序渐进地提升语感与表达能力。</p>
      <h4 id="sub-shuxue">数学</h4>
      <p>区分度最高的科目,强调逻辑思维与运算能力。学习上要重视概念理解,做好错题整理与题型归纳,循序渐进地建立知识体系。</p>
      <h4 id="sub-yingyu">英语</h4>
      <p>以词汇为基石,听说读写缺一不可。建议坚持每日阅读输入,利用碎片时间积累词汇,听力与口语也要常练不辍。</p>
      <h4 id="sub-wuli">物理</h4>
      <p>对抽象思维要求较高,重在理解物理过程与规律。公式不只是记忆,更要会推导、会应用,学习时多从模型和实际场景入手。</p>
      <h4 id="sub-huaxue">化学</h4>
      <p>知识点零碎,理解与记忆并重。方程式与实验是常考的重点,建议在理解原理的基础上反复练习,逐步建立清晰的知识网络。</p>
      <h4 id="sub-shengwu">生物</h4>
      <p>一门回归教材的学科,细节非常多。概念、图像与过程要反复翻看、及时巩固,扎实的基础是取得高分的前提。</p>
      <h4 id="sub-zhengzhi">政治</h4>
      <p>紧密联系时事热点,对术语规范与逻辑条理要求高。学习时要多关注新闻时事,学会用学科语言有条理地分析和表达观点。</p>
      <h4 id="sub-lishi">历史</h4>
      <p>重在时间线的梳理与史实的理解,强调材料分析与历史思维。建议按时间轴整理脉络,多读史料,培养"论从史出"的意识。</p>
      <h4 id="sub-dili">地理</h4>
      <p>自然与人文相结合,图表题是重点。建议强化图表判读与区域分析的训练,把零散的知识放到具体区域中去理解记忆。</p>
    </div>

    <!-- 2. 选课建议 -->
    <h3 class="sub-title" id="course-select"><span class="num">02</span>选课建议</h3>
    <p class="sub-sub">"3+1+2"中,"1"要在物理与历史之间二选一,这是最关键的一步。</p>
    <div class="plain-text">
      <h4>物理方向</h4>
      <p>面向理工、医学、农学等大多有选科要求的专业,适合逻辑思维强、理科基础好的同学。常搭配"物理+化学"这类专业覆盖率高的组合,将来填报志愿时选择面更宽。</p>
      <h4>历史方向</h4>
      <p>以人文、社科、语言类专业为主,适合记忆与文字表达有优势的同学。组合选择较为灵活,竞争分布相对均衡,同样能通往不错的专业与高校。</p>
      <h4>选科原则</h4>
      <p>贵州省实行新高考"3+1+2"模式。选科前建议结合个人兴趣、优势学科与目标专业方向综合决定,不要盲目跟风"热门组合"。选科一旦确定中途调整成本较高,请认真对待选科宣讲与咨询环节。</p>
    </div>

    <!-- 3. 赋分制度 -->
    <h3 class="sub-title" id="course-score"><span class="num">03</span>赋分制度</h3>
    <p class="sub-sub">只有"再选科目"(政治、地理、化学、生物)按等级赋分计入高考总分。</p>
    <div class="plain-text">
      <h4>计分方式</h4>
      <p>高考中,语文、数学、外语与首选科目(物理或历史)按原始分直接计入总分;只有再选科目(政治、地理、化学、生物)实行等级赋分,依据的是全省考生排名而非卷面分。</p>
      <h4>等级划分</h4>
      <p>赋分按排名比例划分为五个等级:前 15% 为 A 档,赋分区间 100~86 分;前 50% 为 B 档,85~71 分;前 85% 为 C 档,70~56 分;前 98% 为 D 档,55~41 分;最后 2% 为 E 档,40~30 分,赋分下限为 30 分。</p>
      <h4>排名决定赋分</h4>
      <p>也就是说,赋分结果取决于你在同科考生中的相对位置,而不只是卷面分数。因此选科时也要考虑同科考生的整体水平,合理评估自身优势。以上比例与区间为通用参考,请以贵州省教育考试院最新公布为准。</p>
    </div>

  </div>
</section>
'@
New-Page -name 'courses.html' -title '课程建议 - DYYZDocs' -desc '都匀一中新生指南 · 课程建议' `
  -hero (New-Hero -h1 '课程建议' -sub '新高考下,了解科目、学会选科、看懂赋分,才能少走弯路。') `
  -body $coursesBody

# ============================================================
# 4. 校园生活
# ============================================================
$lifeBody = @'
<section id="life">
  <div class="container">
    <div class="plain-text">
      <h4 id="life-canteen">食堂与餐饮</h4>
      <p>介绍校内食堂分布、菜品种类与价格区间,以及充值、打饭的注意事项。</p>
      <h4 id="life-dorm">宿舍生活</h4>
      <p>说明宿舍几人间、床铺尺寸、基本设施与用电用水规定、熄灯时间等。</p>
      <h4 id="life-day">走读</h4>
      <p>家庭住址较近的同学可申请走读,通常需家长同意并办理相关手续,向班主任或政教处提交申请。走读生应注意上下学安全,严格遵守作息时间,不迟到不早退。</p>
      <h4 id="life-schedule">作息时间</h4>
      <p>列出一天的作息安排:早读、上课、午休、晚自习与就寝时间节点。</p>
      <h4 id="life-sports">运动场地</h4>
      <p>介绍操场、篮球场、羽毛球场、体育馆等场地的开放时间与使用规则。</p>
      <h4 id="life-club">社团与活动</h4>
      <p>学生会、各类社团与校园活动的纳新时间和参与方式,丰富课余生活。</p>
      <h4 id="life-library">图书馆</h4>
      <p>图书馆开放时间、借阅规则与自习座位管理,学会用好这一资源。</p>
    </div>
  </div>
</section>
'@
New-Page -name 'life.html' -title '校园生活 - DYYZDocs' -desc '都匀一中新生指南 · 校园生活' `
  -hero (New-Hero -h1 '校园生活' -sub '吃、住、行、玩,提前了解,从容入学。') `
  -body $lifeBody

# ============================================================
# 5. 常见问题
# ============================================================
$faqBody = @'
<section id="faq">
  <div class="container">
    <div class="plain-text">
      <h4 id="faq-report">报到当天需要带什么?</h4>
      <p>一般需要:录取通知书、身份证/户口本复印件、团员档案、个人生活用品(被褥是否统一发放请以学校通知为准)、换洗衣物与常用药品。具体清单以录取通知书内说明为准。</p>
      <h4 id="faq-military">军训持续多久?需要准备什么?</h4>
      <p>通常为一周左右,具体以学校安排为准。建议准备:防晒霜、水壶、舒适的运动鞋、创可贴、常用药,以及良好的体能储备。</p>
      <h4 id="faq-dorm">住宿如何分配?可以走读吗?</h4>
      <p>宿舍一般按班级/性别集中分配,入住后按床位安排即可。走读政策视学校与年级管理规定而定,有需要可向班主任或政教处咨询申请。</p>
      <h4 id="faq-xuanke">新高考如何选科?</h4>
      <p>贵州实行"3+1+2"模式:语数外为必考,再从物理/历史中选择 1 门,从政、地、化、生中选择 2 门。建议结合兴趣、成绩与目标专业的选科要求综合决定。</p>
      <h4 id="faq-canteen">食堂如何收费?可以点外卖吗?</h4>
      <p>通常使用校园卡/饭卡充值消费,价格公开透明。关于外卖与手机使用,各校规定不一,请遵守学校纪律要求,以班主任通知为准。</p>
      <h4 id="faq-help">遇到学习或生活问题可以找谁?</h4>
      <p>学习问题先找任课老师或班主任;心理与情绪问题可联系学校心理辅导室;生活问题(宿舍、饭卡等)可找宿管或相关后勤部门。</p>
    </div>
  </div>
</section>
'@
New-Page -name 'faq.html' -title '常见问题 - DYYZDocs' -desc '都匀一中新生指南 · 常见问题' `
  -hero (New-Hero -h1 '常见问题' -sub '新生最常问的问题与解答。') `
  -body $faqBody

# ============================================================
# 6. 关于我们
# ============================================================
$aboutBody = @'
<section id="about-us">
  <div class="container">
    <div class="plain-text">
      <h4 id="au-qqgroup">QQ群</h4>
      <p>都匀一中新生交流群,群内学长学姐在线答疑,也会同步发布指南更新通知。<br>群号:<b>请填写 QQ 群号</b></p>
      <h4 id="au-editor">编辑人QQ</h4>
      <p>本指南由热心同学整理,如有疑问或建议可私聊编辑人。<br>编辑人QQ:<b>请填写编辑人 QQ 号</b></p>
    </div>
  </div>
</section>
'@
New-Page -name 'about.html' -title '关于我们 - DYYZDocs' -desc '都匀一中新生指南 · 关于我们' `
  -hero (New-Hero -h1 '关于我们' -sub '加入我们的交流群,随时提问与交流。') `
  -body $aboutBody

# ============================================================
# 主文件:首页(Hero + 板块导航)
# ============================================================
$mainHero = @'
<!-- ===== Hero ===== -->
<header class="hero" id="top">
  <div class="container">
    <div class="avatar">🎓</div>
    <h1>欢迎来到都匀一中</h1>
    <p class="subtitle">DYYZDocs · 新生生活指导与课程建议</p>
    <p class="intro">为初入都匀一中的你整理的一份学习与生活指南:从报到注册到新高考选科,从食堂宿舍到社团活动,一站式解答你的大多数疑问。</p>
    <div class="hero-actions">
      <a href="preread.html" class="btn btn-primary">开始阅读指南</a>
      <a href="faq.html" class="btn btn-ghost">查看常见问题</a>
    </div>
  </div>
</header>
'@

$mainBody = @'
<!-- ===== 板块导航 ===== -->
<section id="sections">
  <div class="container">
    <h2 class="section-title">板块导航</h2>
    <p class="section-sub">指南已拆分为独立页面,点击任意卡片即可跳转阅读。</p>
    <div class="cards">
      <a class="card" href="preread.html"><h3>看前须知</h3><p>这份指南是给谁的、信息准确性、使用建议。</p></a>
      <a class="card" href="essentials.html"><h3>新生须知</h3><p>报到、军训、三色衣、课程、选科、分班、考试。</p></a>
      <a class="card" href="courses.html"><h3>课程建议</h3><p>科目概览、选课建议、赋分制度。</p></a>
      <a class="card" href="life.html"><h3>校园生活</h3><p>食堂、宿舍、走读、作息、运动、社团、图书馆。</p></a>
      <a class="card" href="faq.html"><h3>常见问题</h3><p>新生最常问的问题与解答。</p></a>
      <a class="card" href="about.html"><h3>关于我们</h3><p>加入交流群,随时提问与交流。</p></a>
    </div>
  </div>
</section>
'@

$mainHtml = $head.Replace('__TITLE__', 'DYYZDocs').Replace('__DESC__', '都匀一中新生生活指南') + $nav + $mainHero + $mainBody + $foot
Set-Content -LiteralPath (Join-Path $dir 'DYYZDocs.html') -Value $mainHtml -Encoding utf8
Write-Host '生成: DYYZDocs.html'
Write-Host '全部页面生成完毕。'
