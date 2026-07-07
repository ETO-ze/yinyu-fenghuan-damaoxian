# 第一关可视化编辑指南

第一关现在优先从 `scenes/levels/Level01Editable.tscn` 读取关卡数据。你可以在 Godot 编辑器里直接拖动平台、羽毛、金币、出生点、传送门和检查点。

## 如何微调

1. 打开 Godot。
2. 打开场景 `scenes/levels/Level01Editable.tscn`。
3. 展开节点：
   - `Platforms`：平台碰撞和路线。
   - `Feathers`：羽毛位置。
   - `Coins`：金币位置。
   - `Special`：玩家出生点、中央风环、终点传送门。
   - `Checkpoints`：检查点位置。
4. 在 2D 视图里拖动对应 `Marker2D`。
5. 保存场景。
6. 运行项目，`Main.tscn` 会自动读取这些位置。

## 平台怎么调

平台节点使用 `EditablePlatform.gd`。

可调属性：

| 属性 | 用途 |
| --- | --- |
| `position` | 平台中心点位置，可以直接拖 |
| `platform_name` | 平台 ID，不建议随意改 |
| `platform_size` | 平台碰撞尺寸 |
| `route_platform` | 是否参与路线可达性检查 |

注意：

- 蓝色矩形是碰撞尺寸预览，不是最终平台贴图。
- 黄色上边线表示玩家可站立平台顶面。
- 大地面平台通常不参与路线节奏检查，`route_platform = false`。
- 浮空平台和终点薄平台通常保持 `route_platform = true`。

## 装饰贴图如何跟随平台

运行时的草丛、晶体、花、石块、终点高塔、NPC 和奖励宝箱会按平台名自动贴回对应位置。微调平台时请尽量保留这些平台 ID：

| 平台 ID | 影响内容 |
| --- | --- |
| `tower_finish` | 终点高塔、NPC、终点小装饰 |
| `tower_ground` | 奖励宝箱、终点地面装饰 |
| `start_step`、`floating_a`、`floating_b`、`floating_c`、`portal_left`、`portal_right`、`tower_step_a`、`tower_step_b` | 草丛、晶体、路线小装饰 |

如果只是拖动位置或修改 `platform_size`，贴图会跟随。不要随意改 `platform_name`，否则运行时找不到对应平台，装饰会回退到默认位置。

## 收集物和特殊点

点位节点使用 `EditableLevelPoint.gd`。

| point_type | 用途 |
| --- | --- |
| `player_start` | 玩家出生点 |
| `portal` | 右侧终点传送门 |
| `wind_ring` | 中央风环视觉地标 |
| `feather` | 羽毛 |
| `coin` | 金币 |
| `checkpoint` | 检查点 |

## 运行时数据来源

`scripts/LevelLoader.gd` 会优先加载：

```text
res://scenes/levels/Level01Editable.tscn
```

如果这个场景缺失或读取失败，才会回退到：

```text
res://data/levels/Level01Data.gd
```

## 当前限制

- 终点高塔、NPC、宝箱和部分装饰仍在 `Main.gd` 中以装饰点位生成。
- 这次优先解决平台、收集物、出生点、传送门、检查点的关卡微调。
- 如果你后续也想拖动塔楼、宝箱、NPC，我可以继续把这些装饰点位也拆进 `Level01Editable.tscn`。
