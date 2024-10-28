import { MediaPreviewComponent } from "../components/MediaPreviewComponent";
import { MediaModel } from "../models/MediaModel";
import { MediaPreviewPromptAction } from "../models/MediaPreviewPromptAction";
import { DefaultImageItem } from "./DefaultImageItem";
import { DefaultMediaModel, DefaultMediaType } from "./DefaultMediaModel";
import { DefaultVideoItem } from "./DefaultViedeoItem";

@Component
export struct DefaultMediaPreview {
  @Require @Prop action: MediaPreviewPromptAction

  build() {
    MediaPreviewComponent({
      promptAction: this.action,
      options: this.action.options,
      contentBuilder: (item: MediaModel, index: number) => {
        if ((item as DefaultMediaModel).type == DefaultMediaType.IMAGE) {
          this.imageBuilder(item, index)
        } else {
          this.videoBuilder(item, index)
        }
      },
      thumbBuilder: this.action.options.thumbBuilder,
    })
      .width('100%')
      .height('100%')
  }

  @Builder
  imageBuilder(item: MediaModel, index: number) {
    DefaultImageItem({
      resource: item as DefaultMediaModel,
      index: index,
      onLongPressListener: this.action.options.onLongPressListener,
    })
  }

  @Builder
  videoBuilder(item: MediaModel, index: number) {
    DefaultVideoItem({
      resource: item as DefaultMediaModel,
      index: index,
      onLongPressListener: this.action.options.onLongPressListener,
    })
  }
}

@Builder
export function DefaultMediaPreviewBuilder(action: MediaPreviewPromptAction) {
  DefaultMediaPreview({
    action: action,
  })
}