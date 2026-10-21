// 来源：亨利d1对话✔.md（铁匠亨利，d1 村内对话）
// 转换日期：2026-10-21
// 结构：开场 → 两个主分支（生意/陌生人）→ 分支2内含嵌套分支(2.1/2.2) → （分支结束）汇合 → 通用结尾
// 说明：亨利对话无条件分支；henry_talked 变量统一声明于 day1.ink。
=== henry_d1 ===
铁匠正在铁砧前工作，火花溅洒在地上。他留着胡髯，身材宽阔，长着一张不容易被忘记的脸，你却觉得似乎从来没有在村里见过他。看到你前来，他放下火钳。 # speaker:旁白 # tone:description
“愿上帝保佑您，先生。” # speaker:金德日赫
“愿上帝保佑你。” # speaker:亨利
他面色平和。 # speaker:亨利 # tone:description
“你一定就是那位见习修士。” # speaker:亨利
“是的，先生。我是金德日赫，是宁谷修道院的见习修士。” # speaker:金德日赫
“我是亨利，如你所见，铁匠亨利。” # speaker:亨利
沉默蔓延片刻。他似乎是个寡言少语的人。 # speaker:亨利 # tone:description
+ [“生意还好吗？”]
    -> henry_business
+ [“我好像从未见过您。”]
    -> henry_stranger

=== henry_business ===
“铁匠铺的生意还好吗？” # speaker:金德日赫
“很幸运，还不错。人们总会需要新的铁器，我也可以帮人修理。” # speaker:亨利
“那太好了。” # speaker:金德日赫
-> henry_close

=== henry_stranger ===
“我好像从未见过您。” # speaker:金德日赫
“我才刚刚来到村里，那是你应该已经去了修道院。” # speaker:亨利
“我也不太喜欢出门。” # speaker:亨利
+ [“是这样吗...”]
    -> henry_work
+ [“可您却知道我是谁。”]
    -> henry_knows

=== henry_work ===
“是这样吗...” # speaker:金德日赫
“总有做不完的工作把人留在铺子里。” # speaker:亨利
但他看起来并不是在抱怨。 # speaker:亨利 # tone:description
“而且附近也有金色的田野。” # speaker:亨利
-> henry_close

=== henry_knows ===
“可您却知道我是谁。” # speaker:金德日赫
“人们时不时会谈论起你。” # speaker:亨利
“他们说了什么？” # speaker:金德日赫
“我不喜欢谈论别人。” # speaker:亨利
-> henry_close

// 两个主分支在此汇合（对应源稿（分支结束）之后的通用结尾）
=== henry_close ===
~ henry_talked = true
“有什么我可以为你做的吗？” # speaker:亨利
“我想...暂时没有。” # speaker:金德日赫
亨利的胡髯下再次露出和善的微笑。 # speaker:亨利 # tone:description
“有需要随时来找我。” # speaker:亨利
-> END
