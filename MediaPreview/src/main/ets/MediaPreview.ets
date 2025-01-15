import { DefaultMediaPreviewBuilder } from "./default/DefaultMediaPreview";
import { MediaModel } from "./models/MediaModel";
import { MediaPreviewOptions } from "./models/MediaPreviewOptions";
import { MediaPreviewPromptAction } from "./models/MediaPreviewPromptAction";
import { PreviewCloseParam, PromptActionTool } from "./utils/PromptActionTool";

export class MediaPreview {
  static open<T extends MediaModel>(uiContext: UIContext, options: MediaPreviewOptions<T>): string {
    let value = new MediaPreviewPromptAction(options)
    PromptActionTool.openCustomDialog<MediaPreviewPromptAction<T>>(uiContext, {
      builder: wrapBuilder(DefaultMediaPreviewBuilder),
      params: value,
    })
    return value.dialogId
  }

  static close(params?: PreviewCloseParam) {
    PromptActionTool.closePreview(params)
  }
}