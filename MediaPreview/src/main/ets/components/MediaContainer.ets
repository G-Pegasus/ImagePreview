import { MediaPreviewOptions } from '../models/MediaPreviewOptions'
import { display } from '@kit.ArkUI'
import { appManager, common } from '@kit.AbilityKit'

@Component
export struct MediaContainer {
  @Require @BuilderParam contentBuilder: () => void
  @Require @Prop options: MediaPreviewOptions
  @Prop zoomEnable: boolean = true
  onTap?: () => void
  @State private itemWidth: number = 0
  private hScroller: Scroller = new Scroller()
  private vScroller: Scroller = new Scroller()
  private currentPanOffsetX: number = 0
  private currentPanOffsetY: number = 0
  @State private currentScaleRatio: number = 1
  private preScaleRatio: number = 0
  private isPinching: boolean = false
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All })
  private contentWidth: number = 0
  private contentHeight: number = 0
  private screenWidth: number = px2vp(display.getDefaultDisplaySync().width)
  private screenHeight: number = px2vp(display.getDefaultDisplaySync().height)
  private currentMediaCenter: Size = { width: 0, height: 0 }
  private isScrolling: boolean = false
  private timeOutTag: number = 0

  build() {
    Scroll(this.vScroller) {
      Scroll(this.hScroller) {
        Column() {
          this.contentBuilder()
        }
        .width(this.zoomEnable ? this.itemWidth * this.currentScaleRatio : this.itemWidth)
        .renderFit(RenderFit.CENTER)
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
      .onScrollStart(() => {
        this.isScrolling = true
      })
      .onScrollStop(() => {
        clearTimeout(this.timeOutTag)
        this.timeOutTag = setTimeout(() => {
          this.isScrolling = false
        }, 500)
        this.setPanDirection()
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
    .onScrollStart(() => {
      this.isScrolling = true
    })
    .onScrollStop(() => {
      // 延迟设置scroll状态，可以有效降低滑动时的单击灵敏度
      clearTimeout(this.timeOutTag)
      this.timeOutTag = setTimeout(() => {
        this.isScrolling = false
      }, 500)
      this.setPanDirection()
    })
    .onVisibleAreaChange([0.0, 1.0], (isVisible, currentRatio) => {
      // @issue #IBBN8Y  https://gitee.com/lyb5834/media-preview/issues/IBBN8Y 只在前台活跃时还原
      let applicationContext = (getContext() as common.UIAbilityContext).getApplicationContext()
      if (currentRatio == 0) {
        clearTimeout(this.timeOutTag)
      }
      applicationContext.getRunningProcessInformation((err, data) => {
        if (data && data.length > 0) {
          let processInfo = data[0]
          if (processInfo.state == appManager.ProcessState.STATE_ACTIVE) {
            if (isVisible) {
              this.setPanDirection()
            }
            if (currentRatio == 0) {
              setTimeout(() => {
                this.currentScaleRatio = 1
              }, 300)
            }
          }
        }
      })
    })
    .gesture(
      GestureGroup(
        GestureMode.Exclusive,

        // 捏合手势
        PinchGesture()
          .onActionStart((event) => {
            if (!this.zoomEnable) {
              return
            }
            this.setPanDirection()
            this.currentPanOffsetY = this.vScroller.currentOffset().yOffset
            this.currentPanOffsetX = this.hScroller.currentOffset().xOffset
            this.preScaleRatio = this.currentScaleRatio
            this.currentMediaCenter = {
              width: (this.hScroller.currentOffset().xOffset + event.pinchCenterX) /
                (this.contentWidth * this.preScaleRatio),
              height: (this.vScroller.currentOffset().yOffset + event.pinchCenterY) /
                (this.contentHeight * this.preScaleRatio)
            }
            this.isPinching = true
          })
          .onActionUpdate((event) => {
            if (!this.zoomEnable) {
              return
            }
            // 修改比例
            const temp = event.scale * this.preScaleRatio
            if (temp < this.options.minScale) {
              this.currentScaleRatio = this.options.minScale
            } else if (temp > this.options.maxScale * (1 + this.options.extraScale)) {
              this.currentScaleRatio = this.options.maxScale * (1 + this.options.extraScale)
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
            this.setPanDirection()
          })
          .onActionEnd((event) => {
            if (!this.zoomEnable) {
              return
            }
            this.isPinching = false
            this.setPanDirection()
            this.currentMediaCenter = {
              width: (this.hScroller.currentOffset().xOffset + event.pinchCenterX) /
                (this.contentWidth * this.currentScaleRatio),
              height: (this.vScroller.currentOffset().yOffset + event.pinchCenterY) /
                (this.contentHeight * this.currentScaleRatio)
            }
            if (this.currentScaleRatio < 1) {
              this.onAnimation(() => {
                this.currentScaleRatio = 1
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
                this.setPanDirection()
                this.currentMediaCenter = {
                  width: (this.hScroller.currentOffset().xOffset + event.pinchCenterX) /
                    (this.contentWidth * this.currentScaleRatio),
                  height: (this.vScroller.currentOffset().yOffset + event.pinchCenterY) /
                    (this.contentHeight * this.currentScaleRatio)
                }
              })
            }
          }),

        // 双击手势
        TapGesture({ count: 2 })
          .onAction((event) => {
            if (!this.zoomEnable) {
              return
            }
            this.currentPanOffsetY = this.vScroller.currentOffset().yOffset
            this.currentPanOffsetX = this.hScroller.currentOffset().xOffset
            if (event.fingerList.length == 0) {
              return
            }

            const fingerInfo = event.fingerList[0]
            this.currentMediaCenter = {
              width: (this.hScroller.currentOffset().xOffset + fingerInfo.localX) /
                (this.contentWidth * this.currentScaleRatio),
              height: (this.vScroller.currentOffset().yOffset + fingerInfo.localY) /
                (this.contentHeight * this.currentScaleRatio)
            }
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
                this.currentMediaCenter = {
                  width: (this.hScroller.currentOffset().xOffset + fingerInfo.localX) /
                    (this.contentWidth * this.currentScaleRatio),
                  height: (this.vScroller.currentOffset().yOffset + fingerInfo.localY) /
                    (this.contentHeight * this.currentScaleRatio)
                }
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
                this.currentMediaCenter = {
                  width: (this.hScroller.currentOffset().xOffset + fingerInfo.localX) /
                    (this.contentWidth * this.currentScaleRatio),
                  height: (this.vScroller.currentOffset().yOffset + fingerInfo.localY) /
                    (this.contentHeight * this.currentScaleRatio)
                }
              })
            }
          }),

        // 单击手势
        TapGesture({ count: 1 })
          .onAction(() => {
            // 没有event
            if (!this.isScrolling && !this.isPinching) {
              this.onTap?.()
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

  calculateOffsetX(offsetX: number, ratio: number): number {
    if (this.contentWidth * ratio <= this.screenWidth) {
      return 0
    }
    const minOffsetX = 0
    const maxOffsetX = this.contentWidth * ratio - this.screenWidth
    const currentOffsetX = this.currentPanOffsetX
    let calculateOffsetX =
      this.currentMediaCenter.width * this.contentWidth * ratio - offsetX
    if (calculateOffsetX > maxOffsetX) {
      calculateOffsetX = maxOffsetX
    } else if (currentOffsetX < minOffsetX) {
      calculateOffsetX = minOffsetX
    }
    return calculateOffsetX
  }

  calculateOffsetY(offsetY: number, ratio: number): number {
    if (this.contentHeight * ratio <= this.screenHeight) {
      return 0
    }
    const minOffsetY = 0
    const maxOffsetY = this.contentHeight * ratio - this.screenHeight
    const currentOffsetY = this.currentPanOffsetY
    let calculateOffsetY =
      this.currentMediaCenter.height * this.contentHeight * ratio - offsetY
    if (calculateOffsetY > maxOffsetY) {
      calculateOffsetY = maxOffsetY
    } else if (currentOffsetY < minOffsetY) {
      calculateOffsetY = minOffsetY
    }
    return calculateOffsetY
  }

  isLongPicture(): boolean {
    const result = this.vScroller.getItemRect(0)
    return this.currentScaleRatio == 1 && result.height > this.screenHeight
  }

  setPanDirection() {
    if (this.isLongPicture() && this.currentScaleRatio == 1) {
      if (this.vScroller.currentOffset().yOffset == 0) {
        this.panOption.setDirection(PanDirection.Up)
      } else if (this.vScroller.isAtEnd()) {
        this.panOption.setDirection(PanDirection.Down)
      } else {
        this.panOption.setDirection(PanDirection.Vertical)
      }
    } else if (this.currentScaleRatio > 1) {
      const maxOffsetX = Math.ceil(this.contentWidth * this.currentScaleRatio - this.screenWidth)
      const maxOffsetY = Math.ceil(this.contentHeight * this.currentScaleRatio - this.screenHeight)
      const currentOffsetX = Math.ceil(this.hScroller.currentOffset().xOffset)
      const currentOffsetY = Math.ceil(this.vScroller.currentOffset().yOffset)
      if (maxOffsetY <= 0) {
        if (currentOffsetX == 0) {
          this.panOption.setDirection(PanDirection.Left)
        } else if (currentOffsetX >= maxOffsetX) {
          this.panOption.setDirection(PanDirection.Right)
        } else {
          this.panOption.setDirection(PanDirection.Horizontal)
        }
      } else {
        if (currentOffsetX == 0 && currentOffsetY == 0) {
          this.panOption.setDirection(PanDirection.Left | PanDirection.Up)
        } else if (currentOffsetX == 0 && currentOffsetY >= maxOffsetY) {
          this.panOption.setDirection(PanDirection.Left | PanDirection.Down)
        } else if (currentOffsetX >= maxOffsetX && currentOffsetY == 0) {
          this.panOption.setDirection(PanDirection.Right | PanDirection.Up)
        } else if (currentOffsetX >= maxOffsetX && currentOffsetY >= maxOffsetY) {
          this.panOption.setDirection(PanDirection.Right | PanDirection.Down)
        } else if (currentOffsetX == 0) {
          this.panOption.setDirection(PanDirection.Left | PanDirection.Vertical)
        } else if (currentOffsetX >= maxOffsetX) {
          this.panOption.setDirection(PanDirection.Right | PanDirection.Vertical)
        } else if (currentOffsetY == 0) {
          this.panOption.setDirection(PanDirection.Horizontal | PanDirection.Up)
        } else if (currentOffsetY >= maxOffsetY) {
          this.panOption.setDirection(PanDirection.Horizontal | PanDirection.Down)
        } else {
          this.panOption.setDirection(PanDirection.All)
        }
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