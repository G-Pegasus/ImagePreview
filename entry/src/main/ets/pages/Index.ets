@Entry
@Component
struct Index {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack()
  @State models: HomeModel[] = []

  aboutToAppear(): void {
    this.models = [
      {
        name: 'SimpleDemoPage',
        desc: '简单用法demo'
      },
      {
        name: 'SimpleCustomDemoPage',
        desc: '简单自定义demo'
      },
      {
        name: 'CustomDemoPage',
        desc: '完全自定义demo'
      }
    ]
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        List() {
          ForEach(this.models, (item: HomeModel, _index: number) => {
            ListItem() {
              Column() {
                Button(item.desc)
                  .fontSize(20)
                  .onClick(() => {
                    this.pathStack.pushPath({ name: item.name, param: item })
                  })
              }
              .width('100%')
              .height('60vp')
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 16, right: 16 })
            }
          }, (item: HomeModel, index: number) => JSON.stringify(item) + index)
        }
        .width('100%')
        .height('100%')
        .listDirection(Axis.Vertical)

      }
      .margin({ top: 50 })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideNavBar(false)
    .title('MediaPreviewDemo')
  }
}

export interface HomeModel {
  readonly name: string
  readonly desc: string
}