import { DefaultMediaModel } from './DefaultMediaModel'

@Component
export struct DefaultImageItem {
  @Prop resource: DefaultMediaModel
  @Prop index: number
  onLongPressListener?: (item: DefaultMediaModel, index: number) => void
  @State private loadingStatus: number = -1

  build() {
    Column() {
      Stack() {
        Image(this.resource?.thumbSrc)
          .objectFit(ImageFit.Cover)
          .width("100%")
          .visibility(this.loadingStatus == 1 ? Visibility.None : Visibility.Visible)

        Image(this.resource?.sourceSrc)
          .objectFit(ImageFit.Cover)
          .visibility(this.loadingStatus == 1 ? Visibility.Visible : Visibility.Hidden)
          .onComplete(event => {
            this.loadingStatus = event?.loadingStatus ?? -1
          })
          .width("100%")
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