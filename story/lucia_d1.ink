// 来源：卢齐娅d1对话✔.md（集市神秘女子卢齐娅，d1 村内对话）
// 转换日期：2026-10-21
// 结构：要不要追？→ 两分支；追则进入相识对话 → 条件分支【已/尚未和多罗塔对话】→
//       尚未分支内：去找 / 继续对话 → 森林话题两问皆可(2.2.1/2.2.2) → 玛丽娜子分支(2.2.2.1/2.2.2.2) → 【通用结尾】
// 说明：talked_to_dorota / lucia_met / lucia_asked_why / lucia_asked_marina 变量统一声明于 day1.ink；
//       2.2.1/2.2.2 用「选项全部展示 + 回环 + 标志位」实现两问皆可。
=== lucia_d1 ===
一位貌美的年轻女子正在集市里闲逛，你很难不注意到她披散的深色长发和红色披肩，以及那双琥珀色的大眼睛——可她只是一闪而过，在你的眼底留下一个影子。 # speaker:旁白 # tone:description
要追上去吗？ # speaker:旁白 # tone:description
+ [“可是还有扬兄弟交代的工作。”]
    -> lucia_leave
+ [“追随她。”]
    -> lucia_follow

=== lucia_leave ===
于是你前往下一个目的地。 # speaker:旁白 # tone:description
-> END

=== lucia_follow ===
集市上有太多的人，你无法辨别她去向了哪个方向，唯一能做地只有凭借模糊的印象盲目寻找，并祈祷上帝允许你再次遇见她。 # speaker:旁白 # tone:description
在售卖首饰的小摊前你最终发现了那位女子，她正在仔细端详一对银耳饰。你看到她发丝间的耳环有和瞳孔相同的色彩。 # speaker:旁白 # tone:description
你笨拙地试图同她搭话，努力不让自己的声音听起来结结巴巴。 # speaker:金德日赫 # tone:description
“愿，愿上帝保佑你，女士。” # speaker:金德日赫
她看向你，轻笑一声。 # speaker:女子 # tone:description
“上帝的保佑，连同我的那份一起给你吧，小修士。请叫我卢齐娅。” # speaker:女子
“你好，卢齐娅。我是金德日赫，是宁谷修道院的见习修士。” # speaker:金德日赫
“你好，金德日赫。你来找我有什么事吗？” # speaker:卢齐娅
你紧张地咽了口唾沫。 # speaker:金德日赫 # tone:description
“我...我在找酒馆的老板，你有看到她吗？” # speaker:金德日赫
~ lucia_met = true
{ talked_to_dorota:
    -> lucia_dorota_already
}
-> lucia_dorota_notyet

// 条件分支：已和多罗塔对话
=== lucia_dorota_already ===
卢齐娅看穿了你拙劣的借口。她向你俯下身，嬉笑道： # speaker:卢齐娅 # tone:description
“你不是才同她说过话，怎么这就找不到啦？” # speaker:卢齐娅
-> END

// 条件分支：尚未和多罗塔对话
=== lucia_dorota_notyet ===
“她就在那里，看，你要去找她吗？” # speaker:卢齐娅
卢齐娅向你指出一位带着深色头巾的妇人。要去找她吗？ # speaker:卢齐娅 # tone:description
+ [“去找。”]
    -> lucia_go
+ [“继续和卢齐娅对话。”]
    -> lucia_talk

=== lucia_go ===
踌躇。卢齐娅笑容灿烂，可你总有一丝不安。你应该抓紧完成扬兄弟交代的任务才对。 # speaker:金德日赫 # tone:description
“是...我想是的。谢谢你。” # speaker:金德日赫
你谢过这位神秘的女子，匆忙离开。 # speaker:旁白 # tone:action
-> END

=== lucia_talk ===
是的，你应该去，可是时间真有这么紧急吗？ # speaker:金德日赫 # tone:description
“我想应该...来得及。”你喃喃道。 # speaker:金德日赫
“嗯？” # speaker:卢齐娅
她微微偏头，饶有兴味地看着你。 # speaker:卢齐娅 # tone:description
“您的披肩很特别，很好看。” # speaker:金德日赫
“在森林中生活，披肩可以抵挡露水。” # speaker:卢齐娅
“您住在森林中吗？” # speaker:金德日赫
“玛丽娜要是知道我把一切都告诉你肯定会很生气的，可你只是个穿灰袍子的小朋友。” # speaker:卢齐娅
“往林子最深最密的地方去，你就能找到我们。但是你来做什么呢？你穿着上帝的衣裳，就应该留在上帝的居所里。” # speaker:卢齐娅
-> lucia_forest

// 两问皆可（对应源稿备注「可以两个都选一遍」）：选项全部展示，选过即隐藏，回环直到问完。
=== lucia_forest ===
{ not lucia_asked_why:
    + [“什么不想让我去？”]
        ~ lucia_asked_why = true
        -> lucia_why
}
{ not lucia_asked_marina:
    + [“玛丽娜是谁？”]
        ~ lucia_asked_marina = true
        -> lucia_marina
}
-> lucia_general

=== lucia_why ===
“啊...为什么？” # speaker:金德日赫
“男人和基督徒总想教导我应当怎么做，不应当怎么做。你成年了吗？” # speaker:卢齐娅
“是的，我成年了。” # speaker:金德日赫
“那更糟了，你是一个领了圣职的男人。” # speaker:卢齐娅
-> lucia_forest

=== lucia_marina ===
“玛丽娜？” # speaker:金德日赫
“自从营地里的男人都离世后，她就负责带领大家。” # speaker:卢齐娅
+ [“请节哀。”]
    -> lucia_sympathy
+ [“发生什么了？为什么人们在死去？”]
    -> lucia_war

=== lucia_sympathy ===
“抱歉。” # speaker:金德日赫
“这没什么。每个人都会死的，剩下的人只能尽量活下去。” # speaker:卢齐娅
-> lucia_general

=== lucia_war ===
“发生什么了？为什么人们在死去？” # speaker:金德日赫
“动乱，战争。” # speaker:卢齐娅
她神色平静。 # speaker:卢齐娅 # tone:description
“基督徒争执教义，却要其他人付出代价。” # speaker:卢齐娅
-> lucia_general

// 【通用结尾】
=== lucia_general ===
“可你知道什么呢？你还只是一个小朋友。” # speaker:卢齐娅
“去做你应该做的事情吧。” # speaker:卢齐娅
-> END
