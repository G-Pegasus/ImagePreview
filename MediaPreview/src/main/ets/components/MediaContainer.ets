import { MediaPreviewOptions } from '../models/MediaPreviewOptions'
import { display } from '@kit.ArkUI'

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
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All })
  private contentWidth: number = 0
  private contentHeight: number = 0
  private screenWidth: number = px2vp(display.getDefaultDisplaySync().width)
  private screenHeight: number = px2vp(display.getDefaultDisplaySync().height)

  build() {
    Scroll(this.vScroller) {
      Scroll(this.hScroller) {
        Column() {
          this.contentBuilder()
        }
        .width(this.itemWidth * this.currentScaleRatio)
        .onAreaChange(() => {
          if (this.currentScaleRatio == 1) {
            const h_res = this.hScroller.getItemRect(0)
            const v_res = this.vScroller.getItemRect(0)
            this.contentWidth = h_res.width
            this.contentHeight = v_res.height
            this.setPanDirection()
          }
        })
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
            this.setPanDirection()
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
            } else if (temp > this.options.maxScale + this.options.extraScale) {
              this.currentScaleRatio = this.options.maxScale + this.options.extraScale
            } else {
              this.currentScaleRatio = temp
            }
            this.hScroller.scrollTo({
              animation: { duration: 0 },
              xOffset: this.calculateOffsetX(event.pinchCenterX, this.currentScaleRatio),
              yOffset: 0
            })
            this.vScroller.scrollTo({
              animation: { duration: 0 },
              xOffset: 0,
              yOffset: this.calculateOffsetY(event.pinchCenterY, this.currentScaleRatio)
            })
          })
          .onActionEnd((_event) => {
            this.isPinching = false
            this.setPanDirection()
            if (this.currentScaleRatio < 1) {
              this.onAnimation(() => {
                this.currentScaleRatio = 1
                this.setPanDirection()
              })
            }
          }),

        // 双击手势
        TapGesture({ count: 2 })
          .onAction((event) => {
            this.currentPanOffsetY = this.vScroller.currentOffset().yOffset
            this.currentPanOffsetX = this.hScroller.currentOffset().xOffset
            if (event.fingerList.length == 0) {
              return
            }

            const fingerInfo = event.fingerList[0]
            if (this.currentScaleRatio === 1) {
              this.onAnimation(() => {
                this.currentScaleRatio = this.options.maxScale
                this.hScroller.scrollTo({
                  xOffset: this.calculateOffsetX(fingerInfo.localX, this.currentScaleRatio),
                  yOffset: 0
                })
                this.vScroller.scrollTo({
                  xOffset: 0,
                  yOffset: this.calculateOffsetY(fingerInfo.localY, this.currentScaleRatio)
                })
                this.setPanDirection()
              })
            } else {
              this.onAnimation(() => {
                this.currentScaleRatio = 1
                this.hScroller.scrollTo({
                  xOffset: this.calculateOffsetX(fingerInfo.localX, this.currentScaleRatio),
                  yOffset: 0
                })
                this.vScroller.scrollTo({
                  xOffset: 0,
                  yOffset: this.calculateOffsetY(fingerInfo.localY, this.currentScaleRatio)
                })
                this.setPanDirection()
              })
            }
          }),

        // 拖拽手势，用于预览
        PanGesture(this.panOption)
          .onActionStart((_event: GestureEvent) => {
            this.currentPanOffsetY = this.vScroller.currentOffset().yOffset
            this.currentPanOffsetX = this.hScroller.currentOffset().xOffset
            this.setPanDirection()
          })
          .onActionUpdate((event: GestureEvent) => {
            //长图时允许滑动
            if (this.currentScaleRatio > 1 || this.isLongPicture()) {
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
              this.setPanDirection()
            }
          })
          .onActionEnd((event: GestureEvent) => {
            this.setPanDirection()
            if (this.currentScaleRatio > 1 || this.isLongPicture()) {
              this.vScroller.fling(event.velocityY)
              this.hScroller.fling(event.velocityX)
            }
          }),
      )
    )
    .onGestureJudgeBegin((gestureInfo, _event) => {
      if (!this.zoomEnable) {
        return GestureJudgeResult.REJECT
      }
      if (gestureInfo.type == GestureControl.GestureType.PAN_GESTURE) {
        if (this.isPinching) {
          return GestureJudgeResult.REJECT
        }
        if (this.currentScaleRatio == 1) {
          if (this.isLongPicture()) {
            //长图时允许滑动
            return GestureJudgeResult.CONTINUE
          }
          return GestureJudgeResult.REJECT
        }
      }
      return GestureJudgeResult.CONTINUE
    })
  }

  calculateOffsetX(offsetX: number, radio: number): number {
    if (this.contentWidth * radio <= this.screenWidth) {
      return 0
    }
    const minOffsetX = 0
    const maxOffsetX = this.contentWidth * radio - this.screenWidth
    const currentOffsetX = this.currentPanOffsetX
    const currentCenterX = offsetX + currentOffsetX
    const currentAspectRatio = currentCenterX / this.contentWidth
    let calculateOffsetX =
      currentAspectRatio * this.contentWidth * (radio > 1 ? radio : radio / this.options.maxScale) - offsetX
    if (calculateOffsetX > maxOffsetX) {
      calculateOffsetX = maxOffsetX
    } else if (currentOffsetX < minOffsetX) {
      calculateOffsetX = minOffsetX
    }
    return calculateOffsetX
  }

  calculateOffsetY(offsetY: number, radio: number): number {
    if (this.contentHeight * radio <= this.screenHeight) {
      return 0
    }
    const minOffsetY = 0
    const maxOffsetY = this.contentHeight * radio - this.screenHeight
    const currentOffsetY = this.currentPanOffsetY
    const currentCenterY = offsetY + currentOffsetY
    const currentAspectRatio = currentCenterY / this.contentHeight
    let calculateOffsetY =
      currentAspectRatio * this.contentHeight * (radio > 1 ? radio : radio / this.options.maxScale) - offsetY
    if (calculateOffsetY > maxOffsetY) {
      calculateOffsetY = maxOffsetY
    } else if (currentOffsetY < minOffsetY) {
      calculateOffsetY = minOffsetY
    }
    console.log(`calculateOffsetY = ${calculateOffsetY} scale: ${radio}`)
    return calculateOffsetY
  }

  isLongPicture(): boolean {
    const result = this.vScroller.getItemRect(0)
    return this.currentScaleRatio == 1 && result.height > this.screenHeight
  }

  setPanDirection() {
    if (this.isLongPicture()) {
      if (this.vScroller.currentOffset().yOffset == 0) {
        this.panOption.setDirection(PanDirection.Up)
      } else if (this.vScroller.isAtEnd()) {
        this.panOption.setDirection(PanDirection.Down)
      } else {
        this.panOption.setDirection(PanDirection.Vertical)
      }
    } else {
      this.panOption.setDirection(PanDirection.All)
    }
  }

  onAnimation(action: () => void) {
    animateTo({
      duration: this.options.duration,
      curve: Curve.EaseInOut
    }, action)
  }
}