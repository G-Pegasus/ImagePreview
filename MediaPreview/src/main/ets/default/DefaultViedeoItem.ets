import { DefaultMediaModel } from './DefaultMediaModel'

@Component
export struct DefaultVideoItem {
  @Prop resource: DefaultMediaModel
  @Prop index: number
  onLongPressListener?: (item: DefaultMediaModel, index: number) => void

  build() {
    Column() {
      VideoPlayer({
        src: this.resource.sourceSrc,
        previewUri: this.resource.thumbSrc
      })
        .width("100%")
        .height('100%')
    }
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height("100%")
    .gesture(
      LongPressGesture({ duration: 300 })
        .onAction((_event) => {
          this.onLongPressListener?.(this.resource, this.index)
        })
    )
  }
}

enum PlayerState {
  STATE_NOT_PLAY = "not_play",
  STATE_PLAYING = "playing",
  STATE_PAUSED = "paused",
  STATE_COMPLETED = "completed",
  STATE_ERROR = "error"
}

@Component
export struct VideoPlayer {
  controller: VideoController = new VideoController()
  @Prop src: string | Resource
  @Prop previewUri: string | PixelMap | Resource
  @State isPlaying: boolean = false
  @State playerState: PlayerState = PlayerState.STATE_NOT_PLAY
  @State totalTime: number = 0
  @State currentTime: number = 0

  aboutToDisappear(): void {
    this.controller.stop()
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        this.setupVideo()
        this.placeImageUI()
        this.bottomViewUI()
      }
      .width("100%")
      .height("100%")
    }
    .onClick(() => this.playAction())
  }

  @Builder
  setupVideo() {
    Video({ src: this.src, controller: this.controller })
      .width("100%")
      .height('100%')
      .onPrepared((time) => {
        this.totalTime = time.duration
      })
      .onStart(() => {
        this.isPlaying = true
        this.playerState = PlayerState.STATE_PLAYING
      })
      .onPause(() => {
        this.isPlaying = false //暂停
        this.playerState = PlayerState.STATE_PAUSED
      })
      .onFinish(() => {
        this.isPlaying = false //播放完成
        this.playerState = PlayerState.STATE_COMPLETED
      })
      .onError(() => {
        this.isPlaying = false //播放出错
        this.playerState = PlayerState.STATE_ERROR
      })
      .onUpdate((time) => {
        this.currentTime = time.time
      })
      .objectFit(ImageFit.Contain)// 自适应视频的最佳状态，不要拉伸视频
      .controls(false)
      .autoPlay(true)
      .loop(true)
  }

  @Builder
  placeImageUI() {
    Image(this.previewUri)
      .width("100%")
      .height("100%")
      .objectFit(ImageFit.Contain)
      .visibility((this.playerState === PlayerState.STATE_PLAYING
        || this.playerState === PlayerState.STATE_PAUSED
        || this.playerState === PlayerState.STATE_COMPLETED
        || this.playerState === PlayerState.STATE_ERROR) ? Visibility.Hidden : Visibility.Visible)
  }

  @Builder
  bottomViewUI() {
    Row({ space: 8 }) {
      Image(this.isPlaying ? $r('app.media.video_player_pause') : $r('app.media.video_player_play'))
        .width(20)
        .height(20)
        .objectFit(ImageFit.Fill)
      Text(this.getTextTime(this.currentTime)).fontColor(Color.White).fontSize(18)
      Slider({
        value: this.currentTime,
        min: 0,
        max: this.totalTime,
        step: 1,
        style: SliderStyle.OutSet
      })
        .layoutWeight(1)
        .blockColor(Color.White)
        .trackColor(Color.Gray)
        .selectedColor(Color.White)
        .showSteps(false)
        .showTips(false)
        .trackThickness(4)
        .onChange((num) => {
          let n = parseInt(num.toFixed(0))
          this.currentTime = n
          this.controller?.setCurrentTime(num)
        })
      Text(this.getTextTime(this.totalTime)).fontColor(Color.White).fontSize(18)
    }
    .padding({
      left: 16,
      right: 16,
      bottom: 40,
    })
    .width('100%')
    .height(60)
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [["#99000000", 0.0], ["#00000000", 1.0]]
    })
  }

  private playAction() {
    if (this.isPlaying) {
      this.controller?.pause()
    } else {
      this.controller?.start()
      this.playerState = PlayerState.STATE_NOT_PLAY
    }
    this.isPlaying = !this.isPlaying
  }

  private getTextTime(num: number) {
    let str: string = ''
    if (num < 60) {
      return `00:${num < 10 ? `0${num}` : num}`
    }
    if (num < 60 * 60) {
      let m = Number.parseInt(`${num / 60}`)
      let s = num % 60
      return `${m < 10 ? `0${m}` : m}:${s < 10 ? `0${s}` : s}`
    }
    return str
  }
}