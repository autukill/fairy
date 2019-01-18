fairy
==
一个在开发中的UI框架,目的是 GameMaker Studio 2 接入fairygui.
由于 gml 主要面向游戏开发的脚本语言,缺少一些有用的函数或者功能,比如没有可收缩的数组.因此需要做一定的适配工作.

参考
--
- GameMaker Studio 2 user manual:http://docs2.yoyogames.com
- sfgml:https://yal.cc/r/18/sfgml
- FairyGUI:http://www.fairygui.com/guide
- FairyGUI-monogame:https://github.com/fairygui/FairyGUI-monogame
- OpenFL:https://github.com/openfl/openfl
- OpenGL SuperBible:http://www.openglsuperbible.com

开发环境
--
- haxe 4.0.0-preview.5
- IntelliJ IDEA Community
- sfhx:https://bitbucket.org/yal_cc/sfhx
- sfgml:https://bitbucket.org/yal_cc/sfgml
- fairytest:https://github.com/autukill/fairytest

进展(已完成):
--
- support.Slice - 可收缩的数组
- events.* - 事件分发
- geom.Point
- geom.Rectangle
- core.NTexture