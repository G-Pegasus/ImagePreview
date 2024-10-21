import { MediaPreviewOptions } from '../models/MediaPreviewOptions'

@Component
export struct MediaContainer {
  @Require @BuilderParam contentBuilder: () => void
  @Require @Prop options: MediaPreviewOptions
  @Prop zoomEnable: boolean = true
  @State private itemWidth: number = 0
  private hScroller: Scroller = new Scroller()
  private vScroller: Scroller = new Scroller()
  private currentPanOffsetX: number = 0
  private currentPanOffsetY: number = 0
  @State private currentScaleRatio: number = 1
  private preScaleRadio: number = 0
  private isPinching: boolean = false

  build() {
    Scroll(this.vScroller) {
      Scroll(this.hScroller) {
        Column() {
          this.contentBuilder()
        }
        .width(this.itemWidth * this.currentScaleRatio)
      }
      .scrollBar(BarState.Off)
      .enableScrollInteraction(false)
      .scrollable(ScrollDirection.Horizontal)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST
      })
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .enableScrollInteraction(false)
    .scrollable(ScrollDirection.Vertical)
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.PARENT_FIRST
    })
    .onAreaChange((_oldValue, newValue) => {
      this.itemWidth = Number.parseFloat(newValue.width.toString())
    })
    .gesture(
      GestureGroup(
        GestureMode.Parallel,

        // 捏合手势
        PinchGesture()
          .onActionStart((_event) => {
            this.currentPanOffsetY = this.vScroller.currentOffset().yOffset
            this.currentPanOffsetX = this.hScroller.currentOffset().xOffset
            this.preScaleRadio = this.currentScaleRatio
            this.isPinching = true
          })
          .onActionUpdate((event) => {
            // 修改比例
            const temp = event.scale * this.preScaleRadio
            if (temp < this.options.minScale) {
              this.currentScaleRatio = this.options.minScale
            } else if (temp > this.options.maxScale * (1 + this.options.extraScale)) {
              this.currentScaleRatio = this.options.maxScale * (1 + this.options.extraScale)
            } else {
              this.currentScaleRatio = temp
            }
            this.vScroller.scrollTo({
              animation: { duration: 0 },
              xOffset: 0,
              yOffset: this.currentScaleRatio * event.pinchCenterY
            })
            this.hScroller.scrollTo({
              animation: { duration: 0 },
              yOffset: 0,
              xOffset: this.currentScaleRatio * event.pinchCenterX
            })
          })
          .onActionEnd((_event) => {
            this.isPinching = false
            if (this.currentScaleRatio < 1) {
              this.onAnimation(() => {
                this.currentScaleRatio = 1
              })
            }
          }),

        // 双击手势
        TapGesture({ count: 2 })
          .onAction((event) => {
            if (event.fingerList.length == 0) {
              return
            }
            const fingerInfo = event.fingerList[0]
            if (this.currentScaleRatio === 1) {
              this.onAnimation(() => {
                this.currentScaleRatio = this.options.maxScale
                this.hScroller.scrollTo({
                  xOffset: fingerInfo.localX * this.currentScaleRatio / 2,
                  yOffset: 0
                })
                this.vScroller.scrollTo({
                  xOffset: 0,
                  yOffset: fingerInfo.localY * this.currentScaleRatio / 2,
                })
              })
            } else {
              this.onAnimation(() => {
                this.hScroller.scrollTo({
                  xOffset: 0,
                  yOffset: 0
                })
                this.vScroller.scrollTo({
                  xOffset: 0,
                  yOffset: 0
                })
                this.currentScaleRatio = 1
              })
            }
          }),

        // 拖拽手势，用于预览
        PanGesture({ fingers: 1 })
          .onActionStart((_event: GestureEvent) => {
            this.currentPanOffsetY = this.vScroller.currentOffset().yOffset
            this.currentPanOffsetX = this.hScroller.currentOffset().xOffset
          })
          .onActionUpdate((event: GestureEvent) => {
            if (this.currentScaleRatio > 1) {
              this.vScroller.scrollTo({
                xOffset: 0,
                yOffset: this.currentPanOffsetY - event.offsetY,
                animation: { duration: 0 }
              })
              this.hScroller.scrollTo({
                xOffset: this.currentPanOffsetX - event.offsetX,
                yOffset: 0,
                animation: { duration: 0 }
              })
            }
          })
          .onActionEnd((event: GestureEvent) => {
            if (this.currentScaleRatio > 1) {
              this.onAnimation(() => {
                this.vScroller.fling(event.velocityY)
                this.hScroller.fling(event.velocityX)
              })
            }
          }),
      )
    )
    .onGestureJudgeBegin((gestureInfo, _event) => {
      if (!this.zoomEnable) {
        return GestureJudgeResult.REJECT
      }
      if (gestureInfo.type == GestureControl.GestureType.PAN_GESTURE) {
        if (this.currentScaleRatio == 1 || this.isPinching) {
          return GestureJudgeResult.REJECT
        }
      }
      return GestureJudgeResult.CONTINUE
    })
  }

  onAnimation(action: () => void) {
    animateTo({
      duration: this.options.duration,
      curve: Curve.EaseInOut
    }, action)
  }
}