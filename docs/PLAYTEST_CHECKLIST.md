# v0.1-demo 人工测试清单

## 测试环境

| 项目 | 内容 |
|---|---|
| 引擎 | Godot 4.x |
| 分辨率 | 480x854 竖屏 |
| 主入口 | scenes/StartMenu.tscn |
| 主关卡 | scenes/Main.tscn |
| 测试版本 | v0.1-demo |

## 1. 开始界面

### 1.1 项目启动

步骤：

1. 打开 Godot 项目。
2. 运行主场景。
3. 观察是否进入开始界面。

预期结果：

- 首屏显示《银羽风环大冒险》开始界面。
- 背景、按钮、角色、传送门正常显示。
- 没有 Godot 报错。

失败时检查：

- project.godot 的 run/main_scene。
- scenes/StartMenu.tscn。
- scripts/StartMenu.gd。
- assets/title/start_menu_background_v1.png。

### 1.2 开始游戏按钮

步骤：

1. 在开始界面点击“开始游戏”。
2. 等待场景切换。

预期结果：

- 进入 scenes/Main.tscn。
- HUD 出现。
- 玩家出现在左侧起点。
- 没有黑屏或卡死。

失败时检查：

- scripts/StartMenu.gd 中 MAIN_SCENE_PATH。
- scenes/Main.tscn 是否存在。
- Main.tscn 是否包含 World 和 HUD 节点。

### 1.3 继续冒险按钮

步骤：

1. 在无存档情况下点击“继续冒险”。

预期结果：

- 显示“暂无存档，请点击开始游戏”。
- 不进入关卡。
- 不报错。

失败时检查：

- scripts/StartMenu.gd 的 _show_no_save_message()。

### 1.4 设置按钮

步骤：

1. 点击“设置”。
2. 再次点击“设置”。

预期结果：

- 第一次显示操作提示。
- 第二次隐藏操作提示。
- 开始界面的底部提示显示状态正常。

失败时检查：

- scripts/StartMenu.gd 的 _toggle_controls()。
- StartMenu.tscn 中 ControlsLabel 和 TextHintClickStart。

## 2. 玩家操作

### 2.1 左右移动

步骤：

1. 进入第一关。
2. 按 A / ←。
3. 按 D / →。

预期结果：

- 玩家向左、向右移动。
- 动画方向正确翻转。
- 不被平台贴图遮挡。

失败时检查：

- scripts/Player.gd 的 move_left / move_right 输入。
- Main.gd 中 _ensure_input_actions()。
- Player.gd 中 generated_sprite.z_index。

### 2.2 跳跃

步骤：

1. 玩家站在平台上。
2. 按 Space / W / ↑。

预期结果：

- 玩家向上跳起。
- 可到达设计好的浮空平台。
- 跳跃动画正常。

失败时检查：

- Player.gd 的 JUMP_VELOCITY。
- Main.gd 的 PLATFORM_LAYOUT。
- docs/PROJECT_REVIEW.md 的关卡可达性分析。

### 2.3 滑翔

步骤：

1. 玩家跳起后开始下落。
2. 按住 Space。

预期结果：

- 下落速度明显降低。
- 羽翼能量持续消耗。
- 能量归零后滑翔失效。

失败时检查：

- Player.gd 的 GLIDE_GRAVITY、GLIDE_MAX_FALL_SPEED。
- HUD.gd 的 energy_label 更新。

### 2.4 疾跑

步骤：

1. 按住方向键。
2. 同时按住 Shift 或 J。

预期结果：

- 玩家横向速度提高。
- 羽翼能量持续消耗。
- 松开 Shift/J 后恢复普通速度。

失败时检查：

- Player.gd 的 DASH_SPEED 和 DASH_ENERGY_DRAIN。
- Main.gd 的 dash 输入绑定。

### 2.5 下蹲

步骤：

1. 玩家站在平台上。
2. 按 S / ↓。

预期结果：

- 玩家进入下蹲状态。
- 移动速度降低。
- 羽翼能量恢复速度提高。
- 碰撞高度变小但不穿地。

失败时检查：

- Player.gd 的 _update_collision_pose()。
- CROUCH_RADIUS / CROUCH_HEIGHT。

## 3. 收集物

### 3.1 羽毛收集

步骤：

1. 触碰一根羽毛。

预期结果：

- 羽毛消失。
- 羽毛数量 +1。
- 分数增加。
- HUD 更新。

失败时检查：

- scripts/Collectible.gd。
- Player.gd 的 add_feather()。
- HUD.gd 的 feather_label。

### 3.2 金币收集

步骤：

1. 触碰一枚金币。

预期结果：

- 金币消失。
- 分数增加。
- 羽毛数量不变。

失败时检查：

- scripts/Coin.gd。
- Player.gd 的 add_score()。
- HUD.gd 的 score_label。

## 4. 传送门

### 4.1 羽毛不足时触碰传送门

步骤：

1. 收集少于 5 根羽毛。
2. 到达右侧终点传送门。

预期结果：

- 不通关。
- HUD 显示还需要几根羽毛。
- 玩家仍可继续操作。

失败时检查：

- scripts/NextLevelPortal.gd 的 locked_attempt。
- Main.gd 的 _on_portal_locked()。

### 4.2 羽毛足够时触碰传送门

步骤：

1. 收集至少 5 根羽毛。
2. 到达右侧终点传送门。

预期结果：

- 触发胜利。
- 玩家输入锁定。
- 胜利 UI 显示。
- 出现胜利粒子。

失败时检查：

- NextLevelPortal.gd 的 victory_requested。
- Main.gd 的 _on_victory_requested()。
- HUD.gd 的 show_victory()。
- Player.gd 的 celebrate()。

## 5. 宝箱

### 5.1 开启终点宝箱

步骤：

1. 进入终点区域。
2. 触碰宝箱。

预期结果：

- 宝箱打开。
- 分数增加。
- 羽翼能量恢复。
- 显示奖励提示。
- 再次触碰不重复领奖。

失败时检查：

- scripts/RewardChest.gd。
- Main.gd 的 _on_chest_reward_claimed()。

## 6. 失败状态

### 6.1 掉落扣生命

步骤：

1. 控制玩家从平台掉落云层以下。

预期结果：

- 玩家回到出生点或检查点。
- 生命 -1。
- 羽翼能量恢复。

失败时检查：

- Player.gd 的 _respawn()。
- Player.gd 中掉落高度判断。

### 6.2 生命归零

步骤：

1. 连续掉落直到生命归零。

预期结果：

- 玩家输入锁定。
- 播放失败状态。
- HUD 显示失败 UI。

失败时检查：

- Player.gd 的 defeated_state。
- Main.gd 的 _on_player_defeated()。
- HUD.gd 的 show_failure()。

## 7. 美术显示

### 7.1 像素显示

步骤：

1. 观察角色、平台、背景、HUD。
2. 缩放窗口。

预期结果：

- 像素风保持清晰。
- 不出现明显模糊。
- UI 不错位。

失败时检查：

- project.godot 的 texture_filter。
- StartMenu.gd 的 _layout_canvas()。
- StartMenu.tscn 的 texture_filter 设置。

## 8. 发布前结论

发布 v0.1-demo 前必须满足：

- [ ] 开始界面可以进入第一关。
- [ ] 第一关可以从头到尾完成。
- [ ] 少于 5 根羽毛无法通关。
- [ ] 5 根及以上羽毛到达传送门可以通关。
- [ ] 宝箱只领奖一次。
- [ ] 掉落扣生命。
- [ ] 生命归零失败。
- [ ] 无 Godot 红色报错。
- [ ] README 中操作说明与实际一致。
