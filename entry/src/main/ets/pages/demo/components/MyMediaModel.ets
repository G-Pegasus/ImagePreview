import { MediaModel } from "MediaPreview";

export enum MyMediaModelType {
  IMAGE,
  VIDEO,
  AUDIO
}

export class MyMediaModel extends MediaModel {
  type: MyMediaModelType = MyMediaModelType.IMAGE
  sourceSrc?: ResourceStr
  thumbSrc?: ResourceStr

  constructor(sourceSrc?: ResourceStr, thumbSrc?: ResourceStr, type: MyMediaModelType = MyMediaModelType.IMAGE) {
    super();
    this.sourceSrc = sourceSrc
    this.thumbSrc = thumbSrc
    this.type = type
  }
}