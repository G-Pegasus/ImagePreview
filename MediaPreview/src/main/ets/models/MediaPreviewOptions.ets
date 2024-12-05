import { MediaDataSource } from './MediaDataSource'
import { MediaModel } from './MediaModel'

export class MediaPreviewOptions {
  /**
   * 数据源
   */
  dataSource: MediaDataSource<MediaModel> = new MediaDataSource()
  /**
   * 初始化index
   */
  initIndex: number = 0
  /**
   * 最小缩放比例
   */
  minScale: number = 0.5
  /**
   * 最大缩放比例
   */
  maxScale: number = 3
  /**
   * 额外缩放比例，在最大最小的基础上缩放，提升用户体验
   */
  extraScale: number = 0.5
  /**
   * 指示器
   */
  indicator: DotIndicator | DigitIndicator | boolean = false
  /**
   * 背景色 默认 #000000
   */
  backgroundColor: ResourceColor = '#000000'
  /**
   * 动画时长
   */
  duration: number = 300
  /**
   * 是否显示分页文字
   */
  showPageText: boolean = true
  /**
   * 设置item的id 默认是 model + index
   */
  idBuilder: (item: MediaModel, index: number) => string = (item, index) => JSON.stringify(item) + index
  /**
   * 可设置thumb, 必须传@Builder，优化一镜到底效果
   */
  thumbBuilder?: (item: MediaModel, index: number) => void
  /**
   * 预览页，自定义的时候可传
   */
  contentBuilder?: (item: MediaModel, index: number) => void
  /**
   * 是否支持缩放，默认是true
   */
  onZoomEnable: (item: MediaModel, index: number) => boolean = () => true
  /**
   * 长按事件回调
   */
  onLongPressListener: (item: MediaModel, index: number) => void = () => {
  }
  /**
   * 返回回调
   */
  onBackListener: () => void = () => {
  }
  /**
   * page 切换回调
   */
  onPageChangedListener: (item: MediaModel, index: number) => void = () => {
  }

  constructor(medias: MediaModel[] = [], initIndex: number = 0) {
    this.dataSource.pushData(...medias)
    this.initIndex = initIndex
  }

  //=================================== Builders ===================================//
  /**
   * 设置数据list
   */
  setMedias(medias: MediaModel[]): MediaPreviewOptions {
    this.dataSource.clear()
    this.dataSource.pushData(...medias)
    return this
  }

  /**
   * 增加一条数据
   */
  addMedia(media: MediaModel): MediaPreviewOptions {
    this.dataSource.pushData(media)
    return this
  }

  /**
   * 删除一条数据
   */
  deleteMedia(index: number): MediaPreviewOptions {
    this.dataSource.deleteData(index)
    return this
  }

  /**
   * 设置初始化index
   */
  setInitIndex(initIndex: number): MediaPreviewOptions {
    this.initIndex = initIndex
    return this
  }

  /**
   * 设置最小缩放比例
   */
  setMinScale(minScale: number): MediaPreviewOptions {
    this.minScale = minScale
    return this
  }

  /**
   * 设置最大缩放比例
   */
  setMaxScale(maxScale: number): MediaPreviewOptions {
    this.maxScale = maxScale
    return this
  }

  /**
   * 设置额外缩放比例
   */
  setExtraScale(extraScale: number): MediaPreviewOptions {
    this.extraScale = extraScale
    return this
  }

  /**
   * 设置指示器
   */
  setIndicator(indicator: DotIndicator | DigitIndicator | boolean): MediaPreviewOptions {
    this.indicator = indicator
    return this
  }

  /**
   * 设置背景色
   */
  setBackgroundColor(backgroundColor: ResourceColor): MediaPreviewOptions {
    this.backgroundColor = backgroundColor
    return this
  }

  /**
   * 设置回调
   */
  setBackListener(onBackListener: () => void): MediaPreviewOptions {
    this.onBackListener = onBackListener
    return this
  }

  /**
   * 设置id
   */
  setIdBuilder(idBuilder: (item: MediaModel, index: number) => string): MediaPreviewOptions {
    this.idBuilder = idBuilder
    return this
  }

  /**
   * 设置thumb,优化一镜到底效果
   */
  setThumbBuilder(thumbBuilder: (item: MediaModel, index: number) => void): MediaPreviewOptions {
    this.thumbBuilder = thumbBuilder
    return this
  }

  /**
   * 设置content，自定义预览组件
   */
  setContentBuilder(contentBuilder: (item: MediaModel, index: number) => void): MediaPreviewOptions {
    this.contentBuilder = contentBuilder
    return this
  }

  /**
   * 监听page切换
   */
  setPageChangedListener(onPageChangedListener: (item: MediaModel, index: number) => void): MediaPreviewOptions {
    this.onPageChangedListener = onPageChangedListener
    return this
  }

  /**
   * 长按事件监听,自定义时失效
   */
  setLongPressListener(onLongPressListener: (item: MediaModel, index: number) => void): MediaPreviewOptions {
    this.onLongPressListener = onLongPressListener
    return this
  }

  /**
   * 设置动画时长
   */
  setDuration(duration: number): MediaPreviewOptions {
    this.duration = duration
    return this
  }

  /**
   * 设置是否显示分页文字
   */
  setShowPageText(showPageText: boolean): MediaPreviewOptions {
    this.showPageText = showPageText
    return this
  }
}