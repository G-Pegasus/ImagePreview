import { MediaPreviewComponent } from "../components/MediaPreviewComponent";
import { MediaPreviewPromptAction } from "../models/MediaPreviewPromptAction";
import { DefaultImageItem } from "./DefaultImageItem";
import { DefaultMediaModel, DefaultMediaType } from "./DefaultMediaModel";
import { DefaultVideoItem } from "./DefaultViedeoItem";

@Component
export struct DefaultMediaPreview {
  @Require @Prop action: MediaPreviewPromptAction<DefaultMediaModel>

  build() {
    MediaPreviewComponent({
      promptAction: this.action,
      options: this.action.options,
      contentBuilder: this.action.options.contentBuilder ? this.action.options.contentBuilder :
        (item: DefaultMediaModel, index: number) => {
          if (item.type == DefaultMediaType.IMAGE) {
            this.imageBuilder(item, index)
          } else {
            this.videoBuilder(item, index)
          }
        },
      thumbBuilder: this.action.options.thumbBuilder,
      toolBuilder: this.action.options.toolBuilder,
    })
      .width('100%')
      .height('100%')
  }

  @Builder
  imageBuilder(item: DefaultMediaModel, index: number) {
    DefaultImageItem({
      resource: item,
      index: index,
      onLongPressListener: this.action.options.onLongPressListener,
    })
  }

  @Builder
  videoBuilder(item: DefaultMediaModel, index: number) {
    DefaultVideoItem({
      resource: item,
      index: index,
      onLongPressListener: this.action.options.onLongPressListener,
    })
  }
}

@Builder
export function DefaultMediaPreviewBuilder(action: MediaPreviewPromptAction<ESObject>) {
  DefaultMediaPreview({
    action: action,
  })
}