import {
  MediaModel,
  MediaPreviewComponent,
  MediaPreviewOptions,
  PreviewCloseParam,
  PromptActionTool
} from "MediaPreview"
import { MediaPreviewPromptAction } from "MediaPreview/src/main/ets/models/MediaPreviewPromptAction"
import { MyImageItem } from "./MyImageItem"
import { MyMediaModel, MyMediaModelType } from "./MyMediaModel"
import { MyVideoItem } from "./MyVideoItem"

@Component
export struct MyMediaPreview {
  @Require @Prop action: MediaPreviewPromptAction<MyMediaModel>

  build() {
    MediaPreviewComponent({
      promptAction: this.action,
      options: this.action.options,
      thumbBuilder: this.action.options.thumbBuilder,
      toolBuilder: this.action.options.toolBuilder,
      contentBuilder: (item: MyMediaModel, index: number) => {
        if (item.type == MyMediaModelType.IMAGE) {
          this.imageBuilder(item, index)
        } else if (item.type == MyMediaModelType.VIDEO) {
          this.videoBuilder(item, index)
        } else {
          // 音频样式... 自己实现
        }
      },
    })
      .width('100%')
      .height('100%')
  }

  @Builder
  imageBuilder(item: MyMediaModel, index: number) {
    MyImageItem({
      resource: item ,
      index: index,
      onLongPressListener: this.action.options.onLongPressListener,
    })
  }

  @Builder
  videoBuilder(item: MyMediaModel, index: number) {
    MyVideoItem({
      resource: item ,
      index: index,
      onLongPressListener: this.action.options.onLongPressListener,
    })
  }
}

@Builder
export function MyMediaPreviewBuilder(action: MediaPreviewPromptAction<ESObject>) {
  MyMediaPreview({
    action: action,
  })
}

export class CustomMediaPreview {
  static open<T extends MediaModel>(uiContext: UIContext, options: MediaPreviewOptions<T>) {
    let value = new MediaPreviewPromptAction(options)
    PromptActionTool.openCustomDialog<MediaPreviewPromptAction<T>>(uiContext, {
      builder: wrapBuilder(MyMediaPreviewBuilder),
      params: value,
    })
  }

  static close(params?: PreviewCloseParam) {
    PromptActionTool.closePreview(params)
  }
}