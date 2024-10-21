import { MyMediaModel } from "./MyMediaModel"

@Component
export struct MyImageItem {
  @Prop resource: MyMediaModel
  @Prop index: number
  onLongPressListener?: (item: MyMediaModel, index: number) => void
  @State private loadingStatus: number = -1

  build() {
    Column() {
      Stack({alignContent: Alignment.Center}) {
        Image(this.resource?.sourceSrc)
          .objectFit(ImageFit.Cover)
          .visibility(this.loadingStatus == 1 ? Visibility.Visible : Visibility.Hidden)
          .onComplete(event => {
            this.loadingStatus = event?.loadingStatus ?? -1
          })
          .width("100%")

        Text(`自定义图片 ${this.index + 1}`)
          .fontColor(Color.White)
          .fontSize(16)
      }
    }
    .justifyContent(FlexAlign.Center)
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