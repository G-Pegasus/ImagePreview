import { DefaultMediaPreviewBuilder } from "./default/DefaultMediaPreview";
import { MediaPreviewOptions } from "./models/MediaPreviewOptions";
import { MediaPreviewPromptAction } from "./models/MediaPreviewPromptAction";
import { PreviewCloseParam, PromptActionTool } from "./utils/PromptActionTool";

export class MediaPreview {
  static open(uiContext: UIContext, options: MediaPreviewOptions): string {
    let value = new MediaPreviewPromptAction(options)
    PromptActionTool.openCustomDialog<MediaPreviewPromptAction>(uiContext, {
      builder: wrapBuilder(DefaultMediaPreviewBuilder),
      params: value,
    })
    return value.dialogId
  }

  static close(params?: PreviewCloseParam) {
    PromptActionTool.closePreview(params)
  }
}