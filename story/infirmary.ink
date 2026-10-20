// 文案里的药舍使用现有 infirmary（病舍）场景。
=== inspect_saint_luke ===
~ observed_luke = true
一位圣人坐在书案前，低头望着眼前摊开的书本。他穿着红色的长袍，衣角落在一头伏在他脚边的牛犊身上。画框下方写着一行金色的字：SANCTVS LVCAS # speaker:圣路加 # tone:description
+ [（触摸画像） # tone:action]
    ~ touched_luke = true
    -> touch_saint_luke
+ [（离开。） # tone:action]
    -> END

=== touch_saint_luke ===
你将指尖轻轻搭在那张画上。画布摸起来凉凉的，褪色的地方摸起来格外光滑——许多临死的人也像你一样，将手指停在这里。 # speaker:金德日赫 # tone:description
-> END

=== inspect_medicine_cabinet ===
~ observed_medicine_cabinet = true
药柜威严地矗立着，把手上挂着一只锁。你明白，它不会告诉任何人钥匙在哪里。 # speaker:药柜 # tone:description
-> END

=== lukas_conversation ===
{ lukas_response == "well":
    -> lukas_return_well
}
{ lukas_response == "unwell":
    -> lukas_return_unwell
}
“你生病了吗？” # speaker:卢卡什
+ [“我感觉没有，卢卡什兄弟。”]
    ~ lukas_response = "well"
    -> lukas_well
+ [“我感觉...有些头疼脑热...四肢发冷....”]
    ~ lukas_response = "unwell"
    -> lukas_exam

=== lukas_well ===
“那你还站在这里干什么？” # speaker:卢卡什
+ [（离开。） # tone:action]
    -> END

=== lukas_exam ===
“那就走近点，让我看看。” # speaker:卢卡什
卢卡斯轻轻碰了碰你的手指，又摸了摸你的前额。接着，他让你张开嘴，又用一根小钳子夹住了你的舌头，朝外拉出去。 # speaker:金德日赫 # tone:description
你很快便后悔了——在这个姿势下，卢卡什可以往你嘴里倒入任何东西。哪怕是一碗魔鬼的胆汁，你也只能任由它从你的嗓子里淌过，咽进肚子里。 # speaker:金德日赫 # tone:description
幸而，卢卡什很快放开了你。你仿佛得了救一般，连忙活动自己僵硬的嘴巴。 # speaker:金德日赫 # tone:description
“你的舌苔很干净，什么毛病也没有，”他一面说，一面拿手帕擦拭着小钳子，“用这种办法是没法逃过日课的，快出去吧。” # speaker:卢卡什
-> END

=== lukas_return_well ===
“去忙你的吧，金德日赫。我还得把这些给研磨了。” # speaker:卢卡什
-> END

=== lukas_return_unwell ===
“我这里没有能逃掉日课的药。” # speaker:卢卡什
-> END
