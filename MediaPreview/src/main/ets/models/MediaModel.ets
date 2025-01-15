import { util } from "@kit.ArkTS";

export abstract class MediaModel {
  readonly mediaUniqueId: string = util.generateRandomUUID(true)
}