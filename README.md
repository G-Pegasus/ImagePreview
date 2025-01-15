# MediaPreview

#### 介绍

简单易用的媒资预览框架,可自定义支持各种预览，仿微信一镜到底效果

#### 安装教程

执行安装命令
`ohpm install @lyb/media-preview`

#### 效果预览
![preview](MediaPreview/resources/preview.gif)

#### SDK Support

| SDK版本  | Support   |
|--------|-----------|
| 1.0.0  | 5.0.0(12) |

#### 1.2.0 迁移攻略
申明 `options` 的时候需指定model，默认 `DefaultMediaModel`

* 之前
```
options: MediaPreviewOptions = new MediaPreviewOptions()
```
* 1.2.0 之后
```
options: MediaPreviewOptions<DefaultMediaModel> = new MediaPreviewOptions<DefaultMediaModel>()
```
* 完全自定义
```
options: MediaPreviewOptions<MyMediaModel> = new MediaPreviewOptions<MyMediaModel>()
```

#### 使用说明
先设置资源
```
this.options
    .setInitIndex(index)
    .setMedias(this.resources)
```

再打开preview
```
MediaPreview.open(this.getUIContext(), this.options)
```

仿微信一镜到底效果设置
```
List({ space: 10 }) {
        ForEach(this.resources, (item: DefaultMediaModel, index: number) => {
          ListItem() {
            this.getImageItem(item, index)
          }
          //设置id，不然不会显示一镜到底效果
          .id(this.options.idBuilder(item, index))
          .aspectRatio(1)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.8 })
          //仿微信那种资源在预览时原始资源隐藏显示
          .visibility(index == this.index ? Visibility.Hidden : Visibility.Visible)
          .onClick(() => {
            this.options
              .setInitIndex(index)
              .setMedias(this.resources)
            //弹出preview
            MediaPreview.open(this.getUIContext(), this.options)
          })
        }, (item: DefaultMediaModel, index: number) => JSON.stringify(item) + index)
```

一镜到底效果优化，设置 `thumbBuilder` 
```
this.options
     .setThumbBuilder((item, index) => {
      this.customItem(item, index)
    })
```

#### 自定义
* 简单自定义

```
this.options
    .setContentBuilder((item, index) => {
      this.getContentBuilder(item as DefaultMediaModel, index)
    })
```
* 完全自定义

可从model开始自定义，详细见demo

#### 开源协议

[Apache-2.0](LICENSE)
