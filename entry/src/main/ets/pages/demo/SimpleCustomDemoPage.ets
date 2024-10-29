import { MediaPreview, MediaPreviewOptions } from "MediaPreview"
import { DefaultMediaModel, DefaultMediaType } from "MediaPreview/src/main/ets/default/DefaultMediaModel"
import { HomeModel } from "../Index"

@Builder
export function SimpleDemoPageBuilder(name: string, param: object) {
  SimpleCustomDemoPage({ item: param as HomeModel })
}

//TODO: 简单自定义只是传入 `contentBuilder` 实现预览的自定义
@Component
export struct SimpleCustomDemoPage {
  @Prop item: HomeModel
  @State resources: DefaultMediaModel[] = []
  //TODO: 可在初始化的时候set回调，注：options 也不一定需要全局申明，可在点击的时候创建
  options: MediaPreviewOptions = new MediaPreviewOptions()
    .setPageChangedListener((_item, index) => {
      this.index = index
    })
    .setBackListener(() => {
      this.index = -1
    })
    .setLongPressListener((_item, index) => {
      console.log(`长按了第${index + 1}个资源`)
    })//TODO: 可以自定义id
    .setIdBuilder((_item, index) => {
      return `media_${index}`
    })//TODO: 设置thumb可以优化一镜到底效果，可以注释对比效果
    .setThumbBuilder((item, index) => {
      this.getImageItem(item as DefaultMediaModel, index)
    })//TODO: 设置 `contentBuilder` 可以自定义preview
    .setContentBuilder((item, index) => {
      this.getContentBuilder(item as DefaultMediaModel, index)
    })
  @State index: number = -1

  aboutToAppear(): void {
    this.resources = [
      new DefaultMediaModel(
        'https://mh.storage.shmedia.tech/86f0a492ec0e40b2bb7665e8c1c3f578.jpg',
        'https://mh.storage.shmedia.tech/86f0a492ec0e40b2bb7665e8c1c3f578.jpg?imageMogr2/auto-orient/thumbnail/300x300>',),
      new DefaultMediaModel(
        'https://mh.storage.shmedia.tech/98d8ab5e066047aa913c11f6d47136ad.jpg',
        'https://mh.storage.shmedia.tech/98d8ab5e066047aa913c11f6d47136ad.jpg?imageMogr2/auto-orient/thumbnail/300x300>'),
      new DefaultMediaModel(
        'https://mh.storage.shmedia.tech/0a1574f51f49409883ca31ee81f3011b.jpg',
        'https://mh.storage.shmedia.tech/0a1574f51f49409883ca31ee81f3011b.jpg?imageMogr2/auto-orient/thumbnail/300x300>'),
      new DefaultMediaModel(
        'https://mh.storage.shmedia.tech/f4fd277caeec4ddc896eef19f741ab0f.jpg',
        'https://mh.storage.shmedia.tech/f4fd277caeec4ddc896eef19f741ab0f.jpg?imageMogr2/auto-orient/thumbnail/300x300>'),
      new DefaultMediaModel(
        'https://mh.storage.shmedia.tech/0fb2f4863cfe408ab6dd9a02879e8cd4.jpg',
        'https://mh.storage.shmedia.tech/0fb2f4863cfe408ab6dd9a02879e8cd4.jpg?imageMogr2/auto-orient/thumbnail/300x300>'
      ),
      new DefaultMediaModel(
        'https://mh.storage.shmedia.tech/2e3e00c3ae1945c4bd7ac8078dbb7a83.mp4',
        'https://mh.storage.shmedia.tech/2e3e00c3ae1945c4bd7ac8078dbb7a83.mp4?vframe/jpg/offset/0',
        DefaultMediaType.VIDEO,
      )
    ]

  }

  build() {
    NavDestination() {
      List({ space: 10 }) {
        ForEach(this.resources, (item: DefaultMediaModel, index: number) => {
          ListItem() {
            this.getImageItem(item, index)
          }
          //TODO: 设置id，不然不会显示一镜到底效果
          // .id(this.options.idBuilder(item, index))
          //TODO: 如果列表数据模型和mediaPreview的数据模型不一致，可以自己设置，不过要和上面的`setIdBuilder`中id一致
          .id(`media_${index}`)
          .aspectRatio(1)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.8 })
          //TODO: 仿微信那种资源在预览时原始资源隐藏显示
          .visibility(index == this.index ? Visibility.Hidden : Visibility.Visible)
          .onClick(() => {
            this.options
              .setInitIndex(index)
              .setMedias(this.resources)
            MediaPreview.open(this.getUIContext(), this.options)
          })
        }, (item: DefaultMediaModel, index: number) => JSON.stringify(item) + index)
      }
      .width('100%')
      .height('100%')
      .lanes(3, 10)
      .padding(10)
    }
    .title(this.item.desc)
  }

  @Builder
  getImageItem(item: DefaultMediaModel, index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Image(item.thumbSrc)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(6)
        .clip(true)

      Image($r('app.media.play'))
        .width('30vp')
        .height('30vp')
        .fillColor(Color.White)
        .visibility(item.type == DefaultMediaType.VIDEO ? Visibility.Visible : Visibility.None)
    }
  }

  //TODO: 这里只是展示效果，就不详细绘制了
  @Builder
  getContentBuilder(item: DefaultMediaModel, _index: number) {
    Column() {
      Stack() {
        Image(item.thumbSrc)
          .objectFit(ImageFit.Cover)
          .width("100%")

        Image(item.sourceSrc)
          .objectFit(ImageFit.Cover)
          .autoResize(true)
          .width("100%")
      }
    }
    .justifyContent(FlexAlign.Center)
    .width("100%")
  }
}