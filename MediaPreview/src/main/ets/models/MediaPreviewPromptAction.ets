import { PromptActionBaseBean } from "../utils/PromptActionTool";
import { MediaPreviewOptions } from "./MediaPreviewOptions";

export class MediaPreviewPromptAction extends PromptActionBaseBean {
  options: MediaPreviewOptions

  constructor(options: MediaPreviewOptions) {
    super()
    this.options = options
  }
}