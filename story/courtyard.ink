// D1-02 外院。巴托什与奥尔德里希是不同人物，以详细对白为准。
=== courtyard_intro ===
# title:外院 · 晨祷
“噢，没关系，”骑士拧了拧自己的胡须，露出一个温和的、迷人的微笑，“我相信你们会解决这件事的，对吗？” # speaker:德拉霍尼采的巴托什
“当然，巴托什大人，只是我们要先同扬兄弟——他负责粮食的管理——确认一下，然后我想——” # speaker:菲利普修士
“对吗？” # speaker:德拉霍尼采的巴托什
“...会的，大人，我们会安排妥当。” # speaker:菲利普修士
“劳烦扬修士多费心了。我家大人很珍爱那五匹匈牙利马——西吉斯蒙德陛下的赏赐。”骑士依旧保持着迷人温和的微笑。他稍稍侧过身，为菲利普让出了路。 # speaker:德拉霍尼采的巴托什
~ courtyard_intro_seen = true
+ [“发生什么事了？”]
    ~ courtyard_response = "ask"
    -> philipp_request
+ [（沉默地注视着眼前发生的一切，思绪飘散在远方。） # tone:action # action:离开]
    ~ courtyard_response = "silent"
    -> END

// 沉默离开后允许补问；听过口信才催促。这是已确认的接续规则。
=== philipp_followup ===
# title:外院 · 菲利普
{ oats_request_known:
    -> philipp_reminder
}
+ [“发生什么事了？”]
    -> philipp_request
+ [（离开） # tone:action]
    -> END

// 首次询问和后续补问共用同一段，改文案只需改这里。
=== philipp_request ===
“一点....小事。听着，金德日赫。”菲利普走近你，在你耳边压低声音，“你要去见扬修士，是不是？” # speaker:菲利普
“...没错。” # speaker:金德日赫
~ oats_request_known = true
“我们没有燕麦喂马了——告诉他。而且，如果在奥尔德里希大人来之前，我们还没有燕麦——”他抬起头，用那双总是如此忧愁的双眼打量了一下四周，叹息了一声，“——大家都不想看到那样的事情。” # speaker:菲利普
+ [“什么样的事情？”]
    ~ oats_response = "ask"
    -> philipp_fear
+ [“好的。” # action:离开]
    ~ oats_response = "accept"
    -> END

=== philipp_fear ===
~ oats_question_asked = true
“...我也不知道，一定会是很可怕的事情。”菲利普说。他张着嘴，望着你，似乎有点生气。他还想说些什么，但最后只是闭上了眼睛。“总之....我们不能让他生气。” # speaker:菲利普
+ [“好的。” # action:离开]
    -> END

=== philipp_reminder ===
“找到扬兄弟了吗？……劳烦你快一些。” # speaker:菲利普
-> END
