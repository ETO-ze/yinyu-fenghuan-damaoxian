# 像素美术资源清单

本清单用于把当前代码占位图替换为正式 16 位复古像素美术。命名统一使用小写 snake_case，动画序列用 `资源名_状态_帧序号.png`，例如 `hero_silverwing_run_03.png`。建议导入设置关闭过滤：Filter Off，Compression Lossless。

当前美术方向稿：`docs/art/silverwing_art_direction_v1.png`。它定义了银白鹰/凤凰主角、黑白徽章、云海遗迹、高塔终点与右侧下一关传送门的整体方向。本轮缺失贴图源稿为 `docs/art/silverwing_missing_texture_sheet_v3_source.png`，总览图为 `docs/art/missing_texture_asset_preview_v3.png`。

## 目录规范

```text
assets/
  characters/
  npcs/
  environment/
  collectibles/
  ui/
  backgrounds/
  effects/
  audio/
```

## 角色

已生成并接入：`assets/characters/hero_silverwing_*.png`，包含 idle/run/jump/fall/glide/celebrate/dash/crouch/fail。源图保留为 `hero_silverwing_sheet_source.png`，透明整图为 `hero_silverwing_sheet.png`。本轮动作细化源图保留为 `docs/art/hero_motion_refinement_sheet_v4_source.png`，预览图为 `docs/art/hero_motion_refinement_preview_v4.png`。

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 主角银羽鹰/凤凰 | `assets/characters/` | 320x320 源帧，游戏内缩放 | 40+ | idle 2, run 12, dash 6, crouch 4, jump 4, fall 4, glide 5, celebrate 1, fail 4 | `hero_silverwing_<state>_<00-11>.png` |
| 主角圣物/徽记 | `assets/characters/` | 24x24 | 4 | idle 2, shine 2 | `hero_relic_<state>_<00-03>.png` |

主角风格要求：银白羽翼、深色斗篷、金色边线，剪影参考白色鹰/凤凰徽章。所有动作需要朝右绘制，Godot 内部用水平翻转处理朝左。

## NPC

已生成并接入：`npc_bird_cheer_00-02.png`、`npc_rabbit_cheer_00-01.png`、`npc_hood_cheer_00-02.png`。NPC 源帧来自同一张 16 位像素风生成稿，游戏内统一缩放到终点平台比例。

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 欢呼 NPC 小鸟 | `assets/npcs/` | 约 94x127 源帧，游戏内缩放 | 3 | cheer loop | `npc_bird_cheer_<00-02>.png` |
| 欢呼 NPC 兔子 | `assets/npcs/` | 约 84x139 源帧，游戏内缩放 | 2 | cheer loop | `npc_rabbit_cheer_<00-01>.png` |
| 欢呼 NPC 兜帽群众 | `assets/npcs/` | 约 92x112 源帧，游戏内缩放 | 3 | cheer loop | `npc_hood_cheer_<00-02>.png` |

## 平台与场景物件

已生成并接入：`platform_unified_small_00-02.png`、`platform_unified_long_00-02.png`、`platform_unified_tower_cap_00.png`、`platform_unified_badge_00.png`、`platform_stone_chunk_00-07.png`、`prop_blue_lantern_00.png`、`prop_wind_banner_pole_00-02.png`、`prop_wind_banner_hanging_01.png`、`prop_grass_tuft_00-04.png`、`prop_flower_cluster_00-01.png`、`prop_rock_cluster_00-01.png`、`prop_chain_arch_00.png`、`prop_crystal_post_00-04.png`。平台碰撞仍由代码矩形控制，视觉层正常只显示一张统一平台贴图；代码矩形只作为缺图 fallback。旧的 `platform_floating_*.png` 保留为历史资源，当前关卡不再使用。

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 石质地面瓦片 | `assets/environment/` | 76-200px 宽源帧，游戏内缩放 | 8 | static variants | `tile_stone_ground_<00-07>.png` |
| 石质平台边缘 | `assets/environment/` | 53-93px 宽源帧，游戏内缩放 | 6 | top, left, right, bottom, corner_l, corner_r | `tile_stone_edge_<state>.png` |
| 浮空平台装饰链 | `assets/environment/` | 107x121 | 1 | static | `prop_chain_arch_00.png` |
| 风环旗帜 | `assets/environment/` | 32x48 | 4 | flutter | `prop_wind_banner_<00-03>.png` |
| 高塔终点 | `assets/environment/` | 128x192 | 4 | idle 2, shine 2 | `tower_finish_<state>_<00-01>.png` |
| 长浮空平台 | `assets/environment/` | 471-1384px 宽源帧，游戏内缩放 | 3 | static variants | `platform_unified_long_<00-02>.png` |
| 小浮空平台 | `assets/environment/` | 173-377px 宽源帧，游戏内缩放 | 3 | static variants | `platform_unified_small_<00-02>.png` |
| 链条浮岛 | `assets/environment/` | 260x260 | 1 | static | `platform_floating_chain_island_00.png` |
| 蓝焰灯笼 | `assets/environment/` | 150x150 | 1 | static | `prop_blue_lantern_00.png` |
| 终点平台薄帽 | `assets/environment/` | 373x182 | 1 | static | `platform_unified_tower_cap_00.png` |
| 徽章装饰平台 | `assets/environment/` | 551x191 | 1 | static | `platform_unified_badge_00.png` |
| 备用精细石块平台块 | `assets/environment/` | 76-200px 宽源帧，游戏内缩放 | 8 | static variants | `platform_stone_chunk_<00-07>.png` |
| 草丛装饰 | `assets/environment/` | 48-71px 宽源帧，游戏内缩放 | 5 | static variants | `prop_grass_tuft_<00-04>.png` |
| 花丛装饰 | `assets/environment/` | 52-63px 宽源帧，游戏内缩放 | 2 | static variants | `prop_flower_cluster_<00-01>.png` |
| 岩石装饰 | `assets/environment/` | 73-83px 宽源帧，游戏内缩放 | 2 | static variants | `prop_rock_cluster_<00-01>.png` |
| 蓝水晶柱 | `assets/environment/` | 73-74px 宽源帧，游戏内缩放 | 5 | static variants | `prop_crystal_post_<00-04>.png` |

## 传送门

已生成并接入：`assets/environment/portal_next_level_idle_00.png` 和 `assets/environment/marker_wind_ring_00.png`。

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 下一关传送门 | `assets/environment/` | 160x160 | 16 | locked 4, idle 6, open 6 | `portal_next_level_<state>_<00-05>.png` |
| 中央风环地标 | `assets/environment/` | 128x128 | 8 | idle pulse | `marker_wind_ring_<00-07>.png` |
| 凤凰徽章核心 | `assets/environment/` | 64x64 | 4 | pulse | `portal_phoenix_core_<00-03>.png` |

下一关传送门必须放在右侧高塔终点，用于进入下一关或触发当前 Demo 胜利。中央风环只是路标/能量地标，不应触发通关。传送门碰撞半径当前为 82px，美术外圈建议控制在 150-160px 内，避免视觉范围和触发范围差距过大。

## 收集物

已生成并接入：`collect_feather_spin_00-05.png`、`collect_coin_spin_00-07.png`、`chest_reward_closed_02.png`、`chest_reward_open_01.png`、`reward_gem_blue_00.png`。旧的 `collect_*_generated.png` 只保留为缺图 fallback。

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 银蓝羽毛 | `assets/collectibles/` | 24x24 | 6 | idle spin | `collect_feather_spin_<00-05>.png` |
| 金币 | `assets/collectibles/` | 16x16 | 8 | spin | `collect_coin_spin_<00-07>.png` |
| 打开的宝箱 | `assets/collectibles/` | 64x48 | 8 | closed 1, open 4, sparkle 3 | `chest_reward_<state>_<00-03>.png` |
| 蓝色奖励宝石 | `assets/collectibles/` | 64x64 | 1 | static sparkle | `reward_gem_blue_00.png` |

金币目前未接入玩法，可作为后续加分收集物。羽毛是通关条件资源，必须保持高对比蓝白色。

## HUD 图标

已生成并接入：`ui_icon_heart_full.png`、`ui_icon_heart_empty.png`、`ui_icon_wing_energy_full/mid/low/empty.png`、`ui_icon_timer.png`、`ui_icon_score_coin_00-03.png`、`ui_icon_feather_00-03.png`、`ui_badge_phoenix.png`。HUD 已使用专用金币和羽毛图标，不再复用收集物大图。

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 生命心形 | `assets/ui/` | 16x16 | 2 | full, empty | `ui_icon_heart_<state>.png` |
| 羽翼能量 | `assets/ui/` | 16x16 | 4 | full, mid, low, empty | `ui_icon_wing_energy_<state>.png` |
| 分数金币 | `assets/ui/` | 16x16 | 4 | sparkle | `ui_icon_score_coin_<00-03>.png` |
| 羽毛计数 | `assets/ui/` | 16x16 | 4 | sparkle | `ui_icon_feather_<00-03>.png` |
| 计时器 | `assets/ui/` | 16x16 | 1 | static | `ui_icon_timer.png` |
| HUD 黑白徽章 | `assets/ui/` | 48x48 | 1 | static | `ui_badge_phoenix.png` |

## 背景

已生成并接入：`bg_blue_sky_clouds.png`、`bg_cloud_small_*.png`、`bg_tiny_sky_decor_*.png`、`bg_cloud_clump_00.png`、`fx_sparkle_cluster_00.png`。背景不再使用代码绘制的多边形云和远景塔，比例过大的漂浮遗迹也不再放在近景可玩区域。

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 夜空背景 | `assets/backgrounds/` | 480x854 | 1 | static | `bg_sky_night.png` |
| 远景云海层 A | `assets/backgrounds/` | 960x256 | 1 | parallax loop | `bg_cloud_sea_far.png` |
| 远景云海层 B | `assets/backgrounds/` | 960x256 | 1 | parallax loop | `bg_cloud_sea_mid.png` |
| 远景高塔剪影 | `assets/backgrounds/` | 512x384 | 1 | parallax loop | `bg_towers_far.png` |
| 蓝天白云主背景 | `assets/backgrounds/` | 480x854 | 1 | static | `bg_blue_sky_clouds.png` |
| 小云贴图组 | `assets/backgrounds/` | 220x120 | 8 | static variants | `bg_cloud_small_<00-07>.png` |
| 小型浮空远景装饰 | `assets/backgrounds/` | 180x120 | 4 | static variants | `bg_tiny_sky_decor_<00-03>.png` |

## 终点高塔

已生成并接入：`assets/environment/tower_finish_generated.png`。它包含白石高塔、黑白凤凰旗、蓝水晶和嵌入式蓝色传送门。

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 终点高塔正式贴图 | `assets/environment/` | 360x520 | 1 | static | `tower_finish_generated.png` |

背景资源需要横向无缝循环，当前代码的 Parallax mirroring 宽度为 960px。

## 特效与音频

| 资源 | 放置目录 | 单帧尺寸 | 帧数 | 动画状态 | 命名规范 |
|---|---|---:|---:|---|---|
| 胜利星星粒子 | `assets/effects/` | 8x8 | 4 | sparkle | `fx_star_sparkle_<00-03>.png` |
| 彩带粒子 | `assets/effects/` | 8x16 | 6 | fall | `fx_confetti_<00-05>.png` |
| 宝箱奖励闪光 | `assets/effects/` | 8x8 | 4 | sparkle | `fx_reward_sparkle_<00-03>.png` |
| 天空星点 | `assets/effects/` | 8x8 | 4 | twinkle variants | `fx_sky_star_<00-03>.png` |
| 风环开启闪光 | `assets/effects/` | 96x96 | 4 | burst | `fx_portal_burst_<00-03>.png` |
| 胜利音效 | `assets/audio/` | wav/ogg | 1 | one shot | `sfx_victory_jingle.ogg` |
| 收集羽毛音效 | `assets/audio/` | wav/ogg | 1 | one shot | `sfx_collect_feather.ogg` |

音频命名同样使用 snake_case。短音效建议 ogg 或 wav，循环音乐另放 `bgm_*.ogg`。
