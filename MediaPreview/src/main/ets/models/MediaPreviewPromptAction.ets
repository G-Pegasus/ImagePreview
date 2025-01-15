import { PromptActionBaseBean } from "../utils/PromptActionTool";
import { MediaModel } from "./MediaModel";
import { MediaPreviewOptions } from "./MediaPreviewOptions";

export class MediaPreviewPromptAction<T extends MediaModel> extends PromptActionBaseBean {
  options: MediaPreviewOptions<T>

  constructor(options: MediaPreviewOptions<T>) {
    super()
    this.options = options
  }
}