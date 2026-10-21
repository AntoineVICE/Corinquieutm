// 来源：多罗塔d1对话✔️.md（酒馆老板多罗塔，d1 村内对话）
// 转换日期：2026-10-21
// 结构：订购菜品（线性）→ 麦酒两问皆可（为什么我送/他为什么不自己来取）→ 好的/我不想送 终选
// 说明：1.与2.两个提问为「两问皆可」（同卢齐娅稿，标志位+回环实现），之后才出现「好的/我不想送」；
//       飞书图片链接已忽略；talked_to_dorota / dorota_asked_why / dorota_asked_take 变量统一声明于 day1.ink。
=== dorota_d1 ===
瞻礼市集，售卖水果和新鲜蔬菜的摊位前站着一位高挑美丽的妇人，单手叉腰，神色凌厉，正与摊主交谈着什么。她穿着深色的裙子，裙摆系在腰间。你注意到她与众不同的深灰色头巾——她就是要找的人。 # speaker:旁白 # tone:description
“愿主保佑您，夫人。” # speaker:金德日赫
寡妇留意到年轻的见习修士，转身面向你，身体的重心放在一条腿上。盘起的金发在头巾下随着转身的动作一晃。她的似乎习惯性略微撅着嘴，丰满的唇透露出一种倔强的滋味。 # speaker:妇人 # tone:description
“也保佑你，小伙子。你找我什么事？” # speaker:妇人
“我是金德日赫，是宁谷修道院的见习修士。” # speaker:金德日赫
“您是酒馆的老板，多罗塔吗？今晚修道院内设宴招待客人，扬兄弟派我来向您订购菜品。” # speaker:金德日赫
多罗塔微微偏头，她看向你的袍子。不带恶意的目光几乎将你穿透。 # speaker:多罗塔 # tone:description
她短促点头。 # speaker:多罗塔 # tone:description
“是我。请稍等。” # speaker:多罗塔
她转身和摊主结账，然后领着你走到人流更少的角落。 # speaker:多罗塔 # tone:description
“你们要定什么？” # speaker:多罗塔
你拿出扬兄弟给你的纸条，开始读清单。 # speaker:金德日赫 # tone:description
“蜜酒香料焖鸡，四份。” # speaker:金德日赫
“酒馆里自然有蜜酒，额外的香料恰好可以在集市上购买。” # speaker:多罗塔
你拿出扬兄弟给你的纸条，开始读清单。 # speaker:金德日赫 # tone:description
“蜂蜜梨膏，一篮。” # speaker:金德日赫
“七月并不是梨子成熟的季节，但我的仓库里应当有去年冬天的储藏。” # speaker:多罗塔
“还要狗鱼配酸香绿酱，两份。” # speaker:金德日赫
多罗塔嘴角微微上扬。 # speaker:多罗塔 # tone:description
“品味不错，这是我的拿手好菜。” # speaker:多罗塔
“上面说要新鲜的狗鱼，不能用鱼干。” # speaker:金德日赫
多罗塔点点头。 # speaker:多罗塔 # tone:description
“很合理，我让雇工下午去河里抓鱼。” # speaker:多罗塔
“端上桌时要整鱼。” # speaker:金德日赫
多罗塔叹了口气 # speaker:多罗塔 # tone:description
“还有，所有菜都要用高级香料。” # speaker:金德日赫
“这次的客人是救过神父的命吗？” # speaker:多罗塔
“是奥尔德里希大人，修道院的世俗资助人。” # speaker:金德日赫
你老实回答。 # speaker:金德日赫 # tone:description
“...那还真是。” # speaker:多罗塔
“如果抓不到鱼该怎么办呢？” # speaker:金德日赫
经验丰富的酒馆老板有备而来。 # speaker:多罗塔 # tone:description
“磨坊边上有一个池塘，里面养了不少鱼。如果河里抓不到，我会让雇工去那里取。” # speaker:多罗塔
“说到磨坊，你们今天还会去那里吗？磨坊主在我这里订了麦酒，你可以替我送过去吗？” # speaker:多罗塔
-> dorota_questions

// 麦酒两问皆可：选过即隐藏，回环直到问完，之后进入「好的/我不想送」终选。
=== dorota_questions ===
{ not dorota_asked_why:
    + [“为什么要我送？”]
        ~ dorota_asked_why = true
        -> dorota_why
}
{ not dorota_asked_take:
    + [“他为什么不自己来取？”]
        ~ dorota_asked_take = true
        -> dorota_take
}
-> dorota_deliver

=== dorota_why ===
你有点意外。 # speaker:金德日赫 # tone:description
“为什么是我去送？” # speaker:金德日赫
多罗塔双手叉腰。 # speaker:多罗塔 # tone:description
“因为我所有雇工都要加紧准备你们定的菜。” # speaker:多罗塔
-> dorota_questions

=== dorota_take ===
“他为什么不自己来取呢？” # speaker:金德日赫
多罗塔皱起眉，面露嫌色。 # speaker:多罗塔 # tone:description
“大约是又醉倒在面粉堆里了吧...” # speaker:多罗塔
“他这人怎么这样。” # speaker:金德日赫
酒馆老板叹了口气。 # speaker:多罗塔 # tone:description
“大家都有各自的烦心事。” # speaker:多罗塔
-> dorota_questions

// 终选：送 / 不送（二者择一，选完对话结束）
=== dorota_deliver ===
+ [“好的。”]
    -> dorota_yes
+ [“我不想送。”]
    -> dorota_no

=== dorota_yes ===
“是的，我想我们等下会去磨坊。乐意效劳。” # speaker:金德日赫
“谢谢你，小伙子。你可以在酒馆里取到酒罐。” # speaker:多罗塔
~ talked_to_dorota = true
-> END

=== dorota_no ===
你严辞拒绝。 # speaker:金德日赫 # tone:description
“我是一名修士，我不该助长他人酗酒的恶习。” # speaker:金德日赫
多罗塔咧嘴笑起来。 # speaker:多罗塔 # tone:description
“你说得对，他也是该醒醒酒了。等空下来我再找人送过去。” # speaker:多罗塔
~ talked_to_dorota = true
-> END
