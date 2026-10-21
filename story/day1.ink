// 第一天剧本入口。按地点编辑各章节 Ink 文件。
// 用随工程提供的「编译对白.cmd」编译本文件。
VAR dorm_wakeup_done = false
VAR courtyard_intro_seen = false
VAR oats_request_known = false
VAR oats_question_asked = false
VAR observed_bed = false
VAR observed_desk = false
VAR observed_cross = false
VAR observed_chest = false
VAR wake_response = ""
VAR courtyard_response = ""
VAR oats_response = ""
VAR vaclav_met = false
VAR vaclav_home_question_heard = false
VAR simon_met = false
VAR simon_response = ""
VAR rodrigo_met = false
VAR rodrigo_response = ""
VAR lukas_response = ""
VAR observed_hens = false
VAR observed_luke = false
VAR touched_luke = false
VAR observed_medicine_cabinet = false
VAR cloister_intro_seen = false
VAR ambrose_met = false
VAR ambrose_response = ""
// 小镇（村庄）d1 对话变量
VAR talked_to_dorota = false
VAR henry_talked = false
VAR lucia_met = false
VAR lucia_asked_why = false
VAR lucia_asked_marina = false
VAR dorota_asked_why = false
VAR dorota_asked_take = false
VAR pavel_talked = false
VAR vit_talked = false

// Inky 中从宿舍开场试玩；游戏通过相应 knot 进入。
-> dorm_wakeup

INCLUDE dorm.ink
INCLUDE courtyard.ink
INCLUDE garden.ink
INCLUDE kitchen.ink
INCLUDE infirmary.ink
INCLUDE cloister_south.ink
INCLUDE henry_d1.ink
INCLUDE lucia_d1.ink
INCLUDE dorota_d1.ink
INCLUDE pavel_d1.ink
INCLUDE vit_d1.ink
