# 项目审查与重构说明

## 审查范围

- `project.godot`：主场景路径、窗口尺寸、渲染设置。
- `scenes/Main.tscn`：根节点、`World`、`HUD` 路径。
- `scripts/Main.gd`：关卡生成、节点创建、信号连接、资源路径。
- `scripts/Player.gd`：移动、跳跃、滑翔、胜利后输入锁定。
- `scripts/RewardChest.gd`：终点奖励宝箱、开箱奖励、奖励粒子。
- `scripts/HUD.gd`：顶部 HUD、胜利 UI、计时器。
- `scripts/Collectible.gd`：羽毛收集、玩家接口调用。
- `scripts/Coin.gd`：金币收集、分数增加。
- `scripts/NextLevelPortal.gd`：通关条件、触发信号、范围内玩家检测。

## 已检查结论

| 项目 | 结论 |
|---|---|
| 脚本命名 | `Main.gd`, `Player.gd`, `HUD.gd`, `Collectible.gd`, `NextLevelPortal.gd` 职责清晰。 |
| 节点路径 | `Main.tscn` 保留 `World` 与 `HUD`，`Main.gd` 使用 `$World` 和 `$HUD`，路径有效。 |
| 信号连接 | 玩家状态、背包变化、传送门胜利和锁定提示均由 `Main.gd` 集中连接。 |
| 资源路径 | 主角、平台、背景、NPC、收集物、HUD、粒子和终点道具均使用 `res://assets/` 内贴图；脚本 `preload` 路径均在 `res://scripts/` 下。 |
| 可运行性 | 已用 Godot 4.7 headless 加载 `res://scenes/Main.tscn` 验证无报错。 |
| 潜在 bug | 已修复传送门只在 `body_entered` 检查导致的漏触发问题；已将真正传送门移动到右侧高塔终点。 |

## 关卡可达性分析

玩家参数：

- 跳跃初速度：`530px/s`
- 重力：`1080px/s^2`
- 理论最大上升高度：约 `130px`
- 同高度普通跳跃理论水平覆盖：约 `186px`
- 关卡安全上升高度阈值：`92px`
- 关卡安全边缘间距阈值：`220px`
- 当前主路线边缘间距：约 `125-175px`
- 横向速度：`190px/s`
- 疾跑速度：`330px/s`
- 疾跑消耗：按住方向键 + Shift/J 时持续消耗 `13` 点羽翼能量/秒

主路线平台顺序：

```text
start_ground -> start_step -> floating_a -> floating_b -> floating_c
-> portal_left -> portal_right -> tower_step_a -> tower_step_b -> tower_finish
```

相邻平台最大上升高度约 `73px`，小于安全阈值 `92px`。主路线正向跳跃的边缘间距约 `125-175px`，低于普通跳跃同高度水平覆盖约 `186px`，滑翔还能增加容错。路线节奏为起点连续上升、中段下落、风环前再上升、终点下降落塔，平台比旧版更分散，但仍在可达范围内。

`Main.gd` 现在包含 `_validate_level_layout()`，运行时会检查主路线平台顶面高度差和边缘间距。如果后续把平台改得过高、过远或过近，会输出 Godot warning。

关卡语义：

- 中央 `CentralWindRingMarker` 是无碰撞视觉地标，只提示风之圆环主题。
- 右侧 `NextLevelPortal` 是唯一通关/下一关传送触发器。
- 玩家必须收集足够羽毛并抵达右侧高塔终点，才会触发胜利 UI。
- 终点 `RewardChest` 是实际奖励物，玩家碰到后只触发一次，增加分数并恢复羽翼能量，不影响通关条件。

## 本次重构

- 将平台、羽毛、传送门、玩家起点等关键关卡数据集中到 `Main.gd` 顶部常量。
- 新增 `PLATFORM_LAYOUT`、`FEATHER_POSITIONS`、`ROUTE_PLATFORM_NAMES`，减少位置改动不同步。
- 新增 `_validate_level_layout()` 和 `_platform_top_y()`，从逻辑上检查平台可达性。
- 重写 HUD 顶部布局，显示标题、生命、羽翼能量、分数、羽毛数量、关卡名、计时器。
- 胜利 UI 文案改为：“恭喜通关！风之徽记已点亮，新的旅程即将开启！”
- `Player.gd` 增加 `input_locked`，胜利后暂停输入。
- `NextLevelPortal.gd` 记录范围内玩家，羽毛数量更新后也能补触发胜利。
- `Main.gd` 将传送门节点命名为 `NextLevelPortal`，位置移动到右侧高塔终点。
- 新增 `CentralWindRingMarker` 作为中央装饰风环，避免中段提前通关。
- 新增 `Coin.gd` 和 `COIN_POSITIONS`，金币只加分，不影响羽毛通关条件。
- `Player.gd` 接入 `hero_silverwing_*.png` 透明帧，缺失图片时回退到代码绘制。
- `HUD.gd` 接入生成的心形、羽翼、计时器、金币、羽毛图标。
- 重新切分主角帧为 320x320，保留安全透明边距，修复移动时头部/羽翼贴边遮挡。
- `Main.gd` 将生成的浮空平台图叠加到平台视觉层，碰撞矩形不变。
- 新增远景高塔、漂浮遗迹、云团、星光和蓝焰灯笼道具。
- 接入 `bg_blue_sky_clouds.png` 作为同款亮蓝天白云背景。
- 接入 `tower_finish_generated.png` 作为右侧终点高塔正式视觉稿。
- 删除代码绘制的多边形云和远景塔，背景云朵全部换成 `bg_cloud_small_*.png` 或云海贴图。
- 传送门只在玩家进入右侧终点范围时检查羽毛数量，`update_feathers()` 只记录数量，不再自动触发胜利。
- 关卡宽度拉长到 `3800px`，终点高塔、NPC、宝箱和传送门整体后移到右侧终点区域。
- 红圈处比例不协调的远景遗迹不再引用，改用 `bg_tiny_sky_decor_*.png` 小型远景装饰，减少近景建筑误读。
- 新增疾跑和下蹲输入：疾跑与滑翔共用羽翼能量；疾跑是持续快速移动，不再是短促冲刺；下蹲降低速度并加快能量恢复。
- 生命值现在可以归零。归零后 `Player.gd` 进入 `defeated_state`，锁定输入，播放 `hero_silverwing_fail_*.png`，HUD 显示失败 UI。
- 新增 `RewardChest.gd`，终点宝箱从静态截图改为可触发奖励物。
- 平台视觉改为 `platform_unified_*.png` 统一平台组，并按石面可站立顶面对齐碰撞矩形，避免草、水晶或装饰顶部误当作站立面。
- 移除地图内中文指示牌，只保留 HUD 文案；终点薄平台改用 `platform_unified_tower_cap_00.png`，平台节点正常情况下只显示统一像素贴图，旧的灰色矩形临时视觉只保留为缺图 fallback。
- 补齐缺失贴图：NPC 欢呼动画、羽毛/金币旋转帧、宝箱关闭帧、HUD 专用金币/羽毛图标、天空星点、胜利彩带、宝箱奖励闪光、精细石块 tile、花草岩石、锁链和天空小鸟均已生成并接入。
- 新增通用贴图/动画加载逻辑，`Main.gd` 中的 NPC、天空星点和胜利粒子优先使用 PNG 资源；代码绘制矩形仅作为资源缺失时的 fallback。
- `Collectible.gd` 和 `Coin.gd` 改为 `AnimatedSprite2D` 多帧播放，旧单图只作为 fallback。
- `RewardChest.gd` 使用 `chest_reward_closed_02.png`，奖励粒子改用 `fx_reward_sparkle_*.png`。
- 定位到旧 `platform_floating_small_01/02/03` 自带灰绿色桥条，`platform_floating_long_02` 顶部有灰色板，`platform_tower_cap_02` 存在透明缺口，导致上下风格不一和人物视觉悬空。
- 重新调用图片生成工具生成 `platform_unified_sheet_v5_source.png`，裁切为 `platform_unified_small/long/tower_cap/badge` 系列。
- `Main.gd` 取消石块补片叠层，当前关卡平台只使用一张统一平台贴图，并通过 `_platform_visual_surface_y()` 将碰撞顶面对齐到真实石面。
- `RewardChest.gd` 改用 `chest_reward_closed_02.png`，关闭/开启宝箱现在使用同尺寸、同金边与蓝宝石风格。
- `Player.gd` 扩展动作帧：跑步 12 帧、疾跑 6 帧、蹲下 4 帧、跳跃 4 帧、下落 4 帧、滑翔 5 帧，减少移动和跑步的跳帧感。

## 后续建议

- 将关卡数据进一步拆成 `res://data/level_01.gd` 或 `.tres`，便于多关卡扩展。
- 将 `tile_stone_ground_*.png` 和 `tile_stone_edge_*.png` 组装成 Godot `TileSet`，便于后续用 TileMap 绘制更长关卡。
