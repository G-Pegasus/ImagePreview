import { ComponentContent, promptAction } from '@kit.ArkUI'
import { JSON, util } from '@kit.ArkTS'

export interface PromptActionOptions<T extends PromptActionBaseBean> {
  builder: WrappedBuilder<[T]>
  params: T,
}

export abstract class PromptActionBaseBean {
  dialogId: string
  needDismiss: boolean = false

  constructor(dialogId: string = '') {
    if (dialogId === '') {
      dialogId = util.generateRandomUUID()
    }
    this.dialogId = dialogId
  }
}

interface PromptActionInfo {
  dialogId: string
  componentContent: ComponentContent<object>
}

let promptActionInfos: PromptActionInfo[] = []

function getPromptActionInfoByDialogId(dialogId: string): PromptActionInfo | undefined {
  return promptActionInfos.find(item => dialogId == item.dialogId)
}

export class PromptActionTool {
  /**
   * 弹出自定义弹窗
   */
  static async openCustomDialog<T extends PromptActionBaseBean>(uiContext: UIContext ,value: PromptActionOptions<T>): Promise<void> {
    try {
      const promptAction = uiContext.getPromptAction()
      const componentContent = new ComponentContent(uiContext, value.builder, value.params)

      let options: promptAction.BaseDialogOptions = {
        alignment: DialogAlignment.Center,
        autoCancel: true,
        maskColor: Color.Transparent,
        transition: TransitionEffect.IDENTITY,
        keyboardAvoidMode: KeyboardAvoidMode.NONE,
        onWillDismiss: (action: DismissDialogAction) => {
          if (action.reason == DismissReason.PRESS_BACK) {
            value.params.needDismiss = true
          } else if (action.reason == DismissReason.TOUCH_OUTSIDE) {
            value.params.needDismiss = true
          }
          PromptActionTool.updateCustomDialog<T>(value.params)
        },
        onWillDisappear: () => {
          const index = promptActionInfos.findIndex(item => item.dialogId == value.params.dialogId)
          if (index >= 0) {
            promptActionInfos.splice(index, 1)
          } else {
            promptActionInfos.shift()
          }
        }
      }

      if (!PromptActionTool.existsCustomDialog(value.params.dialogId)) {
        promptActionInfos.unshift({
          dialogId: value.params.dialogId,
          componentContent: componentContent
        })
        promptAction.openCustomDialog(componentContent, options)
      }
    } catch (error) {
      console.error('PromptActionUtils', ` openCustomDialog error = ${JSON.stringify(error)}`)
    }
  }

  /**
   * 关闭自定义弹窗
   */
  static async closeCustomDialog(uiContext: UIContext, dialogId?: string): Promise<void> {
    try {
      const promptAction = uiContext.getPromptAction()
      let info: PromptActionInfo | undefined = undefined
      if (dialogId) {
        info = getPromptActionInfoByDialogId(dialogId)
      } else {
        info = promptActionInfos.length > 0 ? promptActionInfos[0] : undefined
      }
      if (info) {
        await promptAction.closeCustomDialog(info.componentContent)
        // @issue #IBAP41  https://gitee.com/lyb5834/media-preview/issues/IBAP41 弹窗关闭后销毁
        info.componentContent.dispose()
      } else {
        console.error('PromptActionUtils', ` closeCustomDialog error = info is undefined`)
      }
    } catch (error) {
      console.error('PromptActionUtils', ` closeCustomDialog error = ${JSON.stringify(error)}`)
    }
  }

  /**
   * 刷新自定义弹窗
   */
  static updateCustomDialog<T extends PromptActionBaseBean>(params: T) {
    let promptActionInfo: PromptActionInfo | undefined = getPromptActionInfoByDialogId(params.dialogId)
    if (promptActionInfo) {
      promptActionInfo.componentContent.update(params)
    }
  }

  /**
   * 是否存在自定义弹窗
   */
  static existsCustomDialog(dialogId: string): boolean {
    let info = getPromptActionInfoByDialogId(dialogId)
    return info != undefined
  }
}