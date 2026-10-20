// 首次进入南回廊强制播放。结束后副院长离开，安布罗斯留在柱旁。
=== cloister_south_intro ===
“那么...名额的事情...” # speaker:安布罗斯
“还没有定下来。” # speaker:塞维里诺
“院长大人说，他还想听听格雷戈尔修士的意见。” # speaker:塞维里诺
“格雷戈尔修士…可是…为什么？他同我们一般年纪…” # speaker:安布罗斯
“正因为他同你们一般年纪。” # speaker:塞维里诺
“院长说，他总得听听年轻修士的意见。” # speaker:塞维里诺
“可是…” # speaker:安布罗斯
“不要担心，安布罗斯兄弟。院长会看见你为我们的主所做的一切的。” # speaker:塞维里诺
副院长将手放在年轻的修士的肩膀上，像安抚一只鸟那样温柔地拍了拍。年轻的修士张开嘴，似乎像说些什么，却没有发出声音。最后，他只能目视着副院长沿着回廊远去。 # speaker:回廊 # tone:description
~ cloister_intro_seen = true
回廊吞下了鞋底踩在石头上轻柔的摩擦声。 # speaker:回廊 # tone:description
-> END

=== ambrose_conversation ===
{ ambrose_met:
    -> ambrose_return
}
~ ambrose_met = true
年轻的修士把眼睛藏在羊皮纸的后边，警惕地盯着你。 # speaker:安布罗斯 # tone:description
“你都听见了。” # speaker:安布罗斯
+ [“不，我没有听见。” # action:离开]
    ~ ambrose_response = "deny"
    -> END
+ [（沉默地回望他） # tone:action]
    -> ambrose_silent

=== ambrose_silent ===
“…你确实听见了。”他闭上眼睛，片刻后又重新睁开。“…你想知道什么？” # speaker:安布罗斯
+ [“我什么都不想知道，那是你的事情。”]
    ~ ambrose_response = "respect"
    -> ambrose_respect
+ [（继续沉默地回望着他） # tone:action]
    ~ ambrose_response = "leipzig"
    -> ambrose_leipzig

=== ambrose_respect ===
年轻人似乎有些惊讶。“谢…谢谢，”过了一会儿，他才想起来说，“愿我们的主看顾你。” # speaker:安布罗斯
-> END

=== ambrose_leipzig ===
“好吧…我想去莱比锡。” # speaker:安布罗斯
“每隔几年，修道院会送一个兄弟去大学进修。我正在校订一些……圣歌。核对年代、抄本，还有同一首歌的不同版本。有时候两份抄本只差一个词…那个词为什么会变？我在这里永远也找不到答案。”他的拇指沿着另一只手的指甲边缘来回摩挲。 # speaker:安布罗斯
“…大学里应该有人能告诉我答案…或者，至少有人能告诉我哪里能找到答案。” # speaker:安布罗斯
“不过，要先听格雷戈尔修士的意见…我不知道他肯不肯替我说句话。他可能更喜欢克莱门斯那样的人。克莱门斯总是……” # speaker:安布罗斯
年轻人突然停住了。他的脸色发白，似乎意识到自己说了太多。他的手指骤然抓住袍袖的边缘，过了好一会儿才慢慢松开。“抱歉，”他低下头说，“…我说得太多了。” # speaker:安布罗斯
-> END

=== ambrose_return ===
安布罗斯安静地靠着柱子，拇指反复刮过另一只手的指甲边缘。袖口已经被他揉皱了。 # speaker:安布罗斯 # tone:description
-> END
