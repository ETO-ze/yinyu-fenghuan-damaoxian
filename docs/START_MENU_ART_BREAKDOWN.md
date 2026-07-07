# 开始界面美术拆分

本轮开始界面采用一张完整竖屏像素美术底图作为主视觉，Godot 场景内叠加真实可编辑的标题、按钮文字和点击区域。这样可以保留参考图的整体质感，同时避免生成图中文字不可控的问题。

## 项目内资源

| 资源 | 路径 | 用途 |
| --- | --- | --- |
| 生成源图 | `docs/art/start_menu_generated_source_v1.png` | 原始 AI 生成主视觉，保留用于复查和后续二次切图 |
| 游戏背景图 | `assets/title/start_menu_background_v1.png` | `StartMenu.tscn` 实际使用的 2x 竖屏背景贴图 |
| 完整预览 | `docs/art/start_menu_full_preview_v1.png` | 带标题和按钮文字的效果预览 |
| 部件总览 | `docs/art/start_menu_parts_contact_sheet_v1.png` | 七个关键区域的快速检查图 |

## 单独部件截图

| 部件 | 路径 | 内容 |
| --- | --- | --- |
| 天空云海 | `docs/art/start_menu_parts/01_sky_clouds_preview.png` | 顶部蓝天、白云、星点、标题牌上缘 |
| 标题牌 | `docs/art/start_menu_parts/02_title_plaque_preview.png` | 黑金标题框、银白羽翼、蓝水晶 |
| 菜单按钮组 | `docs/art/start_menu_parts/03_menu_buttons_preview.png` | 三个空按钮框、侧旗、塔楼中段 |
| 塔楼传送门 | `docs/art/start_menu_parts/04_tower_portal_preview.png` | 中央高塔、蓝色传送门、菜单结构关系 |
| 角色与宝箱 | `docs/art/start_menu_parts/05_hero_npc_chest_preview.png` | 主角、兔子 NPC、黑色小伙伴、蓝晶宝箱 |
| 前景浮岛 | `docs/art/start_menu_parts/06_foreground_island_preview.png` | 石质浮岛、藤蔓、瀑布、旗帜和水晶装饰 |
| 文字层 | `docs/art/start_menu_parts/07_text_overlays_preview.png` | 中文标题、英文副标题、三个菜单按钮文字 |

## Godot 场景

- 场景：`scenes/StartMenu.tscn`
- 脚本：`scripts/StartMenu.gd`
- 关键文字、按钮热区和背景都在 `StartMenu/MenuCanvas` 下作为真实节点存在，可按 `docs/START_MENU_LAYOUT_GUIDE.md` 直接调整位置。
- 启动入口：`project.godot` 的 `run/main_scene`
- 只有点击“开始游戏”才会进入 `scenes/Main.tscn`
- “继续冒险”暂时显示暂无存档提示，不进入关卡
- “设置”显示/隐藏简短操作提示

## 设计取舍

- 标题、按钮文字不烘焙到图片里，便于后续替换字体、字号和语言。
- 背景图按 480x854 竖屏坐标设计，并保存为 960x1708 的 2x 贴图，便于检查细节。
- 开始界面暂时不接存档系统，“继续冒险”只做状态提示，避免把 Demo 流程复杂化。
