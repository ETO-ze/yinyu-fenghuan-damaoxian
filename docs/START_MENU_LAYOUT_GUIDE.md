# 开始界面贴图位置调整指南

开始界面场景是 `scenes/StartMenu.tscn`。现在关键贴图都已经拆成场景树节点，可以在 Godot 编辑器里直接调 Position。

## 如何调整

1. 用 Godot 打开 `scenes/StartMenu.tscn`。
2. 切到 2D 视图，展开节点 `StartMenu/MenuCanvas`。
3. 选中要调整的节点，在右侧 Inspector 修改 `Transform > Position`。
4. 改完按 `Ctrl + S` 保存场景，再按 F5 运行检查。

## 常用节点

| 节点 | 用途 |
| --- | --- |
| `GeneratedPixelArtBackground` | 整张开始界面背景，包含云海、塔楼、按钮框、角色、宝箱 |
| `TextTitle` | 中文标题 |
| `TextSubtitle` | 英文副标题 |
| `TextButtonStart` | “开始游戏”文字 |
| `TextButtonContinue` | “继续冒险”文字 |
| `TextButtonSettings` | “设置”文字 |
| `TextHintClickStart` | 底部提示文字 |
| `StartButton` | “开始游戏”的透明点击区域 |
| `ContinueButton` | “继续冒险”的透明点击区域 |
| `SettingsButton` | “设置”的透明点击区域 |

## 坐标规则

- 开始界面基准尺寸是 `480 x 854`。
- X 轴向右增加，Y 轴向下增加。
- 这些贴图是 2x 像素资源，所以 Sprite2D 的 `Scale` 保持 `0.5, 0.5`，不要随意改。
- 如果只移动文字，改 `TextButtonStart` 这类文字节点即可。
- 如果移动了按钮文字很多，也要同步移动对应的透明点击区域，例如 `StartButton`。

## 当前按钮文字位置

| 节点 | Position |
| --- | --- |
| `TextButtonStart` | `(130, 277)` |
| `TextButtonContinue` | `(130, 362)` |
| `TextButtonSettings` | `(130, 447)` |

## 注意

当前塔楼、按钮框、前景角色和宝箱仍然在 `GeneratedPixelArtBackground` 这张完整背景图里。如果你想单独移动塔楼、宝箱、角色或按钮框本身，需要把它们进一步拆成透明 PNG 独立图层后再接入场景。
