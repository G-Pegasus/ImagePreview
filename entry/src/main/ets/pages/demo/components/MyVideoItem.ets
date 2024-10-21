import { MyMediaModel } from "./MyMediaModel"

@Component
export struct MyVideoItem {
  @Prop resource: MyMediaModel
  @Prop index: number
  onLongPressListener?: (item: MyMediaModel, index: number) => void

  build() {
    Column() {
      Stack() {
        Video({ src: this.resource.sourceSrc })
          .width("100%")
          .height('100%')
          .objectFit(ImageFit.Contain)
          .controls(false)
          .autoPlay(true)
          .loop(true)

        Text(`自定义视频 ${this.index + 1}`)
          .fontColor(Color.White)
          .fontSize(16)
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width("100%")
    .clip(true)
    .gesture(
      LongPressGesture({ duration: 300 })
        .onAction((_event) => {
          this.onLongPressListener?.(this.resource, this.index)
        })
    )
  }
}