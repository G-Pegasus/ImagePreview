import { MediaModel } from '../models/MediaModel'
import { MediaPreviewOptions } from '../models/MediaPreviewOptions'
import { JSON } from '@kit.ArkTS'
import { MediaContainer } from './MediaContainer'
import ComponentUtils from '@ohos.arkui.UIContext';
import type componentUtils from '@ohos.arkui.componentUtils';
import { display } from '@kit.ArkUI';
import { PromptActionBaseBean, PromptActionTool } from '../utils/PromptActionTool';

@Component
export struct MediaPreviewComponent {
  @Link @Watch('valueChanged') promptAction: PromptActionBaseBean
  @Require options: MediaPreviewOptions = new MediaPreviewOptions()
  @Require @BuilderParam contentBuilder: (item: MediaModel, index: number) => void
  @BuilderParam thumbBuilder: (item: MediaModel, index: number) => void
  @BuilderParam toolBuilder: () => void
  @State private currentPage: number = 0
  @State private alpha: number = 0
  @State private currentOffsetX: number = 0
  @State private currentOffsetY: number = 0
  @State private preOffsetX: number = 0
  @State private preOffsetY: number = 0
  private dismissOffsetY: number = 150
  @State private scaleRadio: number = 1
  private firstLoad: boolean = false
  @State private animating: boolean = false
  private previewComponentInfo?: componentUtils.ComponentInfo
  @State private thumbWidth?: Length = 0
  @State private thumbHeight?: Length = 0
  @State private thumbX?: Length = 0
  @State private thumbY?: Length = 0
  private componentUtils: ComponentUtils.ComponentUtils = this.getUIContext().getComponentUtils()

  aboutToAppear() {
    this.currentPage = this.options.initIndex
    this.options.onPageChangedListener(this.options.dataSource.getData(this.currentPage), this.currentPage)
  }

  valueChanged() {
    if (this.promptAction.needDismiss) {
      this.closeAnimation(this.promptAction.dismissAnimation)
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.options.backgroundColor)
        .opacity(this.alpha)

      Swiper() {
        LazyForEach(this.options.dataSource, (item: MediaModel, index: number) => {
          if (this.thumbBuilder != undefined) {
            this.thumbBuilder(item, index)
          } else {
            this.contentBuilder(item, index)
          }
        }, (item: MediaModel, index: number) => JSON.stringify(item) + index)
      }
      .index(this.currentPage)
      .margin({
        left: this.thumbX,
        top: this.thumbY,
      })
      .width(this.thumbWidth)
      .height(this.thumbHeight)
      .indicator(false)
      .loop(false)
      .visibility(this.animating ? Visibility.Visible : Visibility.Hidden)

      Swiper() {
        LazyForEach(this.options.dataSource, (item: MediaModel, index: number) => {
          Column() {
            MediaContainer({
              options: this.options,
              contentBuilder: () => this.contentBuilder(item, index),
              zoomEnable: this.options.onZoomEnable(item, index)
            })
              .id(`preview+${this.options.idBuilder(item, index)}`)
              .offset({
                x: this.currentOffsetX,
                y: this.currentOffsetY,
              })
              .scale({ x: this.scaleRadio, y: this.scaleRadio })
              .visibility(!this.animating ? Visibility.Visible : Visibility.Hidden)
              .onAreaChange((_oldValue, newValue) => {
                if (newValue.height > 0) {
                  this.getPreviewUIInfo(index)
                  if (!this.firstLoad) {
                    this.firstLoad = true
                    this.startAnimation()
                  }
                }
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }, (item: MediaModel, index: number) => JSON.stringify(item) + index)
      }
      .indicator(this.options.indicator)
      .index(this.options.initIndex)
      .width("100%")
      .height("100%")
      .loop(false)
      .clip(true)
      .onChange((index) => {
        this.currentPage = index
        this.options.onPageChangedListener(this.options.dataSource.getData(index), index)
      })

      Row() {
        Blank()
        Text(`${this.currentPage + 1}/${this.options.dataSource.totalCount()}`)
          .fontColor(Color.White)
          .fontSize('14sp')
          .visibility(this.options.showPageText && this.options.dataSource.totalCount() > 1 ? Visibility.Visible :
          Visibility.None)
          .textShadow({
            radius: 4,
            color: "#5C000000",
            offsetX: 0,
            offsetY: 1
          })
          .margin({ top: '40vp', right: '40vp' })
      }
      .width('100%')

      if (this.toolBuilder != null) {
        Column() {
          this.toolBuilder()
        }
        .hitTestBehavior(HitTestMode.Transparent)
        .opacity(this.alpha)
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.closeAnimation()
    })
    .gesture(
      PanGesture({ fingers: 1 })
        .onActionStart(_event => {
          this.preOffsetX = this.currentOffsetX
          this.preOffsetY = this.currentOffsetY
        })
        .onActionUpdate(event => {
          this.currentOffsetX = this.preOffsetX + event.offsetX
          this.currentOffsetY = this.preOffsetY + event.offsetY
          let progress: number = 0
          if (Math.abs(this.currentOffsetY) >= this.dismissOffsetY) {
            progress = 1
          } else {
            progress = Math.abs(this.currentOffsetY) / this.dismissOffsetY
          }
          this.alpha = 1 - progress
          this.scaleRadio = 1 - 0.2 * (1 - this.alpha)
        })
        .onActionEnd(_event => {
          if (Math.abs(this.currentOffsetY) <= this.dismissOffsetY) {
            animateTo({
              duration: this.options.duration,
              curve: Curve.Linear,
              iterations: 1,
            }, () => {
              this.currentOffsetX = 0
              this.currentOffsetY = 0
              this.scaleRadio = 1
              this.alpha = 1
            })
          } else if (Math.abs(this.currentOffsetY) > this.dismissOffsetY) {
            this.closeAnimation()
          }
        })
    )
  }

  getPreviewUIInfo(index: number) {
    let result =
      this.componentUtils.getRectangleById(`preview+${this.options.idBuilder(this.options.dataSource.getData(index),
        index)}`)
    this.previewComponentInfo = result
  }

  getInitUIInfo() {
    let id = this.options.idBuilder(this.options.dataSource.getData(this.currentPage), this.currentPage)
    let result = this.componentUtils.getRectangleById(id)
    if (result.size.width > 0 && result.size.height > 0) {
      this.thumbX = px2vp(result.screenOffset?.x)
      this.thumbY = px2vp(result.screenOffset?.y)
      this.thumbWidth = px2vp(result.size?.width)
      this.thumbHeight = px2vp(result.size?.height)
    } else {
      this.thumbX = px2vp(display.getDefaultDisplaySync().width) / 2 - 10
      this.thumbY = px2vp(display.getDefaultDisplaySync().height) / 2 - 10
      this.thumbWidth = 10
      this.thumbHeight = 10
    }
  }

  startAnimation() {
    // @issue https://gitee.com/lyb5834/media-preview/issues/IB6B0R
    if (this.animating) {
      return
    }
    this.getInitUIInfo()
    this.animating = true
    animateTo({
      duration: this.options.duration, onFinish: () => {
        this.animating = false
      }
    }, () => {
      this.alpha = 1
      this.thumbX = px2vp(this.previewComponentInfo?.screenOffset?.x)
      this.thumbY = px2vp(this.previewComponentInfo?.screenOffset?.y)
      this.thumbWidth = px2vp(this.previewComponentInfo?.size?.width)
      this.thumbHeight = px2vp(this.previewComponentInfo?.size?.height)
    })
  }

  closeAnimation(animated: boolean = true) {
    // @issue https://gitee.com/lyb5834/media-preview/issues/IB6B0R
    if (this.animating) {
      return
    }
    this.getPreviewUIInfo(this.currentPage)
    this.animating = true
    this.thumbX = px2vp(this.previewComponentInfo?.screenOffset?.x) + this.currentOffsetX
    this.thumbY = px2vp(this.previewComponentInfo?.screenOffset?.y) + this.currentOffsetY
    this.thumbWidth = px2vp(this.previewComponentInfo?.size?.width) * this.scaleRadio
    this.thumbHeight = px2vp(this.previewComponentInfo?.size?.height) * this.scaleRadio
    animateTo({
      duration: animated ? this.options.duration : 0, onFinish: () => {
        this.animating = false
        this.options.onBackListener()
        PromptActionTool.closeCustomDialog(this.getUIContext(), this.promptAction.dialogId)
      }
    }, () => {
      this.getInitUIInfo()
      this.alpha = 0
    })
  }
}