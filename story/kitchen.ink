// 厨房保留当前地图连接；三种打招呼方式只改变语气。
=== rodrigo_conversation ===
{ rodrigo_met:
    -> rodrigo_return
}
~ rodrigo_met = true
棕色皮肤的年轻人正沉默地解剖着鱼。他把刀尖刺进鱼肚子里，沿着鱼背抹开。火焰在他的胳膊肘旁边噼啪跃动，就像一颗不会停息的心脏。 # speaker:罗德里戈 # tone:description
“早安，金德日赫。” # speaker:罗德里戈
+ [“早安，罗德里戈。”]
    ~ rodrigo_response = "greet"
    -> rodrigo_bread
+ [“你怎么知道是我？”]
    ~ rodrigo_response = "recognize"
    -> rodrigo_bread
+ [（沉默） # tone:action]
    ~ rodrigo_response = "silent"
    -> rodrigo_bread

=== rodrigo_bread ===
他没有听你的话，只是抬起胳膊，指了指一旁的面包篮。 # speaker:罗德里戈 # tone:description
“如果你饿了，可以先吃点。”接着，他便继续处理手中的鱼去了。 # speaker:罗德里戈
-> END

=== rodrigo_return ===
棕色皮肤的年轻人没有抬头。他用刀背将处理好的鱼推到砧板的另一端，腾出一小块地方。 # speaker:罗德里戈 # tone:description
-> END
