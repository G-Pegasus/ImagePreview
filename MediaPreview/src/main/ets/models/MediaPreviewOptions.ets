import { MediaDataSource } from './MediaDataSource'
import { MediaModel } from './MediaModel'

export class MediaPreviewOptions<T extends MediaModel> {
  /**
   * 数据源
   */
  dataSource: MediaDataSource<T> = new MediaDataSource()
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
  idBuilder: (item: T, index: number) => string = (item, index) => JSON.stringify(item) + index
  /**
   * 可设置thumb, 必须传@Builder，优化一镜到底效果
   */
  thumbBuilder?: (item: T, index: number) => void
  /**
   * 预览页，自定义的时候可传
   */
  contentBuilder?: (item: T, index: number) => void
  /**
   * 工具页
   */
  toolBuilder?: () => void
  /**
   * 是否支持缩放，默认是true
   */
  onZoomEnable: (item: T, index: number) => boolean = () => true
  /**
   * 长按事件回调
   */
  onLongPressListener: (item: T, index: number) => void = () => {
  }
  /**
   * 返回回调
   */
  onBackListener: () => void = () => {
  }
  /**
   * page 切换回调
   */
  onPageChangedListener: (item: T, index: number) => void = () => {
  }

  constructor(medias: T[] = [], initIndex: number = 0) {
    this.dataSource.pushData(...medias)
    this.initIndex = initIndex
  }

  //=================================== Builders ===================================//
  /**
   * 设置数据list
   */
  setMedias(medias: T[]): MediaPreviewOptions<T> {
    this.dataSource.clear()
    this.dataSource.pushData(...medias)
    return this
  }

  /**
   * 增加一条数据
   */
  addMedia(media: T): MediaPreviewOptions<T> {
    this.dataSource.pushData(media)
    return this
  }

  /**
   * 删除一条数据
   */
  deleteMedia(index: number): MediaPreviewOptions<T> {
    this.dataSource.deleteData(index)
    return this
  }

  /**
   * 设置初始化index
   */
  setInitIndex(initIndex: number): MediaPreviewOptions<T> {
    this.initIndex = initIndex
    return this
  }

  /**
   * 设置最小缩放比例
   */
  setMinScale(minScale: number): MediaPreviewOptions<T> {
    this.minScale = minScale
    return this
  }

  /**
   * 设置最大缩放比例
   */
  setMaxScale(maxScale: number): MediaPreviewOptions<T> {
    this.maxScale = maxScale
    return this
  }

  /**
   * 设置额外缩放比例
   */
  setExtraScale(extraScale: number): MediaPreviewOptions<T> {
    this.extraScale = extraScale
    return this
  }

  /**
   * 设置指示器
   */
  setIndicator(indicator: DotIndicator | DigitIndicator | boolean): MediaPreviewOptions<T> {
    this.indicator = indicator
    return this
  }

  /**
   * 设置背景色
   */
  setBackgroundColor(backgroundColor: ResourceColor): MediaPreviewOptions<T> {
    this.backgroundColor = backgroundColor
    return this
  }

  /**
   * 设置回调
   */
  setBackListener(onBackListener: () => void): MediaPreviewOptions<T> {
    this.onBackListener = onBackListener
    return this
  }

  /**
   * 设置id
   */
  setIdBuilder(idBuilder: (item: T, index: number) => string): MediaPreviewOptions<T> {
    this.idBuilder = idBuilder
    return this
  }

  /**
   * 设置是否可以缩放
   */
  setZoomEnable(zoomBuilder: (item: T, index: number) => boolean): MediaPreviewOptions<T> {
    this.onZoomEnable = zoomBuilder
    return this
  }

  /**
   * 设置thumb,优化一镜到底效果
   */
  setThumbBuilder(thumbBuilder: (item: T, index: number) => void): MediaPreviewOptions<T> {
    this.thumbBuilder = thumbBuilder
    return this
  }

  /**
   * 设置content，自定义预览组件
   */
  setContentBuilder(contentBuilder: (item: T, index: number) => void): MediaPreviewOptions<T> {
    this.contentBuilder = contentBuilder
    return this
  }

  /**
   * 可设置工具栏
   */
  setToolBuilder(toolBuilder: () => void): MediaPreviewOptions<T> {
    this.toolBuilder = toolBuilder
    return this
  }

  /**
   * 监听page切换
   */
  setPageChangedListener(onPageChangedListener: (item: T, index: number) => void): MediaPreviewOptions<T> {
    this.onPageChangedListener = onPageChangedListener
    return this
  }

  /**
   * 长按事件监听,自定义时失效
   */
  setLongPressListener(onLongPressListener: (item: T, index: number) => void): MediaPreviewOptions<T> {
    this.onLongPressListener = onLongPressListener
    return this
  }

  /**
   * 设置动画时长
   */
  setDuration(duration: number): MediaPreviewOptions<T> {
    this.duration = duration
    return this
  }

  /**
   * 设置是否显示分页文字
   */
  setShowPageText(showPageText: boolean): MediaPreviewOptions<T> {
    this.showPageText = showPageText
    return this
  }
}