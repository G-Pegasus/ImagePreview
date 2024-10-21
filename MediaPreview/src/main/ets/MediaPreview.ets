import { DefaultMediaPreviewBuilder } from "./default/DefaultMediaPreview";
import { MediaPreviewOptions } from "./models/MediaPreviewOptions";
import { MediaPreviewPromptAction } from "./models/MediaPreviewPromptAction";
import { PromptActionTool } from "./utils/PromptActionTool";

export class MediaPreview {
  static open(uiContext: UIContext, options: MediaPreviewOptions) {
    let value = new MediaPreviewPromptAction(options)
    PromptActionTool.openCustomDialog<MediaPreviewPromptAction>(uiContext,{
      builder: wrapBuilder(DefaultMediaPreviewBuilder),
      params: value,
    })
  }
}