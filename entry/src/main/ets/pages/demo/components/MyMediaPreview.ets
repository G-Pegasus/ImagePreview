import {
  MediaModel,
  MediaPreviewComponent,
  MediaPreviewOptions,
  PreviewCloseParam,
  PromptActionTool
} from "MediaPreview"
import { DefaultMediaModel, DefaultMediaType } from "MediaPreview/src/main/ets/default/DefaultMediaModel"
import { MediaPreviewPromptAction } from "MediaPreview/src/main/ets/models/MediaPreviewPromptAction"
import { MyImageItem } from "./MyImageItem"
import { MyMediaModel } from "./MyMediaModel"
import { MyVideoItem } from "./MyVideoItem"

@Component
export struct MyMediaPreview {
  @Require @Prop action: MediaPreviewPromptAction

  build() {
    MediaPreviewComponent({
      promptAction: this.action,
      options: this.action.options,
      thumbBuilder: this.action.options.thumbBuilder,
      toolBuilder: this.action.options.toolBuilder,
      contentBuilder: (item: MediaModel, index: number) => {
        if ((item as DefaultMediaModel).type == DefaultMediaType.IMAGE) {
          this.imageBuilder(item, index)
        } else if ((item as DefaultMediaModel).type == DefaultMediaType.VIDEO) {
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
  imageBuilder(item: MediaModel, index: number) {
    MyImageItem({
      resource: item as MyMediaModel,
      index: index,
      onLongPressListener: this.action.options.onLongPressListener,
    })
  }

  @Builder
  videoBuilder(item: MediaModel, index: number) {
    MyVideoItem({
      resource: item as MyMediaModel,
      index: index,
      onLongPressListener: this.action.options.onLongPressListener,
    })
  }
}

@Builder
export function MyMediaPreviewBuilder(action: MediaPreviewPromptAction) {
  MyMediaPreview({
    action: action,
  })
}

export class CustomMediaPreview {
  static open(uiContext: UIContext, options: MediaPreviewOptions) {
    let value = new MediaPreviewPromptAction(options)
    PromptActionTool.openCustomDialog<MediaPreviewPromptAction>(uiContext, {
      builder: wrapBuilder(MyMediaPreviewBuilder),
      params: value,
    })
  }

  static close(params?: PreviewCloseParam) {
    PromptActionTool.closePreview(params)
  }
}