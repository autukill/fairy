fairy
==
一个在开发中的UI框架,目的是 GameMaker Studio 1/2 接入fairygui.
一部分代码由 openfl 移植来的,因为 gml 没有可收缩的数组,没有反射等原因.所以需要做一定的适配工作.

参考
--
- GameMaker Studio 2 user manual:http://docs2.yoyogames.com/
- FairyGUI:http://www.fairygui.com/guide/
- FairyGUI-unity:https://github.com/fairygui/FairyGUI-unity
- Openfl:https://github.com/openfl/openfl
- OpenGL SuperBible:http://www.openglsuperbible.com/

开发环境
--
- haxe 4.0.0-preview.5
- IntelliJ IDEA Community
- sfhx:https://bitbucket.org/yal_cc/sfhx
- sfgml:https://bitbucket.org/yal_cc/sfgml
- fairytest:https://github.com/autukill/fairytest

进展(已完成):
--
移植:
- openfl.events.* - 事件分发

填充物:
- support.Slice - 可收缩的数组
