// D1-01 见习生宿舍。两种起床回应只记录角色语气。
=== dorm_wakeup ===
# title:见习生宿舍 · 晨祷
“金德日赫？” # speaker:扬
“快起床，钟声已经响了。” # speaker:扬
“我去章会厅等你，如果你今天又迟到的话，就算是我也没有办法在院长面前替你说情了。” # speaker:扬
+ [“是...是...我马上...”]
    ~ wake_response = "spoken"
    -> wakeup_finish
+ [（沉默且疲惫地从床上爬起来） # tone:action]
    ~ wake_response = "silent"
    -> wakeup_finish

=== wakeup_finish ===
~ dorm_wakeup_done = true
-> END

// 以下观察均可重复，不消耗时间，也不是出门的前置条件。
=== inspect_bed ===
# title:见习生宿舍 · 床
~ observed_bed = true
你的床，很窄。粗布褥套里塞着压实的稻草。修道院发给你的薄毯叠在床脚，边缘被磨得发白，露出几根被扯松的线头。 Noli diligere somnum.（不要贪睡） # speaker:床 # tone:description
-> END

=== inspect_desk ===
# title:见习生宿舍 · 书桌
~ observed_desk = true
一张书桌，上面放着你的抄写本，一根细绳夹在扬指定你抄写的段落中间。从基督诞生至今的漫长时日里，曾有许多双手在这里抄写关于救赎、服从和永恒的名字——同你一样。 # speaker:书桌 # tone:description
-> END

=== inspect_cross ===
# title:见习生宿舍 · 十字架
~ observed_cross = true
我们的主注视着你，保持着祂被盯上十字架时的姿态。 正如《福音书》所记载的那样。 # speaker:耶稣·基督 # tone:description
-> END

=== inspect_chest ===
# title:见习生宿舍 · 床尾的箱子
~ observed_chest = true
箱子里装着你从家里带来的东西：一只勺子、一双鞋、一件斗篷。 你望着它们，舌尖仿佛又尝到了辣根同蔬菜根茎的味道。 # speaker:床尾的箱子 # tone:description
-> END
