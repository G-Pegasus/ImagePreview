import { MediaPreviewOptions } from "MediaPreview"
import { HomeModel } from "../Index"
import { MyMediaModel, MyMediaModelType } from "./components/MyMediaModel"
import { CustomMediaPreview } from "./components/MyMediaPreview"

@Builder
export function CustomDemoPageBuilder(name: string, param: object) {
  CustomDemoPage({ item: param as HomeModel })
}

//TODO: 完全自定义从model，到preview可以完全自定义
@Component
export struct CustomDemoPage {
  @Prop item: HomeModel
  @State resources: MyMediaModel[] = []
  options: MediaPreviewOptions<MyMediaModel> = new MediaPreviewOptions()
  @State index: number = -1

  aboutToAppear(): void {
    this.resources = [
      new MyMediaModel(
        'https://mh.storage.shmedia.tech/86f0a492ec0e40b2bb7665e8c1c3f578.jpg',
        'https://mh.storage.shmedia.tech/86f0a492ec0e40b2bb7665e8c1c3f578.jpg?imageMogr2/auto-orient/thumbnail/300x300>',),
      new MyMediaModel(
        'https://mh.storage.shmedia.tech/98d8ab5e066047aa913c11f6d47136ad.jpg',
        'https://mh.storage.shmedia.tech/98d8ab5e066047aa913c11f6d47136ad.jpg?imageMogr2/auto-orient/thumbnail/300x300>'),
      new MyMediaModel(
        'https://mh.storage.shmedia.tech/0a1574f51f49409883ca31ee81f3011b.jpg',
        'https://mh.storage.shmedia.tech/0a1574f51f49409883ca31ee81f3011b.jpg?imageMogr2/auto-orient/thumbnail/300x300>'),
      new MyMediaModel(
        'https://mh.storage.shmedia.tech/f4fd277caeec4ddc896eef19f741ab0f.jpg',
        'https://mh.storage.shmedia.tech/f4fd277caeec4ddc896eef19f741ab0f.jpg?imageMogr2/auto-orient/thumbnail/300x300>'),
      new MyMediaModel(
        'https://mh.storage.shmedia.tech/0fb2f4863cfe408ab6dd9a02879e8cd4.jpg',
        'https://mh.storage.shmedia.tech/0fb2f4863cfe408ab6dd9a02879e8cd4.jpg?imageMogr2/auto-orient/thumbnail/300x300>'
      ),
      new MyMediaModel(
        'https://gd-hbimg.huaban.com/fedf4f47abe4ca16ab6432480c2b47233317d9462caa88-d9fyor_fw236',
        'https://gd-hbimg.huaban.com/fedf4f47abe4ca16ab6432480c2b47233317d9462caa88-d9fyor_fw236'
      ),
      new MyMediaModel(
        'https://img95.699pic.com/photo/50080/3093.jpg_wh300.jpg',
        'https://img95.699pic.com/photo/50080/3093.jpg_wh300.jpg'
      ),
      new MyMediaModel(
        'https://mh.storage.shmedia.tech/2e3e00c3ae1945c4bd7ac8078dbb7a83.mp4',
        'https://mh.storage.shmedia.tech/2e3e00c3ae1945c4bd7ac8078dbb7a83.mp4?vframe/jpg/offset/0',
        MyMediaModelType.VIDEO,
      )
    ]

    this.options
      .setPageChangedListener((_item, index) => {
        this.index = index
      })
      .setBackListener(() => {
        this.index = -1
      })
      .setLongPressListener((_item, index) => {
        console.log(`长按了第${index + 1}个资源`)
      })//TODO: 设置thumb可以优化一镜到底效果，可以注释对比效果
      .setThumbBuilder((item, index) => {
        this.getImageItem(item, index)
      })
  }

  build() {
    NavDestination() {
      List({ space: 10 }) {
        ForEach(this.resources, (item: MyMediaModel, index: number) => {
          ListItem() {
            this.getImageItem(item, index)
          }
          //TODO: 设置id，不然不会显示一镜到底效果
          .id(this.options.idBuilder(item, index))
          .aspectRatio(1)
          .clickEffect({ level: ClickEffectLevel.MIDDLE, scale: 0.8 })
          //TODO: 仿微信那种资源在预览时原始资源隐藏显示
          .visibility(index == this.index ? Visibility.Hidden : Visibility.Visible)
          .onClick(() => {
            this.options
              .setInitIndex(index)
              .setMedias(this.resources)
            CustomMediaPreview.open(this.getUIContext(), this.options)
          })
        }, (item: MyMediaModel, index: number) => JSON.stringify(item) + index)
      }
      .width('100%')
      .height('100%')
      .lanes(3, 10)
      .padding(10)
    }
    .title(this.item.desc)
  }

  @Builder
  getImageItem(item: MyMediaModel, index: number) {
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
        .visibility(item.type == MyMediaModelType.VIDEO ? Visibility.Visible : Visibility.None)
    }
  }
}