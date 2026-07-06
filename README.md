# 银羽风环大冒险 Demo

Godot 4.x / GDScript 制作的最小可玩 2D 横版平台 Demo。

## 文件结构

```text
silverwing_wind_ring_demo/
  project.godot
  README.md
  scenes/
    Main.tscn
  scripts/
    Main.gd
    Player.gd
    HUD.gd
    Collectible.gd
    Coin.gd
    NextLevelPortal.gd
  assets/
    characters/
    npcs/
    environment/
    collectibles/
    ui/
    backgrounds/
    effects/
    audio/
  docs/
    PIXEL_ART_ASSET_LIST.md
    PROJECT_REVIEW.md
    art/
      silverwing_art_direction_v1.png
      silverwing_missing_texture_sheet_v3_source.png
      missing_texture_asset_preview_v3.png
```

## 操作

- A / ←：向左移动
- D / →：向右移动
- Space / W / ↑：跳跃
- 下落时按住 Space：短暂滑翔
- 按住方向键 + Shift / J：持续疾跑，消耗羽翼能量
- S / ↓：下蹲，移动速度降低并更快恢复羽翼能量

## 目标

从左侧起点出发，穿过中段浮空平台，收集至少 5 根羽毛，抵达右侧高塔终点的下一关传送门，触发“恭喜通关”。

## 当前关卡

- 左侧：起点平台。
- 中段：多段浮空平台，玩家需要跳跃和滑翔通过。
- 中央：风环视觉地标，不触发通关。
- 右侧：高塔终点、下一关传送门、NPC 和奖励宝箱。
- 背景：使用 `ParallaxBackground` 和多层 `ParallaxLayer` 生成远景高塔与云海。

当前主角、平台、云海、小云、远景装饰、高塔、传送门、收集物与 HUD 图标已经接入生成像素贴图；地图内文字牌已移除，避免破坏画面统一性。

## 文档

- `docs/PIXEL_ART_ASSET_LIST.md`：正式像素美术资源清单、尺寸、帧数、动画状态、命名规范和目录。
- `docs/PROJECT_REVIEW.md`：项目审查、重构说明和关卡可达性分析。
- `docs/art/silverwing_art_direction_v1.png`：根据参考图生成的当前美术方向稿。
- `docs/art/silverwing_missing_texture_sheet_v3_source.png`：本轮补齐贴图的生成源稿。
- `docs/art/missing_texture_asset_preview_v3.png`：新增贴图总览，便于检查风格统一性。
- `docs/art/platform_unified_sheet_v5_source.png`：本轮统一浮空平台生成源稿。
- `docs/art/platform_unified_ingame_preview_v5.png`：按关卡实际缩放和碰撞顶面对齐的平台预览。

## 已接入生成美术

- `assets/characters/hero_silverwing_*.png`：主角 idle/run/jump/fall/glide/celebrate 透明帧。
- `assets/characters/hero_silverwing_dash_*.png`、`hero_silverwing_crouch_*.png`、`hero_silverwing_fail_*.png`：疾跑、下蹲和失败动画帧。
- `docs/art/hero_motion_refinement_sheet_v4_source.png`：本轮主角动作细化源稿。
- `docs/art/hero_motion_refinement_preview_v4.png`：主角动作帧预览。
- `assets/environment/portal_next_level_idle_00.png`：右侧下一关传送门。
- `assets/environment/marker_wind_ring_00.png`：中央风环视觉地标。
- `assets/environment/prop_wind_banner_00.png`：黑白凤凰旗帜。
- `assets/npcs/npc_bird_cheer_*.png`、`npc_rabbit_cheer_*.png`、`npc_hood_cheer_*.png`：终点欢呼 NPC 动画帧。
- `assets/collectibles/collect_feather_spin_*.png`：羽毛收集物旋转动画。
- `assets/collectibles/collect_coin_spin_*.png`：金币收集物旋转动画。
- `assets/collectibles/chest_reward_closed_02.png`、`chest_reward_open_01.png`：可交互终点宝箱。
- `assets/ui/ui_icon_*.png`：HUD 图标。
- `assets/effects/fx_confetti_*.png`、`fx_star_sparkle_*.png`、`fx_reward_sparkle_*.png`、`fx_sky_star_*.png`：胜利、宝箱和天空星点粒子。
- `assets/environment/platform_unified_*.png`：当前关卡实际使用的统一风格浮空平台。
- `assets/environment/tile_stone_ground_*.png`、`platform_stone_chunk_*.png`：备用精细石块 tile/平台块变体。
- `assets/environment/prop_grass_tuft_*.png`、`prop_flower_cluster_*.png`、`prop_rock_cluster_*.png`、`prop_chain_arch_00.png`、`prop_crystal_post_*.png`：平台小装饰，降低关卡重复感。
- `assets/environment/platform_unified_tower_cap_00.png`：终点区域专用统一风格薄平台。
- `assets/backgrounds/bg_*.png`：蓝天白云、云海、小云和远景浮空装饰背景元素。
- `assets/backgrounds/bg_blue_sky_clouds.png`：同款亮蓝天白云主背景。
- `assets/backgrounds/bg_cloud_small_*.png`：贴图化小云，替换原先代码绘制的小云。
- `assets/backgrounds/bg_tiny_sky_decor_*.png`：小型远景浮空装饰，替换比例不协调的近景建筑/遗迹。
- `assets/environment/tower_finish_generated.png`：右侧终点高塔正式视觉稿。
- `assets/environment/prop_blue_lantern_00.png`：蓝焰灯笼关卡道具。

## 最近修复

- 修复主角移动时头部/羽翼贴边遮挡：重新切分 `hero_silverwing_*.png` 为 320x320 透明帧并保留安全留白。
- 提高玩家显示层级，避免被平台美术层压住。
- 保持平台碰撞矩形不变，仅在视觉层叠加浮空平台素材，降低关卡 bug 风险。
- 提高跳跃高度并重设浮空平台路线：最大上升差约 73px，理论跳跃高度约 130px。
- 删除背景中代码绘制的多边形云和远景塔，全部改为贴图资源或缩小的浮空装饰。
- 修正传送门逻辑：收集第 5 根羽毛不会自动通关，必须到达右侧终点传送门并拥有 5 根及以上羽毛。
- 拉长关卡宽度到 3800px，重新布置浮空平台，主路线边缘间距约 125-175px，避免平台挤在一起。
- 替换红圈处比例不协调的远景建筑，改用 `bg_tiny_sky_decor_*.png` 作为更远、更小的天空装饰。
- 新增疾跑、下蹲和生命归零失败状态；失败后暂停输入并显示失败 UI。
- 终点宝箱改为实际奖励物：玩家碰到后打开，增加分数并恢复羽翼能量。
- 平台贴图增加多套变体，并按透明像素顶边对齐碰撞平台，修正终点高塔附近的视觉穿模。
- 移除地图内中文指示牌，重做终点薄平台和小装饰细节；平台节点正常情况下只显示像素贴图，灰色代码矩形只作为缺图 fallback。
- 疾跑改为按住方向键 + Shift/J 的持续快速移动，能量持续消耗，不再是短促冲刺。
- 补齐缺少贴图：NPC、羽毛/金币旋转帧、宝箱关闭帧、HUD 专用图标、胜利/宝箱粒子、天空星点、石块 tile、花草岩石与锁链装饰均已生成并接入。
- 重做平台美术：弃用灰桥条和石块补片混搭，当前关卡统一使用 `platform_unified_*.png`，按石面可站立顶面对齐碰撞。
- 重做主角动作：跑步扩展到 12 帧，疾跑 6 帧，蹲下 4 帧，跳跃/下落各 4 帧，滑翔 5 帧。
- 重做关闭宝箱为 `chest_reward_closed_02.png`，尺寸、金边、蓝宝石和材质语言与开启宝箱保持一致。
