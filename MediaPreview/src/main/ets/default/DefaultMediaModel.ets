import { MediaModel } from "../models/MediaModel";


export enum DefaultMediaType {
  IMAGE,
  VIDEO
}

export class DefaultMediaModel extends MediaModel {
  /**
   * 类型
   */
  type: DefaultMediaType = DefaultMediaType.IMAGE
  /**
   * 资源图片
   */
  sourceSrc?: ResourceStr
  /**
   * 缩略图
   */
  thumbSrc?: ResourceStr

  constructor(sourceSrc?: ResourceStr, thumbSrc?: ResourceStr, type: DefaultMediaType = DefaultMediaType.IMAGE) {
    super();
    this.sourceSrc = sourceSrc
    this.thumbSrc = thumbSrc
    this.type = type
  }
}